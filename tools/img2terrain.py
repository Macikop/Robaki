import sys
import re
import math
from PIL import Image
import numpy as np

def next_pow2(x):
    return 1 << (x - 1).bit_length()

# input image
image_file = sys.argv[1]

# open image and convert to grayscale
image = Image.open(image_file).convert("L")
array = np.array(image)

orig_w = image.width
orig_h = image.height

pad_w = next_pow2(orig_w)
pad_h = next_pow2(orig_h)

# output file
output_file_name = re.sub(r'\.[a-zA-Z0-9]+$', '.dat', image_file)
output_file = open(output_file_name, 'w')

output_file.write("// 1-bit monochrome image ROM\n")
output_file.write("// original WIDTH = {}\n".format(orig_w))
output_file.write("// original HEIGHT = {}\n".format(orig_h))
output_file.write("// PAD WIDTH = {}\n".format(pad_w))
output_file.write("// PAD HEIGHT = {}\n".format(pad_h))
output_file.write("// BIT = 0 white, 1 black\n")

# threshold (you can tune this)
THRESHOLD = 128

for y in range(pad_h):
    for x in range(pad_w):

        if y < orig_h and x < orig_w:
            pixel = array[y, x]
            bit = 0 if pixel > THRESHOLD else 1  # white=0, black=1
        else:
            bit = 0  # padding = white

        # store as hex (4 pixels per hex digit if you want later packing,
        # but here we keep 1 bit per line like your original)
        output_file.write(str(bit) + "\n")

output_file.close()

print("Saved:", output_file_name)