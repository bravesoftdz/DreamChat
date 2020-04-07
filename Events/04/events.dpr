//����� ���� DLL ���������������� � ��� ���� ��� ���� (AS IS)
//������� ��������������� �� ����������� ��� ������ ����� �� �����.
//� ���� �� ����������� � ����� DELPHI 5

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

library events;

uses
{$IFDEF USEFASTSHAREMEM}
  FastShareMem,
{$ENDIF}
  Windows,
  mmsystem,
  SysUtils,
  //SysInit,
  Classes,
  Inifiles,
{$IFDEF USELOG4D}
  log4d,
{$ENDIF USELOG4D}
  Messages;

const
  LINE_TYPE_COMMON = 0;
  LINE_TYPE_PRIVATE_CHAT = 1;
  LINE_TYPE_COMMON_LINE = 2;
  DllVersion = 'E03';//E = Events

{$IFDEF USELOG4D}
    // name of logger (configured in tcpkrnl.prop)
  EVLOGGER_NAME = 'events';
{$ENDIF USELOG4D}

type TCallBackFunction = function(Buffer:Pchar; MessCountInBuffer:cardinal):PChar;

var
  sExePath                      :string;
  RunCallBackFunction           :TCallBackFunction;
  debug                         :boolean;

{=============== �������, ��������� ����� � ��������� �������� ================}

// returns error message string in case of error.
// if no error then empty string should be returned.
function InternalEvInit(AdressCallBackFunction:Pointer; pExePath:PChar):PChar;
var
    ChatConfig: TMemIniFile;
begin
  // ensure that path ends on path delimiter
  sExePath := ExcludeTrailingPathDelimiter(pExePath);

  debug := true;//false;

  ChatConfig := TMemIniFile.Create(sExePath + 'sound.ini');

  if ChatConfig.ReadBool('SystemMessages', 'SoundDebug', false) = true
    then debug := true;

  ChatConfig.Free;

  RunCallBackFunction := AdressCallBackFunction;

//******************************************************************************
//* ���������� ����� ������� ��������� ������, ��� ����� �� ��������.          *
//* ������ ��� ����� ���� ��� ������ �����, � ������ ������ ��� ������ ���� �  *
//* ���� �������. �� ���������� � EXE �������� ��������� �������:              *
//
//* FUNCTION CallBackFunction(Buffer:Pchar; MessCountInBuffer:cardinal):PChar; *
//* BEGIN                                                                      *
//*   {DLL ����� ������� ��� ������� ����� �� ���������}                       *
//* Form2.Memo2.Lines.Add(Buffer);                                             *
//* sglob := 'CallBackFunction: ���� ������ ��� ������� DLL!';                 *
//* result := @sglob[1];                                                       *
//* END;                                                                       *
//******************************************************************************
//���� �� �������, �� ���������:
//� DLL � �������� ��������� �������, ������� �������� ���, ����� ��� ����� EXE.
//������ DLL ���� ����� ������������ ����� � EXE � ���������� �� �
//������������ ������ �������, �� ��������� ����� EXE ������� ���� �� ��
//�������. ��� ����� � �������� �������� ��������� ������. ��������������
//EXE �������� DLL ����� ����� �������/������, ������� ����� ������� �
//������������ ������ �������, DLL ��� ���������� � �������� ��������.
//������ � ������ ����������, ���� ����� �������� �����, ����� �����
//������ ���������� �����! �.�. � CallBackFunction ���������� ������ �
//�����������.

  //���������� ������ ������ ���� ���� ������, ����� ��������� �� ������!
  Result := ''; //roma PChar(InfoForExe);
end;

function EvInit(AdressCallBackFunction:Pointer; pExePath:PChar):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvInit(AdressCallBackFunction, pExePath);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========== �������������, ����������� ����� � ��������� ��������� ============}
function EvShutDown():PChar;
//{$IFDEF USELOG4D}
//var
//  logger: TlogLogger;
//{$ENDIF USELOG4D}
begin
//{$IFDEF USELOG4D}
//  logger := TLogLogger.GetLogger(EVLOGGER_NAME);
//  logger.Info('------------------------   FINISH   ---------------------');
//{$ENDIF USELOG4D}

  Result := 'ShutDown of ' + DllVersion + ' OK!';
end;

{=================== �������� ������� DISCONNECT ==============================}
function InternalEvOnCommDisconnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
// iChat  1  ANDREY  DISCONNECT  iTCniaM 
// iChat  [���� ASCII]  [�����������]  DISCONNECT  iTCniaM 
//s := ChatConfig.ReadString('sound', 'Disconnect', '');
//if (length(s) > 0) and (s[1] = '\') then s := sExePath + s;

  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommDisconnect: ' + s), 0);
end;

function EvOnCommDisconnect(LineType: integer; pReceivedMessage, PlayFile:PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommDisconnect(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{====================== �������� ������� CONNECT ==============================}
function InternalEvOnCommConnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
//iChat2ANDREYCONNECTiTCniaMAdminsAndrey�����������!*1.21b60
//s := ChatConfig.ReadString('sound', 'Connect', '');
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommConnect: ' + s), 0);
end;

function EvOnCommConnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommConnect(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{========================= �������� ������� TEXT ==============================}
function InternalEvOnCommText(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
//iChat983KITTYTEXTgsMTCI ���������� ��������?Andrey
//������ ���������
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommText: ' + s), 0);
end;

function EvOnCommText(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommText(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{====================== �������� ������� STATUS ==============================}
function InternalEvOnCommStatus(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  //iChat  24           KITTY          STATUS  3         Katushka ��������... ��������� :gigi:
  //iChat  642          ALF            STATUS  3         ���� ���.   
  //iChat [���� ASCII]  [�����������]  STATUS  [������]  [Away_����] 
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommStatus: ' + s), 0);
end;

function EvOnCommStatus(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommStatus(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;


{=================== �������� ������� RECEIVED ==============================}
function InternalEvOnCommReceived(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  // iChat  305  KITTY  RECEIVED  gsMTCI . ��� ����.
  // iChat  [���� ASCII]  [�����������]  RECEIVED  gsMTCI  [Away_����]
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommReceived: ' + s), 0);
end;

function EvOnCommReceived(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommReceived(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== �������� ������� BOARD ==============================}
function InternalEvOnCommBoard(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommBoard: ' + s), 0);
end;

function EvOnCommBoard(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommBoard(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{=================== �������� ������� REFRESH ==============================}
function InternalEvOnCommRefresh(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var s:string;
begin
  //iChat137ANDREYREFRESHiTCniaMAdminsAndrey�����������!*1.21b63
  //iChat137ANDREYREFRESHiTCniaMAdminsAndrey�����������!*1.21b63
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommRefresh: ' + s), 0);
end;

function EvOnCommRefresh(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommRefresh(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   �������� ������� RENAME   ==============================}
function InternalEvOnCommRename(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  //iChat287KITTYRENAMEKITTY
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommRename: ' + s), 0);
end;

function EvOnCommRename(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommRename(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   �������� ������� CREATE   ==============================}
function InternalEvOnCommCreate(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  //�� ���� ������� ������ ���:
  //��� ��������: ������ ������ ������ ���
  //iChat527KITTYCREATE856000ANDREY

  //� �������: � ������ � ����
  //iChat28ANDREYCONNECT856000AdminsAndrey�����������!*1.3b30

  //��� ��������: ANDREY ��� ���� �����������
  //iChat531KITTYCONNECT856000Katushkakat�shka:hello:ANDREY1.3b30

  //� �������: KITTY ��� ���� �����������
  //iChat30ANDREYCONNECT856000AdminsAndrey�����������!KITTY1.3b30

  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommCreate: ' + s), 0);
end;

function EvOnCommCreate(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommCreate(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{==========================   ������ ���������   ==============================}
function InternalEvOnCommAlert(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommAlert: ' + s), 0);
end;

function EvOnCommAlert(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommAlert(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   �������� ������ ���������   ============================}
function InternalEvOnCommAlertToAll(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommAlertToAll: ' + s), 0);
end;

function EvOnCommAlertToAll(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommAlertToAll(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

{===================   ������� ����� �����   ============================}
function InternalEvOnCommFindLine(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
var
  s:string;
begin
  s := PlayFile;
  if (length(s) > 0) and (s[1] = '\') then s := sExePath + PlayFile;
  PlaySound(PChar(s), 0, $0001); //SND_ASYNC

  Result := '';

  if debug
    then RunCallBackFunction(PChar('EOnCommFindLine: ' + s), 0);
end;

function EvOnCommFindLine(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;
{$IFDEF USELOG4D}
var
  logger: TlogLogger;
{$ENDIF USELOG4D}
begin
  try
    Result := InternalEvOnCommFindLine(LineType, pReceivedMessage, PlayFile, UserID);
  except
    on E: Exception do begin
      Result := nil;
{$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(EVLOGGER_NAME);
      logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    end;
  end;
end;

exports
  EvInit index 1 name 'EvInit',
  EvShutDown index 2 name 'EvShutDown',
  EvOnCommDisconnect index 3 name 'EvOnCommDisconnect',
  EvOnCommConnect index 4 name 'EvOnCommConnect',
  EvOnCommText index 5 name 'EvOnCommText',
  EvOnCommReceived index 6 name 'EvOnCommReceived',
  EvOnCommStatus index 7 name 'EvOnCommStatus',
  EvOnCommBoard index 8 name 'EvOnCommBoard',
  EvOnCommRefresh index 9 name 'EvOnCommRefresh',
  EvOnCommRename index 10 name 'EvOnCommRename',
  EvOnCommCreate index 11 name 'EvOnCommCreate',
  EvOnCommAlert index 12 name 'EvOnCommAlert',
  EvOnCommAlertToAll index 13 name 'EvOnCommAlertToAll',
  EvOnCommFindLine index 14 name 'EvOnCommFindLine';

var
{$IFDEF USELOG4D}
  logger: TlogLogger;
  DllName                       :array[0..MAX_PATH] of char;
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
{$IFDEF USELOG4D}
  FillChar(DllName, sizeof(DllName), #0);
  GetModuleFileName(SysInit.hInstance, DllName, sizeof(DllName));
  //sExePath:=DllName;
  sExePath := ExtractFilePath(DllName);

  // initialize log4d
  TLogPropertyConfigurator.Configure(sExePath+'events.props');

  logger := TLogLogger.GetLogger(EVLOGGER_NAME);
  logger.Info('--------------------------------------------------------');
  logger.Info('------------------------   START   ---------------------');
  logger.Info('--------------------------------------------------------');

  SavedDllProc := DllProc;  // save exit procedure chain
  DllProc := @LibExit;  // install LibExit exit procedure
{$ENDIF USELOG4D}
end.


