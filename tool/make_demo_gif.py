# Joins the frames from test/screenshots/demo_test.dart into docs/demo.gif.
# Needs Pillow: pip install pillow
from pathlib import Path

from PIL import Image

frames_dir = Path("build/demo_frames")
paths = sorted(frames_dir.glob("*.png"))
if not paths:
    raise SystemExit("No frames found. Run the demo test with --update-goldens first.")

frames = [Image.open(path).convert("RGB") for path in paths]

# Typing frames are quick, everything else stays up long enough to read.
durations = []
for index in range(len(frames)):
    if 2 <= index <= 3:
        durations.append(500)
    else:
        durations.append(1800)
durations[-1] = 2500

frames[0].save(
    "docs/demo.gif",
    save_all=True,
    append_images=frames[1:],
    duration=durations,
    loop=0,
    optimize=True,
)
print(f"Saved docs/demo.gif with {len(frames)} frames")
