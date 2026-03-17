program ndd;

uses
  Sockets, BaseUnix, Netdb, SysUtils;

var
    buf: array[0..4096] of char;
    addr: TInetSockAddr;
    addrlen: TSockLen;
    sock: LongInt;
    n: cint;
    backlog: cint;
    afd: cint;
    fd: cint;
    ipstr: String;
    input_path: String;
    output_path: array[0..64] of char;
    pid: TPid;

procedure listener;
begin

    if fpListen(sock, backlog) = 0 then
      WriteLn('LISTENING')
    else
    begin
      WriteLn('LISTEN REFUSAL');
      Exit;
    end;

  addrlen := SizeOf(addr);
  afd := fpAccept(sock, @addr, @addrlen);

    if afd = -1 then
    begin
      WriteLn('ACCEPT FAILED');
      Exit;
    end;
  WriteLn('CONNECTION ACCEPTED');

end;

procedure pathXfer;
var
  buf2: array[0..64] of char;
  fd2: cint;
begin

  if (ParamStr(1) = 'r') or (ParamStr(1) = 'd') then
    begin
      fd2 := fpRead(afd, buf2, SizeOf(buf2));
      output_path := StrPas(buf2);
    end
  else
    begin
      fpWrite(afd, output_path, SizeOf(output_path) + 1);
    end;

end;

procedure writeFile;
    begin
        fd := fpOpen(input_path, O_RDONLY);
          repeat
            n := fpRead(fd, buf, SizeOf(buf));
            if n > 0 then fpWrite(afd, buf, n);
    until n <= 0;
    fpClose(fd);
    fpClose(afd);
end;

procedure readFile;
    begin
        fd := fpOpen(PChar(output_path),O_WrOnly or O_Creat or O_Trunc, 438);
          repeat
            n := fpRead(afd, buf, SizeOf(buf));
            if n > 0 then fpWrite(fd, buf, n);
    until n <= 0;
    fpClose(fd);
    fpClose(afd);
end;

procedure tx;
begin

  addr.sin_family := AF_INET;
  addr.sin_port := htons(9999);
  addr.sin_addr := StrToNetAddr(ipstr);
  fpConnect(sock, @addr, SizeOf(addr));

  afd := sock;
  pathXfer;
  writeFile;

end;

procedure rx;
begin

  addr.sin_family := AF_INET;
  addr.sin_port := htons(9999);
  addr.sin_addr.s_addr := 0;
  fpBind(sock, @addr, sizeof(addr));

  listener;
  pathXfer;
  readFile;

end;

procedure daemon;
begin
    pid := fpFork;
      if pid = -1 then
      begin
        WriteLn('FORK FAILED');
        Exit;
      end;

      if pid = 0 then
        // CHILD
        rx
      else
  // PARENT
  fpExit(0);
end;

begin

  backlog := 5;
  sock := fpSocket(AF_INET, SOCK_STREAM, 0);
  if sock = -1 then
      begin
        WriteLn('COULD NOT CREATE SOCKET');
        Exit;
      end;

  ipstr := ParamStr(2);
  input_path := ParamStr(3);
  output_path := ParamStr(4);

    if (ParamCount = 1) and (ParamStr(1) = 'r') then
      rx
    else if ParamStr(1) = 's' then
      tx
    else if ParamStr(1) = 'd' then
      daemon
    else
      Exit;
end.
