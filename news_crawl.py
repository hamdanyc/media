import csv
import os
import time
import random
from crawl4ai import AsyncWebCrawler
from dotenv import load_dotenv
import groq
import asyncio

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
                'headline_prompt': row['headline'],
                'link_prompt': row['link'],
                'content_prompt': row['page']
            })
    return news_profiles

# Get website content with proper delays to avoid being blocked
async def get_page_content(url):
    try:
        # Add random delay between requests (1-3 seconds)
        time.sleep(random.uniform(1, 3))
        
        async with AsyncWebCrawler() as crawler:
            result = await crawler.arun(url=url)
        
        return result.html if result else None
        
    except Exception as e:
        print(f"Error fetching {url}: {str(e)}")
        return None

# Analyze the content using LLM with a specific prompt for text extraction
def extract_text_with_llm(html_content, prompt):
    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a content extraction assistant. Follow instructions carefully and extract only the requested information."}, 
                {"role": "user", "content": f"{html_content}\n\n{prompt}"}
            ],
            max_tokens=2000,
            temperature=0.3
        )
        
        if response.choices and len(response.choices) > 0:
            return response.choices[0].message.content.strip()
        
        return None
    except Exception as e:
        print(f"Error extracting content: {str(e)}")
        return None

# Analyze website with LLM model to evaluate extraction quality
def analyze_extraction(base_url, headline_prompt, link_prompt, content_prompt):
    prompt = f"""Analyze the effectiveness of these prompts for {base_url}:
1. Headlines: {headline_prompt}
2. Links: {link_prompt}
3. Content: {content_prompt}

Evaluate if these prompts reliably extract the news elements from HTML documents, and suggest improvements if needed."""

    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are a web scraping analyst evaluating content extraction prompts for news websites."},
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
async def main():
    csv_file = 'news_prof.csv'
    output_file = 'news_daily_output.md'
    
    # Read news profiles
    news_profiles = read_news_profiles(csv_file)
    
    # Prepare results storage
    results = []
    
    for profile in news_profiles:
        portal_name = profile['base_url'].split('/')[2]
        
        print(f"\nProcessing: {profile.get('base_url', 'Unknown Portal')}")
        
        # Analyze extraction quality
        analysis = analyze_extraction(
            profile.get('base_url', ''),
            profile.get('headline_prompt', ''),
            profile.get('link_prompt', ''),
            profile.get('content_prompt', '')
        )
        print(f"Extraction analysis: {analysis[:200]}...")
        
        # Get first page content
        home_page_html = await get_page_content(profile.get('base_url', ''))
        if not home_page_html:
            print("Could not fetch home page")
            continue
        
        # Extract headlines using LLM-only analysis
        headlines_prompt = """Extract only the news headlines from this HTML document. 
Return only a plain text list of headline texts, one headline per line."""
        
        headlines = extract_text_with_llm(home_page_html, headlines_prompt)
        print(f"Found headlines: {headlines}")
        
        # Extract article URLs using LLM-only analysis
        links_prompt = """Extract only the article links from this HTML document. 
Return only a plain text list of full URLs, one URL per line."""
        
        article_urls = extract_text_with_llm(home_page_html, links_prompt)
        print(f"Found article URLs: {article_urls}")
        
        article_contents = []
        article_urls_clean = []
        
        # Process article URLs
        if article_urls and article_urls.strip():
            try:
                article_urls_list = article_urls.strip().split('\n')
                print(f"Extracting content from {len(article_urls_list)} articles")
                
                for article_url in article_urls_list:
                    if not article_url.strip():
                        continue
                    
                    # Get article content
                    article_html = await get_page_content(article_url)
                    
                    if article_html:
                        content_prompt = """Extract only the main content of this article.
Return only plain text content, no HTML, no markdown, and no extra formatting."""
                        
                        content = extract_text_with_llm(article_html, content_prompt)
                        if content:
                            article_contents.append(content)
                            article_urls_clean.append(article_url)
                    
                    # Add random delay between article requests (0.5-1.5 seconds)
                    time.sleep(random.uniform(0.5, 1.5))
            except Exception as e:
                print(f"Error processing article URLs: {str(e)}")
        
        # Generate summaries for all articles
        article_summaries = [generate_summary(content) for content in article_contents]
        
        # Save results for this portal
        results.append({
            'portal_name': portal_name,
            'headlines': [h.strip() for h in headlines.strip().split('\n') if h.strip()],
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
    asyncio.run(main())
