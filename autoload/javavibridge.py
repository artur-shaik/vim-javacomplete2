#!/usr/bin/env python
# encoding: utf-8

import socket
import sys
import time
import subprocess

SERVER = ('127.0.0.1', 9999)

# A wrapper for subprocess.Popen that works around a Popen bug on Windows.
def SafePopen(*args, **kwargs):
    if kwargs.get('stdin') is None:
        kwargs['stdin'] = subprocess.PIPE if sys.platform == 'win32' else None

    return subprocess.Popen( *args, **kwargs )

class JavaviBridge():

    sock = None
    popen = None

    def setupServer(self, javabin, args):
        self.popen = SafePopen([javabin + ' ' + args + ' ' + str(SERVER[1])], shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE)

    def pid(self):
        return self.popen.pid

    def poll(self):
        return self.popen.poll() is None

    def terminateServer(self):
        self.popen.terminate()

    def makeSocket(self):
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        except socket.error as msg:
            self.sock = None

        try:
            self.sock.connect(SERVER)
        except socket.error as msg:
            self.sock.close()
            self.sock = None

        if self.sock is None:
            print('could not open socket')
            sys.exit(1)

        self.sock.setblocking(0)


    def send(self, data):
        if self.sock is None:
            print("creating socket")
            self.makeSocket()
            if self.sock is None:
                return {}

        self.sock.sendall(data + '\n')
        totalData = []
        while 1:
            try:
                data = self.sock.recv(4096)
                if not data or len(data) == 0:
                    break

                totalData.append(data)
                time.sleep(.01)
            except:
                if totalData: break

        self.sock.close()
        self.sock = None
        return ''.join(totalData)
