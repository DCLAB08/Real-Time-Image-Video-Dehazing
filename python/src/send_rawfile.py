'''
    send_rawfile.py
    send raw RGB file to destination IP address
'''

import socket
import time

# Parameters
PACKET_SIZE = 1452

# DCLAB_5G
HOST, PORT = "192.168.50.2", 1234
# Dlink-router
# HOST, PORT = "192.168.0.3", 1234

FILE = "../data/output_RGB24.bin"
f = open(FILE, 'rb')

# Modifying TYPE to determine how the image is sent to FPGA
# TYPE 0: RGB24
# TYPE 1: RGB16
# ==========================================================
TYPE = 0                                     # <- here!!
DELAY = 2e-4
# ==========================================================

# ethernet connection
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 8192)
client.connect((HOST, PORT))


print("Start sending the file...")
start_time = time.time()
s = time.time()

# Read all data, the type of all_data is "bytes" (byte array)
all_data = f.read()

count = 0
print(len(all_data))
while(count+PACKET_SIZE < len(all_data)):
    if not (client.send(all_data[count:count+PACKET_SIZE])):
        print("error occurred")

    count += PACKET_SIZE
    # print(time.time()-s) # With the print function, we can know whether the the connection is alive
    s = time.time()
    time.sleep(DELAY)

# Send last packet (may not reach the MTU)
if not (client.send(all_data[count:len(all_data)-1])):
    print("error occurred")

send_time = time.time()-start_time

if(TYPE == 0):
    frame_sent = len(all_data)/921600
elif(TYPE == 1):
    frame_sent = len(all_data)/614400
     

print ("Time costed = %s s" % send_time)
print ("Total %d frames have been sent to %s" % (frame_sent, HOST))
print ("Average FPS = ", frame_sent/send_time)
print ("The video has been sent to %s" % (HOST))

client.close()