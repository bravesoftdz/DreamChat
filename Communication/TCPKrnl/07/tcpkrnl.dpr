//����� ���� DLL ���������������� � ��� ���� ��� ���� (AS IS)
//������� ��������������� �� ����������� ��� ������ ����� �� �����.
//� ���� �� ����������� � ����� DELPHI 5 + FREE WARE component DCP +
//������ ���������� ������� JwaWinType � http://www.delphi-jedi.org/
//��... project jedi ������ �������� ������ ��� ����������� :-)
//�.�. �������� ��������� ��� ���� API ������� WINDOWS.
//�� ��� �� ������� �������!

//��������� �����������:
//1.������ �� ���� ��� �������� ����� ����� ���������� ������,
//  �� ����������� �������� � �.�. ���� ���, �� �������� �����, ������ ���
//  �� ������ ���� � ���� �� ������� �������. ����� ����, ����� ����� 
//  ����������� ����� ��� �� ������������� ���� (�� ������� ������) ��� ���-��
//  ��������� ��� ����������� �� �������...
//2.��� ��������� ����� DLL �� ������ �������� �������������� �������,
//  ����������, ��� � ����������� ������������ � ��� ����������, � ����� ���
//  ����������!
//3.� �������������� ����� ��������� �� ������ ����������.


//�������� ������� �������� ���������� �����
library TCPkrnl;

uses
  windows,
  JwaWinType,
  DCPcrypt2,
  DCPrc4,
  sysutils,
  Classes,
  messages,
  ScktComp,
  Inifiles,
  WinSock, extctrls,
  JwaIpHlpApi, MyJwaIpRtrMib, syncobjs;

type
  TMailSlotThread = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
    PROCEDURE OnTryConnect(Sender: TObject);
  end;

type TCallBackFunction = function(Buffer:Pchar; Destination:cardinal):PChar;

function Init(ModuleHandle: HMODULE;AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;forward;
function ShutDown():PChar;forward;
function GetLocalUserLoginName():string;forward;
function GetLocalComputerName():string;forward;
function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;forward;
function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;forward;
function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;forward;

const
  KernelVersion = 'T07';//T = TCP
  WaitForSomething = 250;//���� ������ ������ ������ ���� ������ �������
                         //�� 250�� (�.�. ��� ������������ �� ����� 4 ��� � ���)
  FullWorkSpeed = 10;//������ ������� ��������, � ���� ������ �������� ���������
                     //�� ������, �� ���-���� ������ ���� ������ �� 10��

var
  key, InfoForExe, LocalComputerName, LocalLoginName, LocalIpAddres  :string;
  ApplicationPath                                                    :String;
  ChatVersion, FullVersion                                           :string;
  crypted_in, crypted_out, buffer_in, temp_in, buffer_out            :array[0..1499] of Char;
  hClientSocket                                                      :handle;
  ClientSocket                                                       :TClientSocket;
  Show_SystemMessages_Connect                                        :boolean;
  Show_SystemMessages_Connected                                      :boolean;

  SendMessCount, nMaxMessSize, UsersCount                            :cardinal;
  DCP_rc41                                                           :TDCP_rc4;
  RunCallBackFunction                                                :TCallBackFunction;
  OpenMailSlotList, QueueOfMessages, QueueOfRemoteComputersNames     :TStringList;
  IncommingQueueOfMessages                                           :TStringList;
  MSThread                                                           :TMailSlotThread;
  ConnectingTimer                                                    :TTimer;
  ThreadBlocked, DoConnect                                           :boolean;
  CriticalSection                                                    :TCriticalSection;


{============= �������������� ������� �������� ������ ======================}
FUNCTION  GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
I, Posit: integer;
S: string;
BEGIN
//������������ ��, ��� ����� ������������� (Separator)
S := SourceString;
for I := 1 to ParamNumber do
  begin
  Posit := Pos(Separator, S) + Length(Separator) - 1;
  Delete(S, 1, Posit);
end;
Posit := Pos(Separator, S);
Delete(S, Posit , Length(S) - Posit + 1);
if HideSingleSeparaterError = true then
  begin
  i := Pos(Separator[1], s);
  while i > 0 do
    begin
    delete(s, i, 1);
    i := Pos(Separator[1], s);
    end;
  end;
Result := s;
END;

FUNCTION SetVersion(Version:PChar):PChar;
BEGIN
//���������� ��������� � ������ ������ ���� ���� ������ ������� ����������
FullVersion := '';
ChatVersion := Version;
FullVersion := ChatVersion + KernelVersion;
result := PChar(FullVersion);
END;

{FUNCTION GetOpenMailSlot(pNameOfRemoteComputer:PChar):THandle;
VAR i:integer;
    MailSlotWriteName, sNameOfRemoteComputer:string;
BEGIN
//������ ��� ������ �������� ��������� ���������� ����� �� ����� ��������
//���������� �������� ����� �������� �� ����������. ��-�� ����� ���������
//�������. �������: ������� ��� ��������� � ����� ������� �� ���������.
//� ���� ������� ������ �������� ��������.

//�������� �������� ���������, ����� �� ����� �������� DISCONNECT � ����� �����
//� �� ������ ������ �������� ���������� ������ �������������!!!!
result := INVALID_HANDLE_VALUE;
sNameOfRemoteComputer := pNameOfRemoteComputer;
if OpenMailSlotList.Find(sNameOfRemoteComputer, i) = true then
  begin
  //� ���� ������ �������� ��� ������
  result := THandle(OpenMailSlotList.Objects[i]);
  end
else
  begin
  //�������� �� �����, ��������� �����
  MailSlotWriteName := '\\' + sNameOfRemoteComputer + '\Mailslot\ICHAT047';
  hMailSlotWrite := CreateFile(PChar(MailSlotWriteName),GENERIC_WRITE, FILE_SHARE_READ,
                                nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  OpenMailSlotList.AddObject(sNameOfRemoteComputer, pointer(hMailSlotWrite));
  //������� ������ ������: � ������ ����� pointer(hMailSlotWrite)?
  //�� ��� ������ ����� ������� ����
  //[������(��� �����) + 32��������� �����(Handle ��������� ��������� � ���� ������)]
  //����� ��������� ���, ��� ������ ���� ��������� (����������� �� ���������)
  //������ � ��� ������������� ����� �� ��� ��������� � ��� ������ (����� ��� �����)
  result := hMailSlotWrite;
  //RunCallBackFunction(PChar('��������� �����:' + sNameOfRemoteComputer + '  ' +
  //                    inttostr(hMailSlotWrite)), 0);
  end;
END;}

{==================== �������� ����� ���������� �����  ========================}
function GetLocalUserLoginName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
    lpUserName:PChar;
begin
BufferSize := SizeOf(TempBuffer);
lpUserName := @TempBuffer;
if WNetGetUser(nil, lpUserName, BufferSize) = NO_ERROR then
  begin
  result := lpUserName;
  end
else
  result := 'Error GetLocalUserLoginName'; //��������� � ��������!!!
end;

{===================== �������� ��� ���������� �����  =========================}
function GetLocalComputerName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
begin
BufferSize := SizeOf(TempBuffer);
GetComputerName(@TempBuffer, BufferSize);
LocalComputerName := strpas(StrUpper(TempBuffer));

//LocalComputerName := '192.168.0.5' + '/' + LocalComputerName + '/' + 'Andrey';

if Length(LocalComputerName) > 0 then
  begin
  result := LocalComputerName;
  end
else
  result := 'Error GetLocalComputerName';
end;

{===================== �������� IP ���������� �����  =========================}
{function GetIP : string;
var
wsaData : TWSAData;
P: PHostEnt;
s: array [0..128] of char;
begin
WSAStartup(MAKEWORD(1,1), wsaData);
GetHostName(@s, 128);
P:= GetHostByName(@s);
Result:= iNet_ntoa(PInAddr(p^.h_addr_list^)^);
WSACleanup;
end;}
function GetIP : PChar;
var
err, n: integer;
len, NumberOfInterfaces: cardinal;
MibIpAddrTable: MIB_IPADDRTABLE;
MyAdrr: in_addr;
res, IP, Lan, Internet: string;
ChatConf: TMemIniFile;
begin
Lan := '';
Internet := '';

//RunCallBackFunction(PChar('����������� ������� ����������:'), 0);
//IP_For_Exe := '127.0.0.1';
res := '127.0.0.1';
len := SizeOF(MibIpAddrTable);
FillChar(MibIpAddrTable, len, 0);
err := GetIpAddrTable(@MibIpAddrTable, len, false);
if err <> 0 then
  begin
  //��� ������ �-��� ��������� ������
//  RunCallBackFunction(PChar('������! ����� 127.0.0.1'), 0);
  exit;
  end;
n := 0;
//���-�� ����������� = MibIpAddrTable.dwNumEntries;

for n := 0 to MibIpAddrTable.dwNumEntries - 1 do
  begin
  MyAdrr.S_addr := MibIpAddrTable.table[n].dwAddr;
  Ip := inet_ntoa(MyAdrr);
//  RunCallBackFunction(PChar('[' + inttostr(n) + '] ' + ip), 0);
  ip := copy(ip, 1, pos('.', Ip) - 1);
//  if ip = '127' then ����� Loopback ���������;
  if (ip <> '127') then
    begin
    if (ip = '10') or (ip = '172') or (ip = '192') then
      Lan := inet_ntoa(MyAdrr)
    else
      Internet := inet_ntoa(MyAdrr);
    end;
  end;
if Length(LAN) > 0 then res := LAN;
if Length(Internet) > 0 then res := Internet;
ChatConf := TMemIniFile.Create(ApplicationPath + 'config.ini');
if ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1') <> '127.0.0.1' then
  res := ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1');
ChatConf.Free;
result := PChar(res);
//RunCallBackFunction(PChar('� ���� ����� ��������� ��������� IP: ' + res), 0);
end;

function GetLocalIPs : String;
var
err, n: integer;
len, NumberOfInterfaces: cardinal;
MibIpAddrTable: MIB_IPADDRTABLE;
MyAdrr: in_addr;
res, IP, Lan, Internet: string;
ChatConf: TMemIniFile;
begin
Lan := '';
Internet := '';
//RunCallBackFunction(PChar('����������� ������� ����������:'), 0);
//IP_For_Exe := '127.0.0.1';
res := '127.0.0.1';
len := SizeOF(MibIpAddrTable);
FillChar(MibIpAddrTable, len, 0);
err := GetIpAddrTable(@MibIpAddrTable, len, false);
if err <> 0 then
  begin
  //��� ������ �-��� ��������� ������
//  RunCallBackFunction(PChar('������! ����� 127.0.0.1'), 0);
  exit;
  end;
n := 0;
//���-�� ����������� = MibIpAddrTable.dwNumEntries;

for n := 0 to MibIpAddrTable.dwNumEntries - 1 do
  begin
  MyAdrr.S_addr := MibIpAddrTable.table[n].dwAddr;
  Ip := inet_ntoa(MyAdrr);
//  RunCallBackFunction(PChar('[' + inttostr(n) + '] ' + ip), 0);
  ip := copy(ip, 1, pos('.', Ip) - 1);
//  if ip = '127' then ����� Loopback ���������;
  if (ip <> '127') then
    begin
    if (ip = '10') or (ip = '172') or (ip = '192') then
      Lan := inet_ntoa(MyAdrr)
    else
      Internet := inet_ntoa(MyAdrr);
    end;
  end;
if Length(LAN) > 0 then res := LAN;
if Length(Internet) > 0 then res := Internet;

ChatConf := TMemIniFile.Create(ApplicationPath + 'config.ini');
if ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1') <> '127.0.0.1' then
  res := ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1');
ChatConf.Free;
result := res;
//RunCallBackFunction(PChar('� ���� ����� ��������� ��������� IP: ' + res), 0);
end;

{======================== GetIncomingMessageCount =============================}
function GetIncomingMessageCount():cardinal;
begin
//exe �������� ��� �-���, ����� ������ ������� ������ ���������.
//���������� ���������� ��������� ���������, ��������� ���������.

//��������!!! � ����������� ���� ������������ � �-����� ������� ��������
//�������!!! ������ ��������� ��� ���������� �������� � ���� �-����!
//�.�. IncommingQueueOfMessages ��� �������� � ������� ��� �����
//�������� �-���, ��� ���������� ��������� � ����� �������.
CriticalSection.Acquire; // ������������ ������ �������
try
  if (ThreadBlocked = false) and (IncommingQueueOfMessages <> nil) then
    result := IncommingQueueOfMessages.Count
  else
    result := 0;
finally
  CriticalSection.Release;
end;  
end;

{=========================== GetNextIncomingMessage ===========================}
function GetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
var MessSize:cardinal;
begin

//exe �������� � ��� �-��� ��������� �� �����, � ������� ��� ������ ���������
//��������� ��������� ���������
//���������� ���-�� ��������� ���������.
CriticalSection.Acquire; // ������������ ������ �������
try
  if IncommingQueueOfMessages <> nil then
    begin
    if (ThreadBlocked = false) and (IncommingQueueOfMessages.Count > 0) then
      begin

      //RunCallBackFunction(PChar('IncommingQueueOfMessages: ' + inttostr(IncommingQueueOfMessages.Count)), 0);
      //RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.Count - 1]), 0);

      MessSize := StrToInt(IncommingQueueOfMessages.Strings[0]);
      if BufferSize > MessSize then
        CopyMemory(PBufferForMessage,  Pointer(IncommingQueueOfMessages.Objects[0]), MessSize)
      else
        begin
        RunCallBackFunction(PChar('��-�� �� ������ ������� ������, ' +
                    '���������������� EXE������, ��� ������ ��������� �� DLL ' +
                    '��������� �������� ��������� ���� ������� ��� ���������'), 0);
        RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[0]), 0);
        end;
      //RunCallBackFunction(PChar('PBufferForMessage: '), 0);
      //RunCallBackFunction(PChar(PBufferForMessage), 0);

      //StrDispose(PChar(IncommingQueueOfMessages.Objects[0]));
      FreeMem(Pointer(IncommingQueueOfMessages.Objects[0]));
      IncommingQueueOfMessages.Delete(0);
      end
    else
      begin
      RunCallBackFunction(PChar('Thread EXE was Blocked for 1 time!: '), 0);
      //PBufferForMessage := @buffer_in;
      end;
    end;
finally
  CriticalSection.Release;
end;
result := 0;//length(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.count - 1]));
end;

PROCEDURE TMailSlotThread.OnTryConnect(Sender: TObject);
begin
if (ConnectingTimer <> nil) and (ClientSocket <> nil) and
  (ClientSocket.Socket.Connected = false) then
  begin
  RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Trying connect to ' +
                      ClientSocket.Address + ':' + Inttostr(ClientSocket.port)), 0);
  //����� �� ������ ��������� ��������� � ����� ���?
  if Show_SystemMessages_Connect = true then
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Trying connect to ' +
                        ClientSocket.Address + ':' + Inttostr(ClientSocket.port)), 1);
  ClientSocket.Open;
  ConnectingTimer.Interval := 3000;
  end;
end;

{=========================== ClientSocketError ===========================}
procedure TMailSlotThread.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                ErrorEvent: TErrorEvent; var ErrorCode: Integer);
var s:string;
begin
//eeGeneral
  case ErrorEvent of
    eeGeneral:
      begin
      s := 'Communication: General error (' + inttostr(ErrorCode) + ')';
      end;
    eeSend:
      begin
      s := 'Communication: Send error (' + inttostr(ErrorCode) + ')';
      end;
    eeReceive:
      begin
      s := 'Communication: Receive error (' + inttostr(ErrorCode) + ')';
      end;
    eeConnect:
      begin
      s := 'Communication: Connect error (' + inttostr(ErrorCode) + ')';
      end;
    eeDisconnect:
      begin
      s := 'Communication: Disconnect error (' + inttostr(ErrorCode) + ')';
      end;
    eeAccept:
      begin
      s := 'Communication: Accept error (' + inttostr(ErrorCode) + ')';
      end;
  end;
RunCallBackFunction(PChar(s), 0);
RunCallBackFunction(PChar(s), 1);
ErrorCode := 0;
end;

{=========================== ClientSocketConnecting ===========================}
procedure TMailSlotThread.ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
RunCallBackFunction(PChar('Socket Connecting... '), 0);
end;
{============================ ClientSocketConnect =============================}
procedure TMailSlotThread.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
if ClientSocket.Socket.Connected = true then
  begin
  RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                            ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 0);
  if Show_SystemMessages_Connected = true then
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                              ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 1);
  end;
if ConnectingTimer <> nil then ConnectingTimer.Enabled := false;
DoConnect := false;
end;
{============================ ClientSocketDisconnect =============================}
procedure TMailSlotThread.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
if ConnectingTimer <> nil then
  begin
  RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Disconnect'), 0);
  RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Disconnect.'), 1);
  DoConnect := true;
  ConnectingTimer.Interval := 1;
  ConnectingTimer.Enabled := true;
  end;
end;
{============================ ClientSocketLookup =============================}
procedure TMailSlotThread.ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
begin
RunCallBackFunction(PChar('Socket access...'), 0);
end;

{=============================== ClientSocketRead =============================}
//function GetNextIncomingMessageFromTCP():PChar;
procedure TMailSlotThread.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var SocketReadMessLen, IChatMessLen, NextIchatPacketSize{, MaxMessSize} :cardinal;
    LenOfFieldMessLen, LenOfFieldCommand, HeaderLen, ProcessedData :cardinal;
    PTemp:PChar;
    PMem{, PSource}: Pointer;
    STemp, SHeader:String;
begin
//Socket DLL'�� �������� ��� �-���, ����� � ���� ���-�� ������ �� ����
//��������� ������, ������������, ���� ������ ��������� "���������" ���������
//IChat ��������� �� � �������� � ������������� ����� IncommingQueueOfMessages
//������ ��������� ����� �������� exe, ����� ��� ����� ������.
//���������� ���� ����������, ����� EXE �� ���� ���������� � IncommingQueueOfMessages
//���� �� ��������� ��� �������.
ThreadBlocked := true;
ZeroMemory(@buffer_in, SizeOf(buffer_in));
ZeroMemory(@crypted_in, SizeOf(crypted_in));

//� ������ buffer_in "�����" ������, �������� �� ����.
SocketReadMessLen := Socket.ReceiveBuf(buffer_in, SizeOf(buffer_in));
//���������� ��� �������������� ���� (���� ���� ��������� �������� ���������)
ProcessedData := 0;

//RunCallBackFunction(PChar('<-- FullReceivedDataSize = [' + inttostr(SocketReadMessLen) + ']'), 0);

repeat
//[����� ���������][0x00] [CMD] [0x00] [���������]
// ^^^^^^^^^^^^^^^--- ��� ����� ��������� ������� � �����, ���������� �� ������ �����
//[106][0][192.168.0.5/ANDREY/Andrey][FORWARD][0][!iChat!!6!!IP/KName/Login!!STATUS!!0!!erew!][66][0][....]
// ^       ^                          ^        ^                                            ^
// |       |<--------------- NextIchatMessSize ------------------------------->|            |
// |                                  |                                                     |
// |<-  HeaderLen                   ->|                                                     |
// |                                                                                        |
// |<----------------------- SocketReadMessLen -------------------------------------------->|
//

//���������� TCPIchat ���������
//[����� ���������]
PTemp := @buffer_in;
STemp := String(PTemp);
NextIchatPacketSize := 0;
try
  NextIchatPacketSize := StrToInt(STemp);
except
  on E:Exception do
    begin
    NextIchatPacketSize := 0;
    RunCallBackFunction(PChar('TCPKRNL Exception! ' + E.ClassName + ' : ' + E.Message), 0);
    end;
end;

SHeader := '[' + STemp + '][$00]';
LenOfFieldMessLen := Length(STemp);
HeaderLen := LenOfFieldMessLen + 1;
//���� HeaderLen ��� ������ ����� ���� [����� ���������] + [0x00]
//RunCallBackFunction(PChar('<-- LenOfFieldMessLen = [' + Inttostr(LenOfFieldMessLen) +
//                          ']; NextIchatPacketSize = [' + Inttostr(NextIchatPacketSize) + ']'), 0);

if ((NextIchatPacketSize + HeaderLen) <= SocketReadMessLen) and
  (NextIchatPacketSize > 0) then
  begin
  //��� �������� �� �����, ����� �� ��������� ����� � ������� ������ ����� ���������
  //��� ������ ������ ���������
  //[�������]
  PTemp := @buffer_in[HeaderLen];
  STemp := String(PTemp);
  SHeader := SHeader + '[' + STemp + '][$00]';
  LenOfFieldCommand := Length(STemp);
  HeaderLen := HeaderLen + LenOfFieldCommand + 1;

  //[���������]
  PTemp := @buffer_in[HeaderLen];

  //���� ������������! IChatMessLen ����� ����� �������������!
  //� ������ �.�. IChatMessLen: cardinal, �� ������ �������������!!!!!
  //� ��� ����� ������������ �����! �������� ��������� ������� ��������!
  if (NextIchatPacketSize > LenOfFieldCommand + 1) then
    begin
    IChatMessLen := NextIchatPacketSize - LenOfFieldCommand - 1;

    //���������� ������������� ��������� IChat � ����� crypted_in
    Move(buffer_in[HeaderLen], crypted_in, IChatMessLen);

    //������� ��������� �����, � ���� �������� �������������� ��������� IChat
    ZeroMemory(@temp_in, SizeOf(temp_in));

    DCP_rc41.Init(key[1], length(key) * 8, nil);
    DCP_rc41.Decrypt(crypted_in, temp_in, IChatMessLen);

    //StrCopy ������������ � $00, ������������� ������ �-����
    PMem := AllocMem(IChatMessLen);//�������������

//������� DELPHI (c):
// dRake (c) (29.11.05 21:06)
//   ���� ���������, �� ����� ������, ���������� ����� AllocMem(), ����� ��
//   ������ ����� �� ����� ��������� ������ ������ �� ������� �� ���������?
// jack128 (c) (29.11.05 21:16) [2]
//   ������������ �����, �� ��� �� ���������������, ������� �� ����� ��� ������..
// ������ (c) (29.11.05 21:18) [3]
//   ������ getmem.inc � ����� ������ mystic'� �� www.delphikingom.ru
// Palladin (c) (29.11.05 21:25) [4]
//   :) �� ������-�� ����� ��������� ������ ����� ������� �� ������� ������...
//   ������ � ����������� �������� Delphi ��� ������ �� �����������...
//   ����� ��� ��� ����������...
// dRake � (29.11.05 22:11) [5]
//   ����������� ��� ��� ���� ���-�� ���� ���� ���������� ����� �������
//   ����� ������ ������� �� ������ ��������� ������ :)
// jack128 (c) (29.11.05 22:34) [7]
//   ������ ������ ��� ����� ����, �� ����� �� �������������� �������� ������
//   ����� ���������..
// dRake (c) (30.11.05 12:22) [8]
//   ��.. � ���� ��� �������� ��� ������ ������?
// ������ (c) (30.11.05 12:30) [9]
//   ����� ������� ��� ������ ����� ���� ����� � ��� "������ �����", �������
//   ������ ������, ������ ��� ����������� ������� ������ ������������� ������
//   ��������� ���������� ���������, � ����� ... �� ... ����������....

//�����:
//����� - ��������, ��������� �� ���� ��� ����� ������������� :-)))
    CopyMemory(PMem, @temp_in, IChatMessLen);

//RunCallBackFunction(PChar('<-- LenOfFieldMessLen = [' + Inttostr(LenOfFieldMessLen) +
//                          ']; NextIchatPacketSize = [' + Inttostr(NextIchatPacketSize) +
//                          ']; IChatMessLen = [' + inttostr(IChatMessLen) + ']'), 0);
//RunCallBackFunction(PChar('<-- IChatMessLen = [' + inttostr(IChatMessLen) + ']'), 0);

//    RunCallBackFunction(PChar('<--' + SHeader + string(PMem)), 0);
    //^^^^^^^^^^^ ��� ������� ����� ������ ������� � ����� ������, ������
    //�������� �� ������� �� ��� ��� ���� �� ��������� 0, � ���� � �������
    //��� ��� � �� ����, ������� ��� �������� �� ����� �������
    SetString(STemp, PChar(PMem), IChatMessLen);//��� �����
//RunCallBackFunction(PChar('<--' + SHeader + STemp), 0);

    IncommingQueueOfMessages.AddObject(inttostr(IChatMessLen), pointer(PMem));
    ProcessedData := ProcessedData + LenOfFieldMessLen + NextIchatPacketSize + 1
    end
  else
    begin
    //NextIchatMessSize ���� ������������ ��� ������, �� �������� ���������
    //�����! �������� ������������� ��� ������� �������.
    //���������� ���������!
    ProcessedData := SocketReadMessLen;
    end;
  end
else
  begin
  //���� �������� ��� ������� � ������������� ������� ������!
  //������ ����� ������ �����-�� ����! ���������� �� ���������!
  ProcessedData := SocketReadMessLen;
  end;
until ProcessedData <= SocketReadMessLen;

ThreadBlocked := false;
end;

function SendNextOutgoingMessageFromBuffer:cardinal;
var writeCount, MessageLen :cardinal;
    SDebug, HeaderOfProtocol, NetBiosNameOfRemoteComputer, stemp, scrypto :string;
    Full_buffer :array[0..1499] of Char;
//    PFullPacket: PChar;
begin
//������ ��� ������ �������� ��������� ���������� ����� �� ����� ��������
//���������� �������� ����� �������� �� ����������. ��-�� ����� ���������
//�������. �������: ������� ��� ��������� � ����� ������� �� ���������.
//�� ��� ��� �� ���! �.�. ������ ��������� � �������� ���������� �����
//�������� ��������� ����� (�������� �� �����), � �-��� ������ �����������, �.�.
//WriteFile(hMailSlotWrite....) ��������� �����, �� ��� ��� ���� �� �������
//��������� �� ������ ��� ������� ������, �������� �������� ��� ��� ���������
//�����. ���������� ���� ����� ��������� ������ DLL � ������ � EXE �����
//�����, ���� �������� �����-���� ���������� ��������� ������ EXE.
//������� ����� ��������...
//
//� ��� ����� DLL ��������� �������� ��� �-���, ����� ������, ���� �� � ������
//���������, ������� ���������� ���������.
//(��... �� ������-�� �� ���������, � ~4 ���� � ��� �� "��������" ����, �����
//����� ���� � �� 100 ��� � ��� ��� �� ������ ������)
//������������� ��� ������ �������, �� �������� ����� ����������� ������������.
//sleep(250) <---- ���� windows ���� ���������� ����� ������ ������ ����� 250��
//��� ������� ��� ��� �� �������, �� ���� ���������, �� RTFM �� WINDOWS :-)

result := 0;
if (QueueOfMessages.Count > 0) and (ClientSocket.Socket.Connected = true) then
  begin
  NetBiosNameOfRemoteComputer := QueueOfRemoteComputersNames.Strings[0];
  QueueOfRemoteComputersNames.Delete(0);

  stemp := QueueOfMessages.Strings[0];
  QueueOfMessages.Delete(0);

  //������������� ������
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //����� �� ���� ���� ������ (key[0] � ��� ����� ������ key)

  //������� ������, �������� ������ HEX �����
//  S trCopy(@buffer_out, PChar(stemp));
  CopyMemory(@buffer_out, @stemp[1], length(stemp));

//RunCallBackFunction(PChar(@buffer_out), 0);

  writeCount := Length(stemp);
  DCP_rc41.Encrypt(buffer_out, crypted_out, writeCount);

//RunCallBackFunction(PChar('����� crypto � ���������� writeCount = ' + inttostr(writeCount)), 0);

//  if (hClientSocket <> INVALID_HANDLE_VALUE) then
  if (ClientSocket <> nil) then
    begin
    //[����� ���������] [0x00] [�����������] [0x00] [CMD] [0x00] [���������� | "*"] [0x00] [���������]
    //[][0x00][192.168.0.5/ANDREY/Andrey][0x00][FORWARD][0x00][*][0x00][.......]
    HeaderOfProtocol := LocalComputerName + #00 + 'FORWARD' + #00 + NetBiosNameOfRemoteComputer + #00;
    SDebug := '[' + LocalComputerName + '][$00][' + 'FORWARD' + '][$00][' + NetBiosNameOfRemoteComputer + '][$00]';
    MessageLen := cardinal(Length(HeaderOfProtocol)) + writeCount;
    HeaderOfProtocol := InttoStr(MessageLen) + #00 + HeaderOfProtocol;
    SDebug := GetParamX(stemp, 4, #19#19, true) + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug;

//    scrypto := string(PChar(@crypted_out));
    //�������� � ���, ��� ��� �-��� ���������� � null-terminated ��������
    //������ ��-�� ����� ������������ ������ � � �������� ��������� ���������������
    //���������! ����������� ����� string. ��� ���������� ������� ������ ������,
    //��������� ��� ����� buffer_out, ������� ����� ���������� �����������.
    //������������ MOVE

//RunCallBackFunction(PChar('����� ��������� = [' + inttostr(length(HeaderOfProtocol)) +
//                          ']; ����� crypto = [' + inttostr(writeCount) + ']'), 0);

    MessageLen := length(HeaderOfProtocol) + WriteCount;
    SDebug := SDebug + string(buffer_out);

    CopyMemory(@Full_buffer, @HeaderOfProtocol[1], length(HeaderOfProtocol));
    CopyMemory(@Full_buffer[length(HeaderOfProtocol)], @crypted_out, writeCount);

RunCallBackFunction(PChar({'��������� ������ � �������� ����� [' + inttostr(MessageLen) + '] = ' + }SDebug), 0);
    WriteCount := ClientSocket.Socket.SendBuf(Full_buffer, MessageLen);
    SendMessCount := SendMessCount + 1;
//RunCallBackFunction(Pchar('--> SendNextOutgoingMessageFromBuffer: � Socket ���� �������� = [' + inttostr(WriteCount) + ']'), WriteCount);
    end;
  //������ ����� ������ ������������� �������!!!!
  //��� ����������� ����� ������ ��������� ������ � CallBack

  result := QueueOfMessages.Count;
  end;
//RunCallBackFunction(Pchar('SendNextOutgoingMessageFromBuffer ���� ��������'), 0);
end;

PROCEDURE TMailSlotThread.Execute;
//var count:cardinal;
BEGIN
//�������� ���� ���� DLL. ��� ��������� ��� �������� ���������� �� EXE
//� DLL. ��� ���������� �� � ����� � ���������� ���������� ���������� � EXE
//����� � DLL �������� ��������� ����� � ���� � ������ ���-�� ����, �� ��������
//��� ��������� ���������.
While not Terminated do
  begin
  //���������� �������� ���� ������ DLL
{  count := GetIncomingMessageCountFromMailSlot();
}
  if (SendNextOutgoingMessageFromBuffer = 0) {and (count = 0)} then
    sleep(WaitForSomething)
  else
    sleep(FullWorkSpeed);
{  if count > 0 then GetNextIncomingMessageFromMailSlot();
}
  end;
END;

{=============== �������, ��������� ����� � ��������� �������� ================}
function Init(ModuleHandle: HMODULE; AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;
var Stemp:String;
    L:integer;
    ChatConfig: TMemIniFile;
begin
//����� EXE ����������, �� ������ ��� ������� �����-������ �-��� DLL,
//����������� �������� �-��� ������������� DLL

ApplicationPath := ExePath;
ChatConfig := TMemIniFile.Create(ExePath + 'config.ini');

Show_SystemMessages_Connect := ChatConfig.ReadBool('SystemMessages', 'TryingMessage', true);
Show_SystemMessages_Connected := ChatConfig.ReadBool('SystemMessages', 'ConnectedMessage', true);

ThreadBlocked := false;
hClientSocket := INVALID_HANDLE_VALUE;
InfoForExe := '';
FullVersion := KernelVersion;
SendMessCount := 1;
//key := 'tahci';//��������! �� ��������� ���!!!!
key := ChatConfig.ReadString('Crypto', 'Key', 'tahci');

UsersCount := 0;

{<�������� ��� �����>}
LocalComputerName := GetLocalComputerName();

{<�������� ��� �����>}
LocalLoginName := GetLocalUserLoginName();

{<�������� IP �����>}
LocalIpAddres := GetLocalIPs();
//LocalComputerName
//MessageBox(0, PChar(LocalIpAddres), PChar(inttostr(0)) ,mb_ok);
//RunCallBackFunction(PChar(LocalIpAddres), 0);

LocalComputerName := LocalIpAddres + '/' + LocalComputerName + '/' + LocalLoginName;

if DCP_rc41 = nil then
  begin
  DCP_rc41 := TDCP_rc4.Create(nil);
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  OpenMailSlotList := TStringlist.Create;
  OpenMailSlotList.Sorted := true;
  nMaxMessSize := SizeOf(buffer_in);
  QueueOfMessages := TStringList.Create;
  IncommingQueueOfMessages := TStringList.Create;
  QueueOfRemoteComputersNames := TStringList.Create;
  CriticalSection := TCriticalSection.Create;
  if MSThread = nil then
    begin
    MSThread := TMailSlotThread.Create(false);
    MSThread.Priority := tpIdle;
    end;
  if ClientSocket = nil then
    begin
    ClientSocket := TClientSocket.Create(nil);
    ClientSocket.OnError := MSThread.ClientSocketError;
    ClientSocket.OnRead := MSThread.ClientSocketRead;
    ClientSocket.OnConnect := MSThread.ClientSocketConnect;
    ClientSocket.OnConnecting := MSThread.ClientSocketConnecting;
    ClientSocket.OnDisconnect := MSThread.ClientSocketDisconnect;
    ClientSocket.OnError := MSThread.ClientSocketError;
    ClientSocket.OnLookup := MSThread.ClientSocketLookup;

//    ClientSocket.OnWrite ������ ������

    //�������� ���� � ��� ���� DLL
    L := MAX_PATH + 1;
    SetLength(Stemp, L);
    GetModuleFileName(ModuleHandle, pointer(Stemp), L);
    //��������� config.ini � ����� ����� �������
//    ClientSocket.Port:=7777;
//    ClientSocket.Address:='62.149.2.14';

    ClientSocket.Address := ChatConfig.ReadString('ConnectionType', 'IP', '127.0.0.1');
    ClientSocket.Port := StrToInt(ChatConfig.ReadString('ConnectionType', 'Port', '6666'));
    ClientSocket.ClientType := ctNonBlocking;
//    ClientSocket.Active := true;
    hClientSocket := ClientSocket.Socket.Handle;
    MSThread.Resume;

    DoConnect := true;
    ConnectingTimer := TTimer.Create(nil);
    ConnectingTimer.OnTimer := MSThread.OnTryConnect;
    ConnectingTimer.Interval := 1;
    end;
  if hClientSocket = INVALID_HANDLE_VALUE then
     InfoForExe := '������ �������� hClientSocket1: error ' + inttostr(GetLastError());
  end
else
  InfoForExe := InfoForExe + '�� ���� ������� DCP_rc41, �.�. �� ��� ������!';

RunCallBackFunction := AdressCallBackFunction;

//******************************************************************************
//* ���������� ����� ������� ��������� ������, ��� ����� �� ��������.          *
//* ������ ��� ����� ���� ��� ������ �����, � ������ ������ ��� ������ ���� �  *
//* ���� �������. �� ���������� � EXE �������� ��������� �������:              *
//
//* FUNCTION CallBackFunction(Buffer:Pchar; MessCountInBuffer:cardinal):PChar; *
//* BEGIN                                                                      *
//*   //DLL ����� ������� ��� ������� ����� �� ���������                       *
//* Form2.Memo2.Lines.Add(Buffer);                                             *
//* sglob := 'CallBackFunction: ���� ������ ��� ������� DLL!';                 *
//* result := @sglob[1];                                                       *
//* END;                                                                       *
//******************************************************************************
//���� �� �������, �� ���������:
//� DLL � �������� ��������� �������, ������� �������� ���, ����� ��� ����� EXE.
//������ ���� � DLL ���� ���� ������, �� �� ���� ����� ������������ ����� � EXE
//� ���������� �� � ������������ ������ �������, �� ��������� ����� EXE �������
//���� �� �� �������. ��� ����� � �������� �������� ��������� ������.
//�������������� EXE �������� DLL ����� ����� �������/������, ������� �����
//������� � ������������ ������ �������, DLL ��� ���������� � �������� ��������.
//������ � ������ ����������, ���� ����� �������� �����, ����� �����
//������ ���������� �����! �.�. � CallBackFunction ���������� ������ �
//�����������.

nMaxMessSize := SizeOf(buffer_in);
//���������� ������ ������ ��� ��������� �� ������!

ChatConfig.Free;
result := PChar(InfoForExe);
end;

{========== �������������, ����������� ����� � ��������� ��������� ============}
function ShutDown():PChar;
var n:cardinal;
//    PTemp: PChar;
begin
//������ ��� "�������" EXE �������� �-��� "��������" DLL
//���������� ��� ��� � ������� �� ��������!!!!
//����� DISCONNECT �� ������ ����!!!
While SendNextOutgoingMessageFromBuffer <> 0 do
  begin
  sleep(1);
  end;

result := 'DCP_rc41 ��� ����� ����! � hMailSlotWrite ������!';
if DCP_rc41 <> nil then
  begin
  if CriticalSection <> nil then CriticalSection.Free;
  if ClientSocket <> nil then
    begin
    ClientSocket.Active := false;
    ClientSocket.Close;
    ClientSocket.Free;
    end;
  if MSThread <> nil then
    begin
    MSThread.Terminate;
    sleep(100);
    MSThread.Free;
    MSThread := nil;
    end;
  if ConnectingTimer <> nil then
    begin
    ConnectingTimer.Free;
    end;
  DCP_rc41.Free;
  DCP_rc41 := nil;
  if OpenMailSlotList <> nil then
    begin
    if OpenMailSlotList.Count > 0 then
      begin
      for n := 0 to (OpenMailSlotList.Count - 1) do
        begin
        if THandle(OpenMailSlotList.Objects[n]) > 0 then CloseHandle(THandle(OpenMailSlotList.Objects[n]));
        end;
      end;
    OpenMailSlotList.Free;
    end;

  if (IncommingQueueOfMessages.Count > 0) then
    begin
    for n := (IncommingQueueOfMessages.Count - 1) downto 0 do
      begin
      //������� ������ ��������� ���������!!!!!
//      PTemp := PChar(IncommingQueueOfMessages.Objects[n]);
//      if PTemp <> nil then StrDispose(PTemp);
      if Pointer(IncommingQueueOfMessages.Objects[n]) <> nil then
        FreeMem(Pointer(IncommingQueueOfMessages.Objects[n]));
      IncommingQueueOfMessages.Delete(n);
      end;
    end;
//MessageBox(0, PChar('IncommingQueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
  IncommingQueueOfMessages.Free;
  if (QueueOfMessages.Count > 0) then
    begin
    for n := (QueueOfMessages.Count - 1) downto 0 do
      begin
      QueueOfMessages.Delete(n);
      end;
    end;
  QueueOfMessages.Free;
//MessageBox(0, PChar('QueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
  if (QueueOfRemoteComputersNames.Count > 0) then
    begin
    for n := (QueueOfRemoteComputersNames.Count - 1) downto 0 do
      begin
      QueueOfRemoteComputersNames.Delete(n);
      end;
    end;
  QueueOfRemoteComputersNames.Free;
//MessageBox(0, PChar('QueueOfRemoteComputersNames free'), PChar(inttostr(0)) ,mb_ok);
  result := 'DCP_rc41.Free! All objects Free !';
  end;
end;

{=================== �������� ������� DISCONNECT ==============================}
function SendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
var {writeCount:cardinal;}
    stemp, sLineName, sNetbiosNameOfRemoteComputer, sNameOfLocalComputer,
    sProtoName:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� DISCONNECT
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sLineName := pLineName;
  sNameOfLocalComputer := pNameOfLocalComputer;
  sProtoName := pProtoName;

  //192.168.0.5/ANDREY/Andrey
  sNameOfLocalComputer := LocalComputerName;

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;

  if Length(sNameOfLocalComputer) = 0 then sNameOfLocalComputer := LocalComputerName;

  // iChat  1  ANDREY  DISCONNECT  iTCniaM 
  // iChat  [���� ASCII]  [�����������]  DISCONNECT  iTCniaM 

  //                  iChat               [���� ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [�����������]            DISCONNECT     
           sNameOfLocalComputer  +  #19#19 + 'DISCONNECT'  + #19#19 +
  //       iTCniaM    
           sLineName + #19;

  //������������� ������
  //DCP_rc41.Init('tahci', length(key) * 8, nil);
  DCP_rc41.Init(key[1], length(key) * 8, nil);
  //�� ��� ��� key[1] �� �������� ���������� ���������� �����
  //����� �� ���� ���� ������ (key[0] � ��� ����� ������ key)

  //������� ������, �������� ������ HEX �����
  StrCopy(@buffer_out, PChar(stemp));
  DCP_rc41.Encrypt(buffer_out, crypted_out, Length(stemp));

  //���������� � ��� �������� �������
//  if sNetbiosNameOfRemoteComputer = sNameOfLocalComputer then sNetbiosNameOfRemoteComputer := '.';
  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);

//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);

  end;
result := '';
end;

{====================== �������� ������� CONNECT ==============================}
function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
var stemp, sNameOfRemoteComputer, sProtoName:string;
    sNetbiosNameOfRemoteComputer, sMessageStatusX, sLineName, LocalNickName:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� CONNECT
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  LocalNickName := pLocalNickName;
  sNameOfRemoteComputer := pNameOfRemoteComputer;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sLineName := pLineName;
  sProtoName := pProtoName;

  //���� ��� ����� � ���������� = '', �� ������ ��� ��������� ����
  if Length(sNameOfRemoteComputer) = 0 then sNameOfRemoteComputer := '*';

  sMessageStatusX := pMessageStatusX;
  if Length(sMessageStatusX) = 0 then sMessageStatusX := 'Hi all!';

  //iChat2ANDREYCONNECTiTCniaMAdminsAndrey�����������!*1.21b60
  //iChat [���� ASCII]  [�����������] CONNECTiTCniaM [�����] 
  //[���]  [Away_����] * [������]  [������] 

//                     iChat               [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
//                  CONNECT           iTCniaM            [�����]         
           #19#19 + 'CONNECT' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
//          [���]                         [Away_����]                       *
           LocalNickName + #19#19 + #19#19 + sMessageStatusX + #19#19 + sNameOfRemoteComputer +
//                 [������]               [������]          
            #19#19 + FullVersion + #19#19 + inttostr(status) + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);
  end;
result := '';
end;

{========================= �������� ������� TEXT ==============================}
function SendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer,
    sProtoName, sChatLine:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� TEXT
//iChat983KITTYTEXTgsMTCI ���������� ��������?Andrey
//������ ���������
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
{[~] [ichat] [~~] [������� ASCII] [~~] [�����������] [~~] [TEXT] [~~]
 [�����] [~~] [�����] [~~] [��� ���������� | "*" | ""] [~]
}
  sChatLine := ChatLine;
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sNickNameOfRemoteComputer := pNickNameOfRemoteComputer;
//  SendMessCount := SendMessCount + cardinal(Increment);
  //����� � TEdit �� �������� 99999999 ���� � �� ��������� ������
    sMessageText := pMessageText;
  if length(sMessageText) >= SizeOf(buffer_out) - 100 then
    sMessageText := copy(sMessageText, 0, SizeOf(buffer_out) - 100)
  else
    sMessageText := pMessageText;
  //��� ������ ������ +1, ����� ����� ����� ��������� ��� �� 2 ������ �����������

//  messagebox(0, PChar(MailSlotWriteName), 'SendCommText: MailSlotWriteName=' ,mb_ok);

  //                   iChat              [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              TEXT            iTCniaM            [�����]       
           #19#19 + 'TEXT' + #19#19 + sChatLine + #19#19 + sMessageText + #19#19 +
   //      [��� ����������]                   
           sNickNameOfRemoteComputer + #19 {+ #19};

//  SendMessCount := SendMessCount + 1;
  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages: ' + stemp), 0);
  end;
result := '';
end;

{====================== �������� ������� STATUS ==============================}
function SendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
var sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� STATUS
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

//  MailSlotWriteName := '\\*\Mailslot\ICHAT047';
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //iChat  24           KITTY          STATUS  3         Katushka ��������... ��������� :gigi:
  //iChat  642          ALF            STATUS  3         ���� ���.   
  //iChat [���� ASCII]  [�����������]  STATUS  [������]  [Away_����] 

  //                   iChat              [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS            [������]                                  
           #19#19 + 'STATUS' + #19#19 + inttostr(LocalUserStatus) + #19#19 +
   //      [Away_����]     
           StatusMessage + #19;
//         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ��� �� �����!!!

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{=================== �������� ������� RECEIVED ==============================}
function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
var sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� RECEIVED
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  // iChat  305  KITTY  RECEIVED  gsMTCI . ��� ����.
  // iChat  [���� ASCII]  [�����������]  RECEIVED  gsMTCI  [Away_����]

  //                  iChat               [���� ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [�����������]                 RECEIVED     
           LocalComputerName  +  #19#19 + 'RECEIVED'  + #19#19 +
  //       gsMTCI            [Away_����]         
           'gsMTCI' + #19#19 + MessAboutReceived + #19;
//           'gsMTCI' + #19#19 + ChatUsers[UserId].HelloMessage + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{=================== �������� ������� BOARD ==============================}
function SendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
var n, i, partcount, LenMess, StartPart{, EndPart}:cardinal;
    strbuffer: array of char;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� BOARD
//������ ��� ����, ����� ���������� ������� ��������� ����� ����������
//�� ��������� ������ ������.
//� ����� �� ��������� � ��� �����?! �����, ����� ���������...
LenMess := strlen(pMessageBoard);
partcount := round(LenMess/MaxSizeOfPart) - 1;
setlength(strbuffer, MaxSizeOfPart + 1);
if LenMess > MaxSizeOfPart then
  begin
  for n := 0 to partcount do
    begin
    StartPart := n * MaxSizeOfPart;
//    EndPart := n * MaxSizeOfPart + MaxSizeOfPart;
//    if EndPart > LenMess then EndPart := LenMess;
    for i := 0 to MaxSizeOfPart - 1 do
      begin
      strbuffer[i] := pMessageBoard[StartPart];
      inc(StartPart);
      end;
    SendCommBoardX(pProtoName, pNameOfRemoteComputer, PChar(strbuffer), n);
    end;
  end
else
  begin
  SendCommBoardX(pProtoName, pNameOfRemoteComputer, pMessageBoard, 0);
  end;
result := '';
end;

function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;
var sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
begin
//���������� ���� �������� ��������
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  // iChat  387  VADIMUS  BOARD  0  ����, ������� ����� �����.
  //# iChat ## 20  ## SAMAEL  ## BOARD ## 0 ##                           #

  //                  iChat               [���� ASCII]              
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 +
      //   [�����������]                 BOARD     
           LocalComputerName  +  #19#19 + 'BOARD'  + #19#19 +
  //       [����� ����� ���������]           [MessageBoard]         
           inttostr(PartMessNumber) + #19#19 + pMessageBoard + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{=================== �������� ������� REFRESH ==============================}
function SendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
var sReceiver, sNetbiosNameOfRemoteComputer, sTemp, sAwayMess,
    sProtoName, sLocalNickName, sLineName:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� REFRESH
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  //� ������ ������:
  //iChat137ANDREYREFRESHiTCniaMAdminsAndrey�����������!*1.21b63
  //iChat137ANDREYREFRESHiTCniaMAdminsAndrey�����������!*1.21b63

    sAwayMess := pAwayMess;
    sLocalNickName := pLocalNickName;
    sLineName := pLineName;
    sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
    sReceiver := pReceiver;
    sProtoName := pProtoName;

    //                   iChat              [���� ASCII]                     [�����������]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              REFRESH            iTCniaM            [�����]         
             #19#19 + 'REFRESH' + #19#19 + sLineName + #19#19 + LocalLoginName + #19#19 +
    //       [���]                         [Away_����]           *      
             sLocalNickName + #19#19 + #19#19 + sAwayMess   + #19#19 + sReceiver + #19#19 +
    //       [������]             [������]                     
             FullVersion + #19#19 + inttostr(LocalUserStatus) + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{===================   �������� ������� RENAME   ==============================}
function SendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
var sProtoName, sNetbiosNameOfRemoteComputer, sTemp, sNewNickName:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� RENAME
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sNewNickName := pNewNickName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //��� ����� ����� ����������, �������� �� ���� �� ����:
  //iChat287KITTYRENAMEKITTY

    //                   iChat              [���� ASCII]                     [�����������]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //              RENAME            NewNickName     
             #19#19 + 'RENAME' + #19#19 + sNewNickName + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{===================   �������� ������� CREATE   ==============================}
function SendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
var sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� CREATE
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sPrivateChatLineName := pPrivateChatLineName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;
  //�� ���� ������� ������ ���:
  //��� ��������: ������ ������ ������ ���
  //iChat527KITTYCREATE856000ANDREY

  //� �������: � ������ � ����
  //iChat28ANDREYCONNECT856000AdminsAndrey�����������!*1.3b30

  //��� ��������: ANDREY ��� ���� �����������
  //iChat531KITTYCONNECT856000Katushkakat�shka:hello:ANDREY1.3b30

  //� �������: KITTY ��� ���� �����������
  //iChat30ANDREYCONNECT856000AdminsAndrey�����������!KITTY1.3b30

    //                   iChat              [���� ASCII]                     [�����������]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [��� ���������� ����]                  [����������]                 
             #19#19 + 'CREATE' + #19#19 + sPrivateChatLineName + #19#19 + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{=================   �������� ������� CREATELINE   ============================}
function SendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password:Pchar):Pchar;
var sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName, sPassword:string;
begin
//iChat613192.168.1.4/ANDREY/UserCREATE_LINE����� �����        192.168.1.4/ANDREY/User
//                                                   [��� �����]  [������]  [�����������]
//exe �������� ��� �-��� ����� ����� ������� ��������� CREATE
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sPrivateChatLineName := pPrivateChatLineName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sPassword := Password;
  sProtoName := pProtoName;
  //�� ���� ������� ������ ���:
  //��� ��������: ������ ������ ������ ���
  //iChat527KITTYCREATE856000ANDREY

  //� �������: � ������ � ����
  //iChat28ANDREYCONNECT856000AdminsAndrey�����������!*1.3b30

  //��� ��������: ANDREY ��� ���� �����������
  //iChat531KITTYCONNECT856000Katushkakat�shka:hello:ANDREY1.3b30

  //� �������: KITTY ��� ���� �����������
  //iChat30ANDREYCONNECT856000AdminsAndrey�����������!KITTY1.3b30

    //                   iChat              [���� ASCII]                     [�����������]
    stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
    //               CREATE           [��� ���������� ����]         [������]            [����������]                   
             #19#19 + 'CREATE_LINE' + #19#19 + sPrivateChatLineName + #19#19 + sPassword + #19#19 + sNetbiosNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{===============   �������� ������� SendCommStatus_Req   ======================}
function SendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
var sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� STATUS
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));

//  MailSlotWriteName := '\\*\Mailslot\ICHAT047';
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sProtoName := pProtoName;

  //iChat418SATANASTATUS_REQ
  //                   iChat              [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              STATUS_REQ      
           #19#19 + 'STATUS_REQ' + #19;

  SendMessCount := SendMessCount + 1;
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
//  RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

{===============   �������� ������� SendCommMe   ======================}
function SendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer,
    sProtoName, sChatLine:string;
begin
//ME [0x13][0x13] [���������] [0x13][0x13] [��� �����] [0x13][0x13] [����������] - ������ ACTION � IRC (������� /me ���������). ����� IChatMeMessage.
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sChatLine := ChatLine;
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  sNickNameOfRemoteComputer := pNickNameOfRemoteComputer;
//  SendMessCount := SendMessCount + cardinal(Increment);
  //����� � TEdit �� �������� 99999999 ���� � �� ��������� ������
    sMessageText := pMessageText;
  if length(sMessageText) >= SizeOf(buffer_out) - 100 then
    sMessageText := copy(sMessageText, 0, SizeOf(buffer_out) - 100)
  else
    sMessageText := pMessageText;
  //��� ������ ������ +1, ����� ����� ����� ��������� ��� �� 2 ������ �����������

  //                   iChat              [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              ME              iTCniaM            gfrjeioj      
           #19#19 + 'ME' + #19#19 + sChatLine + #19#19 + sMessageText + #19#19 +
   //      [��� ����������]            
           sNickNameOfRemoteComputer + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  end;
result := '';
end;

//REFRESH_BOARD - ������ �� ���������� ����� ����������. �����

exports
Init index 1 name 'Init',
ShutDown index 2 name 'ShutDown',
SendCommDisconnect index 3 name 'SendCommDisconnect',
SendCommConnect index 4 name 'SendCommConnect',
SendCommText index 5 name 'SendCommText',
SendCommReceived index 6 name 'SendCommReceived',
SendCommStatus index 7 name 'SendCommStatus',
SendCommBoard index 8 name 'SendCommBoard',
SendCommRefresh index 9 name 'SendCommRefresh',
SetVersion index 10 name 'SetVersion',
SendCommBoardX index 11 name 'SendCommBoardX',
SendCommRename index 12 name 'SendCommRename',
GetIncomingMessageCount index 13 name 'GetIncomingMessageCount',
GetNextIncomingMessage index 14 name 'GetNextIncomingMessage',
SendCommCreate index 15 name 'SendCommCreate',
GetIP index 16 name 'GetIP',
SendCommCreateLine index 17 name 'SendCommCreateLine',
SendCommStatus_Req index 18 name 'SendCommStatus_Req',
SendCommMe index 19 name 'SendCommMe';
end.


