unit uChatLine;

//������� �������� ��������� ������������ �����!
//��������� ��� ��������� ��������� ������! ��� ��������� ������� 'CONNECT'
//���� ������������ ��� ������, ������ form1.ShowAllUserInTree(self);
//� ������ UChatLine ������ �� ����!!!! ����� ���� ������!!!
//���� ����� ���� ������������, �� �������� �������� ��������� ����� ��������
//����� � ����� �������� LineNode!!!!

interface

uses
     Classes, Controls, ComCtrls, Forms, ExtCtrls, SysUtils, Windows,
     Graphics, uFormDebug, CVLiteGifAniX2, Inifiles, litegifX2,
     ChatView, sChatView, cvStyle,  WinSock, JwaIpHlpApi, JwaIpRtrMib,
     uChatUser,
     VirtualTrees, UGifVirtualStringTree,
     sPageControl, sSplitter
     {$IFDEF USELOG4D}, log4d {$ENDIF USELOG4D}
     , DreamChatConsts
     ;

const
  UNKNOWN_LOG_FILE_NAME = 'Unknown_line_name';
  INVALID_USER_ID = CARDINAL($FFFFFFFF);
//  LINE_TYPE_COMMON = 0;
//  LINE_TYPE_PRIVATE_CHAT = 1;
//  LINE_TYPE_COMMON_LINE = 2;

type
TLineType = (LT_COMMON, LT_PRIVATE_CHAT, LT_LINE);

type
  TChatLine = class;

  TOnCmdConnect = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdDisconnect = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdText = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdRefresh = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdReceived = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdReName = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdBoard = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal;DoUpdate:Boolean) of object;
  TOnCmdStatus = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdStatus_Req = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdRefresh_Board = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdCREATE = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;
  TOnCmdCREATELINE = procedure (Sender: TChatLine; var IncommingMessage: String; UserID:cardinal) of object;


  TChatLine = class (TPersistent)
  private
    //Show_SystemMessages_Refresh :boolean;
    FChatLineName 		 :String;//�������� �����
    FChatLineTabSheet  :TsTabSheet;//�������� ��� ���������� [�����] � [������]
    FChatLineView		   :TsChatView;//��������� ��� ������ [�����]
    FChatLineTree		   :TGifVirtualStringTree;//��������� ��� ������ ������ �������������
    FChatSplitter      :TsSplitter;//����������� [�����] � [������]
    FMessagesHistory   :TStringList;//������� ����� ��������� (TEdit1.OnKeyDown)
    FAutoRefreshTime   :integer;//����� �������������� ������ ������
//    FUsersCount        :cardinal;//���������� �������������
    FOnCmdConnect      :TOnCmdConnect;//������� ������� �� ������� 'Connect'
    FOnCmdDisconnect   :TOnCmdDisconnect;//������� ������� �� ������� 'Disconnect'
    FOnCmdText         :TOnCmdText;//������� ������� �� ������� 'Text'
    FOnCmdRefresh      :TOnCmdRefresh;//������� ������� �� ������� 'Rerfresh'
    FOnCmdReceived     :TOnCmdReceived;//������� ������� �� ������� 'Received'
    FOnCmdBoard        :TOnCmdBoard;//������� ������� �� ������� 'Board'
    FOnCmdStatus       :TOnCmdStatus;//������� ������� �� ������� 'Status'
    FOnCmdStatus_Req   :TOnCmdStatus_Req;//������� ������� �� ������� 'Status_Req'
    FOnCmdRefresh_Board:TOnCmdRefresh_Board;//������� ������� �� ������� 'Refresh_Board'
    FOnCmdRename       :TOnCmdRename;//������� ������� �� ������� 'Rerfresh'
    FOnCmdCreate       :TOnCmdCreate;//������� ������� �� ������� 'Rerfresh'
    FOnCmdCreateLine   :TOnCmdCreateLine;//������� ������� �� ������� 'Rerfresh'
    TimerSendMsgRefresh:TTimer;

    {/��� ��������� ������}
    FUNCTION GetSafetyLogFileName(FileNameWithExceptSymbols: string):string;
  protected
    {��� ��������� ������}
    {/��� ��������� ������}
    PROCEDURE ChatLineViewMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    PROCEDURE OnVScrolled(Sender: TObject);
    PROCEDURE ChatSplitterCanResize(Sender: TObject; var NewSize: Integer;
              var Accept: Boolean);
    PROCEDURE SetAutoRefreshTime(RefreshTime: integer);
    function GetUsersCount():cardinal;
    function GetLocalComputerName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
    procedure StringToComponent(Component: TComponent; Value: string);
  public
    UsersConnectHistory                 :TStringlist;//��� ����� ��������� ��������� �� ����� OffLine ��� ������� �����.
    LineID                              :cardinal;//��������� � PageIndex
    LineType             		            :TLineType;//��������� �������� �����
    DisplayChatLineName 	              :String;//���������������� �������� �����
//    SmilesName                          :TStringlist;
    FFullLogFileName                    :string;//��� ����� ���� ��� /^* � ������ ��������� ��������
    LineLog                             :TStringlist;//��� ���� ��������� ���� �����
    ChatLineUsers     		              :array of TChatUser;//����� ������� � ���� ����� ����
    Key                                 :string;
    LocalIpAddres                       :string;
    LocalComputerName                   :string;
    LocalLoginName                      :string;
    ScrollToEnd                         :boolean;
    MessagesHistoryIndex                :integer;
    RefreshTreeNumber                   :Cardinal;
    property AutoRefreshTime            :integer read FAutoRefreshTime write SetAutoRefreshTime;//����� �������������� ������ ������
    property ChatLineName 	    :String read FChatLineName write FChatLineName;
    property ChatLineTabSheet   :TsTabSheet read FChatLineTabSheet write FChatLineTabSheet;
    property ChatLineView		    :TsChatView read FChatLineView write FChatLineView;
    property ChatLineTree		    :TGifVirtualStringTree read FChatLineTree write FChatLineTree;
    property ChatSplitter		    :TsSplitter read FChatSplitter write FChatSplitter;
    property MessagesHistory	  :TStringList read FMessagesHistory write FMessagesHistory;
    property UsersCount		      :cardinal read GetUsersCount;// write FUsersCount;
    property OnCmdConnect	      :TOnCmdConnect read FOnCmdConnect write FOnCmdConnect;
    property OnCmdDisconnect	  :TOnCmdDisconnect read FOnCmdDisconnect write FOnCmdDisconnect;
    property OnCmdText		      :TOnCmdText read FOnCmdText write FOnCmdText;
    property OnCmdRefresh		    :TOnCmdRefresh read FOnCmdRefresh write FOnCmdRefresh;
    property OnCmdReceived		  :TOnCmdReceived read FOnCmdReceived write FOnCmdReceived;
    property OnCmdRename		    :TOnCmdRename read FOnCmdRename write FOnCmdRename;
    property OnCmdCreate		    :TOnCmdCreate read FOnCmdCreate write FOnCmdCreate;
    property OnCmdCreateLine	  :TOnCmdCreateLine read FOnCmdCreateLine write FOnCmdCreateLine;
    property OnCmdBoard		      :TOnCmdBoard read FOnCmdBoard write FOnCmdBoard;
    property OnCmdStatus		    :TOnCmdStatus read FOnCmdStatus write FOnCmdStatus;
    property OnCmdStatus_Req	  :TOnCmdStatus_Req read FOnCmdStatus_Req write FOnCmdStatus_Req;
    property OnCmdRefresh_Board :TOnCmdRefresh_Board read FOnCmdRefresh_Board write FOnCmdRefresh_Board;

//    FUNCTION GetLocalUserLoginName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
    FUNCTION GetUniqueNickName(NewUserId: cardinal):string;
    //roma FUNCTION GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
    function GetUserIdByCompName(CompName:String):cardinal;
    function GetUserIdByDisplayNickName(DisplayNickName:String):cardinal;//�������� IP !!!
    function GetUserInfo(UserNumber:cardinal):TChatUser;
    function GetUserByDisplayNickName(DisplayNickName:String):TChatUser;//�������� IP !!!
    function GetLocalUserId():cardinal;
    function GetLocalUser():TChatUser;
    PROCEDURE Scheduler(Sender: TObject);
    procedure SendDisconnectConnect(sReceivedMessage:string);
    procedure MessageProtocolProcessing(pReceivedMessage: PChar);//���� ������� ���������� �� DLL ������
    procedure Assign(Source: TPersistent);override;{virtual;}
    //function StrToIntE(s: string):integer;
  published
    constructor Create(LineName:String;ChatPageControl:TPageControl;CVStyle:TCVStyle);
    destructor Destroy;override;
  end;

  PChatLine = ^TChatLine;

implementation

uses uFormMain, uLineNode, DreamChatTools, DreamChatConfig, uPathBuilder;

PROCEDURE TChatLine.Scheduler(Sender: TObject);
VAR tLocalUser: TChatUser;
    n:cardinal;
    Mess:string;
{$IFDEF USELOG4D}
    logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN

try
  tLocalUser := Self.GetUserInfo(Self.GetLocalUserID);

  if tLocalUser <> nil then begin
{$IFDEF USELOG4D}
    if Self.UsersCount = 0 then begin
      logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
      logger.Error('[TChatLine.Scheduler] Weird, Self.UsersCount = 0 (!)');
    end;
{$ENDIF USELOG4D}

    //for n := 0 to Self.UsersCount - 1 do begin
    n := 0;
    while n < self.UsersCount do begin
      if (tLocalUser.UserID <> Self.ChatLineUsers[n].UserID) and
         (Self.ChatLineUsers[n].Status = dcsDisconnected) then
      begin
        if TDreamChatConfig.GetRefreshMessage = True //Show_SystemMessages_Refresh = True
          then FormMain.ParseAllChatView(ChatLineUsers[n].DisplayNickName + ' ' + fmInternational.Strings[I_NOTANSWERING],
                             self, FormMain.CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE],
                             nil, nil, false, true)
        else
          TDebugMan.AddLine2(ChatLineUsers[n].DisplayNickName + ' ' + fmInternational.Strings[I_NOTANSWERING]); //FormDebug.DebugMemo2.Lines.Add(ChatLineUsers[n].DisplayNickName + ' ' + fmInternational.Strings[I_NOTANSWERING]);
         //������ ��� ��� ���-�� ������ ��������� DISCONNECT �� ����� �����
         // iChat  1  ANDREY  DISCONNECT  iTCniaM 
         Mess := #19 + ChatLineUsers[n].ProtoName + #19#19 + inttostr(ChatLineUsers[n].LastReceivedMessNumber + 1) +
                 #19#19 + ChatLineUsers[n].ComputerName +  #19#19 + 'DISCONNECT' +  #19#19 +
                 self.FChatLineName + #19;
         // ���� ������� ����� �� ������ �� n �� �����������
         MessageProtocolProcessing(PChar(Mess));
         TDebugMan.AddLine2('���� �� ��������, ������� ��� �� ����� [' + self.ChatLineName + '] <<<< ' + Mess); //FormDebug.DebugMemo2.Lines.Add('���� �� ��������, ������� ��� �� ����� [' + self.ChatLineName + '] <<<< ' + Mess);
         {SendCommDisconnect(PChar(ChatLineUsers[n].ProtoName),
                         PChar(ChatLineUsers[n].ComputerName),
                         PChar(tLocalUser.ComputerName),
                         PChar(self.FChatLineName));}
      end
      else
      begin
        inc(n); // ����������� n ������ ���� �� ������� �����
      end;
    end;

    for n := 0 to Self.UsersCount - 1 do begin
      if tLocalUser.UserID <> Self.ChatLineUsers[n].UserID then begin
        Self.ChatLineUsers[n].Status := dcsDisconnected;
  //    SendCommStatus(PChar(MainLine.ChatLineUsers[n].ComputerName), tLocalUser.Status, PChar(tLocalUser.MessageStatus.Strings[tLocalUser.Status]));

        if ChatMode <> cmodTCP
          then SendCommRefresh(PChar(Self.ChatLineUsers[n].ProtoName), PChar(Self.ChatLineUsers[n].ComputerName), PChar(Self.ChatLineName), PChar(Self.ChatLineUsers[n].DisplayNickName), Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 0);

        SendCommRefresh(PChar(Self.ChatLineUsers[n].ProtoName), PChar(Self.ChatLineUsers[n].ComputerName), PChar(Self.ChatLineName), PChar(Self.ChatLineUsers[n].DisplayNickName), Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 1);
      end;
    end;
  end;

  SendMessage(application.MainForm.handle,
              UM_INCOMMINGMESSAGE,
              UM_INCOMMINGMESSAGE_UpdateTree, Self.LineID);

  TimerSendMsgRefresh.Interval := Self.AutoRefreshTime; // TODO ????? why is it?

except
  on E: Exception do begin
{$IFDEF USELOG4D}
    logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
    logger.Error(E.Message, E);
{$ENDIF USELOG4D}
    raise;
  end;
end;

END;

procedure TChatLine.ChatLineViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
//form1.Caption := 'x = ' + inttostr(x) + ' y = ' + inttostr(y);
if Button = mbRight then
  begin
  p.X := X;
  p.Y := Y;
  p := (Sender as TControl).ClientToScreen(p);
  DynamicPopupMenu.OnComponentClick(TComponent(Sender), p.X, p.Y {MouseX, MouseY});
  end;
end;

{roma
FUNCTION TChatLine.GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
VAR
I, Posit, DelCount: integer;
S: string;
BEGIN
S := SourceString;
for I := 1 to ParamNumber do begin
  Posit := Pos(Separator, S) + Length(Separator) - 1;
  Delete(S, 1, Posit);
end;
Posit := Pos(Separator, S);
DelCount := Length(S) - Posit + 1;
Delete(S, Posit, DelCount);
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
}

PROCEDURE TChatLine.SetAutoRefreshTime(RefreshTime: integer);
BEGIN
self.TimerSendMsgRefresh.Interval := RefreshTime;
self.FAutoRefreshTime := RefreshTime;
END;

FUNCTION TChatLine.GetUniqueNickName(NewUserId: cardinal):string;
VAR c, LocalUserId:cardinal;
BEGIN
//�������� ��� �� � ���� ����� � ����� �� �����, ��� � ���������
result := Self.ChatLineUsers[NewUserId].NickName;
LocalUserId := Self.GetLocalUserId();
if GetLocalUserId = INVALID_USER_ID then
  begin
  TDebugMan.AddLine2('[' + self.ChatLineName + '].GetUniqueNickName(): ���������� ����� ��� � ���� �����!'); //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + '].GetUniqueNickName(): ���������� ����� ��� � ���� �����!');
  exit;
  end;

for c := 0 to Self.UsersCount - 1 do
  begin
  if (c <> LocalUserId) and (NewUserId = LocalUserId) and
    (AnsiCompareText(Self.ChatLineUsers[c].NickName, Self.ChatLineUsers[LocalUserId].NickName) = 0) then
    begin
    //� ��� ������ ��������� ������������, �� ��� ��� ���������
    //� ����� ������� ����� ���������� ��� ��� ��-�������
    //��������� � ���� _IP_Login
    if ChatMode = cmodTCP then
      Self.ChatLineUsers[c].DisplayNickName :=  Self.ChatLineUsers[c].NickName + '_' + Self.ChatLineUsers[c].IP + '_' + Self.ChatLineUsers[c].Login
    else
      Self.ChatLineUsers[c].DisplayNickName :=  Self.ChatLineUsers[c].NickName + '_' + Self.ChatLineUsers[c].ComputerName + '_' + Self.ChatLineUsers[c].Login;

    TDebugMan.AddLine2('[' + self.ChatLineName + ']: ��� ����� [' + Self.ChatLineUsers[c].ComputerName + '] ��������� � ����� ���������� �����!'); //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + ']: ��� ����� [' + Self.ChatLineUsers[c].ComputerName + '] ��������� � ����� ���������� �����!');
    TDebugMan.AddLine2('[' + self.ChatLineName + ']: ������ ��� ����� [' + Self.ChatLineUsers[c].ComputerName + '] �� ' + Self.ChatLineUsers[c].DisplayNickName); //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + ']: ������ ��� ����� [' + Self.ChatLineUsers[c].ComputerName + '] �� ' + Self.ChatLineUsers[c].DisplayNickName);
    break;
    end;

  if (NewUserId <> LocalUserId) and (NewUserId <> c) and
   (AnsiCompareText(Self.ChatLineUsers[NewUserId].NickName, Self.ChatLineUsers[c].DisplayNickName) = 0) then
    begin
    //���� ��� ��������� ��������� � ����� ����-�� � ���� ���������� ��� ��� ��-�������
    //MessageBox(0, PChar('Match!!!!'), PChar(inttostr(0)) ,mb_ok);
    if ChatMode = cmodTCP then
      Result :=  Self.ChatLineUsers[NewUserId].NickName + '_' + Self.ChatLineUsers[NewUserId].IP + '_' + Self.ChatLineUsers[NewUserId].Login
    else
      Result :=  Self.ChatLineUsers[NewUserId].NickName + '_' + Self.ChatLineUsers[NewUserId].ComputerName + '_' + Self.ChatLineUsers[NewUserId].Login;

    TDebugMan.AddLine2('[' + self.ChatLineName + ']: 2 ���������� ����! ������������ [' + Self.ChatLineUsers[c].ComputerName + '] ' + Self.ChatLineUsers[c].DisplayNickName +
                              ' � ��������� [' + Self.ChatLineUsers[NewUserId].ComputerName + '] ' + Self.ChatLineUsers[NewUserId].NickName);
                              //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + ']: 2 ���������� ����! ������������ [' + Self.ChatLineUsers[c].ComputerName + '] ' + Self.ChatLineUsers[c].DisplayNickName +
                              //' � ��������� [' + Self.ChatLineUsers[NewUserId].ComputerName + '] ' + Self.ChatLineUsers[NewUserId].NickName);
    TDebugMan.AddLine2('[' + self.ChatLineName + ']: ������ ��� [' + Self.ChatLineUsers[NewUserId].ComputerName + '] ' + Self.ChatLineUsers[NewUserId].NickName + ' �� ' + Result); //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + ']: ������ ��� [' + Self.ChatLineUsers[NewUserId].ComputerName + '] ' + Self.ChatLineUsers[NewUserId].NickName + ' �� ' + Result);
    break;
    end;
  end;
END;

FUNCTION TChatLine.GetUserByDisplayNickName(DisplayNickName:String):TChatUser;
BEGIN
  Result := self.GetUserInfo(self.GetUserIdByDisplayNickName(DisplayNickName));
END;

FUNCTION TChatLine.GetLocalUserId():cardinal;
BEGIN
  Result := self.GetUserIdByCompName(LocalComputerName);
END;

FUNCTION TChatLine.GetLocalUser():TChatUser;
BEGIN
  Result := self.GetUserInfo(self.GetLocalUserID());
END;

function TChatLine.GetUsersCount():cardinal;
begin
  Result := Length(self.ChatLineUsers);
end;

function TChatLine.GetUserInfo(UserNumber: cardinal):TChatUser;
begin
if (GetUsersCount() > 0) and (UserNumber <= (GetUsersCount() - 1)) then
  begin
  Result := self.ChatLineUsers[UserNumber];
  end
else
  Result := nil;
end;

function TChatLine.GetUserIdByCompName(CompName: String):cardinal;
var c:cardinal;
begin
Result := INVALID_USER_ID;
if (length(Self.ChatLineUsers) > 0) and (Self.UsersCount > 0) {and (Length(ChatLineUsers) > 0)} then
  begin
  for c := 0 to Self.UsersCount - 1 do
    begin
    if AnsiCompareText(CompName, Self.ChatLineUsers[c].ComputerName) = 0 then
      begin
      Result := Self.ChatLineUsers[c].UserID;
      break;
      end;
    end;
  end;
end;

function TChatLine.GetUserIdByDisplayNickName(DisplayNickName: String):cardinal;
var c:cardinal;
begin
result := INVALID_USER_ID;
for c := 0 to UsersCount - 1 do
  begin
  if (Self <> nil) and (Self.ChatLineUsers[c] <> nil) and
     (DisplayNickName = Self.ChatLineUsers[c].DisplayNickName) then
    begin
    result := Self.ChatLineUsers[c].UserID;
    end;
  end;
end;

function TChatLine.GetLocalComputerName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
var TempBuffer:array[0..255] of Char;
    BufferSize:cardinal;
begin
BufferSize := SizeOf(TempBuffer);
GetComputerName(@TempBuffer, BufferSize);
self.LocalComputerName := strpas(StrUpper(TempBuffer));

if Length(LocalComputerName) > 0 then
  begin
  result := LocalComputerName;
  end
else
  result := 'ErrorGetLocalComputerName';
end;


{//��� �-��� �������� �� ������ � DLL, �.�. �� ����� �������� �� DreamChat.dpr

function TChatLine.GetLocalUserLoginName():string;//����� ����� ��������� win = 98/NT !!!!!!!!!
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
  result := 'ErrorGetLocalUserLoginName'; //��������� � ��������!!!
end;}

procedure TChatLine.SendDisconnectConnect(sReceivedMessage:string);
var tLocalUser: TChatUser;
    LineName, sProtoName: string;
    MainLine: TChatLine;
    {$IFDEF USELOG4D}
    logger: TLogLogger;
    {$ENDIF USELOG4D}
    ComputerName: string;
begin
    {$IFDEF USELOG4D}
    logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
    {$ENDIF USELOG4D}

    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
    TDebugMan.AddLine2('��������! ������ ��������� ' +
                          PChar(GetParamX(sReceivedMessage, 3, #19#19, true)) + ' �� ' +
                          PChar(GetParamX(sReceivedMessage, 2, #19#19, true)) +
                          ' �� � ���� ��� ���!');
    //FormDebug.DebugMemo2.Lines.Add('��������! ������ ��������� ' +
    //                      PChar(GetParamX(sReceivedMessage, 3, #19#19, true)) + ' �� ' +
    //                      PChar(GetParamX(sReceivedMessage, 2, #19#19, true)) +
    //                      ' �� � ���� ��� ���!');
    TDebugMan.AddLine2('�������� ��� DISCONNECT + CONNECT...'); //FormDebug.DebugMemo2.Lines.Add('�������� ��� DISCONNECT + CONNECT...');
    //SendCommDisconnect(PChar(GetParamX(sReceivedMessage, 1, #19, true)), '', PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), 'iTCniaM');
    //LineName := Pchar(GetParamX(sReceivedMessage, 4, #19#19, true));
    LineName := self.FChatLineName;
    SendCommDisconnect(
                       PChar(GetParamX(sReceivedMessage, 1, #19, True)), '',
                       PChar(GetParamX(sReceivedMessage, 2, #19#19, True)), PChar(LineName));
    tLocalUser := FormMain.GetMainLine.GetLocalUser ;//self.GetUserInfo(self.GetLocalUserID());

    {$IFDEF USELOG4D}
    if tLocalUser = nil
      then logger.error('[TChatLine.SendDisconnectConnect] tLocalUser = NULL!');
    {$ENDIF USELOG4D}

    if LineName = '*'
      then LineName := TDreamChatDefaults.MainChatLineName; //'iTCniaM';

    sProtoName := GetParamX(sReceivedMessage, 1, #19, True);
    ComputerName := GetParamX(sReceivedMessage, 2, #19#19, True);

    SendCommConnect(
                    PChar(sProtoName),
                    PChar(LocalNickName),
                    Pchar(ComputerName {GetParamX(sReceivedMessage, 2, #19#19, true)}),
                    Pchar(LineName),// 'iTCniaM',
                    Pchar(ComputerName {GetParamX(sReceivedMessage, 2, #19#19, true)}),
                    PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                    Ord(tLocalUser.Status));

    {$IFDEF USELOG4D}
    logger.info('[TChatLine.SendDisconnectConnect] after SendCommConnect');
    {$ENDIF USELOG4D}

    MainLine := FormMain.GetMainLine;
    tLocalUser := MainLine.GetLocalUser;
    if tLocalUser <> nil then
      begin
      SendCommStatus_Req(PChar(tLocalUser.ProtoName), PChar(GetParamX(sReceivedMessage, 2, #19#19, True)));
      SendCommRefresh_Board(PChar(tLocalUser.ProtoName), PChar(GetParamX(sReceivedMessage, 2, #19#19, True)), 1);
      end;
end;

PROCEDURE TChatLine.OnVScrolled;
BEGIN
if self.ChatLineView.VScrollPos = self.ChatLineView.VScrollMax then
  ScrollToEnd := true
else
  ScrollToEnd := false;
END;

procedure TChatLine.ChatSplitterCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
if FChatSplitter.Align = FChatLineTree.Align then
  begin
  if (FChatLineTree.Constraints.MinWidth > 0) and
    (NewSize < FChatLineTree.Constraints.MinWidth) then
    Accept := false;
  if (FChatLineTree.Constraints.MaxWidth > 0) and
    (NewSize > FChatLineTree.Constraints.MaxWidth) then
    Accept := false;
  end;
if FChatSplitter.Align = FChatLineView.Align then
  begin
  if (FChatLineView.Constraints.MinWidth > 0) and
    (NewSize < FChatLineView.Constraints.MinWidth) then
    Accept := false;
  if (FChatLineView.Constraints.MaxWidth > 0) and
   (NewSize > FChatLineView.Constraints.MaxWidth) then
    Accept := false;
  end;
if FChatLineView.Align = alClient then
  begin
  if FChatLineView.Parent.Width - NewSize <= FChatLineView.Constraints.MinWidth + 5 then
    Accept := false;
  end;
end;

procedure TChatLine.StringToComponent(Component: TComponent; Value: string);
var
  StrStream:TStringStream;
  ms: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    ms := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, ms);
      ms.position := 0;
      ms.ReadComponent(Component);
    finally
      ms.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

constructor TChatLine.Create(LineName:String; ChatPageControl:TPageControl; CVStyle:TCVStyle);
var
  strlist: TStringList;
  si, sc: string;
  LocalIP: PChar;
begin
  inherited Create;
  {����� ��� �������� �������� �� �������� ����� � ����������� ������� � �.�.}
  self.ChatLineName := LineName;

  //Show_SystemMessages_Refresh := TDreamChatConfig.GetRefreshMessage(); //FormMain.ChatConfig.ReadBool('SystemMessages', 'RefreshMessage', true);

  //��� ����� ��������� ��������� �� ����� OffLine ��� ������� �����.
  //����� ���� �������� ���, �� ��� ��� ����� ����� ���������� ������
  //������� ��������� � ���� ������. ���� ���� ����� ����� � ���, �� ��
  //��������� ��������� �� ��� ������������ �����.
  UsersConnectHistory := TStringlist.Create;

  MessagesHistory := TStringList.Create;
  LineLog := TStringList.Create;
  FFullLogFileName := GetSafetyLogFileName(LineName);
  if FFullLogFileName = UNKNOWN_LOG_FILE_NAME then
  begin
    sc := LineLog.Text;
    LineLog.Add(sc);
  end;

  FFullLogFileName := TPathBuilder.GetExePath() + 'Logs\' + FFullLogFileName + '.log';
{if FileExists(FFullLogFileName) then
  begin
  LineLog.LoadFromFile(FFullLogFileName);
  LineLog.Add(sc);
  end;}
  LineLog.Add('DreamChat runing at: [' + DateToStr(Now) + '/' + TimeToStr(Now) + ']');

  self.LineType := LT_COMMON;
  self.LineID := 0;
  self.ScrollToEnd := true;
  self.MessagesHistoryIndex := 0;
  strlist := TStringList.Create;
  si := TPathBuilder.GetExePath();//+'images\';// ������� � ����� ������
  sc := TPathBuilder.GetComponentsFolderName(); //ExePath + 'Components\';
  self.RefreshTreeNumber := 0;
  {������� ChatLineTabSheet}
  ChatLineTabSheet := TsTabSheet.Create(ChatPageControl);
  if FileExists(sc + 'clTabSheet.txt') then
    begin
    strlist.LoadFromFile(sc + 'clTabSheet.txt');
    StringToComponent(ChatLineTabSheet, strlist.text);
    end
  else
    begin
    TDebugMan.AddLine2( '�� ������ ���� �������� ����������: ' + sc + 'clTabSheet.txt'); //FormDebug.DebugMemo2.Lines.Add('�� ������ ���� �������� ����������: ' + sc + 'clTabSheet.txt');
    TDebugMan.AddLine2('��� ���������� ' + ChatLineTabSheet.Name + ' ���������� ��������� �� .res'); //FormDebug.DebugMemo2.Lines.Add('��� ���������� ' + ChatLineTabSheet.Name + ' ���������� ��������� �� .res');
    ChatLineTabSheet.Caption := '����� ���';
    ChatLineTabSheet.ImageIndex := 1;
    end;
  ChatLineTabSheet.Name := 'TabSheet_' + inttostr(GetTickCount());//LineName; <- ��� ����� ���� �� �� ����������!!!

  if ChatLineName = TDreamChatDefaults.MainChatLineName {'iTCniaM'}
    then ChatLineTabSheet.UseCloseBtn:= MinimizeOnClose;

  ChatLineTabSheet.Visible := false;
  //ChatLineTabSheet.TabVisible := false;
  //���� �������. ���� ����� ����� �����������.
  ChatLineTabSheet.Parent := ChatPageControl;
  ChatLineTabSheet.ParentWindow := ChatPageControl.Handle;
  ChatLineTabSheet.PageControl := ChatPageControl;
  ChatLineTabSheet.Visible := false;
  ChatLineTabSheet.Caption := LineName + ' created';
  //  ChatLineTabSheet.UseCloseBtn := false;
  {/������� ChatLineTree}

  {������� ChatLineTree}
  ChatLineTree := TGifVirtualStringTree.CreateGVST(self, ChatLineTabSheet, si);
  ChatLineTree.Name := 'Tree_' + inttostr(GetTickCount());//LineName; <- ��� ����� ���� �� �� ����������!!!
  ChatLineTree.parent := ChatLineTabSheet;
  ChatLineTree.ParentWindow := ChatLineTabSheet.Handle;
  if FileExists(sc + 'clGifVTree.txt') then
    begin
    strlist.LoadFromFile(sc + 'clGifVTree.txt');
    StringToComponent(ChatLineTree, strlist.text);
    end
  else
    begin
    TDebugMan.AddLine2('�� ������ ���� �������� ����������: ' + sc + 'clGifVTree.txt'); //FormDebug.DebugMemo2.Lines.Add('�� ������ ���� �������� ����������: ' + sc + 'clGifVTree.txt');
    TDebugMan.AddLine2('��� ���������� ' + ChatLineTree.Name + ' ���������� ��������� �� .res'); //FormDebug.DebugMemo2.Lines.Add('��� ���������� ' + ChatLineTree.Name + ' ���������� ��������� �� .res');
    ChatLineTree.Left := 318;
    ChatLineTree.Top := 0;
    ChatLineTree.Width := 194;
    ChatLineTree.Height := 291;
    ChatLineTree.Align := alRight;
    ChatLineTree.CheckImageKind := ckCustom;
    ChatLineTree.DefaultNodeHeight := 16;
    ChatLineTree.DefaultPasteMode := amInsertAfter;
    ChatLineTree.Font.Charset := RUSSIAN_CHARSET;
    ChatLineTree.Font.Color := clWindowText;
    ChatLineTree.Font.Height := -15;
    ChatLineTree.Font.Name := 'Tahoma';
    ChatLineTree.Font.Style := [];
    ChatLineTree.Header.AutoSizeIndex := -1;
    ChatLineTree.Header.Font.Charset := RUSSIAN_CHARSET;
    ChatLineTree.Header.Font.Color := clWindowText;
    ChatLineTree.Header.Font.Height := -11;
    ChatLineTree.Header.Font.Name := 'Tahoma';
    ChatLineTree.Header.Font.Style := [];
    ChatLineTree.Header.MainColumn := -1;
    ChatLineTree.Header.Options := [hoColumnResize, hoDrag];
    ChatLineTree.Indent := 16;
    ChatLineTree.Margin := 32;
    ChatLineTree.NodeDataSize := 0;
    ChatLineTree.ParentFont := False;
    ChatLineTree.TabOrder := 0;
    ChatLineTree.TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes];
    ChatLineTree.TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages];
    //ChatLineTree.Columns := <>;
    end;
  ChatLineTree.Header.Columns.Add;
  {/������� ChatLineTree}

  {������� ChatSplitter}
  ChatSplitter := TsSplitter.Create(ChatLineTabSheet);
  if FileExists(sc + 'clGifVTree.txt') then
    begin
    strlist.LoadFromFile(sc + 'clChatSplitter.txt');
    StringToComponent(ChatSplitter, strlist.text);
    end
  else
    begin
    ChatSplitter.Width := 5;
    ChatSplitter.Cursor := crHSplit;
    ChatSplitter.Align := alRight;
    end;
  ChatSplitter.parent := ChatLineTabSheet;
  ChatSplitter.Name := 'Splitter_'  + inttostr(GetTickCount());//LineName; <- ��� ����� ���� �� �� ����������!!!
  ChatSplitter.OnCanResize := ChatSplitterCanResize;
  {/������� ChatSplitter}

  {������� ChatLineView}
  ChatLineView := TsChatView.Create(ChatLineTabSheet);
  ChatLineView.Name := 'sChatView_' + inttostr(GetTickCount());//LineName; <- ��� ����� ���� �� �� ����������!!!
  ChatLineView.parent := ChatLineTabSheet;
  ChatLineView.ParentWindow := ChatLineTabSheet.Handle;
  ChatLineView.Style := CVStyle;//��� ����!
  if FileExists(sc + 'CLChatLineView.txt') then
    begin
    strlist.LoadFromFile(sc + 'CLChatLineView.txt');
    StringToComponent(ChatLineView, strlist.text);
    end
  else
    begin
    TDebugMan.AddLine2('�� ������ ���� �������� ����������: ' + sc + 'CLChatLineView.txt'); //FormDebug.DebugMemo2.Lines.Add('�� ������ ���� �������� ����������: ' + sc + 'CLChatLineView.txt');
    TDebugMan.AddLine2('��� ���������� ' + ChatLineView.Name + ' ���������� ��������� �� .res'); //FormDebug.DebugMemo2.Lines.Add('��� ���������� ' + ChatLineView.Name + ' ���������� ��������� �� .res');

    ChatLineView.Left := 0;
    ChatLineView.Top := 0;
    ChatLineView.Width := 525;
    ChatLineView.Height := 243;
    ChatLineView.TabStop := True;
    ChatLineView.TabOrder := 0;
    ChatLineView.Align := alClient;
    ChatLineView.Tracking := True;
    ChatLineView.VScrollVisible := True;
    ChatLineView.FirstJumpNo := 0;
    ChatLineView.MaxTextWidth := 0;
    ChatLineView.MinTextWidth := 0;
    ChatLineView.LeftMargin := 5;
    ChatLineView.RightMargin := 5;
    ChatLineView.BackgroundStyle := bsNoBitmap;
    ChatLineView.Delimiters := ' .;,:)}"';
    ChatLineView.MergeDelimiters := '({"|';
    ChatLineView.AllowSelection := True;
    ChatLineView.SingleClick := False;
    ChatLineView.VScrollBound := 20;
    ChatLineView.HScrollBound := 20;
    ChatLineView.BoundLabel.Indent := 0;
    ChatLineView.BoundLabel.Font.Charset := DEFAULT_CHARSET;
    ChatLineView.BoundLabel.Font.Color := clWindowText;
    ChatLineView.BoundLabel.Font.Height := -11;
    ChatLineView.BoundLabel.Font.Name := 'MS Sans Serif';
    ChatLineView.BoundLabel.Font.Style := [];
    //ChatLineView.BoundLabel.Layout := sclLeft;
    ChatLineView.BoundLabel.MaxWidth := 0;
    ChatLineView.BoundLabel.UseSkinColor := True;
    ChatLineView.SkinData.SkinSection := 'EDIT';
    end;
  ChatLineView.Style := CVStyle;//��� ����!
  ChatLineView.OnVScrolled := OnVScrolled;
  ChatLineView.CursorSelection := false;
  ChatLineView.OnMouseDown := ChatLineViewMouseDown;
  ChatLineView.Constraints.MinWidth := 50;
  {/������� ChatLineView}

  ChatPageControl.ActivePage := ChatLineTabSheet;
  Self.LocalComputerName := self.GetLocalComputerName();
  Self.LocalLoginName := GetUserLoginName(); //roma{self.}GetLocalUserLoginName('');
  Self.LocalIpAddres := '127.0.0.1';

  //if FormMain.ChatConfig.ReadString('ConnectionType', 'Server', 'Yes') <> 'No' then
  if TDreamChatConfig.GetServer() <> 'No' then //TODO: magic number!  
  begin
    LocalIP := GetLocalIP();
    Self.LocalIpAddres := StrPas(LocalIP);
    //FormMain.Caption := Self.LocalIpAddres;
    LocalComputerName := Self.LocalIpAddres + '/' + LocalComputerName + '/' + LocalLoginName;
  end;

  strlist.Free;

  TimerSendMsgRefresh := TTimer.Create(FormMain);
  TimerSendMsgRefresh.OnTimer := Self.Scheduler;
  TimerSendMsgRefresh.Interval := Self.AutoRefreshTime;
  TimerSendMsgRefresh.Enabled := true;

  ChatLineTabSheet.Visible := true;
  //ChatLineTabSheet.TabVisible := true;
  ChatPageControl.ActivePage := ChatLineTabSheet;  
end;

destructor TChatLine.Destroy;
var n: word;
    FileStream: TFileStream;
begin
if FileExists(FFullLogFileName) then
  begin
  FileStream := TFileStream.Create(FFullLogFileName, fmOpenWrite);
  FileStream.Seek(0, soFromEnd);
  FileStream.write(pointer(LineLog.Text)^, length(LineLog.Text));
  FileStream.Free;
  end
else
  LineLog.SaveToFile(FFullLogFileName);
LineLog.Free;

TimerSendMsgRefresh.Enabled := false;
ChatLineTabSheet.Visible := false;
ChatLineView.Clear;
ChatLineView.Free;
ChatLineView := nil;//���� ��� ����������� ��������! ����� AV � SaveUserSettingsToIni()

//�����-�� ���� ����� � ����������� ����� ��� ������ Destroy
//������ ��� ���-�� �� �������� �����������...
if self.FChatLineName = TDreamChatDefaults.MainChatLineName {'iTCniaM'}
  then ChatLineTree.Destroy//TODO: ��������!!! �������� ����� �����������!!
  else ChatLineTree.Free;//TODO: ��������!!! �������� ����� �����������!!

ChatSplitter.Free;
if Length(Self.ChatLineUsers) > 0 then
  begin
  for n := 0 to Length(Self.ChatLineUsers) - 1 do
    begin
    ChatLineUsers[n].Free;
    end;
  end;
SetLength(ChatLineUsers, 0);

//SmilesName.Free;
UsersConnectHistory.Free;
MessagesHistory.Free;
ChatLineTabSheet.Free;
TimerSendMsgRefresh.Free;

inherited Destroy;
end;

procedure TChatLine.Assign(Source: TPersistent);
var n:word;
begin
  if Source is TChatLine then
    begin
    Self.ChatLineName := TChatLine(Source).ChatLineName;
    Self.ChatLineTabSheet.Assign(TTabSheet(TChatLine(Source).ChatLineTabSheet));
    Self.ChatLineView.Assign(TsChatView(TChatLine(Source).ChatLineView));
    Self.ChatLineTree.Assign(TTreeView(TChatLine(Source).ChatLineTree));
    Self.ChatSplitter.Assign(TSplitter(TChatLine(Source).ChatSplitter));
    Self.MessagesHistory.Assign(TStringList(TChatLine(Source).MessagesHistory));
    self.UsersConnectHistory.Assign(TChatLine(Source).UsersConnectHistory);
    Self.FFullLogFileName := TChatLine(Source).FFullLogFileName;
    Self.LineLog.Assign(TStringList(TChatLine(Source).LineLog));
    Self.FAutoRefreshTime := TChatLine(Source).FAutoRefreshTime;
   // Self.UsersCount := TChatLine(Source).UsersCount;
    self.RefreshTreeNumber := TChatLine(Source).RefreshTreeNumber;

    if Length(Self.ChatLineUsers) > 0 then
      begin
      for n := 0 to Length(Self.ChatLineUsers) - 1 do
        begin
        Self.ChatLineUsers[n].Assign(TChatUser(TChatLine(Source).ChatLineUsers[n]));
        end;
      end;

    Self.OnCmdConnect := TChatLine(Source).OnCmdConnect;
    Self.OnCmdDisconnect := TChatLine(Source).OnCmdDisconnect;
    Self.OnCmdText := TChatLine(Source).OnCmdText;
    Self.OnCmdRefresh := TChatLine(Source).OnCmdRefresh;
    Self.OnCmdRename := TChatLine(Source).OnCmdRename;
    Self.OnCmdCreate := TChatLine(Source).OnCmdCreate;
    Self.OnCmdCreateLine := TChatLine(Source).OnCmdCreateLine;
    Self.OnCmdReceived := TChatLine(Source).OnCmdReceived;
    Self.OnCmdBoard := TChatLine(Source).OnCmdBoard;
    Self.OnCmdStatus := TChatLine(Source).OnCmdStatus;
    Self.OnCmdStatus_Req := TChatLine(Source).OnCmdStatus_Req;
//    Self.Sheduler := TChatLine(Source).Sheduler;
//    Self.MessageProtocolProcessing := TChatLine(Source).MessageProtocolProcessing;
    end
  else
    inherited Assign(Source);
end;

FUNCTION TChatLine.GetSafetyLogFileName(FileNameWithExceptSymbols: string):string;
VAR
   c: cardinal;
   i: integer;
   LineNode: TLineNode;
   MainLine: TChatLine;
BEGIN
//������� �������-���������� �� �������� �����
//����� �� �� ������ ������� ���� ���� � ����� ������.
//result := FileNameWithExceptSymbols;
for c := 1 to Length(FileNameWithExceptSymbols) do begin
  if ((Byte(FileNameWithExceptSymbols[c]) > 0) and (Byte(FileNameWithExceptSymbols[c]) < 32)) or
     (FileNameWithExceptSymbols[c] in ['"', '/', ':', '*', '?', '<', '>', '\',
       '|', ';', '*']) then begin
       // nothing to do
  end
  else
  begin
    Result := Result + FileNameWithExceptSymbols[c];
  end
end;

if Length(Result) = 0 then begin
  //�����-�� ���� ������ �����, �������� ������� ������� ������ �� ������-����������!
  //��������� ��� ����������...
  Result := UNKNOWN_LOG_FILE_NAME;
  MainLine := FormMain.GetMainLine();
  if MainLine <> nil then begin
    for c := 0 to MainLine.UsersCount - 1 do begin
      i := MainLine.ChatLineUsers[c].ChatLinesList.IndexOf(self.FChatLineName);
      if i > 0 then begin
        LineNode := TLineNode(MainLine.ChatLineUsers[c].ChatLinesList.Objects[i]);
        Self.LineLog.Add('[' + TimeToStr(Now) + '] Line with name ' +
                    '''' + self.FChatLineName + '''' + ' was created by ' + '''' +
                    LineNode.LineOwner + '''' + ' by command: ' + LineNode.CreatedByCommand);
        break;
      end;
    end;

    if i < 0 then begin
      Self.LineLog.Add('Line with name ' + '''' + self.FChatLineName + '''' + ' was created by unknown user')
    end
  end;
end;
END;

{FUNCTION TChatLine.StrToIntE(s: string):integer;
BEGIN
result := 0;
try
  result := strtoint(s);
except
    //on E:EConvertError do
  on E:Exception do
    begin
    FormMain.ProcessException(Self, E);
    end;
end;
END;
}

{================ ������� ������� ��������� ��������� ��������� ===============}
{            ����� �� ������������� �������� �� ��������� ���������            }
{             � ����� ������ �������������, ��������/���������� ���            }
{==============================================================================}
PROCEDURE TChatLine.MessageProtocolProcessing(pReceivedMessage: PChar);
VAR sReceivedMessage, s:string;
    c, id, MainLineUID:cardinal;
    i: integer;
    tLocalUser:TChatUser;
    MainLine: TChatLine;
    MessBoardNumber:cardinal;
    DoUpdate:boolean;
    StrList:TStringList;
    LineNode: TLineNode;
    PDNode: PDataNode;
BEGIN
sReceivedMessage := pReceivedMessage;
id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
if id <> INVALID_USER_ID then
  begin
  //���� � ����� 2 � ����� ������� ����������, �� �������� ����������� �� ������ �� ���
  //�������������� � ������� �������� �����. ����� REFRESH!!! �� ����� ����� ����� �����!
  if ChatMode = cmodMailSlot then
    begin
    if (GetParamX(sReceivedMessage, 3, #19#19, true) <> 'REFRESH') and
      (self.ChatLineUsers[id].LastReceivedMessNumber >= StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true))) then exit;
    end;
  end;

id := INVALID_USER_ID;
LineNode := nil;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'CONNECT' then
  begin
  //iChat309VETALCONNECTiTCniaM������_login���������� ������!ANDREY1.21b60
  //������� ������� CONNECT
  //messagebox(0, PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), '���� ID ������������������ �����' ,mb_ok);
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     GetParamX(sReceivedMessage, 6, #19#19, true),
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id = INVALID_USER_ID then
    begin
      //���� ������ ����� �� ���� � ������ ������, �� � ��� ����� ����� ����
      //��� � ��� ��������:
      //� ������ ������� ��� �������� �������, �� �� ��� � ������ ������������� ���
      //������� � ����� ������ �������
    //messagebox(0, PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), 'ID ������������������ ����� �� ������!' ,mb_ok);
    MainLine := FormMain.GetMainLine();
    if (
        (AnsiCompareText(GetParamX(sReceivedMessage, 2, #19#19, true), LocalComputerName) <> 0) and
        (AnsiCompareText(GetParamX(sReceivedMessage, 9, #19#19, true), '*') = 0)
       )
        or
       (
        (AnsiCompareText(GetParamX(sReceivedMessage, 2, #19#19, true), LocalComputerName) <> 0) and
        (AnsiCompareText(GetParamX(sReceivedMessage, 9, #19#19, true), LocalComputerName) = 0) {and
        (AnsiCompareText(GetParamX(sReceivedMessage, 5, #19#19, true), LocalLoginName) <> 0) }{and
        (AnsiCompareText(GetParamX(sReceivedMessage, 6, #19#19, true), LocalNickName) = 0)
        })
        or
        (AnsiCompareText(GetParamX(sReceivedMessage, 5, #19#19, true), LocalLoginName) <> 0) then
      begin
      //���� �������� ��������� CONNECT, �� �� ���� � ���
      //�� �������� ������� �� ��� ��������� CONNECT
      //������ ������ ����� ���� � ����� �������������
      //messagebox(0, PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), '������ ������ ����� ���� � ����� �������������!' ,mb_ok);
      if (AnsiCompareText(GetParamX(sReceivedMessage, 4, #19#19, True), TDreamChatDefaults.MainChatLineName {'iTCniaM'}) <> 0) and
        (MainLine.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true)) = INVALID_USER_ID) then
        begin
        //���� ����� ��� ��� � ������� �����, � �� ���� ������ CONNECT � ����� �����.
        SendDisconnectConnect(pReceivedMessage);
        exit;
        end;

      tLocalUser := Self.GetUserInfo(Self.GetLocalUserId());
      if tLocalUser = nil then
        begin
        TDebugMan.AddLine2('� ���� ����� ��� ��� ���������� ������������, ����������� �� iTCniaM'); //FormDebug.DebugMemo2.Lines.Add('� ���� ����� ��� ��� ���������� ������������, ����������� �� iTCniaM');
        tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserId());
        end;
      if tLocalUser = nil then
        begin
        //��������! �������� ��������� �� ������� ������������, �� ����
        //��� ��������� ������������� ���������� ������������!
        TDebugMan.AddLine2('��������! ��������� ����������� ��� �� ����� �  iTCniaM!' +
                                  '������� ���������� ���������� ������������...');
         //FormDebug.DebugMemo2.Lines.Add('��������! ��������� ����������� ��� �� ����� �  iTCniaM!' +
         //                         '������� ���������� ���������� ������������...');
        //������������� ������� ���������� ���������� ������������, ����� ���������
        //���������� ����� ����� ��������
        tLocalUser := TChatUser.Create(self, '');//TODO: ���������!!! �� �������� '' �� ��� � ������?
        //��������! ���������� ������ ������!
        //TODO: �������� ��� ������� ���������� ������������.
        tLocalUser.ComputerName := self.LocalComputerName;
        tLocalUser.IP := LocalIpAddres;

        tLocalUser.Login := self.LocalLoginName;
        tLocalUser.NickName := LocalNickName;
        tLocalUser.DisplayNickName := LocalNickName;
        tLocalUser.LineName := self.FChatLineName;
        //tLocalUser.Version := VERSION;
        tLocalUser.Version := 'Not init';
        tLocalUser.ReceivedMessCount := 0;
        tLocalUser.LastReceivedMessNumber := 0;
        tLocalUser.TimeInChat := GetTickCount();
        tLocalUser.TimeOfLastMess := GetTickCount();
        tLocalUser.Status := dcsNormal;
        tLocalUser.MessageStatus.Clear;

        TDreamChatConfig.FillMessagesState(tLocalUser.MessageStatus);
        StrList := TStringList.Create;
{        for i := 0 to 3 do begin
          FormMain.ChatConfig.ReadSectionValues('MessagesState' + IntToStr(i), StrList);
          if StrList.Count > 0 then
            tLocalUser.MessageStatus.Add(StrList.Strings[0])
          else
            tLocalUser.MessageStatus.Add('Hi all!');
        end;
        StrList.Clear;}
        tLocalUser.ProtoName := TDreamChatConfig.GetProtoName(); //FormMain.ChatConfig.ReadString('Protocols', 'ProtoName', 'iChat');
        StrList.LoadFromFile(TPathBuilder.GetExePath() + TDreamChatConfig.GetMessageBoard()); //FormMain.ChatConfig.ReadString('Common', 'MessageBoard', 'MessageBoard.txt'));
        tLocalUser.MessageBoard.Text := StrList.Text;
        StrList.Free;
        end;

//    messagebox(0, PChar(inttostr(UsersCount)), 'UsersCount = ' ,mb_ok);
      SetLength(Self.ChatLineUsers, UsersCount + 1);
      ChatLineUsers[UsersCount - 1] := TChatUser.Create(Self, sReceivedMessage);//TODO: �������������� �����������!! ���������� � ���� ��������� �������!!
      ChatLineUsers[UsersCount - 1].ComputerName := GetParamX(sReceivedMessage, 2, #19#19, true);
      ChatLineUsers[UsersCount - 1].Login := GetParamX(sReceivedMessage, 5, #19#19, true);
      ChatLineUsers[UsersCount - 1].NickName := GetParamX(sReceivedMessage, 6, #19#19, true);
      ChatLineUsers[UsersCount - 1].Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 11, #19#19, True)));
      if ChatLineUsers[UsersCount - 1].ComputerName <> Self.LocalComputerName then
        begin
        while Ord(ChatLineUsers[UsersCount - 1].Status) >= ChatLineUsers[UsersCount - 1].MessageStatus.Count do
          begin
          ChatLineUsers[UsersCount - 1].MessageStatus.Add('');
          end;
        ChatLineUsers[UsersCount - 1].MessageStatus.Strings[Ord(ChatLineUsers[UsersCount - 1].Status)] := GetParamX(sReceivedMessage, 8, #19#19, True);
        end;
      //ChatLineUsers[UsersCount - 1].MessageStatus.Clear;
      //ChatLineUsers[UsersCount - 1].MessageStatus.Add(GetParamX(sReceivedMessage, 8, #19#19, true));
      ChatLineUsers[UsersCount - 1].LineName := (GetParamX(sReceivedMessage, 4, #19#19, true));
      ChatLineUsers[UsersCount - 1].Version := GetParamX(sReceivedMessage, 10, #19#19, true);
      ChatLineUsers[UsersCount - 1].ReceivedMessCount := ChatLineUsers[UsersCount - 1].ReceivedMessCount + 1;
      ChatLineUsers[UsersCount - 1].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
      if ChatMode = cmodTCP then ChatLineUsers[UsersCount - 1].Ip := GetParamX(ChatLineUsers[UsersCount - 1].ComputerName, 0, '/', true);
      ChatLineUsers[UsersCount - 1].TimeInChat := GetTickCount();
      ChatLineUsers[UsersCount - 1].TimeOfLastMess := GetTickCount();
      //messagebox(0, PChar(inttostr(ChatLineUsers[UsersCount - 1].UserID)), '����� ID' ,mb_ok);
      ChatLineUsers[UsersCount - 1].ProtoName := GetParamX(sReceivedMessage, 1, #19, true);
      //}
      ChatLineUsers[UsersCount - 1].DisplayNickName := Self.GetUniqueNickName(ChatLineUsers[UsersCount - 1].UserID);
      //��������� ������ ������������� ��������� �������� ��� ��������
      case ChatLineUsers[UsersCount - 1].CN_State of
        CNS_Personal: UserListCNS_Personal.Add(Self.ChatLineUsers[UsersCount - 1].ComputerName);
        CNS_Private: UserListCNS_Private.Add(Self.ChatLineUsers[UsersCount - 1].ComputerName);
        end;

      //FormMain.ShowUserInTree(self, UsersCount - 1, ShowUser_ADD);
      //��������� ������ ����� � ������� ���������� ����
      if MainLine <> nil then
        begin
        //��������� ����� ��� ��� ��� ����
        MainLineUID := MainLine.GetUserIdByCompName(ChatLineUsers[UsersCount - 1].ComputerName);
        if MainLineUID <> INVALID_USER_ID then
          begin
          if MainLine.ChatLineUsers[MainLineUID].ChatLinesList.IndexOf(Self.ChatLineUsers[UsersCount - 1].LineName) < 0 then
            begin
            LineNode := TLineNode.Create(ChatLineUsers[UsersCount - 1].LineName, LS_LineObjectCreated);
            LineNode.LineName := GetParamX(sReceivedMessage, 4, #19#19, true);
            LineNode.LineType := FormMain.GetLineType(LineNode.LineName);
            if LineNode.LineType = LT_COMMON then LineNode.DisplayLineName := fmInternational.Strings[I_CommonChat];//'�����';
            if LineNode.LineType = LT_PRIVATE_CHAT then LineNode.DisplayLineName := fmInternational.Strings[I_Private];//'������';
//            if LineNode.LineType = LT_LINE then LineNode.DisplayLineName := fmInternational.Strings[I_LINE];//'�����';
            if LineNode.LineType = LT_LINE then LineNode.DisplayLineName := LineNode.LineName;//'�����';
            LineNode.CreatedByCommand := 'Connect';
            LineNode.LineOwner := ChatLineUsers[UsersCount - 1].ComputerName;
            LineNode.LineOwnerId := UsersCount - 1;
            LineNode.LineUsers.Add(LineNode.LineOwner);
            LineNode.TimeCreate := Now();
            LineNode.TimeOfLastMess := GetTickCount();
            LineNode.LineID := MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(Self.ChatLineUsers[UsersCount - 1].LineName, LineNode);
            TDebugMan.AddLine2('����� ' + Self.ChatLineUsers[UsersCount - 1].LineName +
                                      ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
                                       //FormDebug.DebugMemo2.Lines.Add('����� ' + Self.ChatLineUsers[UsersCount - 1].LineName +
                                      //' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
            //FormMain.ShowLinesInTree(self, ChatLineUsers[UsersCount - 1], LineNode, ShowLine_ADD);
            end
          else
            begin
            //���� ��������, ���� ������/����� ���� ��������� � ������ �������� REFRESH
            //� ����� ���� � ��� �����!
            end;
          end;
        end;

      self.OnCmdConnect(self, sReceivedMessage, UsersCount - 1);
      SendCommConnect(
                      PChar(tLocalUser.ProtoName),
                      PChar(LocalNickName),
                      Pchar(GetParamX(sReceivedMessage, 2, #19#19, true)),
                      PChar(self.ChatLineName){'iTCniaM'},
                      Pchar(GetParamX(sReceivedMessage, 2, #19#19, true)),
                      PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                      Ord(tLocalUser.Status));
      SendCommStatus(PChar(tLocalUser.ProtoName),
                     PChar(GetParamX(sReceivedMessage, 2, #19#19, true)),
                     Ord(tLocalUser.Status),
                     PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
      SendCommBoard(PChar(tLocalUser.ProtoName), PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), PChar(tLocalUser.MessageBoard.Text), TDreamChatConfig.GetMaxSizeOfMessBoardPart());

      //FormMain.ShowAllUserInTree(self);
      //messagebox(0, PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), '������ ������ ����� � �������������!' ,mb_ok);
      //if tLocalUser <> nil then tLocalUser.free;//�������� ����� �� ������� TEMP_tLocalUser
      end
    else
      begin
      //���� ������� �� ����
      TDebugMan.AddLine2('[' + self.ChatLineName + ']: ���������� ��������� ����.'); //FormDebug.DebugMemo2.Lines.Add('[' + self.ChatLineName + ']: ���������� ��������� ����.');
    //  UsersCount := UsersCount + 1;
      SetLength(Self.ChatLineUsers, UsersCount + 1);
      ChatLineUsers[UsersCount - 1] := TChatUser.Create(Self, sReceivedMessage);
      //{
      ChatLineUsers[UsersCount - 1].ComputerName := GetParamX(sReceivedMessage, 2, #19#19, true);
      ChatLineUsers[UsersCount - 1].Login := GetParamX(sReceivedMessage, 5, #19#19, true);
      ChatLineUsers[UsersCount - 1].NickName := GetParamX(sReceivedMessage, 6, #19#19, true);
      ChatLineUsers[UsersCount - 1].Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 11, #19#19, True)));
      StrList := TStringList.Create;

      TDreamChatConfig.FillMessagesState(ChatLineUsers[UsersCount - 1].MessageStatus);
{      for i := 0 to 3 do begin
        FormMain.ChatConfig.ReadSectionValues('MessagesState' + IntToStr(i), StrList);
        if StrList.Count > 0 then begin
          ChatLineUsers[UsersCount - 1].MessageStatus.Add(StrList.Strings[0]);
        end
        else
          ChatLineUsers[UsersCount - 1].MessageStatus.Add('Hi all!');
      end;}

      StrList.free;
      //ChatLineUsers[UsersCount - 1].MessageStatus.Clear;
      //ChatLineUsers[UsersCount - 1].MessageStatus.Add(GetParamX(sReceivedMessage, 8, #19#19, true));
      ChatLineUsers[UsersCount - 1].LineName := (GetParamX(sReceivedMessage, 4, #19#19, true));
      ChatLineUsers[UsersCount - 1].Version := GetParamX(sReceivedMessage, 10, #19#19, true);
      ChatLineUsers[UsersCount - 1].ReceivedMessCount := ChatLineUsers[UsersCount - 1].ReceivedMessCount + 1;
      ChatLineUsers[UsersCount - 1].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
      ChatLineUsers[UsersCount - 1].TimeInChat := GetTickCount();
      ChatLineUsers[UsersCount - 1].TimeOfLastMess := GetTickCount();
      if ChatMode = cmodTCP then ChatLineUsers[UsersCount - 1].Ip := GetParamX(ChatLineUsers[UsersCount - 1].ComputerName, 0, '/', true);
      ChatLineUsers[UsersCount - 1].ProtoName := GetParamX(sReceivedMessage, 1, #19, true);
      //}
      ChatLineUsers[UsersCount - 1].DisplayNickName := Self.GetUniqueNickName(self.ChatLineUsers[UsersCount - 1].UserID);
      //FormMain.ShowUserInTree(self, UsersCount - 1, ShowUser_ADD);
      //��������� ������ ����� � ������� ���������� ����
      if MainLine <> nil then
        begin
        //��������� ����� ��� ��� ��� ����
        MainLineUID := MainLine.GetUserIdByCompName(ChatLineUsers[UsersCount - 1].ComputerName);
        if MainLineUID <> INVALID_USER_ID then
          begin
          if MainLine.ChatLineUsers[MainLineUID].ChatLinesList.IndexOf(Self.ChatLineUsers[UsersCount - 1].LineName) < 0 then
            begin
            LineNode := TLineNode.Create(ChatLineUsers[UsersCount - 1].LineName, LS_LineObjectCreated);
            LineNode.LineName := GetParamX(sReceivedMessage, 4, #19#19, true);
            LineNode.LineType := FormMain.GetLineType(LineNode.LineName);
            if LineNode.LineType = LT_COMMON then LineNode.DisplayLineName := fmInternational.Strings[I_COMMONChat];//'�����';
            if LineNode.LineType = LT_PRIVATE_CHAT then LineNode.DisplayLineName := fmInternational.Strings[I_PRIVATE];//'������';
//            if LineNode.LineType = LT_LINE then LineNode.DisplayLineName := fmInternational.Strings[I_LINE];//'�����';
            if LineNode.LineType = LT_LINE then LineNode.DisplayLineName := LineNode.LineName;//'�����';
            LineNode.CreatedByCommand := 'Connect';
            LineNode.LineOwner := ChatLineUsers[UsersCount - 1].ComputerName;
            LineNode.LineOwnerID := UsersCount - 1;
            LineNode.LineUsers.Add(LineNode.LineOwner);
            LineNode.TimeCreate := Now();
            LineNode.TimeOfLastMess := GetTickCount();
            LineNode.LineID := MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(Self.ChatLineUsers[UsersCount - 1].LineName, LineNode);
            TDebugMan.AddLine2('����� ' + Self.ChatLineUsers[UsersCount - 1].LineName +
                                      ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
             //FormDebug.DebugMemo2.Lines.Add('����� ' + Self.ChatLineUsers[UsersCount - 1].LineName +
               //                       ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
            //FormMain.ShowLinesInTree(self, ChatLineUsers[UsersCount - 1], LineNode, ShowLine_ADD);
            end;
          end;
        end;

      //    messagebox(0, PChar(inttostr(ChatLineUsers[UsersCount - 1].UserID)), '����� ID' ,mb_ok);
      self.OnCmdConnect(self, sReceivedMessage, UsersCount - 1);
      tLocalUser := GetUserInfo(GetLocalUserId());
      if (tLocalUser <> nil) then
        if (tLocalUser.ComputerName <> ChatLineUsers[UsersCount - 1].ComputerName) then
          begin
          SendCommStatus(PChar(ChatLineUsers[UsersCount - 1].ProtoName),
                         PChar(GetParamX(sReceivedMessage, 2, #19#19, True)),
                         Ord(tLocalUser.Status),
                         PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
          SendCommBoard(PChar(ChatLineUsers[UsersCount - 1].ProtoName),
                        PChar(GetParamX(sReceivedMessage, 2, #19#19, True)), PChar(tLocalUser.MessageBoard.Text), TDreamChatConfig.GetMaxSizeOfMessBoardPart());
          end;
      end;
//����� ����������� ����������� (��� 10 ��� ��������� �� ��������)
    end
  else
    begin
    //� ��� ����� ��� ������������ ���� (������� ���)
    //messagebox(0, PChar(inttostr(id)), '� ��� ����� ��� ������������ ���� (������� ���)' ,mb_ok);
//    ChatLineUsers[id].UserID := id;
    ChatLineUsers[id].ComputerName := GetParamX(sReceivedMessage, 2, #19#19, true);
    ChatLineUsers[id].Login := GetParamX(sReceivedMessage, 5, #19#19, true);
    ChatLineUsers[id].NickName := GetParamX(sReceivedMessage, 6, #19#19, true);
    ChatLineUsers[id].Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 11, #19#19, True)));
    ChatLineUsers[id].MessageStatus.Clear;
    ChatLineUsers[id].MessageStatus.Add(GetParamX(sReceivedMessage, 8, #19#19, true));
    ChatLineUsers[id].Version := GetParamX(sReceivedMessage, 10, #19#19, true);
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeInChat := GetTickCount();
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    if ChatMode = cmodTCP then ChatLineUsers[id].Ip := GetParamX(ChatLineUsers[id].ComputerName, 0, '/', true);
    ChatLineUsers[id].DisplayNickName := Self.GetUniqueNickName(self.ChatLineUsers[id].UserID);
    ChatLineUsers[id].ProtoName := GetParamX(sReceivedMessage, 1, #19, true);

    //FormMain.ShowUserInTree(self, id, ShowUser_REDRAW);
    //��������� ������ ����� � ������� ���������� ����
    if (MainLine <> nil) and (MainLine.ChatLineUsers[id].ChatLinesList.IndexOf(GetParamX(sReceivedMessage, 4, #19#19, true)) < 0) then
      begin
      //MainLine.ChatLineUsers[id].ChatLinesList.Clear;
      LineNode := TLineNode.Create(ChatLineUsers[id].LineName, LS_LineObjectCreated);
      LineNode.LineName := GetParamX(sReceivedMessage, 4, #19#19, true);
      LineNode.LineType := FormMain.GetLineType(LineNode.LineName);
      if LineNode.LineType = LT_COMMON then LineNode.DisplayLineName := fmInternational.Strings[I_COMMONCHAT];//'�����';
      if LineNode.LineType = LT_PRIVATE_CHAT then LineNode.DisplayLineName := fmInternational.Strings[I_PRIVATE];//'������';
      if LineNode.LineType = LT_LINE then LineNode.DisplayLineName := fmInternational.Strings[I_LINE];//'�����';
      LineNode.CreatedByCommand := 'Connect';
      LineNode.LineOwner := ChatLineUsers[UsersCount - 1].ComputerName;
      LineNode.LineUsers.Add(LineNode.LineOwner);
      LineNode.TimeCreate := Now();
      LineNode.TimeOfLastMess := GetTickCount();
      MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(Self.ChatLineUsers[id].LineName, LineNode);
      MainLine.ChatLineUsers[MainLineUID].ChatLinesList.Add(Self.ChatLineUsers[id].LineName);
      TDebugMan.AddLine2('����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName); //FormDebug.DebugMemo2.Lines.Add('����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
      //FormMain.ShowLinesInTree(self, ChatLineUsers[UsersCount - 1], LineNode, ShowLine_REDRAW);
      end;

      FormMain.ShowAllUserInTree(self);
//    messagebox(0, PChar('id=' + inttostr(id)), '� ��� ����� ��� ������������ ���� (�������� ���!)' ,mb_ok);
//    self.OnCmdConnect(self, sReceivedMessage, id);
//    messagebox(0, PChar(GetParamX(sReceivedMessage, 2, #19#19, true)), '������ ������ ����� ���� � ����� �������������!' ,mb_ok);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'CREATE' then
  begin
  //!iChat!!527!!KITTY!!CREATE!!856000!!!!ANDREY!
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    //��������� CREATE ��� ����������� MainLine.MessageProtocolProcessing
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();

    //��������� ����� ������ � ������ ����� ����� �����
    MainLine := FormMain.GetMainLine();
    if MainLine <> nil then
      begin
      MainLineUID := MainLine.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
      if MainLineUID <> INVALID_USER_ID then
        begin
        //��������� ����� ��� ��� ��� ����
        //messagebox(0, PChar('MainLineUID <> INVALID_USER_ID'), '' ,mb_ok);
        if MainLine.ChatLineUsers[MainLineUID].ChatLinesList.IndexOf(GetParamX(sReceivedMessage, 4, #19#19, true)) < 0 then
          begin
          LineNode := TLineNode.Create(ChatLineUsers[id].LineName, LS_LineObjectCreated);
          LineNode.LineName := GetParamX(sReceivedMessage, 4, #19#19, true);
          LineNode.DisplayLineName := fmInternational.Strings[I_PRIVATE];//'������';
          LineNode.CreatedByCommand := 'CREATE';
          LineNode.LineOwner := ChatLineUsers[id].ComputerName;
          LineNode.LineOwnerId := id;
          LineNode.LineUsers.Add(LineNode.LineOwner);
          LineNode.TimeCreate := Now();
          LineNode.TimeOfLastMess := GetTickCount();
          LineNode.LineType := LT_PRIVATE_CHAT;
          LineNode.LineID := MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(GetParamX(sReceivedMessage, 4, #19#19, true), LineNode);
          TDebugMan.AddLine2('CREATE: ����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName); //FormDebug.DebugMemo2.Lines.Add('CREATE: ����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
          end;
        end;
      end;

    //������� ����� ������� ����
    self.OnCmdCREATE(self, sReceivedMessage, id);
    //FormMain.ShowLinesInTree(self, ChatLineUsers[id], LineNode, ShowLine_ADD);
    FormMain.ShowAllUserInTree(self);
    tLocalUser := GetUserInfo(GetLocalUserId());
    //���� ��������� ������ �� �� ���� ������, �� �������� �������
    //���������� �����, ����� �� ������� � ������ ����, ��� ��������� � ���� � �����
    //�� �� �� ���� AV
    if tLocalUser <> nil then
    begin
      //���� CREATE �� �� ����
      if (AnsiCompareText(GetParamX(sReceivedMessage, 2, #19#19, true), LocalComputerName) <> 0) then
        begin
        //����
        SendCommConnect(
                        PChar(tLocalUser.ProtoName),
                        PChar(tLocalUser.NickName),
                        PChar(LocalComputerName),
                        PChar(GetParamX(sReceivedMessage, 4, #19#19, true)),
                        PChar(LocalComputerName),
                        PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                        Ord(tLocalUser.Status));
        end;
      //���������� �����
      SendCommConnect(
                      PChar(tLocalUser.ProtoName),
                      PChar(tLocalUser.NickName),
                      PChar(GetParamX(sReceivedMessage, 2, #19#19, true)),
                      PChar(GetParamX(sReceivedMessage, 4, #19#19, true)),
                      '*',
                      PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                      Ord(tLocalUser.Status));
      end;
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
    ///SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'CREATE_LINE' then
  begin
  //iChat613192.168.1.4/ANDREY/UserCREATE_LINE����� �����192.168.1.4/ANDREY/User
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    //��������� CREATE ��� ����������� MainLine.MessageProtocolProcessing
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();

    //��������� ����� ����� � ������ ����� ����� �����
    MainLine := FormMain.GetMainLine();
    if MainLine <> nil then
      begin
      MainLineUID := MainLine.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
      if MainLineUID <> INVALID_USER_ID then
        begin
        //��������� ����� ��� ��� ��� ����
        //messagebox(0, PChar('MainLineUID <> INVALID_USER_ID'), '' ,mb_ok);
        if MainLine.ChatLineUsers[MainLineUID].ChatLinesList.IndexOf(GetParamX(sReceivedMessage, 4, #19#19, true)) < 0 then
          begin
          LineNode := TLineNode.Create(ChatLineUsers[id].LineName, LS_LineObjectCreated);
          LineNode.LineName := GetParamX(sReceivedMessage, 4, #19#19, true);
          LineNode.DisplayLineName := LineNode.LineName;
          LineNode.CreatedByCommand := 'CREATE_LINE';
          LineNode.LineOwner := ChatLineUsers[id].ComputerName;
          LineNode.LineOwnerId := id;
          LineNode.LineUsers.Add(LineNode.LineOwner);
          LineNode.TimeCreate := Now();
          LineNode.TimeOfLastMess := GetTickCount();
          LineNode.LineType := LT_LINE;
          LineNode.LineID := MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(GetParamX(sReceivedMessage, 4, #19#19, true), LineNode);
          TDebugMan.AddLine2('CREATE_LINE: ����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName); //FormDebug.DebugMemo2.Lines.Add('CREATE_LINE: ����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
          //FormMain.ShowLinesInTree(MainLine, ChatLineUsers[id], LineNode, ShowLine_ADD);
          FormMain.ShowAllUserInTree(self);
          if PlaySounds then
            SoundOnCommCreate(integer(MainLine.LineType), PChar(sReceivedMessage), PChar(ChatLineUsers[id].SoundCreate), id);
          end;
        end;
      end;

    if ChatLineUsers[id].ComputerName <> LocalComputerName then
      begin
      //self.OnCmdCREATELINE(self, sReceivedMessage, id);
      end
    else
      begin
      //���� ��������� ������ �� ������ ����
      //������� �����
      self.OnCmdCREATELINE(self, sReceivedMessage, id);
      FormMain.ShowAllUserInTree(MainLine);
      tLocalUser := GetUserInfo(GetLocalUserId());
      if tLocalUser <> nil then
      begin
        //���� CREATE �� ����
        if (AnsiCompareText(GetParamX(sReceivedMessage, 2, #19#19, true), LocalComputerName) <> 0) then
          begin
          //����
          SendCommConnect(
                          PChar(tLocalUser.ProtoName),
                          PChar(tLocalUser.NickName),
                          PChar(LocalComputerName),
                          PChar(GetParamX(sReceivedMessage, 4, #19#19, true)),
                          PChar(LocalComputerName),
                          PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                          Ord(tLocalUser.Status));
          end;
        {//���������� �����
        SendCommConnect(PChar(tLocalUser.NickName),
                        PChar(GetParamX(sReceivedMessage, 2, #19#19, true)),
                        PChar(GetParamX(sReceivedMessage, 4, #19#19, true)),
                        '*',
                        PChar(tLocalUser.MessageStatus.Strings[tLocalUser.Status]),
                        tLocalUser.Status);
        }
        end;
      end;
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
    ///SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'TEXT' then
  begin
  //iChat110ANDREYTEXTgsMTCI hiYT
  //������� ������� TEXT
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     GetParamX(sReceivedMessage, 6, #19#19, true),
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdText(self, sReceivedMessage, id);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'REFRESH' then
  begin
  //iChat137ANDREYREFRESHiTCniaMAdminsAndrey�����������!*1.21b63
  //������� ������� REFRESH
  //��������� ����� � ������ ����� �����
  MainLine := FormMain.GetMainLine();
  if MainLine <> nil then
    begin
    MainLineUID := MainLine.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
    if MainLineUID <> INVALID_USER_ID then
      begin
      //��������� ����� ��� ��� ��� ����
      //messagebox(0, PChar('MainLineUID <> INVALID_USER_ID'), '' ,mb_ok);
      s := GetParamX(sReceivedMessage, 4, #19#19, true);
      //��-�� �������������� ��������� ��� ���� ���������� ����������
      //REFRESH ������ �� ����� ��� �� �������
      //����� ������� ��� ���� �������� ����� ������ �� ���� �� ��� ������
      //� ���� ������ ��� ���� ����� �� TLineNode.Create() �� �����!
      For c := 1 to length(s) do
        begin
        if not (s[c] in ['0'..'9']) then
          begin
          i := 0;
          break;
          end
        else
          begin
          i := 1;
          end;
        end;
//      if i = 1 then s := '*';//���������� �������� �������� �����, ����� �� ��������� ���
      if (AnsiCompareText(s, '*') <> 0) and
         (MainLine.ChatLineUsers[MainLineUID].ChatLinesList.IndexOf(s) < 0) then
        begin
        LineNode := TLineNode.Create(MainLine.ChatLineUsers[MainLineUID].LineName, LS_LineObjectCreated);
        LineNode.LineName := s;
        if i = 1 then
          begin
          LineNode.DisplayLineName := fmInternational.Strings[I_PRIVATE] + ' (?)';
          LineNode.LineType := LT_PRIVATE_CHAT;
          end
        else
          begin
          LineNode.DisplayLineName := LineNode.LineName;
          LineNode.LineType := LT_LINE;
          end;
        LineNode.CreatedByCommand := 'REFRESH';
        LineNode.LineOwner := MainLine.ChatLineUsers[MainLineUID].ComputerName;
        LineNode.LineOwnerID := MainLineUID;
        LineNode.LineUsers.Add(LineNode.LineOwner);
        LineNode.TimeCreate := Now();
        LineNode.TimeOfLastMess := GetTickCount();
        LineNode.LineID := MainLine.ChatLineUsers[MainLineUID].ChatLinesList.AddObject(s, LineNode);
        TDebugMan.AddLine2('����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName); //FormDebug.DebugMemo2.Lines.Add('����� ' + LineNode.LineName + ' ��������� � ������ ����� ' + MainLine.ChatLineUsers[MainLineUID].ComputerName);
        //FormMain.ShowUserInTree(MainLine, MainLineUID, ShowUser_REDRAW);
        //FormMain.ShowLinesInTree(MainLine, MainLine.ChatLineUsers[MainLineUID], LineNode, ShowLine_ADD);
        if PlaySounds then
          SoundOnCommFindLine(integer(MainLine.LineType), PChar(sReceivedMessage), PChar(MainLine.ChatLineUsers[MainLineUID].SoundFindLine), MainLineUID);
        FormMain.ShowAllUserInTree(MainLine);
        end
      else
        begin
        //FormMain.ShowUserInTree(MainLine, MainLineUID, ShowUser_REDRAW);
        end;
      end;
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
    TDebugMan.AddLine2('!!!! <-- ' + sReceivedMessage); //FormDebug.DebugMemo2.Lines.Add('!!!! <-- ' + sReceivedMessage);
    SendDisconnectConnect(sReceivedMessage);
    end;

  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    //ChatLineUsers[id].LastReceivedMessNumber := strtointE(GetParamX(sReceivedMessage, 1, #19#19, true));
    //������ ��������, ��� ��� ��������� ��� ���� ���� �� ������� ��� ���������
    //� OnCmdREFRESH()
    ChatLineUsers[id].TimeLastUpdate := GetTickCount();
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    ChatLineUsers[id].Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 11, #19#19, True)));
    self.OnCmdREFRESH(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
      TDebugMan.AddLine2('!!!! <-- ' + sReceivedMessage); //FormDebug.DebugMemo2.Lines.Add('!!!! <-- ' + sReceivedMessage);
      SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'RENAME' then
  begin
  //������� ������� RENAME
  //iChat287KITTYRENAMEnewnikKITTY
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeLastUpdate := GetTickCount();
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdRENAME(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'RECEIVED' then
  begin
  //iChat47DIMARECEIVEDgsMTCI. ���� ���.
  //������� ������� RECEIVED
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdRECEIVED(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'BOARD' then
  begin
  //iChat85192.168.0.5/HOME-3EGDLXBNPB/slavaBOARD0
  //������� ������� BOARD
  id := self.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    //��������!!! ��������� ����� ���� �� ���������� ������!
    DoUpdate := false;
    MessBoardNumber := StrToIntE(GetParamX(sReceivedMessage, 4, #19#19, true));
    if (length(GetParamX(sReceivedMessage, 5, #19#19, true)) > 0) then
      begin
      //���� � ����� ����� ���-�� ������
      if (MessBoardNumber = 0) then
        begin
        //� ��������� ������ ���� �����
        {ChatLineUsers[id].MessageBoard.Clear;
        s := GetParamX(sReceivedMessage, 5, #19#19, true);
        MessageBox(0, Pchar(inttostr(byte(s[length(s)- 1])) +
                            inttostr(byte(s[length(s)]))
                            ), '', mb_ok);}
        ChatLineUsers[id].MessageBoard.Clear;
        ChatLineUsers[id].MessageBoard.Text := GetParamX(sReceivedMessage, 5, #19#19, true);
        end
      else
        begin
        //� ��������� ��������� ������
        ChatLineUsers[id].MessageBoard.Text := copy(ChatLineUsers[id].MessageBoard.Text, 0, Length(ChatLineUsers[id].MessageBoard.Text) - 2) + (GetParamX(sReceivedMessage, 5, #19#19, true));
        end;
      ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
      ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
      end
    else
      begin
      //� ����� ������ �� ������! ������, ���� � ����� ����� ������, �� ����,
      //����� ��� ���������� ��� ���� ������
      if Length(ChatLineUsers[id].MessageBoard.Text) > 0 then
        begin
        DoUpdate := True;
        TDebugMan.AddLine1('�������� �����!'); //FormDebug.DebugMemo1.Lines.Add('�������� �����!');
        ChatLineUsers[id].MessageBoard.Clear;
        end;
      end;
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    //MessageBox(0, Pchar(inttostr(id)), 'OnCmdBOARD', mb_ok);
    self.OnCmdBOARD(self, sReceivedMessage, id, DoUpdate);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'STATUS' then
  begin
  //iChat22ANDREYSTATUS0�����������!
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 4, #19#19, True)));
    while Ord(ChatLineUsers[id].Status) >= ChatLineUsers[id].MessageStatus.Count do
      begin
      ChatLineUsers[id].MessageStatus.Add('');
      end;
    ChatLineUsers[id].MessageStatus.Strings[Ord(ChatLineUsers[id].Status)] := GetParamX(sReceivedMessage, 5, #19#19, True);
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, True));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdSTATUS(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'REFRESH_BOARD' then
  begin
  //iChat%d192.168.1.4/ANDREY/UserREFRESH_BOARD
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdREFRESH_BOARD(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'STATUS_REQ' then
  begin
  //iChat418SATANASTATUS_REQ
  id := GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if id <> INVALID_USER_ID then
    begin
    ChatLineUsers[id].ReceivedMessCount := ChatLineUsers[id].ReceivedMessCount + 1;
    ChatLineUsers[id].LastReceivedMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    ChatLineUsers[id].TimeOfLastMess := GetTickCount();
    self.OnCmdSTATUS_REQ(self, sReceivedMessage, id);
    end
  else
    begin
    //���� ������������, �.�. ��� ��������� ������ �� �� ����������������� �����
//    SendDisconnectConnect(sReceivedMessage);
    end;
  end;

if GetParamX(sReceivedMessage, 3, #19#19, true) = 'DISCONNECT' then
  begin
  // iChat  1  ANDREY  DISCONNECT  iTCniaM 
  //�������� id �������� �����
  id := self.GetUserIdByCompName(GetParamX(sReceivedMessage, 2, #19#19, true));
  //id := GetUserIdByCompNameAndNickName(GetParamX(sReceivedMessage, 2, #19#19, true),
  //                                     '',
  //                                     StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true)));
  if (Self.ChatLineName = TDreamChatDefaults.MainChatLineName {'iTCniaM'}) and (id = Self.GetLocalUserId()) and
    (Closing <> true) and (Initing <> true) then
    begin
    //��� ��� � ���? �������� ���� �� ����������, ������ ������������� ���������,
    //������ ������ ������� �� ���������� ���������� ������������ �� ������� �����!
    //���-�� ��� ������!!!!
    TDebugMan.AddLine2('��������! ���-�� �������� ������ ���������� ������������ �� ���� �������� ''DISCONNECT''!'); //FormDebug.DebugMemo2.Lines.Add('��������! ���-�� �������� ������ ���������� ������������ �� ���� �������� ''DISCONNECT''!');
    id := INVALID_USER_ID;
    end;
  if Initing = true then Initing := false;//������������� ���������
  if (id <> INVALID_USER_ID) then
    begin
    //����� ��� ��������� �����, ����� ������ ����� ��������...
    //� ��� /close ������� ���� � ITCIAM
    MainLine := FormMain.GetMainLine();
    if MainLine <> nil then
      //���������� ������ �c��� :-))
      begin
      if (self.ChatLineName <> TDreamChatDefaults.MainChatLineName {'iTCniaM'}) or
        (
        (self.ChatLineName = TDreamChatDefaults.MainChatLineName {'iTCniaM'}) and
        (GetParamX(sReceivedMessage, 4, #19#19, True) <> TDreamChatDefaults.MainChatLineName {'iTCniaM'})
        ) then
        //�������� 2� ������:
        //1. ���� ��� ��� ����� �� ������� ���� ��� ����� (�.�. ��������� ������ ��
        //� ������� �����)
        //2. ���� � ��� ������ ������, ������-����� ����� ������� ���� ����������,
        //� 2� �������� ������� ����� ��� ������� ����� 5 ���, �� ��� ���������
        //DISCONNECT ��� �� ������������ ����� ��������� � 'iTCniaM'.
        //� ���� ������ ��� ������ ����� ������ ������ ����� � ����� ����� � ������.
        begin
        //�� ������� ��� �����/��� �� ������ ����� ����� �����
        //�������� ID ����� ����� � ������� ����� (� ������� � ����� ������ ID)
        //������...
        MainLineUId := MainLine.GetUserIdByCompName(self.ChatLineUsers[id].ComputerName);
        if MainLineUId <> INVALID_USER_ID then
          begin
          //c := MainLine.ChatLineUsers[MainLineUId].ChatLinesList.IndexOf(��� ������! self.ChatLineName);
          TDebugMan.AddLine2('���� ����� ' + GetParamX(sReceivedMessage, 4, #19#19, true) + ' ������� ������� ���� ' + self.ChatLineUsers[id].DisplayNickName + ' � ��� ������ �����...'); //FormDebug.DebugMemo2.Lines.Add('���� ����� ' + GetParamX(sReceivedMessage, 4, #19#19, true) + ' ������� ������� ���� ' + self.ChatLineUsers[id].DisplayNickName + ' � ��� ������ �����...');
          if MainLine.ChatLineUsers[MainLineUId].ChatLinesList.Count > 0 then
            begin
            i := MainLine.ChatLineUsers[MainLineUId].ChatLinesList.IndexOf(GetParamX(sReceivedMessage, 4, #19#19, true));
            if i >= 0 then
              begin
              if MainLine.ChatLineUsers[MainLineUId].ChatLinesList.Objects[i] <> nil then
                begin
                //FormMain.ShowLinesInTree(MainLine, MainLine.ChatLineUsers[MainLineUId],
                //                      TLineNode(MainLine.ChatLineUsers[MainLineUId].ChatLinesList.objects[i]),
                //                      ShowLine_DELETE);//��������� �� ����, ���������� � OnCmdDisconnect()
                MainLine.ChatLineUsers[MainLineUId].ChatLinesList.Objects[i].free;
                end;
              MainLine.ChatLineUsers[MainLineUId].ChatLinesList.Delete(i);
              //���� ����� ����-����� � ����� ������������ � ������ � ���� ��
              //�������� ��������� �� LineNode � PDNode.
              {��� ��������� ������ ���� � ���������� ����, ����� ������ �����
              �������������� �� ������ ����, � �� ������� ��� ������
              While ����������� ���� ������� ���� ����
              PDNode := Line.ChatLineTree.GetNodeData(VirtualNode);
              }
              FormMain.ShowAllUserInTree(MainLine);
              TDebugMan.AddLine2('����� ���� ������� �� ��� LinesList.'); //FormDebug.DebugMemo2.Lines.Add('����� ���� ������� �� ��� LinesList.');
              end
            else
              begin
              TDebugMan.AddLine2('����� �� �������.'); //FormDebug.DebugMemo2.Lines.Add('����� �� �������.');
              end;
            end
          else
            begin
            TDebugMan.AddLine2('� ������������ ��� �����.'); //FormDebug.DebugMemo2.Lines.Add('� ������������ ��� �����.');
            end;
          end;
        end;
      end;

    //���� ���� ���� ��� ������� ��������� - ������� �������
    i := UserListCNS_Private.IndexOf(ChatLineUsers[id].ComputerName);
    if i >= 0 then UserListCNS_Private.Delete(i);
    i := UserListCNS_Personal.IndexOf(ChatLineUsers[id].ComputerName);
    if i >= 0 then UserListCNS_Personal.Delete(i);

    if (AnsiCompareText(self.ChatLineName, GetParamX(sReceivedMessage, 4, #19#19, true)) = 0) then
      begin
      FormMain.ParseAllChatView(fmInternational.Strings[I_USERDISCONNECTED] + ' ' + ChatLineUsers[id].DisplayNickName +
                             ' [' + GetParamX(sReceivedMessage, 2, #19#19, true) +']',
                             self, FormMain.CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE],
                             nil, nil, false, true);
      //FormMain.ShowUserInTree(self, id, ShowUser_DELETE);
      //FormMain.ShowAllUserInTree(self);
      //MessageBox(0, PChar(''), PChar(inttostr(id)) ,mb_ok);
      if id = UsersCount - 1 then
        begin
        //���� ���� ����� ��������� ����� � �������, �� ������� ������� �� ����!
        //������ ��� �������!
        //messagebox(0, PChar(inttostr(id)), ' ����' ,mb_ok);
        if PlaySounds then
          SoundOnCommDisconnect(integer(Self.LineType), PChar(sReceivedMessage), PChar(ChatLineUsers[id].SoundDisconnect), ID);
        TChatUser(ChatLineUsers[id]).Free;
       // UsersCount := UsersCount - 1;
        SetLength(ChatLineUsers, UsersCount - 1);
        end
      else
        begin
        //����� ����� �� ���������! �� ��� ���� ��� �����!
        //����������� ���������� ����� �� �������������� �����
        //messagebox(0, PChar(inttostr(UsersCount - 1) + ' => ' + inttostr(id)), '����������� ���������� ����� �� �������������� �����' ,mb_ok);
        if PlaySounds then
          SoundOnCommDisconnect(integer(Self.LineType), PChar(sReceivedMessage), PChar(ChatLineUsers[id].SoundDisconnect), ID);
        TChatUser(ChatLineUsers[id]).Free;
        //ChatLineUsers[id].Assign(ChatLineUsers[UsersCount - 1]);//UsersCount - 1 => id
        ChatLineUsers[id] := ChatLineUsers[UsersCount - 1];//UsersCount - 1 => id

//        ChatLineUsers[id].UserID := id;//�� �������� ������� �����, ��� � ���� ��������� id!!!
        self.FChatLineTree.FocusedNode := ChatLineUsers[id].VirtualNode;
        PDNode := self.ChatLineTree.GetNodeData(ChatLineUsers[id].VirtualNode);
        //TChatUser(ChatLineUsers[UsersCount - 1]).Free;//���� id, � ����� UsersCount - 1 �������
       // UsersCount := UsersCount - 1;
        SetLength(ChatLineUsers, UsersCount - 1);
        //messagebox(0, PChar(inttostr(UsersCount)), '���� ����������, ����� ������:' ,mb_ok);

        //�������� �� ���� ���� ��� � "����������� ������" � ����� ����������� ����
        //������, ����� ������� �� �� �����
        for c := 0 to self.UsersCount - 1 do
          begin
          if AnsiCompareText(self.ChatLineUsers[c].DisplayNickName, self.ChatLineUsers[c].NickName) <> 0 then
            self.ChatLineUsers[c].DisplayNickName := Self.GetUniqueNickName(self.ChatLineUsers[c].UserID);
          end;
        //FormMain.ShowAllUserInTree(Self);//��������� �� ����, ���������� � OnCmdDisconnect()
        //FormMain.ShowAllUserInTree(FormMain.GetMainLine);//��������� �� ����, ���������� � OnCmdDisconnect()
        end;
      //��������! ���������� id ��� �� ������������� �����!
      //�� ����� id ��� ����� ��� ��� ������ ���� ��� �������!
      end;

    //���� ����� �� ��������, �� ����� ���� ������������ � ����������� OnCmdDisconnect()
    self.OnCmdDisconnect(self, sReceivedMessage, INVALID_USER_ID{id});
    end;
  end;
END;

end.
