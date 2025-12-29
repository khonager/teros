import os
import re

def rename_files():
    # Matches files like: frame_00_delay-0.09s.png
    # Captures the number part (e.g., "00", "05", "20")
    pattern = re.compile(r"frame_(\d+)_delay.*\.png")

    files = [f for f in os.listdir('.') if f.endswith('.png')]
    files.sort()

    print(f"Found {len(files)} PNG files.")

    for filename in files:
        match = pattern.search(filename)
        if match:
            # Get the number, convert to int to remove leading zeros (00 -> 0, 05 -> 5)
            number_str = match.group(1)
            number = int(number_str)
            
            new_name = f"progress-{number}.png"
            print(f"Renaming: {filename} -> {new_name}")
            os.rename(filename, new_name)

if __name__ == "__main__":
    rename_files()