#
# Source: Labs page
# Modified to return 13 bit 1 bit alpha and 12 bit RGB
#

import sys
import re
import math
from PIL import Image
from numpy import asarray

def next_pow2(x):
    return 1 << (x - 1).bit_length()

# read argument (image file name)
image_file = sys.argv[1]

# open image
image = Image.open(image_file)
array = asarray(image)

# detect channels
is_rgb = len(array.shape) > 2

if is_rgb:
    r = array[:, :, 0]
    g = array[:, :, 1]
    b = array[:, :, 2]
    has_alpha = array.shape[2] >= 4
    if has_alpha:
        a = array[:, :, 3]
else:
    r = array
    g = array
    b = array
    has_alpha = False

# original dimensions
orig_w = image.width
orig_h = image.height

# padded power-of-two dimensions
pad_w = next_pow2(orig_w)
pad_h = next_pow2(orig_h)

# prepare output file
output_file_name = re.sub(r'.[a-zA-Z0-9]*$', '.dat', image_file)
output_file = open(output_file_name, 'w')

output_file.write("// pimage rom content of: {}\n".format(sys.argv[1]))
output_file.write("// WIDTH = {}\n".format(orig_w))
output_file.write("// HEIGHT = {}\n".format(orig_h))

# generate padded canvas (transparent default)
for h in range(pad_h):
    for w in range(pad_w):

        if h < orig_h and w < orig_w:
            rv = r[h, w]
            gv = g[h, w]
            bv = b[h, w]

            if has_alpha:
                transparent_bit = '1' if a[h, w] == 0 else '0'
            else:
                transparent_bit = '0'
        else:
            rv = 0
            gv = 0
            bv = 0
            transparent_bit = '1'  # padded area = transparent

        r_val = '{:X}'.format(rv)[0]
        g_val = '{:X}'.format(gv)[0]
        b_val = '{:X}'.format(bv)[0]

        pixel = transparent_bit + r_val + g_val + b_val
        output_file.write(pixel + "\n")

output_file.close()