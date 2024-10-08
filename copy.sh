#!/bin/bash

# Define your HPC login and destination directory
hpc_login="alina@dt1.wynton.ucsf.edu"
dest_dir="/Users/alinaarzamassky/Documents/scoring_function/for_github/"
success_file="/Users/alinaarzamassky/Documents/scoring_function/for_github/successful_directories.txt"

# Confirm file reading
if [[ ! -f "$success_file" ]]; then
    echo "Error: Successful directories file not found at $success_file."
    exit 1
fi

echo "Starting to process directories from $success_file"
echo "-----------------------------------------"

# Iterate over each line in successful_directories.txt
while IFS= read -r zinc_dir; do
    echo "Processing directory: $zinc_dir"
    
    # Define paths to the required files
    xvg_file="$zinc_dir/interaction_energy.xvg"
    mol2_file=$(ssh "$hpc_login" "find '$zinc_dir' -maxdepth 1 -type f -name 'ZINC*.mol2'")

    # Create a matching directory structure on your local machine
    local_subdir="${dest_dir}${zinc_dir#/wynton/group/bks/work/alina/desolv_calc_large/3D_for_work/}"
    mkdir -p "$local_subdir"
    
    # Check if the interaction_energy.xvg file exists before copying
    if ssh "$hpc_login" "[ -f '$xvg_file' ]"; then
        echo "Copying $xvg_file to $local_subdir/"
        scp -v "$hpc_login:$xvg_file" "$local_subdir/"
    else
        echo "File not found: $xvg_file"
    fi
    
    # Check if the ZINC*.mol2 file exists before copying
    if [ -n "$mol2_file" ]; then
        echo "Copying $mol2_file to $local_subdir/"
        scp -v "$hpc_login:$mol2_file" "$local_subdir/"
    else
        echo "ZINC*.mol2 file not found in $zinc_dir"
    fi

    echo "Completed transfer for $zinc_dir"
    echo "-----------------------------------------"
done < "$success_file"

echo "All directories processed."

