#!/usr/bin/env python3
"""
Split a large markdown script file into numbered parts with prev/next navigation.

Usage:
    python scripts/split_script.py <input_file> <output_dir> <game_title> [--lines-per-part=2000]

Splits on section headers (## or #) when possible, falling back to line count.
Each part gets YAML-style frontmatter with navigation links.
"""

import re
import sys
from pathlib import Path


def find_split_points(lines, max_lines=2000):
    """Find good split points at section headers, respecting max_lines."""
    splits = [0]
    last_split = 0

    for i, line in enumerate(lines):
        distance = i - last_split
        # Look for header lines as natural break points
        is_header = re.match(r'^#{1,3}\s', line.strip())

        if distance >= max_lines:
            # We've exceeded max — find nearest header backward, or split here
            if is_header:
                splits.append(i)
                last_split = i
            else:
                # Look back up to 200 lines for a header
                found = False
                for j in range(i, max(last_split, i - 200), -1):
                    if re.match(r'^#{1,3}\s', lines[j].strip()):
                        splits.append(j)
                        last_split = j
                        found = True
                        break
                if not found:
                    # No header nearby — split at a blank line
                    for j in range(i, max(last_split, i - 50), -1):
                        if lines[j].strip() == '':
                            splits.append(j)
                            last_split = j
                            found = True
                            break
                    if not found:
                        splits.append(i)
                        last_split = i
        elif distance >= max_lines * 0.75 and is_header:
            # We're past 75% and hit a header — good natural break
            splits.append(i)
            last_split = i

    return splits


def split_file(input_path, output_dir, game_title, max_lines=2000):
    input_path = Path(input_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    content = input_path.read_text(encoding='utf-8')
    lines = content.split('\n')
    total_lines = len(lines)

    if total_lines <= max_lines:
        print(f"  File is only {total_lines} lines — no splitting needed.")
        # Still write as part-01 with nav header
        splits = [0]
    else:
        splits = find_split_points(lines, max_lines)

    # Build parts
    parts = []
    for idx, start in enumerate(splits):
        end = splits[idx + 1] if idx + 1 < len(splits) else total_lines
        parts.append((start, end))

    num_parts = len(parts)
    print(f"  Splitting {total_lines} lines into {num_parts} parts")

    filenames = []
    for i, (start, end) in enumerate(parts):
        part_num = i + 1
        filename = f"part-{part_num:02d}.md"
        filenames.append(filename)

    for i, (start, end) in enumerate(parts):
        part_num = i + 1
        filename = filenames[i]

        # Build navigation header
        nav_lines = []
        nav_lines.append(f"# {game_title} — Script Part {part_num}/{num_parts}")
        nav_lines.append("")
        nav_lines.append(f"> Lines {start + 1}–{end} of {total_lines}")
        nav_lines.append("")

        prev_link = f"[< Previous: {filenames[i-1]}](./{filenames[i-1]})" if i > 0 else "*(start)*"
        next_link = f"[Next: {filenames[i+1]} >](./{filenames[i+1]})" if i < num_parts - 1 else "*(end)*"
        nav_lines.append(f"**Navigation:** {prev_link} | {next_link}")
        nav_lines.append("")
        nav_lines.append("---")
        nav_lines.append("")

        part_content = '\n'.join(nav_lines) + '\n'.join(lines[start:end])

        out_path = output_dir / filename
        out_path.write_text(part_content, encoding='utf-8')
        size_kb = len(part_content.encode('utf-8')) / 1024
        print(f"    {filename}: lines {start+1}-{end} ({size_kb:.1f} KB)")

    # Write index file
    index_lines = [
        f"# {game_title} — Complete Script Index",
        "",
        f"**Total:** {total_lines} lines across {num_parts} parts",
        "",
        "## Parts",
        "",
    ]
    for i, fname in enumerate(filenames):
        start, end = parts[i]
        index_lines.append(f"- [{fname}](./{fname}) — Lines {start+1}–{end}")

    index_path = output_dir / "index.md"
    index_path.write_text('\n'.join(index_lines) + '\n', encoding='utf-8')
    print(f"    index.md written")

    # Remove the full_script.md since we've split it
    if input_path.exists() and input_path.parent == output_dir:
        input_path.unlink()
        print(f"    Removed {input_path.name} (replaced by parts)")


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)

    input_file = sys.argv[1]
    output_dir = sys.argv[2]
    game_title = sys.argv[3]

    max_lines = 2000
    for arg in sys.argv[4:]:
        if arg.startswith('--lines-per-part='):
            max_lines = int(arg.split('=')[1])

    split_file(input_file, output_dir, game_title, max_lines)


if __name__ == '__main__':
    main()
