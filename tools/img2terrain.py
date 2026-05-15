import sys
import re
from PIL import Image
import numpy as np

# input image
image_file = sys.argv[1]

# open image and convert to grayscale
image = Image.open(image_file).convert("L")
array = np.array(image)

width = image.width
height = image.height

# output file
output_file_name = re.sub(r'\.[a-zA-Z0-9]+$', '.dat', image_file)

# threshold
THRESHOLD = 128

with open(output_file_name, 'w') as output_file:

    output_file.write("// 1-bit monochrome image ROM\n")
    output_file.write(f"// WIDTH = {width}\n")
    output_file.write(f"// HEIGHT = {height}\n")
    output_file.write("// BIT = 0 white, 1 black\n")

    for y in range(height):
        for x in range(width):

            pixel = array[y, x]

            # white = 0, black = 1
            bit = 0 if pixel > THRESHOLD else 1

            output_file.write(f"{bit}\n")

print("Saved:", output_file_name)