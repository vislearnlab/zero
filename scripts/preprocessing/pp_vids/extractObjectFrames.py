"""
Step 1 of 3 in the object-isolation pipeline:
  extractObjectFrames.py -> segmentObjectSam2.py -> compositeObjectVideo.py

Extracts a time window from a Pupil Labs scene-camera video at a fixed fps,
producing a numbered JPEG sequence ready for SAM2 tracking.

Example:
    python extractObjectFrames.py \
        --video ../../../data/pilot-apv/2025-02-13_14-25-27-bd67a4a8/cd4cad3d_0.0-179.795.mp4 \
        --name french_press --start 0 --end 79 --fps 5
"""
import argparse
import os
import subprocess

DERIVED_ROOT = "../../data/pilot-apv/derived"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", required=True, help="path to source scene-camera video")
    parser.add_argument("--name", required=True, help="object name, e.g. french_press")
    parser.add_argument("--start", type=float, required=True, help="window start (seconds)")
    parser.add_argument("--end", type=float, required=True, help="window end (seconds)")
    parser.add_argument("--fps", type=float, default=5, help="frame extraction rate")
    args = parser.parse_args()

    out_dir = os.path.join(DERIVED_ROOT, args.name, "frames")
    os.makedirs(out_dir, exist_ok=True)

    subprocess.run([
        "ffmpeg", "-y",
        "-ss", str(args.start), "-to", str(args.end),
        "-i", args.video,
        "-vf", f"fps={args.fps}",
        "-q:v", "2",
        os.path.join(out_dir, "%05d.jpg"),
    ], check=True)

    n_frames = len(os.listdir(out_dir))
    print(f"wrote {n_frames} frames to {out_dir}")


if __name__ == "__main__":
    main()
