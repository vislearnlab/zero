#!/bin/bash

csv_file="../../data/pilot/processed/gazeTileFramesCoords.csv"

# First, read the header line to identify column positions
header=$(head -n 1 "$csv_file")
IFS=',' read -r -a columns <<< "$header"

# Debug: Print all column names and their positions
echo "Found these columns:"
for i in "${!columns[@]}"; do
    # Trim whitespace and carriage returns from column name
    columns[$i]=$(echo "${columns[$i]}" | tr -d '\r' | tr -d ' ')
    echo "Position $i: '${columns[$i]}'"
done

# Find the indices of the columns we need
for i in "${!columns[@]}"; do
    case "${columns[$i]}" in
        "Var1_1") 
            video_col=$i
            echo "Found Var1_1 at position $i" ;;
        "Var9")
            output_col=$i
            echo "Found Var9 at position $i" ;;
        "frameInds")
            frame_col=$i
            echo "Found frameInds at position $i" ;;
        "Xcoord")
            x_col=$i
            echo "Found Xcoord at position $i" ;;
        "Ycoord")
            y_col=$i
            echo "Found Ycoord at position $i" ;;
    esac
done

# Verify that we found all required columns
if [[ -z "$video_col" ]] || [[ -z "$output_col" ]] || [[ -z "$frame_col" ]] || [[ -z "$x_col" ]] || [[ -z "$y_col" ]]; then
    echo "Error: Missing required columns in CSV. Expected: Var1_1, Var9, frameInds, Xcoord, Ycoord"
    echo "Found header: $header"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "../../data/pilot/processed/tiles"

# Process the first 2 data rows using the identified column positions
while IFS=',' read -r -a row; do
    video_path="${row[$video_col]}"
    output_path="${row[$output_col]}"
    frame="${row[$frame_col]}"
    x_coord="${row[$x_col]}"
    y_coord="${row[$y_col]}"

    if [ "$x_coord" = "nan" ] || [ "$y_coord" = "nan" ]; then
        continue
    fi

    echo "Processing: $video_path, $output_path, frame=$frame, X=$x_coord, Y=$y_coord"
    ffmpeg -i "$video_path" -vf "select=eq(n\,"$frame-1")" -vframes 1 "$output_path"
    ffmpeg -i "$output_path" -vf "crop=224:224:${x_coord}-112:${y_coord}-112" "$output_path"

done < <(tail -n +2 "$csv_file" | head -n 2)