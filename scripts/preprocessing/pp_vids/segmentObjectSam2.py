"""
Step 2 of 3 in the object-isolation pipeline:
  extractObjectFrames.py -> segmentObjectSam2.py -> compositeObjectVideo.py

Tracks a single object across a frame sequence using Meta's SAM2 video
predictor, starting from one (x, y) click on one frame. Saves a boolean
mask per frame.

Setup (one-time):
    pip install torch torchvision
    pip install "git+https://github.com/facebookresearch/sam2.git"
    curl -L -o <DEFAULT_CHECKPOINT> \
        https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_small.pt
(swap in a different sam2.1_hiera_*.pt / matching config for a bigger/smaller model)

Example:
    python segmentObjectSam2.py --name french_press \
        --prompt-frame 20 --point 160 1100
"""
import argparse
import os

import numpy as np
import torch
from sam2.build_sam import build_sam2_video_predictor

DERIVED_ROOT = "../../data/pilot-apv/derived"
DEFAULT_CHECKPOINT = "../../data/models/sam2/sam2.1_hiera_small.pt"
DEFAULT_CONFIG = "configs/sam2.1/sam2.1_hiera_s.yaml"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="object name, matches extractObjectFrames.py --name")
    parser.add_argument("--prompt-frame", type=int, required=True,
                         help="1-based frame filename (e.g. 20 for 00020.jpg) with a clear, unoccluded view of the object")
    parser.add_argument("--point", type=float, nargs=2, required=True, metavar=("X", "Y"),
                         help="pixel coordinate on the object in the prompt frame")
    parser.add_argument("--checkpoint", default=DEFAULT_CHECKPOINT)
    parser.add_argument("--config", default=DEFAULT_CONFIG)
    parser.add_argument("--device", default="mps", help="mps (Apple Silicon), cuda, or cpu")
    args = parser.parse_args()

    frames_dir = os.path.join(DERIVED_ROOT, args.name, "frames")
    prompt_idx = args.prompt_frame - 1  # SAM2 frame_idx is 0-based

    predictor = build_sam2_video_predictor(args.config, args.checkpoint, device=args.device)

    with torch.inference_mode():
        state = predictor.init_state(video_path=frames_dir)
        predictor.add_new_points_or_box(
            state,
            frame_idx=prompt_idx,
            obj_id=1,
            points=np.array([args.point], dtype=np.float32),
            labels=np.array([1], dtype=np.int32),
        )

        n_frames = state["num_frames"]
        masks = np.zeros((n_frames, state["video_height"], state["video_width"]), dtype=bool)

        for frame_idx, _, mask_logits in predictor.propagate_in_video(state):
            masks[frame_idx] = (mask_logits[0] > 0.0).cpu().numpy().squeeze()

        if prompt_idx > 0:
            for frame_idx, _, mask_logits in predictor.propagate_in_video(
                state, start_frame_idx=prompt_idx, reverse=True
            ):
                masks[frame_idx] = (mask_logits[0] > 0.0).cpu().numpy().squeeze()

    out_path = os.path.join(DERIVED_ROOT, args.name, "masks.npz")
    np.savez_compressed(out_path, masks=masks)
    print(f"saved {out_path}, shape={masks.shape}, mean_area={masks.mean():.4f}")


if __name__ == "__main__":
    main()
