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

{/$/DEFINE USELOG4D}

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF}
  ExceptionLog,
  Windows,
  SysUtils,
  //SysInit,
  Classes,
  Messages,
  DCPcrypt2,
  DCPrc4,
  ScktComp,
  Inifiles,
  SyncObjs,
  WinSock,
  ExtCtrls,
  JwaWinType,
  JwaIpHlpApi,
  JwaIpRtrMib,
{$IFDEF USELOG4D}
  log4d,
{$ENDIF USELOG4D}
  ProtocolMessage in 'ProtocolMessage.pas';

type
  TMailSlotThread = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnected(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
                                ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
    PROCEDURE OnTryConnect(Sender: TObject);
  end;

type TCallBackFunction = function(Buffer:Pchar; Destination:cardinal):PChar;

//function Init(ModuleHandle: HMODULE;AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;forward;
//function ShutDown():PChar;forward;
//function GetLocalUserLoginName(OverrideLN: PChar):PChar;forward;
//function GetLocalComputerName():string;forward;
//function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;forward;
//function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
//                         pLineName,pNameOfRemoteComputer,
//                         pMessageStatusX:PChar; Status:Byte):Pchar;forward;
//function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;forward;

function SendNextOutgoingMessageFromBuffer:cardinal;forward;

const
  KernelVersion = 'T11';//T = TCP
  WaitForSomething = 250;//���� ������ ������ ������ ���� ������ �������
                         //�� 250�� (�.�. ��� ������������ �� ����� 4 ��� � ���)
  FullWorkSpeed = 10;//������ ������� ��������, � ���� ������ �������� ���������
                     //�� ������, �� ���-���� ������ ���� ������ �� 10��
  MESSAGEBUFSIZE = 1500;

{$IFDEF USELOG4D}
  // name of logger (configured in tcpkrnl.prop)
  TCPLOGGER_NAME = 'tcpkrnl';
{$ENDIF USELOG4D}

type
  TMessageBuf = array[0..MESSAGEBUFSIZE-1] of Char;

var
  key, InfoForExe, LocalComputerName, LocalLoginName, LocalIpAddres  :string;
  OverrideLoginName                                                  :String;
  ApplicationPath                                                    :String;
  {ChatVersion,} FullVersion                                           :string;
  //crypted_in, crypted_out, buffer_in, temp_in, buffer_out            :array[0..1499] of Char;
  //hClientSocket                                                      :handle;
  ClientSocket                                                       :TClientSocket;
  Show_SystemMessages_Connect                                        :boolean;
  Show_SystemMessages_Connected                                      :boolean;
{$IFDEF USELOG4D}
  DllName                                                            :array[0..MAX_PATH] of char;
{$ENDIF USELOG4D}
  SendMessCount, nMaxMessSize, UsersCount                            :cardinal;
  DCP_rc41                                                           :TDCP_rc4;
  RunCallBackFunction                                                :TCallBackFunction;
  OpenMailSlotList, QueueOfMessages, QueueOfRemoteComputersNames     :TStringList;
  IncommingQueueOfMessages                                           :TStringList;
  MSThread                                                           :TMailSlotThread;
  ConnectingTimer                                                    :TTimer;
  {ThreadBlocked,} DoConnect                                           :boolean;
  CriticalSection                                                    :TCriticalSection;


{============= �������������� ������� �������� ������ ======================}
FUNCTION GetParam(SourceString: String; ParamNumber: Integer; Separator: String): String;
var
  s: string;
  i, Count: integer;
{$IFDEF USELOG4D}
  logger: TlogLogger;
{$ENDIF USELOG4D}
BEGIN

try

  Count := 0;
  s := SourceString;
  i := pos(Separator, s);
  while i > 0 do begin
    if Count = ParamNumber then begin
      Result := copy(s, 1, i - 1);
      exit;
    end;
    delete(s, 1, i);
    inc(Count);
    i := pos(Separator, s);
  end;

  if Count < ParamNumber
    then Result := ''
    else Result := s;

except
 on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
   raise;
 end;
end;

END;

FUNCTION  GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
  I, Posit: integer;
  S: string;
{$IFDEF USELOG4D}
  logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN
try

  //������������ ��, ��� ����� ������������� (Separator)
  S := SourceString;
  for I := 1 to ParamNumber do begin
    Posit := Pos(Separator, S) + Length(Separator) - 1;
    Delete(S, 1, Posit);
  end;

  Posit := Pos(Separator, S);
  Delete(S, Posit , Length(S) - Posit + 1);
  if HideSingleSeparaterError = true then begin
    i := Pos(Separator[1], s);
    while i > 0 do begin
      delete(s, i, 1);
      i := Pos(Separator[1], s);
    end;
  end;
  Result := s;
except
 on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
   raise;
 end;
end

END;

FUNCTION SetVersion(Version:PChar):PChar;
var
    ChatVersion: string;
BEGIN
  //���������� ��������� � ������ ������ ���� ���� ������ ������� ����������
  FullVersion := '';
  ChatVersion := Version;
  FullVersion := ChatVersion + KernelVersion;
  Result := PChar(FullVersion);
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


{===================== �������� ��� ���������� �����  =========================}
function GetLocalComputerName():string;//TODO: ����� ����� ��������� win = 98/NT !!!!!!!!!
var
    TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
begin
  BufferSize := SizeOf(TempBuffer);
  GetComputerName(@TempBuffer, BufferSize);
  LocalComputerName := strpas(StrUpper(TempBuffer));

//LocalComputerName := '192.168.0.5' + '/' + LocalComputerName + '/' + 'Andrey';

  if Length(LocalComputerName) > 0
    then Result := LocalComputerName
    else Result := 'Error GetLocalComputerName';
end;

{===================== �������� IP ���������� �����  =========================}
function GetLocalIP : string;
var
  err: integer;
  len, n: cardinal;
  MyAdrr: in_addr;
  res, IP, FirstOktetMyIP, Lan, Internet, ServerN, FirstOktetServerIP: string;
  ChatConf: TMemIniFile;
  MibIpAddrTable: PMIB_IPADDRTABLE;
  StrLst: TStringList;
begin
  Lan := '';
  Internet := '';
  ServerN := '';
  //RunCallBackFunction(PChar('����������� ������� ����������:'), 0);
  //IP_For_Exe := '127.0.0.1';
  res := '127.0.0.1';

  MibIpAddrTable := AllocMem(SizeOF(MIB_IPADDRTABLE));
  len := SizeOF(MIB_IPADDRTABLE);
  //FillChar(MibIpAddrTable, len, 0);

  err := GetIpAddrTable(MibIpAddrTable, len, false);
  if err = ERROR_INSUFFICIENT_BUFFER then
  begin
    // allocate larger buffer
    FreeMem(MibIpAddrTable);
    MibIpAddrTable := AllocMem(len);
    err := GetIpAddrTable(MibIpAddrTable, len, false);
  end;

  if err <> 0 then
  begin
    //��� ������ �-��� ��������� ������
    //  RunCallBackFunction(PChar('������! ����� 127.0.0.1'), 0);
    //TODO: add logging here
    FreeMem(MibIpAddrTable);
    Result := res; //PChar(res);
    exit;
  end;

  //���-�� ����������� = MibIpAddrTable.dwNumEntries;

  StrLst := TStringList.Create;//��������������� ������ ��� ������ config.ini
  ChatConf := TMemIniFile.Create(ApplicationPath + 'config.ini');
  ChatConf.ReadSection('ConnectionType', StrLst);
  IP := ChatConf.ReadString('ConnectionType', 'IP', '127.0.0.1');//������ IP ������� �� 'config.ini'
  FirstOktetServerIP := copy(IP, 1, pos('.', IP) - 1);

  for n := 0 to MibIpAddrTable.dwNumEntries - 1 do
  begin
// turn off range checking for table[n] entry
{$IFOPT R+}
{$DEFINE REVERSE_R}
{$R-}
{$ENDIF}
    MyAdrr.S_addr := MibIpAddrTable.table[n].dwAddr;
{$IFDEF REVERSE_R}
{$UNDEF REVERSE_R}
{$R+}
{$ENDIF}
    IP := StrPas(inet_ntoa(MyAdrr));
  //  RunCallBackFunction(PChar('[' + inttostr(n) + '] ' + ip), 0);
    FirstOktetMyIP := copy(IP, 1, pos('.', IP) - 1);
  //  if ip = '127' then ����� Loopback ���������;
//    if (FirstOktetMyIP <> '127') then
//    begin
      //� ������������ ����� �������� ������� ��������� (�� LoopBack!)
      if FirstOktetMyIP = FirstOktetServerIP then
         begin
         //����� ��������� ������� ���������, �� ����� ����, ��� � ������ ����.
         ServerN := IP;
         break;
         end;
      if (FirstOktetMyIP = '10') or (FirstOktetMyIP = '172') or (FirstOktetMyIP = '192') then
        Lan := IP //inet_ntoa(MyAdrr)
      else
        Internet := IP; //inet_ntoa(MyAdrr);
//    end;
  end;

  if Length(LAN) > 0
    then res := LAN;

  if Length(Internet) > 0
    then res := Internet;

  if Length(ServerN) > 0
    then res := ServerN;

  //���� ���� � Config.ini ������ LocalIP, �� ������������� �������� ��
  //�������� ����� �������� ����������
  if strlst.IndexOf('LocalIP') >= 0 then
    res := ChatConf.ReadString('ConnectionType', 'LocalIP', '127.0.0.1');
  StrLst.free;

  Result := res; //PChar(res);

  FreeMem(MibIpAddrTable);

  ChatConf.Free;

//RunCallBackFunction(PChar('� ���� ����� ��������� ��������� IP: ' + res), 0);
end;



{=================== TMailSlotThread ==========================}

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
var
  s:string;
begin
//eeGeneral
  case ErrorEvent of
    eeGeneral:
      begin
      s := 'Communication: General error (' + inttostr(ErrorCode) + ') with host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeSend:
      begin
      s := 'Communication: Send error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeReceive:
      begin
      s := 'Communication: Receive error (' + inttostr(ErrorCode) + ') from host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeConnect:
      begin
      s := 'Communication: Connect error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeDisconnect:
      begin
      s := 'Communication: Disconnect error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
      end;
    eeAccept:
      begin
      s := 'Communication: Accept error (' + inttostr(ErrorCode) + ') to host ' + (ClientSocket.Address) + ':' + IntToStr(ClientSocket.Port);
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

{============================ ClientSocketConnected =============================}
procedure TMailSlotThread.ClientSocketConnected(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ClientSocket.Socket.Connected = true then begin
    RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                            ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 0);
    if Show_SystemMessages_Connected = true
      then RunCallBackFunction(PChar('[' + TimeToStr(Now) + '] Connected with ' + inet_ntoa(ClientSocket.Socket.RemoteAddr.sin_addr) +
                              ':' + Inttostr(ntohs(ClientSocket.Socket.RemoteAddr.sin_port))), 1);
  end;

  if ConnectingTimer <> nil
    then ConnectingTimer.Enabled := false;

  DoConnect := false;
end;

{============================ ClientSocketDisconnect =============================}
procedure TMailSlotThread.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ConnectingTimer <> nil then begin
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

var
  MessageManager: TProtocolMessageManager;

{=============================== ClientSocketRead =============================}
//function GetNextIncomingMessageFromTCP():PChar;
procedure TMailSlotThread.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var SocketReadMessLen{, IChatMessLen, NextIchatPacketSize, MaxMessSize} :cardinal;
    {LenOfFieldMessLen, LenOfFieldCommand, HeaderLen, ProcessedData :cardinal;}
//    PTemp:PChar;
//    PMem{, PSource}: Pointer;
//    STemp, SHeader:String;
{$IFDEF USELOG4D}
    logger: TlogLogger;
{$ENDIF USELOG4D}
    buffer_in: array[0..1499] of Char;
begin
  //Socket DLL'�� �������� ��� �-���, ����� � ���� ���-�� ������ �� ����
  //��������� ������, ������������, ���� ������ ��������� "���������" ���������
  //IChat ��������� �� � �������� � ������������� ����� IncommingQueueOfMessages
  //������ ��������� ����� �������� exe, ����� ��� ����� ������.
  //���������� ���� ����������, ����� EXE �� ���� ���������� �
  //IncommingQueueOfMessages
  //���� �� ��������� ��� �������.
  {ThreadBlocked := true;}
  ZeroMemory(@buffer_in, SizeOf(buffer_in));
  //ZeroMemory(@crypted_in, SizeOf(crypted_in));

  //� ������ buffer_in "�����" ������, �������� �� ����.
  SocketReadMessLen := Socket.ReceiveBuf(buffer_in, SizeOf(buffer_in));
  //���������� ��� �������������� ���� (���� ���� ��������� �������� ���������)
  //ProcessedData := 0;

  try
    MessageManager.Parse(buffer_in, SocketReadMessLen);
  except
    on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TlogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error('Error parsing network message buffer.', E);
{$ENDIF USELOG4D}
    end;
  end;

  MessageManager.Export(IncommingQueueOfMessages);

  //RunCallBackFunction(PChar('<-- FullReceivedDataSize = [' + inttostr(SocketReadMessLen) + ']'), 0);
{
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

  logger.Info(STemp);

  NextIchatPacketSize := 0;
  try
    NextIchatPacketSize := StrToInt(STemp);
  except
    on E:Exception do begin
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

  if ((NextIchatPacketSize + HeaderLen) <= SocketReadMessLen) and (NextIchatPacketSize > 0) then
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
      ProcessedData := ProcessedData + LenOfFieldMessLen + NextIchatPacketSize + 1;
    end
    else
    begin
      //NextIchatMessSize ���� ������������ ��� ������, �� �������� ���������
      //�����! �������� ������������� ��� ������� �������.
      //���������� ���������!
      ProcessedData := SocketReadMessLen;
      logger.Warn('NextIchatMessSize ���� ������������ ��� ������, �� �������� ���������' +
                  '�����! �������� ������������� ��� ������� �������.' +
                  '���������� ���������!');
    end;
  end
  else
  begin
    //���� �������� ��� ������� � ������������� ������� ������!
    //������ ����� ������ �����-�� ����! ���������� �� ���������!
    ProcessedData := SocketReadMessLen;
    logger.Warn('���� �������� ��� ������� � ������������� ������� ������!' +
                '������ ����� ������ �����-�� ����! ���������� �� ���������!');
  end;
until ProcessedData >= SocketReadMessLen; // break the loop only after all messages are processed in buffer.

}

{ThreadBlocked := false;}
end;

PROCEDURE TMailSlotThread.Execute;
{$IFDEF USELOG4D}
var
  //count:cardinal;
  logger: TlogLogger;
{$ENDIF USELOG4D}
BEGIN
  //�������� ���� ���� DLL. ��� ��������� ��� �������� ���������� �� EXE
  //� DLL. ��� ���������� �� � ����� � ���������� ���������� ���������� � EXE
  //����� � DLL �������� ��������� ����� � ���� � ������ ���-�� ����, �� ��������
  //��� ��������� ���������.
  while not Terminated do
  begin
    //���������� �������� ���� ������ DLL
    {  count := GetIncomingMessageCountFromMailSlot();
    }
    try
      if (SendNextOutgoingMessageFromBuffer = 0) {and (count = 0)} then
        sleep(WaitForSomething)
      else
        sleep(FullWorkSpeed);
  {  if count > 0 then GetNextIncomingMessageFromMailSlot();
  }
    except
      on E: Exception do begin
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME {'dreamchat'});
        logger.Error('[TMailSlotThread.Execute]', E);
{$ENDIF USELOG4D}
      end;
    end;

  end;
END;

function SendNextOutgoingMessageFromBuffer:cardinal;
var
    writeCount, MessageLen :cardinal;
    Command, SDebug, HeaderOfProtocol, NetBiosNameOfRemoteComputer, stemp{, scrypto} :string;
    crypted_out, buffer_out, Full_buffer :array[0..1499] of Char;
//    PFullPacket: PChar;
{$IFDEF USELOG4D}
    logger: TLogLogger;
{$ENDIF USELOG4D}
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

Result := 0;

try
  CriticalSection.Enter;

  try
    if (QueueOfMessages.Count > 0) and (ClientSocket <> nil) and
       (ClientSocket.Socket.Connected = true) then
      begin
      NetBiosNameOfRemoteComputer := QueueOfRemoteComputersNames.Strings[0];
      QueueOfRemoteComputersNames.Delete(0);

      stemp := QueueOfMessages.Strings[0];
      QueueOfMessages.Delete(0);

      //������������� ������
      DCP_rc41.Init(key[1], length(key) * 8, nil);
      //����� �� ���� ���� ������ (key[0] � ��� ����� ������ key)

      //������� ������, �������� ������ HEX �����
      //StrCopy(@buffer_out, PChar(stemp));
      CopyMemory(@buffer_out, @stemp[1], length(stemp));

      //RunCallBackFunction(PChar(@buffer_out), 0);

      writeCount := Length(stemp);
      DCP_rc41.Encrypt(buffer_out, crypted_out, writeCount);

      //RunCallBackFunction(PChar('����� crypto � ���������� writeCount = ' + inttostr(writeCount)), 0);

      //  if (hClientSocket <> INVALID_HANDLE_VALUE) then
      //if  then begin
        //[����� ���������] [0x00] [�����������] [0x00] [CMD] [0x00] [���������� | "*"] [0x00] [���������]
        //[][0x00][192.168.0.5/ANDREY/Andrey][0x00][FORWARD][0x00][*][0x00][.......]

        HeaderOfProtocol := LocalComputerName + #00 + 'FORWARD' + #00 + NetBiosNameOfRemoteComputer + #00;
        SDebug := '[' + LocalComputerName + '][$00][' + 'FORWARD' + '][$00][' + NetBiosNameOfRemoteComputer + '][$00]';
        MessageLen := cardinal(Length(HeaderOfProtocol)) + writeCount;
        HeaderOfProtocol := InttoStr(MessageLen) + #00 + HeaderOfProtocol;
        //SDebug := GetParam(stemp, 4, #19#19) + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug;
        Command := GetParamX(stemp, 3, #19#19, true);
        if (Command = 'STATUS_REQ') or (Command = 'REFRESH_BOARD') then
          begin
          SDebug := 'iTCniaM' + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug
          end
        else
          begin
          SDebug := GetParamX(stemp, 4, #19#19, true) + ' ==> [' + InttoStr(MessageLen) + '][$00]' + SDebug;
          end;
   //    scrypto := string(PChar(@crypted_out));
        //�������� � ���, ��� ��� �-��� ���������� � null-terminated ��������
        //������ ��-�� ����� ������������ ������ � � �������� ��������� ���������������
        //���������! ����������� ����� string. ��� ���������� ������� ������ ������,
        //��������� ��� ����� buffer_out, ������� ����� ���������� �����������.
        //������������ MOVE

//RunCallBackFunction(PChar('����� ��������� = [' + inttostr(length(HeaderOfProtocol)) +
//                          ']; ����� crypto = [' + inttostr(writeCount) + ']'), 0);

        MessageLen := length(HeaderOfProtocol) + WriteCount;
        SDebug := SDebug + copy(buffer_out, 0, length(stemp));

        CopyMemory(@Full_buffer, @HeaderOfProtocol[1], length(HeaderOfProtocol));
        CopyMemory(@Full_buffer[length(HeaderOfProtocol)], @crypted_out, writeCount);

       // RunCallBackFunction(PChar(SDebug), 0);

        WriteCount := ClientSocket.Socket.SendBuf(Full_buffer, MessageLen);
        SendMessCount := SendMessCount + 1;
//RunCallBackFunction(Pchar('--> SendNextOutgoingMessageFromBuffer: � Socket ���� �������� = [' + inttostr(WriteCount) + ']'), WriteCount);
      //end

      //������ ����� ������ ������������� �������!!!!
      //��� ����������� ����� ������ ��������� ������ � CallBack
      Result := QueueOfMessages.Count;
      end
    else
      begin
       //���� ����� ������� �� �������, � ����� ��� �������� ��� ����������
      if (QueueOfMessages.Count > 32700) then QueueOfMessages.Delete(0);
      end;
  except
    on E: Exception do begin
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      raise;
    end;
  end;
finally
  CriticalSection.Leave;
end;
end;

///////////////////////////////////////////////////
///  Exported functions
///////////////////////////////////////////////////

{==================== GetLocalUserLoginName �������� ����� ���������� �����  ========================}
function InternalGetLocalUserLoginName(OverrideLN: PChar):PChar;
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
    lpUserName:PChar;
begin
  //��� ���? ��� ������� ���� �� DreamChat.dpr ���� ����� ���������� ��������� �����
  if (Length(OverrideLN) > 0) and (Length(OverrideLoginName) = 0) then begin
    //���������� ��������� ����� � ��� ��������� ������ ���� �-��� ������ ���.
    OverrideLoginName := OverrideLN;
    Result := PChar(OverrideLoginName);
    exit;
  end;

  if Length(OverrideLoginName) > 0 then begin
    //������ ��������� ����� � ��� ������ ���� �-���.
    Result := PChar(OverrideLoginName);
    exit;
  end;

  //��������� ����� �� ����������, ������� ����������� ��������
  BufferSize := SizeOf(TempBuffer);
  lpUserName := @TempBuffer;

  if WNetGetUser(nil, lpUserName, BufferSize) = NO_ERROR then begin
    Result := lpUserName;
  end
  else
  begin
    Result := 'ErrorGetLocalUserLoginName'; //TODO: ��������� � ��������!!!
  end;
end;

function GetLocalUserLoginName(OverrideLN: PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalGetLocalUserLoginName(OverrideLN);
  except
    on E: Exception do begin
      Result := '';
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{======================== GetIP =============================}
function InternalGetIP : PChar;
var
  TempBuffer:array[0..255] of Char;
  s: string;
begin
  s := GetLocalIP();
  ZeroMemory(@TempBuffer, sizeof(TempBuffer));
  MoveMemory(@TempBuffer, PChar(s), Length(s));
  Result := @TempBuffer;
end;

function GetIP():PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalGetIP();
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{======================== GetIncomingMessageCount =============================}
function InternalGetIncomingMessageCount():cardinal;
begin
  //exe �������� ��� �-���, ����� ������ ������� ������ ���������.
  //���������� ���������� ��������� ���������, ��������� ���������.

  //��������!!! � ����������� ���� ������������ � �-����� ������� ��������
  //�������!!! ������ ��������� ��� ���������� �������� � ���� �-����!
  //�.�. IncommingQueueOfMessages ��� �������� � ������� ��� �����
  //�������� �-���, ��� ���������� ��������� � ����� �������.

  if {(ThreadBlocked = false) and} (IncommingQueueOfMessages <> nil)
    then Result := IncommingQueueOfMessages.Count
    else Result := 0;
end;

function GetIncomingMessageCount():cardinal;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalGetIncomingMessageCount();
    except
      on E: Exception do begin
        Result := 0;
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=========================== GetNextIncomingMessage ===========================}
function InternalGetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
var MessSize:cardinal;
begin

//exe �������� � ��� �-��� ��������� �� �����, � ������� ��� ������ ���������
//��������� ��������� ���������
//���������� ���-�� ��������� ���������.

  if IncommingQueueOfMessages <> nil then begin
    if {(ThreadBlocked = false) and} (IncommingQueueOfMessages.Count > 0) then begin

      //RunCallBackFunction(PChar('IncommingQueueOfMessages: ' + inttostr(IncommingQueueOfMessages.Count)), 0);
      //RunCallBackFunction(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.Count - 1]), 0);

      MessSize := StrToInt(IncommingQueueOfMessages.Strings[0]);
      if BufferSize > MessSize then begin
        CopyMemory(PBufferForMessage,  Pointer(IncommingQueueOfMessages.Objects[0]), MessSize)
      end
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

  Result := 0;//length(PChar(IncommingQueueOfMessages.Objects[IncommingQueueOfMessages.count - 1]));
end;

function GetNextIncomingMessage(PBufferForMessage:Pointer; BufferSize:cardinal):cardinal;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalGetNextIncomingMessage(PBufferForMessage, BufferSize);
    except
      on E: Exception do begin
        Result := 0;
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=============== �������, ��������� ����� � ��������� �������� ================}
function InternalInit(ModuleHandle: HMODULE; AdressCallBackFunction:Pointer; ExePath:Pchar):PChar;
var
 //   L:integer;
    ChatConfig: TMemIniFile;
begin
  //����� EXE ����������, �� ������ ��� ������� �����-������ �-��� DLL,
  //����������� �������� �-��� ������������� DLL

  ApplicationPath := ExePath;
  ChatConfig := TMemIniFile.Create(ExePath + 'config.ini');

  Show_SystemMessages_Connect := ChatConfig.ReadBool('SystemMessages', 'TryingMessage', true);
  Show_SystemMessages_Connected := ChatConfig.ReadBool('SystemMessages', 'ConnectedMessage', true);

  {ThreadBlocked := false;}
  // roma hClientSocket := INVALID_HANDLE_VALUE;
  InfoForExe := '';
  FullVersion := KernelVersion;
  SendMessCount := 1;
  //key := 'tahci';//��������! �� ��������� ���!!!!
  key := ChatConfig.ReadString('Crypto', 'Key', 'tahci');

  UsersCount := 0;

  {<�������� ��� �����>}
  LocalComputerName := GetLocalComputerName();

  {<�������� ��� �����>}

  LocalLoginName := GetLocalUserLoginName('');

  {<�������� IP �����>}
  LocalIpAddres := GetLocalIP();
  //LocalComputerName
  //MessageBox(0, PChar(LocalIpAddres), PChar(inttostr(0)) ,mb_ok);
  //RunCallBackFunction(PChar(LocalIpAddres), 0);

  LocalComputerName := LocalIpAddres + '/' + LocalComputerName + '/' + LocalLoginName;

  if DCP_rc41 = nil then begin
    DCP_rc41 := TDCP_rc4.Create(nil);
    DCP_rc41.Init(key[1], length(key) * 8, nil);
    OpenMailSlotList := TStringlist.Create;
    OpenMailSlotList.Sorted := true;
    nMaxMessSize := SizeOf(TMessageBuf);
    QueueOfMessages := TStringList.Create;
    IncommingQueueOfMessages := TStringList.Create;
    MessageManager := TProtocolMessageManager.Create(key);
    QueueOfRemoteComputersNames := TStringList.Create;
    CriticalSection := TCriticalSection.Create;

    if MSThread = nil then begin
      MSThread := TMailSlotThread.Create(false);
      MSThread.Priority := tpIdle;
    end;

    if ClientSocket = nil then begin
      ClientSocket := TClientSocket.Create(nil);
      ClientSocket.OnError := MSThread.ClientSocketError;
      ClientSocket.OnRead := MSThread.ClientSocketRead;
      ClientSocket.OnConnect := MSThread.ClientSocketConnected;
      ClientSocket.OnConnecting := MSThread.ClientSocketConnecting;
      ClientSocket.OnDisconnect := MSThread.ClientSocketDisconnect;
      ClientSocket.OnError := MSThread.ClientSocketError;
      ClientSocket.OnLookup := MSThread.ClientSocketLookup;

//    ClientSocket.OnWrite ������ ������

      //�������� ���� � ��� ���� DLL

      //roma commented out next 3 lines
      //L := MAX_PATH + 1;
      //SetLength(Stemp, L);
      //GetModuleFileName(ModuleHandle, pointer(Stemp), L);


      //��������� config.ini � ����� ����� �������
//    ClientSocket.Port:=7777;
//    ClientSocket.Address:='62.149.2.14';

      ClientSocket.Address := ChatConfig.ReadString('ConnectionType', 'IP', '127.0.0.1');
      ClientSocket.Port := StrToInt(ChatConfig.ReadString('ConnectionType', 'Port', '6666'));
      ClientSocket.ClientType := ctNonBlocking;
//    ClientSocket.Active := true;
      //roma hClientSocket := ClientSocket.Socket.Handle;
      MSThread.Resume;

      DoConnect := true;
      ConnectingTimer := TTimer.Create(nil);
      ConnectingTimer.OnTimer := MSThread.OnTryConnect;
      ConnectingTimer.Interval := 1;
    end;

//roma    if hClientSocket = INVALID_HANDLE_VALUE
    if ClientSocket.Socket.Handle = INVALID_HANDLE_VALUE
      then InfoForExe := '������ �������� hClientSocket1: error ' + inttostr(GetLastError());
  end
  else
  begin
    InfoForExe := InfoForExe + '�� ���� ������� DCP_rc41, �.�. �� ��� ������!';
  end;

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

  nMaxMessSize := SizeOf(TMessageBuf);
 //���������� ������ ������ ��� ��������� �� ������!

  ChatConfig.Free;
  Result := PChar(InfoForExe);
end;

function Init(ModuleHandle: HMODULE; AdressCallBackFunction:Pointer; ExePath:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalInit(ModuleHandle, AdressCallBackFunction, ExePath);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========== �������������, ����������� ����� � ��������� ��������� ============}
function InternalShutDown():PChar;
var
  n:cardinal;

begin
  //������ ��� "�������" EXE �������� �-��� "��������" DLL
  //���������� ��� ��� � ������� �� ��������!!!!
  //����� DISCONNECT �� ������ ����!!!
  // TODO: MSThread ���� � ���� ������ ����������! ����� ��� ���������� �������.
  while SendNextOutgoingMessageFromBuffer <> 0 do begin
    sleep(1);
  end;

  Result := 'DCP_rc41 ��� ����� ����! � hMailSlotWrite ������!';
  if DCP_rc41 <> nil then begin

    if CriticalSection <> nil
      then CriticalSection.Free;

    if ClientSocket <> nil then begin
      ClientSocket.Active := false;
      ClientSocket.Close;
      ClientSocket.Free;
    end;

    if MSThread <> nil then begin
      MSThread.Terminate;
      sleep(100);
      MSThread.Free;
      MSThread := nil;
    end;

    if ConnectingTimer <> nil then begin
      ConnectingTimer.Free;
    end;

    DCP_rc41.Free;
    DCP_rc41 := nil;

    if OpenMailSlotList <> nil then begin
      if OpenMailSlotList.Count > 0 then begin
        for n := 0 to (OpenMailSlotList.Count - 1) do begin
          if THandle(OpenMailSlotList.Objects[n]) > 0
            then CloseHandle(THandle(OpenMailSlotList.Objects[n]));
        end;
      end;
      OpenMailSlotList.Free;
    end;

    if (IncommingQueueOfMessages.Count > 0) then begin
      for n := (IncommingQueueOfMessages.Count - 1) downto 0 do begin
        //������� ������ ��������� ���������!!!!!
//      PTemp := PChar(IncommingQueueOfMessages.Objects[n]);
//      if PTemp <> nil then StrDispose(PTemp);
        if Pointer(IncommingQueueOfMessages.Objects[n]) <> nil
          then FreeMem(Pointer(IncommingQueueOfMessages.Objects[n]));
        IncommingQueueOfMessages.Delete(n);
      end;
    end;

//MessageBox(0, PChar('IncommingQueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
    IncommingQueueOfMessages.Free;

    if (QueueOfMessages.Count > 0) then begin
      for n := (QueueOfMessages.Count - 1) downto 0 do begin
        QueueOfMessages.Delete(n);
      end;
    end;

    QueueOfMessages.Free;
//MessageBox(0, PChar('QueueOfMessages free'), PChar(inttostr(0)) ,mb_ok);
    if (QueueOfRemoteComputersNames.Count > 0) then begin
      for n := (QueueOfRemoteComputersNames.Count - 1) downto 0 do begin
        QueueOfRemoteComputersNames.Delete(n);
      end;
    end;

    QueueOfRemoteComputersNames.Free;
//MessageBox(0, PChar('QueueOfRemoteComputersNames free'), PChar(inttostr(0)) ,mb_ok);
    Result := 'DCP_rc41.Free! All objects Free !';
  end;

  MessageManager.Free;

end;

function ShutDown():PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalShutDown();
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
//      logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
//      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== �������� ������� DISCONNECT ==============================}
function InternalSendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
var {writeCount:cardinal;}
    stemp, sLineName, sNetbiosNameOfRemoteComputer, sNameOfLocalComputer,
    sProtoName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� DISCONNECT
if DCP_rc41 <> nil then begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sLineName := pLineName;
  sNameOfLocalComputer := pNameOfLocalComputer;
  sProtoName := pProtoName;

  //192.168.0.5/ANDREY/Andrey
  sNameOfLocalComputer := LocalComputerName;

  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;

  if Length(sNameOfLocalComputer) = 0
    then sNameOfLocalComputer := LocalComputerName;

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

function SendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName:PChar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommDisconnect(pProtoName, pNameOfLocalComputer, pNetbiosNameOfRemoteComputer, pLineName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{====================== �������� ������� CONNECT ==============================}
function InternalSendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
var stemp, sNameOfRemoteComputer, sProtoName:string;
    sNetbiosNameOfRemoteComputer, sMessageStatusX, sLineName, LocalNickName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//exe �������� ��� �-��� ����� ����� ������� ��������� CONNECT
if DCP_rc41 <> nil then begin
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

function SendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                         pLineName,pNameOfRemoteComputer,
                         pMessageStatusX:PChar; Status:Byte):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommConnect(pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                           pLineName,pNameOfRemoteComputer,
                           pMessageStatusX, Status);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{========================= �������� ������� TEXT ==============================}
function InternalSendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer,
    sProtoName, sChatLine:string;
    buffer_out, crypted_out: TMessageBuf;
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

function SendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommText(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer, pMessageText, ChatLine, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{====================== �������� ������� STATUS ==============================}
function InternalSendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
var
  sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommStatus(pProtoName, pNetbiosNameOfRemoteComputer, LocalUserStatus, StatusMessage);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================== �������� ������� RECEIVED ==============================}
function InternalSendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer:PChar;MessAboutReceived:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommReceived(pProtoName, pNetbiosNameOfRemoteComputer, MessAboutReceived);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================== �������� ������� BOARD ==============================}

function InternalSendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer:PChar;pMessageBoard:Pchar;PartMessNumber:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommBoardX(pProtoName, pNetbiosNameOfRemoteComputer, pMessageBoard, PartMessNumber);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

function InternalSendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
var n, i, partcount, LenMess, StartPart{, EndPart}:cardinal;
    strbuffer: array of char;
begin
  //exe �������� ��� �-��� ����� ����� ������� ��������� BOARD
  //������ ��� ����, ����� ���������� ������� ��������� ����� ����������
  //�� ��������� ������ ������.
  //� ����� �� ��������� � ��� �����?! �����, ����� ���������...
  LenMess := strlen(pMessageBoard);
  //partcount := round(LenMess/MaxSizeOfPart) - 1;
  partcount := round(LenMess/MaxSizeOfPart) + 1; //AVR: -1 is removed
  setlength(strbuffer, MaxSizeOfPart + 1);

  if LenMess > MaxSizeOfPart then begin
    for n := 0 to partcount do begin
      StartPart := n * MaxSizeOfPart;
//    EndPart := n * MaxSizeOfPart + MaxSizeOfPart;
//    if EndPart > LenMess then EndPart := LenMess;
      for i := 0 to MaxSizeOfPart - 1 do begin
        strbuffer[i] := pMessageBoard[StartPart];
        inc(StartPart);
      end;
      InternalSendCommBoardX(pProtoName, pNameOfRemoteComputer, PChar(strbuffer), n);
    end;
  end
  else
  begin
    InternalSendCommBoardX(pProtoName, pNameOfRemoteComputer, pMessageBoard, 0);
  end;

  Result := '';
end;

function SendCommBoard(pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommBoard(pProtoName, pNameOfRemoteComputer, pMessageBoard, MaxSizeOfPart);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;



{=================== �������� ������� REFRESH ==============================}
function InternalSendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
var sReceiver, sNetbiosNameOfRemoteComputer, sTemp, sAwayMess,
    sProtoName, sLocalNickName, sLineName:string;
    buffer_out, crypted_out: TMessageBuf;
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

function SendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;
                         LocalUserStatus:cardinal;pAwayMess:Pchar;
                         pReceiver:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRefresh(pProtoName, pNetbiosNameOfRemoteComputer, pLineName, pLocalNickName, LocalUserStatus, pAwayMess, pReceiver, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{===================   �������� ������� RENAME   ==============================}
function InternalSendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
var
  sProtoName, sNetbiosNameOfRemoteComputer, sTemp, sNewNickName:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommRename(pProtoName, pNetbiosNameOfRemoteComputer:Pchar;pNewNickName:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRename(pProtoName, pNetbiosNameOfRemoteComputer, pNewNickName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;

end;

{===================   �������� ������� CREATE   ==============================}
function InternalSendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
var
  sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommCreate(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{=================   �������� ������� CREATELINE   ============================}
function InternalSendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password:Pchar):Pchar;
var
  sProtoName, sTemp, sNetbiosNameOfRemoteComputer, sPrivateChatLineName, sPassword:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password:Pchar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommCreateLine(pProtoName, pNetbiosNameOfRemoteComputer, pPrivateChatLineName, Password);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{===============   �������� ������� SendCommStatus_Req   ======================}
function InternalSendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
var
  sNetbiosNameOfRemoteComputer, sProtoName, stemp:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommStatus_Req(pProtoName, pNetbiosNameOfRemoteComputer);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{===============   �������� ������� SendCommMe   ======================}
function InternalSendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
var
  sMessageText, stemp, sNickNameOfRemoteComputer, sNetbiosNameOfRemoteComputer, sProtoName, sChatLine:string;
  buffer_out, crypted_out: TMessageBuf;
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

function SendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer:PChar;pMessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommMe(pProtoName, pNetbiosNameOfRemoteComputer, pNickNameOfRemoteComputer, pMessageText, ChatLine, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


{==============   �������� ������� SendCommBoard_Refresh   ====================}
function InternalSendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
var {sMessageText,} stemp, sNetbiosNameOfRemoteComputer,
    sProtoName:string;
    buffer_out, crypted_out: TMessageBuf;
begin
//������ �����
//iChat[0x13][0x13]%d[0x13][0x13]192.168.1.4/ANDREY/User[0x13][0x13]REFRESH_BOARD
if DCP_rc41 <> nil then
  begin
  ZeroMemory(@buffer_out, SizeOf(crypted_out));
  ZeroMemory(@crypted_out, SizeOf(crypted_out));
  sProtoName := pProtoName;
  sNetbiosNameOfRemoteComputer := pNetbiosNameOfRemoteComputer;
  //��� ������ ������ +1, ����� ����� ����� ��������� ��� �� 2 ������ �����������

  //                   iChat              [���� ASCII]                     [�����������]
  stemp := Char($13) + sProtoName + #19#19 + inttostr(SendMessCount) + #19#19 + LocalComputerName +
  //              REFRESH_BOARD      
           #19#19 + 'REFRESH_BOARD' + #19;

  SendMessCount := SendMessCount + cardinal(Increment);
  QueueOfMessages.Add(stemp);
  QueueOfRemoteComputersNames.Add(sNetbiosNameOfRemoteComputer);
  //RunCallBackFunction(PChar('==> QueueOfMessages:  ' + stemp), 0);
  end;
result := '';
end;

function SendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    CriticalSection.Enter;
    try
      Result := InternalSendCommRefresh_Board(pProtoName, pNetbiosNameOfRemoteComputer, Increment);
    except
      on E: Exception do begin
        Result := '';
{$IFDEF USELOG4D}
        logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
        logger.Error(E.Message, E);
{$ENDIF USELOG4D}
      end;
    end;
  finally
    CriticalSection.Leave;
  end;
end;


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
  SendCommMe index 19 name 'SendCommMe',
  SendCommRefresh_Board index 20 name 'SendCommRefresh_Board',
  GetLocalUserLoginName index 21 name 'GetLocalUserLoginName';

var
{$IFDEF USELOG4D}
  logger: TlogLogger;
{$ENDIF USELOG4D}
  SavedDllProc: TDLLProc = nil;

procedure LibExit(Reason: Integer);
begin
{$IFDEF USELOG4D}
  if Reason = DLL_PROCESS_DETACH then begin
    logger.Info('--------------------------------------------------------');
    logger.Info('-----------------------   FINISH   ---------------------');
    logger.Info('--------------------------------------------------------');
  end;
{$ENDIF USELOG4D}

  if Assigned(SavedDllProc)
    then SavedDllProc(Reason);  // call saved entry point procedure
end;

begin
  IsMultiThread := True;

{$IFDEF USELOG4D}
  FillChar(DllName, sizeof(DllName), #0);
  GetModuleFileName(SysInit.hInstance, DllName, sizeof(DllName));
  //ApplicationPath:=DllName;
  ApplicationPath := ExtractFilePath(DllName);

  // initialize log4d
  TLogPropertyConfigurator.Configure(ApplicationPath + 'tcpkrnl.props');

  logger := TLogLogger.GetLogger(TCPLOGGER_NAME);
  logger.Info('--------------------------------------------------------');
  logger.Info('------------------------   START   ---------------------');
  logger.Info('--------------------------------------------------------');

  SavedDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure
{$ENDIF USELOG4D}
end.


