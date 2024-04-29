import os
import json
import requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

def fetch_existing_page_id(path, locale='en'):
    print(f"Fetching existing page at path {path}...")
    
    url = 'https://wiki.pars.doe.gov'  # Initialize this with your actual wikijs URL

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f"Bearer {os.getenv('WIKIJS_API_KEY')}"
    }
    
    # Query for getting a single page by its path
    query_single_by_path = """
        query ($path: String!, $locale: String!) {
            pages {
              singleByPath(path: $path, locale: $locale) {
                id
              }
            }
          }
    """

    variables = {
        "path": path,
        "locale": locale
    }

    payload = {"query" : query_single_by_path, "variables" : variables}
    
    response = requests.post(url + '/graphql', headers=headers, json=payload)
    response_json = response.json()

    if not response_json:
        print("Error: Response is empty")
        return None

    data = response_json.get('data')
    print(data)
    if not data:
        print("Error: 'data' missing from response")
        return None

    pages = data.get('pages')
    if not pages:
        print("Error: 'pages' missing from data")
        return None

    singleByPath = pages.get('singleByPath')
    if not singleByPath:
        print("Error: 'singleByPath' missing from pages")
        return None

    if 'id' not in singleByPath:
        print("'id' not found in singleByPath")
        return None

    return singleByPath['id']

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

excluded_files = ['index.md', 'alert.md', 'error.md', 'warning.md']

for root, dirs, files in os.walk("./wikijs"):
    for file in files:
        if file.endswith(".md") and file not in excluded_files:
            ds = os.path.basename(root)
            name = os.path.splitext(file)[0]
            path = f"DIQs/{ds}/{name}"
            
            existing_page_id = fetch_existing_page_id(path)
            
            if existing_page_id is None:
                continue
                
            download_page_content(existing_page_id, ds, name)  # Passing 'ds' and 'name' as extra parameters