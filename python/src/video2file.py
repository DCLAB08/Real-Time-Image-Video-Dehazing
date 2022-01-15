'''
    video2file.py
    convert mp4 into RGB raw file (byte format)
'''

import cv2
 
FILE = "../data/walk.mp4"
OUT_FILE = "../data/output.bin"

# Modifying TYPE to determine how the image is sent to FPGA
# ==========================================================
# TYPE 0: RGB24
# TYPE 1: RGB16
TYPE = 0                                     # <- here!!
# ==========================================================

vidcap = cv2.VideoCapture(FILE)
FPS = round(vidcap.get(cv2.CAP_PROP_FPS))
print("original FPS:", FPS)

if(TYPE == 0): # RGB24
    SAMPLE_TIMES = int(FPS/5)
elif(TYPE == 1): # RGB16
    SAMPLE_TIMES = int(FPS/15)

success, frame = vidcap.read()
height, width, channels = frame.shape

# output file
f = open(OUT_FILE, 'wb')

f_count = 0;

if(TYPE == 0): # RGB
    while success:
        if(f_count != SAMPLE_TIMES):
            f_count += 1
            success, frame = vidcap.read()
            continue
  
        for i in range(0, height):
            for j in range(0, width):
                f.write(frame[i,j,0])
                f.write(frame[i,j,1])
                f.write(frame[i,j,2])

        f_count = 1
        success, frame = vidcap.read()

elif(TYPE == 1):
    while success:
        if(f_count != SAMPLE_TIMES):
            f_count += 1;
            success, frame = vidcap.read()
            continue

        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGR565)
        for i in range(0, height):
            for j in range(0, width):
                f.write(bytes([frame[i,j,1]]))
                f.write(bytes([frame[i,j,0]]))

        f_count = 1
        success, frame = vidcap.read()

f.close()
print ("The video has been written to the file ", OUT_FILE)