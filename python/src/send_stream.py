'''
    stream.py
    extract frame from URL (through HLS protocol)
    (only support 640x480 streaming image)
    and send it to destination IP address
'''

import cv2
import socket
import time
import sys

PACKET_SIZE = 1452
DELAY = 0

# DCLAB_5G
HOST, PORT = "192.168.50.2", 1234

# ethernet connection
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 8192)
client.connect((HOST, PORT))

# video url (HLS protocol)
# 640 480
# 合歡山武嶺亭 台14甲31K+500標高3275公尺 https://tw.live/cam/?id=T14A-d61a0c91
VIDEO_URL = "https://thbcctv07.thb.gov.tw/T14A-d61a0c91"

# 清境農場 台14甲6K+950 仁愛鄉-仁和路雲之味餐廳前 https://tw.live/cam/?id=T14A-006K-950
# VIDEO_URL = "https://thbcctv07.thb.gov.tw/T14A-006K+950"
cap = cv2.VideoCapture(VIDEO_URL)
if (cap.isOpened() == False):
    print('!!! Unable to open URL')
    sys.exit(-1)

# retrieve FPS and calculate how long to wait between each frame to be display
fps = cap.get(cv2.CAP_PROP_FPS)
wait_ms = int(1000/fps)
print('Original Video FPS:', fps)


success = False
frame = 0
while not success:
    success, frame = cap.read()
height, width, channels = frame.shape

print('Original Video resolution:',  height, ',', width)


count = 0
packet_count = 0
data_PACKET = bytearray(PACKET_SIZE)

while(True):
    # read one frame
    t = time.time()
    cap = cv2.VideoCapture(VIDEO_URL)
    ready, frame = cap.read()
    if not ready:
        print('Can\'t get image')
        print('Trying again...')
        cap = cv2.VideoCapture(VIDEO_URL)
        ready, frame = cap.read()
        continue

    for i in range(0, height):
        for j in range(0, width):
            data_PACKET[count] = frame[i,j,0]
            data_PACKET[count+1] = frame[i,j,1]
            data_PACKET[count+2] = frame[i,j,2]
            count += 3

            if(count == PACKET_SIZE):
                count = 0  
                packet_count += 1
                if not(client.send(data_PACKET)):
                    print("error occurred")
                time.sleep(DELAY)

    print('current fps: ', 1/(time.time()-t))
