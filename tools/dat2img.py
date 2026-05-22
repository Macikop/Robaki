#
# Source: Labs page
# Modified to accept 13 bit length word (1 bit - transparency, 12 bit - rgb)
#
import sys
import re
from PIL import Image 
from numpy import (array, uint8)

dat_file_name = sys.argv[1]
dat_file = open(dat_file_name, 'r')

# skip header and read W and H
dat_file.readline()
width = int(re.sub('\n', '', re.sub('// WIDTH = ', '', dat_file.readline())))
height = int(re.sub('\n', '', re.sub('// HEIGHT = ', '', dat_file.readline())))

rgb = array([[[0 for i in range(4)] for w in range(width)] for h in range(height)], dtype=uint8)

# read pixel by pixel
w = 0
h = 0
for pixel_line in dat_file:
    pixel = pixel_line.strip()
    
    # Skip empty lines and comment lines
    if not pixel or pixel.startswith('//'):
        continue
    
    # Check if 13-bit format (4 hex digits with transparency)
    if len(pixel) >= 4:
        # 13-bit format: {T, R, G, B}
        # Extract transparency bit (bit 12, first hex digit & 1)
        transparency_bit = int(pixel[0], 16) & 1
        alpha = 0 if transparency_bit == 1 else 255
        
        # Extract RGB (remaining 3 hex digits)
        r_val = 16 * uint8(int(pixel[1], 16))
        g_val = 16 * uint8(int(pixel[2], 16))
        b_val = 16 * uint8(int(pixel[3], 16))
    else:
        # Legacy 12-bit format: {R, G, B} (3 hex digits, opaque)
        r_val = 16 * uint8(int(pixel[0], 16))
        g_val = 16 * uint8(int(pixel[1], 16))
        b_val = 16 * uint8(int(pixel[2], 16))
        alpha = 255
    
    rgb[h, w] = [r_val, g_val, b_val, alpha]
    
    if w == width - 1:
        h = h + 1
    w = (w + 1) % width

dat_file.close()

image = Image.fromarray(rgb)
image.show()