import requests
import json
from bs4 import BeautifulSoup
import markdownify
from urllib.parse import urljoin
from dotenv import load_dotenv
import os
import time
import random

# Load environment variables if needed
load_dotenv()

def extract_news_data(url):
    """
    Extract news headlines, article links, and article content
    from a given URL and format it into a dictionary.
    """
    try:
        # Add random delay between requests (1-3 seconds)
        time.sleep(random.uniform(1, 3))

        # Fetch the web page
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        html = response.text

        # Parse HTML
        soup = BeautifulSoup(html, "html.parser")

        # Determine source (based on URL)
        source = url.split("//")[-1].split("/")[0]  # Simple source extraction from URL

        # Extract title
        title = soup.title.string if soup.title else "Unknown Title"

        # Extract headlines and filter out empty or irrelevant entries
        headlines = [h.get_text(strip=True) for h in soup.select("h1, h2, h3") if h.get_text(strip=True)]
        headlines = list(set(headlines))  # Remove duplicates
        headlines = headlines[:5]  # Limit to 5 headlines

        # Extract article links and normalize them
        link_elements = soup.select("a")
        raw_links = [a.get("href") for a in link_elements if a.get("href") and not a.get("href").startswith("#")]
        article_links = [urljoin(url, link).strip() for link in raw_links if (link.startswith("http"))]
        article_links = list(set(article_links))  # Remove duplicates
        article_links = article_links[:5]  # Limit to top 5

        # Extract article content for each valid link
        article_contents, valid_article_links = [], []
        for article_url in article_links:
            try:
                # Simulate random delay between subsequent requests
                time.sleep(random.uniform(0.5, 1.5))

                # Retrieve and parse the article content
                article_response = requests.get(article_url, timeout=10)
                article_response.raise_for_status()
                article_html = BeautifulSoup(article_response.text, "html.parser")

                # Convert HTML to markdown
                content = markdownify.markdownify(str(article_html), escape_ansi=False, heading_style="ATX")
                if content.strip():
                    article_contents.append(content)
                    valid_article_links.append(article_url)
            except Exception as e:
                print(f"Failed to extract articles from {article_url}: {str(e)}")
                continue

        # Build the structured result
        news_data = {
            "source": source,
            "title": title,
            "url": url,
            "headlines": headlines,
            "article_links": valid_article_links,
            "article_contents": article_contents,
        }
        return {"status": "success", "data": news_data}

    except Exception as e:
        return {"status": "error", "reason": str(e), "data": None}


def process_urls(urls):
    """
    Process a list of URLs using the extract_news_data function.
    Returns a list of dictionaries containing the extracted data.
    """
    results = []
    for url in urls:
        print(f"Processing {url}")
        result = extract_news_data(url)
        results.append(result)
    return results


def save_output_to_json(output_data, output_file="news_data_output.json"):
    """
    Save processed data to a JSON file.
    """
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=4)
    print(f"Data saved to {output_file}")


def upload_to_mongodb(data, db_name="news_db", collection_name="news_data"):
    """
    Upload data to a MongoDB collection via a cloud instance (e.g., MongoDB Atlas).
    Ensure `pymongo` is installed and MongoDB URI is loaded into the environment or hardcoded.
    """
    try:
        from pymongo import MongoClient
    except ImportError:
        raise ImportError("pymongo is not installed. Install with 'pip install pymongo'")

    try:
        client = MongoClient("mongodb+srv://your_user:your_password@cluster0.mongodb.net/myFirstDatabase?retryWrites=true&w=majority")
        db = client[db_name]
        collection = db[collection_name]
        # Filter only success entries
        valid_entries = [entry["data"] for entry in data if entry.get("status") == "success"]
        collection.insert_many(valid_entries)
        client.close()
        print(f"Uploading to MongoDB: {len(valid_entries)} entries inserted")
    except Exception as e:
        print(f"Error uploading to MongoDB: {str(e)}")


# Example Usage:
if __name__ == "__main__":
    # Input URLs to extract news data
    urls = [
        "https://news.example1.com",
        "https://news.example2.com"
    ]

    # Run the extraction process
    result_data = process_urls(urls)

    # Save as JSON output
    save_output_to_json(result_data)

    # Optional: upload to MongoDB
    upload_to_mongodb(result_data)
