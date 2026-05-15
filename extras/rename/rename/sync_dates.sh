#!/bin/bash

# --- CONFIGURATION ---
ARTIST_HEADER="Artist Name(s)"
TRACK_HEADER="Track Name"
DATE_HEADER="Added At"
# ---------------------

if [ -n "$1" ]; then
    CSV_FILE="$1"
else
    CSV_COUNT=$(ls -1 *.csv 2>/dev/null | wc -l)
    if [ "$CSV_COUNT" -eq 0 ]; then
        echo "Error: No CSV file found."; exit 1
    elif [ "$CSV_COUNT" -eq 1 ]; then
        CSV_FILE=$(ls *.csv)
    else
        echo "Multiple CSVs found. Usage: ./sync_dates.sh 'filename.csv'"; exit 1
    fi
fi

echo "Syncing with Flexible Metadata Matching using: $CSV_FILE"
echo "---"

python3 -c "
import csv
import sys
import os
import unicodedata
import re
import subprocess

def normalize(text):
    if not text: return ''
    text = re.sub(r' - SpotubeDL\.com', '', text, flags=re.I)
    text = ''.join(c for c in unicodedata.normalize('NFD', text) if unicodedata.category(c) != 'Mn')
    return re.sub(r'[^a-z0-9]', '', text.lower())

csv_file = sys.argv[1]
audio_files = [f for f in os.listdir('.') if f.lower().endswith(('.mp3', '.ogg'))]

# Load CSV data into separate lookup tables
full_map = {}   # artist + title
title_map = {}  # title only

try:
    with open(csv_file, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            date = row.get('$DATE_HEADER')
            track = row.get('$TRACK_HEADER')
            artist = row.get('$ARTIST_HEADER', '')
            
            if date and track:
                norm_t = normalize(track)
                norm_a = normalize(artist)
                
                # Store combinations
                full_map[norm_a + norm_t] = date
                # Store title-only if not already present (keeps the first occurrence)
                if norm_t not in title_map:
                    title_map[norm_t] = date
except Exception as e:
    print(f'PYTHON_ERROR|{e}')
    sys.exit(1)

for filename in audio_files:
    # Extract Metadata
    m_artist = ''
    m_title = ''
    try:
        m_artist = subprocess.check_output(['ffprobe', '-loglevel', 'error', '-show_entries', 'format_tags=artist', '-of', 'default=noprint_wrappers=1:nokey=1', filename]).decode('utf-8').strip()
        m_title = subprocess.check_output(['ffprobe', '-loglevel', 'error', '-show_entries', 'format_tags=title', '-of', 'default=noprint_wrappers=1:nokey=1', filename]).decode('utf-8').strip()
    except:
        pass

    n_m_artist = normalize(m_artist)
    n_m_title = normalize(m_title)
    n_filename = normalize(os.path.splitext(filename)[0]) # Normalize filename without extension

    found_date = None
    match_type = ''

    # 1. Try Metadata Artist + Title
    if n_m_artist and n_m_title and (n_m_artist + n_m_title) in full_map:
        found_date = full_map[n_m_artist + n_m_title]
        match_type = 'Full Metadata Match'
    # 2. Try Metadata Title Only
    elif n_m_title and n_m_title in title_map:
        found_date = title_map[n_m_title]
        match_type = 'Title Metadata Match'
    # 3. Try Filename Match (against title list)
    elif n_filename in title_map:
        found_date = title_map[n_filename]
        match_type = 'Filename Match'
    # 4. Partial Filename Match (if filename contains title or vice versa)
    else:
        for t_norm, d in title_map.items():
            if len(t_norm) > 3 and (t_norm in n_filename or n_filename in t_norm):
                found_date = d
                match_type = 'Partial Match'
                break

    if found_date:
        print(f'{found_date}|{filename}|{match_type}')
    else:
        print(f'SKIP|{filename}|None')

" "$CSV_FILE" | while IFS="|" read -r date filename mtype; do
    if [[ "$date" == "SKIP" ]]; then
        skipped_files+=("$filename")
    else
        if touch -d "$date" "$filename"; then
            echo "SUCCESS: [$date] -> $filename ($mtype)"
            ((success_count++))
        fi
    fi
done

echo "---"
echo "Done! Updated: $success_count files."
if [ ${#skipped_files[@]} -ne 0 ]; then
    echo -e "\nStill Skipped (${#skipped_files[@]}):"
    for item in "${skipped_files[@]}"; do echo "  - $item"; done
fi