NDD

This tool allows you to transfer files over your network using a raw socket connection. It includes a mode allows it to be used as a service.


{USAGE}

RECIEVE
'ndd r'

SEND
'ndd s *IP* /file/to/send /destination/dir/filename'

DAEMON
'ndd d'


Compile with FPC. Copy binary to /usr/local/bin

There is no encryption or verification, use at your own risk.
