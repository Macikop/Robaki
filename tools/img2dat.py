#
# Source: Labs page
# Modified to return 13 bit 1 bit alpha and 12 bit RGB
#

import sys
import re
from PIL import Image 
from numpy import asarray

# read argument (image file name) 
image_file = sys.argv[1]

# open image
image = Image.open(image_file)

# convert image to array
# the array shape is [width x height x 4]
# these 4 arrays are: red, green, blue and alpha
array = asarray(image)
# check if the image is rgb or black&white
is_rgb = len(array.shape) > 2

if is_rgb:
    r = array[:,:,0]
    g = array[:,:,1]
    b = array[:,:,2]
    # Check if alpha channel exists (RGBA)
    has_alpha = array.shape[2] >= 4
    if has_alpha:
        a = array[:,:,3]
else:
    r = array
    g = array
    b = array
    has_alpha = False

# prepare output file
output_file_name = re.sub('.[a-zA-Z0-9]*$', '.dat', image_file)
output_file = open(output_file_name, 'w')
output_file.write("// image rom content of: " + str(image_file) + "\n")
output_file.write("// WIDTH = " + str(image.width) + "\n")
output_file.write("// HEIGHT = " + str(image.height) + "\n")
output_file.write("// BIT [12] = transparency (1 if transparent, 0 if opaque)\n")
output_file.write("// BIT [11:8] = red\n")
output_file.write("// BIT [7:4] = green\n")
output_file.write("// BIT [3:0] = blue\n")

# for each pixel convert color to 13-bit with transparency bit
for h in range(image.height):
    for w in range(image.width):
        # Extract RGB (take upper 4 bits from each 8-bit value)
        r_val = '{:X}'.format(r[h,w])[0]
        g_val = '{:X}'.format(g[h,w])[0]
        b_val = '{:X}'.format(b[h,w])[0]
        
        # Determine transparency bit (1 if transparent, 0 if opaque)
        if has_alpha:
            transparent_bit = '1' if a[h,w] == 0 else '0'
        else:
            transparent_bit = '0'  # No alpha channel = opaque
        
        # Format as 13-bit: {transparency_bit[12], R[11:8], G[7:4], B[3:0]}
        pixel = transparent_bit + r_val + g_val + b_val
        output_file.write(pixel + "\n")

output_file.close()