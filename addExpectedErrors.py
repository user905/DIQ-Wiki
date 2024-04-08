# This python script reads in each file from the /tests directory, which have names like DIQ_Test_<testname>.json or DIQ_Test_<testname>-<testnumber>.json. It then looks in the /results/correct directory to find a matching results file which has the same name but prepended with "results_". It then itearates through each entry in the json array which represents a test that the file triggered. For each test, it looks at the results_rowdata array which contains an array of rows. Those rows match up with rows in the test file. It then finds that row in the test file and adds an "expected_errors" property containing the UID of that test. It saves the updated test file and continues.

import os
import json

# Set the directories for tests and correct results
test_dir = "tests"
results_dir = "results/correct"

def find_matching_row(row_to_find, test_rows):
    for index, row in enumerate(test_rows):
        if row == row_to_find:
            return index
    return None

def main():
    # Iterate through all files in the /tests directory
    for test_file_name in os.listdir(test_dir):
        if not (test_file_name.startswith("DIQ_Test_") and test_file_name.endswith(".json")):
            continue
        
        # Find the matching results file name
        result_file_name = f"results_{test_file_name}"

        # Read both the test and results files
        with open(os.path.join(test_dir, test_file_name), 'r') as test_file:
            test_data = json.load(test_file)
        
        with open(os.path.join(results_dir, result_file_name), 'r') as result_file:
            result_data = json.load(result_file)

        print(f"Processing {test_file_name}...")
        # Iterate through each entry in the JSON array (test_results)
        for result_row in result_data:
            uid = result_row["DIQ_ID"]

            # Parse the results_rowdata string to obtain an array of rows
            rows_to_update = json.loads(result_row["results_rowdata"])

            # Iterate over the rows' data in rows_to_update and update each with expected errors
            for row_data in rows_to_update:
                matching_index = find_matching_row(row_data, test_data)
                
                if matching_index is not None:
                    test_data[matching_index]["expected_errors"] = uid

        # Save the updated test file
        with open(os.path.join(test_dir, test_file_name), 'w') as test_file:
            json.dump(test_data, test_file, indent=2)

if __name__ == "__main__":
    main()

