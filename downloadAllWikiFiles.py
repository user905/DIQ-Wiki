import os
import json
import requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

def fetch_all_pages():
    print(f"Fetching all pages")
    
    url = 'https://wiki.pars.doe.gov'  # Initialize this with your actual wikijs URL

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f"Bearer {os.getenv('WIKIJS_API_KEY')}"
    }

    # Query for getting a single page by its path
    query = """
        query {
            pages {
                list (orderBy: TITLE) {
                    id
                    path
                    title
                }
            }
        }
    """

    response = requests.post(url + '/graphql', headers=headers, json={"query": query})
    response_json = response.json()

    if not response_json:
        print("Error: Response is empty")
        return None
    
    DIQs_pages = [page for page in response_json['data']['pages']['list'] if 'DIQs' in page['path']]
    
    # Write JSON data into file
    with open('published_DIQs.json', 'w') as outfile:
        json.dump(DIQs_pages, outfile)

def process_pages():
    # Load pages data from JSON file
    with open('published_DIQs.json') as json_file:
        pages = json.load(json_file)

    # Loop through pages and download each one
    for page in pages:
        path_parts = page['path'].split('/')
        page_id = page['id']
        ds = path_parts[1] if len(path_parts) > 1 else 'index'
        name = path_parts[2] if len(path_parts) > 2 else 'index'
        
        download_page_content(page_id, ds, name)

def download_page_content(page_id, ds, name):
    print(f"Downloading content of page with ID {page_id}...")

    url = 'https://wiki.pars.doe.gov'  # Initialize this with your actual wikijs URL

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f"Bearer {os.getenv('WIKIJS_API_KEY')}"
    }

    query_single_by_id = """
        query ($id: Int!) {
            pages {
                single(id: $id) {
                    title,
                    description,
                    content
                }
            }
        }
    """
  
    variables = {"id": page_id}

    payload = {"query" : query_single_by_id, "variables" : variables}
    
    response = requests.post(url + '/graphql', headers=headers, json=payload)
    response_json = response.json()
    # print(response_json)

    if 'data' in response_json and 'pages' in response_json['data'] and 'single' in response_json['data']['pages']:
        # print('here')
        base_dir = './wikijs_published'
        directory = os.path.join(base_dir, ds) 

        if not os.path.exists(directory):
            os.makedirs(directory)

        filepath = os.path.join(directory, f"{name}.md")

        with open(filepath, 'w', encoding='utf-8') as file:
            file.write(response_json['data']['pages']['single']['content'])
        print(f"The content was downloaded and saved to {filepath}.")
        return True
    else:
        print(f"Error downloading page content.")
        return False


fetch_all_pages()
process_pages()
