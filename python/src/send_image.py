'''
    send_image.py
    send jpg file to destination IP address
'''

import cv2
import socket
import time

# Maximum PACKET size: 1454 bytes
# The Problem now is that the speed cannot afford our need (640p 30fps)
# So we decide to send the raw jpeg in binary format to FPGA 
# And decode it in fpga 

# Parameters
PACKET_SIZE = 1452
HOST, PORT = "192.168.50.2", 1234
FILE = "../data/test.jpg"

# TYPE 0: RGB24
# TYPE 1: RGB16 (R5G6B5)

# Modifying TYPE to determine how the image is sent to FPGA
# ==========================================================
TYPE = 0                                   # <- here!!
DELAY = 0
# ==========================================================

image = cv2.imread(FILE)

if(TYPE == 1):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2BGR565)

# image = cv2.imread('fog.jpeg')
height, width, channels = image.shape
BYTES_LENGTH = 3*height*width
LAST_PACKET_SIZE = BYTES_LENGTH % PACKET_SIZE



# ethernet connection
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 8192)
client.connect((HOST, PORT))


# For debug usage
R_last = 0

print("Start sending image (size = %d * %d)" % (width, height))
start_time = time.time()

count = 0;
data_PACKET = bytearray(PACKET_SIZE);
s = time.time()

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
            
            data_PACKET[count] = image[i,j,1]
            data_PACKET[count+1] = image[i,j,0]

            R_last = data_PACKET[count+1]
            count += 2
            if(count == PACKET_SIZE):
                count = 0  
                if not(client.send(data_PACKET)):
                    print("error occurred")
                print(time.time()-s)
                s = time.time()
                time.sleep(DELAY)

if not(client.send(data_PACKET[0:count])):
    print("error occurred")

print("Last byte (R) = ", R_last)
print ("Time costed = %s " % (time.time()-start_time))
print("Image has been sent to %s" % (HOST))

client.close()