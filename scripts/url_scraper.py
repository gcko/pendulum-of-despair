#!/usr/bin/env python3
"""
URL scraper using curl_cffi and html2text for markdown conversion.
Uses curl_cffi TLS impersonation for broad site compatibility.

Usage:
    scripts/.venv/bin/python scripts/url_scraper.py <url> <output_file>
    scripts/.venv/bin/python scripts/url_scraper.py --batch <json_file>

Batch JSON format:
    [
        {"url": "https://example.com/page1", "output": "docs/references/page1.md"},
        {"url": "https://example.com/page2", "output": "docs/references/page2.md"}
    ]
"""

import json
import sys
import time
from pathlib import Path

import html2text
from curl_cffi import requests
from lxml import html as lxml_html


def make_converter():
    c = html2text.HTML2Text()
    c.body_width = 0
    c.ignore_links = False
    c.ignore_images = True
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


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

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
