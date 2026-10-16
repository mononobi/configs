#!/usr/bin/env python3
"""
Patch Tela Icon Theme SVGs for GTK 4.22 / GNOME 50 High-DPI & Zoom Scaling.
Replaces root SVG width/height with 512 on folder (places) icons to prevent GTK 4.22
fallback texture capping at 64px.

Safety Rules:
1. Targets ONLY 'places' (folder icons with dynamic color-scheme <style> tags).
2. Guarantees viewBox exists (injects viewBox="0 0 {orig_w} {orig_h}" if missing)
   so icons never shrink into dots.
3. Strictly skips all symlinks.
4. Validates XML syntax before writing.
"""

import os
import sys
import glob
import re
import xml.etree.ElementTree as ET

def patch_tag(tag: str, target_size: int = 512) -> str:
    # Extract original width / height if available
    w_match = re.search(r'\bwidth=[\"\']([^\"\']+)[\"\']', tag)
    h_match = re.search(r'\bheight=[\"\']([^\"\']+)[\"\']', tag)
    orig_w = w_match.group(1) if w_match else "64"
    orig_h = h_match.group(1) if h_match else "64"

    # Strip units if any (e.g. 64px -> 64)
    orig_w_num = re.sub(r'[^\d.]', '', orig_w) or "64"
    orig_h_num = re.sub(r'[^\d.]', '', orig_h) or "64"

    # Check if viewBox exists
    has_vb = bool(re.search(r'\bviewBox=[\"\'][^\"\']+[\"\']', tag, re.I))

    new_tag = tag
    # If missing, inject viewBox based on original dimensions so content scales to fill
    if not has_vb:
        new_tag = re.sub(r'<svg\b', f'<svg viewBox="0 0 {orig_w_num} {orig_h_num}"', new_tag, count=1)

    # Set width to target_size
    if w_match:
        new_tag = re.sub(r'\bwidth=[\"\'][^\"\']+[\"\']', f'width="{target_size}"', new_tag)
    else:
        new_tag = re.sub(r'<svg\b', f'<svg width="{target_size}"', new_tag, count=1)

    # Set height to target_size
    if h_match:
        new_tag = re.sub(r'\bheight=[\"\'][^\"\']+[\"\']', f'height="{target_size}"', new_tag)
    else:
        new_tag = re.sub(r'<svg\b', f'<svg height="{target_size}"', new_tag, count=1)

    return new_tag

def patch_tela_svgs(repo_dir: str, target_size: int = 512):
    repo_dir = os.path.abspath(os.path.expanduser(repo_dir))
    scalable_dir = os.path.join(repo_dir, "src", "scalable")

    if not os.path.isdir(scalable_dir):
        print(f"[!] Error: Could not find '{scalable_dir}'. Is this a Tela-icon-theme repository?")
        sys.exit(1)

    print(f"[+] Targeting Tela repository at: {repo_dir}")
    print(f"[+] Patching folder icons under: {scalable_dir}/places")

    # Only patch 'places' where <style id="current-color-scheme"> causes GTK fallback
    categories = ["places"]
    total_scanned = 0
    total_patched = 0
    skipped_symlinks = 0
    corrupt_files = []

    for cat in categories:
        cat_path = os.path.join(scalable_dir, cat)
        if not os.path.isdir(cat_path):
            continue

        svg_files = sorted(glob.glob(os.path.join(cat_path, "*.svg")))
        cat_patched = 0

        for fpath in svg_files:
            total_scanned += 1

            # Safety: Strictly skip any symlinks
            if os.path.islink(fpath):
                skipped_symlinks += 1
                continue

            with open(fpath, "r", encoding="utf-8", errors="ignore") as fp:
                content = fp.read()

            # Find root <svg ...> tag
            match = re.search(r'(<svg\b[^>]*>)', content)
            if not match:
                continue

            orig_tag = match.group(1)
            new_tag = patch_tag(orig_tag, target_size)

            if new_tag != orig_tag:
                new_content = content[:match.start()] + new_tag + content[match.end():]

                # Validate XML before saving
                try:
                    ET.fromstring(new_content)
                except Exception as e:
                    corrupt_files.append((fpath, str(e)))
                    continue

                with open(fpath, "w", encoding="utf-8") as fp:
                    fp.write(new_content)

                cat_patched += 1
                total_patched += 1

        print(f"  • {cat}: {len(svg_files)} files scanned, {cat_patched} patched")

    print("\n" + "=" * 60)
    print(" PATCH SUMMARY")
    print("=" * 60)
    print(f"  Total SVG files scanned : {total_scanned}")
    print(f"  Total SVG files patched : {total_patched}")
    print(f"  Symlinks encountered    : {skipped_symlinks} (100% untouched)")
    print(f"  XML syntax errors       : {len(corrupt_files)}")

    if corrupt_files:
        print("\n[!] WARNING: The following files failed XML parsing:")
        for cf, err in corrupt_files:
            print(f"    - {cf}: {err}")
        sys.exit(1)

    print("[✓] Patch completed successfully with zero syntax errors!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {os.path.basename(sys.argv[0])} <path_to_tela_repo>")
        sys.exit(1)
    patch_tela_svgs(sys.argv[1])
