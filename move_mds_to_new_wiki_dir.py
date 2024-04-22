import shutil
import os

# List of ID's
ids = [
    "9040203",
"9180591",
"1190593",
"1030097",
"1200595",
"1040215",
"1030108",
"1040321",
"1050236",
"9080394",
"1060256",
"1010018",
"9060283",
"9040134",
"1040145",
"9060301",
"1060259",
"1040160",
"1040166",
"1040167",
"1040177",
"1040178",
"9030068",
"1040192",
"1040193",
"1030089",
"1060249",
"9060297",
"9010016",
"9060296",
"9030102",
"1040139",
"1060246",
"9060292",
"1030046",
"9040196",
"1030074",
"9040200",
"1040220",
"9040223",
"9040187",
"9060287",
"9040216",
"9040219",
"1040176",
"9040222",
"9070362",
"9200596",
"1040107",
"9030072",
"1050234",
"1060261",
"9030100",
"9010015",
"9070369",
"1060260",
"9040224",
"1060237",
"9040214",
"9050282",
"9010029",
"1060247",
"9060284",
"9010014",
"1030075",
"1030088",
"9040217",
"1030081",
"1020040",
"9010013",
"9060294",
"9050280",
"9060298",
"9050283",
"1030091",
"9060293",
"9060300",
"9060290",
"9170579",
"1080404",
"9050281",
"9030324",
"9060291",]

source_directory = "./wikijs_v4/DS"
target_directory = "./wikijs/"

for id in ids:
    # Get second digit
    second_digit = id[1]
    # Get third digit
    third_digit = id[2]

    # Create target folder name using 'DS' + third digit
    target_folder_name = "DS" +second_digit + third_digit

    # Create source file path
    source_file_path = source_directory + second_digit + third_digit + "/" + id + ".md"

    # Create target file path
    target_file_path = os.path.join(target_directory, target_folder_name)

    # Ensure target dir exists
    os.makedirs(target_file_path, exist_ok=True)

    # Define full target file path including the filename
    full_target_file_path = os.path.join(target_file_path, id + ".md")

    # Check if the source file exists
    if os.path.isfile(source_file_path):
        # Check if the file does not already exist in the target path
        if not os.path.isfile(full_target_file_path):
            # Copy the file to target path, maintaining original file name
            shutil.copy2(source_file_path, full_target_file_path)
        else:
            print(f"File {full_target_file_path} already exists, skipping...")
    else:
        print(f"Source file {source_file_path} does not exist, skipping...")
