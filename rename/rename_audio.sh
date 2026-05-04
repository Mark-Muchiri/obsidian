#!/bin/bash

# Loop through both mp3 and ogg files in the current directory
for file in *.mp3 *.ogg; do
    
    # Skip if no matching files are found (prevents errors if one extension is missing)
    [[ -e "$file" ]] || continue

    # Extract the extension (e.g., mp3 or ogg)
    ext="${file##*.}"
    # Strip the extension to get the base name
    base_name="${file%.*}"

    # TASK 1: If the file contains " - Ao Vivo", remove everything AFTER it
    if [[ "$base_name" == *" - Ao Vivo"* ]]; then
        # ${base_name%% - Ao Vivo*} grabs everything BEFORE " - Ao Vivo"
        # We then manually add " - Ao Vivo" back onto the end
        new_base="${base_name%% - Ao Vivo*} - Ao Vivo"
        
    # TASK 2: If it DOESN'T have " - Ao Vivo", remove everything after the first " -"
    else
        # ${base_name%% - *} deletes everything from the first " -" onwards
        new_base="${base_name%% - *}"
    fi

    # Reattach the correct original extension
    new_name="${new_base}.${ext}"

    # If the new name is different from the old name, rename it
    if [[ "$file" != "$new_name" ]]; then
        # DRY RUN: Currently it just prints what it WOULD do. 
        echo "Renaming: '$file'  -->  '$new_name'"
        
        # UNCOMMENT THE LINE BELOW (remove the #) to actually rename the files
        mv -n "$file" "$new_name"
    fi
done
