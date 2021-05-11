import struct
import numpy as np
from matplotlib import pyplot as plt

HEIGHT = 8
WIDTH = 8

values = []

with open('../mem.hex', 'r') as file:
    counter = 0
    while counter < HEIGHT * WIDTH * 3:
        line = file.readline()
        if line.startswith('//'):
            continue
        value = struct.unpack('!f', bytes.fromhex(line))[0]
        values.append(value)
        counter += 1

img = np.array(values).reshape((HEIGHT, WIDTH, 3))

plt.imshow(img); plt.show()
