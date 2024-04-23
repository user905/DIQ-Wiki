import os
import shutil

def copy_index_files(src_dir, dest_dir):
    # Iterate over all directories in the source directory
    for dir_name in os.listdir(src_dir):
        src_subdir = os.path.join(src_dir, dir_name)
        dest_subdir = os.path.join(dest_dir, dir_name)

        # Check if it's actually a directory
        if os.path.isdir(src_subdir):
            if os.path.exists(dest_subdir):  # Ensure destination sub-directory exists
                src_file = os.path.join(src_subdir, 'index.md')
                dest_file = os.path.join(dest_subdir, 'index.md')

                # If index.md file exists in the source sub-directory then copy it to the destination
                if os.path.isfile(src_file):
                    shutil.copy2(src_file, dest_file)
                else:
                    print(f"No 'index.md' found in {src_subdir}")
            else:
                print(f"Destination subdirectory does not exist: {dest_subdir}")

# Define your source and destination directories
source_directory = 'wikijs_v4'
destination_directory = 'wikijs'

copy_index_files(source_directory, destination_directory)