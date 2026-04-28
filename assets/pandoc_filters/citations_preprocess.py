#!/usr/bin/env python3
import contextlib
import os
import re
import sys

text = sys.stdin.read()

defs = {}

# Match simple Markdown reference definitions:
# [foo]: https://example.com/ "Optional title"
ref_def_re = re.compile(
    r"""(?mx)
    ^\[([^\]]+)\]:
    [ \t]*
    (\S+)
    (?:[ \t]+
      (?:
        "([^"]*)"
        |
        '([^']*)'
        |
        \(([^)]*)\)
      )
    )?
    [ \t]*$
    """,
)


def collect_def(match: re.Match[str]) -> None:
    ref_id = match.group(1).strip()
    key = ref_id.lower()
    url = match.group(2).strip()
    title = next((g for g in match.groups()[2:] if g is not None), "").strip()

    defs[key] = {
        "id": key,
        "type": "webpage",
        "title": title or ref_id,
        "URL": url,
    }


ref_def_spans = []
for match in ref_def_re.finditer(text):
    ref_def_spans.append((match.start(), match.end()))
    collect_def(match)


# Replace [ref-id] with Pandoc citation [@ref-id].
ref_link_re = re.compile(r"(?<!\])\[([^\]]+)\](?!\[)(?!\()")


def replace_ref_link(match: re.Match[str]) -> str:
    if any(s <= match.start() < e for s, e in ref_def_spans):
        return match.group(0)
    content = match.group(1)
    parts = (
        [p.strip() for p in content.split(";")] if ";" in content else [content.strip()]
    )
    converted = [f"@{p}" if p.lower() in defs else p for p in parts]
    return "[" + "; ".join(converted) + "]"


text = ref_link_re.sub(replace_ref_link, text)

entries = []
for ref in defs.values():
    entry = (
        f"@misc{{{ref['id']},\n"
        f"  title = {{{ref['title']}}},\n"
        f"  url   = {{{ref['URL']}}},\n"
        f"}}"
    )
    entries.append(entry)
bib_text = "\n\n".join(entries) + "\n"


merge_re = re.compile(r"\[@([^\]]+)\](?:[,; ]\s*\[@([^\]]+)\])+")


def merge_citations(match: re.Match[str]) -> str:
    refs = re.findall(r"@([^\]]+)", match.group(0))
    return "[@" + "; @".join(refs) + "]"


text = merge_re.sub(merge_citations, text)

sys.stdout.write(text)
with contextlib.suppress(OSError):
    os.write(3, bib_text.encode())
