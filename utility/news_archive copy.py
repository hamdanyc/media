#!/usr/bin/env python3
import os
import re

# Create archive directory if it doesn't exist
os.makedirs('archive', exist_ok=True)

# Extract active .R files from 'thenews' vector in newsdailyBat.R
# with open('newsdailyBat.R', 'r') as f:
#    content = f.read()

content = '''thenews <- c("airtimes",
             "bernama",
             "borneopost",
             "fmt",
             "harakah",
             "kosmo",
             "malaysiakini", 
             "malaysianow",
             "malaysiainsight",
             "newsarawaktribune",
             "roketkini",
             "sarawakvoice", 
             "sinarharian",
             "theAseanPost",
             "themalaymailonline",
             "theRakyatPost",
             "thesundaily",
             "umnoonline",
             "utusan")'''

lines = content.splitlines()
in_thenews_vector = False
thenews_content = []

for line in lines:
    if "thenews <- c(" in line:
        in_thenews_vector = True
        thenews_content = []
        # Extract any quoted strings from this line
        thenews_content.extend(re.findall(r'"(.*?)"', line))
        continue
    if in_thenews_vector:
        if ")" in line:
            in_thenews_vector = False
        # Extract quoted strings from this line
        thenews_content.extend(re.findall(r'"(.*?)"', line))

# Convert to .R filenames
active_files = [f"{name}.R" for name in thenews_content]

# Add explicitly sourced files
active_files += ['news_rs_part.R', 'newsadddb_mongo.R']

# Get all .R files in the current directory, excluding the archive folder
all_r_files = []
for entry in os.listdir('.'):
    if entry.endswith('.R') and not entry.startswith('archive/'):
        all_r_files.append(entry)

# Debug output
print("All .R files found:", all_r_files)
print("Active files found:", active_files)

# Move inactive files to archive
for filename in all_r_files:
    if filename not in active_files and filename != 'newsdailyBat.R':
        os.rename(filename, os.path.join('archive', filename))

print("Inactive .R files have been moved to the 'archive' folder.")
