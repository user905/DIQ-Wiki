import os
import sys
import pyodbc
import logging
from dotenv import load_dotenv
import re
import xml.etree.ElementTree as ET
import json

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Load environment variables from .env file
load_dotenv()

# Initialize diq_data
diq_data = {}

# Get connection string from environment variable
CONNECTION_STRING = os.getenv("CONNECTION_STRING")

# Connect to Azure MSSQL server using the connection string
try:
    connection = pyodbc.connect(CONNECTION_STRING)
except Exception as e:
    logging.error(f"Error connecting to database: {e}")
    sys.exit(1)

logging.info("Connected to database successfully")

# Create a cursor object
cursor = connection.cursor()

# Create /diqs folder in the current directory if not exists
diqs_path = os.path.join(os.getcwd(), "diqs_v4")
os.makedirs(diqs_path, exist_ok=True)

logging.info(f"Created diqs folder at path: {diqs_path}")

# Delete all files in the /diqs folder
for filename in os.listdir(diqs_path):
    file_path = os.path.join(diqs_path, filename)
    try:
        if os.path.isfile(file_path):
            os.unlink(file_path)
            logging.info(f"Deleted file: {file_path}")
    except Exception as e:
        logging.error(f"Error deleting file {file_path}: {e}")

# Retrieve functions with name starting with 'fnDIQ'
query = """
SELECT ROUTINE_NAME, OBJECT_DEFINITION(OBJECT_ID(ROUTINE_NAME)) AS ROUTINE_DEFINITION
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME LIKE 'fnDIQ%'
"""

cursor.execute(query)
logging.info("Executed query to retrieve functions")

# Fetch the results
results = cursor.fetchall()
logging.info(f"Number of rows fetched: {len(results)}")

# Print the function definitions and save them in diqs folder
for row in results:
    function_name = row.ROUTINE_NAME
    function_definition = row.ROUTINE_DEFINITION.strip() # using ROW. (dot notation) to access column for readability 

    logging.info(f"Function name: {function_name}")
   # logging.info(f"Function definition: {function_definition}")

    file_path = os.path.join(diqs_path, f"{function_name}.sql")

    with open(file_path, "w",  encoding="utf-8") as file:
        file.write(function_definition)

    logging.info(f"Saved function {function_name} to file: {file_path}")

     # Extract the XML content using regex
    xml_content = re.search(r"<documentation>([\s\S]+)</documentation>", function_definition)

    if xml_content:
        try:
            # Parse the XML content
            root = ET.fromstring(xml_content.group(0))

            diq_info = {}
            for child in root:
                # Use the tag names as keys and text values as the corresponding dictionary values
                diq_info[child.tag] = child.text.strip() if child.text else ''

            # Add diq_info to the diq_data dictionary
            diq_data[function_name] = diq_info
        except ET.ParseError as e:
            logging.error(f"Error parsing XML for {function_name}: {e}")

test_files_path = os.path.join(os.getcwd(), "tests")

if os.path.exists(test_files_path):
    for filename in os.listdir(test_files_path):
        # Check if the file format matches DIQ_Test_<function name>.json
        match = re.match(r"DIQ_Test_(.+)\.json", filename)
        if match:
            fn_name = match.group(1)
            # If a DIQ entry exists for the matched function name, add "test" property with the test file path
            if fn_name in diq_data:
                test_file_path = os.path.join(test_files_path, filename)
                diq_data[fn_name]["test"] = test_file_path
else:
    logging.warning("The /tests folder doesn't exist.")

# Save the parsed diq_data as a JSON file
with open("diq_data.json", "w") as json_file:
    json.dump(diq_data, json_file, indent=4)


# Close the connection
connection.close()

logging.info("Functions have been successfully downloaded and saved to files in the diqs folder.")
