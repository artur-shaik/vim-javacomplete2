#!/usr/bin/env python
# encoding: utf-8

import socket
import sys
import time
import subprocess
import os

# function to get free port from ycmd
def GetUnusedLocalhostPort():
  sock = socket.socket()
  # This tells the OS to give us any free port in the range [1024 - 65535]
  sock.bind(('', 0))
  port = sock.getsockname()[1]
  sock.close()
  return port

SERVER = ('127.0.0.1', GetUnusedLocalhostPort())

# A wrapper for subprocess.Popen that works around a Popen bug on Windows.
def SafePopen(*args, **kwargs):
    if kwargs.get('stdin') is None:
        kwargs['stdin'] = subprocess.PIPE if sys.platform == 'win32' else None

    return subprocess.Popen( *args, **kwargs )

class JavaviBridge():

    sock = None
    popen = None
    logfile = None

    def setupServer(self, javabin, args, classpath):
        environ = os.environ.copy()
        if 'CLASSPATH' in environ:
            environ['CLASSPATH'] = environ['CLASSPATH'] + (';' if sys.platform == 'win32' else ':') + classpath
        else:
            environ['CLASSPATH'] = classpath

        if vim.eval('exists("g:JavaComplete_JavaviLogfileDirectory")') == "1":
            self.logfile = open(vim.eval("g:JavaComplete_JavaviLogfileDirectory") + "/javavi_" + str(SERVER[1]) + ".log", "w")
            output = self.logfile
        else:
            output = subprocess.PIPE

        is_win = sys.platform == 'win32'
        shell = is_win == False
        if is_win and vim.eval('has("gui_running")'):
            info = subprocess.STARTUPINFO()
            info.dwFlags = 1
            info.wShowWindow = 7
            self.popen = SafePopen(javabin + ' ' + args + ' -D ' + str(SERVER[1]), shell=shell, env=environ, stdout = output, stderr = subprocess.PIPE, startupinfo = info)
        else:
            self.popen = SafePopen(javabin + ' ' + args + ' -D ' + str(SERVER[1]), shell=shell, env=environ, stdout = output, stderr = subprocess.PIPE)

    def pid(self):
        return self.popen.pid

    def port(self):
        return SERVER[1]

    def poll(self):
        return self.popen.poll() is None

    def terminateServer(self):
        self.popen.terminate()

        if self.logfile:
            self.logfile.close()

    def makeSocket(self):
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        except socket.error as msg:
            self.sock = None

        try:
            self.sock.connect(SERVER)
            time.sleep(.1)
        except socket.error as msg:
            self.sock.close()
            self.sock = None

        if self.sock is None:
            print('could not open socket, try again')
            return

        self.sock.setblocking(0)


    def send(self, data):
        if self.sock is None:
            self.makeSocket()
            if self.sock is None:
                return ''

        self.sock.sendall((data.decode('UTF-8') + '\n').encode('UTF-8'))
        totalData = []
        while 1:
            try:
                data = self.sock.recv(4096)
                if not data or len(data) == 0:
                    break

                totalData.append(data.decode('UTF-8'))
                time.sleep(.01)
            except:
                if totalData: break

        self.sock.close()
        self.sock = None
        return ''.join(totalData)
