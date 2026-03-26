#!/usr/bin/env python3
"""
URL scraper using curl_cffi and html2text for markdown conversion.
Uses curl_cffi TLS impersonation for broad site compatibility.

Usage:
    scripts/.venv/bin/python scripts/url_scraper.py <url> <output_file>
    scripts/.venv/bin/python scripts/url_scraper.py --images <url> <output_dir>
    scripts/.venv/bin/python scripts/url_scraper.py --batch <json_file>

--images mode downloads page text as markdown AND all content images
into <output_dir>/images/, with markdown referencing local paths.

Batch JSON format:
    [
        {"url": "https://example.com/page1", "output": "docs/references/page1.md"},
        {"url": "https://example.com/page2", "output": "docs/references/page2.md"}
    ]
"""

import json
import re
import sys
import time
from pathlib import Path
from urllib.parse import urljoin, urlparse

import html2text
from curl_cffi import requests
from lxml import html as lxml_html


def make_converter(*, include_images=False):
    c = html2text.HTML2Text()
    c.body_width = 0
    c.ignore_links = False
    c.ignore_images = not include_images
    c.ignore_tables = False
    c.single_line_break = True
    return c


# CSS-selector-like content extraction using lxml
CONTENT_SELECTORS = [
    './/div[contains(@class, "faqtext")]',       # GameFAQs
    './/div[contains(@class, "mw-parser-output")]',  # Fandom/MediaWiki
    './/article',
    './/main',
    './/div[@id="content"]',
    './/body',
]


def extract_main_content(page_html):
    tree = lxml_html.fromstring(page_html)
    for xpath in CONTENT_SELECTORS:
        elements = tree.xpath(xpath)
        if elements:
            return lxml_html.tostring(elements[0], encoding="unicode")
    return page_html


def clean_markdown(md):
    lines = md.split("\n")
    cleaned = []
    blank_count = 0
    for line in lines:
        if line.strip() == "":
            blank_count += 1
            if blank_count <= 2:
                cleaned.append(line)
        else:
            blank_count = 0
            cleaned.append(line)
    return "\n".join(cleaned).strip()


def extract_image_urls(page_html, base_url):
    """Extract image URLs from HTML content, resolving relative URLs."""
    tree = lxml_html.fromstring(page_html)
    # Find content area first
    content_el = None
    for xpath in CONTENT_SELECTORS:
        elements = tree.xpath(xpath)
        if elements:
            content_el = elements[0]
            break
    if content_el is None:
        content_el = tree

    images = []
    for img in content_el.xpath('.//img'):
        src = img.get('src') or img.get('data-src') or ''
        if not src:
            continue
        # Skip tiny icons, tracking pixels, and SVG placeholders
        if any(skip in src for skip in ['data:image', '/tracking/', '/pixel']):
            continue
        # Resolve relative URLs
        full_url = urljoin(base_url, src)
        # For Fandom, prefer full-size: strip /revision/... suffix
        full_url = re.sub(r'/revision/latest/scale-to-width-down/\d+', '/revision/latest', full_url)
        alt = img.get('alt', '')
        images.append({'url': full_url, 'alt': alt})
    return images


def sanitize_filename(name):
    """Make a string safe for use as a filename."""
    name = re.sub(r'[^\w\s\-.]', '', name)
    name = re.sub(r'\s+', '_', name.strip())
    return name[:100] if name else 'image'


def download_images(session, images, output_dir):
    """Download images to output_dir. Returns list of (local_path, alt) tuples."""
    img_dir = Path(output_dir) / "images"
    img_dir.mkdir(parents=True, exist_ok=True)
    downloaded = []
    seen_urls = set()

    for i, img in enumerate(images):
        url = img['url']
        if url in seen_urls:
            continue
        seen_urls.add(url)

        # Derive filename from URL
        parsed = urlparse(url)
        url_filename = Path(parsed.path).name
        if not url_filename or url_filename == 'latest':
            # Fandom URLs: /wiki/File:Name.png/revision/latest
            parts = parsed.path.split('/')
            for part in reversed(parts):
                if '.' in part and not part == 'latest':
                    url_filename = part
                    break
            else:
                ext = '.png'
                url_filename = f"image_{i:03d}{ext}"

        url_filename = sanitize_filename(url_filename)
        # Ensure extension
        if '.' not in url_filename:
            url_filename += '.png'

        dest = img_dir / url_filename
        if dest.exists():
            # Avoid overwriting — add numeric suffix
            stem = dest.stem
            suffix = dest.suffix
            counter = 1
            while dest.exists():
                dest = img_dir / f"{stem}_{counter}{suffix}"
                counter += 1

        print(f"    IMG {url_filename} ...", end=" ")
        try:
            resp = session.get(url, timeout=30)
            if resp.status_code == 200 and len(resp.content) > 100:
                dest.write_bytes(resp.content)
                size_kb = len(resp.content) / 1024
                print(f"OK ({size_kb:.1f} KB)")
                downloaded.append({
                    'local': str(dest),
                    'relative': f"images/{dest.name}",
                    'alt': img['alt'],
                })
            else:
                print(f"SKIP (HTTP {resp.status_code}, {len(resp.content)} bytes)")
        except Exception as e:
            print(f"FAIL ({e})")
        time.sleep(0.5)  # Be polite

    return downloaded


def rewrite_image_refs(markdown, downloaded_images):
    """Replace remote image URLs in markdown with local paths."""
    for img_info in downloaded_images:
        local_ref = img_info['relative']
        alt = img_info['alt']
        # html2text outputs images as ![alt](url) — we just append an image gallery
        # since URL matching is fragile with Fandom CDN rewrites
    # Append image gallery at the end
    if downloaded_images:
        gallery = "\n\n---\n\n## Downloaded Images\n\n"
        for img_info in downloaded_images:
            alt = img_info['alt'] or img_info['relative']
            gallery += f"![{alt}]({img_info['relative']})\n\n"
        return markdown + gallery
    return markdown


def scrape_url(session, url, output_path, converter):
    print(f"  Fetching {url} ...")
    try:
        resp = session.get(url, timeout=30)
    except Exception as e:
        print(f"  FAIL {url} -> {e}")
        return False

    if resp.status_code != 200:
        print(f"  FAIL {url} -> HTTP {resp.status_code}")
        return False

    try:
        page_html = resp.text
        if len(page_html) < 500:
            print(f"  FAIL {url} -> response too small ({len(page_html)} bytes)")
            return False

        main_html = extract_main_content(page_html)
        markdown = converter.handle(main_html)
        markdown = clean_markdown(markdown)

        header = f"# Source: {url}\n\n---\n\n"
        content = header + markdown

        out = Path(output_path)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(content, encoding="utf-8")

        size_kb = len(content.encode("utf-8")) / 1024
        print(f"  OK   -> {output_path} ({size_kb:.1f} KB)")
        return True
    except Exception as e:
        print(f"  FAIL {url} -> parse error: {e}")
        return False


def scrape_with_images(session, url, output_dir):
    """Scrape a URL, saving text as markdown and downloading all images."""
    print(f"  Fetching {url} ...")
    try:
        resp = session.get(url, timeout=30)
    except Exception as e:
        print(f"  FAIL {url} -> {e}")
        return False

    if resp.status_code != 200:
        print(f"  FAIL {url} -> HTTP {resp.status_code}")
        return False

    try:
        page_html = resp.text
        if len(page_html) < 500:
            print(f"  FAIL {url} -> response too small ({len(page_html)} bytes)")
            return False

        # Extract and download images
        print("  Extracting images...")
        images = extract_image_urls(page_html, url)
        print(f"  Found {len(images)} images")
        downloaded = download_images(session, images, output_dir)
        print(f"  Downloaded {len(downloaded)} images")

        # Convert to markdown with images included
        converter = make_converter(include_images=True)
        main_html = extract_main_content(page_html)
        markdown = converter.handle(main_html)
        markdown = clean_markdown(markdown)

        # Add local image gallery
        markdown = rewrite_image_refs(markdown, downloaded)

        header = f"# Source: {url}\n\n---\n\n"
        content = header + markdown

        out_dir = Path(output_dir)
        out_dir.mkdir(parents=True, exist_ok=True)
        md_path = out_dir / "content.md"
        md_path.write_text(content, encoding="utf-8")

        size_kb = len(content.encode("utf-8")) / 1024
        print(f"  OK   -> {md_path} ({size_kb:.1f} KB)")
        return True
    except Exception as e:
        print(f"  FAIL {url} -> parse error: {e}")
        return False


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    if sys.argv[1] == "--images":
        if len(sys.argv) < 4:
            print("Usage: url_scraper.py --images <url> <output_dir>")
            sys.exit(1)
        url = sys.argv[2]
        output_dir = sys.argv[3]
        print(f"Scraping with images: {url}\n")
        session = requests.Session(impersonate="chrome")
        success = scrape_with_images(session, url, output_dir)
        sys.exit(0 if success else 1)

    if sys.argv[1] == "--batch":
        if len(sys.argv) < 3:
            print("Usage: url_scraper.py --batch <json_file>")
            sys.exit(1)
        batch_file = Path(sys.argv[2])
        targets = json.loads(batch_file.read_text())
    else:
        if len(sys.argv) < 3:
            print("Usage: url_scraper.py <url> <output_file>")
            sys.exit(1)
        targets = [{"url": sys.argv[1], "output": sys.argv[2]}]

    print(f"Scraping {len(targets)} URL(s) with curl_cffi (Chrome TLS impersonation)...\n")

    session = requests.Session(impersonate="chrome")
    converter = make_converter()

    ok_count = 0
    fail_count = 0
    for i, target in enumerate(targets):
        if not isinstance(target, dict) or "url" not in target or "output" not in target:
            print(f"  SKIP entry {i}: malformed target (missing 'url' or 'output' key): {target!r}")
            fail_count += 1
            continue
        if scrape_url(session, target["url"], target["output"], converter):
            ok_count += 1
        else:
            fail_count += 1
        if len(targets) > 1:
            time.sleep(3)  # Be polite between requests

    print(f"\nDone. {ok_count} succeeded, {fail_count} failed.")


if __name__ == "__main__":
    main()
