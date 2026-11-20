import json
import struct
from pathlib import Path

folder = Path("mouse_9")
source = folder / "data1.bin"
destination = folder / "preview_50frames.bin"

sequence = json.loads((folder / "sequence.json").read_text())
angles_per_frame = int(sequence["nbAngles"])
first_frame = 100
frames_to_keep = 50

with source.open("rb") as f:
    header = f.read(12)
    n_samples, n_channels, n_events = struct.unpack("<3i", header)

    events_per_frame = n_events // angles_per_frame
    assert n_events % angles_per_frame == 0
    assert first_frame + frames_to_keep - 1 <= events_per_frame

    event_count = frames_to_keep * angles_per_frame
    bytes_per_event = n_samples * n_channels * 2  # int16 samples
    first_event = (first_frame - 1) * angles_per_frame

    f.seek(12 + first_event * bytes_per_event)
    data = f.read(event_count * bytes_per_event)

with destination.open("wb") as f:
    f.write(struct.pack("<3i", n_samples, n_channels, event_count))
    f.write(data)

print(f"Created {destination} ({destination.stat().st_size / 1_000_000:.1f} MB)")