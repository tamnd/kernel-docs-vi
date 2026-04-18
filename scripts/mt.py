#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "deep-translator>=1.11.4",
# ]
# ///
"""Machine-translate kernel RST docs into Documentation/translations/vi_VN_mt/.

Usage:
    uv run scripts/mt.py                 # translate everything missing
    uv run scripts/mt.py --limit 20      # stop after 20 files
    uv run scripts/mt.py --workers 8     # concurrent worker count
    uv run scripts/mt.py path/to/foo.rst # translate specific files

Notes:
    - Output goes to Documentation/translations/vi_VN_mt/ preserving the
      source directory layout. The existing hand-curated tree under
      Documentation/translations/vi_VN/ is never touched.
    - Prose paragraphs are translated via Google Translate. RST directives,
      code blocks, tables, and inline markup are preserved verbatim using
      placeholder tokens.
    - Output is marked with a machine-translation notice so readers know it
      has not been human-reviewed. Human-reviewed translations still belong
      in vi_VN/.
    - Safe to re-run: files already present in vi_VN_mt/ are skipped.
"""

from __future__ import annotations

import argparse
import concurrent.futures as cf
import os
import random
import re
import sys
import threading
import time
from pathlib import Path

from deep_translator import GoogleTranslator
from deep_translator.exceptions import TooManyRequests

RATE_LIMIT_LOCK = threading.Lock()
RATE_LIMIT_UNTIL = 0.0

REPO_ROOT = Path(__file__).resolve().parent.parent
DOC_ROOT = REPO_ROOT / "Documentation"
SOURCE_ROOT = DOC_ROOT
TARGET_ROOT = DOC_ROOT / "translations" / "vi_VN_mt"
UPSTREAM_FILE = REPO_ROOT / "UPSTREAM"

SKIP_DIR_PARTS = {
    "translations",
    "output",
    "sphinx-includes",
}
SKIP_PREFIXES_REL = (
    "ABI/",
    "devicetree/bindings/",
    "netlink/specs/",
    "features/",
)

INLINE_PATTERNS = [
    re.compile(r":[a-zA-Z:+-]+:`[^`]+`"),
    re.compile(r"``[^`]+``"),
    re.compile(r"`[^`]+`_{1,2}"),
    re.compile(r"`[^`]+`"),
    re.compile(r"\*\*[^*\n]+\*\*"),
    re.compile(r"\*[^*\s][^*\n]*\*"),
    re.compile(r"\|[^|\n]+\|"),
    re.compile(r"https?://\S+"),
    re.compile(r"\b[A-Z_][A-Z0-9_]{2,}\b"),
    re.compile(r"#\s*[A-Za-z0-9_-]+"),
]

TOKEN_FMT = "ZZ{:04d}ZZ"
TOKEN_RE = re.compile(r"ZZ\d{4}ZZ")

HEADING_CHARS = set("=-~^\"*+#`:._'")


def get_upstream_sha() -> str:
    try:
        for line in UPSTREAM_FILE.read_text(encoding="utf-8").splitlines():
            if line.startswith("commit:"):
                return line.split(":", 1)[1].strip()
    except FileNotFoundError:
        pass
    return "unknown"


def protect(text: str) -> tuple[str, dict[str, str]]:
    tokens: dict[str, str] = {}

    def replace(match: re.Match[str]) -> str:
        key = TOKEN_FMT.format(len(tokens))
        tokens[key] = match.group(0)
        return key

    for pat in INLINE_PATTERNS:
        text = pat.sub(replace, text)
    return text, tokens


def restore(text: str, tokens: dict[str, str]) -> str:
    return TOKEN_RE.sub(lambda m: tokens.get(m.group(0), m.group(0)), text)


def is_heading_underline(line: str, prev_line: str) -> bool:
    s = line.rstrip()
    if not s or prev_line == "":
        return False
    if set(s) & HEADING_CHARS != set(s) or len(set(s)) > 1:
        return False
    return len(s) >= max(3, len(prev_line.rstrip()) - 1)


def split_blocks(text: str) -> list[tuple[str, list[str]]]:
    """Split RST into (kind, lines) blocks.

    kind ∈ {"prose", "code", "directive", "heading", "blank", "raw"}.
    """
    lines = text.splitlines()
    blocks: list[tuple[str, list[str]]] = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        stripped = line.lstrip()
        indent = len(line) - len(stripped)

        if not line.strip():
            start = i
            while i < n and not lines[i].strip():
                i += 1
            blocks.append(("blank", lines[start:i]))
            continue

        if stripped.startswith(".."):
            start = i
            i += 1
            while i < n:
                cur = lines[i]
                if not cur.strip():
                    i += 1
                    continue
                cur_indent = len(cur) - len(cur.lstrip())
                if cur_indent > indent:
                    i += 1
                    continue
                break
            blocks.append(("directive", lines[start:i]))
            continue

        prev_block_lines = blocks[-1][1] if blocks else []
        prev_line = prev_block_lines[-1] if prev_block_lines else ""
        if is_heading_underline(line, prev_line):
            blocks.append(("heading", [line]))
            i += 1
            continue

        if indent > 0 and blocks and blocks[-1][0] == "prose":
            prev_prose = blocks[-1][1]
            if prev_prose and prev_prose[-1].rstrip().endswith("::"):
                start = i
                while i < n:
                    cur = lines[i]
                    if not cur.strip():
                        i += 1
                        continue
                    cur_indent = len(cur) - len(cur.lstrip())
                    if cur_indent <= 0:
                        break
                    i += 1
                blocks.append(("code", lines[start:i]))
                continue

        start = i
        while i < n:
            cur = lines[i]
            if not cur.strip():
                break
            cur_stripped = cur.lstrip()
            if cur_stripped.startswith(".."):
                break
            prev = lines[i - 1] if i > start else ""
            if is_heading_underline(cur, prev) and i > start:
                break
            i += 1
        blocks.append(("prose", lines[start:i]))
    return blocks


def _wait_for_rate_limit() -> None:
    while True:
        with RATE_LIMIT_LOCK:
            remaining = RATE_LIMIT_UNTIL - time.time()
        if remaining <= 0:
            return
        time.sleep(min(remaining, 5) + random.uniform(0, 0.5))


def _set_rate_limit_penalty(seconds: float) -> None:
    global RATE_LIMIT_UNTIL
    with RATE_LIMIT_LOCK:
        target = time.time() + seconds
        if target > RATE_LIMIT_UNTIL:
            RATE_LIMIT_UNTIL = target


def translate_with_retry(translator: GoogleTranslator, text: str) -> str | None:
    attempts = 6
    backoff = 2.0
    for i in range(attempts):
        _wait_for_rate_limit()
        try:
            result = translator.translate(text)
        except TooManyRequests:
            penalty = backoff * (2 ** i) + random.uniform(0, backoff)
            penalty = min(penalty, 120.0)
            _set_rate_limit_penalty(penalty)
            continue
        except Exception as exc:
            print(f"  ! translate failed: {exc!r}", file=sys.stderr)
            return None
        return result if result else None
    return None


def translate_prose(translator: GoogleTranslator, lines: list[str]) -> list[str]:
    text = "\n".join(lines)
    if not text.strip():
        return lines
    protected, tokens = protect(text)
    if not protected.strip():
        return lines
    result = translate_with_retry(translator, protected)
    if not result:
        return lines
    restored = restore(result, tokens)
    out = restored.splitlines() or [restored]
    return out


def translate_rst(text: str, translator: GoogleTranslator) -> str:
    blocks = split_blocks(text)
    rendered: list[str] = []
    for kind, lines in blocks:
        if kind == "prose":
            rendered.extend(translate_prose(translator, lines))
        else:
            rendered.extend(lines)
    return "\n".join(rendered) + ("\n" if text.endswith("\n") else "")


def extract_spdx(text: str) -> tuple[str | None, str]:
    lines = text.splitlines()
    for idx, line in enumerate(lines[:5]):
        if "SPDX-License-Identifier" in line:
            return line, "\n".join(lines[idx + 1 :]).lstrip("\n")
    return None, text


def make_header(source_rel: str, spdx_line: str | None, upstream_sha: str) -> str:
    spdx = spdx_line if spdx_line else ".. SPDX-License-Identifier: GPL-2.0"
    depth = source_rel.count("/")
    disclaimer_path = "../" * (depth + 1) + "disclaimer-vi.rst"
    return (
        f"{spdx}\n\n"
        f".. include:: {disclaimer_path}\n\n"
        f":Original: Documentation/{source_rel}\n"
        f":Translator: Google Translate (machine translation)\n"
        f":Upstream-at: {upstream_sha[:12]}\n\n"
        ".. warning::\n"
        "   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.\n"
        "   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac\n"
        "   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc\n"
        "   review) duoc dat trong thu muc vi_VN/.\n\n"
    )


def iter_source_files() -> list[Path]:
    results: list[Path] = []
    for path in SOURCE_ROOT.rglob("*.rst"):
        try:
            rel = path.relative_to(SOURCE_ROOT)
        except ValueError:
            continue
        if any(part in SKIP_DIR_PARTS for part in rel.parts):
            continue
        rel_str = rel.as_posix()
        if rel_str.startswith(SKIP_PREFIXES_REL):
            continue
        results.append(path)
    return sorted(results)


def target_path_for(src: Path) -> Path:
    rel = src.relative_to(SOURCE_ROOT)
    return TARGET_ROOT / rel


def translate_file(
    src: Path,
    translator: GoogleTranslator,
    upstream_sha: str,
    force: bool,
) -> str:
    rel = src.relative_to(SOURCE_ROOT).as_posix()
    dst = target_path_for(src)
    if dst.exists() and not force:
        return f"skip {rel}"
    text = src.read_text(encoding="utf-8", errors="replace")
    spdx_line, body = extract_spdx(text)
    translated = translate_rst(body, translator)
    header = make_header(rel, spdx_line, upstream_sha)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(header + translated, encoding="utf-8")
    return f"done {rel}"


def run(files: list[Path], workers: int, force: bool) -> int:
    upstream_sha = get_upstream_sha()
    translator = GoogleTranslator(source="en", target="vi")

    def worker(src: Path) -> str:
        local_translator = GoogleTranslator(source="en", target="vi")
        try:
            return translate_file(src, local_translator, upstream_sha, force)
        except Exception as exc:
            return f"fail {src.relative_to(SOURCE_ROOT).as_posix()}: {exc!r}"

    total = len(files)
    done = skipped = failed = 0
    started = time.time()
    with cf.ThreadPoolExecutor(max_workers=workers) as pool:
        for idx, result in enumerate(pool.map(worker, files), 1):
            if result.startswith("done"):
                done += 1
            elif result.startswith("skip"):
                skipped += 1
            else:
                failed += 1
            if idx % 10 == 0 or idx == total:
                elapsed = time.time() - started
                rate = idx / elapsed if elapsed else 0
                print(
                    f"[{idx}/{total}] done={done} skipped={skipped} failed={failed}"
                    f" rate={rate:.2f}/s",
                    flush=True,
                )
    _ = translator
    print(f"\nTotal: done={done} skipped={skipped} failed={failed} of {total}")
    return 0 if failed == 0 else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="specific .rst files (relative to repo root)")
    parser.add_argument("--workers", type=int, default=int(os.environ.get("MT_WORKERS", "8")))
    parser.add_argument("--limit", type=int, default=0, help="stop after N files")
    parser.add_argument("--force", action="store_true", help="overwrite existing translations")
    args = parser.parse_args()

    if args.files:
        files = [Path(f).resolve() for f in args.files]
        files = [f for f in files if f.exists() and f.suffix == ".rst"]
    else:
        files = iter_source_files()

    if args.limit:
        files = files[: args.limit]

    if not files:
        print("No files to translate.")
        return 0

    print(f"Translating {len(files)} files using {args.workers} workers ...")
    return run(files, args.workers, args.force)


if __name__ == "__main__":
    sys.exit(main())
