#!/bin/bash

set -e

# Get the file with the notebook to execute
file=$(echo "$1")

# Store the command line arguments in a file
echo "${@:2}" | tr -d "\n" > arguments.txt

# Execute the notebook and convert it to HTML
jupyter nbconvert --to html --execute $file.ipynb

# Move the HTML to the destination directory
mv $file.html $(cat destination.txt)
