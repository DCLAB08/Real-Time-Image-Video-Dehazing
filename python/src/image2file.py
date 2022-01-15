'''
    image2file.py
    convert jpg image into RGB raw file (byte format)
'''

import cv2
import socket
import time

FILE = "../data/test.jpg"
OUT_FILE = "../data/output.bin"

# Parameters
PACKET_SIZE = 1452
HOST, PORT = "192.168.50.2", 1234


# Modifying TYPE to determine how the image is sent to FPGA
# TYPE 0: RGB24
# TYPE 1: RGB16 (R5G6B5)
# ==========================================================
TYPE = 1                                   # <- here!!
DELAY = 0
# ==========================================================

image = cv2.imread(FILE)

if(TYPE == 1):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2BGR565)

# image = cv2.imread('fog.jpeg')
height, width, channels = image.shape
f = open(OUT_FILE, 'wb')
print("Start writing image (size = %d * %d)" % (width, height))

if(TYPE == 0): # RGB24
    for i in range(0, height):
        for j in range(0, width):
            R_last = image[i,j,2]
            data_PACKET[count] = image[i,j,0]
            data_PACKET[count+1] = image[i,j,1]
            data_PACKET[count+2] = image[i,j,2]
            count += 3
            if(count == PACKET_SIZE):
                count = 0  
                if not(client.send(data_PACKET)):
                    print("error occurred")
                print(time.time()-s)
                s = time.time()
                time.sleep(DELAY)

elif(TYPE == 1): #RGB16
    for i in range(0, height):
        for j in range(0, width):
            print(i, j)
            f.write(bytes([image[i,j,1]]))
            f.write(bytes([image[i,j,0]]))

f.close()


