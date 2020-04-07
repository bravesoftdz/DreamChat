//������������������� �������, ��� ��, ��:
//-���� �� ������ �� ������ ��������. � �� ������ � ���� ���� ������ ����� �����.
//-�������� ���� ����� � ������

//- ��� ������ ChatLineTree.Free; �� ���������� ������ ChatLineTree.Destroy!!!!!
//- ���� ��������� ���� ������, ��� ���������� ��������!

unit uFormMain;
{$DEFINE Release}
//�������� FormDebug ��� �������

{$IFDEF Release}
{$ELSE}
  {$DEFINE AdminRel}
  //Not for Public release!
  //��� ����� ��������� ������������ ��������� /msgfile ��� ��������
  //����������� ��������� ������ ����� ��������� ���������
  //����� ��� ����, ��� ��� ������ ���� � ������������ �������� ���������
  //� ����� ����� �� ��������!
{$ENDIF Release}

interface

//PROCEDURE <- ��� ������������ ��������������� ���������, ������� ��������� �
//procedure <- ��� ������������ ���������, ������� ���������� � �����������

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  sSkinManager, sSkinProvider, CVStyle, Buttons, sSpeedButton, CVScroll,
  ChatView, sChatView, ComCtrls, sPageControl, StdCtrls, sMemo, sEdit,
  ExtCtrls, sSplitter, sPanel, ImgList, Menus, ToolWin, Inifiles,
  DCPcrypt2, DCPrc4, JwaWinType, RXShell, VirtualTrees, VTHeaderPopup,
  litegifX2, uChatUser, uChatLine, uGifVirtualStringTree, ShellAPI,
  uLineNode, uVTHeaderPopupMenu, uFormPassword, uFormPopUpMessage,
  uCommLine, uFormUserInfo, uFormAbout, uSettings, uBMPtoICO,
  sButton, sDialogs, DreamChatConsts,
  sHintManager, uFormSmiles
  {$IFDEF USELOG4D}, log4d {$ENDIF USELOG4D}
  ;

const
  UM_INCOMMINGMESSAGE = WM_USER + 1;
  UM_CALLBACKFUNCTION = WM_USER + 2;

  UM_INCOMMINGMESSAGE_ReDrawAll = 1;
  UM_INCOMMINGMESSAGE_UpdateTree = 2;
//  UM_INCOMMINGMESSAGE_CallBackFunction = 3;

  INVALID_USER_ID = CARDINAL($FFFFFFFF);
//  ALL_USERS = INVALID_USER_ID;
  NORMALTEXTSTYLE = 0;
  SYSTEMTEXTSTYLE = 1;
  PRIVATETEXTSTYLE = 2;
  BOARDTEXTSTYLE = 3;
  LINKTEXTSTYLE = 4;
  ONLINKTEXTSTYLE = 5;
  INFONAMESTYLE = 6;
  INFOTEXTSTYLE = 7;
  METEXTSTYLE = 8;
  USEROFFLINENICKSTYLE = 9;

  EngToRus = 0;
  RusToEng = 1;
  VERSION = 'D0.99';
  CAPTIONVERSION = 'Dream Chat 0.999';

//------------------- International captions -----------------------------------
  IE_ERROR     = 0;//��������� ������
  IE_ATWORK    = 1;//��� ���������� �������:
  IE_JOBFAILED = 2;//������� �� ��������� � ������� �� �������.

//[Form]
  I_COMMONCHAT          = 0;//'�����'
  I_PRIVATE             = 1;//'������'
  I_LINE                = 2;//'�����'
  I_MESSAGESBOARD       = 3;//����� ����������
  I_MESSAGESBOARDUPDATE = 4;//��������� ����� ����������
  I_USERCONNECTED       = 5;//� ��� ��������:
  I_USERDISCONNECTED    = 6;//��� ������� :
  I_NOTANSWERING        = 7;
  I_PRIVATEWITH         = 8;//������ ��� �
  I_USERRENAME          = 9;//�������� ��� ��
//[PopUpMenu]
  I_CLOSE               = 10;//�������
  I_REFRESH             = 11;//��������
  I_SAVELOG             = 12;//��������� ���
  I_PRIVATEMESSAGE      = 13;//������ ���������
  I_PRIVATEMESSAGETOALL = 14;//������ ��������� ����
  I_CREATELINE          = 15;//������� �����
  I_TOTALIGNOR          = 16;//������������ ��� ���������
  I_USERINFO            = 17;//� ������������
  I_COMETOPRIVATE       = 18;//����� � ������
  I_COMETOLINE          = 19;//����� � �����
//[UserInfo]
  I_DisplayNickName     = 20;
  I_NickName            = 21;
  I_IP                  = 22;
  I_ComputerName        = 23;
  I_Login               = 24;
  I_ChatVer             = 25;
  I_CommDllVer          = 26;
  I_STATE               = 27;
//[NewLine]
  I_INPUTPASSWORD       = 28;
  I_COMING              = 29;//�����
  I_INPUTPASSANDLINENAME = 30;//������� �������� � ������ ��� ����� �����:
  I_CREATE              = 31;
  I_NEWLINE             = 32;
  I_CANCEL              = 33;
  I_LINENAME            = 34;
  I_PASSWORD            = 35;
//[MainPopUpMenu]
  I_EXIT                = 36;

  I_SEESHARE            = 37;//������� � �������� ����������
  I_WRITENICKNAME       = 38;//�������� ��� �����

  MAX_MESSAGE_SIZE = 1500; //size of the buffer for received messages, represents max mess size

//------------------- /\ International captions /\ -----------------------------


{type
  TShowUserAction = (ShowUser_ADD, ShowUser_REDRAW, ShowUser_DELETE);
type
  TShowLineAction = (ShowLine_ADD, ShowLine_REDRAW, ShowLine_DELETE);}
type
  TChatMode = (cmodMailSlot, cmodTCP);

type
  TLinkType = (ltHTTP, ltNICK);

//type
//  TMainThread = class(TThread)
//  private
//    { Private declarations }
//  protected
//    procedure Execute; override;
//  end;

type
  TFormMain = class(TForm)
    Panel1: TsPanel;
    Panel2: TsPanel;
    Panel3: TsPanel;
    Edit1: TsEdit;
    PageControl1: TsPageControl;
    TabSheet2: TsTabSheet;
    CVStyle1: TCVStyle;
    ClearButton: TsSpeedButton;
    RefreshButton: TsSpeedButton;
    SpeedButton3: TsSpeedButton;
    SpeedButton4: TsSpeedButton;
    SpeedButton5: TsSpeedButton;
    SpeedButton6: TsSpeedButton;
    SpeedButton7: TsSpeedButton;
    SpeedButton8: TsSpeedButton;
    SpeedButton9: TsSpeedButton;
    SpeedButton10: TsSpeedButton;
    Memo1: TsMemo;
    Panel4: TsPanel;
    Splitter1: TsSplitter;
    sSkinProvider1: TsSkinProvider;
    SkinManMain: TsSkinManager;
    sChatView2: TsChatView;
    MainLoopTimer: TTimer;
    sHintManager1: TsHintManager;
    PROCEDURE WndProc(var Msg: TMessage); override;
    PROCEDURE WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
//    PROCEDURE ProcIdleHandler(Sender: TObject; var Done: Boolean);
    PROCEDURE MainLoop();
    PROCEDURE ProcessException(Sender: TObject; E: Exception);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    PROCEDURE ShowAllUserInTree(Line:TChatLine);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton7Click(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Splitter1Moved(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl1CloseBtnClick(Sender: TComponent;
      TabIndex: Integer; var CanClose: Boolean;
      var Action: TacCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MainLoopTimerTimer(Sender: TObject);
  private
    { Private declarations }
    ErrorLog: TStringList;
    BeforeAutoAwayStatus: TDreamChatStatus;//���������� ������ ����� ���������� �� N|A
    AutoAwayStatus: boolean;//��������������� ���� ��� ��� ������ ������
    MBSmilesName : TStringList;
    TimerRefreshAllMessageBoard:TTimer;
    TimerJob:TTimer;
    SmilesGIFImages: array of TGif;
    RxTrayIcon: TRxTrayIcon;
    JobMessAndTimeDelimiter: string;
    LinksKeyWordList: TStringList;
    JobsList: TStringList;
    Direct: byte;
    MaxDxEng, MaxDxRus: word;
    FDictionaryRus, FDictionaryEng: TStringList;
//    SendMessCount, readCount, nMaxMessSize: cardinal;
    {MaxMessBoardPart,} MessCount{, UsersCount}: cardinal;
    SmilesCount: word;
    MaxSmileLen: integer;//������������ ����� ������ � ��������
    TempEdit1Height: integer;//��� �����! �� �� ����� Edit1 ��� ������ ����������� ���� ������...
      //ShiftKey, CtrlKey, AltKey
    CtrlKey: boolean;//������ �� ��� �������?
    ExceptSymbols: string;
      //���� ��� DLL � ������������ ����������� ������� ����� ��� ������ �������,
    //� ����� ���������, ���� ������ � ��������� ������.
    CommunicationLibHandle: HMODULE;
//    SettingsLibHandle     : HMODULE;
    AFormSmiles: TFormSmiles;
    procedure SaveSkinParameters;
    procedure InitializeTrayIcon;
  public
    { Public declarations }
    //ChatConfig                          : TMemIniFile;
    DefaultUser: TMemIniFile;
    FSettings: TFSettings;
    //SysTrayPopUpMenuGifImages           : array [0..1] of TGIF;

    PROCEDURE Debug(Mess, Mess2: String);
    PROCEDURE LoadComponents(Sender: TObject);
    FUNCTION  Init(Sender: TObject):string;
    PROCEDURE ChangeLang(LangFile:string);
    procedure OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��������� ����� �� ��v���
    procedure OnLinkMouseUpProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��������� ����� �� ��v���
    procedure RxTrayIconOnClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonOnClick(Sender: TObject);
    procedure ApplicationMinimize(Sender: TObject);
    procedure ApplicationRestore(Sender: TObject);
    PROCEDURE About(Sender: TObject);
    PROCEDURE PluginMessageProcessing(var Message: TMessage); message UM_INCOMMINGMESSAGE;
    PROCEDURE ProcessCallBackFunction(var Message: TMessage); message UM_CALLBACKFUNCTION;
    PROCEDURE ReadLocalUserInfoFromIni(LocalUserId:cardinal);
    //*streaming* PROCEDURE StringToComponent(Component: TComponent; Value: string);
    //*streaming* FUNCTION ComponentToString(Component: TComponent): string;
    PROCEDURE RefreshAllMessageBoard(Sender: TObject);
    PROCEDURE Sheduller(Sender: TObject);
    procedure OnCmdConnect(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdDisconnect(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdText(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdRefresh(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdReceived(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdRename(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdBoard(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal;DoUpdate:Boolean);
    procedure OnCmdStatus(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdStatus_Req(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdRefresh_Board(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdCREATE(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    procedure OnCmdCREATELINE(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
    FUNCTION GetLineType(LineName:string):TLineType;
    FUNCTION GetActiveChatLine():TChatLine;
    FUNCTION GetChatLineByName(LineName:string):TChatLine;
    FUNCTION GetChatLineByDisplayLineName(DisplayLineName:string):TChatLine;
    FUNCTION GetChatLineById(LineId:cardinal):TChatLine;
    FUNCTION GetMainLine():TChatLine;
    function GetDictionaryEng: TStringList;
    function GetDictionaryRus: TStringList;
//    FUNCTION ParseControl(SourceControlString: String; ChatLine: TChatLine; Style:integer): boolean;
//    FUNCTION ParseNick(SourceSmilesString: String; ChatLine: TChatLine; Style: TFontInfo; tLink: TLinkInfo; FromNewLine: boolean): boolean;
    FUNCTION ParseBoard(SourceSmilesString: String; ChatView: TsChatView; Style: TFontInfo; tLink: TLinkInfo): boolean;
//    FUNCTION ParseAll(SourceSmilesString: String; ChatLine: TChatLine; Style: TFontInfo; FromNewLine: boolean): boolean;
    FUNCTION ParseAllChatView(SourceSmilesString: String; ChatLine: TChatLine;
                              Style: TFontInfo; tLink: TLinkInfo;
                              ChatView_IfNotChatLine: TsChatView;
                              ShowTime, FromNewLine: Boolean): boolean;
    FUNCTION ParseSmile(SourceSmilesString: String; ChatLine: TChatLine; Style: TFontInfo; tLink: TLinkInfo; ChatView_IfNotChatLine: TsChatView): boolean;
    //roma FUNCTION GetParam(SourceString: String; ParamNumber: Integer; Separator: String): String;
    //roma FUNCTION GetParamX(SourceString: String; ParamNumber: Integer; Separator: String; HideSingleSeparaterError:boolean): String;
    FUNCTION GetDelimitersCount(SourceString: String; Separator: String): Integer;
    FUNCTION MultiTranslate(SourceString: String;Direct:byte): string;

    property DictionaryRus: TStringList read GetDictionaryRus;
    property DictionaryEng: TStringList read GetDictionaryEng;
  end;

  FUNCTION CallBackFunction(Buffer:Pchar; Destination:cardinal):PChar;
  FUNCTION MySort(List: TStringList; Index1, Index2: Integer): Integer;forward;

type
  TCallBackMessageData = class
  private
    FBuffer: PChar;
    FDestination: cardinal;
  public
    constructor Create(buffer:PChar; Destination:cardinal);
    destructor Destroy;override;
    property Buffer: PChar read FBuffer;
    property Destination: cardinal read FDestination;
  end;

  {----------------------------- MSKRNL ----------------------------}
//'../../Kernel/MSkrnl/28/mskrnl.dll'
type
  {----------------------------- Communications ----------------------------}
  TCommunicationInit = function (ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar):PChar;
  TCommunicationShutDown = function ():PChar;
  TSendCommDisconnect = function (
                                  pProtoName, pNameOfLocalComputer,
                                  pNameOfRemoteComputer, pLineName:PChar):Pchar;
  TSendCommConnect = function (
                               pProtoName, pLocalNickName, pNetbiosNameOfRemoteComputer,
                               pLineName,pNameOfRemoteComputer,
                               pMessageStatusX:PChar; Status:Byte):Pchar;
  TSendCommText = function (pProtoName, pNameOfRemoteComputer:PChar;pNickNameOfRemoteComputer:PChar;MessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
  TSendCommReceived = function (pProtoName, pNameOfRemoteComputer:PChar;MessAboutReceived:PChar):Pchar;
  TSendCommStatus = function (pProtoName, pNameOfRemoteComputer:PChar;LocalUserStatus:cardinal;StatusMessage:Pchar):Pchar;
  TSendCommBoard = function (pProtoName, pNameOfRemoteComputer:PChar;pMessageBoard:Pchar;MaxSizeOfPart:cardinal):Pchar;
  TSendCommRefresh = function (pProtoName, pNameOfRemoteComputer, pLineName, pLocalNickName:Pchar;LocalUserStatus:cardinal;pAwayMess:Pchar;pReceiver:Pchar;Increment:integer):Pchar;
  TSendCommRename = function (pProtoName, pNameOfRemoteComputer:Pchar;pNewNickNameMess:Pchar):Pchar;
  TSetVersion = function (Version:PChar):PChar;
  TGetIncomingMessageCount = function ():cardinal;
  TGetNextIncomingMessage = function (BufferForMessage:Pointer; BufferSize:cardinal):cardinal;
  TSendCommCreate = function (pProtoName, pNameOfRemoteComputer, pPrivateChatLineName:Pchar):Pchar;
  TGetIP = function ():PChar;
  TSendCommCreateLine = function (pProtoName, pNameOfRemoteComputer, pPrivateChatLineName, pPassword:Pchar):Pchar;
  TSendCommStatus_Req = function (pProtoName, pNetbiosNameOfRemoteComputer:PChar):Pchar;
  TSendCommMe = function (pProtoName, pNameOfRemoteComputer:PChar;pNickNameOfRemoteComputer:PChar;MessageText:PChar; ChatLine:Pchar;Increment:integer):Pchar;
  TSendCommRefresh_Board = function (pProtoName, pNetbiosNameOfRemoteComputer: PChar; Increment:integer):Pchar;
  TGetLocalUserLoginName = function (OverrideLoginName: PChar):PChar;
  TSetNewCryptoKey = function (pSecretKey: Pointer; SizeSecretKey: word):PChar;
  {----------------------------- Settings ----------------------------}

  {----------------------------- EVENTS ----------------------------}
  function SoundInit(AdressCallBackFunction:Pointer; Path:PChar):PChar;external 'events.dll' name 'EvInit';
  function SoundShutDown():PChar;external 'events.dll' name 'EvShutDown';
  function SoundOnCommDisconnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommDisconnect';
  function SoundOnCommConnect(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommConnect';
  function SoundOnCommText(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommText';
  function SoundOnCommReceived(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommReceived';
  function SoundOnCommStatus(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommStatus';
  function SoundOnCommBoard(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommBoard';
  function SoundOnCommRefresh(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommRefresh';
  function SoundOnCommRename(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommRename';
  function SoundOnCommCreate(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommCreate';
  function SoundOnCommAlert(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommAlert';
  function SoundOnCommAlertToAll(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommAlertToAll';
  function SoundOnCommFindLine(LineType: integer; pReceivedMessage, PlayFile: PChar; UserID:cardinal):PChar;external 'events.dll' name 'EvOnCommFindLine';

var
  FormMain                                              : TFormMain;
  FormAbout                                             : TFormAbout;
  DynamicPopupMenu :TDynamicVTHPopupMenu;
//  MainThread                                            : TMainThread;
  FormPopUpMessageList                                  : TStringList;//��� ��������� ������ ���������� �� ������������� ���� ������ ���������
  LocalNickName, ErrorMessage{, ExePath}           : string;
  FullVersion                                           : string;
  CurrLang                                              : string;
//  SmileGIFImage                                         : TGIF;
  RxTrayMess                                            : TRxTrayIcon;
  Button                                                : TsButton;
  //crypted_in, buffer_in                                 : array[0..1499] of Char;
  {key, {MailSlotReadName,}

  //InitTab                                             : TStringList;//��� ��� �������� ��������� ��������
//  ErrorLog                                              : TStringList;

  PlaySounds                           : boolean;
  ChatLines                                             : TStringList;//TChatLine;
  AllKnownChatLines                                     : TStringList;//������ �����, ��������� � ���� (���� ��� � ��� ��������� ���� �� ����������)
  UserListCNS_Private                                   : TStringList;//������ ������������� ���������� � ������ ��������
  UserListCNS_Personal                                  : TStringList;//������ ������������� ���������� � ������ ��������

  ChatMode                                              : TChatMode;
  CommandLine                                           : TCommandLine;//��� ������ ������ �� ������ ����� ����������


  InitError, Closing, Initing                           : boolean;
  MinimizeOnClose : boolean;
  CloseBtnString                                        : String;

  fmInternational, EInternational                       : TStringList;//������ ���� �������� ����������

  CallBackMessagesList                                  : TStringList;//For debug memory leaks


  CommunicationInit : TCommunicationInit;
  CommunicationShutDown : TCommunicationShutDown;
  SendCommDisconnect : TSendCommDisconnect;
  SendCommConnect : TSendCommConnect;
  SendCommText : TSendCommText;
  SendCommReceived : TSendCommReceived;
  SendCommStatus : TSendCommStatus;
  SendCommBoard : TSendCommBoard;
  SendCommRefresh : TSendCommRefresh;
  SendCommRename : TSendCommRename;
  SetVersion : TSetVersion;
  GetIncomingMessageCount : TGetIncomingMessageCount;
  GetNextIncomingMessage : TGetNextIncomingMessage;
  SendCommCreate : TSendCommCreate;
  GetLocalIP : TGetIP;
  SendCommCreateLine : TSendCommCreateLine;
  SendCommStatus_Req : TSendCommStatus_Req;
  SendCommMe : TSendCommMe;
  SendCommRefresh_Board: TSendCommRefresh_Board;
  SetNewCryptoKey: TSetNewCryptoKey;
  //GetLocalUserLoginName: TGetLocalUserLoginName;

implementation

uses
  uFormDebug, uFormStart,
  DreamChatConfig, DreamChatTools, uPathBuilder, uImageLoader;

{$R *.DFM}
{$R WindowsXPVista.res}

constructor TCallBackMessageData.Create(buffer:PChar; Destination:cardinal);
begin
  inherited Create;
  //��� ���������� ����������� buffer, �.�. �� ����� ���� ���������� ��� ��
  //���� ��� ��� ��������� ����� ����������
  FBuffer := StrNew(buffer);
  FDestination := Destination;
end;

destructor TCallBackMessageData.Destroy;
begin
  inherited destroy;
  SysUtils.StrDispose(FBuffer);
  FBuffer := nil;
end;

PROCEDURE TFormMain.WndProc(var Msg: TMessage);
begin
  inherited;

  if Msg.Msg = WM_HOTKEY then
  begin
    if (Application.MainForm <> nil) then
      if Application.MainForm.Visible = false then
      begin
        Application.Restore;
      end
      else
      begin
        Application.Minimize;
      end;
  end;

end;

FUNCTION CallBackFunction(Buffer:PChar; Destination:cardinal):PChar;
VAR
  CallBackData: TCallBackMessageData;
BEGIN
//DLL ����� ������� ��� ������� ����� �� ��������� � �� ������ �����.

  CallBackData := TCallBackMessageData.Create(Buffer, Destination);

  if FormMain <> nil then
    begin
    //PostMessage(FormMain.handle, UM_CALLBACKFUNCTION, Integer(buffer), Integer(Destination));
    PostMessage(FormMain.handle, UM_CALLBACKFUNCTION, Integer(CallBackData), 0);

    //�������� ���� � ���������:
    //��� �������� ��������� ������ �������� ���� ��������� ShutDown, �������
    //������ ������ CallBack. ��� ������ ��������� ��������� UM_CALLBACKFUNCTION � ���������
    //������� TCallBackMessageData, �� ������-�� FormDesroy �� ������������ ���
    //������� ���������, � ���� ������� ���, ��� �� �������� ����������
    //� ���������� ��������� ������� TCallBackMessageData ��� � ���������� ��
    //�������������, ���� ������� �� ��� �������� ������ � ��������� ��������� �������
    //������� ��������: ������ �������������� ������ ��� �������� ���� ���������
    //�������� TCallBackMessageData � �������������� ���������� �� �� FormDestroy
    CallBackMessagesList.AddObject('', CallBackData);
    end
  else
    CallBackData.free;
{
if FormDebug <> nil then
  begin
  if FormDebug.DebugMemo2 <> nil then
    begin
    if FormDebug.DebugMemo2.Lines.Count > 1500 then FormDebug.DebugMemo2.Lines.Clear;
    case Destination of
      0: FormDebug.DebugMemo2.Lines.Add(Buffer);
      1: if (FormMain <> nil) then
           begin
           ChatLine := FormMain.GetMainLine;
           if (ChatLine <> nil) and (ChatLine.ChatLineView <> nil) then
             begin
             ChatLine.ChatLineView.AddTextFromNewLine(buffer, SYSTEMTEXTSTYLE, nil);
             ChatLine.ChatLineView.FormatTail;
             ChatLine.ChatLineView.Repaint;
             SendMessage(application.MainForm.handle,
                         UM_INCOMMINGMESSAGE,
                         UM_INCOMMINGMESSAGE_Redrawall, ChatLine.LineID);
             end;
           end;
      end;
    end;
  end;}

{SendMessage(application.MainForm.handle,
            UM_INCOMMINGMESSAGE,
            UM_INCOMMINGMESSAGE_ReDrawAll, 0);}
  Result := '';
END;

procedure TFormMain.ProcessCallBackFunction(var Message: TMessage);
var
  //buffer: PChar;
  //Destination: Cardinal;
  i: integer;
  ChatLine: TChatLine;
  CallBackData: TCallBackMessageData;
begin

  CallBackData := TCallBackMessageData(Message.WParam);

  //buffer := PChar(Message.WParam);
  //Destination := Message.LParam;
  //if FormDebug <> nil then begin
  //  if FormDebug.DebugMemo2 <> nil then begin
      //if FormDebug.DebugMemo2.Lines.Count > 1500
      //  then FormDebug.DebugMemo2.Lines.Clear;
 if CallBackData <> nil then
   begin
      case CallBackData.Destination of
        0: if (FormMain <> nil) then TDebugMan.AddLine2(CallBackData.Buffer);// FormDebug.DebugMemo2.Lines.Add(CallBackData.Buffer);
        1: if (FormMain <> nil) then begin
             ChatLine := FormMain.GetMainLine;
             if (ChatLine <> nil) and (ChatLine.ChatLineView <> nil) then begin
               ChatLine.ChatLineView.AddTextFromNewLine(CallBackData.Buffer, SYSTEMTEXTSTYLE, nil);
               ChatLine.ChatLineView.FormatTail;
               ChatLine.ChatLineView.Repaint;
               SendMessage(application.MainForm.handle,
                             UM_INCOMMINGMESSAGE,
                             UM_INCOMMINGMESSAGE_Redrawall, ChatLine.LineID);
             end;
           end;
      end;
    //end;
  //end;

  //FreeAndNil(CallBackData);//������ ����� ��� ������� ��������� ���� ����
  for I := 0 to CallBackMessagesList.Count - 1 do
    begin
    if CallBackData = TCallBackMessageData(CallBackMessagesList.Objects[i]) then
      begin
      TCallBackMessageData(CallBackMessagesList.Objects[i]).free;
      CallBackMessagesList.Delete(i);
      break;
      end;
    end;
  end;
end;

PROCEDURE TFormMain.PluginMessageProcessing(var Message: TMessage);
VAR c, n, SenderLineId:cardinal;
    CurrentLine:TChatLine;
BEGIN
SenderLineId := Message.LParam;
//CurrentLine := GetActiveChatLine();
CurrentLine := GetChatLineById(SenderLineId);
if CurrentLine <> nil then begin

  if Message.WParam = UM_INCOMMINGMESSAGE_ReDrawAll then begin
//TODO: ��������! �������� ����� ��������� 2�� ��������� ���������, ����������� ����� �����!!
//    CurrentLine.ChatLineView.Format;
    if CurrentLine.ScrollToEnd = true then begin
      CurrentLine.ChatLineView.ScrollTo(CurrentLine.ChatLineView.VScrollMax);
    end;

    CurrentLine.ChatLineView.Paint;
    sChatView2.Format;
    sChatView2.Paint;
  end;

  if Message.WParam = UM_INCOMMINGMESSAGE_UpdateTree then begin
    if FormMain.PageControl1.PageCount > 0 then begin
      for n := 0 to FormMain.PageControl1.PageCount - 1 do begin
        if cardinal(FormMain.PageControl1.Pages[FormMain.PageControl1.ActivePageIndex].Tag) = CurrentLine.LineID then begin
          if CurrentLine.UsersCount > 0 then
            for c := 0 to CurrentLine.UsersCount - 1 do begin
            //ShowUserInTree(CurrentLine, c, ShowUser_REDRAW);
            ShowAllUserInTree(CurrentLine);
            end;
        end;
      end;
    end;
  end;
end;
END;

function TFormMain.GetDictionaryEng: TStringList;
begin
result := FormMain.FDictionaryEng;
end;

function TFormMain.GetDictionaryRus: TStringList;
begin
result := FormMain.FDictionaryRus;
end;

PROCEDURE TFormMain.Debug(Mess, Mess2: String);
BEGIN
//Form1.Caption := Mess;
END;

//PROCEDURE TForm1.ProcIdleHandler(Sender: TObject; var Done: Boolean);
PROCEDURE TFormMain.MainLoop();
var Redraw, DefaultProcessing:boolean;
    sMessageName, sLineName:String;
    CurrentLine:TChatLine;
    KeyPress: Char;
    buffer_in : array[0..MAX_MESSAGE_SIZE - 1] of Char;
BEGIN
Redraw := false;
CurrentLine := nil;

MessCount := GetIncomingMessageCount();

if MessCount > 0 then begin
//while MessCount > 0 do
  DefaultProcessing := True;
//  if FormDebug.DebugMemo2.Lines.Count > 1555
//    then FormDebug.DebugMemo2.Lines.Clear;

  // ����� ���? FormDebug.Caption := '��������� � ������ MAILSLOT: ' + inttostr(MessCount);

  ZeroMemory(@buffer_in, MAX_MESSAGE_SIZE);
  GetNextIncomingMessage(@buffer_in, MAX_MESSAGE_SIZE);

  //��������! ����� ������� ����! ���������� ����������
  //����� ����� ������������� ��������� � �������
  //MessageProtocolProcessing() ������ ��� �����!!!
  //��� ������ ������������ ��������� ���������:
  //����� ��� 5 ���� ������ ���������
  //DISCONNECT, CONNECT, REFRESH = ����� iTCniaM
  //�������� ������ ������� TEXT = ����� gsMTCI
  //�����                   TEXT = ����� iTCniaM
  sMessageName := GetParamX(buffer_in, 3, #19#19, true);
  sLineName := GetParamX(buffer_in, 4, #19#19, true);

  if (sMessageName = 'CONNECT') or
     (sMessageName = 'DISCONNECT') or
     (sMessageName = 'REFRESH') or
     (sMessageName = 'TEXT') then begin
    //���������� ���������� ����� ����� ������������� ��������� � �������
    //MessageProtocolProcessing() ������ ��� �����!!!
    CurrentLine := FormMain.GetChatLineByName(sLineName);

    if CurrentLine <> nil then begin
      TDebugMan.AddLine2(sLineName + ' <-- ' + buffer_in); //FormDebug.DebugMemo2.Lines.Add(sLineName + ' <-- ' + buffer_in);
      CurrentLine.MessageProtocolProcessing(buffer_in);
      DefaultProcessing := false;
    end;
  end
  else
  begin
    if (sMessageName = 'TEXT') then begin
      CurrentLine := FormMain.GetChatLineByName(sLineName);
      if CurrentLine <> nil then begin
{      If (sLineName = CurrentLine.ChatLineName) or
         (sLineName = 'gsMTCI') then
        begin}
        TDebugMan.AddLine2(TDreamChatDefaults.MainChatLineName + ' <-- ' + buffer_in); //FormDebug.DebugMemo2.Lines.Add(TDreamChatDefaults.MainChatLineName + ' <-- ' + buffer_in);
        CurrentLine.MessageProtocolProcessing(buffer_in);
        DefaultProcessing := False;
{        end;}
      end;
    end;
  end;

  if DefaultProcessing = true then begin
    CurrentLine := FormMain.GetMainLine();
    if CurrentLine <> nil then begin
      TDebugMan.AddLine2(CurrentLine.ChatLineName + ' <-- ' + buffer_in); //FormDebug.DebugMemo2.Lines.Add(CurrentLine.ChatLineName + ' <-- ' + buffer_in);
      CurrentLine.MessageProtocolProcessing(buffer_in);
    end;
  end;

    MessCount := GetIncomingMessageCount();
    Redraw := true;
end;

  //FormDebug.Caption := '��������� � ������: ' + inttostr(MessCount);

  if CurrentLine <> nil then begin
    if Redraw = True then SendMessage(application.MainForm.handle,
                                  UM_INCOMMINGMESSAGE,
                                  UM_INCOMMINGMESSAGE_ReDrawAll, CurrentLine.LineID);
  end;

  if (CommandLine.IncommigCommand = True) then begin
    //MessageBox(0, PChar('IncommigCommand = true'), PChar(inttostr(0)) ,mb_ok);
    FormMain.Edit1.Text := CommandLine.Command;
    KeyPress := Char(#13);
    Edit1KeyPress(self, KeyPress);
  end;
END;

{PROCEDURE TMainThread.Execute;
BEGIN
While not Terminated do
  begin
    MainThread.Synchronize(FormMain.MainLoop);

    if MessCount = 0
      then sleep(250);//��� ��� ������ ��� ������ ������ ������������� �������!!!!!!!

  end;
END;}

PROCEDURE TFormMain.About(Sender: TObject);
BEGIN

END;

{
FUNCTION StrToIntE(s: string):integer;
BEGIN
result := 0;
try
  result := strtoint(s);
except
    //on E:EConvertError do
  on E:Exception do
    begin
    FormMain.ProcessException(FormMain, E);
    end;
end;
END;
}

PROCEDURE TFormMain.ReadLocalUserInfoFromIni(LocalUserId:cardinal);
VAR
    tLocalUser:TChatUser;
    id: cardinal;
    MainLine:TChatLine;
//    i: integer;
{$IFDEF USELOG4D}
    logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN
try
  MainLine := GetMainLine();
  id := MainLine.GetLocalUserID();
  if id <> INVALID_USER_ID then begin
    tLocalUser := MainLine.GetUserInfo(id);
    if tLocalUser <> nil then begin
      //�������������� ��������� ������������ ��������� ��� ��� ��������� �
      //��������������� ��� ��������� �� INI �����

      TDreamChatConfig.FillMessagesState(tLocalUser.MessageStatus);

      tLocalUser.NickName := TDreamChatConfig.GetNickName(); //ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.NickName {'NickName'}, 'NoNaMe');
      tLocalUser.ProtoName := TDreamChatConfig.GetProtoName(); //ChatConfig.ReadString(TDreamChatConfig.Protocols {'Protocols'}, TDreamChatConfig.ProtoName {'ProtoName'}, 'iChat');
      tLocalUser.IP := string(GetLocalIP());
      tLocalUser.DisplayNickName := tLocalUser.NickName;
      tLocalUser.MessageBoard.LoadFromFile(TPathBuilder.GetExePath() + TDreamChatConfig.GetMessageBoard());
      tLocalUser.Version := VERSION;
      SendCommBoard(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName), PChar(tLocalUser.MessageBoard.Text), TDreamChatConfig.GetMaxSizeOfMessBoardPart());
    end;
  end;
//MessageBox(0,Pchar(tLocalUser.MessageStatus.Strings[0]),'',mb_ok);
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

{
FUNCTION TFormMain.ParseControl(SourceControlString: String; ChatLine: TChatLine; Style:integer): boolean;
//VAR
//   voteString: string;
BEGIN
//MessageBox(0, Pchar(voteString), '', mb_ok);
//�� ����� ��-�� ��������� �������????
Result := False;
if GetParamX(SourceControlString, 0, ' ', true) = '/vote' then //������ ����� = \msg
  begin
  //��������� ������ ��� �����������
  ChatLine.ChatLineView.AddTextFromNewLine('<' + ChatLine.GetUserInfo(ChatLine.GetLocalUserId()).DisplayNickName + '> ' +
                                 ' VOTE BEGIN: ' +
                                 GetParamX(SourceControlString, 1, '/vote ', true),
                                 PRIVATETEXTSTYLE, nil);
  if Button = nil then
    begin
    Button := TsButton.Create(ChatLine.ChatLineView);
    Button.OnClick := FormMain.ButtonOnClick;
    Button.Caption := GetParamX(SourceControlString, 1, '/vote ', true);//�������� ��� ��, ��� ����� \msg XXXXXX
    ChatLine.ChatLineView.AddWinControl(button, False, nil);
    end;
//  ChatLine.ChatLineView.Format;
  ChatLine.ChatLineView.FormatTail;
  ChatLine.ChatLineView.Repaint;
  Result := true;
  end;
END;                                                                                                                                                        Fdest
}

FUNCTION TFormMain.ParseBoard(SourceSmilesString: String; ChatView: TsChatView; Style: TFontInfo; tLink: TLinkInfo): boolean;
//��� ���� �������, �.�. �-��� AddFromNewLine � AddTextFromNewLine
//�����������, ���, ��� � AddTextFromNewLine ������������������ #13#10
//�������� � �������� ������, � � AddFromNewLine ��������� ����������
begin
  Result := ParseAllChatView(SourceSmilesString, nil, Style, nil, FormMain.sChatView2, false, false);
end;

{FUNCTION TForm1.ParseAll(SourceSmilesString: String; ChatLine: TChatLine; Style: TFontInfo; FromNewLine: boolean): boolean;
begin
result := ParseAllChatView(SourceSmilesString, ChatLine, Style, nil, nil, false, FromNewLine);
end;}

FUNCTION TFormMain.ParseAllChatView(SourceSmilesString: String; ChatLine: TChatLine;
                                 Style: TFontInfo;
                                 tLink: TLinkInfo;
                                 ChatView_IfNotChatLine: TsChatView;
                                 ShowTime, FromNewLine: Boolean): boolean;
var
TextAndSmile, ParseString, Link, LinkAndText, FullLink: string;
NowDateTime: TDateTime;
StartPos, EndPos, LenParseString: integer;
j, i, n: integer;
doit, NoLinks: boolean;
ChatView: TsChatView;
LinkText, OverLinkText: TFontInfo;
begin
LinkText := CVStyle1.TextStyles.Items[LINKTEXTSTYLE];
OverLinkText := CVStyle1.TextStyles.Items[ONLINKTEXTSTYLE];
if (ChatLine <> nil) then
  ChatView := ChatLine.ChatLineView
else
  ChatView := ChatView_IfNotChatLine;//���� ����� �����
if (ShowTime = true) then
  begin
  NowDateTime := Now;
  ChatView.AddTextFromNewLine('[' + TimeToStr(NowDateTime) + '] ', Style.Index, nil);
  if (ChatLine <> nil) then
    begin
    ChatLine.LineLog.Add('[' + TimeToStr(NowDateTime) + '] ' + SourceSmilesString);
    end;
  end
else
  begin
  if FromNewLine = true then
    begin
    ChatView.AddFromNewLine('', Style.Index, nil);
    if (ChatLine <> nil) then
      begin
      ChatLine.LineLog.Add(SourceSmilesString);
      end;
    end
  else
    begin
    if (ChatLine <> nil) then
      begin
      TextAndSmile := ChatLine.LineLog.Strings[ChatLine.LineLog.Count - 1];
      TextAndSmile := TextAndSmile + SourceSmilesString;
      ChatLine.LineLog.Strings[ChatLine.LineLog.Count - 1] := TextAndSmile;
      end;
    end;
  end;

  SmilesCount := MBSmilesName.Count;
  ParseString := SourceSmilesString;
    StartPos := 1;
    EndPos := 1;
    doit := false;
    NoLinks := true;
    LenParseString := Length(ParseString) + 1;
    while EndPos <= LenParseString do
      begin
      TextAndSmile := copy(ParseString, StartPos, EndPos - StartPos);
      for j := 0 to LinksKeyWordList.Count - 1 do
        begin
        i := Pos(LinksKeyWordList.strings[j], TextAndSmile);//���������� ����� �� �������
        if i > 0 then
          begin
          NoLinks := false;
          TextAndSmile := Copy(ParseString, StartPos, i - 1);
          ParseSmile(TextAndSmile, ChatLine, Style, tLink, ChatView_IfNotChatLine);

          LinkAndText := Copy(ParseString, StartPos + i - 1, length(ParseString) - 1);

          //���� ����� ������ �� ����� ' ' (������)
          n := Pos(' ', LinkAndText);
          if n = 0 then n := Pos(#13, LinkAndText);//���� ����� ������ �� ����� #13 (������� ������)
          if n = 0 then
            begin
            n := length(LinkAndText)
            end
          else
            doit := true;
          Link := TrimRight(Copy(LinkAndText, 0, n));
          FullLink:=Link;
          //������� file: �� ������ ������
          if (Pos('file:\\', Link) > 0) or (Pos('file://', Link) > 0) then
            begin
            Link := Copy(Link, 6, length(Link) - 1);
            end;

          StartPos := StartPos + i + length(Link) - 1;

          EndPos := StartPos;
          ChatView.AddText(Link, Style.Index,
                           ChatView.AddLink(integer(ltHTTP),
                           OnLinkMouseMoveProcessing,
                           OnLinkMouseUpProcessing,
                           LinkText, OverLinkText,
                           FullLink));
          break;
          end;
        end;
      inc(EndPos);
      if (ChatLine = nil) and (Style.Index <> PRIVATETEXTSTYLE) then
        begin
        //(ChatLine = nil) ���� ������ ����� �����, ������� ������� ��������
        //PRIVATETEXTSTYLE ����� ������ ������� � ��������
        //Form1.PageControl1.Pages[1].Caption := 'Parsing links... ' + IntToStr(round(EndPos/LenParseString * 100)) + '%';
        Application.ProcessMessages;
        end;
      end;
  if (doit = true) or (NoLinks = true) then
    ParseSmile(TextAndSmile, ChatLine, Style, tLink, ChatView_IfNotChatLine);
  if (ChatLine <> nil) and (ChatView <> nil) then
    begin
    //���� ChatView ��� �� ����� ����������
    ChatView.FormatTail;
    ChatView.Repaint;
//    TsChatView(ChatView).paint;
//MessageBox(0, PChar(string(ChatView.ClassName)), PChar(IntToStr(0)), MB_OK);
    end;

result := true;
end;

FUNCTION TFormMain.ParseSmile(SourceSmilesString: String; ChatLine: TChatLine; Style: TFontInfo; tLink: TLinkInfo; ChatView_IfNotChatLine: TsChatView): boolean;
var
Text, TextAndSmile, ParseString, Smile: string;
//NowDateTime: TDateTime;
StartPos, EndPos, i, n, LenParseString: integer;
ChatView: TsChatView;
begin
if ChatLine <> nil then
  ChatView := ChatLine.ChatLineView
else
  ChatView := ChatView_IfNotChatLine;//Form1.sChatView2;

  SmilesCount := MBSmilesName.Count;
  ParseString := SourceSmilesString;
  StartPos := 1;
  EndPos := 1;
  LenParseString := Length(ParseString) + 1;
    while EndPos <= LenParseString do
      begin
      TextAndSmile := copy(ParseString, StartPos, EndPos - StartPos);
      for n := 0 to SmilesCount - 1 do
        begin
        //:gr - � ���� �� � ���� ������� ������?
        Smile := MBSmilesName.Names[n];
        //:gr - � ���� �� � ���� ������� �����?
         i := Pos(Smile, TextAndSmile);//���������� ����� �� �������
        if i > 0 then
          begin
          if i = 1 then //�.�. ����� ������� ��� ����
            begin
            ChatView.AddGifAni(Smile, SmilesGIFImages[strtoint(MBSmilesName.Values[Smile])], false, nil);
            TextAndSmile := '';
            StartPos := EndPos;
            break;//0.442
            end;
          if i >= 2 then //�.�. ����� ������� ���� �����
            begin
            Text := copy(TextAndSmile, 0, i - 1);
            Delete(TextAndSmile, 1, i + Length(Smile) - 1);
            ChatView.AddText(Text, Style.Index, tLink);
            StartPos := EndPos;
            ChatView.AddGifAni(Smile, SmilesGIFImages[strtoint(MBSmilesName.Values[Smile])], false, nil);
            break;//0.442
            end;
          end;
        end;
      inc(EndPos);
      {if EndPos - StartPos > MaxSmileLen then
        begin
        //��� ������ ������ ����������� ������ ����� ��� ���������,
        //�.�. �� ��� ������ ������������� ������!!
        Text := copy(TextAndSmile, StartPos, EndPos - StartPos);
        ChatView.AddText(Text, Style, -1);
        StartPos := EndPos;
        //StartPos := StartPos + 1;
        //����! ��� ������!((( ����� ������� �� ���������� ���� ���������...
        end;}
      //+++++++++++++++++++++++==
      if (ChatLine = nil) and (Style.Index <> PRIVATETEXTSTYLE) then
        begin
        //PRIVATETEXTSTYLE ����� uFormPopUpMessage
        //ChatLine = nil ���� ������ ����� �����, ������� ������� ��������
        //Form1.PageControl1.Pages[1].Caption := 'Parsing smiles... ' + IntToStr(round(EndPos/LenParseString * 100)) + '%';
        Application.ProcessMessages;
        end;
      //+++++++++++++++++++++++==
      end;
    //������� ����� ������, ����� ���������� ������
    ChatView.AddText(TextAndSmile, Style.Index, tLink);
//end;
Result := true;
end;

procedure TFormMain.OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);
var
    tUser: TChatUser;
    ChatLine: TChatLine;
BEGIN
//���� ����� ����� ����������� Sender
ChatLine := FormMain.GetActiveChatLine;
if ChatLine <> nil then
  begin
  tUser := ChatLine.GetUserInfo(ChatLine.GetUserIdByCompName(LinkInfo.LinkText));
  if tUser <> nil then
    begin
    FormUI.GetUserInfo(ChatLine, tUser);
    if FormUI.Visible = true then
      FormUI.BringToFront;
    end;
  end;
END;

procedure TFormMain.OnLinkMouseUpProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo: TLinkInfo);//��������� ����� �� ��v���
var //StartupInfo: TStartupInfo;
    //ProcessInfo: TProcessInformation;
    //CommandLine: string;
    tUser: TChatUser;
    ChatLine: TChatLine;
BEGIN
if Button = mbLeft then
  begin
  case LinkInfo.LinkType of
    Ord(ltHTTP):
      begin
      {FillChar(StartupInfo, SizeOf(StartupInfo), #0);
      StartupInfo.cb := SizeOf(StartupInfo);
      StartupInfo.dwFlags := STARTF_USESTDHANDLES;
      StartupInfo.wShowWindow := SW_SHOWNORMAL;//SW_HIDE;
      StartupInfo.hStdOutput := 0;
      StartupInfo.hStdInput := 0;}
      {CommandLine := 'explorer.exe ' + LinkInfo.LinkText;
      CreateProcess(nil, PChar(CommandLine), nil, nil, True,
                    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                    nil, nil, StartupInfo, ProcessInfo);}
      if ExtractFilePath(LinkInfo.LinkText)=LinkInfo.LinkText then
      begin
//        if ShellExecute(0, 'explore', PChar(LinkInfo.LinkText), '', '', SW_SHOWNORMAL)<33
        if ShellExecute(0,'Open', PChar(LinkInfo.LinkText), nil, nil, SW_SHOWNORMAL) < 33
          then TDebugMan.AddLine2('Can''t open ' + LinkInfo.LinkText); // FormDebug.DebugMemo2.Lines.Add('Can''t open ' + LinkInfo.LinkText);
      end
      else
        if ShellExecute(0, 'open', PChar(LinkInfo.LinkText), '', PChar(ExtractFilePath(LinkInfo.LinkText)), SW_SHOWNORMAL)<33
          then TDebugMan.AddLine2('Can''t open ' + LinkInfo.LinkText); // FormDebug.DebugMemo2.Lines.Add('Can''t open ' + LinkInfo.LinkText);
      //DebugForm.DebugMemo1.Lines.Add('ContainerNumber = ' + inttostr(DrawCont.ContainerNumber) + '  LinkInfo.LinkText = ' +
      //              LinkInfo.LinkText);
      //MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
      end;
    Ord(ltNICK):
      begin
      //���� ����� ����� ����������� Sender
      ChatLine := FormMain.GetActiveChatLine;
      if ChatLine <> nil then
        begin
        //FormMain.Caption := LinkInfo.LinkText;
        tUser := ChatLine.GetUserInfo(ChatLine.GetUserIdByCompName(LinkInfo.LinkText));
        if tUser <> nil then
          begin
          FormMain.Edit1.Text := '/msg "' + tUser.DisplayNickName + '" ' + FormMain.Edit1.Text;
          FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
          end;
        end;
      end;
    end;
  end;
//else
if Button = mbRight then
  begin
  //���� ����� ����� ����������� Sender
  ChatLine := FormMain.GetActiveChatLine;
  if ChatLine <> nil then
    begin
    tUser := ChatLine.GetUserInfo(ChatLine.GetUserIdByCompName(LinkInfo.LinkText));
    if tUser <> nil then
      begin
      DynamicPopupMenu.AddNickLinkMenu(SenderCV, X, Y, tUser);
      end;
    end;
  end;
END;

PROCEDURE TFormMain.ShowAllUserInTree(Line:TChatLine);
VAR cUser, cLine, c, UsersCount:cardinal;
    tUser, tUser2:TChatUser;
    //s:string;
    VirtualNode, ParentVirtualNode, PrivateChatVirtualNode: PVirtualNode;
    PDNode: PDataNode;
    LineNode: TLineNode;
BEGIN
if (Line <> nil) and (Line.ChatLineTree <> nil) then
  begin
  Line.ChatLineTree.HScrollPos := Line.ChatLineTree.OffsetX;
  Line.ChatLineTree.VScrollPos := Line.ChatLineTree.OffsetY;
  Line.ChatLineTree.BeginUpdate;
  Line.ChatLineTree.Clear;
  Line.ChatLineTree.ColumnWidth := 0;
  UsersCount := Line.UsersCount;
  if UsersCount > 0 then
    begin
    AllKnownChatLines.Clear;
    for c := 0 to UsersCount - 1 do
      begin
      tUser := Line.GetUserInfo(c);
      //s := Copy(tUser.NickName, 0, Length(tUser.NickName));
      if tUser <> nil then
        begin
        //��������� ����� � ������
        VirtualNode := Line.ChatLineTree.AddChild(nil);
        PDNode := Line.ChatLineTree.GetNodeData(VirtualNode);
        PDNode.DataType := dtUser;
        //PDNode.DataUserId := c;
        PDNode.User := tUser;//���� �������� ����������� ������ �����
        PDNode.LineNode := nil;
        tUser.VirtualNode := VirtualNode;
        //���� ���� ����� 'iTCniaM' ���������� � ������ ������, ��������� ��� �����
        if tUser.ChatLinesList.Count > 0 then
          begin
          //���������� ������ ����� �����
          ParentVirtualNode := VirtualNode;
          for cLine := 0 to tUser.ChatLinesList.Count - 1 do
            begin
            if AnsiCompareText(tUser.ChatLinesList.Strings[cLine], TDreamChatDefaults.MainChatLineName {'iTCniaM'}) <> 0 then
              begin
              //���� ��� �� MainLine, ��������� �� � ������ �������� ����� ParentVirtualNode
              VirtualNode := Line.ChatLineTree.AddChild(ParentVirtualNode);
              PDNode := Line.ChatLineTree.GetNodeData(VirtualNode);
              //PDNode.DataUserId := c;//���� �������� ����������� ������ �����
              PDNode.User := tUser;//���� �������� ����������� ������ �����
              LineNode := TLineNode(tUser.ChatLinesList.Objects[cLine]);//�������� ������-���� ������ �����
              //PDNode.DataLineId := cLine;//ID ��������� ����� � ������ �����, �������� ��� �����������;
              PDNode.LineNode := LineNode;//ID ��������� ����� � ������ �����, �������� ��� �����������;
              case LineNode.LineType of
                LT_COMMON: PDNode.DataType := dtCommon;
                LT_PRIVATE_CHAT: PDNode.DataType := dtPrivateChat;
                LT_LINE: PDNode.DataType := dtLine;
              end;
              //if LineNode.IsExpanded = true then Line.ChatLineTree.Expanded[VirtualNode] := true;
              //����� ��������� �� � ������ ���� ��������� �����
              //�� ����� ����������� ��� ������ � ������ ������ �����
              //��� ��������������
              //��������� ���� �� ��� ��� � ������!
              if AllKnownChatLines.IndexOf(LineNode.LineName) < 0 then
                begin
                //LineNode.IsExpanded := true;
                AllKnownChatLines.AddObject(LineNode.LineName, LineNode);
                end;

              //������ ����� �������� ������-���������� � ��� ��������� �����
              //��� ����� ���������� ���� ������
              PrivateChatVirtualNode := VirtualNode;
              for cUser := 0 to Line.UsersCount - 1 do
                begin
                if (cUser <> c) then
                  begin
                  //� ���� � ��� � ������� ����� ����� cLine
                  tUser2 := Line.GetUserInfo(cUser);
                  if (tUser2.ChatLinesList.IndexOf(tUser.ChatLinesList.Strings[cLine]) > 0) then
                    begin
                    VirtualNode := Line.ChatLineTree.AddChild(PrivateChatVirtualNode);
                    PDNode := Line.ChatLineTree.GetNodeData(VirtualNode);
                    PDNode.DataType := dtUser;
                    //PDNode.DataUserId := cUser;//���� �������� ����������� ������ �����
                    PDNode.User := tUser2;//���� �������� ����������� ������ �����
                    PDNode.LineNode := nil;
                    end;
                  end;
                end;
              end;
            end;
          if tUser.IsExpanded = true then Line.ChatLineTree.Expanded[ParentVirtualNode] := true;
          end;
        end;
      end;
    //��������� � ����� ������ ����� � ������� ���������� �����
    //������� ������
    AllKnownChatLines.Sort;
    if AllKnownChatLines.Count > 0 then
      begin
      for cLine := 0 to AllKnownChatLines.Count - 1 do
        begin
        //��������� ����� � ������
        ParentVirtualNode := Line.ChatLineTree.AddChild(nil);
        PDNode := Line.ChatLineTree.GetNodeData(ParentVirtualNode);
        LineNode := TLineNode(AllKnownChatLines.Objects[cLine]);
        //PDNode.DataUserId := LineNode.LineOwnerID;//���� �������� ����������� ������ �����
        PDNode.User := Line.GetUserInfo(LineNode.LineOwnerID);//���� �������� ����������� ������ ����� (������-���� �� ������� �����)
        //PDNode.DataLineId := LineNode.LineID;//tUser.ChatLinesList.Strings[0];
        PDNode.LineNode := LineNode;//tUser.ChatLinesList.Strings[0];
        case LineNode.LineType of
          LT_COMMON: PDNode.DataType := dtCommon;
          LT_PRIVATE_CHAT: PDNode.DataType := dtPrivateChat;
          LT_LINE: PDNode.DataType := dtLine;
          end;
        //��������� ������ ������ � ��� �����
        for cUser := 0 to Line.UsersCount - 1 do
          begin
          tUser := Line.GetUserInfo(cUser);
          //s := Copy(tUser.NickName, 0, Length(tUser.NickName));
          if tUser <> nil then
            begin
            if tUser.ChatLinesList.IndexOf(LineNode.LineName) >= 0 then
              begin
              VirtualNode := Line.ChatLineTree.AddChild(ParentVirtualNode);
              PDNode := Line.ChatLineTree.GetNodeData(VirtualNode);
              //PDNode.DataUserId := cUser;//���� �������� ����������� ������ �����
              PDNode.User := tUser;//���� �������� ����������� ������ �����
              PDNode.LineNode := nil;
              PDNode.DataType := dtUser;
              end;
            end;
          end;
        //if LineNode.IsExpanded = true then Line.ChatLineTree.Expanded[ParentVirtualNode] := true;
        end;
      end;
    end;
  Line.ChatLineTree.EndUpdate;
  Line.ChatLineTree.ScrollToXY(Line.ChatLineTree.HScrollPos, Line.ChatLineTree.VScrollPos);

  //�������� ������������ ����� �� ��� ����, ������� ��� �� ���������� ������
  VirtualNode := Line.ChatLineTree.GetFirst;
  while VirtualNode <> nil do
    begin
    if VirtualNode.Index = Line.ChatLineTree.FocusedNodeIndex then
      begin
      Line.ChatLineTree.FocusedNode := VirtualNode;
      break;
      end
    else
      VirtualNode := Line.ChatLineTree.GetNextSibling(VirtualNode);
    end;
  //������������? :-)))

  case Line.LineType of
    LT_COMMON:
      Line.ChatLineTabSheet.Caption := Line.DisplayChatLineName + ' [' +
        inttostr(Line.UsersCount) + ']' + CloseBtnString;
    LT_PRIVATE_CHAT:
      Line.ChatLineTabSheet.Caption := Line.DisplayChatLineName;
    LT_LINE:
      Line.ChatLineTabSheet.Caption := Line.DisplayChatLineName;
  else
    Line.ChatLineTabSheet.Caption := Line.DisplayChatLineName + ' [' + inttostr(Line.UsersCount) + ']';
  end;

  //Result := UsersCount - 1;
  end
//else
//  begin
  //Result := 0;
//  end;
END;

procedure TFormMain.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
inherited;
//���� DCaht �� ����� ��������� ������ ����������
//Message.Result:=0;
FormMain.Close;
end;

PROCEDURE TFormMain.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  WinInfo:tagWINDOWINFO;
  DesktopHWND: HWND;
  ScreenX, ScreenY: integer;
  Rect: TRect;
begin
ScreenX := 800;
ScreenY := 600;
DesktopHWND := GetDesktopWindow();
if GetWindowInfo(DesktopHWND, WinInfo) = true then
  begin
  //' Left='+inttostr(WinInfo.rcWindow.Left)+
  ScreenX := WinInfo.rcWindow.Right;
  //' Top='+inttostr(WinInfo.rcWindow.Top)+
  if SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0) = true then
    ScreenY := rect.Bottom
  else
    ScreenY := WinInfo.rcWindow.Bottom;
  end;

if (Message.WindowPos.x >= -5) and (Message.WindowPos.x < 10) then
  Message.WindowPos.x := 0;
if (Message.WindowPos.y >= -5) and (Message.WindowPos.y < 10) then
  Message.WindowPos.y := 0;
if (Message.WindowPos.x + Message.WindowPos.cx > ScreenX - 10) and
   (Message.WindowPos.x + Message.WindowPos.cx < ScreenX + 10) then
  begin
  Message.WindowPos.x := ScreenX - Message.WindowPos.cx;
  end;
if (Message.WindowPos.y + Message.WindowPos.cy > ScreenY - 10) and
   (Message.WindowPos.y + Message.WindowPos.cy < ScreenY + 10) then
  begin
  Message.WindowPos.y := ScreenY - Message.WindowPos.cy;
  end;

//����� ���� �� ����� ���������� � ����� ������������� ���� SWP_NOMOVE
//Message.WindowPos.flags := Message.WindowPos.flags or SWP_NOMOVE;

//���� �������� ������� ����
//Message.WindowPos.x := 0;
//Message.Result := 0;
//inherited;
end;

FUNCTION TFormMain.GetLineType(LineName:string):TLineType;
VAR i: integer;
BEGIN
//TLineType = (LT_COMMON, LT_PRIVATE_CHAT, LT_COMMON_LINE);
result := LT_COMMON;
for i := 0 to ChatLines.Count - 1 do
  begin
  if TChatLine(ChatLines.Objects[i]).ChatLineName = LineName then
    begin
    result := TChatLine(ChatLines.Objects[i]).LineType;
    break;
    end;
  end;
END;

FUNCTION TFormMain.GetActiveChatLine():TChatLine;
VAR i: integer;
BEGIN
result := nil;
if (ChatLines <> nil) then
  begin
  for i := 0 to ChatLines.Count - 1 do
    begin
    if cardinal(FormMain.PageControl1.Pages[FormMain.PageControl1.ActivePageIndex].Tag) = TChatLine(ChatLines.Objects[i]).LineID then
      begin
      result := TChatLine(ChatLines.Objects[i]);
      break;
      end;
    end;
  end;
END;

FUNCTION TFormMain.GetChatLineById(LineId:cardinal):TChatLine;
VAR i: integer;
BEGIN
result := nil;
for i := 0 to ChatLines.Count - 1 do
  begin
  if TChatLine(ChatLines.Objects[i]).LineId = LineId then
    begin
    result := TChatLine(ChatLines.Objects[i]);
    break;
    end;
  end;
END;

FUNCTION TFormMain.GetChatLineByName(LineName:string):TChatLine;
VAR i: integer;
BEGIN
  Result := nil;
  if (ChatLines <> nil) and (Length(LineName) > 0) then
    begin
    for i := 0 to ChatLines.Count - 1 do begin
      if TChatLine(ChatLines.Objects[i]).ChatLineName = LineName then begin
        Result := TChatLine(ChatLines.Objects[i]);
        break;
      end;
    end;
  end;
END;

FUNCTION TFormMain.GetChatLineByDisplayLineName(DisplayLineName:string):TChatLine;
VAR i: integer;
BEGIN
result := nil;
if Length(DisplayLineName) > 0 then
  begin
  for i := 0 to ChatLines.Count - 1 do
    begin
//    MessageBox(0, PChar(TChatLine(ChatLines.Objects[n]).DisplayChatLineName), PChar(inttostr(n)) ,mb_ok);
    if AnsiCompareText(TChatLine(ChatLines.Objects[i]).DisplayChatLineName, DisplayLineName) = 0 then
      begin
      result := TChatLine(ChatLines.Objects[i]);
      break;
      end;
    end;
  end;
END;

FUNCTION TFormMain.GetMainLine():TChatLine;
BEGIN
  Result := GetChatLineByName(TDreamChatDefaults.MainChatLineName {'iTCniaM'});
END;

FUNCTION TFormMain.GetDelimitersCount(SourceString: String; Separator: String): Integer;
VAR
  Posit: integer;
  S: string;
BEGIN
  S := SourceString;
  Result := 0;
  while Pos(Separator, S) > 0 do
  begin
    Posit := Pos(Separator, S) + Length(Separator) - 1;
    Delete(S, 1, Posit);
    inc(Result);
  end;
END;

procedure TFormMain.InitializeTrayIcon;
begin
  RxTrayMess := TRxTrayIcon.Create(FormMain);
  RxTrayMess.Name := 'RxTrayMess';
  RxTrayMess.OnMouseUp := FormMain.RxTrayIconOnClick;
  RxTrayIcon := TRxTrayIcon.Create(FormMain);
  RxTrayIcon.Icon := Application.Icon;
  RxTrayIcon.Hint := CAPTIONVERSION;
  //RxTrayIcon.Hide;
  RxTrayIcon.OnMouseUp := FormMain.RxTrayIconOnClick;
  RxTrayIcon.PopupMenu := DynamicPopupMenu;
end;

procedure TFormMain.SaveSkinParameters;
begin
  //ChatConfig.WriteBool(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.MinimizeOnClose {'MinimizeOnClose'}, MinimizeOnClose);
  //���� �������� �� ������ ����� �������, �� �
  //���� �������� �� ������ � ��������� ����
  if DirectoryExists(SkinManMain.SkinDirectory) then
  begin
    if pos(TPathBuilder.GetExePath, SkinManMain.SkinDirectory) = 0 then
      //ChatConfig.WriteString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinsPath {'SkinsPath'}, SkinManMain.SkinDirectory)
      TDreamChatConfig.SetSkinsPath(SkinManMain.SkinDirectory)
    else
      //ChatConfig.WriteString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinsPath {'SkinsPath'}, copy(SkinManMain.SkinDirectory, pos(TPathBuilder.GetExePath, SkinManMain.SkinDirectory) + length(TPathBuilder.GetExePath) - 1, Length(SkinManMain.SkinDirectory)-length(TPathBuilder.GetExePath) + 1));
      TDreamChatConfig.SetSkinsPath(copy(SkinManMain.SkinDirectory, pos(TPathBuilder.GetExePath, SkinManMain.SkinDirectory) + length(TPathBuilder.GetExePath) - 1, Length(SkinManMain.SkinDirectory) - length(TPathBuilder.GetExePath) + 1));
  end
  else if DirectoryExists(TPathBuilder.GetDefaultSkinsDirFull) then
    {ExePath+'Skins\'}
    //ChatConfig.WriteString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinsPath {'SkinsPath'}, TDreamChatConfig.DefaultSkinsDir {'\Skins\'});
    TDreamChatConfig.SetSkinsPath(TDreamChatDefaults.DefaultSkinsDir);

  //ChatConfig.WriteBool(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.Enable {'Enable'}, SkinManMain.Active);
  //ChatConfig.WriteString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinName {'SkinName'},SkinManMain.SkinName);
  //ChatConfig.WriteInteger(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinColor {'SkinColor'},SkinManMain.HueOffset);
  TDreamChatConfig.SetEnable(SkinManMain.Active);
  TDreamChatConfig.SetSkinName(SkinManMain.SkinName);
  TDreamChatConfig.SetSkinColor(SkinManMain.HueOffset);
end;

FUNCTION TFormMain.MultiTranslate(SourceString: String;Direct:byte): string;
var
Dict1:TStringList;
DictWord, Text, SChar, SChar2, DictNames: string;
n, dx, x, k: cardinal;
CompareResult:integer;
Found:boolean;
MaxDx:word;
begin
if Direct = EngToRus then
  begin
  Dict1 := FDictionaryEng;
//  Dict2 := DictionaryRus;
  end
else
  begin
  Dict1 := FDictionaryRus;
//  Dict2 := DictionaryEng;
  end;

Result := '';
Found := False;
x := 1;
//CompareResult := -1;
MaxDx := MaxDxEng;
if MaxDx > Length(SourceString) then MaxDx := Length(SourceString);

dx := MaxDx;
while x <= cardinal(Length(SourceString)) do
  begin
  //����������� ��������� ������ ������� ������
  //qwertyuiopqwertyuiop
  // ^
  // |
  // x
  while dx > 0 do
    begin
    //����� ������� ������ �������� ������
    //qwertyuiopqwertyuiop
    //    ^      ^
    //    |<-dx->|
    //    x
    Text := copy(SourceString, x, dx);
    //����������� ����� ������ ������ � dx
    //�.�. Text := tyuiopqw
    for n := 0 to Dict1.Count - 1 do
      begin
      //���������� ����� � ��������� ������ �� �������
      Found := False;
      DictNames := Dict1.Names[n];
      //���� ����� ������ ������� ���� ^�={ ������ ��������� � ������ ��������
      //CompareResult := -1;
      if DictNames[1] = '^' then
      begin
        Delete(DictNames, 1, 1);
        CompareResult := AnsiCompareStr(Text, DictNames);
      end
      else
      begin
        CompareResult := AnsiCompareText(Text, DictNames);
      end;

      if CompareResult = 0 then
        begin
        //����� � ������� ����� ��� ������, �� ������ ����� ������
        //������� ���� ���������
        DictWord := '';
        for k := 1 to Length(GetParamX(Dict1.strings[n], 1, '=', True)) do
          begin
          //�������� ����� ��� ������
          SChar := Copy(Text, k, 1);
          SChar2 := Copy(GetParamX(Dict1.strings[n], 1, '=', True), k, 1);
          //������ ������ ����� lol=������, �.�. ���-�� ���� �� ���������
          //� ��c��� lol �� ������ � �������, � ����� [ ��������� �� ������� �������
          If (k > cardinal(Length(SChar))) or (Pos(SChar, ExceptSymbols) > 0) then
//          If (k > Length(SChar)) or (Pos(SChar, ',.[]') > 0) then
            begin
            DictWord := SChar2;
            end
          else
            if (SChar = AnsiUpperCase(SChar)) then
              DictWord := AnsiUpperCase(SChar2)
            else
              DictWord := AnsiLowerCase(SChar2);
          Result := Result + DictWord;
          end;
        x := x + dx;
        dx := MaxDx + 1;
        Found := True;
        break;
        end
      end;
    dec(dx);
    if x >= cardinal(Length(SourceString)) then break;
    end;
  if Found = False then
    begin
    Result := Result + Copy(SourceString, x, 1);
    inc(x);
    end;
  dx := MaxDx;
  end;
end;

PROCEDURE TFormMain.ApplicationMinimize(Sender: TObject);
BEGIN
  if (Application.MainForm <> nil) then
  begin
    Application.MainForm.Visible := False;
    //�������� ��������� ����, ����� ��� ������ ���� ��������� � ������ �����
    ShowWindow(Application.Handle, SW_HIDE);
  end;
END;

PROCEDURE TFormMain.ApplicationRestore(Sender: TObject);
BEGIN
  if (Application.MainForm <> nil) then
  begin
    Application.MainForm.Visible := True;
    //ShowWindow(Application.Handle, SW_HIDE);
    Application.BringToFront;
  end;
END;

//PROCEDURE TFormMain.ButtonOnClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
PROCEDURE TFormMain.ButtonOnClick(Sender: TObject);
BEGIN
sMessageDlg('Vote!', 'Click test!', mtInformation	, [mbOk], 0)
END;



PROCEDURE TFormMain.RxTrayIconOnClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var  txt: string;
BEGIN
//FormMain.Caption := 'RxTrayIconOnClick: X=' + inttostr(X) + ' Y=' + inttostr(Y);
if TRxTrayIcon(Sender).Name = 'RxTrayMess' then
  begin
  RxTrayMess.Animated := false;
  RxTrayMess.Hide;
  end;

if Button = mbRight then
  begin
  DynamicPopupMenu.AddRxTrayMenu(Self);
  if SkinManMain.Active then
    SkinManMain.SkinableMenus.HookPopupMenu(DynamicPopupMenu, True);

  DynamicPopupMenu.Popup(x, y);
  end
else
begin
  if (Button = mbLeft) and (Application.MainForm <> nil) then
  begin
  if Application.MainForm.Visible = false then
    begin
    if uFormMain.MinimizeOnClose = true then
      begin
      Application.MainForm.Visible := true;
      end
    else
      begin
      Application.Restore;
      end;
    end
  else
    begin
    {  h3 := Application.Handle;
      h1 := GetForegroundWindow();
      h2 := GetTopWindow(NULL);
      SetLength(txt, 255);
      ZeroMemory(PChar(txt), 255);
      GetWindowText(h1, PChar(txt), 255);
      ZeroMemory(PChar(txt), 255);
      GetWindowText(h2, PChar(txt), 255);
      if(not Application.Active)
        then Application.BringToFront
        else Application.Minimize;}
      Application.Minimize;
    end;
  end;
end;
END;

PROCEDURE TFormMain.ProcessException(Sender: TObject; E: Exception);
var
  s, sClassName:string;
  n: integer;
  cl: TPersistentClass;
{$IFDEF USELOG4D}
  logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN
  s := '';

  cl := GetClass(E.ClassName);

  if cl <> nil
    then s := (Sender As TComponentClass(FindClass(E.ClassName))).Name;

  if E.ClassName = 'EClassNotFound' then
  begin
    //Class TButton not found
    //����� ����� ���������� � ����� ������� ��������� ������ �����
    //����� ����� ����� ������� ��� ���������������
    //��� ��������� ������������ ����� � ������� ��������� ������,
    //���� �� �� ��� ��������������� �� �����
    s := copy(E.Message, 7, length(E.Message) - 1);
    sClassName := copy(s, 1, pos(' ', s) - 1);
    cl := GetClass(sClassName);

    if cl <> nil then //���! �������� ��� ������� � ������� ��������� ������!
    begin
      s := (Sender As TComponentClass(cl)).Name
    end
    else
    begin
      for n := 0 to FormMain.ControlCount - 1 do
      begin
        if FormMain.Controls[n].ClassName = sClassName then
        begin
          RegisterClass(TPersistentClass(FormMain.Controls[n].ClassType));
          exit;
        end;
      end;
      RegisterClass(TFormPopUpMessage);
    end;
  end;

  if Sender is TComponent then begin
    s := Format('%s:%s [%s, %s] %s : %s ', [DateToStr(Now), TimeToStr(Now), Sender.ClassName, TComponent(Sender).Name, E.ClassName, E.Message]) + s;
  end
  else
  begin
    s := Format('%s:%s [%s] %s : %s ', [DateToStr(Now), TimeToStr(Now), Sender.ClassName, E.ClassName, E.Message]) + s;
  end;
  //s := '' + DateToStr(Now) + ':' + TimeToStr(Now) + ' [' + Sender.ClassName + '] ' + E.ClassName + ' : ' + E.Message + ' ' + s;

  ErrorLog.Add(s);
  ErrorLog.SaveToFile(TPathBuilder.GetExePath() + 'ErrorLog.txt');

{$IFDEF USELOG4D}
    logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
    logger.Error(s, E);
{$ENDIF USELOG4D}

END;


PROCEDURE TFormMain.LoadComponents(Sender: TObject);
var sc, si{, s}: string;
    strlist: TStringList;
    //MS: TMemoryStream;
    i: integer;
    ChatLine: TChatLine;
    n: cardinal;
    //tempGIFImage : TGIF;
    Icon: TIcon;
begin
//s := TPathBuilder.GetExePath;
sc := TPathBuilder.GetComponentsFolderName; //s + 'Components\';
si := TPathBuilder.GetImagesFolderName; //s + 'Images\';

//tempGIFImage := TGIF.Create;
//InitTab.AddObject('TGIF', SmileGIFImage);

strlist := TStringList.Create;
try
  strlist.LoadFromFile(sc + 'FForm.txt');
  StringToComponent(FormMain, strlist.text);
  strlist.LoadFromFile(sc + 'FPanel1.txt');
  StringToComponent(Panel1, strlist.text);
  strlist.LoadFromFile(sc + 'FPanel2.txt');
  StringToComponent(Panel2, strlist.text);
  strlist.LoadFromFile(sc + 'FPanel3.txt');
  StringToComponent(Panel3, strlist.text);
  strlist.LoadFromFile(sc + 'FPanel4.txt');
  StringToComponent(Panel4, strlist.text);
  strlist.LoadFromFile(sc + 'FSplitter.txt');
  StringToComponent(Splitter1, strlist.text);
  strlist.LoadFromFile(sc + 'FMemo1.txt');
  StringToComponent(Memo1, strlist.text);

  strlist.LoadFromFile(sc + 'FStyle.txt');
  StringToComponent(CVStyle1, strlist.text);
  strlist.LoadFromFile(sc + 'FPageControl.txt');
  StringToComponent(PageControl1, strlist.text);
  strlist.LoadFromFile(sc + 'FTabSheetMessBoard.txt');
  StringToComponent(TabSheet2, strlist.text);

  //������ TEdit! ������ TEdit! ������ TEdit! ������ TEdit! ������ TEdit!
  //�� �� ����� ��, ����� ����� ��������, ������ ���� ���������!
  strlist.LoadFromFile(sc + 'FEdit.txt');
  try
    i := StrToInt(strlist.Values['  Height ']);
  except
    i := 21;
  end;
  TempEdit1Height := i;
  StringToComponent(FormMain.Edit1, strlist.text);


  if (ChatLines <> nil) and (ChatLines.Count > 0) then
    begin
    strlist.LoadFromFile(sc + 'CLGifVTree.txt');
    for n := 0 to ChatLines.Count - 1 do
      begin
      ChatLine := TChatLine(ChatLines.Objects[n]);
      ChatLine.ChatLineTree.Clear;
      StringToComponent(ChatLine.ChatLineTree, strlist.text);
      ChatLine.ChatLineTree.Header.Columns.Add;
      ChatLine.ChatLineTree.NodeDataSize := SizeOf(TDataNode);
      FormMain.ShowAllUserInTree(ChatLine);
      ChatLine.ChatLineView.Format;
      ChatLine.ChatLineView.Paint;
      end;
    end;

  strlist.LoadFromFile(sc + 'FSpeedButton1.txt');
  StringToComponent(ClearButton, strlist.text);
  strlist.LoadFromFile(sc + 'FRefreshButton.txt');
  StringToComponent(RefreshButton, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton3.txt');
  StringToComponent(SpeedButton3, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton4.txt');
  StringToComponent(SpeedButton4, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton5.txt');
  StringToComponent(SpeedButton5, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton6.txt');
  StringToComponent(SpeedButton6, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton7.txt');
  StringToComponent(SpeedButton7, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton8.txt');
  StringToComponent(SpeedButton8, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton9.txt');
  StringToComponent(SpeedButton9, strlist.text);
  strlist.LoadFromFile(sc + 'FSpeedButton10.txt');
  StringToComponent(SpeedButton10, strlist.text);

except
  on E: Exception do
    begin
    sMessageDlg('Component loading  error!', E.Message, mtError, [mbOk], 0);
    InitError := true;
    end;
end;
strlist.free;

  //MS := TMemoryStream.Create;
  try
    //MS.LoadFromFile(si + 'Clear.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    ClearButton.Glyph.Assign(TDreamChatImageLoader.GetImage(G_CLEAR).Bitmap[0]);

    //MS.LoadFromFile(si + 'RefreshB.gif');//Refresh.gif
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    RefreshButton.Glyph.Assign(TDreamChatImageLoader.GetImage(G_REFRESHB).Bitmap[0]);

    //MS.LoadFromFile(si + 'Status0.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton3.Glyph.Assign(TDreamChatImageLoader.GetImage(G_STATUS0).Bitmap[0]);

    //MS.LoadFromFile(si + 'Status1.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton4.Glyph.Assign(TDreamChatImageLoader.GetImage(G_STATUS1).Bitmap[0]);

    //MS.LoadFromFile(si + 'Status2.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton5.Glyph.Assign(TDreamChatImageLoader.GetImage(G_STATUS2).Bitmap[0]);

    //MS.LoadFromFile(si + 'Status3.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton6.Glyph.Assign(TDreamChatImageLoader.GetImage(G_STATUS3).Bitmap[0]);

    //MS.LoadFromFile(si + 'Smile.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton7.Glyph.Assign(TDreamChatImageLoader.GetImage(G_SMILE).Bitmap[0]);

    //MS.LoadFromFile(si + 'Debug.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton8.Glyph.Assign(TDreamChatImageLoader.GetImage(G_DEBUG).Bitmap[0]);

    //MS.LoadFromFile(si + 'Settings.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton9.Glyph.Assign(TDreamChatImageLoader.GetImage(G_SETTINGS).Bitmap[0]);

    //MS.LoadFromFile(si + 'About.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    SpeedButton10.Glyph.Assign(TDreamChatImageLoader.GetImage(G_ABOUT).Bitmap[0]);
    //��������� ������ ���������, ������� ����� ����� � �������
    //MS.LoadFromFile(si + 't_MAINICON.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MAINICON), 0);
    RxTrayIcon.Icons.Add(Icon);
    Icon.Free;
    //MS.LoadFromFile(si + 't_MAINICON_1.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MAINICON_1), 0);
    RxTrayIcon.Icons.Add(Icon);
    Icon.Free;
    //MS.LoadFromFile(si + 't_MAINICON_2.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MAINICON_2), 0);
    RxTrayIcon.Icons.Add(Icon);
    Icon.Free;
    //MS.LoadFromFile(si + 't_MAINICON_3.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MAINICON_3), 0);
    RxTrayIcon.Icons.Add(Icon);
    Icon.Free;

    //��������� ������ ���������� ���������, ������� ����� ����� � �������
    //MS.LoadFromFile(si + 't_mess_1.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MESS_1), 0);
    RxTrayMess.Icons.Add(Icon);
    Icon.Free;
    //MS.LoadFromFile(si + 't_mess_2.gif');
    //tempGIFImage.LoadFromStream(ms);
    //MS.Clear;
    Icon := GIFToICO(TDreamChatImageLoader.GetImage(G_T_MESS_2), 0);
    RxTrayMess.Icons.Add(Icon);
    Icon.Free;

  except
    on E: Exception do begin
      sMessageDlg('GIF image loading  error!', E.Message, mtError, [mbOk], 0);
      InitError := true;
    end;
  end;

//MS.Free;
//tempGIFImage.Free;

FormMain.Resize;
end;


procedure TFormMain.FormCreate(Sender: TObject);
var strlist: TStringList;
    s, s2: string;
    //Myinfo: TStartUpInfo;
begin
Initing := True;
ChatLines := nil;
CallBackMessagesList := TStringList.Create;
Application.OnException := FormMain.ProcessException;

//InitTab := TStringList.Create;
//�������� �������� ������� ����������� �����, ��� ������������� ������ �
//������ ������� ���������. � ���� ������ ������� ���� ����� �� ��������
//������� ����� FormDestroy �������� � �������.
//����� ������ ������! �� �������� ��������� ��
//��� ������� + �� ������ ��������� �������. �.�. ��� �������� �� ������� ��
//���� ���������. �������� ��������� ������ ������������� ���������� �����������
//� ���, ��� �� ������ ������ �������� ��������� ������� ����� ��� �������������
//������ � �������� �������������.

//GetStartUpInfo(MyInfo);
//MyInfo.wShowWindow := SW_HIDE;//SW_MINIMIZE
//ShowWindow(Handle, MyInfo.wShowWindow);

ErrorLog := TStringList.Create;
//InitTab.AddObject('TStringList', ErrorLog);
try
  if FileExists(TPathBuilder.GetExePath() + 'ErrorLog.txt')
    then ErrorLog.LoadFromFile(TPathBuilder.GetExePath() + 'ErrorLog.txt');
except
  on E: Exception do begin
    sMessageDlg('ErrorLog.txt loading  error!', E.Message, mtError, [mbOk], 0);
    FormMain.Close;
  end;
end;

InitializeTrayIcon;

Application.OnMinimize := ApplicationMinimize;
Application.OnRestore  := ApplicationRestore;

PageControl1.Pages[0].Tag := 32767;

FormMain.LoadComponents(sender);
//��... ���� ����� ��� �� ���� Visible = true
//�� ������ Edit1 �� ����� ��������� ���� ��������� �� FEDIT.TXT !!!!
//�.�. �� �� ���������, �� �� ����������������!!!

RegisterClasses([TFormMain, TButton, TEdit, TMemo, TsChatView, TSplitter,
                 TGifVirtualStringTree, TTabSheet, TPageControl,
                 TPanel, TCVStyle]);

AFormSmiles := TFormSmiles.Create(nil);

s := FormMain.Init(Sender);
if length(s) = 0 then
  begin
  FormMain.Edit1.Height := TempEdit1Height;//������! � ��� ������?
  FormMain.Resize;

  //Initing := false;//���������� ��� ��������� ������� DISCONNECT � UChatLine
  FSettings := TFSettings.Create(nil);

  //���� ��� ���������������� ������� �������� ������� CONNECT
  strlist := TStringList.Create;
  s := TDreamChatConfig.GetProtoName;
  TDreamChatConfig.FillMessagesState0(strlist);
  s2 := strlist.Strings[0];
  FSettings.eCryptoKey.Text := TDreamChatConfig.GetCryptoKey();
  SendCommDisconnect(PChar(s), '', '*', TDreamChatDefaults.MainChatLineName {'iTCniaM'});
  SendCommConnect(PChar(s),
                  PChar(LocalNickName), '*',
                  TDreamChatDefaults.MainChatLineName {'iTCniaM'}, '*',
                  PChar(s2), 0);
  strlist.Free;
  //if MainThread <> nil
  // then MainThread.Resume;
  MainLoopTimer.Enabled := True;
  end
else
  begin
  MessageBox(0, PChar('Init() Error!'), PChar(s) ,mb_ok);
  end;
end;

FUNCTION TFormMain.Init(Sender: TObject):string;
VAR s, s2, stemp, FilePath:string;
    n, par, DelimitersCount:word;
    Section, sl: TStringlist;
    SmileFileName:string;
    MainLine:TChatLine;
    MS: TMemoryStream;
    ErrorMessage: string;
    EngWord, RusWord, delim :string;
    InitDictionary, MemIniSmilesFile, MemIniStrings: TMemIniFile;
    RegisterProc: Pointer;
    E: Exception;
//    TempSysKey, SysKey, VK: cardinal;
//    KeyChar: Char;
    i, i_end: integer;
BEGIN
result := '';
//ShiftKey := false;
CtrlKey := false;
//AltKey := false;
Closing := false;
PlaySounds := True;
AutoAwayStatus := false;
if (InitError = false) then
  begin
  ChatMode := cmodTCP;
  InitError := false;
  sChatView2.OnDebug := Debug;
  sChatView2.CursorSelection := false;
  ChatLines := TStringList.Create;
//  InitTab.AddObject('TStringList', ChatLines);
  AllKnownChatLines := TStringList.Create;
//  InitTab.AddObject('TStringList', AllKnownChatLines);
  UserListCNS_Private := TStringList.Create;
//  InitTab.AddObject('TStringList', UserListCNS_Private);
  UserListCNS_Personal := TStringList.Create;
//  InitTab.AddObject('TStringList', UserListCNS_Personal);
  FormPopUpMessageList := TStringList.Create;
//  InitTab.AddObject('TStringList', FormPopUpMessageList);
  //ChatConfig := TMemIniFile.Create(TPathBuilder.GetConfigIniFileName() {ExePath + TDreamChatConfig.ConfigIniFileName {'config.ini'});
//  InitTab.AddObject('TMemIniFile', ChatConfig);

  MinimizeOnClose := TDreamChatConfig.GetMinimizeOnClose(); 
  //MinimizeOnClose := ChatConfig.ReadBool(TDreamChatConfig.Common {'Common'},TDreamChatConfig.MinimizeOnClose {'MinimizeOnClose'}, False);
  if MinimizeOnClose then
    begin
    FormMain.BorderIcons := FormMain.BorderIcons - [biMinimize];
    CloseBtnString:='   ';
    end
  else
    FormMain.BorderIcons := FormMain.BorderIcons + [biMinimize];

  //��������� �����
//  stemp := TDreamChatConfig.GetSkinsPath(); //FormMain.ChatConfig.ReadString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinsPath {'SkinsPath'}, TPathBuilder.GetDefaultSkinsDirFull {'Skins\'});
  stemp := TPathBuilder.BuildSkinsPath(TDreamChatConfig.GetSkinsPath());

//  if (stemp <> '') and (ExtractFileDrive(stemp) = '')
//    then stemp := ExcludeTrailingPathDelimiter(TPathBuilder.GetExePath()) + stemp;

  if DirectoryExists(stemp)
    then SkinManMain.SkinDirectory := stemp
    else
      if DirectoryExists(TPathBuilder.GetDefaultSkinsDirFull {'Skins\'})
        then SkinManMain.SkinDirectory := TPathBuilder.GetDefaultSkinsDirFull {'Skins\'};

  stemp := TDreamChatConfig.GetSkinName(); //FormMain.ChatConfig.ReadString(TDreamChatConfig.Skin {'Skin'}, TDreamChatConfig.SkinName {'SkinName'},'');

  if stemp <> '' then
  begin
    sl := TStringList.Create;
    SkinManMain.GetSkinNames(sl);
    if sl.IndexOf(stemp) <> -1 then
    begin
      SkinManMain.SkinName := stemp;
      SkinManMain.Active:=TDreamChatConfig.GetEnable;
      //���� ��������� ���� �������� � designtime �� �����
      //�������� Delphi, � ����� ����� ���� - ������ F9 �
      //������� ���������� ����� ��������� ������
    end;
    FreeAndNil(sl);
  end;

  stemp := '';
  SkinManMain.HueOffset := TDreamChatConfig.GetSkinColor;
  //����� ���������
  try
    //'DefaultUser.ini'
    DefaultUser := TMemIniFile.Create(TPathBuilder.GetExePath() + TDreamChatDefaults.DefaultUserIniFileName);
  except
    sMessageDlg('File not found!', TPathBuilder.GetExePath() + TDreamChatDefaults.DefaultUserIniFileName, mtError, [mbOk], 0)
  end;

  fmInternational := TStringList.Create;
  EInternational := TStringList.Create;
  Section := TStringlist.Create;

  CurrLang := TDreamChatConfig.GetLanguageFileName(); //TPathBuilder.GetExePath() + ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.Language {'Language'}, 'Languages\English.lng');
  try
    MemIniStrings := TMemIniFile.Create(TPathBuilder.GetExePath() + CurrLang);
  except
    sMessageDlg('File not found!', TPathBuilder.GetExePath() + CurrLang, mtError, [mbOk], 0)
  end;

  MemIniStrings.ReadSection('Strings', Section);
  i_end := Section.Count - 1;
  for i := 0 to i_end do
    begin
    fmInternational.Add(MemIniStrings.ReadString('Strings', InttoStr(i + 10), ''));//Strings
    EInternational.Add(MemIniStrings.ReadString('ErrorStrings', InttoStr(i + 10), ''));
    end;
  //LoadKeyboardLayout('00000419', KLF_ACTIVATE);
  s := MemIniStrings.ReadString('Common', 'KeyboardLayout', '00000419');
  LoadKeyboardLayout(PChar(s), KLF_ACTIVATE);
  ClearButton.Hint := MemIniStrings.ReadString('Hints', 'ClearBtn', ClearButton.Hint);
  RefreshButton.Hint := MemIniStrings.ReadString('Hints', 'RefreshBBtn', RefreshButton.Hint);
  SpeedButton3.Hint := MemIniStrings.ReadString('Hints', 'Status0Btn', SpeedButton3.Hint);
  SpeedButton4.Hint := MemIniStrings.ReadString('Hints', 'Status1Btn', SpeedButton4.Hint);
  SpeedButton5.Hint := MemIniStrings.ReadString('Hints', 'Status2Btn', SpeedButton5.Hint);
  SpeedButton6.Hint := MemIniStrings.ReadString('Hints', 'Status3Btn', SpeedButton6.Hint);
  SpeedButton7.Hint := MemIniStrings.ReadString('Hints', 'SmileBtn', SpeedButton7.Hint);
  SpeedButton8.Hint := MemIniStrings.ReadString('Hints', 'DebugBtn', SpeedButton8.Hint);
  SpeedButton9.Hint := MemIniStrings.ReadString('Hints', 'SettingsBtn', SpeedButton9.Hint);
  SpeedButton10.Hint := MemIniStrings.ReadString('Hints', 'AboutBtn', SpeedButton10.Hint);
  MemIniStrings.Free;
  Section.Free;

  TimerRefreshAllMessageBoard := TTimer.Create(FormMain);
//  InitTab.AddObject('TTimer', TimerRefreshAllMessageBoard);
  TimerRefreshAllMessageBoard.Interval := 0;
  TimerRefreshAllMessageBoard.OnTimer := RefreshAllMessageBoard;
  TimerRefreshAllMessageBoard.Enabled := False;

  TimerJob := TTimer.Create(FormMain);
//  InitTab.AddObject('TTimer', TimerJob);
  //TimerJob.Interval := 0;
  TimerJob.OnTimer := Sheduller;
  TimerJob.Enabled := False;
  TimerJob.Interval := TDreamChatConfig.GetJobSeekingTimer(); //ChatConfig.ReadInteger(TDreamChatConfig.Jobs {'Jobs'},  TDreamChatConfig.JobSeekingTimer {'JobSeekingTimer'}, 60000);
  JobMessAndTimeDelimiter := TDreamChatConfig.GetCommandAndTimeDelimiter(); //ChatConfig.ReadString(TDreamChatConfig.Jobs {'Jobs'}, TDreamChatConfig.CommandAndTimeDelimiter {'CommandAndTimeDelimiter'}, ' ');

  //TODO: ��������! ������� ���������! ������!
  JobsList := TStringList.Create;
//  InitTab.AddObject('TStringList', JobsList);
  try
    JobsList.LoadFromFile(TPathBuilder.GetExePath() + TDreamChatDefaults.JobsIniFileName {'Jobs.ini'});
    JobsList.Sort;
  except
    sMessageDlg('File not found!', TDreamChatDefaults.JobsIniFileName {'Jobs.ini'}, mtError, [mbOk], 0)
  end;

//  if MainThread = nil then begin
//    MainThread := TMainThread.Create(true); // create suspended thread
//    MainThread.Priority := tpIdle;//tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest, tpTimeCritical
//  end;

  // roma nMaxMessSize := SizeOf(buffer_in);

{-------------- �������� ��������� mskrnl.dll ��� tcpkrnl.dll -----------------}
  //if FormMain.ChatConfig.ReadString(TDreamChatConfig.ConnectionType {'ConnectionType'}, TDreamChatConfig.Server {'Server'}, 'Yes') = 'No' then
  if TDreamChatConfig.GetServer() = 'No' then // TODO: magik number
    begin
    //���������� DLL ��� mailslot 'mskrnl'
    ChatMode := cmodMailSlot;
    CommunicationLibHandle := LoadLibrary(PChar(TPathBuilder.GetExePath() + TDreamChatDefaults.CommunicationLibFileNameMailslot {'mskrnl.dll'}));
    s := TDreamChatDefaults.CommunicationLibFileNameMailslot {'mskrnl.dll'};
    end
  else
    begin
    //���������� DLL ��� Servera 'tcpkrnl'
    ChatMode := cmodTCP;
    CommunicationLibHandle := LoadLibrary(PChar(TPathBuilder.GetExePath() + TDreamChatDefaults.CommunicationLibFileNameTCP {'tcpkrnl.dll'}));
    s := TDreamChatDefaults.CommunicationLibFileNameTCP {'tcpkrnl.dll'};
    end;

  if CommunicationLibHandle = Null then
    begin
    InitError := True;
    ErrorMessage := 'Error: Can''t load library ' + s; // TODO: untranslated string
    sMessageDlg('Critical error!', ErrorMessage, mtError, [mbOk], 0);
    E := Exception.Create(ErrorMessage);
    raise E; // roma .create(ErrorMessage);
    end
  else
    begin
    RegisterProc := GetProcAddress(CommunicationLibHandle, 'Init');
    if not Assigned(RegisterProc) then
       sMessageDlg(inttostr(0), '"Init" function not Assigned! In "' + s + '"', mtError, [mbOk], 0) //TODO: untranslated string
    else
      CommunicationInit := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'ShutDown');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"CommunicationShutDown" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      CommunicationShutDown := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommDisconnect');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommDisconnect" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommDisconnect := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommConnect');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommConnect" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommConnect := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommText');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommText" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommText := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommReceived');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommReceived" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommReceived := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommStatus');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommStatus" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommStatus := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommBoard');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommBoard" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommBoard := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommRefresh');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommRefresh" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommRefresh := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommRename');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommRename" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommRename := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SetVersion');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SetVersion" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SetVersion := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'GetIncomingMessageCount');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"GetIncomingMessageCount" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      GetIncomingMessageCount := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'GetNextIncomingMessage');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"GetNextIncomingMessage" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      GetNextIncomingMessage := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommCreate');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommCreate" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommCreate := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'GetIP');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"GetIP" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      GetLocalIP := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommCreateLine');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommCreateLine" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommCreateLine := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommStatus_Req');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommStatus_Req" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommStatus_Req := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommMe');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommMe" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommMe := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SendCommRefresh_Board');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SendCommRefresh_Board" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SendCommRefresh_Board := RegisterProc;

    RegisterProc := GetProcAddress(CommunicationLibHandle, 'SetNewCryptoKey');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"SetNewCryptoKey" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      SetNewCryptoKey := RegisterProc;

{    RegisterProc := GetProcAddress(CommunicationLibHandle, 'GetLocalUserLoginName');
    if not Assigned(RegisterProc) then
      sMessageDlg(inttostr(0), '"GetLocalUserLoginName" function not Assigned! In "' + s + '"', mtError, [mbOk], 0)
    else
      GetLocalUserLoginName := RegisterProc;}

    ErrorMessage := CommunicationInit(CommunicationLibHandle, @CallBackFunction, PChar(TPathBuilder.GetExePath()));
    if Length(ErrorMessage) > 0 then
      begin
      InitError := True;
      E := Exception.Create(ErrorMessage);
      raise E; //roma .create(ErrorMessage);
      if Assigned(CommunicationShutDown()) then CommunicationShutDown(); // TODO: weird code. will not be executed
      end;
    end;

  ErrorMessage := SoundInit(@CallBackFunction, PChar(TPathBuilder.GetExePath()));
  if Length(ErrorMessage) > 0 then
    begin
    InitError := True;
    E := Exception.Create(ErrorMessage);
    raise E; // roma .create(ErrorMessage);
    SoundShutDown(); // TODO: weird code. will not be executed
    sMessageDlg('InitError!', ErrorMessage, mtError, [mbOk], 0)
    end;

  LocalNickName := TDreamChatConfig.GetNickName(); //ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.NickName {'NickName'}, 'NoNaMe');
  FormMain.Caption := CAPTIONVERSION;
  FullVersion := SetVersion(VERSION);

  //MaxMessBoardPart := TDreamChatConfig.GetMaxSizeOfMessBoardPart(); //ChatConfig.ReadInteger(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.MaxSizeOfMessBoardPart {'MaxSizeOfMessBoardPart'}, 10);

  LinksKeyWordList := TStringlist.Create;
  //ChatConfig.ReadSectionValues(TDreamChatConfig.LinksKeyWords {'LinksKeyWords'}, LinksKeyWordList);
  TDreamChatConfig.FillLinksKeywords(LinksKeyWordList);
    //TODO: ��������!!! � ������ ��� ��������� ����� �� ����� � UChatLine !!!!!

  MemIniSmilesFile := TMemIniFile.Create(TPathBuilder.GetSmilesIniFileName {ExePath + 'smiles.ini'});
  MBSmilesName := TStringlist.Create;
  Section := TStringlist.Create;
  MemIniSmilesFile.ReadSection(TDreamChatDefaults.SmilesSmiles {'Smiles'}, Section);

  SmilesCount := Section.Count;
  SetLength(SmilesGIFImages, SmilesCount);
  MS := TMemoryStream.Create;

  if SmilesCount > 0 then
    begin
    try
      FormStart := TFormStart.Create(Application);
      FormStart.Init(SmilesCount div 5);

      //���������� � ����� ���������� Visible=False
      FormStart.Show;
      Application.ProcessMessages;
      //FormStart.sSkinProvider1.PrepareForm;
      //Application.ProcessMessages;
      //SysTrayPopUpMenuGifImages[0] := TDreamChatImageLoader.GetImage(G_POPUP_EXIT);

      //FormStart.Gauge1.MaxValue := SmilesCount div 5; // TODO: we need to correctly handle the case of SmilesCount=0 here
      MaxSmileLen := 0;
      delim := MemIniSmilesFile.ReadString('Options', 'Delimiter', '~');

      FilePath := TPathBuilder.GetSmilesFolderName; // ExePath + 'Smiles\';
      for n := 0 to SmilesCount - 1 do
        begin
        SmileFileName := MemIniSmilesFile.ReadString('Smiles', Section.Strings[n], '');
        if FileExists(FilePath + SmileFileName) then
          begin
          //���� �� ������� ����������
          SmilesGIFImages[n] := TGif.Create;
          //s := Section.Strings[n];
          //MessageBox(0, PChar(Section.Strings[n]), 'Section.Strings[n]=', mb_ok);
          DelimitersCount := GetDelimitersCount(Section.Strings[n], delim);
          for par := 0 to DelimitersCount do
            begin
            s := GetParamX(Section.Strings[n], par, delim, True);
            if length(s) > MaxSmileLen then MaxSmileLen := length(s);
            MBSmilesName.Add(s + '=' + IntToStr(n));
            //MessageBox(0, PChar(s + '=' + inttostr(n)), PChar('par = ' + inttostr(par)), mb_ok);
            end;

          MS.LoadFromFile(FilePath + SmileFileName);
          SmilesGIFImages[n].LoadFromStream(MS);
          AFormSmiles.ChatView1.AddGifAni(GetParamX(Section.Strings[n], 0, delim, True), SmilesGIFImages[n], False, nil);

          if (n mod 5) = 0 then
            begin
            FormStart.MoveProgress(SmileFileName, n);
            //FormStart.sLabel2.Caption := SmileFileName;
            //FormStart.Gauge1.Progress := FormStart.Gauge1.Progress + 1;
            Application.ProcessMessages;
            end;
          end
        else
          begin
          //���� �� ������� �� ����������, ������ ��������� �������
          //�������� � ���, ��� �� � �������� ������ �������� ����� ������ �����!!
          //����� ������� ��������� ������ ��� ����!!
          {DelimitersCount := GetDelimitersCount(Section.Strings[n], delim);
          for par := 0 to DelimitersCount do
          begin
          s := GetParamX(Section.Strings[n], par, delim, true);
          MBSmilesName.Add(s + '=' + inttostr(n));
          end;}
          AFormSmiles.ChatView1.AddText(SmileFileName, NORMALTEXTSTYLE, nil);
          end;
        end;
      //Application.ShowMainForm := true;
      //FormMain.Visible := True;
      TDebugMan.AddLine1(MBSmilesName.Text); //FormDebug.DebugMemo1.Lines := MBSmilesName;
      AFormSmiles.ChatView1.Format;
      AFormSmiles.ChatView1.CursorSelection := True;
    finally
      MS.Free;
      FormStart.Close;
      FormStart.Free;//Destroy;
    end;
    end;
  MemIniSmilesFile.Free;

  {---------- ��������� ������� ��� ���������� ������ --------------}
  if InitError = False then
    begin
    Section.Clear;
    try
    //InitDictionary := TMemIniFile.Create(TPathBuilder.GetExePath() + ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.Language {'Language'}, 'Languages\English.lng'));
    InitDictionary := TMemIniFile.Create(TPathBuilder.GetExePath() + TDreamChatConfig.GetLanguageFileName());
    FDictionaryEng := TStringList.Create;
    FDictionaryRus := TStringList.Create;

    ExceptSymbols := InitDictionary.ReadString('ExceptDictWords', 'ExceptSymbols', ',.[]');

    InitDictionary.ReadSectionValues('EngToLocale', Section);
    for n := 0 to Section.Count - 1 do
      begin
      EngWord := Section.Names[n];
      if MaxDxEng < Length(EngWord) then MaxDxEng := Length(EngWord);
      RusWord := GetParamX(Section.Strings[n], 1, '=', true);
      FDictionaryEng.Add(EngWord + '=' + RusWord);
      end;
    Section.Clear;
    InitDictionary.ReadSectionValues('LocaleToEng', Section);
    for n := 0 to Section.Count - 1 do
      begin
      RusWord := Section.Names[n];
      if MaxDxRus < Length(RusWord) then MaxDxRus := Length(RusWord);
      EngWord := GetParamX(Section.Strings[n], 1, '=', true);
      FDictionaryRus.Add(RusWord + '=' + EngWord);
      end;
    except
      on E: Exception do
        begin
        sMessageDlg(E.Message, 'section [EngToRus] in ' + TPathBuilder.GetExePath() +
                  TDreamChatConfig.GetLanguageFileName()  +
                  ' not found!', mtError, [mbOk], 0);
        InitError := true;
        end;
    end;
    Direct := RusToEng;
    InitDictionary.Free;
    {------------------------}

    MainLine := TChatLine.Create(TDreamChatDefaults.MainChatLineName {'iTCniaM'}, PageControl1, CVStyle1);
    ChatLines.AddObject(TDreamChatDefaults.MainChatLineName {'iTCniaM'}, MainLine);
    MainLine.AutoRefreshTime := TDreamChatConfig.GetAutoRefreshTime(); //ChatConfig.ReadInteger(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.AutoRefreshTime {'AutoRefreshTime'}, 1800000);//180 ���
    MainLine.ChatLineView.OnDebug := Debug;
    MainLine.OnCmdConnect := OnCmdConnect;
    MainLine.OnCmdDisconnect := OnCmdDisconnect;
    MainLine.OnCmdText := OnCmdText;
    MainLine.OnCmdRefresh := OnCmdRefresh;
    MainLine.OnCmdReceived := OnCmdReceived;
    MainLine.OnCmdRename := OnCmdRename;
    MainLine.OnCmdBoard := OnCmdBoard;
    MainLine.OnCmdStatus := OnCmdStatus;
    MainLine.OnCmdStatus_Req := OnCmdStatus_Req;
    MainLine.OnCmdRefresh_Board := OnCmdRefresh_Board;
    MainLine.OnCmdCREATE := OnCmdCREATE;
    MainLine.OnCmdCREATELINE := OnCmdCREATELINE;
    MainLine.ChatLineTree.OnDblClick := TreeViewDblClick;
    MainLine.ChatLineTree.OnClick := TreeViewClick;
    MainLine.ChatLineTree.NodeDataSize := SizeOf(TDataNode);
    //MainLine.ChatLineTree.ReadOnly := true;
    MainLine.ChatLineTabSheet.PageIndex := 0;
    MainLine.DisplayChatLineName := fmInternational.Strings[I_CommonChat];
    MainLine.LineType := LT_COMMON;
    MainLine.LineID := 0;
    MainLine.ChatLineTabSheet.Tag := MainLine.LineID;
    MainLine.ChatLineTabSheet.Caption := fmInternational.Strings[I_CommonChat]+CloseBtnString;

    FormMain.TabSheet2.Caption := fmInternational.Strings[I_MESSAGESBOARD];//������� ����� �����

    DynamicPopupMenu := TDynamicVTHPopupMenu.CreateDVTH(nil, MainLine);
    //SetupLocalHook;

//  if InitError = false then
//    begin
//    TDreamChatConfig.FillMessagesState0(Section);
{    FormMain.ChatConfig.ReadSectionValues('MessagesState0', Section);
    if Section.Count > 0 then
      s2 := Section.Strings[0]
    else
      s2 := TDreamChatConfig.DefaultHiAll;}

//    s2 := Section.Strings[0];
    Section.Free;
    end;

  {��� ������� ��������� ������� ������ �� Config.ini}
//  SysKey := 0;
//  TempSysKey := 0;
//  KeyChar := #0;
//  VK := 0;
//  i := 0;
  //s2 := ChatConfig.ReadString('HotKeys', 'AppBringToFront', '');
  TDebugMan.AddLine2(RegisterHotKeyFromString(FormMain.Handle, TDreamChatConfig.GetAppBringToFront));

  TimerJob.Enabled := True;
  end
else
  begin
  FormMain.Close; //������� AV ���� �� ��� �������������������
  end;
END;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var n, i:cardinal;
    tLocalUser:TChatUser;
begin
  if FormAbout <> nil then FreeAndNil(FormAbout);
  //if FSettings <> nil then FSettings.Close;

  UnRegisterHotKey(FormMain.Handle, 0);
  //ErrorLog.SaveToFile('ErrorLog.txt');

  Closing := True;
  Application.OnIdle := nil;
  TimerRefreshAllMessageBoard.Enabled := false;
  TimerRefreshAllMessageBoard.Free;
  TimerJob.Enabled := false;
  TimerJob.Free;
  JobsList.SaveToFile(TPathBuilder.GetJobsIniFileName() {ExePath+'Jobs.ini'});
  JobsList.Free;

  //�������� Disconnect �� ��� �������� �����
  if InitError = false then
    begin
    for n := 0 to ChatLines.Count - 1 do
      begin
      //���� �� ������� �����
      if TChatLine(ChatLines.Objects[n]).ChatLineName <> TDreamChatDefaults.MainChatLineName {'iTCniaM'} then
        begin
        //���� ������� �� ��������� Disconnect
        for i := 0 to TChatLine(ChatLines.Objects[n]).UsersCount - 1 do
          begin
          tLocalUser := TChatLine(ChatLines.Objects[n]).GetUserInfo(TChatLine(ChatLines.Objects[n]).GetLocalUserID());
          //����� ����
          if tLocalUser <> nil then
            begin
            if tLocalUser.ComputerName <> TChatLine(ChatLines.Objects[n]).ChatLineUsers[i].ComputerName then
              begin
              SendCommDisconnect(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName),
                                 PChar(TChatLine(ChatLines.Objects[n]).ChatLineUsers[i].ComputerName),
                                 PChar(TChatLine(ChatLines.Objects[n]).ChatLineName));
              end;
            end;
          end;
        end;
      end;
    tLocalUser := FormMain.GetMainLine.GetLocalUser;
    if tLocalUser <> nil then SendCommDisconnect(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName), '*',
                                                 TDreamChatDefaults.MainChatLineName {'iTCniaM'});
    //MainLine.ChatLineView.Clear;//����� ��� �������� ���� ��-�� �����!!!!!!!! � ������ ��������
    While ChatLines.Count > 0 do
      begin
      TChatLine(ChatLines.Objects[0]).Destroy;
      ChatLines.Delete(0);
      end;
    end;
if Assigned(CommunicationShutDown) then
  begin
  MainLoopTimer.Enabled := False;
  CommunicationShutDown();
  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var n: integer;
    srtlist: TStringList;
begin
SoundShutDown();

DynamicPopupMenu.Free;

FSettings.free;
FSettings := nil;

//��������� ��� �� �������� ���� � ������� �����������
while FormPopUpMessageList.Count > 0 do
  begin
  if FormPopUpMessageList.Objects[FormPopUpMessageList.Count - 1] <> nil then
    begin
    TFormPopUpMessage(FormPopUpMessageList.Objects[FormPopUpMessageList.Count - 1]).Free;
    FormPopUpMessageList.Objects[FormPopUpMessageList.Count - 1] := nil;
    end;
  //��������� �� ������ FormPopUpMessageList ��������� � FormPopUpMessageList.Destroy!!
  //��� ��� �� �������! ��� ������� ������, ��� ��������� ���� ������ ���� ������� ��� ��������
  end;
FormPopUpMessageList.Free;

//RemoveLocalHook;
FDictionaryEng.Free;
FDictionaryRus.Free;

//MainThread.Terminate; //������ ������ ������������ ������, ��� ��� ��� �� ���������
//MainThread.Destroy;
  //� MainLine.ChatLineView �� ��� ����� ������� ����������!!!
  //������ ����: ������ �� ����� ���� READ!!! ��������� �� �������
sChatView2.Clear;//� ����� �������� ������, ��� ����� ���� ������ ����� :-)

RxTrayIcon.Hide;
RxTrayIcon.Free;

RxTrayMess.Hide;
RxTrayMess.Free;

if ChatLines.Count > 0 then
begin
  for n := 0 to ChatLines.Count - 1 do
  begin
    TChatLine(ChatLines.Objects[n]).ChatLineView.Clear;
    TChatLine(ChatLines.Objects[n]).Free;
    ChatLines.Objects[n] := nil;
  end;
end;

FreeAndNil(ChatLines);

//DefaultUser.UpdateFile;
DefaultUser.Free;

//SysTrayPopUpMenuGifImages[0].Free;

for n := 0 to Length(SmilesGIFImages) - 1 do
  begin
  SmilesGIFImages[n].Free;
  end;
Setlength(SmilesGIFImages, 0);

TDreamChatConfig.SetMinimizeOnClose(MinimizeOnClose);

  SaveSkinParameters;

AllKnownChatLines.Free;
UserListCNS_Private.Free;
UserListCNS_Personal.Free;

MBSmilesName.Free;
LinksKeyWordList.Free;
//ChatConfig.UpdateFile;
//ChatConfig.Free;
//MainThread.Free;

FreeLibrary(CommunicationLibHandle);//CommunicationShutDown() ������� ����

//��������� ��������� �����
srtlist := TStringList.Create;
srtlist.Text := ComponentToString(FormMain);
srtlist.SaveToFile(TPathBuilder.GetComponentsFolderName + 'FForm.txt');
srtlist.Free;

EInternational.Free;
fmInternational.Free;

FreeAndNil(AFormSmiles);

{for n := InitTab.Count - 1 downto 0 do
  begin
  MetaClass := GetClass(InitTab.Strings[n]);
  if MetaClass <> nil then
    begin
    ErrorLog.Add('MetaClass = ' + MetaClass.ClassName);
    ErrorLog.SaveToFile('ErrorLog.txt');
    (InitTab.Objects[n] as MetaClass).free;
    end
  else
    InitTab.Objects[n].free;
  end;}

ErrorLog.SaveToFile(TPathBuilder.GetExePath() + 'ErrorLog.txt');
ErrorLog.Free;


while CallBackMessagesList.Count > 0 do
  begin
  TCallBackMessageData(CallBackMessagesList.Objects[0]).free;
  CallBackMessagesList.Objects[0] := nil;
  CallBackMessagesList.delete(0);
  end;

CallBackMessagesList.Free;
end;

procedure TFormMain.PageControl1Change(Sender: TObject);
var ActiveChatLine: TChatLine;
//    c: cardinal;
begin
ActiveChatLine := GetActiveChatLine();
if ActiveChatLine <> nil then
  begin
  TDebugMan.AddLine1('ActiveChatLine = ' + ActiveChatLine.ChatLineName); //FormDebug.DebugMemo1.Lines.Add('ActiveChatLine = ' + ActiveChatLine.ChatLineName);
  //�������������� ������� ����� � ������
  {for c := 0 to ActiveChatLine.UsersCount - 1 do
    begin
    //FormMain.ShowAllUserInTree();
    end;}
  FormMain.ShowAllUserInTree(ActiveChatLine);
  end
else
  TDebugMan.AddLine1('Active = ' + PageControl1.ActivePage.Caption); //FormDebug.DebugMemo1.Lines.Add('Active = ' + PageControl1.ActivePage.Caption);

if (PageControl1.Pages[PageControl1.ActivePageIndex].FindChildControl('sChatView2') <> nil) then
  begin
  //�� ����� ������������� �� �������� � ������ ����������
  if Memo1.Tag = 1 then
    begin
    Edit1.Visible := false;
    Memo1.Visible := true;
    Splitter1.Visible := true;
    panel3.Height := panel3.Tag;
    Memo1.SetFocus;
    end
  else
    begin
    Edit1.SetFocus;
    end;
  end
else
  begin
  //���� ��� �������� ��������� ����� ���������� ��������� ����� �������� �� ����� �����
  //����� �������� � ���������� ������� Edit1.
  Splitter1.Visible := false;
  panel3.Height := Edit1.Height + 4;
  Edit1.Visible := True;
  Edit1.SetFocus;
  Memo1.Visible := false;
  end;
end;

procedure TFormMain.TreeViewClick(Sender: TObject);
var VirtualNode: PVirtualNode;
    n, i:cardinal;
    tUser:TChatUser;
    PDNode: PDataNode;
    CurrentLine:TChatLine;
    LineNode:TLineNode;
begin
TDebugMan.Clear1(); //FormDebug.DebugMemo1.Lines.Clear;
CurrentLine := GetActiveChatLine();
if CurrentLine <> nil then
  begin
  VirtualNode := CurrentLine.ChatLineTree.FocusedNode;
  PDNode := CurrentLine.ChatLineTree.GetNodeData(VirtualNode);
  if PDNode <> nil then
    begin
    case PDNode.DataType of
    dtUser:
      begin
      //id := PDNode.DataUserId;
      //tUser := CurrentLine.GetUserInfo(id);
      tUser := PDNode.User;
      if tUser <> nil then
        begin
        TDebugMan.AddLine1('CurrentLine : ' + CurrentLine.ChatLineName); //FormDebug.DebugMemo1.Lines.Add('CurrentLine : ' + CurrentLine.ChatLineName);
        TDebugMan.AddLine1('UserID : ' + inttostr(tUser.UserID)); //FormDebug.DebugMemo1.Lines.Add('UserID : ' + inttostr(tUser.UserID));
        TDebugMan.AddLine1('NickName : ' + tUser.NickName); //FormDebug.DebugMemo1.Lines.Add('NickName : ' + tUser.NickName);
        TDebugMan.AddLine1('DisplayNickName : ' + tUser.DisplayNickName); //FormDebug.DebugMemo1.Lines.Add('DisplayNickName : ' + tUser.DisplayNickName);
        TDebugMan.AddLine1('ComputerName : ' + tUser.ComputerName); //FormDebug.DebugMemo1.Lines.Add('ComputerName : ' + tUser.ComputerName);
        TDebugMan.AddLine1('Login : ' + tUser.Login); //FormDebug.DebugMemo1.Lines.Add('Login : ' + tUser.Login);
        TDebugMan.AddLine1('IP : ' + tUser.IP); //FormDebug.DebugMemo1.Lines.Add('IP : ' + tUser.IP);
        TDebugMan.AddLine1('ProtoName : ' + tUser.ProtoName); //FormDebug.DebugMemo1.Lines.Add('ProtoName : ' + tUser.ProtoName);
        TDebugMan.AddLine1('Status: ' + IntToStr(Ord(tUser.Status))); //FormDebug.DebugMemo1.Lines.Add('Status: ' + IntToStr(Ord(tUser.Status)));
        TDebugMan.AddLine1('CNS_State : ' + inttostr(ord(tUser.CN_State))); //FormDebug.DebugMemo1.Lines.Add('CNS_State : ' + inttostr(ord(tUser.CN_State)));
        TDebugMan.AddLine1('IsExpanded = ' + inttostr(byte(tUser.IsExpanded))); //FormDebug.DebugMemo1.Lines.Add('IsExpanded = ' + inttostr(byte(tUser.IsExpanded)));

        //FormDebug.Memo1.Lines.Add('AbsoluteIndex = ' + inttostr(CurrentLine.ChatLineTree.AbsoluteIndex(VirtualNode)));
        //FormDebug.Memo1.Lines.Add('tUser.VirtualNode.Index = ' + inttostr(tUser.VirtualNode.Index));
        //������� ������ ����� � ������� ������� ���� ���� ����
        //��� ����� ���� ����� �� ��������� ����� � ������� ��������� ���� ��� �� �����
        if (tUser.ChatLinesList.Count > 0) {and (CurrentLine.LineName = 'iTCniaM')} then
          begin
          for n := 0 to tUser.ChatLinesList.Count - 1 do
            begin
            TDebugMan.AddLine1('ChatLinesList : ' + tUser.ChatLinesList.Strings[n]); //FormDebug.DebugMemo1.Lines.Add('ChatLinesList : ' + tUser.ChatLinesList.Strings[n]);
            LineNode := TLineNode(tUser.ChatLinesList.Objects[n]);
            if LineNode <> nil then
              begin
              TDebugMan.AddLine1('    LineName: ' + LineNode.LineName); //FormDebug.DebugMemo1.Lines.Add('    LineName: ' + LineNode.LineName);
              TDebugMan.AddLine1('    LineID: ' + inttostr(LineNode.LineID)); //FormDebug.DebugMemo1.Lines.Add('    LineID: ' + inttostr(LineNode.LineID));
              TDebugMan.AddLine1('    DisplayLineName: ' + LineNode.DisplayLineName); //FormDebug.DebugMemo1.Lines.Add('    DisplayLineName: ' + LineNode.DisplayLineName);
              if LineNode.LineType = LT_COMMON then TDebugMan.AddLine1('    LineType: LT_COMMON'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON');
              if LineNode.LineType = LT_PRIVATE_CHAT then TDebugMan.AddLine1('    LineType: LT_PRIVATE_CHAT'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_PRIVATE_CHAT');
              if LineNode.LineType = LT_LINE then TDebugMan.AddLine1('    LineType: LT_COMMON_LINE'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON_LINE');
              TDebugMan.AddLine1('    CreatedByCommand: ' + LineNode.CreatedByCommand); //FormDebug.DebugMemo1.Lines.Add('    CreatedByCommand: ' + LineNode.CreatedByCommand);
              TDebugMan.AddLine1('    LineOwner: ' + LineNode.LineOwner); //FormDebug.DebugMemo1.Lines.Add('    LineOwner: ' + LineNode.LineOwner);
              //FormDebug.Memo1.Lines.Add('    NickName: ' + LineNode.NickName);
              //FormDebug.Memo1.Lines.Add('    DisplayNickName: ' + LineNode.DisplayNickName);
              //FormDebug.Memo1.Lines.Add('    Login: ' + LineNode.Login);
              //FormDebug.Memo1.Lines.Add('    IP: ' + LineNode.IP);
              TDebugMan.AddLine1('    LineUsers: ' + LineNode.LineUsers.Text); //FormDebug.DebugMemo1.Lines.Add('    LineUsers: ' + LineNode.LineUsers.Text);
              end;
            end;
          end;
        //������� ������� ��������� �������-�����
        for n := 0 to ChatLines.Count - 1 do
          begin
          for i := 0 to Length(TChatLine(ChatLines.Objects[n]).ChatLineUsers) - 1 do
            begin
            if tUser.ComputerName = TChatLine(ChatLines.Objects[n]).ChatLineUsers[i].ComputerName then
              begin
              TDebugMan.AddLine1('LinesList objects: ' + TChatLine(ChatLines.Objects[n]).ChatLineUsers[i].LineName); //FormDebug.DebugMemo1.Lines.Add('LinesList objects: ' + TChatLine(ChatLines.Objects[n]).ChatLineUsers[i].LineName);
              end;
            end;
          end;
//        FormDebug.Memo1.Lines.Add('DisplayLinesList: ' + tUser.ChatLinesList.text);
        TDebugMan.AddLine1('Version : ' + tUser.Version); //FormDebug.DebugMemo1.Lines.Add('Version : ' + tUser.Version);
        TDebugMan.AddLine1('TimeOfLastUpdate : ' + inttostr(tUser.TimeLastUpdate)); //FormDebug.DebugMemo1.Lines.Add('TimeOfLastUpdate : ' + inttostr(tUser.TimeLastUpdate));
        TDebugMan.AddLine1('TimeOfLastMess : ' + inttostr(tUser.TimeOfLastMess)); //FormDebug.DebugMemo1.Lines.Add('TimeOfLastMess : ' + inttostr(tUser.TimeOfLastMess));
        TDebugMan.AddLine1('ReceivedMessCount : ' + inttostr(tUser.ReceivedMessCount)); //FormDebug.DebugMemo1.Lines.Add('ReceivedMessCount : ' + inttostr(tUser.ReceivedMessCount));
        TDebugMan.AddLine1('PrivateMessCount : ' + inttostr(tUser.PrivateMessCount)); //FormDebug.DebugMemo1.Lines.Add('PrivateMessCount : ' + inttostr(tUser.PrivateMessCount));
        TDebugMan.AddLine1('LastReceivedMessNumber : ' + inttostr(tUser.LastReceivedMessNumber)); //FormDebug.DebugMemo1.Lines.Add('LastReceivedMessNumber : ' + inttostr(tUser.LastReceivedMessNumber));
        TDebugMan.AddLine1('LastRefreshMessNumber : ' + inttostr(tUser.LastRefreshMessNumber)); //FormDebug.DebugMemo1.Lines.Add('LastRefreshMessNumber : ' + inttostr(tUser.LastRefreshMessNumber));
        TDebugMan.AddLine1('MessageStatus : ' + tUser.MessageStatus.CommaText); //FormDebug.DebugMemo1.Lines.Add('MessageStatus : ' + tUser.MessageStatus.CommaText);
        TDebugMan.AddLine1('MessageBoard : ' + tUser.MessageBoard.CommaText); //FormDebug.DebugMemo1.Lines.Add('MessageBoard : ' + tUser.MessageBoard.CommaText);

        TDebugMan.AddLine1('UserListCNS_Private : ' + UserListCNS_Private.CommaText); //FormDebug.DebugMemo1.Lines.Add('UserListCNS_Private : ' + UserListCNS_Private.CommaText);
        TDebugMan.AddLine1('UserListCNS_Personal : ' + UserListCNS_Personal.CommaText); //FormDebug.DebugMemo1.Lines.Add('UserListCNS_Personal : ' + UserListCNS_Personal.CommaText);
        end;
      end;
    dtPrivateChat:
      begin
      //������� ���������� ���� � ������ "����������� �����" ��� ������� � ������ ��
      //���� ����� PRIVATE CHAT
      TDebugMan.Clear1; //FormDebug.DebugMemo1.Lines.Clear;
      //FormDebug.Memo1.Lines.Add('VirtualNode.Index = ' + inttostr(VirtualNode.Index));
      TDebugMan.AddLine1('AllKnownChatLines.Count = ' + inttostr(AllKnownChatLines.Count)); //FormDebug.DebugMemo1.Lines.Add('AllKnownChatLines.Count = ' + inttostr(AllKnownChatLines.Count));
      if (AllKnownChatLines.Count > 0) {and (CurrentLine.LineName = 'iTCniaM')} then
        begin
        for n := 0 to AllKnownChatLines.Count - 1 do
          begin
          TDebugMan.AddLine1('AllKnownChatLines[' + inttostr(n) + ']: ' + AllKnownChatLines.Strings[n]); //FormDebug.DebugMemo1.Lines.Add('AllKnownChatLines[' + inttostr(n) + ']: ' + AllKnownChatLines.Strings[n]);
          LineNode := TLineNode(AllKnownChatLines.Objects[n]);
          if LineNode <> nil then
            begin
            TDebugMan.AddLine1('    LineName: ' + LineNode.LineName); //FormDebug.DebugMemo1.Lines.Add('    LineName: ' + LineNode.LineName);
            TDebugMan.AddLine1('    LineID: ' + inttostr(LineNode.LineID)); //FormDebug.DebugMemo1.Lines.Add('    LineID: ' + inttostr(LineNode.LineID));
            TDebugMan.AddLine1('    LineOwnerID (UserID): ' + inttostr(LineNode.LineOwnerID)); //FormDebug.DebugMemo1.Lines.Add('    LineOwnerID (UserID): ' + inttostr(LineNode.LineOwnerID));
            TDebugMan.AddLine1('    DisplayLineName: ' + LineNode.DisplayLineName); //FormDebug.DebugMemo1.Lines.Add('    DisplayLineName: ' + LineNode.DisplayLineName);
            //FormDebug.Memo1.Lines.Add('    AbsoluteIndex = ' + inttostr(PDNode.AbsoluteNodeIndex));
            //FormDebug.Memo1.Lines.Add('    AbsoluteIndex = ' + inttostr(CurrentLine.ChatLineTree.AbsoluteIndex(VirtualNode)));
            if LineNode.LineType = LT_COMMON then TDebugMan.AddLine1('    LineType: LT_COMMON'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON');
            if LineNode.LineType = LT_PRIVATE_CHAT then TDebugMan.AddLine1('    LineType: LT_PRIVATE_CHAT'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_PRIVATE_CHAT');
            if LineNode.LineType = LT_LINE then TDebugMan.AddLine1('    LineType: LT_COMMON_LINE'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON_LINE');
            TDebugMan.AddLine1('    CreatedByCommand: ' + LineNode.CreatedByCommand); //FormDebug.DebugMemo1.Lines.Add('    CreatedByCommand: ' + LineNode.CreatedByCommand);
            TDebugMan.AddLine1('    LineOwner: ' + LineNode.LineOwner); //FormDebug.DebugMemo1.Lines.Add('    LineOwner: ' + LineNode.LineOwner);
            //FormDebug.Memo1.Lines.Add('    NickName: ' + LineNode.NickName);
            //FormDebug.Memo1.Lines.Add('    DisplayNickName: ' + LineNode.DisplayNickName);
            //FormDebug.Memo1.Lines.Add('    Login: ' + LineNode.Login);
            //FormDebug.Memo1.Lines.Add('    IP: ' + LineNode.IP);
            TDebugMan.AddLine1('    LineUsers: ' + LineNode.LineUsers.Text); //FormDebug.DebugMemo1.Lines.Add('    LineUsers: ' + LineNode.LineUsers.Text);
            end;
          end;
        end;
      end;
    dtLine:
      begin
      //������� ���������� ���� � ������ "����������� �����" ��� ������� � ������ ��
      //���� ����� LINE
      TDebugMan.Clear1; //FormDebug.DebugMemo1.Lines.Clear;

      //FormDebug.Memo1.Lines.Add('VirtualNode.Index = ' + inttostr(VirtualNode.Index));
      TDebugMan.AddLine1('AllKnownChatLines.Count = ' + inttostr(AllKnownChatLines.Count)); //FormDebug.DebugMemo1.Lines.Add('AllKnownChatLines.Count = ' + inttostr(AllKnownChatLines.Count));
      if (AllKnownChatLines.Count > 0) {and (CurrentLine.LineName = 'iTCniaM')} then
        begin
        for n := 0 to AllKnownChatLines.Count - 1 do
          begin
          TDebugMan.AddLine1('AllKnownChatLines[' + inttostr(n) + ']: ' + AllKnownChatLines.Strings[n]); //FormDebug.DebugMemo1.Lines.Add('AllKnownChatLines[' + inttostr(n) + ']: ' + AllKnownChatLines.Strings[n]);
          LineNode := TLineNode(AllKnownChatLines.Objects[n]);
          if LineNode <> nil then
            begin
            if LineNode.IsExpanded = true
              then TDebugMan.AddLine1('IsExpanded = true') //FormDebug.DebugMemo1.Lines.Add('IsExpanded = true')
              else TDebugMan.AddLine1('IsExpanded = false'); //FormDebug.DebugMemo1.Lines.Add('IsExpanded = false');
            TDebugMan.AddLine1('    LineName: ' + LineNode.LineName); //FormDebug.DebugMemo1.Lines.Add('    LineName: ' + LineNode.LineName);
            TDebugMan.AddLine1('    LineID: ' + inttostr(LineNode.LineID)); //FormDebug.DebugMemo1.Lines.Add('    LineID: ' + inttostr(LineNode.LineID));
            TDebugMan.AddLine1('    LineOwnerID (UserID): ' + inttostr(LineNode.LineOwnerID)); //FormDebug.DebugMemo1.Lines.Add('    LineOwnerID (UserID): ' + inttostr(LineNode.LineOwnerID));
            TDebugMan.AddLine1('    DisplayLineName: ' + LineNode.DisplayLineName); //FormDebug.DebugMemo1.Lines.Add('    DisplayLineName: ' + LineNode.DisplayLineName);
            //FormDebug.Memo1.Lines.Add('    AbsoluteIndex = ' + inttostr(PDNode.AbsoluteNodeIndex));
            //FormDebug.Memo1.Lines.Add('    AbsoluteIndex = ' + inttostr(CurrentLine.ChatLineTree.AbsoluteIndex(VirtualNode)));
            if LineNode.LineType = LT_COMMON then TDebugMan.AddLine1('    LineType: LT_COMMON'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON');
            if LineNode.LineType = LT_PRIVATE_CHAT then TDebugMan.AddLine1('    LineType: LT_PRIVATE_CHAT'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_PRIVATE_CHAT');
            if LineNode.LineType = LT_LINE then TDebugMan.AddLine1('    LineType: LT_COMMON_LINE'); //FormDebug.DebugMemo1.Lines.Add('    LineType: LT_COMMON_LINE');
            TDebugMan.AddLine1('    CreatedByCommand: ' + LineNode.CreatedByCommand); //FormDebug.DebugMemo1.Lines.Add('    CreatedByCommand: ' + LineNode.CreatedByCommand);
            TDebugMan.AddLine1('    LineOwner: ' + LineNode.LineOwner); //FormDebug.DebugMemo1.Lines.Add('    LineOwner: ' + LineNode.LineOwner);
            //FormDebug.Memo1.Lines.Add('    NickName: ' + LineNode.NickName);
            //FormDebug.Memo1.Lines.Add('    DisplayNickName: ' + LineNode.DisplayNickName);
            //FormDebug.Memo1.Lines.Add('    Login: ' + LineNode.Login);
            //FormDebug.Memo1.Lines.Add('    IP: ' + LineNode.IP);
            TDebugMan.AddLine1('    LineUsers: ' + LineNode.LineUsers.Text); //FormDebug.DebugMemo1.Lines.Add('    LineUsers: ' + LineNode.LineUsers.Text);
            end;
          end;
        end;
      end;
      end;//end_case
    end;
  end;
end;

procedure TFormMain.TreeViewDblClick(Sender: TObject);
var VirtualNode: PVirtualNode;
    PDNode: PDataNode;
    ActiveChatLine:TChatLine;
begin
ActiveChatLine := GetActiveChatLine();
VirtualNode := ActiveChatLine.ChatLineTree.FocusedNode;
PDNode := ActiveChatLine.ChatLineTree.GetNodeData(VirtualNode);
Edit1.SetFocus;
if (PDNode <> nil) and (PDNode.DataType = dtUser) then
  //Edit1.Text := '/msg "' + ActiveChatLine.ChatLineUsers[PDNode.DataUserId].DisplayNickName + '" ';
  Edit1.Text := '/msg "' + PDNode.User.DisplayNickName + '" ';

//Edit1.Perform(WM_KEYDOWN, VK_END, 0);
Edit1.SelStart := length(Edit1.Text);
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
Edit1.Width := FormMain.Width - Panel2.Width - 14;
Memo1.Width := FormMain.Width - Panel2.Width - 14;
panel3.Height := Edit1.Height + 4;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TFormMain.N1Click(Sender: TObject);
begin
FormMain.Close;
end;

procedure TFormMain.SpeedButton3Click(Sender: TObject);
var tLocalUser: TChatUser;
    s:string;
    MainLine:TChatLine;
begin
MainLine := GetMainLine();
if MainLine <> nil then
  begin
  tLocalUser := Mainline.GetUserInfo(MainLine.GetLocalUserID);
  tLocalUser.Status := dcsNormal;
  s := '*';
  SendCommStatus(PChar(tLocalUser.ProtoName), PChar(s), Ord(tLocalUser.Status),
                 PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
  //ShowUserInTree(MainLine, tLocalUser.UserID, ShowUser_REDRAW);
  ShowAllUserInTree(MainLine);
  RxTrayIcon.Icon := RxTrayIcon.Icons.Icons[0];
  end;
end;

procedure TFormMain.SpeedButton3MouseDown(Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
if Button = mbRight then
  begin
  TsSpeedButton(Sender).Down := True;
  p.X := X;
  p.Y := Y;
  p := (Sender as TControl).ClientToScreen(p);
  DynamicPopupMenu.OnComponentClick(TComponent(Sender), p.X, p.Y {MouseX, MouseY});
  RxTrayIcon.Icon := RxTrayIcon.Icons.Icons[0];
  end;
end;

procedure TFormMain.SpeedButton4Click(Sender: TObject);
var tLocalUser: TChatUser;
    s:string;
    MainLine:TChatLine;
begin
MainLine := GetMainLine();
if MainLine <> nil then
  begin
  tLocalUser := Mainline.GetUserInfo(MainLine.GetLocalUserID);
  if tLocalUser <> nil then
    begin
    tLocalUser.Status := dcsBusy;
    s := '*';
    SendCommStatus(PChar(tLocalUser.ProtoName), PChar(s), Ord(tLocalUser.Status),
                   PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
    //ShowUserInTree(MainLine, tLocalUser.UserID, ShowUser_REDRAW);
    ShowAllUserInTree(MainLine);
    RxTrayIcon.Icon := RxTrayIcon.Icons.Icons[Ord(dcsBusy)];
    end;
  end;
end;

procedure TFormMain.SpeedButton5Click(Sender: TObject);
var tLocalUser: TChatUser;
    s:string;
    MainLine:TChatLine;
begin
MainLine := GetMainLine();
if MainLine <> nil then
  begin
  tLocalUser := Mainline.GetUserInfo(MainLine.GetLocalUserID);
  if tLocalUser <> nil then
    begin
    tLocalUser.Status := dcsDND;
    s := '*';
    SendCommStatus(PChar(tLocalUser.ProtoName), PChar(s), Ord(tLocalUser.Status),
                   PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
    //ShowUserInTree(MainLine, tLocalUser.UserID, ShowUser_REDRAW);
    ShowAllUserInTree(MainLine);
    RxTrayIcon.Icon := RxTrayIcon.Icons.Icons[Ord(dcsDND)];
    end;
  end;
end;

procedure TFormMain.SpeedButton6Click(Sender: TObject);
var tLocalUser: TChatUser;
    s:string;
    MainLine:TChatLine;
begin
MainLine := GetMainLine();
if MainLine <> nil then
  begin
  tLocalUser := Mainline.GetUserInfo(MainLine.GetLocalUserID);
  if tLocalUser <> nil then
    begin
    tLocalUser.Status := dcsAway;
    s := '*';
    SendCommStatus(PChar(tLocalUser.ProtoName), PChar(s), Ord(tLocalUser.Status),
                   PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
    //ShowUserInTree(MainLine, tLocalUser.UserID, ShowUser_REDRAW);
    ShowAllUserInTree(MainLine);
    RxTrayIcon.Icon := RxTrayIcon.Icons.Icons[Ord(dcsAway)];
    end;
  end;
end;

procedure TFormMain.RefreshButtonClick(Sender: TObject);
VAR tLocalUser: TChatUser;
    c: cardinal;
    CurrentLine, MainLine:TChatLine;
    RemoteCompName: String;
begin
//������ ������� REFRESH
CurrentLine := GetActiveChatLine();
MainLine := GetMainLine();
if MainLine <> nil then
  begin
  if (CurrentLine <> nil) then
    begin
    tLocalUser := CurrentLine.GetUserInfo(CurrentLine.GetLocalUserID);
    if tLocalUser <> nil then
      begin
      if {(CurrentLine.UsersCount = 1) and}
        (CurrentLine.LineType = LT_LINE) or (CurrentLine.LineType = LT_COMMON) then
        begin
        //� ����� ������ ���� ��������, �������� ���� REFRESH ����� ��� ��� �� ����
        //� ������������� ���� ����� �� �������
        RemoteCompName := '*';
        SendCommRefresh(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), PChar(CurrentLine.ChatLineName),
                        PChar(tLocalUser.NickName),
                        Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 1);
        end;
      for c := 0 to CurrentLine.UsersCount - 1 do
        begin
        if tLocalUser.UserID <> CurrentLine.ChatLineUsers[c].UserID then
          begin
          CurrentLine.ChatLineUsers[c].Status := dcsDisconnected;
          if ChatMode <> cmodTCP then
            //� ������ MailSlot ����� �������� 2 ��������� REFRESH � ����������� ��������
            SendCommRefresh(PChar(CurrentLine.ChatLineUsers[c].ProtoName), PChar(CurrentLine.ChatLineUsers[c].ComputerName), PChar(CurrentLine.ChatLineName), PChar(CurrentLine.ChatLineUsers[c].NickName), Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 0);
          SendCommRefresh(PChar(CurrentLine.ChatLineUsers[c].ProtoName), PChar(CurrentLine.ChatLineUsers[c].ComputerName), PChar(CurrentLine.ChatLineName), PChar(CurrentLine.ChatLineUsers[c].NickName), Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 1);
          if CurrentLine = MainLine then
            //���� ��� ������� �����, �� ����� ��� �������� ������ � ����� '*', ����� ���� ����������� ��� ����� � ������� ���������� ��������� ����
            SendCommRefresh(PChar(CurrentLine.ChatLineUsers[c].ProtoName), PChar(CurrentLine.ChatLineUsers[c].ComputerName), '*', PChar(CurrentLine.ChatLineUsers[c].NickName), Ord(tLocalUser.Status), PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), '*', 1);

          //ShowUserInTree(MainLine, CurrentLine.ChatLineUsers[n].UserID, ShowUser_REDRAW);
          end;
        end;
      ShowAllUserInTree(CurrentLine);
      {SendMessage(application.MainForm.handle,
                  UM_INCOMMINGMESSAGE,
                  UM_INCOMMINGMESSAGE_UpdateTree, CurrentLine.LineID);}
      //ShowUserInTree(CurrentLine, ALL_USERS);
      end;
    end
  else
    begin
    //������ �� �� �������� ����� ����������
    //��������� ������� ����� ������ �� ���������� ����� ����������
    tLocalUser := MainLine.GetLocalUser;
    if tLocalUser <> nil then
      begin
      for c := 0 to MainLine.UsersCount - 1 do
        begin
        SendCommRefresh_Board(PChar(tLocalUser.ProtoName), Pchar(MainLine.ChatLineUsers[c].ComputerName), 1);
        end;
      end;
    end;
  end;
end;

procedure TFormMain.SpeedButton8Click(Sender: TObject);
begin
//if FormDebug <> nil then
//  FormDebug.Visible := not FormDebug.Visible;
  TDebugMan.Toggle();
end;

procedure TFormMain.Edit1KeyPress(Sender: TObject; var Key: Char);
var RemoteCompName, RemoteNickName, sChatLine, Mess, sPassword:string;
    n, id, LUID:cardinal;
    LineNodeID: integer;
    tUser, tLocalUser:TChatUser;
    StrList: TStringList;
    MainLine, ActiveChatLine:TChatLine;
    LockText: boolean;//����� ����� �� ������� � ����� ���
{IFDEF AdminRel}
    srtlst: TStringlist;
{ENDIF AdminRel}
begin
if Key = #13 then
  begin
  MainLine := GetMainLine();
  ActiveChatLine := GetActiveChatLine();
  LockText := false;
  if (MainLine <> nil) and
     (ActiveChatLine <> nil) and
     (MainLine.GetLocalUser <> nil) then
    begin
    ActiveChatLine.MessagesHistory.Add(Edit1.Text);
    //�������� � ���, ��� ���� �� ��������� �� ��������� ���������, ��
    //��� ������� ����� �� �������� �������������
    ActiveChatLine.MessagesHistoryIndex := ActiveChatLine.MessagesHistory.Count {- 1};
    if GetParamX(Edit1.Text, 0, ' ', true) = '/messboard' then
      begin
      LUID := MainLine.GetLocalUserID();
      if LUID <> INVALID_USER_ID then
        begin
        tLocalUser := MainLine.GetUserInfo(LUID);
        if tLocalUser <> nil then
          begin
          //������� ������� ����� ����������
          StrList := TStringList.Create;
          StrList.LoadFromFile(TPathBuilder.GetExePath() + TDreamChatConfig.GetMessageBoard()); //ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.MessageBoard {'MessageBoard'}, 'MessageBoard.txt'));
          tLocalUser.MessageBoard.Assign(StrList);
          StrList.Free;
          for n := 0 to MainLine.UsersCount - 1 do
            begin
            tUser := MainLine.GetUserInfo(n);
            if tUser <> nil then SendCommBoard(PChar(tUser.ProtoName), PChar(tUser.ComputerName), tLocalUser.MessageBoard.GetText, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
            end;
          Edit1.Text := '';
          end;
        end;
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/vote' then //������ ����� = /msg
      begin
      //��������� ������ ��� �����������
      MainLine.ChatLineView.AddTextFromNewLine(MainLine.GetLocalUser().DisplayNickName +
                                   ' VOTE BEGIN: ' +
                                   GetParamX(Edit1.Text, 1, '/vote ', True),
                                   SYSTEMTEXTSTYLE, nil);
      if Button = nil then
        begin
        Button := TsButton.Create(MainLine.ChatLineView);
        Button.OnClick := FormMain.ButtonOnClick;
        Button.Caption := GetParamX(Edit1.Text, 1, '/vote ', true);//�������� ��� ��, ��� ����� \msg XXXXXX
        MainLine.ChatLineView.AddWinControl(button, False, nil);
        end;
      MainLine.ChatLineView.Format;
      MainLine.ChatLineView.Repaint;
      Edit1.Text := '';
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/nickname' then //
      begin
      //�������� ������� ����� ����
      RemoteCompName := '*';
      tLocalUser := ActiveChatLine.GetLocalUser;
      Mess := GetParamX(Edit1.Text, 1, '/nickname ', True);
      SendCommRename(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(Mess));
      //ChatConfig.WriteString('Common', 'NickName', Mess);
      TDreamChatConfig.SetNickName(Mess);
      LocalNickName := Mess;
      //ChatConfig.UpdateFile;
      Edit1.Text := '';
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/me' then
      begin
      //�������� ������� "� ����")))
      LockText := true;//����� ����� �� ������� � ����� ���
      RemoteNickName := GetParamX(Edit1.Text, 1, '"', True);//�������� ��� ��, ��� ����� \msg XXXXXX
      if RemoteNickName = '*' then
        begin
        if (ActiveChatLine <> nil) {and (length(Edit1.Text) > 0)} then
          begin
          Mess := GetParamX(Edit1.Text, 1, '"*"', True);
          Mess := TrimLeft(Mess);
          sChatLine := ActiveChatLine.ChatLineName;
          if ActiveChatLine.LineType <> LT_COMMON then
            begin
            //��� �������� ��������� � �����
            //���� ������� ������ (��� 2� �������)
            for n := 0 to (ActiveChatLine.UsersCount - 1) do
              begin
              //�������� ������� ��������� �������
              SendCommMe(PChar(ActiveChatLine.ChatLineUsers[n].ProtoName), PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
              end;
            end
          else
            begin
            //��� �������� ��������� � ����� �����
            RemoteCompName := '*';
            sChatLine := 'gsMTCI';
            tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserId());
            SendCommMe(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
            ParseAllChatView(tLocalUser.DisplayNickName + ' ' + Mess, MainLine,
                             CVStyle1.TextStyles.Items[METEXTSTYLE], nil, nil, False, True);
            end;
          SendMessage(application.MainForm.handle,
                      UM_INCOMMINGMESSAGE,
                      UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
          Edit1.Text := '';
          exit;
          end;
        end
      else
        begin
        tLocalUser := MainLine.GetLocalUser;
        if tLocalUser <> nil then
          begin
          id := MainLine.GetUserIdByDisplayNickName(RemoteNickName);//�������� id ����
          if id <> INVALID_USER_ID then
            begin
            tUser := MainLine.GetUserInfo(id);
            RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
            Mess := GetParamX(Edit1.Text, 1, RemoteNickName + '" ', True);
            end
          else
            begin
            RemoteCompName := '*';
            Mess := GetParamX(Edit1.Text, 1, '/me ', True);
            end;
            //messagebox(0, PChar('RecpCompName=' + RecpCompName + ' id=' + inttostr(id)), PChar('RecpNickName=' + RecpNickName) ,mb_ok);
            sChatLine := 'gsMTCI';//��������� ����� ��� ������ ������
            SendCommMe(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(RemoteNickName), PChar(Mess), PChar(sChatLine), 1);
            ParseAllChatView(tLocalUser.DisplayNickName + ' ' + Mess, MainLine,
                             CVStyle1.TextStyles.Items[METEXTSTYLE], nil, nil, False, True);
            SendMessage(application.MainForm.handle,
                        UM_INCOMMINGMESSAGE,
                        UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
            Edit1.Text := '';
          end;
        end;
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/msg' then //������ ����� = \msg
      begin
      //��� ��������� � ��������� �����
      //  RecpNickName := GetParamX(Edit3.Text, 1, ' ', true);//�������� ��� ��, ��� ����� \msg XXXXXX
      LockText := true;//����� ����� �� ������� � ����� ���
      RemoteNickName := GetParamX(Edit1.Text, 1, '"', True);//�������� ��� ��, ��� ����� \msg XXXXXX
      if RemoteNickName = '*' then
        begin
        if (ActiveChatLine <> nil) {and (length(Edit1.Text) > 0)} then
          begin
          Mess := GetParamX(Edit1.Text, 1, '"*"', True);
          Mess := TrimLeft(Mess);
          sChatLine := ActiveChatLine.ChatLineName;
          if ActiveChatLine.LineType <> LT_COMMON then
            begin
            //��� �������� ��������� � �����
            //���� ������� ������ (��� 2� �������)
            for n := 0 to (ActiveChatLine.UsersCount - 1) do
              begin
              //�������� ������� ��������� �������
              SendCommText(PChar(ActiveChatLine.ChatLineUsers[n].ProtoName), PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
              end;
            end
          else
            begin
            //��� �������� ��������� � ����� �����
            RemoteCompName := '*';
            sChatLine := 'gsMTCI';
            tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserId());
            if tLocalUser = nil then exit;
            SendCommText(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
//            if ParseAll('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], true) = false then
//              MainLine.ChatLineView.AddFromNewLine('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, PRIVATETEXTSTYLE, nil);
            ParseAllChatView( '<' + tLocalUser.DisplayNickName + '> ',
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             tLocalUser.UserOnLineLI, nil, True, True);//false, true
            ParseAllChatView( '<' + RemoteNickName + '> ',
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             nil, nil, false, false);
            ParseAllChatView( Mess,
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             nil, nil, false, false);
            end;
          SendMessage(application.MainForm.handle,
                      UM_INCOMMINGMESSAGE,
                      UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
          Edit1.Text := '';
          exit;
          end;
        end
      else
        begin
        //������ ���������
        id := MainLine.GetUserIdByDisplayNickName(RemoteNickName);//�������� id ����
        if id <> INVALID_USER_ID then
          begin
          tUser := MainLine.GetUserInfo(id);
          tLocalUser := MainLine.GetLocalUser;
          RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
          //messagebox(0, PChar('RecpCompName=' + RecpCompName + ' id=' + inttostr(id)), PChar('RecpNickName=' + RecpNickName) ,mb_ok);
          Mess := GetParamX(Edit1.Text, 1, '"' + RemoteNickName + '" ', true);
          sChatLine := 'gsMTCI';//��������� ����� ��� ������ ������
          SendCommText(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(tUser.NickName), PChar(Mess), PChar(sChatLine), 1);
//          if ParseAll('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], true) = false then
//            MainLine.ChatLineView.AddFromNewLine('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, PRIVATETEXTSTYLE, nil);
//        MainLine.ChatLineView.Format;
          ParseAllChatView( '<' + tLocalUser.DisplayNickName + '> ',
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           tLocalUser.UserOnLineLI, nil, true, true);//false, true
          ParseAllChatView( '<' + RemoteNickName + '> ',
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           tUser.UserOnLineLI, nil, false, false);
          ParseAllChatView( Mess,
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           nil, nil, false, false);
          SendMessage(application.MainForm.handle,
                      UM_INCOMMINGMESSAGE,
                      UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
          Edit1.Text := GetParamX(Edit1.Text, 0, ' ', true)+' "'+GetParamX(Edit1.Text, 1, '"', true)+'" ';
          Edit1.SelStart := Length(Edit1.Text);
          end;
        end;
      end;
    end
  else
    begin
    //���� ������� ����� �� �����-�� ������� �� ������� - �������
    exit;
    end;

{IFDEF AdminRel}
    if (GetParamX(Edit1.Text, 0, ' ', true) = '/msgfile') or
      (GetParamX(Edit1.Text, 0, ' ', true) = '/msgwinfile') then
      begin
      //��� ��������� � ��������� �����
      LockText := true;//����� ����� �� ������� � ����� ���
      RemoteNickName := GetParamX(Edit1.Text, 1, '"', true);//�������� ��� ��, ��� ����� \msg XXXXXX
      if RemoteNickName = '*' then
        begin
        if (ActiveChatLine <> nil) {and (length(Edit1.Text) > 0)} then
          begin
          Mess := GetParamX(Edit1.Text, 1, '"*"', true);
          Mess := TrimLeft(Mess);
          srtlst := TStringlist.Create;
          if FileExists(Mess) then
            begin
            //��������� ���� � ����������
            try
              srtlst.LoadFromFile(Mess);
            except
              srtlst.Add(Mess);
            end;
            if (GetParamX(Edit1.Text, 0, ' ', true) = '/msgwinfile') then
              begin
              srtlst.Text := DosToWin(srtlst.Text);
              end;
            end
          else
            begin
            srtlst.Add(Mess);
            end;
          sChatLine := ActiveChatLine.ChatLineName;
          if ActiveChatLine.LineType <> LT_COMMON then
            begin
            //��� �������� ��������� � �����
            //���� ������� ������ (��� 2� �������)
            for n := 0 to (ActiveChatLine.UsersCount - 1) do
              begin
              //�������� ������� ��������� �������
              SendCommText(PChar(ActiveChatLine.ChatLineUsers[n].ProtoName), PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), Pchar(''), PChar(srtlst.Text), PChar(sChatLine), 0);
              end;
            end
          else
            begin
            //��� �������� ��������� � ����� �����
            RemoteCompName := '*';
            sChatLine := 'gsMTCI';
            tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserId());
            if tLocalUser = nil then exit;
            SendCommText(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(''), PChar(srtlst.Text), PChar(sChatLine), 0);
//            if ParseAll('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], true) = false then
//              MainLine.ChatLineView.AddFromNewLine('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, PRIVATETEXTSTYLE, nil);
            ParseAllChatView( '<' + tLocalUser.DisplayNickName + '> ',
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             tLocalUser.UserOnLineLI, nil, true, true);
            ParseAllChatView( '<' + RemoteNickName + '> ',
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             nil, nil, false, false);
            ParseAllChatView( Mess,
                             MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                             nil, nil, false, false);
            end;
          SendMessage(application.MainForm.handle,
                      UM_INCOMMINGMESSAGE,
                      UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
          Edit1.Text := '';
          srtlst.Free;
          exit;
          end;
        end
      else
        begin
        //������ ���������
        id := MainLine.GetUserIdByDisplayNickName(RemoteNickName);//�������� id ����
        if id <> INVALID_USER_ID then
          begin
          tUser := MainLine.GetUserInfo(id);
          tLocalUser := MainLine.GetLocalUser;
          RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
          //messagebox(0, PChar('RecpCompName=' + RecpCompName + ' id=' + inttostr(id)), PChar('RecpNickName=' + RecpNickName) ,mb_ok);
          Mess := GetParamX(Edit1.Text, 1, '"' + RemoteNickName + '" ', true);
          srtlst := TStringlist.Create;
          if FileExists(Mess) then
            begin
            //��������� ���� � ����������
            try
              srtlst.LoadFromFile(Mess);
            except
              srtlst.Add(Mess);
            end;
            if (GetParamX(Edit1.Text, 0, ' ', true) = '/msgwinfile') then
              begin
              srtlst.Text := DosToWin(srtlst.Text);
              end;
            end
          else
            begin
            srtlst.Add(Mess);
            end;
          sChatLine := 'gsMTCI';//��������� ����� ��� ������ ������
          SendCommText(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(tUser.NickName), PChar(srtlst.Text), PChar(sChatLine), 1);
//          if ParseAll('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], true) = false then
//            MainLine.ChatLineView.AddFromNewLine('<' + tLocalUser.DisplayNickName + '><' + RemoteNickName + '> ' + Mess, PRIVATETEXTSTYLE, nil);
//        MainLine.ChatLineView.Format;
          ParseAllChatView( '<' + tLocalUser.DisplayNickName + '> ',
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           tLocalUser.UserOnLineLI, nil, true, true);
          ParseAllChatView( '<' + RemoteNickName + '> ',
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           tUser.UserOnLineLI, nil, false, false);
          ParseAllChatView( Mess,
                           MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                           nil, nil, false, false);
          SendMessage(application.MainForm.handle,
                      UM_INCOMMINGMESSAGE,
                      UM_INCOMMINGMESSAGE_Redrawall, MainLine.LineID);
          Edit1.Text := GetParamX(Edit1.Text, 0, ' ', true)+' "'+GetParamX(Edit1.Text, 1, '"', true)+'" ';
          Edit1.SelStart := Length(Edit1.Text);
          srtlst.Free;
          end;
        end;
      end;
{ENDIF AdminRel}

    if GetParamX(Edit1.Text, 0, ' ', true) = '/close' then //������ ����� = \msg
      begin
      if ActiveChatLine <> MainLine then
        begin
        //���� ���������� ������ ������, �� �������� Disconnect ���� �����
        if (ActiveChatLine.UsersCount - 1) > 1 then
          begin
          for n := 0 to (ActiveChatLine.UsersCount - 1) do
            begin
            //�������� ������� ��������� �������
            SendCommDisconnect(
                               PChar(ActiveChatLine.ChatLineUsers[n].ProtoName), PChar(''),
                               PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), PChar(ActiveChatLine.ChatLineName));
            end;
          end
        //���� � ��������� ��������, �� �������� ����������, �����
        //�� ��������� ������ � ���� ����� [+]
        else
          SendCommDisconnect(
                             PChar(MainLine.GetLocalUser.ProtoName),
                             PChar(''), '*', PChar(ActiveChatLine.ChatLineName));
        closing := true;
        Edit1.Text := '';
        end
      else
        begin
          if MinimizeOnClose then
          begin
            MinimizeOnClose := False;
            FormMain.Close;
            MinimizeOnClose := True;
          end
          else
            FormMain.Close;
        end;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/chat' then //������ ����� = \msg
      begin
      LockText := true;
      RemoteNickName := GetParamX(Edit1.Text, 1, '"', true);//�������� ��� ��, ��� ����� \msg XXXXXX
      id := MainLine.GetUserIdByDisplayNickName(RemoteNickName);//�������� id ����
      if (id <> INVALID_USER_ID) then
        begin
        tUser := MainLine.GetUserInfo(id);
        id := MainLine.GetLocalUserID();
        if (id <> INVALID_USER_ID) then
          begin
          tLocalUser := MainLine.GetUserInfo(id);
          RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
          if (RemoteCompName <> tLocalUser.ComputerName) then
            begin
            sChatLine := inttostr(GetTickCount());
            //Create ����
            SendCommCreate(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName), PChar(sChatLine));
            //Create ���������� �����
            SendCommCreate(PChar(tUser.ProtoName), PChar(tUser.ComputerName), PChar(sChatLine));
            //Connect ����
            SendCommConnect(
                            PChar(tLocalUser.ProtoName),
                            PChar(tLocalUser.DisplayNickName),
                            PChar(tLocalUser.ComputerName),
                            PChar(sChatLine), PChar(tLocalUser.ComputerName),
                            PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                            Ord(tLocalUser.Status));
            //Connect ���������� ����� �� ���� �� ��� �������)))
            end;
          end;
        end;
      Edit1.Text := '';
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/connectchat' then
    ///connectline "LINENAME" "PASSWORD"
    //���������� �������������� � ��� ������������ �����
    //TODO: ��������! ��������, ��� � ������ ������ ���� ����� � ����������� �������!!
    //���� �� ��� ��������� �� �����
      begin
      LockText := True;
      sChatLine := GetParamX(Edit1.Text, 1, '"', True);//�������� �������� �������
      LUID := MainLine.GetLocalUserID();
      if (LUID <> INVALID_USER_ID) then
        begin
        tLocalUser := MainLine.GetUserInfo(LUID);
        {ChatLine := FormMain.GetChatLineByName(sChatLine);
        if ChatLine <> nil then
          begin
          //���� ����� �����/������ ��� ����������, ������ �������� ��� TabSheet
          FormMain.PageControl1.ActivePageIndex := ChatLine.ChatLineTabSheet.PageIndex;
          end
        else
          begin}
          //����� �����/������� ���� �� ����������, ������
          //�� ������ ��������� ���� ��������� ������ �� �������, ��� ����,
          //� ������� ����� ��������� ������ ��� ����� � ����� ��, � ������� ����� �������
          for n := 0 to MainLine.UsersCount - 1 do
            begin
            if LUID <> n then
              begin
              //��������� ���� �� ������
              LineNodeID := MainLine.ChatLineUsers[n].ChatLinesList.IndexOf(GetParamX(Edit1.Text, 1, '"', true));
              if LineNodeID >= 0 then
                begin
                //��� ����� ����� �����!!! ��������� �����
                sChatLine := MainLine.ChatLineUsers[n].ChatLinesList.Strings[LineNodeID];
                tUser := MainLine.GetUserInfo(n);
                RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
                if (RemoteCompName <> tLocalUser.ComputerName) then
                  begin
                  //����
                  SendCommCreate(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName), PChar(sChatLine));
                  //���������� �����
                  SendCommConnect(
                                  PChar(tLocalUser.ProtoName),
                                  PChar(tLocalUser.DisplayNickName),
                                  PChar(tUser.ComputerName),
                                  PChar(sChatLine), PChar(tUser.ComputerName),
                                  PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                                  Ord(tLocalUser.Status));
                  //����
                  SendCommConnect(
                                  PChar(tLocalUser.ProtoName),
                                  PChar(tLocalUser.DisplayNickName),
                                  PChar(tLocalUser.ComputerName),
                                  PChar(sChatLine), PChar(tLocalUser.ComputerName),
                                  PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                                  Ord(tLocalUser.Status));
                  end;
                break;//����� �� ������������� ��������� ������
                end;
              end;
            end;
          {end;}
        end;
      Edit1.Text := '';
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/line' then
      begin
      LockText := true;
      sChatLine := GetParamX(Edit1.Text, 1, '"', True);//�������� �������� ����� ��, ��� ����� /connect XXXXXX
      sPassword := GetParamX(Edit1.Text, 3, '"', True);//�������� ������
      id := MainLine.GetLocalUserID();
      if (id <> INVALID_USER_ID) then
        begin
        tLocalUser := MainLine.GetUserInfo(id);
        //Create ����
        RemoteCompName := '*';
        SendCommCreateLine(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), PChar(sChatLine), PChar(sPassword));
        //Connect ����
        SendCommConnect(
                        PChar(tLocalUser.ProtoName),
                        PChar(tLocalUser.DisplayNickName),
                        PChar(tLocalUser.ComputerName),
                        PChar(sChatLine), PChar(tLocalUser.ComputerName),
                        PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                        Ord(tLocalUser.Status));
        end;
      Edit1.Text := '';
      end;

    if GetParamX(Edit1.Text, 0, ' ', True) = '/connectline' then
    ///connectline "LINENAME" "PASSWORD"
    //���������� �������������� � ��� ������������ �����
    //TODO: ��������! ��������, ��� � ������ ������ ���� ����� � ����������� �������!!
    //���� �� ��� ��������� �� �����
      begin
      LockText := True;
      sChatLine := GetParamX(Edit1.Text, 1, '"', True);//�������� �������� ����� ��, ��� ����� /connect XXXXXX
      sPassword := GetParamX(Edit1.Text, 3, '"', True);//�������� ������
      LUID := MainLine.GetLocalUserID();
      if (LUID <> INVALID_USER_ID) then
        begin
        tLocalUser := MainLine.GetUserInfo(LUID);
        {ChatLine := FormMain.GetChatLineByName(sChatLine);
        if ChatLine <> nil then
          begin
          //���� ����� �����/������ ��� ����������, ������ �������� ��� TabSheet
          FormMain.PageControl1.ActivePageIndex := ChatLine.ChatLineTabSheet.PageIndex;
          end
        else
          begin}
          //����� �����/������� ���� �� ����������, ������
          //�� ������ ��������� ���� ��������� ������ �� �������, ��� ����,
          //� ������� ����� ��������� ������ ��� ����� � ����� ��, � ������� ����� �������
          for n := 0 to MainLine.UsersCount - 1 do
            begin
            //��������� ���� �� ������
            if LUID <> n then
              begin
              LineNodeID := MainLine.ChatLineUsers[n].ChatLinesList.IndexOf(GetParamX(Edit1.Text, 1, '"', true));
              if LineNodeID >= 0 then
                begin
                //��� ����� ����� �����!!! ��������� �����
                sChatLine := MainLine.ChatLineUsers[n].ChatLinesList.Strings[LineNodeID];
                tUser := MainLine.GetUserInfo(n);
                RemoteCompName := Copy(tUser.ComputerName, 0, Length(tUser.ComputerName));
                if (RemoteCompName <> tLocalUser.ComputerName) then
                  begin
                  //����
                  SendCommCreateLine(PChar(tLocalUser.ProtoName), PChar(tLocalUser.ComputerName), PChar(sChatLine), PChar(sPassword));
                  //���������� �����
                  SendCommConnect(
                                  PChar(tLocalUser.ProtoName),
                                  PChar(tLocalUser.DisplayNickName),
                                  PChar(tUser.ComputerName),
                                  PChar(sChatLine), PChar(tUser.ComputerName),
                                  PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                                  Ord(tLocalUser.Status));
                  //����
                  SendCommConnect(
                                  PChar(tLocalUser.ProtoName),
                                  PChar(tLocalUser.DisplayNickName),
                                  PChar(tLocalUser.ComputerName),
                                  PChar(sChatLine), PChar(tLocalUser.ComputerName),
                                  PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]),
                                  Ord(tLocalUser.Status));
                  end;
                break;//����� �� ������������� ��������� ������
                end;
              end;
            end;
          {end;}
        end;
      Edit1.Text := '';
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/unselect' then //������ ����� = /unselect
      begin
      LockText := true;
      ActiveChatLine := FormMain.GetActiveChatLine();
      if (ActiveChatLine <> nil) then
        begin
        id := ActiveChatLine.GetUserIdByDisplayNickName(GetParamX(Edit1.Text, 1, '"', true));
        if (id <> INVALID_USER_ID) then
          begin
          //tLocalUser := ActiveChatLine.GetUserInfo(id);
          TChatLine(ActiveChatLine).ChatLineUsers[id].CN_State := CNS_UnSelect;
          //FormMain.ShowUserInTree(ActiveChatLine, id, ShowUser_REDRAW);
          FormMain.ShowAllUserInTree(ActiveChatLine);
          end;
        end;
      Edit1.Text := '';
      Key := Char(0);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/selprivate' then //������ ����� = /selprivate
      begin
      LockText := true;
      ActiveChatLine := FormMain.GetActiveChatLine();
      if (ActiveChatLine <> nil) then
        begin
        id := ActiveChatLine.GetUserIdByDisplayNickName(GetParamX(Edit1.Text, 1, '"', true));
        if (id <> INVALID_USER_ID) then
          begin
          //tLocalUser := ActiveChatLine.GetUserInfo(id);
          TChatLine(ActiveChatLine).ChatLineUsers[id].CN_State := CNS_Private;
          //FormMain.ShowUserInTree(ActiveChatLine, id, ShowUser_REDRAW);
          FormMain.ShowAllUserInTree(ActiveChatLine);
          end;
        end;
      Edit1.Text := '';
      Key := Char(0);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/selpersonal' then //������ ����� = /selpersonal
      begin
      LockText := true;
      ActiveChatLine := FormMain.GetActiveChatLine();
      if (ActiveChatLine <> nil) then
        begin
        id := ActiveChatLine.GetUserIdByDisplayNickName(GetParamX(Edit1.Text, 1, '"', true));
        if (id <> INVALID_USER_ID) then
          begin
          //tLocalUser := ActiveChatLine.GetUserInfo(id);
          TChatLine(ActiveChatLine).ChatLineUsers[id].CN_State := CNS_Personal;
          //FormMain.ShowUserInTree(ActiveChatLine, id, ShowUser_REDRAW);
          FormMain.ShowAllUserInTree(ActiveChatLine);
          end;
        end;
      Edit1.Text := '';
      //Key := Char(0);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/getjobs' then //������ ����� = /getjobs
      begin
      //�������� �������� ��������������� �������
      JobsList.LoadFromFile(TPathBuilder.GetJobsIniFileName {ExePath +'Jobs.ini'});
      TimerJob.Interval := TDreamChatConfig.GetJobSeekingTimer(); //ChatConfig.ReadInteger(TDreamChatConfig.Jobs {'Jobs'}, TDreamChatConfig.JobSeekingTimer {'JobSeekingTimer'}, 60000);
      Sheduller(Self);
      Edit1.Text := '';
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/activeline' then //������ ����� = /activeline
      begin
      ActiveChatLine := FormMain.GetChatLineByDisplayLineName(GetParamX(Edit1.Text, 1, '"', true));
      if (ActiveChatLine <> nil) then
        begin
        FormMain.PageControl1.ActivePageIndex := ActiveChatLine.ChatLineTabSheet.TabIndex;
        PageControl1Change(Sender);
        end;
      Edit1.Text := '';
      Key := Char(0);
      //FormMain.ShowAllUserInTree(ActiveChatLine);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/reloadcomponents' then //������ ����� = /reloadcomponents
      begin
      Edit1.Text := '';
      FormMain.Visible := false;
      FormMain.LoadComponents(Sender);
      FormMain.sChatView2.Format;
      FormMain.sChatView2.Repaint;
      AFormSmiles.LoadComponents(Sender);
      FormUI.LoadComponents(Sender);
      FormUI.UserInfoChatView.Format;
      FormUI.UserInfoChatView.Repaint;
      FormMain.Visible := True;
      FormMain.Edit1.Height := TempEdit1Height;//��� � ��� ������� - ������!
      FormMain.Resize;
      if ActiveChatLine <> nil then ActiveChatLine.MessagesHistory.Delete(ActiveChatLine.MessagesHistory.Count - 1);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/show' then //������ ����� = /getjobs
      begin
      //������� �� �������� ���� ��� ��������� ������� �� ������
      if FormMain.Visible = false then
        RxTrayIconOnClick(self.RxTrayIcon, mbLeft, [], 0, 0);
      application.BringToFront;
      Edit1.Text := '';
      Key := Char(0);
      exit;
      end;

    if GetParamX(Edit1.Text, 0, ' ', true) = '/hide' then //������ ����� = /getjobs
      begin
      //�������� ���� ����
      if FormMain.Visible = true then
        begin
        RxTrayIconOnClick(self.RxTrayIcon, mbLeft, [], 0, 0);
        end;
      Edit1.Text := '';
      Key := Char(0);
      exit;
      end;

    if (ActiveChatLine <> nil) and
       (length(Edit1.Text) > 0) and (LockText = false) then
      begin
      //��� ������� ��������� � ����� �����
      RemoteCompName := '*';
      Mess := Edit1.Text;
      sChatLine := ActiveChatLine.ChatLineName;

      if ActiveChatLine.LineType <> LT_COMMON then
        begin
        //���� ������� ������ (��� 2� �������)
        for n := 0 to (ActiveChatLine.UsersCount - 1) do
          begin
          //�������� ������� ��������� �������
          SendCommText(PChar(ActiveChatLine.ChatLineUsers[n].ProtoName),
                       PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
          end;
        end
      else
        begin
        //���� ������� �����������
        //���� � ������ ���� ����� ���������� ->, �.�. ������ UserListCNS_Private ��������
        tLocalUser := ActiveChatLine.GetLocalUser;
        if tLocalUser = nil then exit;
        if UserListCNS_Private.Count > 0 then
          begin
          if CtrlKey = true then
            begin
            for n := 0 to UserListCNS_Private.Count - 1 do
              begin
              RemoteCompName := UserListCNS_Private.Strings[n];
              TUser := MainLine.GetUserInfo(MainLine.GetUserIdByCompName(RemoteCompName));
              RemoteNickName := TUser.DisplayNickName;
              sChatLine := 'gsMTCI';//��������� ����� ��� ������ ������
              SendCommText(PChar(TUser.ProtoName),
                           PChar(RemoteCompName), Pchar(TUser.NickName), PChar(Mess), PChar(sChatLine), 0);
              ParseAllChatView( '<' + MainLine.GetUserInfo(MainLine.GetLocalUserId()).DisplayNickName + '><' + RemoteNickName + '> ' + Mess,
                               MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                               nil, nil, false, true);
              end;
            Edit1.Text := '';
            Key := Char(0);
            exit;
            end;
          end;
        //���� � ������ ���� ����� ���������� ->, �.�. ������ UserListCNS_Private ��������
        if UserListCNS_Personal.Count > 0 then
          begin
          if CtrlKey = true then
            begin
            //���� � ������ ���� ����� ���������� ->, � ������ ������� CTRL!!!
            //������ �������� � ����� ���
            SendCommText(PChar(tLocalUser.ProtoName),
                         PChar(RemoteCompName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
            end
          else
            begin
            for n := 0 to UserListCNS_Personal.Count - 1 do
              begin
              RemoteCompName := UserListCNS_Personal.Strings[n];
              TUser := MainLine.GetUserInfo(MainLine.GetUserIdByCompName(RemoteCompName));
              RemoteNickName := TUser.DisplayNickName;
              sChatLine := 'gsMTCI';//��������� ����� ��� ������ ������
              SendCommText(PChar(tLocalUser.ProtoName),
                           PChar(RemoteCompName), Pchar(TUser.NickName), PChar(Mess), PChar(sChatLine), 0);
              ParseAllChatView( '<' + MainLine.GetUserInfo(MainLine.GetLocalUserId()).DisplayNickName + '><' + RemoteNickName + '> ' + Mess,
                               MainLine, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                               nil, nil, true, true);//false true
              end;
            end;
          Edit1.Text := '';
          Key := Chr(0);
          exit;
          end;
        //���� ��������� ������ ���, �� �������� ������ �����
        SendCommText(PChar(tLocalUser.ProtoName), PChar(RemoteCompName), Pchar(''), PChar(Mess), PChar(sChatLine), 0);
        end;
        Edit1.Text := '';
      end;
  Key := Chr(0);
  end;
if (Key = Chr(10)) then Key := Chr(0);
end;

procedure TFormMain.Edit1KeyDown(Sender: TObject; var Key: Word;
                              Shift: TShiftState);
var ch: char;
  CursorPos, n:integer;
  MainLine, ActiveChatLine:TChatLine;
  tUser, tLocalUser:TChatUser;
  TmpBoard:TStringList;
begin
ActiveChatLine := GetActiveChatLine();
MainLine := GetMainLine();
//ShiftKey := false;
CtrlKey := false;
//AltKey := false;
if (ssCtrl in Shift) then CtrlKey := True;

if (MainLine <> nil) then
  begin
  if (ssCtrl in Shift) then
    begin
    //���� ������ ������� CTRL
    if (lo(Key) = VK_HOME) then
      begin
      //CTRL + HOME
      ActiveChatLine.ChatLineView.Perform(WM_KEYDOWN, VK_HOME, 0);
      end;
    if (lo(Key) = VK_END) then
      begin
      //CTRL + END
      ActiveChatLine.ChatLineView.Perform(WM_KEYDOWN, VK_END, 0);
      end;
    if (lo(Key) = VK_NEXT) then
      begin
      //CTRL + PGDOWN
      ActiveChatLine.ChatLineView.Perform(WM_KEYDOWN, VK_NEXT, 0);
      end;
    if (lo(Key) = VK_PRIOR) then
      begin
      //CTRL + PGUP
      ActiveChatLine.ChatLineView.Perform(WM_KEYDOWN, VK_PRIOR, 0);
      end;
    if (lo(Key) = VK_TAB) then
      begin
      //CTRL + TAB
      FormMain.PageControl1.ActivePage := TsTabSheet(FormMain.PageControl1.FindNextPage(FormMain.PageControl1.ActivePage, True, True));
      end;
    if (lo(Key) = VK_DOWN) then
      begin
      //CTRL + ARROW_DOWN
      //FormUI.Visible := true;
      AFormSmiles.ShowModal;
      end
    else
      begin
      //CTRL + Enter
      if (lo(Key) = VK_RETURN) then
        begin
        if (PageControl1.Pages[PageControl1.ActivePageIndex].FindChildControl('sChatView2') <> nil) then
          begin
          //��������� ����� ����������
          Key := 0;
          TmpBoard := TStringList.Create;
          TmpBoard.Text := Edit1.Text;
          TmpBoard.SaveToFile(TPathBuilder.GetExePath() + TDreamChatConfig.GetMessageBoard()); //ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.MessageBoard {'MessageBoard'}, 'MessageBoard.txt'));
          tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserID());
          if tLocalUser <> nil then
            begin
            //MessageBox(0, PChar('ssCtrl & VK_RETURN'), PChar(inttostr(0)) ,mb_ok);
            for n := 0 to MainLine.UsersCount - 1 do
              begin
              tUser := MainLine.GetUserInfo(n);
              if tUser <> nil then
                begin
                SendCommBoard(PChar(tUser.ProtoName), PChar(tUser.ComputerName), TmpBoard.GetText, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
                end;
              end;
            end;
          TmpBoard.Free;
          end
        else
          begin
          ch := char(key);
          Edit1KeyPress(Sender, ch);
          //MessageBox(0, PChar('ssCtrl & VK_RETURN'), PChar(inttostr(0)) ,mb_ok);
          key := 0;
          exit;
          end;
        end;
      end;
    end
  else
    begin
    //������� CTRL �� ���� ������
    if (lo(Key) = VK_F4) and
     (PageControl1.Pages[PageControl1.ActivePageIndex].FindChildControl('sChatView2') <> nil) then
      begin
      //���� ������ F4 ��� �������� �������� ����� ����������
      if Edit1.Visible = true then
        begin
        tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserID());
        if tLocalUser = nil then exit;
        sChatView2.Visible := false;
        Splitter1.Visible := false;
        Memo1.Text := tLocalUser.MessageBoard.Text;
        Edit1.Visible := false;
        Memo1.Parent := PageControl1.Pages[PageControl1.ActivePageIndex];
        Memo1.Align := alBottom;//alClient;
        //Memo1.Height := 40;
        Memo1.Visible := true;
        Memo1.SetFocus;
        Memo1.Tag := 1;//��������, ��� ����� ������� �������������� MEMO!

        Splitter1.Parent := PageControl1.Pages[PageControl1.ActivePageIndex];
        Splitter1.Align := alBottom;
        Splitter1.Top := Splitter1.Top - Memo1.Top;
        Splitter1.Visible := True;

        sChatView2.Visible := true;

        //��� ������������ ���� ���������� ������������ ��������.
        Panel3.Height := Panel3.Tag;//���� ������� ������� - ���������� ���������
        end;
      end;

    if (lo(Key) = VK_UP) and (ActiveChatLine.MessagesHistoryIndex > 0) then
      begin
      dec(ActiveChatLine.MessagesHistoryIndex);
      Edit1.Text := ActiveChatLine.MessagesHistory.Strings[ActiveChatLine.MessagesHistoryIndex];
      Edit1.SelStart := Length(Edit1.text);
      Key := 0;
      end;
    if (Key = VK_DOWN) and (ActiveChatLine.MessagesHistoryIndex < ActiveChatLine.MessagesHistory.Count - 1) then
      begin
      inc(ActiveChatLine.MessagesHistoryIndex);
      Edit1.Text := ActiveChatLine.MessagesHistory.Strings[ActiveChatLine.MessagesHistoryIndex];
      Edit1.SelStart := Length(Edit1.text);
      Key := 0;
      end;
    end;

  if key = VK_F8 then
    begin
    PlaySounds := not PlaySounds;
    if PlaySounds then
      MessageBeep(MB_OK)
    else
      MessageBeep(MB_ICONEXCLAMATION);
    end;
  if key = VK_F10 then
    begin
    CursorPos := Edit1.SelStart;
    Edit1.Text := MultiTranslate(Edit1.Text, RusToEng);
    Edit1.SelStart := CursorPos;
    key := 0;
    end;
  if key = VK_F11 then
    begin
    CursorPos := Edit1.SelStart;
    Edit1.Text := MultiTranslate(Edit1.Text, EngToRus);
    Edit1.SelStart := CursorPos;
    key := 0;
    end;
  if key = VK_F12 then
    begin
    CursorPos := Edit1.SelStart;
    Edit1.Text := MultiTranslate(Edit1.Text, Direct);
    if Direct = EngToRus then
      Direct := RusToEng
    else
      Direct := EngToRus;
  //  FormDebug.memo1.Lines.Clear;
  {FormDebug.memo1.Lines.Add('-----------DictionaryEng---------------');
    for CursorPos := 0 to DictionaryEng.Count - 1 do
      begin
      FormDebug.memo1.Lines.Add(DictionaryEng.Strings[CursorPos]);
      end;
  FormDebug.memo1.Lines.Add('------------DictionaryRus--------------');
    for CursorPos := 0 to DictionaryRus.Count - 1 do
      begin
      FormDebug.memo1.Lines.Add(DictionaryRus.Strings[CursorPos]);
      end;}
    Edit1.SelStart := CursorPos;
    end;
  end;
end;

procedure TFormMain.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  MainLine: TChatLine;
//  ActiveChatLine: TChatLine;
  n: integer;
  tUser, tLocalUser:TChatUser;
begin
//ActiveChatLine := GetActiveChatLine();
MainLine := FormMain.GetMainLine();
CtrlKey := false;
if (ssCtrl in Shift) then CtrlKey := true;
//FormMain.Caption := inttostr(hi(Key)) + ' ' + inttostr(lo(Key));
//if (lo(Key) = VK_RETURN) then Key := 0;
//if (lo(Key) = 13) then Key := 65;

if (MainLine <> nil) then
  begin
  if (CtrlKey = true) and (lo(Key) = VK_RETURN) then
    begin
    //���� ������ ������� CTRL + Enter
    //��������� ����� ����������
    tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserID());
    Key := 0;
    Memo1.Lines.SaveToFile(TPathBuilder.GetExePath() + TDreamChatConfig.GetMessageBoard()); //ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.MessageBoard {'MessageBoard'}, 'MessageBoard.txt'));
    if tLocalUser <> nil then
      begin
      //MessageBox(0, PChar('ssCtrl & VK_RETURN'), PChar(inttostr(0)) ,mb_ok);
      for n := 0 to MainLine.UsersCount - 1 do
        begin
        tUser := MainLine.GetUserInfo(n);
        if tUser <> nil then SendCommBoard(PChar(tUser.ProtoName), PChar(tUser.ComputerName), Memo1.Lines.GetText{tLocalUser.MessageBoard.GetText}, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
        end;
      end;
    end
  else
    begin
    if (Key = VK_F4) and
     (PageControl1.Pages[PageControl1.ActivePageIndex].FindChildControl('sChatView2') <> nil) then
      begin
      //���� ������ F4 ��� �������� �������� ����� ����������
      if Memo1.Visible = true then
        begin
        Memo1.Tag := 0;//��������, ��� ����� �������������� MEMO �������� !
        //��� ������������ ���� ���������� ������������ ��������.
        Memo1.Visible := false;
        Edit1.Visible := true;
        Splitter1.Visible := false;
        Edit1.SetFocus;
        Panel3.Tag := Panel3.Height;
        Panel3.Height := Edit1.Height + 4;
        end;
      end;
    end;
  end;
end;

procedure TFormMain.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
//FormMain.Caption := inttostr(byte(Key));
if (Key = Chr(10)) then Key := Chr(0);
end;


FUNCTION MySort(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  if length(List.Names[Index1]) > length(List.Names[Index2])
    then Result := -1;
  if length(List.Names[Index1]) = length(List.Names[Index2])
    then Result := 0;
  if length(List.Names[Index1]) < length(List.Names[Index2])
    then Result := 1;
end;


{==============================================================================}
{                          ���������� ����� ���������                          }
{==============================================================================}
{                                   Connect                                    }
{==============================================================================}
PROCEDURE TFormMain.OnCmdConnect(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR
    tUser, tLocalUser: TChatUser;
    MainLine:TChatLine;
    DictIndex:integer;
BEGIN
//MessageBox(0, Pchar(inttostr(UserId)), 'OnCmdConnect!!!', mb_ok);
MainLine := GetMainLine();
tLocalUser := Sender.GetUserInfo(Sender.GetLocalUserID());
if MainLine = nil then
  UserId := INVALID_USER_ID
else
  begin
  if tLocalUser = nil then tLocalUser := MainLine.GetUserInfo(MainLine.GetLocalUserID());
  //���� MainLine ����������, ������ ����� ����, � ���������� ����� ��� ���
  //����� ��� �� ������� �����
  end;

if (UserId <> INVALID_USER_ID) and (tLocalUser <> nil) then
  begin
  tUser := Sender.GetUserInfo(UserId);
//  MessageBox(0, Pchar(inttostr(tLocalUser.UserID)), 'OnCmdConnect: tLocalUser.UserID', mb_ok);
     //��� ���������!!!! tLocalUser �� NIL!!!!!!!!!!!
     //���������� ������ ��� ��������� � �����������
    if ((GetParamX(sReceivedMessage, 9, #19#19, true)) = tLocalUser.ComputerName) or
       ((GetParamX(sReceivedMessage, 9, #19#19, true)) = '*') then
      begin
      ParseAllChatView(fmInternational.Strings[I_USERCONNECTED] + ' ' + tUser.DisplayNickName + '. ' +
                     GetParamX(sReceivedMessage, 8, #19#19, true) +
                     ' [' + GetParamX(sReceivedMessage, 2, #19#19, true) + '] (' +
                     GetParamX(sReceivedMessage, 10, #19#19, true) + ')',
                     sender, CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE],
                     nil, nil, false, true);
      SendMessage(application.MainForm.handle,
                  UM_INCOMMINGMESSAGE,
                  UM_INCOMMINGMESSAGE_UpdateTree, Sender.LineID);
      if PlaySounds then
        SoundOnCommConnect(Integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundConnect), UserID);

      {---------- ��������� ��� ����� � ������� �������� ---------}
      if MaxDxRus < Length('"' + tUser.DisplayNickName + '"') then
        begin
        MaxDxRus := Length('"' + tUser.DisplayNickName + '"');
        MaxDxEng := Length('"' + tUser.DisplayNickName + '"');
        end;
      DictIndex := FDictionaryRus.IndexOf(tUser.DisplayNickName + '=' + tUser.DisplayNickName);
      if DictIndex >= 0 then
        begin
        FDictionaryRus.Delete(DictIndex);
        FDictionaryEng.Delete(DictIndex);
        end;
//      DictionaryRus.Add(tUser.NickName + '=' + tUser.NickName);
//      DictionaryEng.Add(tUser.NickName + '=' + tUser.NickName);
      FDictionaryRus.Add('"' + tUser.DisplayNickName + '"' + '=' + '"' + tUser.DisplayNickName + '"');
      FDictionaryEng.Add('"' + tUser.DisplayNickName + '"' + '=' + '"' + tUser.DisplayNickName + '"');
      FDictionaryRus.CustomSort(MySort);
      FDictionaryEng.CustomSort(MySort);
      {--------------}
      end;
    if CompareText(tUser.ComputerName, tLocalUser.ComputerName) = 0 then
        begin
        //���� �������������� ��������� ������������
        //tLocalUser.Status := 0;//;
        FormMain.ReadLocalUserInfoFromIni(UserId);
        end
      else
        begin
        //���� �������������� ��������� ������������
        //�� ��� ������� ��� ����������� � UChatLine ������ ������
        {s := tUser.ComputerName;
        SendCommStatus(tLocalUser.Status,
                       PChar(tLocalUser.MessageStatus.strings[tLocalUser.Status]),
                       PChar());
        SendCommBoard(PChar(tUser.ComputerName), tLocalUser.MessageBoard.GetText, 0);}
        end;
  end;
//SendMessage(application.MainForm.handle, WM_INCOMMINGMESSAGE, 0, 0);
END;

{==============================================================================}
{                                   CREATE                                     }
{==============================================================================}
PROCEDURE TFormMain.OnCmdCREATE(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR //id:cardinal;
    tUser: TChatUser;
    MainLine: TChatLine;
    PrivateLine: TChatLine;
    sLineName:string;
    n: cardinal;
//    tLocalUser: TChatUser;
BEGIN
//len := Length(ChatLines);
//inc(len);
//SetLength(ChatLines, len);
//pPrivateLine := @ChatLines[len - 1];
sLineName := GetParamX(sReceivedMessage, 4, #19#19, true);
//������� ��� ������������ �����
PrivateLine := GetChatLineByName(sLineName);
if (PrivateLine <> nil) then
  begin
  if (PrivateLine.UsersCount > 0) then
    for n := 0 to (PrivateLine.UsersCount - 1) do
      begin
   //�������� ������� ��������� �������
//        MessageBox(0, PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), PChar(inttostr(0)) ,mb_ok);
      SendCommDisconnect(
                         PChar(PrivateLine.ChatLineUsers[n].ProtoName), PChar(''),
                         PChar(PrivateLine.ChatLineUsers[n].ComputerName), PChar(PrivateLine.ChatLineName));
      end;
   //TODO: ��������!!! ������ ��� �������� ��-�� ���� ��� ������� �����
   //������� �� ������ ����� � ����� ������ FREE �����
   //.IndexOf(ActiveChatLine.ChatLineName) �������� � ������...
  ChatLines.Delete(ChatLines.IndexOf(PrivateLine.ChatLineName));
  PrivateLine.ChatLineView.Clear;
  PrivateLine.Free;
  end;

PrivateLine := TChatLine.Create(sLineName, PageControl1, CVStyle1);
DynamicPopupMenu.FParentChatLine := PrivateLine;
ChatLines.AddObject(sLineName, PrivateLine);

PrivateLine.ChatLineView.OnDebug := Debug;
PrivateLine.OnCmdConnect := OnCmdConnect;
PrivateLine.OnCmdDisconnect := OnCmdDisconnect;
PrivateLine.OnCmdText := OnCmdText;
PrivateLine.OnCmdRefresh := OnCmdRefresh;
PrivateLine.OnCmdReceived := OnCmdReceived;
PrivateLine.OnCmdRename := OnCmdRename;
PrivateLine.OnCmdBoard := OnCmdBoard;
PrivateLine.OnCmdStatus := OnCmdStatus;
PrivateLine.OnCmdStatus_Req := OnCmdStatus_Req;
PrivateLine.OnCmdRefresh_Board := OnCmdRefresh_Board;
PrivateLine.OnCmdCREATE := OnCmdCREATE;
PrivateLine.OnCmdCREATELINE := OnCmdCREATELINE;
PrivateLine.ChatLineTree.OnDblClick := TreeViewDblClick;
PrivateLine.ChatLineTree.OnClick := TreeViewClick;
PrivateLine.ChatLineTree.NodeDataSize := SizeOf(TDataNode);
PrivateLine.LineType := LT_PRIVATE_CHAT;
PrivateLine.LineID := ChatLines.Count - 1;
PrivateLine.ChatLineTabSheet.Tag := PrivateLine.LineID;

TDebugMan.AddLine2('������ ������ PrivateLine.ChatLineName := ' + PrivateLine.ChatLineName); //FormDebug.DebugMemo2.Lines.Add('������ ������ PrivateLine.ChatLineName := ' + PrivateLine.ChatLineName);

MainLine := GetMainLine();
if MainLine = nil then UserID := INVALID_USER_ID;
if UserID <> INVALID_USER_ID then
  begin
  tUser := MainLine.GetUserInfo(UserID);
  if tUser <> nil then
    begin
    PrivateLine.DisplayChatLineName := fmInternational.Strings[I_PRIVATEWITH] + ' ' + tUser.DisplayNickName;//������ ��� �
    PrivateLine.ChatLineTabSheet.Caption := PrivateLine.DisplayChatLineName;
    //���������� �������
    if PlaySounds then
      SoundOnCommCreate(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundCreate), UserID);
    end;
  //ShowAllUserInTree(MainLine);
  end;
//��� ����� ������ MainLine.MessageProtocolProcessing (�� ���������)
//<-- iChat219IZZYCREATE793000ANDREY
//��� ����� ������ MainLine.MessageProtocolProcessing (�� ���������)
//==>[\\IZZY\Mailslot\ICHAT047] iChat12ANDREYCONNECT793000AdminsAndrey���� ������!IZZYD0.20M230
//<-- iChat223IZZYCONNECT793000Izzy������� ������!ANDREY1.3b30
END;

{==============================================================================}
{                               CREATELINE                                     }
{==============================================================================}
PROCEDURE TFormMain.OnCmdCREATELINE(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR //id:cardinal;
    tUser: TChatUser;
    MainLine: TChatLine;
    PrivateLine: TChatLine;
    sLineName:string;
    n: cardinal;
//    tLocalUser: TChatUser;
BEGIN
//len := Length(ChatLines);
//inc(len);
//SetLength(ChatLines, len);
//pPrivateLine := @ChatLines[len - 1];
sLineName := GetParamX(sReceivedMessage, 4, #19#19, true);
//������� ��� ������������ �����
PrivateLine := GetChatLineByName(sLineName);
if (PrivateLine <> nil) then
  begin
  if (PrivateLine.UsersCount > 0) then
    for n := 0 to (PrivateLine.UsersCount - 1) do
      begin
      //�������� ������� ��������� �������
      //MessageBox(0, PChar(ActiveChatLine.ChatLineUsers[n].ComputerName), PChar(inttostr(0)) ,mb_ok);
      SendCommDisconnect(
                         PChar(PrivateLine.ChatLineUsers[n].ProtoName),
                         PChar(''), PChar(PrivateLine.ChatLineUsers[n].ComputerName), PChar(PrivateLine.ChatLineName));
      end;
   //TODO: ��������!!! ������ ��� �������� ��-�� ���� ��� ������� �����
   //������� �� ������ ����� � ����� ������ FREE �����
   //.IndexOf(ActiveChatLine.ChatLineName) �������� � ������...
  ChatLines.Delete(ChatLines.IndexOf(PrivateLine.ChatLineName));
  PrivateLine.ChatLineView.Clear;
  PrivateLine.Free;
  end;

PrivateLine := TChatLine.Create(sLineName, PageControl1, CVStyle1);
DynamicPopupMenu.FParentChatLine := PrivateLine;
ChatLines.AddObject(sLineName, PrivateLine);

PrivateLine.ChatLineView.OnDebug := Debug;
PrivateLine.OnCmdConnect := OnCmdConnect;
PrivateLine.OnCmdDisconnect := OnCmdDisconnect;
PrivateLine.OnCmdText := OnCmdText;
PrivateLine.OnCmdRefresh := OnCmdRefresh;
PrivateLine.OnCmdReceived := OnCmdReceived;
PrivateLine.OnCmdRename := OnCmdRename;
PrivateLine.OnCmdBoard := OnCmdBoard;
PrivateLine.OnCmdStatus := OnCmdStatus;
PrivateLine.OnCmdStatus_Req := OnCmdStatus_Req;
PrivateLine.OnCmdRefresh_Board := OnCmdRefresh_Board;
PrivateLine.OnCmdCREATE := OnCmdCREATE;
PrivateLine.OnCmdCREATELINE := OnCmdCREATELINE;
PrivateLine.ChatLineTree.OnDblClick := TreeViewDblClick;
PrivateLine.ChatLineTree.OnClick := TreeViewClick;
PrivateLine.ChatLineTree.NodeDataSize := SizeOf(TDataNode);
PrivateLine.LineType := LT_LINE;
PrivateLine.LineID := ChatLines.Count - 1;
PrivateLine.ChatLineTabSheet.Tag := PrivateLine.LineID;

TDebugMan.AddLine2('������ ������ PrivateLine.ChatLineName := ' + PrivateLine.ChatLineName); //FormDebug.DebugMemo2.Lines.Add('������ ������ PrivateLine.ChatLineName := ' + PrivateLine.ChatLineName);

MainLine := GetMainLine();
if MainLine = nil then UserID := INVALID_USER_ID;
if UserID <> INVALID_USER_ID then
  begin
  tUser := MainLine.GetUserInfo(UserID);
  if tUser <> nil then
    begin
    PrivateLine.DisplayChatLineName := PrivateLine.ChatLineName;
    PrivateLine.ChatLineTabSheet.Caption := PrivateLine.DisplayChatLineName;
    //���������� �������
    if PlaySounds then
      SoundOnCommCreate(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundCreate), UserID);
    end;
  //ShowAllUserInTree(MainLine);
  end;
//��� ����� ������ MainLine.MessageProtocolProcessing (�� ���������)
//<-- iChat219IZZYCREATE793000ANDREY
//��� ����� ������ MainLine.MessageProtocolProcessing (�� ���������)
//==>[\\IZZY\Mailslot\ICHAT047] iChat12ANDREYCONNECT793000AdminsAndrey���� ������!IZZYD0.20M230
//<-- iChat223IZZYCONNECT793000Izzy������� ������!ANDREY1.3b30
END;

{==============================================================================}
{                                Disconnect                                    }
{==============================================================================}
PROCEDURE TFormMain.OnCmdDisconnect(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR //tUser, tLocalUser: TChatUser;
    MainLine: TChatLine;
BEGIN
//TODO: ��������!!!! ���� ��� NILL ������ ����� �������!
//tUser := Sender.GetUserInfo(UserID);
//if (tUser <> nil)and(PlaySounds) then SoundOnCommDisconnect(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundDisconnect), UserID);

if (GetParamX(sReceivedMessage, 2, #19#19, True) = Sender.LocalComputerName) and
  (closing = True) then
    begin
    ChatLines.Delete(ChatLines.IndexOf(Sender.ChatLineName));
    Sender.ChatLineTree.Clear;
    Sender.ChatLineView.Clear;
    //Sender.Destroy;
    //Sender := nil;
    //Sender.Free;
    FreeAndNil(Sender);
    closing := False;
    MainLine := GetMainline();
    if MainLine <> nil then FormMain.ShowAllUserInTree(MainLine);
    {  begin
      ����� ����� ������� �� ������ ������, �.�. ��� ��� ����� � �������
      ���� ������ � ���� ������ ���������� ��������������, ������� AV
      ����� ����������������� � UChatLine
      //FormMain.ShowUserInTree(MainLine, UserID, ShowUser_DELETE);
      end;}
    end
  else
    begin
    FormMain.ShowAllUserInTree(Sender);
    //FormMain.ShowUserInTree(GetActiveChatLine(), UserID, ShowUser_DELETE);
    end;

//SendMessage(application.MainForm.handle, WM_INCOMMINGMESSAGE, 0, 0);
END;

{==============================================================================}
{                                    Text                                      }
{==============================================================================}
PROCEDURE TFormMain.OnCmdText(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR //id:cardinal;
    tUser: TChatUser;
    tLocalUser: TChatUser;
    MainLine: TChatLine;
//    FormPopUpMessage: TFormPopUpMessage;
    //LinkText, OverLinkText: TFontInfo;
BEGIN
MainLine := GetMainLine();
if MainLine = nil then exit;

if UserId <> INVALID_USER_ID then
  begin
  tUser := Sender.GetUserInfo(UserId);
//  if length(Sender.GetParamX(sReceivedMessage, 6, #19#19, true)) > 0 then
//    begin
    //���� ��� ����������� ������ 0. ��... � ������ ��� ��� ����� �����??!!!
    if CompareText(GetParamX(sReceivedMessage, 4, #19#19, true), 'gsMTCI') = 0 then
      begin
      //��������� ���������
      //tLocalUser := Sender.GetUserInfo(Sender.GetLocalUserId());
      if GetParamX(sReceivedMessage, 6, #19#19, true) = '*' then
        begin
        //�������� ������ ���������
        if tUser.Ignored = true then
          begin
          SendCommReceived(PChar(tUser.ProtoName), PChar(tUser.ComputerName) , PChar(TDreamChatConfig.GetIgnoredMessage()));//ChatConfig.ReadString('common', 'IgnoredMessage', 'Your''s message was ignored')));
          exit;
          end;
        tLocalUser := Sender.GetUserInfo(Sender.GetLocalUserId());
        ParseAllChatView( '<' + tUser.DisplayNickName + '>' +
                         '<*> ' + GetParamX(sReceivedMessage, 5, #19#19, true),
                         Sender, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                         nil, nil, true, true);//false true
        end
      else
        begin
        //������ ���������
        if tUser.Ignored = true then
          begin
          SendCommReceived(PChar(tUser.ProtoName), PChar(tUser.ComputerName) , PChar(TDreamChatConfig.GetIgnoredMessage())); //ChatConfig.ReadString('common', 'IgnoredMessage', 'Your''s message was ignored')));
          exit;
          end;
        tLocalUser := Sender.GetUserInfo(Sender.GetLocalUserId());
        ParseAllChatView( '<' + tUser.DisplayNickName + '> ',
                         Sender, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                         tUser.UserOnLineLI, nil, true, true);//false false
        ParseAllChatView( '<' + tLocalUser.DisplayNickName + '> ',
                         Sender, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                         tLocalUser.UserOnLineLI, nil, false, false);
        ParseAllChatView( GetParamX(sReceivedMessage, 5, #19#19, true),
                         Sender, CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE],
                         nil, nil, false, false);
        end;

      if tLocalUser.Status < dcsDND then
        begin
        //��������� ���� �������������� � ������ ��������� ����
        //���������� �������� �� ��� �������������� ����������... ������������
        {FormPopUpMessage := }TFormPopUpMessage.Create(FormMain, Sender.LineID, tUser.UserID,
                                                     GetParamX(sReceivedMessage, 5, #19#19, true));
        end;
      SendCommReceived(PChar(tUser.ProtoName), PChar(tUser.ComputerName) , PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]));
      if PlaySounds then
        SoundOnCommAlertToAll(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundAlertToAll), UserID);
      end
    else
      begin
      //��������� � ����� ���
      if tUser.Ignored = true then exit;
      {if ParseControl(GetParamX(Buffer, 5, #19#19, true),
                     FormMain.MainLine.ChatLineView, cvsCommonMessage) = false then}
      ParseAllChatView( '<' + tUser.DisplayNickName + '> ',
                       Sender, CVStyle1.TextStyles.Items[NORMALTEXTSTYLE],
                       tUser.UserOnLineLI, nil, true, true);

      ParseAllChatView(GetParamX(sReceivedMessage, 5, #19#19, true),
                       Sender, CVStyle1.TextStyles.Items[NORMALTEXTSTYLE], nil, nil, false, false);
      if PlaySounds then
        SoundOnCommText(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundText), UserID);
      end;
//    end;
  end;
END;

{==============================================================================}
{                                  Refresh                                     }
{==============================================================================}
PROCEDURE TFormMain.OnCmdRefresh(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR
    tUser: TChatUser;
    tLocalUser: TChatUser;
    id: cardinal;
    MainLine: TChatLine;
    n:cardinal;
BEGIN
//���������������!!!!!
MainLine := GetMainLine();
if MainLine = nil then UserId := INVALID_USER_ID;
if UserId <> INVALID_USER_ID then
  begin
  tUser := Sender.GetUserInfo(UserId);//������ Sender.!!
  //������ ������������� ������������ MainLine!!!
  //����� ����� Sender. ��� MainLine. �.�. � ������ ������ � ������ � ���� ��
  //����� ������ ID. ���� ID ���� �� MainLine, � ����� �� ����� ID ����������
  //� ������� ������ � ������ ������ - ������� AV!!!!! �.�. ����� ��� ������ ������� �
  //������ ������������� � ��� ������.
  id := Sender.GetLocalUserID();
  if id <> INVALID_USER_ID then
    begin
    tLocalUser := Sender.GetUserInfo(id);
    n := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
    if (CompareText(tUser.ComputerName, tLocalUser.ComputerName) <> 0) then
       //���� ��������� �� �� ����
      begin
      //��������� ������ ���������� �����
      tUser.Status := TDreamChatStatus(StrToIntE(GetParamX(sReceivedMessage, 11, #19#19, True)));
      if (ChatMode = cmodMailSlot) then
        begin
        //MAILSLOT
        if (tUser.LastRefreshMessNumber = n) then
        //� ��������� REFRESH � ����� ������� ��� ���������
          begin
          {SendMessage(application.MainForm.handle,
                     UM_INCOMMINGMESSAGE,
                     UM_INCOMMINGMESSAGE_UpdateTree, Sender.LineID);}
          {SendCommRefresh(PChar(sglob), tLocalUser.Status,
                        PChar(tLocalUser.MessageStatus.Strings[tLocalUser.Status]));}
          SendCommRefresh(PChar(tUser.ProtoName), PChar(tUser.ComputerName), PChar(Sender.ChatLineName), PChar(tLocalUser.DisplayNickName), Ord(tLocalUser.Status),
                          PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), PChar(tUser.ComputerName), 1);
          //Messagebox(0, PChar(tUser.ComputerName + GetParamX(sReceivedMessage, 1, #19#19, true)), 'SEND REFRESH', mb_ok);
          //ShowUserInTree(Sender, UserId, ShowUser_REDRAW);
          if PlaySounds then
            SoundOnCommRefresh(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundRefresh), UserID);
          end;
        //���������� �������� ���� ����, ���� �� ���������� - ��� ������
        if tUser.VirtualNode <> nil then
          Sender.ChatLineTree.InvalidateNode(tUser.VirtualNode)
        else
          ShowAllUserInTree(Sender);
        tUser.LastRefreshMessNumber := n;
        end
      else
        begin
        //���� ����� TCP
        if CompareText(GetParamX(sReceivedMessage, 9, #19#19, true), tLocalUser.ComputerName) <> 0 then
          begin
          //���� ��� �� ����� �� ��� REFRESH ������
          //������ � ��� ��������� REFRESH � ����� ��������
          SendCommRefresh(PChar(tUser.ProtoName), PChar(tUser.ComputerName), PChar(Sender.ChatLineName), PChar(tLocalUser.DisplayNickName), Ord(tLocalUser.Status),
                          PChar(tLocalUser.MessageStatus.Strings[Ord(tLocalUser.Status)]), PChar(tUser.ComputerName), 1);
          //ShowUserInTree(Sender, UserId, ShowUser_REDRAW);
          //���������� �������� ���� ����, ���� �� ���������� - ��� ������
          if tUser.VirtualNode <> nil then
            Sender.ChatLineTree.InvalidateNode(tUser.VirtualNode)
          else
            ShowAllUserInTree(Sender);
          if PlaySounds then
            SoundOnCommRefresh(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundRefresh), UserID);
          end
        else
          begin
          //���� ��� ����� �� ��� REFRESH ������
          //������� ������
          //ShowUserInTree(Sender, UserId, ShowUser_REDRAW);
          ShowAllUserInTree(Sender);
          end;
        end;
      end
    else
      begin
      //���� ��������� �� ����
      {if (CompareText(tUser.ComputerName, tLocalUser.ComputerName) <> 0) and
         (CompareText(GetParamX(sReceivedMessage, 9, #19#19, true), tLocalUser.ComputerName) = 0) then
        SendMessage(application.MainForm.handle,
                  UM_INCOMMINGMESSAGE,
                  UM_INCOMMINGMESSAGE_UpdateTree, Sender.LineID);
      tUser.LastRefreshMessNumber := StrToIntE(GetParamX(sReceivedMessage, 1, #19#19, true));
      }
      //Messagebox(0, PChar(tUser.ComputerName + GetParamX(sReceivedMessage, 1, #19#19, true)), '���������� LAST_REFRESH', mb_ok);
      end;
    end;
  end;
END;

{==============================================================================}
{                                  Rename                                      }
{==============================================================================}
PROCEDURE TFormMain.OnCmdRename(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR
    tUser: TChatUser;
    MainLine: TChatLine;
BEGIN
MainLine := GetMainLine();
if MainLine = nil then UserId := INVALID_USER_ID;
if UserId <> INVALID_USER_ID then
  begin
  tUser := Sender.GetUserInfo(UserId);
  ParseAllChatView(tUser.DisplayNickName + ' ' + fmInternational.Strings[I_USERRENAME] + '  ' + GetParamX(sReceivedMessage, 4, #19#19, true),
                   MainLine, CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE],
                   nil, nil, false, true);
  Sender.ChatLineUsers[UserID].DisplayNickName := GetParamX(sReceivedMessage, 4, #19#19, true);
  //ShowUserInTree(Sender, UserId, ShowUser_REDRAW);
  ShowAllUserInTree(Sender);
  if PlaySounds then
    SoundOnCommRename(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundRename), UserID);
  end;
END;

{==============================================================================}
{                                  Received                                    }
{==============================================================================}
PROCEDURE TFormMain.OnCmdReceived(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR
    tUser: TChatUser;
    MainLine: TChatLine;
BEGIN
MainLine := GetMainLine();
if MainLine = nil then UserId := INVALID_USER_ID;
if UserId <> INVALID_USER_ID then
  begin
  tUser := Sender.GetUserInfo(UserId);
  ParseAllChatView(tUser.DisplayNickName + ' ' + GetParamX(sReceivedMessage, 5, #19#19, true),
                   MainLine, CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE],
                   nil, nil, false, true);
  if PlaySounds then
    SoundOnCommReceived(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundReceived), UserID);
  end;
END;

{==============================================================================}
{                                    Board                                     }
{==============================================================================}
PROCEDURE TFormMain.OnCmdBoard(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal;
                            DoUpdate:Boolean);
VAR {s:string;}
    tUser: TChatUser;
    n {, messbrdcount}:cardinal;
    MainLine: TChatLine;
BEGIN
//��� ��� ����������! ��������� ����� ������. ������ ������ ������������� �
//������� ��������� ���� (� ��� ������ ����������� ������ ������ ChatLine), �
//� ���� ��������� � ����� ��� ����� �� �����! ���� �� ������ ����� �����������
//��������� ������� ����� �������. ���! ����� ����� ������ ����������� �� ������ ������
//� �������� ���(!) �����, ����� ��������� ��� ��������� � ���������� �������
MainLine := GetMainLine();
//messbrdcount := 0;
if MainLine = nil then UserId := INVALID_USER_ID;
if UserId <> INVALID_USER_ID then
  begin
  //TODO: ������! � ��� ���� ����� ������� �� �� ������� �����???!!
  //����� UserId ����� �� ������ �����, ���� ���������))
  n := MainLine.GetUserIdByCompName(Sender.ChatLineUsers[UserId].ComputerName);
  tUser := MainLine.GetUserInfo(n);
//TODO: ��������! ������ �������� � ������ ������ ����������!
//����� �������� ������ �����, ��� �� ������ ������� ���������� �����������
//���������� sChatView2, ������, ���� ��� � ����� ���� ������ � �� �� �����
//������� �������, ��� ��-�� ������ ���������.
//������ ��������� ����� ����������� ����������
  if (length(GetParamX(sReceivedMessage, 5, #19#19, True)) > 0) or
    (DoUpdate = True) then
    begin
    //FormMain.sChatView2.Clear;//� ��������� �������!
    if GetParamX(sReceivedMessage, 4, #19#19, True) = '0' then
      begin
      MainLine.ChatLineView.AddFromNewLine(fmInternational.Strings[I_MESSAGESBOARDUPDATE] + ' ' + tUser.DisplayNickName, SYSTEMTEXTSTYLE, nil);
      MainLine.ChatLineView.FormatTail;
      MainLine.ChatLineView.Repaint;
      if PlaySounds then
        SoundOnCommBoard(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundBoard), UserID);
      //if TimerRefreshAllMessageBoard.Enabled = false then
      //  begin
      //���� ������ ��������� ����� �����, �������� ��������� �������� �������!
        TimerRefreshAllMessageBoard.Enabled := false;
        FormMain.sChatView2.Clear;
        TimerRefreshAllMessageBoard.Interval := TDreamChatConfig.GetMessageBoardRefreshTime(); // ChatConfig.ReadInteger('Common', 'MessageBoardRefreshTime', 50);
        TimerRefreshAllMessageBoard.Enabled := true;
      //  end;
      end
    else
      begin
      //if TimerRefreshAllMessageBoard.Enabled = false then
      //  begin
      //���� ������ ��������� ����� �����, �������� ��������� �������� �������!
        TimerRefreshAllMessageBoard.Enabled := false;
        FormMain.sChatView2.Clear;
        TimerRefreshAllMessageBoard.Interval := TDreamChatConfig.GetDividedMessageBoardRefreshTime(); //ChatConfig.ReadInteger('Common', 'DividedMessageBoardRefreshTime', 1000);
        TimerRefreshAllMessageBoard.Enabled := true;
      //  end;
      end;
{    for n := 0 to MainLine.UsersCount - 1 do
      begin
      if length(MainLine.ChatLineUsers[n].MessageBoard.Text) > 0 then
        begin
        ParseBoard(MainLine.ChatLineUsers[n].NickName, FormMain.sChatView2, cvsSystemMessage);
        FormMain.sChatView2.AddBreak;
        //ParseBoard(MainLine.ChatLineUsers[n].MessageBoard.Text, FormMain.sChatView2, cvsNormal);
        ParseBoard(MainLine.ChatLineUsers[n].MessageBoard.Text, FormMain.sChatView2, cvsNormal);
//        ParseAllSmiles(MainLine.ChatLineUsers[n].MessageBoard.Text, FormMain.sChatView2, cvsNormal);
        FormMain.sChatView2.AddBreak;
        inc(messbrdcount);
        end
      end;
    FormMain.TabSheet2.Caption := '����� ���������� [' + inttostr(messbrdcount) + ']';}
    end;
  end;
END;

Procedure TFormMain.Sheduller(Sender: TObject);
VAR
    tUser: TChatUser;
    //n:cardinal;
    Line: TChatLine;
    i: integer;
    sDate, sTime, sJobYear, command, RecpNickName, sDateAndTime: string;
    JobDate, JobTime, NowDate, NowTime: TDateTime;
    wYear, wMonth, wDay: word;
    KeyPress: char;
    DoSave: boolean;
    LastInput: tagLASTINPUTINFO;
    IdleTime: integer;
label NexStep;
BEGIN
//TODO: ��������!!! ���������� GetParam!!!!!!!!!!!!!!!!!!!!! ��� X !!!!
Line := FormMain.GetMainLine();
if Line = nil then exit;

LastInput.cbSize := sizeof(LastInput);
GetLastInputInfo(LastInput);
IdleTime := round((GetTickCount() - LastInput.dwTime)/1000);

//� �� ���� �������� ��������� ������ ��� �������� ����������� ������������
//������ ��������� ������� ����������� ������ 2 ��� (������������� � config.ini)
  if IdleTime > TDreamChatConfig.GetTimeOutAWay() then //ChatConfig.ReadInteger('Common', 'TimeOutAWay', 600) then
    begin
    //����������, ��� ���� �� �������� ���������� ��������� ��� ������
    tUser := Line.GetLocalUser();
    if tUser = nil then exit;
    if (tUser.Status <> dcsAway) and (IdleTime > TDreamChatConfig.GetTimeOutNA()) then //ChatConfig.ReadInteger('Common', 'TimeOutNA', 1200)) then
      begin
      //���������� ������ TimeOutNA
      SpeedButton6.Click;
      end
    else
      begin
      if (AutoAwayStatus = False) then
        begin
        //���������� ������ TimeOutAWay
        BeforeAutoAwayStatus := tUser.Status;
        AutoAwayStatus := True;
        SpeedButton5.Click;
        end;
      end;
    end
  else
    begin
    if (AutoAwayStatus = true) and
      (IdleTime < (TDreamChatConfig.GetJobSeekingTimer {ChatConfig.ReadInteger('Jobs', 'JobSeekingTimer', 2000)} * 2)) then
      begin
      //���� ���� �������������� ����� ��������� � ���� ��� � ���� �����
      //�� ���������� ��� ��� ����
      AutoAwayStatus := false;
        case BeforeAutoAwayStatus of
          dcsNormal: SpeedButton3.Click;
          dcsBusy: SpeedButton4.Click;
          dcsDND: SpeedButton5.Click;
          dcsAway: SpeedButton6.Click;
        end;
      end;
    end;

DoSave := False;
Line := FormMain.GetMainLine();
NowDate := Date;
NowTime := SysUtils.Time;
if (JobsList.Count > 0) and (Line <> nil) then
  begin
  i := 0;
  while i < JobsList.Count do
    begin
    sDateAndTime := GetParam(JobsList[i], 0, JobMessAndTimeDelimiter);
    sDate := GetParam(sDateAndTime, 0, '/');
    sTime := GetParam(sDateAndTime, 1, '/');

    //���� �������� � �����, ��� ����������� �� ������ ��� ���������� ��� ����
    sJobYear := GetParam(sDate, 0, '.');
    //���� ��� ������� � ����������� �����, �� � 06 �� ����� job.ini ��������� ������ ��� ����� ���� �� ������� ���� 20
    if length(sJobYear) < 4 then sJobYear := copy(FormatDateTime( 'yyyy', NowDate), 0 , 2) + GetParam(sDate, 0, '.');

    wYear := StrToIntE(sJobYear);
    wMonth := StrToIntE(GetParam(sDate, 1, '.'));
    wDay := StrToIntE(GetParam(sDate, 2, '.'));

    try
      JobDate := EncodeDate(wYear, wMonth, wDay);
      JobTime := StrToTime(sTime);
      //FormMain.Edit1.Text := //'sDateAndTime = ' + sDateAndTime +
                        //' sDate = ' + sDate +
                        //' sTime = ' + sTime +
      //                  ' NowDate = ' + DateToStr(NowDate) +
      //                  ' JobDate = ' + DateToStr(JobDate) +//+
      //                  ' NowTime = ' + TimeToStr(NowTime) +
      //                  ' JobTime = ' + TimeToStr(JobTime);
      //������� ������� ����� ������ ������� �� �����
      if (NowDate >= JobDate) or ((NowDate = JobDate) and (NowTime >= JobTime)) then
        begin
        command := copy(JobsList.Strings[i],
                        Length(sDate + '/' + sTime + JobMessAndTimeDelimiter) + 1,
                        Length(JobsList.Strings[i]) - Length(sDate + '/' + sTime + JobMessAndTimeDelimiter));
        FormMain.Edit1.Text := command;
        Line := FormMain.GetMainLine;
        Line.LineLog.Add('/*');
        Line.LineLog.Add('Job runing at: [' + DateToStr(Now) + '/' + TimeToStr(Now) + ']');
        Line.LineLog.Add('Try to executing command: ' + command);
        Line.LineLog.Add('*/');
        if GetParam(command, 0, ' ') = '/msg' then
          begin
          RecpNickName := GetParam(command, 1, '"');//�������� ��� ��, ��� ����� \msg XXXXXX
          tUser := Line.GetUserByDisplayNickName(RecpNickName);
          if tUser <> nil then
            begin
            FormMain.Edit1.Text := command;
            KeyPress := Char(#13);
            Edit1KeyPress(self, KeyPress);
            JobsList.Delete(i);
            dec(i);
            DoSave := true;
            end;
          end
        else
          begin
          FormMain.Edit1.Text := command;
          KeyPress := Char(#13);
          Edit1KeyPress(self, KeyPress);
          JobsList.Delete(i);
          dec(i);
          DoSave := true;
          end;
        end;
    except
      on E:Exception do
        begin
        tUser := Line.GetLocalUser;
        if tUser <> nil then
          begin
          command := Format(TDreamChatConfig.GetRunIfJobError {ChatConfig.ReadString('Jobs', 'RunIfJobError', '')},
                            ['[FormMain.Sheduller]: ' + EInternational.Strings[IE_ERROR] + ' ' + E.Message + ' ' + EInternational.Strings[IE_ATWORK] +
                            ' ' + JobsList.Strings[i] + '. ' + EInternational.Strings[IE_JOBFAILED]]);
          FormMain.Edit1.Text := command;

          Line := FormMain.GetMainLine;
          Line.LineLog.Add('/*');
          Line.LineLog.Add('Job FAILED at: [' + DateToStr(Now) + '/' + TimeToStr(Now) + ']');
          Line.LineLog.Add('with error message: ' + E.Message);
          Line.LineLog.Add('Error processing: ' + command);
          Line.LineLog.Add('*/');

          KeyPress := Char(#13);
          Edit1KeyPress(self, KeyPress);
          end;
        JobsList.Delete(i);
        dec(i);
        DoSave := true;
        end;
    end;
      inc(i);
    end;
  end;
if DoSave = true then JobsList.SaveToFile(TPathBuilder.GetJobsIniFileName {ExePath +'Jobs.ini'});
END;

Procedure TFormMain.RefreshAllMessageBoard(Sender: TObject);
VAR
    //tUser: TChatUser;
    n, messbrdcount:cardinal;
    MainLine: TChatLine;
{$IFDEF USELOG4D}
    logger: TLogLogger;
{$ENDIF USELOG4D}
BEGIN

try

  TimerRefreshAllMessageBoard.Enabled := false;
  MainLine := GetMainLine();
  messbrdcount := 0;
  //FormMain.sChatView2.Clear;
  if MainLine <> nil then begin
    for n := 0 to MainLine.UsersCount - 1 do begin
      if length(MainLine.ChatLineUsers[n].MessageBoard.Text) > 0 then begin
        ParseBoard(MainLine.ChatLineUsers[n].DisplayNickName, FormMain.sChatView2, CVStyle1.TextStyles.Items[SYSTEMTEXTSTYLE], nil);
        FormMain.sChatView2.AddBreak;
        ParseBoard(MainLine.ChatLineUsers[n].MessageBoard.Text, FormMain.sChatView2, CVStyle1.TextStyles.Items[BOARDTEXTSTYLE], nil);
        FormMain.sChatView2.AddBreak;
        inc(messbrdcount);
      end
    end;
  end;

  if messbrdcount > 0 then begin
    FormMain.sChatView2.Format;//����!!! �.�. � ParseBoard �� �� ������ ��������������!
    FormMain.sChatView2.Repaint;
  end;

  FormMain.TabSheet2.Caption := fmInternational.Strings[I_MESSAGESBOARD] + ' [' + inttostr(messbrdcount) + ']';

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

{==============================================================================}
{                                    Status                                    }
{==============================================================================}
PROCEDURE TFormMain.OnCmdStatus(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR tUser: TChatUser;
BEGIN
if UserID <> INVALID_USER_ID then
  begin
//  tUser := MainLine.GetUserInfo(UserId);
    {ParseAllSmiles(tUser.NickName + ' ' + GetParamX(Buffer, 5, #19#19, true),
                      FormMain.MainLine.ChatLineView, cvsSystemMessage);}
    //FormMain.ShowAllUserInTree(MainLine);
    SendMessage(application.MainForm.handle,
            UM_INCOMMINGMESSAGE,
            UM_INCOMMINGMESSAGE_UpdateTree, Sender.LineID);
  tUser := Sender.GetUserInfo(UserId);
  if (tUser <> nil)and(PlaySounds) then
    SoundOnCommStatus(integer(Sender.LineType), PChar(sReceivedMessage), PChar(tUser.SoundStatus), UserID);
  end;
END;

{==============================================================================}
{                                Status_Req                                    }
{==============================================================================}
PROCEDURE TFormMain.OnCmdStatus_Req(Sender: TChatLine; var sReceivedMessage: String; UserID:cardinal);
VAR tLocalUser: TChatUser;
    tUser: TChatUser;
    id : cardinal;
    MainLine: TChatLine;
BEGIN
MainLine := GetMainLine();
if MainLine = nil then UserId := INVALID_USER_ID;

if UserId <> INVALID_USER_ID then
  begin
  tUser := MainLine.GetUserInfo(UserId);
  {FormMain.MainLine.ChatLineView.AddFromNewLine({'[' + inttostr(UserId) + '] ' +}
  {                      tUser.NickName + ': STATUS_REQ ', cvsNormal);
  FormMain.MainLine.ChatLineView.Format;}
  id := MainLine.GetLocalUserID();
  if (id <> INVALID_USER_ID) and (Id <> UserId) then
    begin
    tLocalUser := MainLine.GetUserInfo(id);
    //FormMain.Caption := '���� ���� ������ -> ' + tUser.ComputerName;
    SendCommStatus(PChar(tUser.ProtoName),
                   PChar(tUser.ComputerName), Ord(tLocalUser.Status),
                   PChar(tLocalUser.MessageStatus.strings[Ord(tLocalUser.Status)]));
//    SendCommBoard(PChar(tUser.ComputerName), tLocalUser.MessageBoard.GetText, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
    end;
  end;
END;

{==============================================================================}
{                           OnCmdRefresh_Board                                 }
{==============================================================================}
PROCEDURE TFormMain.OnCmdRefresh_Board(Sender: TChatLine; var sReceivedMessage: String; UserID: cardinal);
VAR tLocalUser: TChatUser;
    tUser: TChatUser;
    id : cardinal;
    MainLine: TChatLine;
BEGIN
MainLine := GetMainLine();
if MainLine = nil then UserId := INVALID_USER_ID;

if UserId <> INVALID_USER_ID then
  begin
  tUser := MainLine.GetUserInfo(UserId);
  {FormMain.MainLine.ChatLineView.AddFromNewLine({'[' + inttostr(UserId) + '] ' +}
  {                      tUser.NickName + ': STATUS_REQ ', cvsNormal);
  FormMain.MainLine.ChatLineView.Format;}
  id := MainLine.GetLocalUserID();
  if (id <> INVALID_USER_ID) and (Id <> UserId) then
    begin
    tLocalUser := MainLine.GetUserInfo(id);
    //FormMain.Caption := '���� ���� ������ -> ' + tUser.ComputerName;
    SendCommBoard(PChar(tUser.ProtoName),
                  PChar(tUser.ComputerName),
                  tLocalUser.MessageBoard.GetText, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
//    SendCommBoard(PChar(tUser.ComputerName), tLocalUser.MessageBoard.GetText, TDreamChatConfig.GetMaxSizeOfMessBoardPart());
    end;
  end;
END;

procedure TFormMain.SpeedButton7Click(Sender: TObject);
begin
  AFormSmiles.ShowModal;
end;

procedure TFormMain.Splitter1Moved(Sender: TObject);
begin
  Panel3.Tag := Panel3.Height;//���� ������� ������� - ���������� ���������
end;

procedure TFormMain.ClearButtonClick(Sender: TObject);
var ChatLine: TChatLine;
begin
ChatLine := FormMain.GetActiveChatLine();
if ChatLine <> nil then
  begin
  ChatLine.ChatLineView.Clear;
  ChatLine.ChatLineView.Format;
  ChatLine.ChatLineView.Repaint;
  end;
end;

procedure TFormMain.SpeedButton10Click(Sender: TObject);
begin
FormAbout := TFormAbout.Create(FormMain, TPathBuilder.GetComponentsFolderName {ExePath + 'components\'}, TPathBuilder.GetSmilesFolderName {ExePath + 'Smiles\'});
end;

procedure TFormMain.SpeedButton9Click(Sender: TObject);
BEGIN
//  self.FSettings := TFSettings.Create(nil);
  with self.FSettings do
  begin
    try
      Init;
      ShowModal;
    finally
//      Free;
//      self.FSettings := nil;
    end;
  end;
end;

procedure TFormMain.ChangeLang(LangFile: string);
var i:integer;
  s:string;
  Section:TStringList;
  MemIniStrings:TMemIniFile;
  CLine:TChatLine;
begin
  fmInternational.BeginUpdate;
  EInternational.BeginUpdate;
  fmInternational.Clear;
  EInternational.Clear;
  Section := TStringlist.Create;
  MemIniStrings := TMemIniFile.Create(LangFile);
  MemIniStrings.ReadSection('Strings', Section);
  for i := 0 to (Section.Count-1) do
    begin
    fmInternational.Add(MemIniStrings.ReadString('Strings', InttoStr(i + 10), ''));
    EInternational.Add(MemIniStrings.ReadString('ErrorStrings', InttoStr(i + 10), ''));
    end;
  s := MemIniStrings.ReadString('Common', 'KeyboardLayout', '00000419');
  LoadKeyboardLayout(PChar(s), KLF_ACTIVATE);
  ClearButton.Hint := MemIniStrings.ReadString('Hints', 'ClearBtn', ClearButton.Hint);
  RefreshButton.Hint := MemIniStrings.ReadString('Hints', 'RefreshBBtn', RefreshButton.Hint);
  SpeedButton3.Hint := MemIniStrings.ReadString('Hints', 'Status0Btn', SpeedButton3.Hint);
  SpeedButton4.Hint := MemIniStrings.ReadString('Hints', 'Status1Btn', SpeedButton4.Hint);
  SpeedButton5.Hint := MemIniStrings.ReadString('Hints', 'Status2Btn', SpeedButton5.Hint);
  SpeedButton6.Hint := MemIniStrings.ReadString('Hints', 'Status3Btn', SpeedButton6.Hint);
  SpeedButton7.Hint := MemIniStrings.ReadString('Hints', 'SmileBtn', SpeedButton7.Hint);
  SpeedButton8.Hint := MemIniStrings.ReadString('Hints', 'DebugBtn', SpeedButton8.Hint);
  SpeedButton9.Hint := MemIniStrings.ReadString('Hints', 'SettingsBtn', SpeedButton9.Hint);
  SpeedButton10.Hint := MemIniStrings.ReadString('Hints', 'AboutBtn', SpeedButton10.Hint);
  MemIniStrings.Free;
  Section.Free;
  fmInternational.EndUpdate;
  EInternational.EndUpdate;

  if ChatLines.Find(TDreamChatDefaults.MainChatLineName {'iTCniaM'},i) then
  begin
    CLine:=TChatLine(ChatLines.Objects[i]);
    CLine.DisplayChatLineName := fmInternational.Strings[I_CommonChat];
    CLine.ChatLineTabSheet.Caption:= fmInternational.Strings[I_CommonChat]+' ['+
      IntToStr(CLine.UsersCount)+']'+CloseBtnString;
  end;

  FormMain.TabSheet2.Caption := fmInternational.Strings[I_MESSAGESBOARD];

  //ChatConfig.WriteString('Common','Language','Languages\'+ExtractFileName(LangFile));
  TDreamChatConfig.SetLanguageFileName(LangFile); // it will automatically extract file nname and append to languages folder
end;

procedure TFormMain.PanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;  { a magic number }
begin
  ReleaseCapture;
  perform(WM_SysCommand, SC_DragMove, 0);
end;

procedure TFormMain.PageControl1CloseBtnClick(Sender: TComponent;
  TabIndex: Integer; var CanClose: Boolean; var Action: TacCloseAction);
begin
  CanClose:=False;
  UFormMain.FormMain.Edit1.Text:='/close';
  PostMessage(UFormMain.FormMain.Edit1.Handle,WM_KEYUP,13,0);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if MinimizeOnClose then
  begin
    CanClose := False;
    if Application.MainForm <> nil then
      Application.MainForm.Visible := False;
  end;
end;

procedure TFormMain.MainLoopTimerTimer(Sender: TObject);
begin
  MainLoop;
end;

end.




