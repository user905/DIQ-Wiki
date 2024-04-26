import os
import json
import requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

ENABLE_UPDATE=False

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
    
    if 'data' in response_json and 'pages' in response_json['data'] and 'singleByPath' in response_json['data']['pages'] and 'id' in response_json['data']['pages']['singleByPath']:
        return response_json['data']['pages']['singleByPath']['id']
    else:
        print(f"Error fetching page ID: {response_json}")
        return None


# Create or update a page on the wiki
# @param path The path of the page (e.g. "DIQs/DS01")
# @param title The title of the page
# @param subtitle The subtitle of the page
# @param severity The severity of the page (e.g. "error", "warning", "alert")
# @param content The content of the page
# @param editor The editor to use for the page ("markdown" or "html")
# @param ispublished Whether the page should be published or not
def create_or_update_page(path, title, subtitle, severity, content, editor='markdown', ispublished=True, 
                          isprivate=False, locale="en", tags=None, ds=None):
    
    print(f"Creating or updating page at {path}...")
    
    url = 'https://wiki.pars.doe.gov'  # Initialize this with your actual wikijs URL

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f"Bearer {os.getenv('WIKIJS_API_KEY')}"
    }
    
    # Mutation for creating page
    query_create = """
   mutation ($content: String!, $description: String!, $editor: String!, $isPublished: Boolean!,
          $isPrivate: Boolean!, $locale: String!, $path: String!, $tags: [String]!, $title: String!) 
        {
        pages {
            create(
                content: $content,
                description: $description,
                editor: $editor,
                isPublished: $isPublished,
                isPrivate: $isPrivate,
                locale: $locale,
                path: $path,
                tags: $tags,
                title: $title) 
            {
            page {
                id
            }
            responseResult {
                succeeded,
                errorCode,
                slug,
                message
            },
            }
        }
        }
    """

    # Mutation for updating page
    query_update = """
    mutation ($id: Int!, $content: String!, $description: String!, $editor: String!, $isPublished: Boolean!,
          $isPrivate: Boolean!, $locale: String!, $path: String!, $tags: [String]!, $title: String!)
        {
        pages {
            update(
                id: $id,
                content: $content,
                description: $description,
                editor: $editor,
                isPublished: $isPublished,
                isPrivate: $isPrivate,
                locale: $locale,
                path: $path,
                tags: $tags,
                title: $title)
            {
            page {
                id
            }
            responseResult {
                succeeded,
                errorCode,
                slug,
                message
            },
            }
        }
        }
    """

    variables = {
        "content": content,
        "description": subtitle,
        "editor": editor,
        "isPublished": ispublished,
        "isPrivate": isprivate,
        "locale": locale,
        "path": path,
        "tags": [] if severity is None and tags is None else (['Severity: ' + severity, ds] if tags is None else tags),
        "title": title
    }

    payload = {"query" : query_create, "variables" : variables}
    
    response = requests.post(url + '/graphql', headers=headers, json=payload)
    response_json = response.json()

    print(response_json)
    
    if response_json['data']['pages']['create']['responseResult']['succeeded'] == True:
        print(f"Page created with id {response_json['data']['pages']['create']['page']['id']}")
        return True
    elif response_json['data']['pages']['create']['responseResult']['slug'] == 'PageDuplicateCreate' and ENABLE_UPDATE==True:
        # Since we don't receive an ID in case of duplication error, you need to handle fetching the existing page ID here.
        existing_page_id = fetch_existing_page_id(path)
        variables["id"] = existing_page_id
        payload = {"query" : query_update, "variables" : variables}
        response = requests.post(url + '/graphql', headers=headers, json=payload)
        response_json = response.json()
        if response_json['data']['pages']['update']['responseResult']['succeeded'] == True:
            print(f"Page updated with id {existing_page_id }")
            return True
        else:
            print(f"Error updating page: {response_json['data']['pages']['update']['responseResult']}")
    elif response_json['data']['pages']['create']['responseResult']['slug'] == 'PageDuplicateCreate' and ENABLE_UPDATE==False:
        print(f"Not updating existing page as that function is disabled: {response_json['data']['pages']['create']['responseResult']}")
        return True
    else:
        print(f"Error creating page: {response_json['data']['pages']['create']['responseResult']}")
        return False

count=0

with open('diq_data.json', 'r') as json_file:
    data = json.load(json_file)

# remove the 'wiki' property from items
for key, item in data.items():
    if 'wiki' in item:
        del item['wiki']
        
# write back to the file
with open('diq_data.json', 'w') as json_file:
    json.dump(data, json_file)


for root, dirs, files in os.walk("./wikijs"):
    print(count)
    for file in files:
        if file.endswith(".md"):
            path = os.path.join(root, file)
            
            name = file.replace('.md', '')
            try:
                with open(path, 'r') as file_content:
                    content = file_content.read()
            except IOError:
                print(f"Could not read file: {path}")
                break
                    

            if(name == 'index'):
                ds = path[-13:-9]
                if(ds[0:2] == "DS"):
                    path=f"DIQs/{ds}"
                    create_or_update_page(path, ds, "", None, content)
                else:
                    path="DIQs"
                    create_or_update_page(path, "DIQs", "", None, content)
                count+=1
            
            if(name == "error" or name == "warning" or name == "alert"):
                path=f"DIQs/{name}"
                create_or_update_page(path, f"{name.upper()} DIQs", "", None, content) 

            
            with open('diq_data.json', 'r') as json_file:
                data = json.load(json_file)

                for key, item in data.items():
                    if "UID" in item:
                        if item['UID'] == name:
                            title = item['title']
                            subtitle = item['summary']
                            severity = item['severity']
                            ds = item['table'].split()[0]
                            path=f"DIQs/{ds}/{name}"
                                
                            success = create_or_update_page(path, title, subtitle, severity, content, ds=ds)
                            if success:
                                with open('diq_data.json', 'w') as json_file:
                                    item['wiki'] = 'generated'
                                    json.dump(data, json_file)
                            count+=1
                            break
            