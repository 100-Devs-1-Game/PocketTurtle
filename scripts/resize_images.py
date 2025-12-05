#!/usr/bin/env python3
from PIL import Image
import math
import os
import fnmatch

ASSETS_DIR = "src/assets/Art Assets"

def next_pow_2(n):
    v = int(math.log(n, 2))
    return 2**v

def convert(path):
    try:
        img = Image.open(path)
        resized = img.resize((512, 512), resample=Image.Resampling.LANCZOS)
        resized.save(path)
    except e:
        print(f"Error converting image: {e}")

def main():
    files = [
        os.path.join(dirpath, f)
        for dirpath, dirnames, files in os.walk(ASSETS_DIR)
        for f in fnmatch.filter(files, "*.png")
    ]
    for f in files:
        convert(f)    



if __name__ == '__main__':
    main()