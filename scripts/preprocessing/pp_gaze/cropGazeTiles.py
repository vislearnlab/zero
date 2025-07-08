import pandas as pd
import subprocess
import os

# Read the CSV file
csv_file = "../../data/pilot/processed/gazeTileFramesCoords.csv"
df = pd.read_csv(csv_file)

# Create output directories if they don't exist
os.makedirs("../../data/pilot/processed/tiles/uncropped", exist_ok=True)
os.makedirs("../../data/pilot/processed/tiles/cropped", exist_ok=True)

# Process the first 94 rows
for index, row in df.head(100).iterrows():
    video_path = os.path.join("../..", row['Var1_1'])
    # Save uncropped frame in tiles/uncropped folder
    output_path = os.path.join("../..", row['Var9'].replace('.png', '.jpg').replace('/tiles/', '/tiles/uncropped/'))
    # Save cropped frame in tiles/cropped folder
    cropped_output_path = output_path.replace('/tiles/uncropped/', '/tiles/cropped/')
    
    frame = row['frameInds']
    x_coord = row['Xcoord']
    y_coord = row['Ycoord']

    # Create the output directories if they don't exist
    output_dir = os.path.dirname(output_path)
    cropped_output_dir = os.path.dirname(cropped_output_path)
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(cropped_output_dir, exist_ok=True)

    # Skip if coordinates are NaN
    if pd.isna(x_coord) or pd.isna(y_coord):
        continue

    print(f"Processing: {video_path}, {output_path}, frame={frame}, X={x_coord}, Y={y_coord}")
    
    # Extract frame using ffmpeg
    subprocess.run([
        'ffmpeg', '-i', video_path,
        '-vf', f'select=eq(n\\,{int(frame)-1})',
        '-frames:v', '1',
        '-y',
        '-f', 'image2',  # Force image2 format
        '-c:v', 'mjpeg',  # Force JPEG codec
        output_path
    ])

    # Crop the frame and save to cropped folder
    subprocess.run([
        'ffmpeg', '-i', output_path,
        '-vf', f'crop=224:224:{int(x_coord)-112}:{int(y_coord)-112}',
        '-y',  # Overwrite output file if it exists
        cropped_output_path
    ]) 