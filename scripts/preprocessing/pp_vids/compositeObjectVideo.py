"""
Step 3 of 3 in the object-isolation pipeline:
  extractObjectFrames.py -> segmentObjectSam2.py -> compositeObjectVideo.py

Uses the masks from segmentObjectSam2.py to black out everything but the
tracked object, crops/centers a fixed window on the object per frame, and
encodes the result to mp4.

Example:
    python compositeObjectVideo.py --name french_press --fps 5
"""
import argparse
import os
import subprocess

import numpy as np
from PIL import Image

DERIVED_ROOT = "../../data/pilot-apv/derived"


def composite(name, win, min_area):
    base = os.path.join(DERIVED_ROOT, name)
    frames_dir = os.path.join(base, "frames")
    masks = np.load(os.path.join(base, "masks.npz"))["masks"]
    n, H, W = masks.shape
    out_dir = os.path.join(base, "composited")
    os.makedirs(out_dir, exist_ok=True)

    half = win // 2
    max_x0 = max(W - win, 0)
    max_y0 = max(H - win, 0)

    for i in range(n):
        mask = masks[i]
        area = mask.sum()
        img = np.array(Image.open(os.path.join(frames_dir, f"{i+1:05d}.jpg")).convert("RGB"))

        canvas = np.zeros((win, win, 3), dtype=np.uint8)
        if area >= min_area:
            ys, xs = np.where(mask)
            cy, cx = int(ys.mean()), int(xs.mean())
            x0 = int(np.clip(cx - half, 0, max_x0))
            y0 = int(np.clip(cy - half, 0, max_y0))
            crop_img = img[y0:y0 + win, x0:x0 + win]
            crop_mask = mask[y0:y0 + win, x0:x0 + win]
            ch, cw = crop_img.shape[:2]
            comp = np.zeros((ch, cw, 3), dtype=np.uint8)
            comp[crop_mask] = crop_img[crop_mask]
            canvas[:ch, :cw] = comp

        Image.fromarray(canvas).save(os.path.join(out_dir, f"{i+1:05d}.jpg"), quality=92)

    print(f"wrote {n} composited frames to {out_dir}")
    return out_dir


def encode(name, composited_dir, fps):
    out_path = os.path.join(DERIVED_ROOT, name, f"{name}_isolated.mp4")
    subprocess.run([
        "ffmpeg", "-y",
        "-framerate", str(fps),
        "-i", os.path.join(composited_dir, "%05d.jpg"),
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18",
        out_path,
    ], check=True)
    print(f"wrote {out_path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="object name, matches segmentObjectSam2.py --name")
    parser.add_argument("--fps", type=float, default=5, help="must match extractObjectFrames.py --fps")
    parser.add_argument("--window", type=int, default=900, help="output crop size in pixels (square)")
    parser.add_argument("--min-area", type=int, default=500, help="frames with fewer masked pixels are treated as empty (solid black)")
    args = parser.parse_args()

    composited_dir = composite(args.name, args.window, args.min_area)
    encode(args.name, composited_dir, args.fps)


if __name__ == "__main__":
    main()
