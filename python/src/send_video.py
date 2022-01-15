'''
    send_video.py
    send mp4 file to destination IP address
'''

import cv2
import socket
import time

FILE = "../data/walk.mp4"

def video_play(vidcap):
    s =  time.time()
    success, frame = vidcap.read()
    while success:
        if(time.time() - s > 3.33e-2):
            success, frame = vidcap.read()
            cv2.imwrite("frame.jpg" , frame) 
            s = time.time()

# Parameters
# 1452 -> each packet needs 0.31 - 0.32 ms 
#  900 -> each packet needs 0.21 - 0.22 ms 
PACKET_SIZE = 1452

# DCLAB_5G
HOST, PORT = "192.168.50.2", 1234
# Dlink-router
# HOST, PORT = "192.168.0.3", 1234


# Modifying TYPE to determine how the image is sent to FPGA
# ==========================================================
# TYPE 0: RGB24
# TYPE 1: RGB16
TYPE = 0                                     # <- here!!
DELAY = 5e-5
# ==========================================================

vidcap = cv2.VideoCapture(FILE)
FPS = round(vidcap.get(cv2.CAP_PROP_FPS))
print("original FPS:", FPS)

if(TYPE == 0): # RGB24
    SAMPLE_TIMES = int(FPS/5)
elif(TYPE == 1): # RGB16
    SAMPLE_TIMES = int(FPS/7.5)


# print("new FPS:", SAMPLE_TIMES)
success, frame = vidcap.read()
height, width, channels = frame.shape

# ethernet connection
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 8192)
client.connect((HOST, PORT))

f_count = SAMPLE_TIMES
frame_sent = 0
R_last = 0


# output packet to file
f = open("../data/output.bin", 'wb')

count = 0;
packet_count = 0;
data_PACKET = bytearray(PACKET_SIZE);

print("Start sending video (size = %d * %d)" % (width, height))
start_time = time.time()
s = time.time()


if(TYPE == 0): # RGB
    while success:
        if(f_count != SAMPLE_TIMES):
            f_count += 1
            success, frame = vidcap.read()
            continue
  
        frame_sent += 1
        fps_count = time.time()
        for i in range(0, height):
            for j in range(0, width):
                R_last = frame[i,j,2]
                data_PACKET[count] = frame[i,j,0]
                data_PACKET[count+1] = frame[i,j,1]
                data_PACKET[count+2] = frame[i,j,2]
                R_last = data_PACKET[count+2]
                count += 3

                if(count == PACKET_SIZE):
                    count = 0  
                    packet_count += 1
                    if not(client.send(data_PACKET)):
                        print("error occurred")
                    # print(time.time()-s)
                    s = time.time()
                    time.sleep(DELAY)

        f_count = 1
        print('current fps: ', 1/(time.time()-fps_count))
        # print("frame %d has been sent" % (count))
        success, frame = vidcap.read()

elif(TYPE == 1):
    while success:
        if(f_count != SAMPLE_TIMES):
            f_count += 1;
            success, frame = vidcap.read()
            continue

        frame_sent += 1
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGR565)
        fps_count = time.time()
        for i in range(0, height):
            for j in range(0, width):
                
                data_PACKET[count] = frame[i,j,1]
                data_PACKET[count+1] = frame[i,j,0]

                R_last = data_PACKET[count+1]
                count += 2
                if(count == PACKET_SIZE):
                    count = 0  
                    packet_count += 1
                    if not(client.send(data_PACKET)):
                        print("error occurred")
                    # print(time.time()-s)
                    s = time.time()
                    time.sleep(DELAY)

        f_count = 1
        print('current fps: ', 1/(time.time()-fps_count))
        # print("frame %d has been sent" % (count))
        success, frame = vidcap.read()


if not(client.send(data_PACKET[0:count])):
    print("error occurred")

send_time = time.time()-start_time

print ("Last byte (R) = ", R_last)
print ("Time costed = %s s" % send_time)
print ("Total %d packets have been sent to %s" % (packet_count, HOST))
print ("Total %d frames have been sent to %s" % (frame_sent, HOST))
print ("Average FPS = ", frame_sent/send_time)
print ("The video has been sent to %s" % (HOST))

client.close()