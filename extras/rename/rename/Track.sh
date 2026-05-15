#!/bin/bash

# --- CONFIGURATION ---
ARTIST_HEADER="Artist Name(s)"
TRACK_HEADER="Track Name"
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
        echo "Multiple CSVs found. Usage: ./arrange_playlist.sh 'filename.csv'"; exit 1
    fi
fi

echo "Arranging by Playlist Order using: $CSV_FILE"
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
    text = ''.join(c for c in unicodedata.normalize('NFD', text) if unicodedata.category(c) != 'Mn')
    return re.sub(r'[^a-z0-9]', '', text.lower())

csv_file = sys.argv[1]
audio_files = [f for f in os.listdir('.') if f.lower().endswith(('.mp3', '.ogg'))]

full_map = {}
title_map = {}
total_rows = 0

try:
    with open(csv_file, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = next(reader)

        try:
            track_idx = headers.index('$TRACK_HEADER')
            artist_idx = headers.index('$ARTIST_HEADER')
        except ValueError:
            print('PYTHON_ERROR|Missing required headers in CSV')
            sys.exit(1)

        row_index = 1
        for row in reader:
            if not row: continue
            
            track = row[track_idx] if len(row) > track_idx else ''
            artist = row[artist_idx] if len(row) > artist_idx else ''
            
            if track:
                norm_t = normalize(track)
                norm_a = normalize(artist)
                
                # Assign the actual row count as the playlist position
                full_map[norm_a + norm_t] = row_index
                if norm_t not in title_map:
                    title_map[norm_t] = row_index
                
                row_index += 1
        
        # Save total rows to calculate zero-padding later
        total_rows = row_index - 1

except Exception as e:
    print(f'PYTHON_ERROR|{e}')
    sys.exit(1)

for filename in audio_files:
    m_artist = ''
    m_title = ''
    try:
        m_artist = subprocess.check_output(['ffprobe', '-loglevel', 'error', '-show_entries', 'format_tags=artist', '-of', 'default=noprint_wrappers=1:nokey=1', filename]).decode('utf-8').strip()
        m_title = subprocess.check_output(['ffprobe', '-loglevel', 'error', '-show_entries', 'format_tags=title', '-of', 'default=noprint_wrappers=1:nokey=1', filename]).decode('utf-8').strip()
    except:
        pass

    n_m_artist = normalize(m_artist)
    n_m_title = normalize(m_title)
    n_filename = normalize(os.path.splitext(filename)[0])

    found_num = None

    if n_m_artist and n_m_title and (n_m_artist + n_m_title) in full_map:
        found_num = full_map[n_m_artist + n_m_title]
    elif n_m_title and n_m_title in title_map:
        found_num = title_map[n_m_title]
    elif n_filename in title_map:
        found_num = title_map[n_filename]
    else:
        for t_norm, num in title_map.items():
            if len(t_norm) > 3 and (t_norm in n_filename or n_filename in t_norm):
                found_num = num
                break

    if found_num:
        print(f'{found_num}|{total_rows}|{filename}')
    else:
        print(f'SKIP|0|{filename}')

" "$CSV_FILE" | while IFS="|" read -r track_num total_rows filename; do
    if [[ "$track_num" == "PYTHON_ERROR" ]]; then
        echo "Error reading CSV: $filename"
        exit 1
    elif [[ "$track_num" == "SKIP" ]]; then
        skipped_files+=("$filename")
    else
        # Dynamic padding: 3 digits if playlist has 100+ tracks, otherwise 2 digits
        if [ "$total_rows" -ge 100 ]; then
            padded_num=$(printf "%03d" "$track_num")
        else
            padded_num=$(printf "%02d" "$track_num")
        fi
        
        # Strip the old numbering format (e.g., "2245 - ") using sed
        clean_filename=$(echo "$filename" | sed -E 's/^[0-9]+[[:space:]]*-[[:space:]]*//')
        
        new_filename="${padded_num} - ${clean_filename}"
        
        # Only rename if the name is actually changing
        if [[ "$filename" != "$new_filename" ]]; then
            if mv -n "$filename" "$new_filename"; then
                echo "Renamed: '$filename' -> '$new_filename'"
                ((success_count++))
            fi
        else
            echo "Already correctly numbered: '$filename'"
        fi
    fi
done

echo "---"
echo "Done! Arranged: ${success_count:-0} files."
if [ ${#skipped_files[@]} -ne 0 ]; then
    echo -e "\nStill Skipped (${#skipped_files[@]}):"
    for item in "${skipped_files[@]}"; do echo "  - $item"; done
fi