'''
    capture.py
    capture image by openCV from URL (HLS protocol)
    and display on local (real-time)
'''

import cv2
import sys

VIDEO_URL = "https://thbcctv16.thb.gov.tw/T9-300K+900"

cap = cv2.VideoCapture(VIDEO_URL)
if (cap.isOpened() == False):
    print('!!! Unable to open URL')
    sys.exit(-1)


# retrieve FPS and calculate how long to wait between each frame to be display
fps = cap.get(cv2.CAP_PROP_FPS)
wait_ms = int(1000/fps)
print('FPS:', fps)


success = False
frame = 0
while not success:
    success, frame = cap.read()
height, width, channels = frame.shape

print('Original Video resolution:',  height, ',', width)

while(True):
    # read one frame
    ret, frame = cap.read()
    # height, width, channels = frame.shape
    # print('height: ', height)
    # print('width: ', width)
    # print('channels: ', channels)
    if not ret:
        continue

    # display frame
    cv2.imshow('frame',frame)
    if cv2.waitKey(wait_ms) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()