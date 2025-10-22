import csv
import os
import time
import random
from urllib.parse import urljoin
import requests
from bs4 import BeautifulSoup
import markdownify
from dotenv import load_dotenv
import groq

# Load environment variables from .env file
load_dotenv()

# Set up Groq API client
groq_api_key = os.getenv("GROQ_API_KEY")
client = groq.Groq(api_key=groq_api_key)

# Set up user agent header
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# Read news profiles from CSV file
def read_news_profiles(csv_file):
    news_profiles = []
    with open(csv_file, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Clean the URL by removing empty strings
            clean_url = row['url'].rstrip('/')
            if not clean_url.startswith('http'):
                clean_url = 'https://' + clean_url
                
            news_profiles.append({
                'base_url': clean_url,
                'headline_selector': row['headline'],
                'link_selector': row['link'],
                'content_selector': row['page']
            })
    return news_profiles

# Get website content with proper delays to avoid being blocked
def get_page_content(url):
    try:
        # Add random delay between requests (1-3 seconds)
        time.sleep(random.uniform(1, 3))
        
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {url}: {str(e)}")
        return None

# Extract headlines from a webpage
def extract_headlines(soup, headline_selector):
    try:
        headlines = soup.select(headline_selector)
        return [h.get_text(strip=True) for h in headlines if h.get_text(strip=True)]
    except Exception as e:
        print(f"Error extracting headlines: {str(e)}")
        return []

# Extract article URLs from a webpage
def extract_article_urls(soup, link_selector):
    try:
        links = soup.select(link_selector)
        return [a.get('href') for a in links if a.get('href') and not a.get('href').startswith('#')]
    except Exception as e:
        print(f"Error extracting article URLs: {str(e)}")
        return []

# Extract article content based on selectors
def extract_article_content(soup, selectors):
    try:
        content = []
        all_selectors = selectors.split(',') if ',' in selectors else [selectors]
        
        for selector in all_selectors:
            elements = soup.select(selector.strip())
            content.extend([e.get_text(strip=True) for e in elements])
        
        # Join all content and clean up
        full_content = ' '.join(content)
        cleaned_content = ' '.join(full_content.split())
        paragraphed_content = '\n\n'.join(cleaned_content.split('. ') if '.' in cleaned_content else cleaned_content.split(' '))
        
        # Convert to markdown and clean up
        return markdownify.markdownify(paragraphed_content, heading_style="ATX")
    except Exception as e:
        print(f"Error extracting article content: {str(e)}")
        return None

# Analyze website with LLM model to ensure elements are valid
def analyze_web_elements(base_url, headline_selector, link_selector, content_selector):
    prompt = f"""Analyze the following web page structure for {base_url} and determine if the elements:
1. Headline selector: {headline_selector}
2. Link selector: {link_selector}
3. Content selector: {content_selector}

Check if these selectors will reliably find the news headlines, article links, and article content on the web pages. Evaluate if the selectors are valid and will consistently extract the intended content across multiple pages."""

    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a web scraping analyst evaluating CSS selectors for news websites."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=200,
            temperature=0.3
        )
        
        analysis = response.choices[0].message.content.strip()
        return analysis
    
    except Exception as e:
        print(f"Error analyzing web elements: {str(e)}")
        return "Error analyzing web elements with LLM model"

# Generate summary using LLM
def generate_summary(content):
    prompt = f"Create a concise summary of the following news article content:\n\n{content}"
    
    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a news summarizer. Create concise summaries of news articles."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=500,
            temperature=0.3
        )
        
        summary = response.choices[0].message.content.strip()
        return summary
    except Exception as e:
        print(f"Error generating summary: {str(e)}")
        return "Error generating summary for this article."

# Generate markdown report
def generate_markdown_report(news_data):
    markdown_content = "# News Daily Content Report\n\n"
    
    for entry in news_data:
        markdown_content += f"## {entry['portal_name']}\n\n"
        markdown_content += "### Sample Headlines\n\n"
        for i, headline in enumerate(entry['headlines'], 1):
            markdown_content += f"{i}. {headline}\n\n"
        
        markdown_content += "### Article Summaries\n\n"
        for i, (content, url) in enumerate(zip(entry['contents'], entry['urls']), 1):
            markdown_content += f"{i}. {content} [View article]({url})\n\n"
    
    return markdown_content

# Main function
def main():
    csv_file = 'news_prof.csv'
    output_file = 'news_daily_output.md'
    
    # Read news profiles
    news_profiles = read_news_profiles(csv_file)
    
    # Prepare results storage
    results = []
    
    for profile in news_profiles:
        portal_name = next((k for k, v in profile.items() if 'url' in k), None)
        if portal_name:
            portal_name = profile[portal_name].split('/')[2]
        
        print(f"\nProcessing: {profile.get('base_url', 'Unknown Portal')}")
        
        # Analyze web elements
        analysis = analyze_web_elements(
            profile.get('base_url', ''),
            profile.get('headline_selector', ''),
            profile.get('link_selector', ''),
            profile.get('content_selector', '')
        )
        print(f"Selector analysis: {analysis[:200]}...")
        
        # Get first page content
        home_page_html = get_page_content(profile.get('base_url', ''))
        if not home_page_html:
            print("Could not fetch home page")
            continue
            
        home_soup = BeautifulSoup(home_page_html, 'html.parser')
        
        # Extract headlines
        headlines = extract_headlines(home_soup, profile['headline_selector'])
        print(f"Found {len(headlines)} headlines")
        
        # Extract article URLs
        article_urls = extract_article_urls(home_soup, profile['link_selector'])
        article_contents = []
        article_urls_clean = []
        
        if article_urls:
            print(f"Extracting content from {len(article_urls)} articles")
        
        for article_url in article_urls:
            # Clean URL if needed
            if not article_url.strip():
                continue
            
            # Resolve relative URLs
            full_url = urljoin(profile.get('base_url', ''), article_url.strip())
            
            # Get article content
            article_html = get_page_content(full_url)
            
            if article_html:
                article_soup = BeautifulSoup(article_html, 'html.parser')
                content = extract_article_content(article_soup, profile['content_selector'])
                
                if content:
                    article_contents.append(content)
                    article_urls_clean.append(full_url)
            
            # Add random delay between article requests (0.5-1.5 seconds)
            time.sleep(random.uniform(0.5, 1.5))
        
        # Generate summaries for all articles
        article_summaries = [generate_summary(content) for content in article_contents]
        
        # Save results for this portal
        results.append({
            'portal_name': portal_name,
            'headlines': headlines[:5],  # Limit to 5 headlines
            'contents': article_summaries,  # Summaries for all articles
            'urls': article_urls_clean  # URLs for all articles
        })
    
    # Generate markdown report
    markdown_report = generate_markdown_report(results)
    
    # Write markdown file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(markdown_report)
    
    print(f"\nReport generated successfully! Results saved to: {output_file}")

if __name__ == "__main__":
    main()
