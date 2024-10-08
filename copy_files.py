import paramiko
import os

# Define your server connection parameters
hostname = "dt1.wynton.ucsf.edu"
username = "alina"
private_key_path = "/Users/alinaarzamassky/.ssh/id_rsa"

# Define local and remote file paths
local_base_dir = "/Users/alinaarzamassky/Documents/scoring_function/for_github"
remote_base_dir = "/wynton/group/bks/work/alina/desolv_calc_large/3D_for_work"

# Read the list of directories to process
with open("successful_directories.txt", "r") as file:
    directories = [line.strip() for line in file if line.strip()]

# Establish the SSH client connection
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(hostname, username=username, key_filename=private_key_path)

# Use SFTP for file transfer
sftp = client.open_sftp()

for remote_dir in directories:
    print(f"Processing directory: {remote_dir}")
    
    # Extract directory structure
    local_dir = os.path.join(local_base_dir, os.path.relpath(remote_dir, remote_base_dir))
    os.makedirs(local_dir, exist_ok=True)
    
    # Define files to copy
    files_to_copy = ["interaction_energy.xvg", os.path.basename(remote_dir) + ".mol2"]
    
    # Copy each file
    for file_name in files_to_copy:
        remote_file = os.path.join(remote_dir, file_name)
        local_file = os.path.join(local_dir, file_name)
        try:
            print(f"Copying {remote_file} to {local_file}")
            sftp.get(remote_file, local_file)
        except Exception as e:
            print(f"Error copying {remote_file}: {e}")

# Close the SFTP and SSH connections
sftp.close()
client.close()

print("All directories processed.")

