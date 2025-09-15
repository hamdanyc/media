#!/usr/bin/awk -f
# This script extracts news article information from R source code
# It looks for URL, headline, link, and page information

BEGIN {
    FS="\""
    # Initialize array to store values
    i["url"] = ""
    i["http"] = ""
    i["headline"] = ""
    i["link"] = ""
    i["page"] = ""
}

# Look for URL in first 10 lines is found
NR < 9 && /url/ {
    i["http"] = $2
}

# Look for URL in first 13 lines when 'read_html' is found
(NR > 7 && NR < 13) && /url|read_html/ {
    i["url"] = $2
}

# Look for headline in first 13 lines with specific functions
NR < 12 && /read_html|html_nodes|html_elements/ {
    i["headline"] = $2
}

# Look for link in first 15 lines with specific functions
NR < 15 && /html_nodes|html_elements/ {
    i["link"] = $2
}

# Look for page information after line 15 with 'html_node'
NR > 20 && /html_node/ {
    i["page"] = $2
}

END {
    # Print collected information in CSV format
    if (i["http"] == "")
      print i["url"]"," i["headline"]"," i["link"]"," i["page"]
    else
      print i["http"]"," i["headline"]"," i["link"]"," i["page"]
}
