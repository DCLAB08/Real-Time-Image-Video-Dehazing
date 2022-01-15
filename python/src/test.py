'''
    test.py
    debug use
'''

import cv2
import socket
import time
import threading

data1 = bytes([1,100,1,1,1,1,1,1])
data2 = bytes([2,3])
data3 = bytes([4,5,6])
data4 = bytes([7,8,9,10])
data5 = bytes([11,12,13,14,15])

def Client_receive(client): 
    while True:
        data_recv = client.recv(1024)
        # print("Received...", int.from_bytes(data_recv, byteorder='big'))
        print("Received...", data_recv)

# ethernet connection
HOST, PORT = "192.168.50.2", 1234
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.connect((HOST, PORT))

# Start receive threading
t = threading.Thread(target=Client_receive, args = (client,))
t.daemon = True
t.start()

print("Start sending")

print("Send...")
client.send(bytes(0))
time.sleep(1)
input("Press Enter to continue...\n")

print("Send...")
client.send(bytes(data1))
time.sleep(1)
input("Press Enter to continue...\n")

print("Send...")
client.send(bytes(data2))
time.sleep(1)
input("Press Enter to continue...\n")

print("Send...")
client.send(bytes(data3))
time.sleep(1)
input("Press Enter to continue...\n")

print("Send...")
client.send(bytes(data4))
time.sleep(1)
input("Press Enter to continue...\n")

print("Send...")
client.send(bytes(data5))
time.sleep(1)
input("Press Enter to continue...\n")

print("End sending")
client.close()
