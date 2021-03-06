unit ChatView;
//������ �������� � ���, ��� ��� ������ ������ ������� ����������� ������ ��������� ��
//�������� ������. �� �� � ��� ����� �������� ����� ���� ��������� �������� �
//������ ��������� � ���� �������� ������������ ������ ����

interface
{$I CV_Defs.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  CVStyle, CVScroll, ClipBrd, ImgList,
  litegifx2, CVLiteGifAniX2, ExtCtrls;
  {------------------------------------------------------------------}



const
  cvVersion     = 'TChatView v0.50 by Bajenov Andrey';
  cvsBreak      = -1;
  cvsCheckPoint = -2;
  cvsPicture    = -3;
  cvsHotSpot    = -4;
  cvsComponent  = -5;
  cvsBullet     = -6;
  cvsGif        = -7;
  cvsGifAni     = -8;
  BeginSelection    = 0;
  ContinueSelection = 1;
  EndSelection      = 2;
type

  TChatView = class;
  TCVSaveFormat = (cvsfText,
                   cvsfHTML,
                   cvsfRTF, //<---not yet implemented
                   cvsfcvF  //<---not yet implemented
                   );
  TCVSaveOption = (cvsoOverrideImages);
  TCVSaveOptions = set of TCVSaveOption;

  {------------------------------------------------------------------}
  TDrawLineInfo = class
  {������, ������� �������� ���� � �����. �.�. � ���� ����� � ��� �����
   ���������� ��������� �����������, ����� � ������� ���������� �� �������
   BaseLine, ������� ����� ��� ���������� ����� ����� ��������� ��
   ���� ���������� BaseLine, ����� ������� ���� ����������, �� �������� �����
   ��� �����.
   ���� ����� ����� �������� � ������ ����� ��������� ��������-�����������}
     BaseLine, MaxHeight: Integer;
     LineNumber: Integer;
  end;
  {------------------------------------------------------------------}
  TLinkInfo = class;
  {------------------------------------------------------------------}
  TDrawContainerInfo = class
  {������-���������, ������� �������� ���� � ��� � ����� ���������� X,Y
   ������� ���� ����������. ����������, � ����������� �� ������ �����
   ���� �������, GIF, Control � �.�.}
     Left, Width, Height: Integer;
     {Top ������ ������� �� TDrawLineInfo}
     Bottom, LineNum: PInteger;
     ContainerNumber: Integer;
     FromNewLine: Boolean;
     pDrawLineInfo: TDrawLineInfo;
     LinkId: integer;//������ ��� ����� �� ������ TLinkInfo, �� ��� ���������
     //����� �� ��� ����� ����������.
     {WordOffset:Integer;{������ ��� ������! ���� ������ 0 ������ ���
                         ���������� ���� �������� � ������ �����.
                         ���� ������ ����, �� � �����}
     //������ �� ������-�����, ����� ����� ��� ����� ���� ����������
     //� �� ��� ����� ������� � ����� ����������� ������ ������
  end;
  {------------------------------------------------------------------}
{������������ ��� ������������ �� � ���� �����}
  TContainerInfo = class
  {������-���������, ������� �������� ���� � ����������� ��������, ���
   ����� ���� �������, GIF, Control � �.�.}
     StyleNo: Integer;
     SameAsPrev: Boolean;
     Center: Boolean;
     imgNo: Integer; { for cvsJump# used as jump id }
     gr: TPersistent;
     fon: TBitMap;
     LinkId: integer;
  end;
  {------------------------------------------------------------------}
  TCPInfo = class
    public
     Y, LineNo: Integer;
  end;
  {------------------------------------------------------------------}
  TJumpInfo = class
    public
     l,t,w,h: Integer;
     id, idx: Integer;
  end;
  {------------------------------------------------------------------}
  TLinkMouseMove = procedure (Sender:TChatView; DrawContainer: TDrawContainerInfo; LinkInfo:TLinkInfo) of object;//���������� ����� �� ������
  TLinkMouseDown = procedure (Sender:TChatView; DrawContainer: TDrawContainerInfo; LinkInfo:TLinkInfo) of object;//���������� ����� �� ������

  TDebugEvent = procedure (Mess, Mess2: String) of object;
  TDrawGifAni = procedure (MirrorNumber:Word) of object;
  TBeginGifAni = procedure (DestCanvas:TCanvas; BackGroundColor:TColor) of object;
  TJumpEvent = procedure (Sender: TObject; id: Integer) of object;
  TCVMouseMoveEvent = procedure (Sender: TObject; id: Integer) of object;
  TCVSaveComponentToFileEvent = procedure (Sender: TChatView; Path: String; SaveMe: TPersistent; SaveFormat: TCVSaveFormat; var OutStr:String) of object;
  TCVURLNeededEvent = procedure (Sender: TChatView; id: Integer; var url:String) of object;
  TCVDblClickEvent = procedure  (Sender: TChatView; ClickedWord: String; Style: Integer) of object;
  TCVRightClickEvent = procedure  (Sender: TChatView; ClickedWord: String; Style, X, Y: Integer) of object;
  {------------------------------------------------------------------}
  TBackgroundStyle = (bsNoBitmap, bsStretched, bsTiled, bsTiledAndScrolled);
  {------------------------------------------------------------------}
  TCVDisplayOption = (cvdoImages, cvdoComponents, cvdoBullets);
  TCVDisplayOptions = set of TCVDisplayOption;
  {------------------------------------------------------------------}
  TScreenAndDevice = record
       ppixScreen, ppiyScreen, ppixDevice, ppiyDevice: Integer;
       LeftMargin: Integer;
   end;
  {------------------------------------------------------------------}
  TLinkInfo = class
  {���� ������ �������� � ���� ���������� � ���� ������, � ��� ��� �� ����������
  � ��� �� ����������. ����� ������ ������ ������. ������ ����������������
  ������ ������ DrawContainerInfo, ����� ����� ��������� �� ���� �� ��������
  ������ ��� ������ nil. ��������� DrawContainerInfo ����� ��������� �� ����
  � ����� ������ ������. �������� GIF-��������� � ������ �� ��� �����-���������}
     LinkType: Integer;
     OnMouseLinkStyle: integer;
     OnLinkMouseMove: TLinkMouseMove;
     OnLinkMouseDown: TLinkMouseDown;
     Link:String;
     Hint:String;
  end;
  {------------------------------------------------------------------}
  TCVInteger2 = class
   public
    val: Integer;
  end;
  {------------------------------------------------------------------}
  TChatView = class(TCVScroller)
  private
    { Private declarations }
    FVersion: String;
    FDebugText:string;
    FDebugText2:string;
    BufferVirtCanv: TBitmap;//����������� ������! ������� ������ �� ��� ����� �������� � ��������!
    TimerScrollStepY, ScrollToY: Integer;
    FVScrollBound, FHScrollBound: Word;
    TempTimerDebug:cardinal;
    VScrollUp:boolean;
    ScrollTimer: TTimer;
    FAllowSelection, FSingleClick, FCursorSelection: Boolean;
    FDelimiters: String;
    FMergeDelimiters: String;
    Scrolling, DrawHover, Selection: Boolean;
    FOnJump: TJumpEvent;
    FOnDebug: TDebugEvent;//��������! � ��������� ChatView1.OnDebug := Form1.Debug; ����� Access Violation !
    FOnCVMouseMove: TCVMouseMoveEvent;
    FOnSaveComponentToFile: TCVSaveComponentToFileEvent;
    FOnURLNeeded: TCVURLNeededEvent;
    FOnCVDblClick: TCVDblClickEvent;
    FOnCVRightClick: TCVRightClickEvent;
    FOnSelect, FOnResized: TNotifyEvent;
    FFirstJumpNo, FMaxTextWidth, FMinTextWidth, FLeftMargin, FRightMargin: Integer;
    FBackBitmap: TBitmap;
    FBackgroundStyle: TBackgroundStyle;
    OldWidth, OldHeight: Integer;
    FSelStartX, FSelStartY, FSelEndX, FSelEndY: Integer;
    FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
    FSelStartPixOffsInCont, FSelEndPixOffsInCont: Integer;
    FCursorPosX, FCursorPosY, FCursor: integer;//x, y � ��������, FCursor ����� ����������
    FGifAniObjNo : word;
    //procedure InvalidateJumpRect(ContNum: Integer);
    procedure SetStyleOfLinkObject(ContNum: Integer; StyleNumber:integer);
    procedure InvalidateLinkObject(ContNum: Integer);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMVScroll); message WM_HSCROLL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;

//    procedure WMNCMOUSEMOVE(var Message: TMessage); message WM_NCMOUSEMOVE;
    procedure CMInvalidate(var Message: TMessage); message CM_INVALIDATE;
    procedure DefaultDebug(Mess, Mess2: String);
    function GetLineCount: Integer;
//    function GetPrevContainerInThisLine(DrawCont:TDrawContainerInfo): TContainerInfo;
    function GetMaxHeight(Line, FromObject:integer):Integer;
    function GetMinHeight(Line, FromObject:integer):Integer;
    function FindItemAtPos(X,Y: Integer): Integer;//���� �� ����� ������������� ������� (���������������) ��������
    function FindItemAtScreenPos(ScrX, ScrY: Integer): Integer;//���� �� ����� ������������� ������� (���������������) ��������
    function FindNearItemAtPos(X, Y: Integer): Integer;
    function FindNearItemAtScreenPos(X, Y: Integer): Integer;
    function FindNearestItemAtPos(X, Y: Integer): Integer;//���� �� ����� ������������� ������� (���������������) ��������
    function FindNearestItemAtScreenPos(ScrX, ScrY: Integer): Integer;//���� �� ����� ������������� ������� (���������������) ��������
    function GetWordOffset(ContNumber:cardinal; XRange:integer;Str:PChar;StrLen:cardinal;
                           var SelContNo, SelPixOffsInCont:integer):integer;
    function FindSymbolAtScreenPos(ScrX, ScrY: Integer): String;
    procedure SetSelectionItems(X, Y: Integer);
    procedure SetCursorSelectionItems(X, Y: Integer);
    procedure SetCursorContainer(Cont: Integer);
    procedure SetGifAniCanvas(DestionationCanvas: TCanvas);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CorrectSelectionBounds(x, y: integer);
    procedure RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
  protected
    { Protected declarations }
    checkpoints: TStringList;
    jumps: TStringList;
    FStyle: TCVStyle;
    nJmps: Integer;
    TextWidth, TextHeight: Integer;
    LastJumpMovedAbove: Integer;
    LastLinkMovedAbove:Integer;
    LastJumpDowned, XClicked, YClicked, XMouse, YMouse: Integer;
    imgSavePrefix: String;
    imgSaveNo: Integer;
    SaveOptions: TCVSaveOptions;
    skipformatting: Boolean;
    ShareContents: Boolean;

    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
    procedure Click; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure FormatNextContainer(var DrawLineInfo:TDrawLineInfo;
                                  var LineNum, ContNum, x, baseline, Ascent:Integer;
                                  var sourceStrPtr:PChar;
                                  var newline{, CreateDrawLine}:boolean;
                                  Canvas: TCanvas; var sad: TScreenAndDevice);
{FormatNextContainer FormatNextContainer FormatNextContainer FormatNextContainer}




    procedure AdjustJumpsCoords;
//    procedure AdjustChildrenCoords;
    procedure ClearTemporal;
    function GetFirstVisibleContainer: cardinal;
    function GetLastVisibleContainer: cardinal;
    function GetLastContainerInCurrLine(FromContainerNumber: integer): integer;
    function GetFirstContainerInCurrLine(FromContainerNumber: integer): integer;
    function GetContainerAtXInLine(X, LineNum:integer): integer;
    function GetPrevBaseLine(ContNumber:cardinal): integer;
    procedure Format_(OnlyResized:Boolean; depth: Integer; Canvas: TCanvas; OnlyTail: Boolean);
    procedure SetBackBitmap(Value: TBitmap);
    procedure DrawBack(DC: HDC; Rect: TRect; Width,Height:Integer);
    procedure SetBackgroundStyle(Value: TBackgroundStyle);
    function GetNextFileName(Path: String): String; virtual;
    procedure ShareLinesFrom(Source: TChatView);
    procedure OnScrollTimer(Sender: TObject);
    procedure Loaded; override;
  public
    { Public declarations }
    LinksInfo : TStringList;
    DrawLinesInfo : TStringList;
    ContStorage : TStringList;
    DrawContainers : TStringList;
    {� ���� ������ ��������� ���������� ��������� �� ��� ����������!!!!
    ���������� ��� ��������� �������, ������� ������������ �� �������� ����� ������
    ���� ��� �����, �� ������ ��������� �������, � ��������� ��������� ��
    ��������� �� ������. ���� ��� ��������, �� ������ '', � ��������� ���������
    �� ������, ���������� �������� ��������}
    DisplayOptions: TCVDisplayOptions;
    FClientTextWidth: Boolean;
    property CursorSelection: boolean read FCursorSelection write FCursorSelection;
    property CursorContainer: integer read FCursor write SetCursorContainer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
    procedure Paint; override;
    Function GetCanvas():TCanvas;
    Function AddLink(LinkType:Integer; OnLinkMouseMove: TLinkMouseMove;
             OnLinkMouseDown: TLinkMouseDown; OnMouseLinkStyle: integer; LinkText:String):integer;//��������� ������ � ������ ������
    Function DeleteLink(LinkId:Integer):boolean;//������� ������ �� ������� ������
    procedure AddFromNewLine(s: String; StyleNo, LinkId:Integer);
    procedure Add(s: String;StyleNo, LinkId:Integer);
    procedure AddCenterLine(s: String; StyleNo, LinkId:Integer);
    procedure AddText(s: String; StyleNo, LinkId:Integer);
    procedure AddTextFromNewLine(s: String; StyleNo, LinkId:Integer);
    procedure AddBreak;
    function AddCheckPoint: Integer; { returns cp # }
    function AddNamedCheckPoint(CpName: String): Integer; { returns cp # }
    function GetCheckPointY(no: Integer): Integer;
    function GetJumpPointY(no: Integer): Integer;
    procedure AddPicture(gr: TGraphic; LinkId:Integer);
    procedure AddHotSpot(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
    procedure AddBullet (imgNo: Integer; lst: TImageList; fromnewline: Boolean);
//    procedure AddControl(ctrl: TWinControl; center: Boolean);
    procedure AddWinControl(ctrl: TWinControl; center: Boolean; LinkId:Integer);
//    procedure AddGifAni(s: String;imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);
    procedure AddGifAni(s: String; Gif: TGif; fromnewline: Boolean; LinkId:Integer);

    function GetMaxPictureWidth: Integer;
    procedure Clear;
    procedure Format;
    procedure FormatTail;

    procedure AppendFrom(Source: TChatView);
    function GetLastCP: Integer;
    function SaveHTML(FileName, Title, ImagesPrefix: String; Options: TCVSaveOptions):Boolean;
    function SaveText(FileName: String; LineWidth: Integer):Boolean;

    procedure DeleteSection(CpName: String);
    procedure DeleteLines(FirstLine, Count: Integer);

    //use this only inside OnSaveComponentToFile event handler:
    function SavePicture(DocumentSaveFormat: TCVSaveFormat; Path: String; gr: TGraphic): String; virtual;

    procedure GetSelectedText;
    function GetSelText: String;
    function SelectionExists: Boolean;
    procedure Deselect;
    procedure SelectAll;

    property LineCount: Integer read GetLineCount;
    property FirstVisibleContainer: cardinal read GetFirstVisibleContainer;
    property LastVisibleContainer: cardinal read GetLastVisibleContainer;
    procedure SmoothScrollToY(ScrollToYPos:Integer;ScrollSpeed:cardinal);
    procedure SmoothScrollDeltaY(DeltaY:Integer;ScrollSpeed:cardinal);
  published
    { Published declarations }
    property PopupMenu;
    property OnClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property Version: String read FVersion;
    property FirstJumpNo: Integer read FFirstJumpNo write FFirstJumpNo;
    property OnJump: TJumpEvent read FOnJump write FOnJump;
    property OnCVMouseMove: TCVMouseMoveEvent read FOnCVMouseMove write FOnCVMouseMove;
    property OnSaveComponentToFile: TCVSaveComponentToFileEvent read FOnSaveComponentToFile write FOnSaveComponentToFile;
    property OnURLNeeded: TCVURLNeededEvent read FOnURLNeeded write FOnURLNeeded;
    property OnCVDblClick: TCVDblClickEvent read FOnCVDblClick write FOnCVDblClick;
    property OnCVRightClick: TCVRightClickEvent read FOnCVRightClick write FOnCVRightClick;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property OnResized: TNotifyEvent read FOnResized write FOnResized;
    property OnDebug: TDebugEvent read FOnDebug write FOnDebug;
    property Style: TCVStyle read FStyle write FStyle;
    property MaxTextWidth:Integer read FMaxTextWidth write FMaxTextWidth;
    property MinTextWidth:Integer read FMinTextWidth write FMinTextWidth;
    property LeftMargin: Integer read FLeftMargin write FLeftMargin;
    property RightMargin: Integer read FRightMargin write FRightMargin;
    property BackgroundBitmap: TBitmap read FBackBitmap write SetBackBitmap;
    property BackgroundStyle: TBackgroundStyle read FBackgroundStyle write SetBackgroundStyle;
    property Delimiters: String read FDelimiters write FDelimiters;
    property MergeDelimiters: String read FMergeDelimiters write FMergeDelimiters;
    property AllowSelection: Boolean read FAllowSelection write FAllowSelection;
    property SingleClick: Boolean read FSingleClick write FSingleClick;
    property VScrollBound: Word read FVScrollBound write FVScrollBound;
    property HScrollBound: Word read FHScrollBound write FHScrollBound;
  end;

procedure InfoAboutSaD(var sad:TScreenAndDevice; Canvas: TCanvas);

implementation
{-------------------------------------}

procedure TChatView.CMInvalidate(var Message: TMessage);
//var n:integer;
begin
//scrolling := true;
//MessageBox(0, '', PChar(Inttostr(1)), mb_ok);
//DrawFrame;
inherited;
//scrolling := false;
end;

{-------------------------------------}
procedure InfoAboutSaD(var sad:TScreenAndDevice; Canvas: TCanvas);
var screenDC: HDC;
begin
     sad.ppixDevice := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
     //����� �������� �� ���������� ���� �� ������ ���������� (�������)
     sad.ppiyDevice := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
     //����� �������� �� ���������� ���� �� ������ ���������� (�������)
     screenDc := CreateCompatibleDC(0);
     //������� ���������� ������
     sad.ppixScreen := GetDeviceCaps(screenDC, LOGPIXELSX);
     //����� �������� �� ���������� ���� �� ������ ���������� (�������)
     sad.ppiyScreen := GetDeviceCaps(screenDC, LOGPIXELSY);
     //����� �������� �� ���������� ���� �� ������ ���������� (�������)
     DeleteDC(screenDC);
     //���������� ���������� ������
//� ���������� � sad ������������ ������� ��� ���������� ������� �
//������� ������� ������������ � ������� �� ���������
//��� ���� ��� �����? ��� �������� ��������...
end;
{==================================================================}
constructor TChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVersion              := cvVersion;
  FOnDebug              := DefaultDebug;
  BufferVirtCanv        := TBitmap.Create;

  FClientTextWidth      := False;
  FLeftMargin           := 5;
  FRightMargin          := 5;
  FMaxTextWidth         := 0;
  FMinTextWidth         := 0;
  TextWidth             := -1;
  TextHeight            := 0;
//  LastJumpMovedAbove    := -1;
  LastLinkMovedAbove    := -1;
  FStyle                := nil;
  LastJumpDowned        := -1;
  LinksInfo             := TStringList.Create;
  DrawLinesInfo         := TStringList.Create;
  DrawContainers        := TStringList.Create;
  ContStorage           := TStringList.Create;
  checkpoints           := TStringList.Create;
  jumps                 := TStringList.Create;
  FBackBitmap           := TBitmap.Create;
  FBackGroundStyle      := bsNoBitmap;
  nJmps                 :=0;
  FirstJumpNo           :=0;
  skipformatting        := False;
  OldWidth              := 0;
  OldHeight             := 0;
  Width                 := 100;
  Height                := 40;
  DisplayOptions        := [cvdoImages, cvdoComponents, cvdoBullets];
  ShareContents         := False;
  FDelimiters           := ' .;,:)}';
  FMergeDelimiters      := '({"|';
  DrawHover             := False;
  FSelStartContNo       := -1;
  FSelEndContNo         := -1;
  FSelStartOffsInCont   := 0;
  FSelEndOffsInCont     := 0;
  FSelStartPixOffsInCont:= 0;
  FSelEndPixOffsInCont  := 0;
  FSelStartX            := -1;
  FSelStartY            := -1;
  FSelEndX              := -1;
  FSelEndX              := -1;
  Scrolling            := False;
  Selection             := False;
  FAllowSelection       := True;
//  FCursorSelection      := False;
  FCursorSelection      := True;//�������� ������, �������� ������ ��������� ����� ����������
  FCursorPosX           := 0;//������� ������� ������� ���������� ���������� X
  FCursorPosY           := 0;//������� ������� ������� ���������� ���������� Y
  FCursor               := 0;//������� ������� ������� (����� ������������������ ����������)
  ScrollTimer           := nil;
  TimerScrollStepY      := 10;
  ScrollToY             := -1;
  FVScrollBound         := 20;
  FHScrollBound         := 20;
  FGifAniObjNo          := 0;
  AddFromNewLine('', 0, -1);
  //Format_(False,0, Canvas, False);
end;
{-------------------------------------}
destructor TChatView.Destroy;
var n: cardinal;
begin
{  for n := 0 to DrawContainers.Count - 1 do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo <> DestroytedPointer then
      //���������� ��� ������� �����, �� ������� ��������� �������-����������.
      begin
      //�.�. ��������� �� ������, �� ����� ��������� �� ��� ����������� ������
      //�������� ������, ���. ����� � ������ ����� ��������� �� �������
      DestroytedPointer := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
      TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.Free;
      end;
    end;}
  //���������� ���������� �����������
  Clear;
//  GifFrame.Free;
  FBackBitmap.Free;
  BufferVirtCanv.Free;
  //���������� ���� �������-����������
  if DrawLinesInfo.Count > 0 then
    begin
    for n := 0 to DrawLinesInfo.Count - 1 do
      begin
      TDrawLineInfo(DrawLinesInfo.Objects[n]).Free;
      end;
    end;
  //���������� �������-���� ������
  if LinksInfo.Count > 0 then
    begin
    for n := 0 to LinksInfo.Count - 1 do
      begin
      TLinkInfo(LinksInfo.Objects[n]).Free;
      end;
    end;
  LinksInfo.Free;
  DrawLinesInfo.Free;
  DrawContainers.Free;
  checkpoints.Free;
  jumps.Free;
  if not ShareContents then ContStorage.Free;
  inherited Destroy;
end;
{-------------------------------------}
procedure TChatView.DefaultDebug(Mess, Mess2: String);
begin
//�� �������! ���� �� �������� ���������� OnDebug, �� ���������� ��� ���������.
end;
{-------------------------------------}
procedure TChatView.WMSize(var Message: TWMSize);
begin
  Format_(True, 0, Canvas, False);
  if Assigned(FOnResized) then FOnResized(Self);
//  Paint;
end;
{-------------------------------------}
procedure TChatView.Format;
begin
  Format_(False, 0, Canvas, False);
end;
{-------------------------------------}
procedure TChatView.FormatTail;
begin
  Format_(False, 0, Canvas, True);
end;
{-------------------------------------}
procedure TChatView.ClearTemporal;
var i: Integer;
begin
  if ScrollTimer<>nil then begin
     ScrollTimer.Free;
     ScrollTimer := nil;
  end;
  DrawContainers.BeginUpdate;
  for i:=0 to DrawContainers.Count-1 do begin
    TDrawContainerInfo(DrawContainers.objects[i]).Free;
    DrawContainers.objects[i] := nil;
  end;
  DrawContainers.Clear;
  DrawContainers.EndUpdate;
  checkpoints.BeginUpdate;
  for i:=0 to checkpoints.Count-1 do begin
    TCPInfo(checkpoints.objects[i]).Free;
    checkpoints.objects[i] := nil;
  end;
  checkpoints.Clear;
  checkpoints.EndUpdate;
  jumps.BeginUpdate;
  for i:=0 to jumps.Count-1 do begin
    TJumpInfo(jumps.objects[i]).Free;
    jumps.objects[i] := nil;
  end;
  jumps.Clear;
  jumps.EndUpdate;
  nJmps :=0;
end;
{-------------------------------------}
procedure TChatView.Deselect;
begin
  Selection := False;
  FSelStartContNo := -1;
  FSelEndContNo := -1;
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := 0;
  if Assigned(FOnSelect) then OnSelect(Self);  
end;
{-------------------------------------}
procedure TChatView.SelectAll;
begin
  FSelStartContNo := 0;
  FSelEndContNo := DrawContainers.Count-1;
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := 0;
  if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[FSelEndContNo]).ContainerNumber]).StyleNo>=0 then
    FSelEndOffsInCont := Length(DrawContainers[FSelEndContNo])+1;
  if Assigned(FOnSelect) then OnSelect(Self);
end;
{-------------------------------------}
procedure TChatView.Clear;
var i: Integer;
begin
  Deselect;
  if not ShareContents then
    begin
    ContStorage.BeginUpdate;
    for i := 0 to ContStorage.Count - 1 do
      begin
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then { image}
        begin
        TContainerInfo(ContStorage.objects[i]).gr := nil;
        end;
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then {wincontrol}
        begin
//        RemoveControl(TControl(TContainerInfo(ContStorage.objects[i]).gr));
//        TContainerInfo(ContStorage.objects[i]).gr.Free;
//        TContainerInfo(ContStorage.objects[i]).gr := nil;
        end;
      if TContainerInfo(ContStorage.objects[i]).StyleNo = -8 then {GifAni}
        begin
        //����� ���������� ������, ���� � UNIT1 GIFImage1.free; �������
        //�� ChatView1.clear;
        //����� ������� � ����� ���-�� ��������� ��������� �� �������� �����
        //DelAllMirrorImages() ��� ��� ��� ����� ������ �������...
        //������� �������: � UNIT1 ������� ChatView1.clear; � ����� ��� GIFImage1.free;
        TGifAni(TContainerInfo(ContStorage.objects[i]).gr).DelAllMirrorImages();
        end;
      TContainerInfo(ContStorage.objects[i]).Free;
      ContStorage.objects[i] := nil;
      end;
    ContStorage.Clear;
    ContStorage.EndUpdate;
    end;
  ClearTemporal;
  AddFromNewLine('', 0, -1);
end;
{-------------------------------------}
Function TChatView.DeleteLink(LinkId:Integer):boolean;
var n: integer;
begin
//�� ������ �� ������ ������� ������ � ����� id �� ������� ������, �� �
//����������� �� ���� ����������� � �������� ��������� �� ��� ������
//� ������ ����� �� ����� ���������? � � ����������� ������� id?
//�������� ��� ���� �� ������...
result := false;
if (LinksInfo.Count > 0) and (LinkId >= 0) and (LinkId <= LinksInfo.Count) then
  begin
  if LinksInfo.Objects[LinkId] <> nil then
    begin
    for n := 0 to ContStorage.Count - 1 do
      begin
      if LinkId = TContainerInfo(ContStorage.Objects[n]).LinkId then TContainerInfo(ContStorage.Objects[n]).LinkId := -1;
      end;
    for n := 0 to DrawContainers.Count - 1 do
      begin
      if LinkId = TDrawContainerinfo(DrawContainers.Objects[n]).LinkId then TDrawContainerinfo(DrawContainers.Objects[n]).LinkId := -1;
      end;
    TLinkInfo(LinksInfo.Objects[LinkId]).free;
    LinksInfo.Delete(LinkId);
    result := true;
    end;
  end;
end;
{-------------------------------------}
Function TChatView.AddLink(LinkType:Integer; OnLinkMouseMove: TLinkMouseMove;
                           OnLinkMouseDown: TLinkMouseDown; OnMouseLinkStyle: integer;
                           LinkText:String):integer;
var LinkInfo: TLinkInfo;
//  n: integer;
begin
{if LinksInfo.Count > 0 then
  begin
  for n := 0 to LinksInfo.Count - 1 do
    begin
    if TLinkInfo(LinksInfo.Objects[n]).LinkType = LinkType then
      begin
      TLinkInfo(LinksInfo.Objects[n]).OnLinkMouseMoveEvent := OnLinkMouseMove;
      TLinkInfo(LinksInfo.Objects[n]).Link := LinkText;
      result:= n;
      exit;
      end;
    end;
  end;}
LinkInfo := TLinkInfo.Create;
LinkInfo.OnMouseLinkStyle := OnMouseLinkStyle;
LinkInfo.LinkType := LinkType;
LinkInfo.Link := LinkText;
LinkInfo.OnLinkMouseMove := OnLinkMouseMove;
LinkInfo.OnLinkMouseDown := OnLinkMouseDown;
result:= LinksInfo.AddObject('', LinkInfo);
end;

procedure TChatView.AddFromNewLine(s: String; StyleNo, LinkId:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := False;
  if (LinkId >= 0) and (LinksInfo.Count > 0) and (LinkId <= LinksInfo.Count) then
    info.LinkId := LinkId
  else
    info.LinkId := -1;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.Add(s: String; StyleNo, LinkId:Integer);
var info: TContainerInfo;
begin
//���� ��������� ����� ��� ������, �� �������� LinkId := -1!!!
//��������� ������ ������ ��� ����, �.�. #10#13
//����� ������������ �����������
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  if ContStorage.Count = 0 then
    info.SameAsPrev := false
  else
    info.SameAsPrev := true;
  info.Center := False;
  if (LinkId >= 0) and (LinksInfo.Count > 0) and (LinkId <= LinksInfo.Count) then
    info.LinkId := LinkId
  else
    info.LinkId := -1;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddText(s: String;StyleNo, LinkId:Integer);
var p: Integer;
begin
//���� � ������ ������ ���� #10#13,
//�� ���������� ������� ������ �� ��������� ������
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     if s<>'' then Add(s,StyleNo, LinkId);
     exit;
   end;
   Add(Copy(s,1,p-1), StyleNo, LinkId);
   Delete(s,1, p+1);
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s, StyleNo, LinkId);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo, LinkId);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddTextFromNewLine(s: String; StyleNo, LinkId:Integer);
var p: Integer;
begin
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     AddFromNewLine(s, StyleNo, LinkId);
     exit;
   end;
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s, StyleNo, LinkId);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo, LinkId);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddCenterLine(s: String; StyleNo, LinkId:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := True;
  if (LinkId >= 0) and (LinksInfo.Count > 0) and (LinkId <= LinksInfo.Count) then
    info.LinkId := LinkId
  else
    info.LinkId := -1;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddBreak;
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -1;
  info.LinkId := -1;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
function TChatView.AddNamedCheckPoint(CpName: String): Integer;
var info: TContainerInfo;
    cpinfo: TCPInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -2;
  info.LinkId := -1;
  ContStorage.AddObject(CpName, info);
  cpInfo := TCPInfo.Create;
  cpInfo.Y := 0;
  checkpoints.AddObject(CpName,cpinfo);
  AddNamedCheckPoint := checkpoints.Count-1;
end;
{-------------------------------------}
function TChatView.AddCheckPoint: Integer;
begin
  AddCheckPoint := AddNamedCheckPoint('');
end;
{-------------------------------------}
function TChatView.GetCheckPointY(no: Integer): Integer;
begin
  GetCheckPointY := TCPInfo(checkpoints.Objects[no]).Y;
end;
{-------------------------------------}
function TChatView.GetJumpPointY(no: Integer): Integer;
var i: Integer;
begin
  GetJumpPointY := 0;
  for i:=0 to Jumps.Count-1 do
   if  TJumpInfo(jumps.objects[i]).id = no-FirstJumpNo then begin
     GetJumpPointY := TJumpInfo(jumps.objects[i]).t;
     exit;
   end;
end;
{-------------------------------------}
procedure TChatView.AddPicture(gr: TGraphic; LinkId:integer); { gr not copied, do not free it!}
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -3;
  info.gr := gr;
  info.SameAsPrev := False;
  info.Center := True;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
procedure TChatView.AddHotSpot(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -4;
  info.gr := lst;
  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
procedure TChatView.AddBullet(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -6;
  info.gr := lst;
  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
//procedure TChatView.AddGifAni(s: String;imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);
procedure TChatView.AddGifAni(s: String; Gif: TGif; fromnewline: Boolean; LinkId:Integer);
var info: TContainerInfo;
    n:cardinal;
    createGifAniObject:boolean;
    GifAniObject: TGifAni;
    imgNo: Integer;
begin
//���� ���� �� ��� ����� GifAniObject?
imgNo := 0;
createGifAniObject := true;
for n := 0 to ContStorage.count - 1 do
  begin
  info := TContainerInfo(ContStorage.objects[n]);
  if info.StyleNo = -8 then
    begin
    if Gif = TGifAni(info.gr).GifImage then
      begin
      //����� GIF ��� ����!
      GifAniObject := TGifAni(info.gr);
      createGifAniObject := false;
      break;
      end;
    end;
  end;
if createGifAniObject = true then
  begin
  //����� GIF ��� �� ����������
  GifAniObject := TGifAni.Create(Gif, self.Style.Color);
  if FCursor = 0 then CursorContainer := 1;
  end;

  GifAniObject.AddMirrorImages;
//  GifAniObject.OnDebug := Debug;
  info := TContainerInfo.Create;
  info.StyleNo := -8;
  info.gr := GifAniObject;
  if imgNo = 0 then
    begin
    info.imgNo := Length(GifAniObject.MirrorImagesX) - 1;
    end;
//  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  if (LinkId >= 0) and (LinksInfo.Count > 0) and (LinkId <= LinksInfo.Count) then
    info.LinkId := LinkId
  else
    info.LinkId := -1;
  ContStorage.AddObject(s, info);
  GifAniObject.BeginAnimate(Self.GetCanvas, Self.Style.Color);
{  GifAniObject.AddMirrorImages;
  info := TContainerInfo.Create;
  info.StyleNo := -8;
  info.gr := GifAniObject;
  if imgNo = 0 then
    begin
    info.imgNo := Length(GifAniObject.MirrorImagesX) - 1;
    end;
//  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject(s, info);
  GifAniObject.BeginAnimate(Self.GetCanvas, Self.Style.Color);}
end;
{-------------------------------------}
//procedure TChatView.AddControl(ctrl: TControl; center: Boolean); { do not free ctrl! }
procedure TChatView.AddWinControl(ctrl: TWinControl; center: Boolean; LinkId:integer); { do not free ctrl! }
var info: TContainerInfo;
begin
  ctrl.ParentWindow := Self.Handle;
  info := TContainerInfo.Create;
  info.StyleNo := -5;
  info.gr := ctrl;
//  info.SameAsPrev := false;//true;//
  info.SameAsPrev := true;
  info.Center := center;
  if (LinkId >= 0) and (LinksInfo.Count > 0) and (LinkId <= LinksInfo.Count) then
    info.LinkId := LinkId
  else
    info.LinkId := -1;
  ContStorage.AddObject('', info);
//  InsertControl(ctrl);
end;
{-------------------------------------}
function TChatView.GetMaxPictureWidth: Integer;
var i,m: Integer;
begin
{
  cvsBreak      = -1;
  cvsCheckPoint = -2;
  cvsPicture    = -3;
  cvsHotSpot    = -4;
  cvsComponent  = -5;
  cvsBullet     = -6;
  cvsGif        = -7;
  cvsGifAni     = -8;
}
m := 0;
for i := 0 to ContStorage.Count-1 do
  begin
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then
    if m < TGraphic(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TGraphic(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then
    if m < TWinControl(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TWinControl(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -7 then
    if m < TGIF(TContainerInfo(ContStorage.objects[i]).gr).Width then
      m := TGif(TContainerInfo(ContStorage.objects[i]).gr).Width;
  if TContainerInfo(ContStorage.objects[i]).StyleNo = -8 then
    if m < TGifAni(TContainerInfo(ContStorage.objects[i]).gr).GifImage.Width then
      m := TGifAni(TContainerInfo(ContStorage.objects[i]).gr).GifImage.Width;
  end;
//GetMaxPictureWidth := m;
result := m;
end;
{-------------------------------------}
function max(a,b: Integer): Integer;
begin
  if a>b then
    max := a
  else
    max := b;
end;
{-------------------------------------}
function TChatView.GetMaxHeight(Line, FromObject:integer):Integer;
var MaxHeight:integer;
begin
MaxHeight := 0;
  while (line = TDrawContainerInfo(DrawContainers.Objects[fromobject]).LineNum^) and
       (fromobject > 0) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[fromobject]).Height > MaxHeight then
      begin
      MaxHeight := TDrawContainerInfo(DrawContainers.Objects[fromobject]).Height;
      end;
    dec(fromobject);
    end;
result := MaxHeight;
end;
{-------------------------------------}
function TChatView.GetMinHeight(Line, FromObject:integer):Integer;
var MinHeight:integer;
begin
MinHeight := 0;
  while (line = TDrawContainerInfo(DrawContainers.Objects[FromObject]).LineNum^) and
        (fromobject > 0) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[FromObject]).Height < MinHeight then
      begin
      MinHeight := TDrawContainerInfo(DrawContainers.Objects[FromObject]).Height;
      end;
    dec(FromObject);
    end;
result := MinHeight;
end;

FUNCTION TChatView.GetCanvas():TCanvas;
BEGIN
Result := Canvas;
END;
{-------------------------------------}
{-------------------------------------}
{procedure TChatView.AdjustChildrenCoords;
var i: Integer;
    dli: TDrawContainerInfo;
    li : TContainerInfo;
begin
  for i:=0 to DrawContainers.Count-1 do
   begin
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   if li.StyleNo = -5 then //wincontrol
     begin
     TWinControl(li.gr).Left := dli.Left;
     TWinControl(li.gr).Tag := dli.Bottom^ - dli.Height;
     Tag2Y(TWinControl(li.gr));
     end;
   end;
end;}
{-------------------------------------}
procedure TChatView.AdjustJumpsCoords;
var i: Integer;
begin
  for i:=0 to jumps.Count-1 do begin
    TJumpInfo(jumps.Objects[i]).l :=
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).left;
    TJumpInfo(jumps.Objects[i]).t :=
//    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).top^;
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).Bottom^ -
    TDrawContainerInfo(DrawContainers.Objects[TJumpInfo(jumps.Objects[i]).idx]).Height;
  end;
end;
{-------------------------------------}
const gdlnFirstVisible =1;
const gdlnLastCompleteVisible =2;
const gdlnLastVisible =3;
{-------------------------------------}
function TChatView.GetFirstVisibleContainer: cardinal;
var n: integer;
    dli : TDrawLineInfo;
begin
//� ��� ���� ����� ����������������� �������� DrawContainers, ��� ����� ����������
//� ������ ������� ������ ����� �� ������. ��� ����� ��� ���� ������ ����� ������
//��������� ���� ��� VScrollPos
result := 0;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if dli.BaseLine > VScrollPos then
    begin
    result := n;
    break;
    end;
//  else
  n := n + 1;
  end;

//FDebugText :='VScrollPos=' + inttostr(VScrollPos) + ' GetFirstVisibleContainer = ' + inttostr(result);
//self.OnDebug(FDebugText);
end;
{-------------------------------------}
function TChatView.GetLastVisibleContainer: cardinal;
var n: integer;
dli : TDrawLineInfo;
begin
//���� ���� ����� ��������� ��������� ���������� � VScrollPos + Y ������ �������, ��
result := DrawContainers.Count - 1;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if (dli.BaseLine - TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.MaxHeight) > (VScrollPos + self.Height) then
    begin
    result := n - 1;
    break;
    end;
  n := n + 1;
  end;
end;
{------------------------------------------------------------------}
{function TChatView.GetPrevContainerInThisLine(DrawCont:TDrawContainerInfo): TContainerInfo;
var ci : TContainerInfo;
begin
{result := nil;
if (DrawCont.ContainerNumber - 1 >= 0) then
  begin
  ci := TContainerInfo(ContStorage.Objects[DrawCont.ContainerNumber - 1]);
  if (ci. pDrawLineInfo.LineNumber = DrawCont.pDrawLineInfo.LineNumber) then result := dci;
  end;}
//end;
{------------------------------------------------------------------}
function TChatView.GetLineCount: Integer;
begin
  GetLineCount := TDrawContainerInfo(DrawContainers.Objects[DrawContainers.Count - 1]).pDrawLineInfo.LineNumber;
end;
{----------------------------------------------------}
{procedure TChatView.InvalidateJumpRect(no: Integer);
var rec: TRect;
    i, id : Integer;
begin
   if Style.FullRedraw then
     Invalidate
   else begin
     id := no;
     for i:=0 to Jumps.Count -1 do
      if id = TJumpInfo(jumps.objects[i]).id then
       with TJumpInfo(jumps.objects[i]) do begin
         rec.Left := l - HScrollPos - 5;
         rec.Top  := t - VScrollPos * VScrollStep - 5;
         rec.Right := l + w - HScrollPos + 5;
         rec.Bottom := t + h - VScrollPos * VScrollStep + 5;
         InvalidateRect(Handle, @rec, False);
       end;
   end;
   Update;
end;}
procedure TChatView.SetStyleOfLinkObject(ContNum: Integer; StyleNumber:integer);
var dli: TDrawContainerInfo;
    link, n: Integer;
    li: TContainerInfo;
begin
//�����ztv ����� ��������� ������� (������ �� �������)
if ContNum >= 0 then
  begin
  link := TDrawContainerInfo(DrawContainers.Objects[ContNum]).LinkId;
  for n := FirstVisibleContainer to LastVisibleContainer do
    begin
    if link = TDrawContainerInfo(DrawContainers.Objects[n]).LinkId then
      begin
      dli := TDrawContainerInfo(DrawContainers.Objects[n]);
      li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
      if li.StyleNo >= 0 then
        begin // text
        TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo := StyleNumber;
        end;
      end;
    end;
  end;
end;

procedure TChatView.InvalidateLinkObject(ContNum: Integer);
var dli: TDrawContainerInfo;
    link, n, yshift, xshift: Integer;
//    li: TContainerInfo;
    rec: TRect;
//    p: TLinkInfo;
begin
//��� ��������� ������������ ����� �������, ������� �������� ����� ������
//��� ��������� �������� ��������� InvalidateJumpRect � ��� ������������
//��� ��������� ��������-������, ���������� ����� �������,
//��� ����������� ��� ��� ����
if Style.FullRedraw then
  Invalidate
else
  begin
  if ContNum >= 0 then
    begin
    link := TDrawContainerInfo(DrawContainers.Objects[ContNum]).LinkId;
    for n := FirstVisibleContainer to LastVisibleContainer do
      begin
      if link = TDrawContainerInfo(DrawContainers.Objects[n]).LinkId then
        begin
        dli := TDrawContainerInfo(DrawContainers.Objects[n]);
        yshift := VScrollPos + Canvas.ClipRect.Top;
        xshift := HScrollPos + Canvas.ClipRect.Left;
        rec.Left := dli.Left - xshift;
        rec.Right := rec.Left + dli.Width;
        rec.Bottom := dli.pDrawLineInfo.BaseLine - yshift;
        rec.Top := rec.Bottom - dli.Height;
//      canvas.Rectangle(rec);
        InvalidateRect(Handle, @rec, True);
        end;
      end;
    end;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.CMMouseLeave(var Message: TMessage);
//var dli: TDrawContainerInfo;
//    li: TContainerInfo;
begin
SetStyleOfLinkObject(LastLinkMovedAbove, 0);
InvalidateLinkObject(LastLinkMovedAbove);

{   if DrawHover and (LastJumpMovedAbove<>-1) then
     begin
     DrawHover := False;
     InvalidateJumpRect(LastJumpMovedAbove);
     end;}
   if Assigned(FOnCVMouseMove) and
      (LastJumpMovedAbove<>-1) then begin
      LastJumpMovedAbove := -1;
      OnCVMouseMove(Self,-1);
   end;
end;
{procedure TChatView.WMNCMOUSEMOVE(var Message: TMessage);
begin
MessageBox(0, PChar(inttostr(0)), 'WMLButtonUp', mb_ok);
//self.on
//inherited WMMouse(Message);
end;}
{-------------------------------------}
procedure TChatView.OnMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
end;
{-------------------------------------}
procedure TChatView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ItemAtPos: Integer;
//    r :TRect;
//    lastline: Boolean;
    TempLink: TLinkInfo;
begin
if Button <> mbLeft then exit;
{  XClicked := X;
  YClicked := Y;
  //if Assigned(FOnJump) then begin
    LastJumpDowned := -1;
    for i:=0 to jumps.Count-1 do
     with jumps.objects[i] as TJumpInfo do
      if (X>=l-HScrollPos) and
         (X<=l+w-HScrollPos) and
         (Y >= t - VScrollPos * VScrollStep) and
         (Y <= t + h - VScrollPos * VScrollStep) then
           begin
             LastJumpDowned := id;
             break;
           end;
    if AllowSelection then
      begin
      FindItemForSel(XClicked + HScrollPos, YClicked + VScrollPos * VScrollStep, no, FSelStartOffs);
      FSelStartNo := no;
      FSelEndNo   := no;
      Selection   := (no<>-1);
      FSelEndOffs := FSelStartOffs;
      Invalidate;
      if ScrollTimer = nil then begin
        ScrollTimer := TTimer.Create(nil);
        ScrollTimer.OnTimer := OnScrollTimer;
        ScrollTimer.Interval := 100;
      end;

    end;
    if SingleClick and Assigned(FOnCVDblClick) and FindClickedWord(clickedword, StyleNo) then
       FOnCVDblClick(Self, clickedword, StyleNo);

}
if AllowSelection then
  begin
  if selection = false then
    begin
    FSelStartX := x + HScrollPos;
    FSelStartY := y + VScrollPos;
    FSelEndX := x + HScrollPos;
    FSelEndY := y + VScrollPos;

    if FCursorSelection = false then
      SetSelectionItems(x, y)
    else
      begin
      SetCursorSelectionItems(x, y);
      end;

    selection := true;
    invalidate;
    end;
  end;

ItemAtPos := FindItemAtScreenPos(x, y);
if ItemAtPos > 0 then
  begin
  if TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId >= 0 then
    begin
    TempLink := TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]);
    if Assigned(TempLink.OnLinkMouseDown) then
      TempLink.OnLinkMouseDown(Self, TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]), TempLink);
    FDebugText2 := 'MouseDown' +
             #10#13 + 'ItemAtPos = ' + inttostr(ItemAtPos);
    self.OnDebug(FDebugText, FDebugText2);
    end;
  end;

inherited MouseDown(Button, Shift, X, Y);

//������� ���� � ������� ����
if FindItemAtScreenPos(x, y) > 0 then
  FDebugText := 'MouseDown' + #10#13 +
                'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y)) +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.BaseLine) +
                #10#13 + 'Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.LineNumber) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y) +
                #10#13 + DrawContainers.Strings[FindItemAtScreenPos(x, y)]
else
  FDebugText := 'MouseDown' + #10#13 + 'empty' +
                #10#13 + 'FindNearItemAtScreenPos = ' + inttostr(FindNearItemAtScreenPos(x, y));

//self.OnDebug(FDebugText, FDebugText2);
end;
{------------------------------------------------------------------}
procedure TChatView.MouseMove(Shift: TShiftState; X, Y: Integer);
var ItemAtPos{, i, no, offs,ys, cont}: Integer;
    ScrollYSpeed: cardinal;
    DoScroll: boolean;
//    dli: TDrawContainerInfo;
//    li: TContainerInfo;
begin
DoScroll := false;
Cursor := crDefault;
if (Selection = true) then
  begin
  if Y < 0 then
    begin
    DoScroll := true;
    TimerScrollStepY := 2;
    ScrollYSpeed := 100;
    end;
  if Y < -30 then
    begin
    DoScroll := true;
    TimerScrollStepY := VScrollStep;
    ScrollYSpeed := 50;
    end;
  if Y < -100 then
    begin
    DoScroll := true;
    TimerScrollStepY := VPageScrollStep;
    ScrollYSpeed := 25;
    end;
  if Y > ClientHeight then
    begin
    DoScroll := true;
    TimerScrollStepY := 2;
    ScrollYSpeed := 100;
    end;
  if Y > ClientHeight + 30 then
    begin
    DoScroll := true;
    TimerScrollStepY := VScrollStep;
    ScrollYSpeed := 50;
    end;
  if Y > ClientHeight + 100 then
    begin
    DoScroll := true;
    TimerScrollStepY := VPageScrollStep;
    ScrollYSpeed := 25;
    end;
{   if Selection then
      begin
      XMouse := x;
      YMouse := y;
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(X + HScrollPos, ys + VScrollPos * VScrollStep, no, offs);
      FSelEndNo   := no;
      FselEndOffs    := offs;
      Invalidate;
      end;
    for i:=0 to jumps.Count-1 do
      begin
      if (X>=TJumpInfo(jumps.objects[i]).l-HScrollPos) and
         (X<=TJumpInfo(jumps.objects[i]).l+TJumpInfo(jumps.objects[i]).w-HScrollPos) and
         (Y>=TJumpInfo(jumps.objects[i]).t - VScrollPos * VScrollStep) and
         (Y<=TJumpInfo(jumps.objects[i]).t + TJumpInfo(jumps.objects[i]).h - VScrollPos * VScrollStep) then
        begin
        Cursor :=  FStyle.JumpCursor;
        if Assigned(FOnCVMouseMove) and
           (LastJumpMovedAbove<>TJumpInfo(jumps.objects[i]).id) then
          begin
          OnCVMouseMove(Self,TJumpInfo(jumps.objects[i]).id+FirstJumpNo);
          end;
        if DrawHover and (LastJumpMovedAbove<>-1) and
           (LastJumpMovedAbove<>TJumpInfo(jumps.objects[i]).id) then
          begin
          DrawHover := False;
          InvalidateJumpRect(LastJumpMovedAbove);
          end;
        LastJumpMovedAbove := TJumpInfo(jumps.objects[i]).id;
        if (Style<>nil) and (Style.HoverColor<>clNone) and not DrawHover then
          begin
          DrawHover := True;
          InvalidateJumpRect(LastJumpMovedAbove);
          end;
        exit;
        end;
      end;
    Cursor :=  crDefault;
    if DrawHover and (LastJumpMovedAbove<>-1) then
      begin
      DrawHover := False;
      InvalidateJumpRect(LastJumpMovedAbove);
      end;
    if Assigned(FOnCVMouseMove) and
       (LastJumpMovedAbove<>-1) then
      begin
      LastJumpMovedAbove := -1;
      OnCVMouseMove(Self,-1);
      end;
    if Selection then Invalidate;
}
  if FCursorSelection = false then
    begin
    FSelEndX := x + HScrollPos;
    FSelEndY := y + VScrollPos;
    SetSelectionItems(x, y);
    end
  else
    begin
    SetCursorSelectionItems(x, y);
    end;
  invalidate;
  end;
FDebugText := '';
if LastLinkMovedAbove > -1 then
  begin
  SetStyleOfLinkObject(LastLinkMovedAbove, 0);
  InvalidateLinkObject(LastLinkMovedAbove);
  LastLinkMovedAbove := -1;
  end;
if DoScroll = true then SmoothScrollDeltaY(Y, ScrollYSpeed);
ItemAtPos := FindItemAtScreenPos(x, y);
if ItemAtPos > 0 then
  begin
  if TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId >= 0 then
    begin
    if Assigned(TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]).OnLinkMouseMove) then
      TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]).OnLinkMouseMove(Self, TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]), TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]));
    Cursor := FStyle.JumpCursor;
    FDebugText := FDebugText + TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]).Link + #10#13;
    LastLinkMovedAbove := ItemAtPos;
//    SetStyleOfLinkObject(ItemAtPos, 5);
    SetStyleOfLinkObject(ItemAtPos, TLinkInfo(LinksInfo.Objects[TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).LinkId]).OnMouseLinkStyle);
    InvalidateLinkObject(ItemAtPos);
    end;
  end;
inherited MouseMove(Shift, X, Y);

if ItemAtPos > 0 then
  begin
  FDebugText := FDebugText +
                'MouseMove' + '    LastLinkMovedAbove ='+ inttostr(LastLinkMovedAbove) +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).pDrawLineInfo.BaseLine) +
                '   Width =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).width) +
                '   Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).pDrawLineInfo.LineNumber) +
                #10#13 + 'DrawContainer = ' + inttostr(ItemAtPos) + '  ContainerNumber = ' + inttostr(TDrawContainerInfo(DrawContainers.Objects[ItemAtPos]).ContainerNumber) +
                #10#13 + 'FirstVisibleContainer = ' + inttostr(FirstVisibleContainer) + '  LastVisibleContainer = ' + inttostr(LastVisibleContainer);
  end
else
  FDebugText := 'MouseMove' + #10#13 + '��� �������� ��� ����������' +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y);
if FindNearestItemAtScreenPos(x, y) > 0 then
  FDebugText := FDebugText +
                #10#13 + 'MaxHeight =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindNearestItemAtScreenPos(x, y)]).pDrawLineInfo.MaxHeight) +
                #10#13 + 'GetFirstContainerInCurrLine = ' + inttostr(GetFirstContainerInCurrLine(FindNearestItemAtScreenPos(x, y))) +
                '   GetLastContainerInCurrLine = ' + inttostr(GetLastContainerInCurrLine(FindNearestItemAtScreenPos(x, y))) +
//                #10#13 + 'TmpStartX =' + inttostr(TmpStartX) + '   TmpStartY =' + inttostr(TmpStartY) + '  TmpEndX =' + inttostr(TmpEndX) + '  TmpEndY =' + inttostr(TmpEndY) +
                #10#13 + 'FSelStartX =' + inttostr(FSelStartX) + '   FSelStartY =' + inttostr(FSelStartY) + '  FSelEndX =' + inttostr(FSelEndX) + '  FSelEndY =' + inttostr(FSelEndY) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y)
else
  FDebugText := 'MouseMove' + #10#13 + '��� �������� ��� ���� �����' +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y) +
                #10#13 + 'FindNearItemAtScreenPos = ' + inttostr(FindNearItemAtScreenPos(x, y));

self.OnDebug(FDebugText, FDebugText2);
end;
{-------------------------------------}
procedure TChatView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var i, StyleNo, no, offs, ys: Integer;
//    clickedword: String;
//    p: TPoint;
begin
{    if ScrollTimer<> nil then begin
      ScrollTimer.Free;
      ScrollTimer := nil;
    end;
    XClicked := X;
    YClicked := Y;
    if Selection and (Button = mbLeft) then begin
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(XClicked + HScrollPos, ys + VScrollPos * VScrollStep, no, offs);
      FSelEndNo   := no;
      FselEndOffs    := offs;
      Selection   := False;
      Invalidate;
      if Assigned(FOnSelect) then FOnSelect(Self);
    end;
    if Button = mbRight then begin
      inherited MouseUp(Button, Shift, X, Y);
      if not Assigned(FOnCVRightClick) then exit;
      p := ClientToScreen(Point(X,Y));
      if FindClickedWord(clickedword, StyleNo) then
        FOnCVRightClick(Self, clickedword, StyleNo,p.X,p.Y);
      exit;
    end;
    if Button <> mbLeft then exit;
    if (LastJumpDowned=-1) or not Assigned(FOnJump) then begin
      exit;
    end;
    for i:=0 to jumps.Count-1 do
    with jumps.objects[i] as TJumpInfo do
      if (LastJumpDowned=id) and
         (X>=l-HScrollPos) and
         (X<=l+w-HScrollPos) and
         (Y >= t - VScrollPos * VScrollStep) and
         (Y <= t + h - VScrollPos * VScrollStep) then
          begin
            OnJump(Self,id+FirstJumpNo);
            break;
          end;
    LastJumpDowned:=-1;
}
if (AllowSelection = true) and (selection = true) then
  begin
//  FSelEndX := x + HScrollPos;
//  FSelEndY := y + VScrollPos;
  if FCursorSelection = false then
    begin
    SetSelectionItems(x, y)
    end
  else
    begin
    SetCursorSelectionItems(x, y);
    end;
  selection := false;
  invalidate;
  end;

inherited MouseUp(Button, Shift, X, Y);

if FindItemAtScreenPos(x, y) > 0 then
  FDebugText := 'MouseUp' + #10#13 +
                'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y)) +
                #10#13 + 'BaseLine =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.BaseLine) +
                #10#13 + 'Line =' + inttostr(TDrawContainerInfo(DrawContainers.Objects[FindItemAtScreenPos(x, y)]).pDrawLineInfo.LineNumber) +
                #10#13 + 'FSelStartContNo = ' + inttostr(FSelStartContNo) +
                #10#13 + 'FSelStartOffsInCont =' + inttostr(FSelStartOffsInCont) +
                #10#13 + 'FSelStartPixOffsInCont =' + inttostr(FSelStartPixOffsInCont) +
                #10#13 +
                #10#13 + 'FSelEndContNo = ' + inttostr(FSelEndContNo) +
                #10#13 + 'FSelEndOffsInCont =' + inttostr(FSelEndOffsInCont) +
                #10#13 + 'FSelEndPixOffsInCont =' + inttostr(FSelEndPixOffsInCont) +
                #10#13 + 'x = ' + inttostr(x) + '   y = ' + inttostr(y)
else
  FDebugText := 'MouseMove' + #10#13 + 'empty';
end;
{------------------------------------------------------------------}
procedure TChatView.AppendFrom(Source: TChatView);
var i: Integer;
    gr: TGraphic;
    grclass: TGraphicClass;
    li: TContainerInfo;
begin
  ClearTemporal;
  for i:=0 to Source.ContStorage.Count-1 do begin
    li := TContainerInfo(Source.ContStorage.Objects[i]);
    case li.StyleNo of
      -1: AddBreak;
      -2: AddCheckPoint;
      -3: begin
           grclass := TGraphicClass(li.gr.ClassType);
           gr := grclass.Create;
           gr.Assign(li.gr);
           AddPicture(gr, -1);//!!!!!!!!!��������!!!
        end;
      -4: AddHotSpot(li.imgNo, TImageList(li.gr), not li.SameAsPrev);
      -5: ;
       {
       begin
           if li.gr is
           ctrlclass := TControlClass(li.gr.ClassType);
           ctrl := ctrlclass.Create(Self);
           ctrl.Assign(li.gr);
           AddControl(ctrl, li.Center);
        end;
        }
      -6: AddBullet(li.imgNo, TImageList(li.gr), not li.SameAsPrev);
      else
        begin
          if li.Center then
               AddCenterLine(Source.ContStorage[i], li.StyleNo, -1)//!!!!!!!!!��������!!!
          else
             if li.SameAsPrev then
                Add(Source.ContStorage[i], li.StyleNo, -1)//!!!!!!!!!��������!!!
                //��� ����� ���������� -1 ��������!!!
             else
                AddFromNewLine(Source.ContStorage[i], li.StyleNo, -1)//!!!!!!!!!��������!!!
        end;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetLastCP: Integer;
begin
  GetLastCP := CheckPoints.Count-1;
end;
{-------------------------------------}
procedure TChatView.SetBackBitmap(Value: TBitmap);
begin
  FBackBitmap.Assign(Value);
  if (Value=nil) or (Value.Empty) then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
end;
{-------------------------------------}
procedure TChatView.SetBackgroundStyle(Value: TBackgroundStyle);
begin
  FBackgroundStyle := Value;
  if FBackBitmap.Empty then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
end;
{-------------------------------------}
procedure TChatView.DrawBack(DC: HDC; Rect: TRect; Width,Height:Integer);
var i, j: Integer;
    hbr: HBRUSH;
begin
 if FStyle = nil then exit; 
 if FBackBitmap.Empty or (FBackgroundStyle=bsNoBitmap) then
   begin
   hbr := CreateSolidBrush(ColorToRGB(FStyle.Color));
   dec(Rect.Bottom, Rect.Top);
   dec(Rect.Right, Rect.Left);
   Rect.Left := 0;
   Rect.Top := 0;
   FillRect(DC, Rect, hbr);
   DeleteObject(hbr);
   end
 else
   case FBackgroundStyle of
     bsTiled:
       for i := Rect.Top div FBackBitmap.Height to Rect.Bottom div FBackBitmap.Height do
         for j := Rect.Left div FBackBitmap.Width to Rect.Right div FBackBitmap.Width do
         BitBlt(DC, j*FBackBitmap.Width-Rect.Left,i*FBackBitmap.Height-Rect.Top, FBackBitmap.Width,
                FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
     bsStretched:
       StretchBlt(DC, -Rect.Left, -Rect.Top, Width, Height,
                  FBackBitmap.Canvas.Handle, 0, 0, FBackBitmap.Width, FBackBitmap.Height,
                  SRCCOPY);
     bsTiledAndScrolled:
       for i := (Rect.Top + VScrollPos * VScrollStep) div FBackBitmap.Height to
               (Rect.Bottom + VScrollPos * VScrollStep) div FBackBitmap.Height do
         for j := (Rect.Left+HScrollPos) div FBackBitmap.Width to
                  (Rect.Right+HScrollPos) div FBackBitmap.Width do
           BitBlt(DC, j*FBackBitmap.Width-HScrollPos-Rect.Left,i*FBackBitmap.Height-VScrollPos*VScrollStep-Rect.Top, FBackBitmap.Width,
                  FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
   end
end;
{-------------------------------------}
procedure TChatView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var r1: TRect;
begin
scrolling := true;
  if (csDesigning in ComponentState) then exit;
  Message.Result := 1;
  if (OldWidth<ClientWidth) or (OldHeight<ClientHeight) then begin
      GetClipBox(Message.DC, r1);
      DrawBack(Message.DC, r1, ClientWidth, ClientHeight);
  end;
  OldWidth := ClientWidth;
  OldHeight := ClientHeight;
FDebugText:= 'WMEraseBkgnd';
OnDebug(FDebugText, FDebugText2);
//MessageBox(0, PChar(inttostr(0)), 'WMEraseBkgnd', mb_ok);
scrolling := false;
end;
{-------------------------------------}
procedure TChatView.ShareLinesFrom(Source: TChatView);
begin
   if ShareContents then begin
     Clear;
     ContStorage := Source.ContStorage;
   end;
end;
{-------------------------------------}
function TChatView.GetPrevBaseLine(ContNumber:cardinal): integer;
var LineNum, n:integer;
begin
result := TDrawContainerInfo(DrawContainers.Objects[ContNumber]).pDrawLineInfo.BaseLine;
LineNum := TDrawContainerInfo(DrawContainers.Objects[ContNumber]).pDrawLineInfo.LineNumber;
for n := ContNumber downto 0 do
  begin
  if (TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber < LineNum) then
    begin
    result := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.BaseLine;
    break;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetContainerAtXInLine(X, LineNum:integer): integer;
//X - ���������� ����������
var
  n: Cardinal;
  dli: TDrawContainerInfo;
begin
result := -1;
for n := 0 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (dli.pDrawLineInfo.LineNumber = LineNum) and
     (X > dli.Left) and (X < dli.Left + dli.Width) then
    begin
    result := n;
    break;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetFirstContainerInCurrLine(FromContainerNumber: integer): integer;
//������ ����� ������� ���������� � �����. ����� ���������� � FromContainerNumber
var n, CurrentLine: cardinal;
//    dli : TDrawLineInfo;
begin
//n := 0;
result := 1;
if FromContainerNumber >= 0 then
  begin
  n := FromContainerNumber;
  CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
  for n := FromContainerNumber downto 0 do
    begin
    if (TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber < CurrentLine) then
      begin
      result := n + 1;
      break;
      end
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetLastContainerInCurrLine(FromContainerNumber: integer): integer;
var n, CurrentLine: cardinal;
//    dli : TDrawLineInfo;
begin
//��� ��������� ������� ����� ����������, �������� � ����� ����� (������)
//�����������. �� ����� ����� ����������, �� ������ ���� ����� ���������� �
//������� ����������������� ����������� DrawContainers.
//n := 0;
result := FromContainerNumber;
if FromContainerNumber >= 0 then
  begin
  n := FromContainerNumber;
  CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
  while n <= (DrawContainers.count - 1) do
    begin
    if TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber > CurrentLine then
      begin
      result := n - 1;
      break;
      end;
    inc(n);
    end;
  end;
end;
{-------------------------------------}
function TChatView.FindItemAtScreenPos(ScrX,ScrY: Integer): Integer;
begin
result := FindItemAtPos(ScrX + HScrollPos,ScrY + VScrollPos);
end;
{-------------------------------------}
function TChatView.FindItemAtPos(X,Y: Integer): Integer;
var
  n: Cardinal;
  dli: TDrawContainerInfo;
begin
result := -1;
for n := 0 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y >= dli.pDrawLineInfo.BaseLine - dli.Height) and
     (Y <= dli.pDrawLineInfo.BaseLine) and
     (X > dli.Left) and (X < dli.Left + dli.Width) then
    begin
    result := n;
    break;
    end;
  end;
end;
{-------------------------------------}
function TChatView.FindNearestItemAtScreenPos(ScrX, ScrY: Integer): Integer;
begin
ScrX := ScrX + HScrollPos;
ScrY := ScrY + VScrollPos;
result := FindNearestItemAtPos(ScrX, ScrY);
end;
{-------------------------------------}
function TChatView.FindNearestItemAtPos(X, Y: Integer): Integer;
//FindLineItemAtPos ���������� �� FindItemAtPos ���, ��� ������ ����� ����������
//�� ������ ����� �� ���� ������� �����, �� � ����� ���� ���������� ���� ����������
//�� � �������� ��� |    |
//�.�. � �������� ����� ����� � �� ����� ��� �-��� ������ -1
var
  n{, FirstInCurrLine, LastInCurrLine}: Cardinal;
  dli: TDrawContainerInfo;
begin
result := -1;
for n := 1 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (Y <= dli.pDrawLineInfo.BaseLine) and
     (Y >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //���� ������ ���� ��������� ����� 2� �����
    if (X > dli.Left) and (X < dli.Left + dli.Width) then
      begin
      //���� ��� �����������
      result := n;
      break;
      end;
    end;
  end;
end;
{-------------------------------------}
function TChatView.FindNearItemAtScreenPos(X, Y: Integer): Integer;
begin
result := FindNearItemAtPos(X + HScrollPos, Y + VScrollPos);
end;
{-------------------------------------}
function TChatView.FindNearItemAtPos(X, Y: Integer): Integer;
//FindNearItemAtPos ���������� �� FindNearestItemAtPos ���, ��� ������ ����� ����������
//�� ������ ����� �� ���� ������� �����, �� � ����� ���� ���������� � ��������
//����� ����� � �� �����
var
  n{, FirstInCurrLine}, LastInCurrLine: Cardinal;
  dli: TDrawContainerInfo;
begin
//MessageBox(0, PChar('y'), PChar(inttostr(y)) ,mb_ok);

{if Y >= TDrawContainerInfo(DrawContainers.Objects[DrawContainers.Count - 1]).pDrawLineInfo.BaseLine then
  begin
  //���� ������ ���� ���� ����� ��������� �����
  FirstInCurrLine := GetFirstContainerInCurrLine(DrawContainers.Count - 1);
  for n := FirstInCurrLine to DrawContainers.Count - 1 do
    begin
    //������� ��� ����� ����������� �� � �� ���������
    dli := TDrawContainerInfo(DrawContainers.Objects[n]);
    if (X < dli.Left + dli.Width) then
      begin
      result := n;
      exit;
      end;
    end;
  if x < 0 then
    result := FirstInCurrLine
  else
    result := DrawContainers.Count - 1
  end
else
  begin
  //����� ���� ��� ��
{  for n := 1 to DrawContainers.Count - 1 do
    begin
    dli := TDrawContainerInfo(DrawContainers.Objects[n]);
    if (Y <= dli.pDrawLineInfo.BaseLine) and
       (Y >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
      begin
      //���� ������ ���� ��������� ����� 2� �����
      if (X > dli.Left) and (X < dli.Left + dli.Width) then
        begin
        //���� ��� �����������
        result := n;
        Exit;
        end;
      end;
    end;}
  //��� ������������ �� ����� ���� ����� � �� �����
  for n := 1 to DrawContainers.Count - 1 do
    begin
    dli := TDrawContainerInfo(DrawContainers.Objects[n]);
    if (Y <= dli.pDrawLineInfo.BaseLine) then
      begin
      //���� ������ ���� ��������� ���� ��������� ������
      if (X <= dli.Left + dli.Width) then
        begin
        //���� ����� ����� �����������
        result := n;
        exit;
        end;
      LastInCurrLine := GetLastContainerInCurrLine(n);
      if n = LastInCurrLine then
        begin
        if (X >= dli.Left + dli.Width) then
          begin
          result := n;
          Exit;
          end;
        end;
      end;
    end;
//  end;
result := LastVisibleContainer;
//FDebugText:= 'x=' + inttostr(x) + ' y=' + inttostr(y) ;//+ ' result=' + inttostr(result);
//OnDebug(FDebugText, FDebugText2);
end;
{-------------------------------------}
function TChatView.FindSymbolAtScreenPos(ScrX, ScrY: Integer): String;
var
  n: Cardinal;
  dli: TDrawContainerInfo;
  OffsWordNumber: integer;
  sz:TSize;
begin
result := '';
for n := 0 to DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (ScrY >= dli.pDrawLineInfo.BaseLine - dli.Height) and
     (ScrY <= dli.pDrawLineInfo.BaseLine) and
     (ScrX > dli.Left) and (ScrX < dli.Left + dli.Width) then
    begin
    GetTextExtentExPoint(Canvas.Handle,  PChar(DrawContainers.Strings[n]),
                         Length(DrawContainers.Strings[n]),
                         ScrX - dli.Left,
                         @OffsWordNumber, nil,
                         sz);
    if OffsWordNumber <> 0 then
      result := Copy(DrawContainers.Strings[n], OffsWordNumber ,1);
    break;
    end;
  end;
end;
  {------------------------------------------------------------------}
function TChatView.FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
var no, lno: Integer;
//    arr: array[0..1000] of integer;
    sz: TSIZE;
    max,first,len: Integer;
begin
  FindClickedWord := False;
  no := FindItemAtScreenPos(XClicked, YClicked);
  if no<>-1 then begin
     lno := TDrawContainerInfo(DrawContainers.Objects[no]).ContainerNumber;
     clickedword := DrawContainers[no];
     styleno := TContainerInfo(ContStorage.Objects[lno]).StyleNo;
     if styleno >= 0 then begin
        with FStyle.TextStyles[StyleNo] do begin
         Canvas.Font.Style   := Style;
         Canvas.Font.Size    := Size;
         Canvas.Font.Name    := FontName;
         Canvas.Font.CharSet := CharSet;
       end;
       GetTextExtentExPoint(Canvas.Handle,  PChar(clickedword),  Length(clickedword),
                            XClicked+HScrollPos-TDrawContainerInfo(DrawContainers.Objects[no]).Left,
                            @max, nil,
//                            max, arr[0],
                            sz);
       inc(max);
       if max>Length(clickedword) then max := Length(clickedword);
       first := max;
       if (Pos(clickedword[first], Delimiters)<>0) then begin
         ClickedWord := '';
         FindClickedWord := True;
         exit;
       end;
       while (first>1) and (Pos(clickedword[first-1], Delimiters)=0) do
         dec(first);
       len := max-first+1;
       while (first+len-1<Length(clickedword)) and (Pos(clickedword[first+len], Delimiters)=0) do
         inc(len);
       clickedword := copy(clickedword, first, len);
     end;
     FindClickedWord := True;
  end;

end;
  {------------------------------------------------------------------}
procedure TChatView.DblClick;
var
    StyleNo: Integer;
    clickedword: String;
begin
  inherited DblClick;
  if SingleClick or (not Assigned(FOnCVDblClick)) then exit;
  if FindClickedWord(clickedword, StyleNo) then
     FOnCVDblClick(Self, clickedword, StyleNo);
end;
  {------------------------------------------------------------------}
procedure TChatView.DeleteSection(CpName: String);
var i,j, startno, endno: Integer;
begin
   if ShareContents then exit;
   for i:=0 to checkpoints.Count-1 do
     if checkpoints[i]=CpName then begin
       startno := TCPInfo(checkpoints.Objects[i]).LineNo;
       endno := ContStorage.Count-1;
       for j := i+1 to checkpoints.Count-1 do
         if checkpoints[j]<>'' then
         begin
           endno := TCPInfo(checkpoints.Objects[j]).LineNo-1;
           break;
         end;
       DeleteLines(startno, endno-startno+1);
       exit;
     end;
end;
  {------------------------------------------------------------------}
procedure TChatView.DeleteLines(FirstLine, Count: Integer);
var i: Integer;
begin
  if ShareContents then exit;
  if FirstLine>=ContStorage.Count then exit;
  Deselect;
  if FirstLine+Count>ContStorage.Count then Count := ContStorage.Count-firstline;
  ContStorage.BeginUpdate;
  for i:=FirstLine to FirstLine+Count-1 do begin
    if TContainerInfo(ContStorage.objects[i]).StyleNo = -3 then { image}
      begin
//        TContainerInfo(ContStorage.objects[i]).gr.Free;//� �����������
        TContainerInfo(ContStorage.objects[i]).gr := nil;
      end;
    if TContainerInfo(ContStorage.objects[i]).StyleNo = -5 then {wincontrol}
      begin
//        RemoveControl(TControl(TContainerInfo(ContStorage.objects[i]).gr));
        TContainerInfo(ContStorage.objects[i]).gr.Free;
        TContainerInfo(ContStorage.objects[i]).gr := nil;
      end;
    TContainerInfo(ContStorage.objects[i]).Free;
    ContStorage.objects[i] := nil;
  end;
  for i:=1 to Count do ContStorage.Delete(FirstLine);
  ContStorage.EndUpdate;
end;
{------------------------------------------------------------------}
procedure TChatView.CorrectSelectionBounds(x, y: integer);
//var i: integer;
begin
//���� ��������� ���� �� ������� ������� � ������� ����� ��� �� ������ �������
//� ������ �������, �� ������ ������� ���������� ����� ����� ���������
{    FSelStartX := x + HScrollPos;
    FSelStartY := y + VScrollPos;
    FSelEndX := x + HScrollPos;
    FSelEndY := y + VScrollPos;}
//    FSelEndX := x + HScrollPos;
{TmpEndX := x + HScrollPos;
TmpEndY := y + VScrollPos;
if TmpStartY >= TmpEndY then
  begin
  FSelEndY := TmpStartY;
  FSelStartY := TmpEndY;
  end
else
  begin
  FSelEndY := TmpEndY;
  FSelStartY := TmpStartY;
  end;
if TmpStartX >= TmpEndX then
  begin
  FSelEndX := TmpStartX;
  FSelStartX := TmpEndX;
  end
else
  begin
  FSelEndX := TmpEndX;
  FSelStartX := TmpStartX;
  end;
}

{if (FSelStartY > FSelEndY) then
  begin
  i := FSelStartY;
  FSelStartY := FSelEndY;
  FSelEndY := i;
  end;}

//���� �� ���� ����� � ��� ���������� ���������� �������������� ���������
//�.�. �������� ���������� ������ ���������
//������ ����� ��� ���������� ��������� ��� ���������� (���� ���� ���������� ���
//�����������) ��� ��� ���� ������ (���� ���� �� �����)
end;
{------------------------------------------------------------------}
function TChatView.GetWordOffset(ContNumber:cardinal; XRange:integer;Str:PChar;StrLen:cardinal;
                                 var SelContNo, SelPixOffsInCont:integer):integer;
var OffsWordNumber, styleno:integer;
    dli:TDrawContainerInfo;
    sz:TSize;
begin
result := 0;
dli := TDrawContainerInfo(DrawContainers.Objects[ContNumber]);
styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if styleno >= 0 then
  begin
  with FStyle.TextStyles[StyleNo] do
    begin
    Canvas.Font.Style := Style;
    Canvas.Font.Size  := Size;
    Canvas.Font.Name  := FontName;
    Canvas.Font.CharSet := CharSet;
    end;
  //+------------------+  �������� ���� ��������� �� ����� �
  //| TChatView        |  ����� ����� �� �������� �� ������ ����������
  //|    ^             |
  //|     \            |
  OffsWordNumber := 0;
//  if SelStartX - dli.Left >= 0 then
  if XRange >= 0 then
  GetTextExtentExPoint(Canvas.Handle, PChar(Str),
                       StrLen,
                       XRange,//SelStartX - dli.Left,
                       @OffsWordNumber,//OffsWordNumber,
                       nil, sz);


//   FSelStartPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[StartCont], 0, OffsWordNumber));
   SelContNo := ContNumber;
   SelPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[ContNumber], 0, OffsWordNumber));
   if OffsWordNumber = 0 then SelPixOffsInCont := 0;
   result := OffsWordNumber;
  end;
{else
  begin
  //��� ����������� ���� ����� ������
//  SelPixOffsInCont := XRange;//SelStartX - dli.Left;
  if (SelPixOffsInCont > dli.Width div 2) then
    SelContNo := ContNumber
  else
    SelContNo := ContNumber - 1;
  end;
{
dli := TDrawContainerInfo(DrawContainers.Objects[EndCont]);
styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if styleno >= 0 then
  begin
  with FStyle.TextStyles[StyleNo] do
    begin
    Canvas.Font.Style := Style;
    Canvas.Font.Size  := Size;
    Canvas.Font.Name  := FontName;
    Canvas.Font.CharSet := CharSet;
    end;
  //+------------------+  �������� ���� ��������� �� ����� �
  //| TChatView        |  ����� ����� �� �������� �� ������ ����������
  //|    ^             |
  //|     \            |
  OffsWordNumber := 0;
  if SelEndX - dli.Left >= 0 then
  GetTextExtentExPoint(Canvas.Handle, PChar(DrawContainers.Strings[EndCont]),
                       Length(DrawContainers.Strings[EndCont]),
                       SelEndX - dli.Left,
                       @OffsWordNumber, nil,
                       sz);

   FSelEndContNo := EndCont;
   FSelEndOffsInCont := OffsWordNumber;
   FSelEndPixOffsInCont := canvas.TextWidth(Copy(DrawContainers.Strings[EndCont], 0, OffsWordNumber));
   if OffsWordNumber = 0 then FSelEndPixOffsInCont := 0;
  end
else
  begin
  //��� ����������� ���� ����� ������
  FSelEndPixOffsInCont := SelEndX - dli.Left;
  if (FSelEndPixOffsInCont > dli.Width div 2) then
    FSelEndContNo := EndCont
  else
    FSelEndContNo := EndCont - 1;
  end;}
end;

{-------------------------------------}
procedure TChatView.SetSelectionItems(x, y: integer);
//FindLineItemAtPos ���������� �� FindItemAtPos ���, ��� ������ ����� ����������
//�� ������ ����� �� ���� ������� �����, �� � ����� ���� ���������� � ��������
//����� ����� � �� �����
var
  n, FirstInCurrLine, LastInCurrLine: Cardinal;
  dli, dli2: TDrawContainerInfo;
  OffsWordNumber, StyleNo, StartCont, EndCont, i, cont:integer;
  sz:TSize;
begin
//������ ����� ������� � ����� ������� �������� ��� ���������� '' (������) ������
//FSelStartContNo, FSelEndContNo, FSelStartOffsInCont, FSelEndOffsInCont: Integer;
//SelStartX, SelStartY
//CorrectSelectionBounds(x, y);

//    FDebugText2 := 'Start �� ��������� �������';
//    OnDebug(FDebugText, FDebugText2);
    FSelStartContNo := DrawContainers.Count - 1;
    FSelStartOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
    FSelStartPixOffsInCont := 0;

for n := 1 to DrawContainers.Count - 1 do
  begin
  //�������� ���������� ��� ���������� � ������� ����, �� ���������� ��������
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (FSelStartY <= dli.pDrawLineInfo.BaseLine) and
     (FSelStartY >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //���� ������ ���� �������� � ������ ������(��������� ����� 2� �����)
    if (FSelStartX > dli.Left) and (FSelStartX < dli.Left + dli.Width) then
      begin
      //� � ������ ����������, �� ���� ��� �����������
      FSelStartContNo := n;
      FSelStartOffsInCont := 0;
      StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      if StyleNo >= 0 then
        begin
        //��� ������
//        FDebugText2 := 'Start ���� ��� ����������� � �������';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartOffsInCont := GetWordOffset(n, FSelStartX - dli.Left,
                                             PChar(DrawContainers.Strings[n]),
                                             length(DrawContainers.Strings[n]),
                                             FSelStartContNo,
                                             FSelStartPixOffsInCont);
        end
      else
        begin
        //��� ����������� ���� ����� ������
//        FDebugText2 := 'Start ���� ��� ����������� ����� ������';
//        self.OnDebug(FDebugText, FDebugText2);
        if (FSelStartX >= dli.Left + (dli.Width div 2)) then
          begin
          FSelStartPixOffsInCont := FSelStartX - dli.Left;
          FSelStartContNo := n
          end
        else
          FSelStartContNo := n + 1;
        end;
      break;
      end
    else
      begin
      //���� ����� �����, �� �� ��� ��������� (��� ����� ���� ������
      //������������ ����� ���������� ��� ������ ���-���� �� �����)
//      FDebugText2 := 'Start ��';
//      self.OnDebug(FDebugText, FDebugText2);
      FSelStartPixOffsInCont := 0;
      FirstInCurrLine := GetFirstContainerInCurrLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (FSelStartX <= dli.Left) then
        begin
        //������ ���� ����� ������ ����������� ���� ����� (�� ����� ����)
//        FDebugText2 := 'Start ����� ������ ����������� ���� �����';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartContNo := FirstInCurrLine;
        FSelStartOffsInCont := 0;
        break;
        end;
      LastInCurrLine := GetLastContainerInCurrLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (FSelStartX >= dli.Left + dli.Width) then
        begin
//        FDebugText2 := 'Start �� ��������� ����������� ���� �����';
//        self.OnDebug(FDebugText, FDebugText2);
        FSelStartContNo := FirstInCurrLine;
        FSelStartOffsInCont := 0;
        break;
        end;
      //������ ���� ���-�� ����� ����������� ���� �����
/////      dli := TDrawContainerInfo(DrawContainers.Objects[n]);
//      FDebugText2 := 'Start �����' +
//      '  n:=' + inttostr(n);
//      self.OnDebug(FDebugText, FDebugText2);
      FSelStartContNo := n;
      FSelStartOffsInCont := 0;
      end;
    end;
  end;


if (FSelEndY < 0) then
  begin
  FDebugText2 := 'End �� ������� ����� �������';
  self.OnDebug(FDebugText, FDebugText2);
  FSelEndContNo := 0;
  FSelEndOffsInCont := 0;
  FSelEndPixOffsInCont := 0;
  end
else
  begin
//  FDebugText2 := 'End �� ��������� �������';
  self.OnDebug(FDebugText, FDebugText2);
  FSelEndContNo := DrawContainers.Count - 1;
  FSelEndOffsInCont := length(DrawContainers.Strings[DrawContainers.Count - 1]);
  FSelEndPixOffsInCont := 0;
  end;

for n := 1 to DrawContainers.Count - 1 do
  begin
  //�������� ���������� ��� ���������� � ������� ����, �� ���������� ��������
  //��� ��� ������� ������������� ����
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  if (FSelEndY <= dli.pDrawLineInfo.BaseLine) and
     (FSelEndY >= dli.pDrawLineInfo.BaseLine - dli.pDrawLineInfo.MaxHeight) then
    begin
    //���� ������ ���� �������� � ������ ������(��������� ����� 2� �����)
    if (FSelEndX > dli.Left) and (FSelEndX < dli.Left + dli.Width) then
      begin
      //� � ������ ����������, �� ���� ��� �����������
      FSelEndContNo := n;
      FSelEndOffsInCont := 0;
      StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      if StyleNo >= 0 then
        begin
        //��� ������
//        FDebugText2 := 'End ���� ��� ����������� � �������';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndOffsInCont := GetWordOffset(n, FSelEndX - dli.Left,
                                             PChar(DrawContainers.Strings[n]),
                                             length(DrawContainers.Strings[n]),
                                             FSelEndContNo,
                                             FSelEndPixOffsInCont);
        end
      else
        begin
        //��� ����������� ���� ����� ������
        if (FSelStartContNo < FSelEndContNo) then
          begin
          //�������� ���� � ������ � ���� ������� -> []
//          FDebugText2 := 'End ��� ������ (EndY > StartY)' +
//                         '  n:=' + inttostr(n);
          self.OnDebug(FDebugText, FDebugText2);
          if (FSelEndX < dli.Left + (dli.Width div 2)) and
             (n - 1 >= 0) then
            begin
            dli2 := TDrawContainerInfo(DrawContainers.Objects[n - 1]);
            FSelEndOffsInCont := GetWordOffset(n - 1,  FSelEndX - dli2.Left,
                                               PChar(DrawContainers.Strings[n - 1]),
                                               length(DrawContainers.Strings[n - 1]),
                                               FSelEndContNo,
                                               FSelEndPixOffsInCont);
            end
          else
            begin
            FSelEndContNo := n;
            end;
          end
        else
          begin
          //�������� ���� � ������ � ���� ������� [] <-
          if (FSelEndContNo < FSelStartContNo) then
            begin
            FDebugText2 := 'End ��� ������ (EndY < StartY)' +
                           '  n:=' + inttostr(n);
            self.OnDebug(FDebugText, FDebugText2);
            if (FSelEndX > dli.Left + (dli.Width div 2)) and
               (FSelEndX < dli.Left + dli.Width) and
               (n + 1 <= DrawContainers.Count - 1) then
              begin
              dli2 := TDrawContainerInfo(DrawContainers.Objects[n + 1]);
              FSelEndOffsInCont := GetWordOffset(n + 1,  FSelEndX - dli2.Left,
                                                 PChar(DrawContainers.Strings[n + 1]),
                                                 length(DrawContainers.Strings[n + 1]),
                                                 FSelEndContNo,
                                                 FSelEndPixOffsInCont);
              end
           else
              begin
              FSelEndContNo := n;
              end;
            end;
          end;
        end;
      break;
      end
    else
      begin
      //���� ����� �����, �� �� ��� ��������� (��� ����� ���� ������
      //������������ ����� ���������� ��� ������ ���-���� �� �����)
//      FDebugText2 := 'End ��';
      self.OnDebug(FDebugText, FDebugText2);
      FSelEndPixOffsInCont := 0;
      FirstInCurrLine := GetFirstContainerInCurrLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[FirstInCurrLine]);
      if (FSelEndX <= dli.Left) then
        begin
        //������ ���� ����� ������ ����������� ���� ����� (�� ����� ����)
        FDebugText2 := 'End ����� ������ ����������� ���� �����';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndContNo := FirstInCurrLine;
        FSelEndOffsInCont := 0;
        break;
        end;
      LastInCurrLine := GetLastContainerInCurrLine(n);
      dli := TDrawContainerInfo(DrawContainers.Objects[LastInCurrLine]);
      if (FSelEndX >= dli.Left + dli.Width) then
        begin
        FDebugText2 := 'End �� ��������� ����������� ���� �����';
        self.OnDebug(FDebugText, FDebugText2);
        FSelEndContNo := LastInCurrLine;
        FSelEndOffsInCont := length(DrawContainers.Strings[LastInCurrLine]);
        FSelEndPixOffsInCont := x;
        break;
        end;
      //������ ���� ���-�� ����� ����������� ���� �����
      //������� ����� �����
      if (n + 1 <= DrawContainers.Count - 1) then
        begin
        dli := TDrawContainerInfo(DrawContainers.Objects[n]);
        dli2 := TDrawContainerInfo(DrawContainers.Objects[n + 1]);
        if (FSelEndX >= dli.Left + dli.Width) and
           (FSelEndX <= dli2.Left) and
           (FSelEndY > FSelStartY) then
          begin
          FDebugText2 := 'End ����� ->' +
          '  n:=' + inttostr(n);
          self.OnDebug(FDebugText, FDebugText2);
          FSelEndContNo := n;
          FSelEndOffsInCont := length(DrawContainers.Strings[n]);
          FSelEndPixOffsInCont := x;
          break;
          end;
        if (FSelEndX >= dli.Left + dli.Width) and
           (FSelEndX <= dli2.Left) and
           (FSelEndY < FSelStartY) then
          begin
          FDebugText2 := 'End ����� <-' +
          '  n:=' + inttostr(n + 1);
          self.OnDebug(FDebugText, FDebugText2);
          FSelEndContNo := n + 1;
          FSelEndOffsInCont := 0;
          FSelEndPixOffsInCont := 0;
          break;
          end;
        end;
      end;
    end;
  end;

if FSelStartContNo > FSelEndContNo then
  begin
  n := FSelEndContNo;
  FSelEndContNo := FSelStartContNo;
  FSelStartContNo := n;

  i := FSelEndOffsInCont;
  FSelEndOffsInCont := FSelStartOffsInCont;
  FSelStartOffsInCont := i;
  end
else
  begin
  if (FSelStartContNo = FSelEndContNo) then
    begin
    if (FSelStartOffsInCont > FSelEndOffsInCont) then
      begin
      n := FSelEndOffsInCont;
      FSelEndOffsInCont := FSelStartOffsInCont;
      FSelStartOffsInCont := n;
      end;
    if (FSelStartPixOffsInCont > FSelEndPixOffsInCont) then
      begin
      n := FSelEndPixOffsInCont;
      FSelEndPixOffsInCont := FSelStartPixOffsInCont;
      FSelStartPixOffsInCont := n;
      end;
    end;
  end;

{StartCont := FindNearestItemAtPos(SelStartX, SelStartY);
//StartCont := GetFirstContainerInCurrLine(StartCont);
if StartCont < 0 then exit;

EndCont := FindNearestItemAtPos(SelEndX, SelEndY);
//EndCont := GetLastContainerInCurrLine(EndCont);
if EndCont < 0 then exit;
}
end;
{------------------------------------------------------------------}
procedure TChatView.SetCursorContainer(Cont: Integer);
begin
FCursor := cont;
FSelStartContNo := cont;
FSelEndContNo := cont;
end;
{------------------------------------------------------------------}
procedure TChatView.SmoothScrollDeltaY(DeltaY:Integer;ScrollSpeed:cardinal);
begin
SmoothScrollToY(VScrollPos + DeltaY, ScrollSpeed);
end;
{------------------------------------------------------------------}
procedure TChatView.SmoothScrollToY(ScrollToYPos:Integer;ScrollSpeed:cardinal);
begin
if ScrollTimer = nil then
  begin
  ScrollTimer := TTimer.Create(nil);
  ScrollTimer.OnTimer := OnScrollTimer;
  ScrollTimer.Interval := ScrollSpeed;
  TempTimerDebug := 0;
  end;
if ScrollToYPos >= 0 then
  begin
  //���� ��� ����� ��������������� �� ����� ���������� �������
  ScrollTimer.Enabled := true;
  ScrollToY := ScrollToYPos;
  if VScrollPos > ScrollToY then
  //� ��� ������� ���� �������
    VScrollUp := true
  else
    VScrollUp := false;
  end;

//FDebugText2 :='ScrollDeltaY := VScrollPos - ToY=' + inttostr(ScrollDeltaY);
//self.OnDebug(FDebugText, FDebugText2);
end;
{------------------------------------------------------------------}
procedure TChatView.OnScrollTimer(Sender: TObject);
var
dli : TDrawLineInfo;
begin

//FDebugText2 := 'OnScrollTimer = ' + inttostr(TempTimerDebug);
inc(TempTimerDebug);

ScrollTimer.Enabled := false;

if (VScrollUp = true) and (VScrollPos + FVScrollBound > ScrollToY) then
  begin
  VScrollPos := VScrollPos - TimerScrollStepY;
//  ScrollTimer.Interval := 10;//ScrollYSpeed;
  ScrollTimer.Enabled := true;
  FDebugText2 := 'VScrollPos=' + inttostr(VScrollPos) +
                 ' ScrollToY=' + inttostr(ScrollToY);
  end;

if (VScrollUp = false) and (VScrollPos + ClientHeight - FVScrollBound < ScrollToY) then
  begin
  VScrollPos := VScrollPos + TimerScrollStepY;
//  ScrollTimer.Interval := 10;//ScrollYSpeed;
  ScrollTimer.Enabled := true;
  FDebugText2 := 'VScrollPos=' + inttostr(VScrollPos) +
                 ' ScrollToY=' + inttostr(ScrollToY);
  end;
//����� ������� � ������������� ������� ��� ���������
if VScrollPos <= 0 then ScrollTimer.Enabled := false;
dli := TDrawContainerInfo(DrawContainers.Objects[DrawContainers.Count - 1]).pDrawLineInfo;
//VScrollPos ��� ����� ������� ������� ������������ ������, ������������� DrawContainers
//� ��� ���� ��� ������ ������ �������, ���� ��������� BaseLine ���������� � ����� ����
if VScrollPos >= (dli.BaseLine - self.Height) then
  begin
  ScrollTimer.Enabled := false;
  end;

//self.OnDebug(FDebugText, FDebugText2);
end;
{------------------------------------------------------------------}
procedure TChatView.SetCursorSelectionItems(X, Y: Integer);
var dli : TDrawContainerInfo;
    StyleNo :integer;
begin
FCursorPosX := X + HScrollPos;
FCursorPosY := Y + VScrollPos;
FSelEndX := X + HScrollPos;
FSelEndY := Y + VScrollPos;
FSelStartX := X + HScrollPos;
FSelStartY := Y + VScrollPos;
FCursor := FindNearestItemAtScreenPos(x, y);
if FCursor < 0 then
  begin
  FCursor := FindNearItemAtScreenPos(x, y);
  if FCursor < 0 then MessageBox(0, PChar('FindNearItemAtScreenPos ������ FCursor < 0!!!'), PChar('������ ��� ������!') ,mb_ok);
  end;
FSelEndContNo := FCursor;
FSelStartContNo := FCursor;
dli := TDrawContainerInfo(DrawContainers.Objects[FCursor]);
StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
if StyleNo >= 0 then
  begin
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := Length(DrawContainers.Strings[FCursor]);
  end
else
  begin
  FSelStartOffsInCont := 0;
  FSelEndOffsInCont := 0;
  end;
FSelStartPixOffsInCont := 0;
FSelEndPixOffsInCont := 0;
//if FCursorPosX >

{FDebugText2 := 'BaseLine=' + inttostr(dli.pDrawLineInfo.BaseLine) +
               '  VScrollPos=' + inttostr(VScrollPos) +
               '  ClientHeight=' + inttostr(ClientHeight);
self.OnDebug(FDebugText, FDebugText2);}
if dli.pDrawLineInfo.BaseLine > VScrollPos + ClientHeight - FVScrollBound then
  begin
  //������������ ����
  SmoothScrollToY(dli.pDrawLineInfo.BaseLine, 10);
  end;
if FCursorPosY - VScrollPos - dli.Height - FVScrollBound < 0 then
  begin
  //������������ �����
  SmoothScrollToY(dli.pDrawLineInfo.BaseLine - dli.Height, 10);
  end;
end;
{------------------------------------------------------------------}
procedure TChatView.RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
//var i: Integer;
//    dli, dli2, dli3: TDrawContainerInfo;
begin
  if StartNo = -1 then exit;
{  for i :=0 to DrawContainers.Count-1 do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
    if dli.ContainerNumber = StartNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelStartContNo := i;
        FSelStartOffsInCont := StartOffs;
        end
      else begin
        if i<>DrawContainers.Count-1 then
          dli2 := TDrawContainerInfo(DrawContainers.Objects[i+1])
        else
          dli2 := nil;
        if i<>0 then
          dli3 := TDrawContainerInfo(DrawContainers.Objects[i-1])
        else
          dli3 := nil;
        if
          ((dli.Offs<=StartOffs) and (Length(DrawContainers[i])+dli.Offs>StartOffs)) or
          ((StartOffs>Length(ContStorage[dli.ContainerNumber])) and ((dli2=nil)or(dli2.ContainerNumber<>dli.ContainerNumber))) or
          ((dli.Offs>StartOffs) and ((dli3=nil)or(dli3.ContainerNumber<>dli.ContainerNumber)))
        then begin
          FSelStartContNo := i;
          FSelStartOffsInCont := StartOffs-dli.Offs+1;
          if FSelStartOffsInCont<0 then FSelStartOffsInCont := 0;
          if FSelStartOffsInCont>dli.Offs+Length(DrawContainers[i]) then FSelStartOffsInCont := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
    if dli.ContainerNumber = EndNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelEndContNo := i;
        FSelEndOffsInCont := EndOffs;
        end
      else begin
        if i<>DrawContainers.Count-1 then
          dli2 := TDrawContainerInfo(DrawContainers.Objects[i+1])
        else
          dli2 := nil;
        if i<>0 then
          dli3 := TDrawContainerInfo(DrawContainers.Objects[i-1])
        else
          dli3 := nil;
        if
          ((dli.Offs<=EndOffs) and (Length(DrawContainers[i])+dli.Offs>EndOffs)) or
          ((EndOffs>Length(ContStorage[dli.ContainerNumber])) and ((dli2=nil)or(dli2.ContainerNumber<>dli.ContainerNumber))) or
          ((dli.Offs>EndOffs) and ((dli3=nil)or(dli3.ContainerNumber<>dli.ContainerNumber)))
        then begin
          FSelEndContNo := i;
          FSelEndOffsInCont := EndOffs-dli.Offs+1;
          if FSelEndOffsInCont<0 then FSelEndOffsInCont := 0;
          if FSelEndOffsInCont>dli.Offs+Length(DrawContainers[i]) then FSelEndOffsInCont := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
  end;}
end;
  {------------------------------------------------------------------}
function TChatView.SelectionExists: Boolean;
begin
if (FSelStartX >= 0) and (FSelStartY >= 0) and
  (FSelEndX >= 0) and (FSelEndY >= 0) then
    Result := True
  else
    Result := False
end;
  {------------------------------------------------------------------}
function TChatView.GetSelText: String;
var i:cardinal;
    s : String;
    StyleNo, LineNum :integer;
    dli : TDrawContainerInfo;
begin
Result := '';
if not SelectionExists then exit;
s := '';
LineNum := TDrawContainerInfo(DrawContainers.Objects[FSelStartContNo]).pDrawLineInfo.LineNumber;
for i := FSelStartContNo to FSelEndContNo do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[i]);
  if dli.pDrawLineInfo.LineNumber > LineNum then
    begin
    LineNum := dli.pDrawLineInfo.LineNumber;
    s := s + chr(13);
    end;
  StyleNo := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo ;
  if StyleNo >= 0 then
    begin
    if (FSelStartContNo = FSelEndContNo) then
      begin
      //���� ��������� � �������� ������ ����������
      s := Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, FSelEndOffsInCont - FSelStartOffsInCont);
      end
    else
      begin
      if (i = FSelStartContNo) then
        begin
        s := s + Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1,  Length(DrawContainers.Strings[i]) - FSelStartOffsInCont);
        end;
      if (i > FSelStartContNo) and (i < FSelEndContNo) then
        begin
        s := s + Copy(DrawContainers.Strings[i], 0, Length(DrawContainers.Strings[i]));
        end;
      if (i = FSelEndContNo) then
        begin
        s := s + Copy(DrawContainers.Strings[i], 0, FSelEndOffsInCont);
        end;
      end;
    end
  else
    begin
    s := s + DrawContainers.Strings[i];
    end;
  end;
result := s;
end;
{------------------------------------------------------------------}
procedure TChatView.GetSelectedText;
begin
if SelectionExists then
  begin
  ClipBoard.Clear;
  Clipboard.SetTextBuf(PChar(GetSelText));
  end;
end;
{------------------------------------------------------------------}
procedure TChatView.WMKeyDown(var Message: TWMKeyDown);
var dli: TDrawContainerInfo;
    FirstInCurrLine, LastInCurrLine: Cardinal;
    PrevLine, NextLine, TempCursor :integer;
begin
if FCursorSelection = true then
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[FCursor]);
  LastInCurrLine := GetLastContainerInCurrLine(FCursor);
  FirstInCurrLine := GetFirstContainerInCurrLine(FCursor);
  with Message do
    case CharCode of
//        VK_PRIOR:
//            vScrollNotify := SB_PAGEUP;
//        VK_PRIOR:
//            vScrollNotify := SB_PAGEUP;
//        VK_NEXT:
//          begin
//          end;
//        VK_HOME:
//            vScrollNotify := SB_TOP;
        VK_END:
          begin
          end;
        VK_UP:
          begin
          PrevLine := dli.pDrawLineInfo.LineNumber - 1;
          if PrevLine < 0 then
            PrevLine := 0
          else
            begin
//            TempCursor := GetContainerAtXInLine(FCursorPosX, PrevLine);
            TempCursor := FindNearItemAtPos(FCursorPosX, GetPrevBaseLine(FCursor));
            if TempCursor >= 0 then
              FCursor := TempCursor
            else
              begin
              //���� ���� �� ���� ����� ���������. ��� ����� ����, ����
              //1.��� ��� � ���, �.�. ��� ����� ������� ������
              //2.� ����� ������ ������ ������ ��� ���� ������ ���������� � ������
              //�� � ������ �� ��� �� ��������
              if FCursor - 1 > 1 then
                begin
                dec(FCursor);
                FCursor := GetFirstContainerInCurrLine(FCursor);
                end;
              end;
            FCursorPosX := TDrawContainerInfo(DrawContainers.Objects[FCursor]).Left +
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).Width div 2;
            FCursorPosY := TDrawContainerInfo(DrawContainers.Objects[FCursor]).pDrawLineInfo.BaseLine -
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).Height div 2;
{            FDebugText2 := 'PrevLine= ' + inttostr(PrevLine) + ' FCursor=' + inttostr(FCursor)+
                           ' FCursorPosY= ' + inttostr(FCursorPosY);
            self.OnDebug(FDebugText, FDebugText2);}
            end;
          end;
        VK_DOWN:
          begin
          NextLine := dli.pDrawLineInfo.LineNumber + 1;
          if NextLine > LineCount then
            begin
            NextLine := LineCount;
            end;
{          TempCursor := GetContainerAtXInLine(FCursorPosX, NextLine);}
          TempCursor := FindNearItemAtPos(FCursorPosX, TDrawContainerInfo(DrawContainers.Objects[FCursor]).pDrawLineInfo.BaseLine + 1);
          if TempCursor >= 0 then
            begin
            FCursor := TempCursor;
            end
          else
            begin
            //���� ���� �� ���� ����� ���������. ��� ����� ����, ����
            //1.��� ��� � ���, �.�. ��� ��������� ������
            //2.� ����� ������ ������ ������ ��� ���� ������ ���������� � ������
            //�� � ������ �� ��� �� ��������
            if FCursor + 1 < DrawContainers.Count - 1 then
              begin
              inc(FCursor);
              FCursor := GetLastContainerInCurrLine(FCursor);
              end;
            end;
          FCursorPosX := TDrawContainerInfo(DrawContainers.Objects[FCursor]).Left +
                         TDrawContainerInfo(DrawContainers.Objects[FCursor]).Width div 2;
          FCursorPosY := TDrawContainerInfo(DrawContainers.Objects[FCursor]).pDrawLineInfo.BaseLine -
                         TDrawContainerInfo(DrawContainers.Objects[FCursor]).Height div 2;
{          FDebugText2 := 'NextLine= ' + inttostr(NextLine) + ' FCursor=' + inttostr(FCursor)+
                         ' FCursorPosY= ' + inttostr(FCursorPosY) +
                         ' LineCount= ' + inttostr(self.LineCount);
          self.OnDebug(FDebugText, FDebugText2);}
          end;
        VK_LEFT:
          begin
          if FCursor > 1 then
            begin
            //���� ����� ��� ���� ����������
            dec(FCursor);
            FCursorPosX := TDrawContainerInfo(DrawContainers.Objects[FCursor]).Left +
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).width div 2;
            FCursorPosY := TDrawContainerInfo(DrawContainers.Objects[FCursor]).pDrawLineInfo.BaseLine -
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).Height div 2;
{            FDebugText2 := 'NextLine= ' + inttostr(NextLine) + ' FCursor=' + inttostr(FCursor)+
                           ' FCursorPosY= ' + inttostr(FCursorPosY) +
                           ' LineCount= ' + inttostr(self.LineCount);
            self.OnDebug(FDebugText, FDebugText2);}
            end;
          end;
        VK_RIGHT:
          begin
          if FCursor < DrawContainers.Count - 1 then
            begin
            //���� ������ ��� ���� ����������
            inc(FCursor);
            FCursorPosX := TDrawContainerInfo(DrawContainers.Objects[FCursor]).Left +
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).width div 2;
            FCursorPosY := TDrawContainerInfo(DrawContainers.Objects[FCursor]).pDrawLineInfo.BaseLine -
                           TDrawContainerInfo(DrawContainers.Objects[FCursor]).Height div 2;
{            FDebugText2 := 'NextLine= ' + inttostr(NextLine) + ' FCursor=' + inttostr(FCursor)+
                           ' FCursorPosY= ' + inttostr(FCursorPosY) +
                           ' LineCount= ' + inttostr(self.LineCount);
            self.OnDebug(FDebugText, FDebugText2);}
            end;
          end
        else
          inherited;
    end;
  SetCursorSelectionItems(FCursorPosX - HScrollPos, FCursorPosY - VScrollPos);
  FDebugText := 'FCursorPosX= ' + inttostr(FCursorPosX) + #10#13 +
                'FCursorPosY= ' + inttostr(FCursorPosY) + #10#13 +
                'FCursor= ' + inttostr(FCursor) + #10#13 +
                'FirstInCurrLine= ' + inttostr(FirstInCurrLine) + #10#13 +
                'LastInCurrLine= ' + inttostr(LastInCurrLine) + #10#13;
  self.OnDebug(FDebugText, FDebugText2);
  Invalidate;
  end
else
  inherited;
end;
{------------------------------------------------------------------}
procedure TChatView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SelectionExists and (ssCtrl in Shift) then
    begin
    if (Key = ord('C')) or (Key = VK_INSERT) then
      begin
      GetSelectedText;
//      MessageBox(0, PChar(Clipboard.AsText), PChar(inttostr(0)) ,mb_ok);
      end;
    end
  else
    begin
    inherited KeyDown(Key, Shift);
    end;
end;
  {------------------------------------------------------------------}
procedure TChatView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FStyle) then begin
      Style := nil;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.Click;
begin
  SetFocus;
  inherited;
end;
  {------------------------------------------------------------------}
procedure TChatView.Loaded;
begin
  inherited Loaded;
  Format;
end;
  {------------------------------------------------------------------}
procedure TChatView.SetGifAniCanvas(DestionationCanvas: TCanvas);
var n, FirstVisible, LastVisible : Cardinal;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
//    r :TRect;
begin
//��� ���� ��� ���:
FirstVisible := FirstVisibleContainer;
LastVisible := LastVisibleContainer;
for n := 0 to DrawContainers.Count - 1 do
  begin
  {� i � ����� �������������� ������ �����, ������� �� ������}
  {DrawContainers - ��� ������ �����, ������� ����� �� ������ ���� TStringList}
  dli := TDrawContainerInfo(DrawContainers.Objects[n]);
  li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
  if li.StyleNo = -8 then
    begin
    if (n >= FirstVisible) and (n <= LastVisible) then
      begin
    //�����!!!!!! � ���� ��������� ����� ���������� ��������!!!!!!
    //�.�. ����� ���� ������ �� ���������� �������� � ������:
    //����� ��� ����� � MirrorImagesY[n] ������ ��������
      //�������� ��������� ���������� ����� ������� ��� ���������, �.�. �� ��
      //���������� � �-��� Paint.
      TGifAni(li.gr).MirrorImagesX[li.imgNo] := TGifAni(li.gr).MirrorImagesX[li.imgNo] + Canvas.ClipRect.Left;
      TGifAni(li.gr).MirrorImagesY[li.imgNo] := TGifAni(li.gr).MirrorImagesY[li.imgNo] + Canvas.ClipRect.Top;
      TGifAni(li.gr).DestCanvas := DestionationCanvas;
      TGifAni(li.gr).ShowingAnimation[li.imgNo] := true;
      end
    else
      begin
      TGifAni(li.gr).ShowingAnimation[li.imgNo] := false;
      end;
    end;
  if li.StyleNo = -5 then
    begin
    if (n > LastVisible) or (n < FirstVisible) then
      begin
      TWinControl(li.gr).visible := false;
      end
    else
      begin
      TWinControl(li.gr).visible := true;
      TWinControl(li.gr).repaint;
      end;
    end;
  end;
end;
{------------------------------------------------------}
procedure TChatView.WMVScroll(var Message: TWMVScroll);
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//��� ���� ��� ���:
//��� ������������� �� ���������� �-��� Paint, ��-�� �� ���������� ����������
//������� GifAni. ���������� ����������� ��������� � ��������� ����������.
inherited;
Scrolling := true;
SetGifAniCanvas(self.Canvas);
Scrolling := false;
end;
procedure TChatView.WMHScroll(var Message: TWMVScroll);
//��������������!!!!
//��������! ��������� HScrollPos!!!
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//��� ���� ��� ���:
//��� ������������� �� ���������� �-��� Paint, ��-�� �� ���������� ����������
//������� GifAni. ���������� ����������� ��������� � ��������� ����������.
inherited;
Scrolling := true;
Invalidate;
SetGifAniCanvas(self.Canvas);
Scrolling := false;
end;

























{-------------------------------------}
procedure TChatView.Paint;
var i,no, yshift, xshift, n: Integer;
    cl, textcolor: TColor;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    lastline, hovernow: Boolean;
    r, rect1, GifRect :TRect;
    canv : TCanvas;
    s, s1 : String;
//    StartNo, EndNo, StartOffs, EndOffs: Integer;
//    GifFrame: TGifFrame;
    GIFImage:TGif;
    FirstVisible, LastVisible: cardinal;
begin
//xshift - �.�. ��� �������������� ����������� ���������� ����������� ��������
//         �� 0 �� ������ �������, �� ��� ������ ����� ������� ����� ������� ��
//         ������ ������ � ���� -����������. ����� ��������� ���������� ����������
//         ����� �������� �� ��� ������������� ����� �������. Xshift ��� � ����.
//yshift - ��� ������ � �������� �� ���� �����, � �������� ���������� ������������ ������

{���������� ��������� TChatView ����������}
 if (csDesigning in ComponentState) or
    not Assigned(FStyle) then
   begin
    {���� �� �������� ��������� Style}
    cl := Canvas.Brush.Color;
    if Assigned(FStyle) then
        Canvas.Brush.Color := FStyle.Color
    else
        Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Color := clWindowText;
    Canvas.Font.Color := clWindowText;
    Canvas.Font.Name := 'MS Sans Serif';
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [];
    Canvas.FillRect(Canvas.ClipRect);
    if (csDesigning in ComponentState) then
      Canvas.TextOut(ClientRect.Left+1, ClientRect.Top+1, FVersion)
    else
      Canvas.TextOut(ClientRect.Left+1, ClientRect.Top+1, 'Error: style is not assigned');
    Canvas.Brush.Color := clWindowText;
    Canvas.FrameRect(ClientRect);
    Canvas.Brush.Color := cl;
    exit;
 end;

// GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
 {
 StartNo - ����� 1� ���������� ������
 EndNo - ����� ��������� ���������� ������
 StartOffs - ???? ����� ������� � �������� ���������� ���������
 EndOffs - ???? ����� ������� �� ������� ������������� ���������
 }
 lastline := False;
 r := Canvas.ClipRect;
//Use ClipRect to determine where the canvas needs painting.
//���� ������ ��������, �� ������ ��� ������ 1 ������
//��������! ����� �� ������� BufferVirtCanv ������� = ���� TChatView!
 BufferVirtCanv.Width := r.Right - r.Left + 1;
 BufferVirtCanv.Height := r.Bottom - r.Top + 1;
//� ����� � ���� 1 ������ ������ ������� ������ ��, ��� �����!!!!!
//�������� ����������� ���������!!!!!!!!
 canv := BufferVirtCanv.Canvas;
 DrawBack(canv.Handle, Canvas.ClipRect, ClientWidth, ClientHeight);
 r.Top := r.Top + yshift;
 r.Bottom := r.Bottom + yshift;
 //�.�. Canvas.ClipRect.Top ��� ���������� ������ ��������� ������� �������,
 //������� ���������� ���������� (�������� ������� � ���� ������, ���� �� �������
 //����������� ������ ���� ������ ������ �� ���� ������ ����)
 //���������� ����������� ������ ��������� ����� ����� �������
 yshift := VScrollPos + Canvas.ClipRect.Top;
 xshift := HScrollPos + Canvas.ClipRect.Left;
 canv.Brush.Style := bsClear;

//FDebugText := 'r.Top  = ' + inttostr(r.TopLeft.y) +
//              'r.Bottom = ' + inttostr(r.BottomRight.y);
//self.OnDebug(FDebugText);

//canv.Rectangle(FSelStartX - HScrollPos, FSelStartY - VScrollPos,
//               FSelEndX - HScrollPos, FSelEndY - VScrollPos);


//�������� ����������� ���������!!!!!!!!
//� �������� ���������� ���������� 1 ������ �� r. ������ ����!!!!
FirstVisible := GetFirstVisibleContainer();
LastVisible := GetLastVisibleContainer();
 for i := FirstVisible to LastVisible do
   begin
   //� i � ����� �������������� ������ �����������, ������� �� ������
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
//   if (lastline = True) and (dli.Left <= TDrawContainerInfo(DrawContainers.Objects[i-1]).left) then break;
//   if dli.top^ > r.Bottom then lastline := True;
   if dli.Bottom^ - dli.Height > r.Bottom then lastline := True;
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   no := li.StyleNo;
   if no >= 0 then
     begin // text
     canv.Font.Style := FStyle.TextStyles[no].Style;
     canv.Font.Size := FStyle.TextStyles[no].Size;
     canv.Font.Name := FStyle.TextStyles[no].FontName;
     canv.Font.CharSet := FStyle.TextStyles[no].CharSet;
     if not ((no in [cvsJump1, cvsJump2]) and DrawHover and
        (LastJumpMovedAbove<>-1) and
        (li.ImgNo = LastJumpMovedAbove)) then
       begin
       textcolor := FStyle.TextStyles[no].Color;
       hovernow := False;
       end
     else
       begin
       textcolor := FStyle.HoverColor;
       hovernow := True;
       canv.Font.Color := textcolor;
       end;
     if (i < FSelStartContNo) or (i > FSelEndContNo) or
        ((FSelStartContNo = FSelEndContNo) and (FSelStartOffsInCont = FSelEndOffsInCont))
       then
       begin
       //���� ��������� ��������� �� �������� � ���������� ������� ��� ��������� ������
       //������� ������� �����
       canv.Font.Color := textcolor;
       canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
       end
     else
       begin
       //���� ��������� ��������� ���������� � ���������� ��������
       //�.�. ��������� ������ ����� ���� ������ � �������� ���������� �
       //��������� ���� � ��������, ����� ��������� ���������� ���������� �����
       //� ������ � � �����
      if (i = FSelStartContNo) and (FSelStartOffsInCont > 0) then
          begin
          //������� �� ���������� ������ (���� ��������� �� � ������ ������)
          s := Copy(DrawContainers.Strings[i], 0, FSelStartOffsInCont);
          canv.Font.Color := textcolor;
//        if not hovernow then canv.Font.Color := FStyle.SelTextColor;
          canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
          end;

       if (FSelStartContNo = FSelEndContNo) then
          begin
          //������� ���� ���������� ����� � �������� ������ ����������
          s := Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, FSelEndOffsInCont - FSelStartOffsInCont);
          canv.Brush.Style := bsSolid;
          canv.Brush.Color := FStyle.SelColor;
          canv.Font.Color := FStyle.SelTextColor;
          canv.TextOut(dli.Left - xshift + FSelStartPixOffsInCont, dli.Bottom^ - dli.Height - yshift, s);
          canv.Brush.Style := bsClear;
          if (FSelEndOffsInCont > 0) then
            begin
            //������� �� ���������� ����� (���� ��������� �� �� ����� ������)
            canv.Font.Color := textcolor;
            canv.TextOut(dli.Left - xshift + FSelStartPixOffsInCont + canv.TextWidth(s),
                         dli.Bottom^ - dli.Height - yshift,
                         Copy(DrawContainers.Strings[i], FSelEndOffsInCont + 1, Length(DrawContainers.Strings[i])));
            end;
          end
        else
          //���� �������� ����� ������ ���������� FSelStartContNo <> FSelEndContNo
          begin
          if (i = FSelStartContNo) then
            begin
            canv.Brush.Style := bsSolid;
            canv.Brush.Color := FStyle.SelColor;
            canv.Font.Color := FStyle.SelTextColor;
//       if not hovernow then canv.Font.Color := FStyle.SelTextColor;
            s := Copy(DrawContainers.Strings[i], 0, FSelStartOffsInCont);
//            canv.TextOut(dli.Left + canv.TextWidth(s),
//                         dli.Bottom^ - dli.Height - yshift,
//                         Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, Length(DrawContainers.Strings[i])));

//        - Canvas.ClipRect.Left, - ���������� ���������� ��� ���������� ����� ������
//        - Canvas.ClipRect.Top,
            canv.TextOut(dli.Left + canv.TextWidth(s) - Canvas.ClipRect.Left,
                         dli.Bottom^ - dli.Height - yshift,
                         Copy(DrawContainers.Strings[i], FSelStartOffsInCont + 1, Length(DrawContainers.Strings[i])));
            canv.Brush.Style := bsClear;
            end;
          if (i > FSelStartContNo) and (i < FSelEndContNo) then
            begin
            canv.Brush.Style := bsSolid;
            canv.Brush.Color := FStyle.SelColor;
            canv.Font.Color := FStyle.SelTextColor;
//       if not hovernow then canv.Font.Color := FStyle.SelTextColor;
            canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
            canv.Brush.Style := bsClear;
            end;
          if (i = FSelEndContNo) then
            begin
            if (FSelEndOffsInCont > 0) then
              begin
              //������� ���������� �����
              s := Copy(DrawContainers.Strings[i], 0, FSelEndOffsInCont);
              canv.Font.Color := textcolor;
              canv.Brush.Style := bsSolid;
              canv.Brush.Color := FStyle.SelColor;
              canv.Font.Color := FStyle.SelTextColor;
              canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
              canv.Brush.Style := bsClear;
              end;
            if (FSelEndOffsInCont >= 0) then
              begin
              //������� �� ���������� �����
              s := Copy(DrawContainers.Strings[i], 0, FSelEndOffsInCont);
              canv.Font.Color := textcolor;
              canv.TextOut(dli.Left - xshift + canv.TextWidth(s),
                           dli.Bottom^ - dli.Height - yshift,
                           Copy(DrawContainers.Strings[i], FSelEndOffsInCont + 1, length(DrawContainers.Strings[i]) - FSelEndOffsInCont + 1));
              end;
            end;
          end;
       end;
     continue;
     end;
{===============================================================================}
   if (no = -8)  then // gifanimate
     begin
      TGifAni(li.gr).MirrorImagesY[li.imgNo] := dli.Bottom^ - dli.Height - VScrollPos {* VScrollStep} - Canvas.ClipRect.Top;
      TGifAni(li.gr).MirrorImagesX[li.imgNo] := dli.Left - HScrollPos - Canvas.ClipRect.Left;
     //��� �������������� ������ ��� ����������!!!!!
        TGifAni(li.gr).DestCanvas := canv;
        TGifAni(li.gr).DrawFrame(li.imgNo);
     //������ ����� ��� ���������
     if (i >= FSelStartContNo) and (i <= FSelEndContNo) then
       canv.Rectangle(dli.Left - HScrollPos - 1 - Canvas.ClipRect.Left,
                      dli.Bottom^ - VScrollPos - Canvas.ClipRect.Top,
                      dli.Left - HScrollPos + dli.Width + 1 - Canvas.ClipRect.Left,
                      dli.Bottom^ - VScrollPos - dli.Height - 1 - Canvas.ClipRect.Top);

  FDebugText := #10#13 + #10#13 + #10#13 +
                'Canvas.ClipRect.Left= ' + inttostr(Canvas.ClipRect.Left) + #10#13 +
                'Canvas.ClipRect.Top= ' + inttostr(Canvas.ClipRect.Top) + #10#13 +
                'Canvas.ClipRect.Right= ' + inttostr(Canvas.ClipRect.Right) + #10#13 +
                'Canvas.ClipRect.Bottom= ' + inttostr(Canvas.ClipRect.Bottom) + #10#13;
  self.OnDebug(FDebugText, FDebugText2);
     end;
{===============================================================================}
   if (no = -7)  then // gif }
     begin
     end;
{===============================================================================}
   if (no = -5)  then // WinControl
     begin
     //������ ����� ��� ���������
     if (i >= FSelStartContNo) and (i <= FSelEndContNo) then
       canv.Rectangle(dli.Left - HScrollPos - 1, dli.Bottom^ - VScrollPos,
                      dli.Left - HScrollPos + dli.Width + 1,
                      dli.Bottom^ - VScrollPos - dli.Height - 1);
     //������, �� �� ������� � ������ �������� ����, � ��� ���� ������� ����� ��
     //������ ��������
     TWinControl(li.gr).Top := dli.Bottom^ - dli.Height - VScrollPos {* VScrollStep};
     TWinControl(li.gr).Left := dli.Left - HScrollPos;

{     FDebugText2 := FDebugText + #10#13 +
                   'paint: TWinControl(li.gr).Top =' + Inttostr(TWinControl(li.gr).Top) + #10#13 +
                   'paint: TWinControl(li.gr).Left =' + Inttostr(TWinControl(li.gr).Left);
     self.OnDebug(FDebugText2);}
     end;
{===============================================================================}
   if (no = -4) or (no = -6)  then
     begin // hotspots and bullets
     if (FSelStartContNo<=i) and (FSelEndContNo>=i) and
        not ((FSelEndContNo=i) and (FSelEndOffsInCont=0)) and
        not ((FSelStartContNo=i) and (FSelStartOffsInCont=2)) then
       begin
       TImageList(li.gr).BlendColor := FStyle.SelColor;
       TImageList(li.gr).DrawingStyle := dsSelected;
     end;
//     TImageList(li.gr).Draw(canv, dli.Left-xshift, dli.top^ -yshift, li.imgNo);
     TImageList(li.gr).Draw(canv, dli.Left - xshift - HScrollPos, dli.Bottom^ - dli.Height - yshift, li.imgNo);
     TImageList(li.gr).DrawingStyle := dsNormal;
     continue;
   end;
{===============================================================================}
   if (no = -3)  then
     begin // graphics
     canv.Draw(dli.Left - xshift - HScrollPos, dli.Bottom^  - yshift, TGraphic(li.gr));
     continue;
     end;
{===============================================================================}
//   if no = -2 then continue; // check point
   if no = -1 then
     begin //break line
     canv.Pen.Color := FStyle.TextStyles[0].Color;
     canv.MoveTo(dli.Left + 5 - xshift, dli.Bottom^ - dli.Height div 2 - yshift);
     canv.LineTo(XSize - 5 - xshift - FRightMargin, dli.Bottom^ - dli.Height div 2 - yshift);
     end;
   // controls ignored
   end;

Canvas.Draw(Canvas.ClipRect.Left, Canvas.ClipRect.Top, BufferVirtCanv);
SetGifAniCanvas(Canvas);
end;

{------------------------------------------------------------------}
procedure TChatView.Format_(OnlyResized:Boolean; depth: Integer; Canvas: TCanvas;
                            OnlyTail: Boolean);
var i, j: Integer;
    OldLine, line, x, b, d, a: Integer;
    pPartStr: Pchar;
    NewLine: Boolean;
    CrDrawLine: Boolean;
    xOld, bOld, dOld, aOld: Integer;
    mx: Integer;
    oldy, oldtextwidth, cw, ch: Integer;
    sad: TScreenAndDevice;
    StyleNo: Integer;
    StartContainer: Integer;
    StartNo, EndNo, StartOffs, EndOffs: Integer;
    LineInfo: TDrawLineInfo;
    LastDrawContainer:cardinal;
begin
   if VScrollStep = 0 then exit;
   if (csDesigning in ComponentState) or
      not Assigned(FStyle) or
      skipformatting or
      (depth>1)
      then exit;
   skipformatting := True;

//   if depth = 0 then StoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);

   OldY := self.VScrollPos;

   oldtextwidth := self.TextWidth;

   {self - ��� ��������� ���������� TChatView, ��������� �������������}
   //������ ��� ������: ������ ������� ��� ������ ��������-��������
   mx := max(self.ClientWidth - (self.FLeftMargin + self.FRightMargin), GetMaxPictureWidth);
   if mx < self.FMinTextWidth then mx := self.FMinTextWidth;

   if self.FClientTextWidth = true then
     begin { widths of pictures and maxtextwidth are ignored }
     self.TextWidth := self.ClientWidth - (self.FLeftMargin + self.FRightMargin);
     if self.TextWidth < self.FMinTextWidth then self.TextWidth := self.FMinTextWidth;
     end
   else
     begin
     if (mx > self.FMaxTextWidth) and (self.FMaxTextWidth > 0) then
       self.TextWidth := self.FMaxTextWidth
     else
       self.TextWidth := mx;
     end;

   if not (OnlyResized and (self.TextWidth = OldTextWidth)) then
     begin
     if OnlyTail = true then
       begin
       //���� ����� ��������������� ������ �� ����������, ������� ���� ���������
       //� �����, ����� ����� ������������ �������� �� ������ ��������� ��������������
       //� ���������� �������
       LastDrawContainer := DrawContainers.Count - 1;
       StartContainer := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).ContainerNumber + 1;
       b:= self.TextHeight;
       LineInfo := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).pDrawLineInfo;
       Line := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.count - 1]).LineNumber;
       x := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).Left +
            TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).Width;
       b := TDrawContainerInfo(DrawContainers.Objects[LastDrawContainer]).pDrawLineInfo.BaseLine;
       inc(Line);
       end
     else
       begin
       StartContainer := 0;
       ClearTemporal;
       LineInfo := nil;
       line := 0;
       x := 0;
       b := 0;
       if DrawLinesInfo.Count > 0 then
         begin
         for i := 0 to DrawLinesInfo.Count - 1 do
           begin
           TDrawLineInfo(DrawLinesInfo.Objects[i]).Free;
           end;
         DrawLinesInfo.clear;
         end;
       end;

     pPartStr := nil;
     d := 0;
     a := 0;

     InfoAboutSaD(sad, Canvas);
     sad.LeftMargin := MulDiv(self.FLeftMargin,  sad.ppixDevice, sad.ppixScreen);

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
     for i := StartContainer to ContStorage.Count - 1 do
       begin
       StyleNo := TContainerInfo(ContStorage.Objects[i]).StyleNo;
       //�������� �� ��������� ��������� ����� � �����
       if not (((StyleNo = cvsPicture) and (not (cvdoImages in DisplayOptions))) or
          ((StyleNo = CvsComponent)and(not (cvdoComponents in DisplayOptions))) or
          (((StyleNo = cvsBullet) or
          (StyleNo = cvsHotspot))and(not (cvdoBullets in DisplayOptions)))) then
         begin
         if TContainerInfo(ContStorage.Objects[i]).SameAsPrev = false then
           {�.�. ���� ������� AddCenterLine ��� AddFromNewLine}
           begin
           NewLine := true;
           end;
         FormatNextContainer(LineInfo, line, i, x, b, a, pPartStr, NewLine, Canvas, sad);
         if Line > 1 then
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine :=
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 2]).BaseLine +
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).MaxHeight
         else
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine :=
           TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).MaxHeight;
         end;
       end;
       {MessageBox(0, Pchar(inttostr(DrawContainers.count)),
                   'DrawContainers.count', mb_ok);}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
     //������ ����� ����������� TChatView
     self.TextHeight := TDrawLineInfo(DrawLinesInfo.Objects[Line - 1]).BaseLine + d + 1;
     if TextHeight div VScrollStep > 30000 then
       self.VScrollStep := self.TextHeight div 30000;
     AdjustJumpsCoords;
     end
   else
     begin
     //���� ��������� ��������� �������� (WM_SIZE)
//     AdjustChildrenCoords;
     //��� �������������� ���������� ���� ������ ������� �������������� ���������
     SetHPos(0);
     end;
   cw := ClientWidth;
   ch := ClientHeight;
   UpdateScrollBars(mx + FLeftMargin + FRightMargin, TextHeight);
   if (cw<>ClientWidth) or (ch<>ClientHeight) then
     begin
     //�� ��� ���....
     skipformatting := False;
     ScrollTo(OldY);
     Format_(OnlyResized, depth + 1, Canvas, False);
//     MessageBox(0, PChar(inttostr(0)), 'cw<>ClientWidth', mb_ok);
     end;
   if OnlyResized then ScrollTo(OldY);
//   if OnlyTail then ScrollTo(TextHeight);
   if depth = 0 then RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);
   skipformatting := False;
SetGifAniCanvas(canvas);   
end;
{------------------------------------------------------------------}
procedure TChatView.FormatNextContainer(var DrawLineInfo:TDrawLineInfo;
                                  var LineNum, ContNum, x, baseline, Ascent:Integer;
                                  var sourceStrPtr:PChar;
                                  var newline:boolean;
                                  Canvas: TCanvas; var sad: TScreenAndDevice);
{
// (x, baseline) - ��� ����� ������ ���� �������������� ��� ������ ������
//baseline  - ���������� Y ������ ������ ������� �������������� (�.�. �� �����
//            ��������� ��� ���� �����������)
//
//x         - ���������� � ������ ������ ������� ��������������
//Ascent  - ������������� �������� (����� ������� � � ������� ������ ������� ������)              (��� �� ����� ������ �������???)

+----------------------------
|  ������    ������ ������_____
|                            ^
|                            | Ascent (����� �����)
|  ������    ������ ������_____Y ��� ������������� ������������� Y ���������� (baseline)
^            ^
|<---------->|
      x
//�.�. (x, prevdesc) - ��� ������ ������ ���� ���������� ������
//����� ������ ����� ������ ����� �������� ���������� ������ ����
}
var {sourceStrPtr,} strForAdd, strSpacePos: PChar;
    sourceStrPtrLen, PrevBaseLine: Integer;
    CreateDrawLine: Boolean;
    sz: TSIZE;
    maxInAllCanvasWidth, max,j, y, ctrlw, ctrlh : Integer;
{$IFNDEF ChatViewDEF4}
    arr: array[0..1000] of integer;
{$ENDIF}
    str: array[0..1000] of char;
    info: TDrawContainerInfo;
    metr: TTextMetric;
    StyleNo: Integer;
    center:Boolean;
    cpinfo: TCPInfo;
    jmpinfo: TJumpInfo;
    n, width, y5, Offs : Integer;
    CanvasRect:TRect;
    s:string;
begin
  width := TextWidth;
  PrevBaseLine := 0;

  if NewLine = true then
    begin
    if DrawLinesInfo.Count > 0 then
      begin
      //���� ���� �������������� ��� ������ ���� ���
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
      DrawLineInfo := TDrawLineInfo.Create;
      DrawLineInfo.LineNumber := LineNum;
      DrawLineInfo.BaseLine := baseline;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      inc(LineNum);
      NewLine := true;
      CreateDrawLine := False;
      end
    else
      begin
      //DrawLineInfo ��������� �������
      DrawLineInfo := TDrawLineInfo.Create;
      DrawLineInfo.LineNumber := LineNum;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      DrawLineInfo.BaseLine := baseline;
      inc(LineNum);
      PrevBaseLine := 0;
      NewLine := true;
      CreateDrawLine := False;
      end;
    end
  else
    begin
    //���� ���������� ����� � ���� ������, �� PrevBaseLine �������� ���� ����
    if DrawLinesInfo.Count > 1 then
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 2]).BaseLine;
//    MessageBox(0, Pchar(inttostr(PrevBaseLine)), 'PrevBaseLine', mb_ok);
    end;
{    if DrawLinesInfo.Count > 0 then
      PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
    end;}

  case TContainerInfo(ContStorage.Objects[ContNum]).StyleNo of
   -8:  { GifAni}
     begin
       ctrlw       := TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).GifImage.Width;
       ctrlh       := TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).GifImage.Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info        := TDrawContainerInfo.Create;
       info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
       info.Width  := ctrlw;

       info.Height := ctrlh + 1;
       info.LineNum     := @DrawLineInfo.LineNumber;
       info.pDrawLineInfo := DrawLineInfo;
       //��������� ����� �������� �� ������v ���������� (��������� �� ������???)

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //� ����� ������ �� �����������
         inc(LineNum);
         x := sad.LeftMargin;//������
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
//         info.LineNum := @DrawLineInfo.LineNumber;
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //� ����� ������, �.�. �� ������ �� ���
           x := sad.LeftMargin;//������
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}
           inc(LineNum);
           end
         else
           begin
           //���������� ������ ������
           x := x + 1 + sad.LeftMargin;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject(ContStorage.Strings[ContNum], info);
       TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).MirrorImagesY[TContainerInfo(ContStorage.Objects[ContNum]).imgNo] := info.Bottom^;
       TGifAni(TContainerInfo(ContStorage.Objects[ContNum]).gr).MirrorImagesX[TContainerInfo(ContStorage.Objects[ContNum]).imgNo] := x;

//FDebugText := 'Format MirrorImagesY[' + inttostr(TContainerInfo(ContStorage.Objects[ContNum]).imgNo) + '] = ' + inttostr(info.Bottom^);
//self.OnDebug(FDebugText);

       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -6: { Bullet }
     begin
       ctrlw       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info := TDrawContainerInfo.Create;
       info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
       info.Width  := ctrlw+1;
       info.Height := ctrlh+1;
       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //� ����� ������ �� �����������
         x := sad.LeftMargin;//������
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
         info.LineNum := @DrawLineInfo.LineNumber;
         inc(LineNum);
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //� ����� ������, �.�. �� ������ �� ���
           x := sad.LeftMargin;//������
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           info.LineNum := @DrawLineInfo.LineNumber;
           inc(LineNum);
           end
         else
           begin
           //���������� ������ ������
           x := x + 1 + sad.LeftMargin;
           info.LineNum := @DrawLineInfo.LineNumber;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;

       info.Left := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('',info);

       DrawLineInfo.LineNumber := LineNum;
       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -5: { WinControl }
     begin
       ctrlw       := TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info        := TDrawContainerInfo.Create;
       info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
       info.Width  := ctrlw;

       info.Height := ctrlh + 1;
       info.LineNum     := @DrawLineInfo.LineNumber;
       info.pDrawLineInfo := DrawLineInfo;
       //��������� ����� �������� �� ������v ���������� (��������� �� ������???)

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false then
         begin
         //� ����� ������ �� �����������
         inc(LineNum);
         x := sad.LeftMargin;//������
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
//         info.LineNum := @DrawLineInfo.LineNumber;
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //� ����� ������, �.�. �� ������ �� ���
           x := sad.LeftMargin;//������
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}
           inc(LineNum);
           end
         else
           begin
           //���������� ������ ������
           x := x + 1 + sad.LeftMargin;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('', info);
       //���� ������, �� ������-�� ������ ��� ������� ������� ���� ��� ����
       //����� ���������
       //TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top := info.Bottom^ - TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Left := x;

s := {'TControl(TContainerInfo(ContStorage}'.Objects[' +
     inttostr(ContNum) +
//     ']).gr).Top =' + inttostr(info.Bottom^);
     ']).gr).Top =' + inttostr(TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top);
Ondebug(s, FDebugText2);

//FDebugText := 'Format MirrorImagesY[' + inttostr(TContainerInfo(ContStorage.Objects[ContNum]).imgNo) + '] = ' + inttostr(info.Bottom^);
//self.OnDebug(FDebugText);

{MessageBox(0, 'format: info.Bottom^ =',
              PChar(Inttostr(info.Bottom^) + ' ' + inttostr(ContNum)),
              mb_ok);}

       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -4: { hotSpot }
     begin
       ctrlw       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Width;
       ctrlh       := TImageList(TContainerInfo(ContStorage.Objects[ContNum]).gr).Height;
       ctrlw       := MulDiv(ctrlw, sad.ppixDevice, sad.ppixScreen);
       ctrlh       := MulDiv(ctrlh, sad.ppiyDevice, sad.ppiyScreen);
       info := TDrawContainerInfo.Create;
       info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
       info.Width  := ctrlw+1;
       info.Height := ctrlh+1;
       jmpinfo     := TJumpInfo.Create;
       jmpinfo.l   := x+1+sad.LeftMargin;;
       jmpinfo.t   := y+1;
       jmpinfo.w   := ctrlw;
       jmpinfo.h   := ctrlh;
       jmpinfo.id  := nJmps;
       jmpinfo.idx := DrawContainers.Count;
       jumps.AddObject('',jmpinfo);
       inc(nJmps);

       if TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev = false or
           (info.Left > width) then
         begin
         //� ����� ������ �� �����������
         x := sad.LeftMargin;
         baseline := PrevBaseLine + Ascent + info.Height;
         DrawLineInfo.BaseLine := baseline;
         DrawLineInfo.MaxHeight := info.Height;
         info.LineNum := @DrawLineInfo.LineNumber;
         inc(LineNum);
         newline := false;
         end
       else
         begin
         if (x + info.Width > width) then
           begin
           //� ����� ������, �.�. �� ������ �� ���
           x := sad.LeftMargin;//������
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           info.LineNum := @DrawLineInfo.LineNumber;

           s := 'x := ' + inttostr(x) +
                '  BaseLine := ' + inttostr(BaseLine) +
                '  LineNum := ' + inttostr(LineNum);

           inc(LineNum);
           end
         else
           begin
           //���������� ������ ������
           x := x + 1 + sad.LeftMargin;
           info.LineNum := @DrawLineInfo.LineNumber;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;

//       MessageBox(0, Pchar(inttostr(nJmps)), 'nJmps', mb_ok);

       info.Left := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.FromNewLine := not TContainerInfo(ContStorage.Objects[ContNum]).SameAsPrev;
       DrawContainers.AddObject('',info);
       x := x + ctrlw + 1 - sad.LeftMargin;
     end;
   -3:  { graphics}
     begin
     end;
   -2: { check point}
    begin
       {cpinfo   := TCPInfo.Create;
       cpinfo.Y := baseline + Ascent;
       cpinfo.LineNo := ContNum;
       checkpoints.AddObject(ContStorage[ContNum], cpinfo);}
    end;
   -1: { break line}
    begin
      y5                 := MulDiv(5, sad.ppiyDevice, sad.ppiyScreen);
      info               := TDrawContainerInfo.Create;
      info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
      info.Left          := sad.LeftMargin;
      info.Bottom         := @DrawLineInfo.BaseLine;
      info.ContainerNumber := ContNum;
      info.LineNum        := @DrawLineInfo.LineNumber;
      info.Width         := Width;
      info.Height        := y5 + y5 + 1;
      info.pDrawLineInfo := DrawLineInfo;
      DrawLineInfo.MaxHeight := info.Height;
      DrawLineInfo.MaxHeight := info.Height;

      DrawContainers.AddObject(ContStorage[ContNum], info);

      baseline := PrevBaseLine + Ascent + info.Height;
//      MessageBox(0, Pchar(inttostr(PrevBaseLine)), 'PrevBaseLine', mb_ok);
      DrawLineInfo.BaseLine := baseline;
      x := 0;
    end;
  else
    begin { text }
      //�������� ������ ������, ������������ � ����������
      //��������:
      //  ChatView ChatView ChatView ChatView
      //  ^
      //  |
      //  +- sourceStrPtr
      if sourceStrPtr = nil then
        begin
        sourceStrPtr := PChar(ContStorage.Strings[ContNum]);
        //� strForAdd ��������� �� ����� [0..1000]
        strForAdd := str;
        //������ ����� ������
        sourceStrPtrLen := StrLen(sourceStrPtr);
        //������ ����� ������ ������
        end;

      StyleNo := TContainerInfo(ContStorage.Objects[ContNum]).StyleNo;
      //����������� ������ �� ������ �����, ����� ��������� ��������
      //������� ������
      with FStyle.TextStyles[StyleNo] do
        begin
        Canvas.Font.Style := Style;
        Canvas.Font.Size  := Size;
        Canvas.Font.Name  := FontName;
        Canvas.Font.CharSet  := CharSet;
        end;
      //�������� � metr ��������� � ����������� ����������� ������
      GetTextMetrics(Canvas.Handle, metr);
      //metr.tmExternalLeading - ������������� ���������� (������
      //���� ������� ��� �)
      //metr.tmAscent - ������ (������ ������� ������ � �������� ��� �,
      //�� ��� ������������ ��������� ������������ �)
      //����: ���� ��������� �������� � ���� ������ ��� � ����������
      //����: �� ������
      Center := TContainerInfo(ContStorage.Objects[ContNum]).Center;

      while sourceStrPtr <> nil do
        //� ���� ����� �������������� ��������� ����� ������� ������, �� ������,
        //������� ���������� � ������. ��� ������ �������� ������, ����� ������
        //��������� ����������� TDrawContainerInfo. ��� ���������� ��������
        //���� � �������������� ������ ������� ������� + � ������� �������
        //�� ����� TOP ����������, � ����� ������ �� ������ DrawLineInfo
        //������� � ����� ��������� TOP ����������. �.�. ��������� TDrawContainerInfo
        //������� ��������� �� ����� ������ ��������� �� ���� TDrawLineInfo
        //����������� ���������� �������� TOP ������ � ������ TDrawLineInfo
        //� �� ��������� � ���� ������.
        begin
        //���� ��������� �������� �����
        //���� ���������� ������� ����� ������
        if newline = true then
          begin
          if CreateDrawLine = true then
            begin
            //��� � ��� ��������: ��� �������� ���� BreakLine � ��������
            //DrawLineInfo ��� ������ ���� ������, � Text ��� ����� � ������
            //��������� ���� ������ ��� �������� ���� �� ������ ������
            //����� ������� ������� �������� � ������������...

            //������������� ������� ����� �� ����������� �������� �������
            if LineNum > 1 then
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).BaseLine :=
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 2]).BaseLine +
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).MaxHeight
            else
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).BaseLine :=
              TDrawLineInfo(DrawLinesInfo.Objects[LineNum - 1]).MaxHeight;

            if DrawLinesInfo.Count > 0 then
              PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine
            else
              PrevBaseLine := 0;
            DrawLineInfo := TDrawLineInfo.Create;
            DrawLineInfo.LineNumber := LineNum;
            DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
            inc(LineNum);
            end;
          //���� �������� ����� � ����� ������, �� ���������� � ���������� � 0
          x := 0;
          //����������� ������� �����
          //�������� !!! �� ����� ����� �� TOP ����������� �������-�����!!!!
          //�������� ����
          newline := false;
//          MessageBox(0, PChar(inttostr(DrawLineInfo.LineNumber) + '  ' + inttostr(baseline)),
//                    'DrawLineInfo.LineNumber   baseline', mb_ok);
          end;

        if x > Width then x := Width;
        GetTextExtentExPoint(Canvas.Handle,  sourceStrPtr,
                             sourceStrPtrLen, Width - x,
                             @max, nil,//� D5 ����������� ��� ������
                             sz);
        //�-��� ���������� � max ���������� ��������, ������������ �� ����� �������


        //�������� ��� ���������� �������� � strForAdd
        StrLCopy(strForAdd, sourceStrPtr, max);

        if max < sourceStrPtrLen then
        //���� max ������, ��� ����� ������ (�.�. ����� �� ���������� �� ����� �������)
          begin
          //������� �������� � ���� ����� ��������� �� ��������� ������
          //� ������ �� ����� �� �������� ������������
          //������� ���� � ������������, ������� �������� �� ������� ������
          //�������� ':'
          for n := 1 to Length(FDelimiters) do
            begin
            strSpacePos := StrRScan(strForAdd, FDelimiters[n]);
            if strSpacePos <> nil then break;
            end;
          //���� �� �����, �� ���� ����� ���������� ������������
          //�������� '{' ��� ������ ������������ � ������ ����� �� �� ������ 
          if strSpacePos = nil then
          for n := 1 to Length(FMergeDelimiters) do
            begin
            strSpacePos := StrRScan(strForAdd, FMergeDelimiters[n]);
            if strSpacePos <> nil then
              begin
              if strSpacePos <> Pchar(strForAdd) then Dec(strSpacePos);
              break;
              end;
            end;
          if strSpacePos <> nil then
            begin
            //�����, �������� ��������� �� �������� (��� ������ ���������� �����
            //������� �� ������ �� ��� ������, ������� � ����� ����� ����� ��������
            //��� ������� ����) ��������, ����� ������, �� ���. ����. sourceStrPtr:
            //  ChatView ChatView ChatView ChatView
            //  ^
            //  |
            //  +- sourceStrPtr

            // +---------------------+  <--- ������� �������
            // |                     |
            // |ChatView ChatView ChatView ChatView
            // |                     |
            // ��������� ����� �� ���������� � ������

            //  ChatView ChatView Cha
            //  ^                ^
            //  |                |
            //  +- strForAdd     +- strSpacePos

            //�.�. ��� ����� ������� ������� ' Cha' ��� �������� ���������� �������
            //  strForAdd =  'ChatView ChatView Cha'
            //  strSpacePos =                 ' Cha'
            max := strSpacePos - strForAdd;
            //� strForAdd �������� ������ �� �����, ������� ������� �������
            inc(max);
            StrLCopy(strForAdd, sourceStrPtr, max);
            sourceStrPtr := @(sourceStrPtr[max]);
            sourceStrPtrLen := StrLen(sourceStrPtr);

            newline := true;
            CreateDrawLine := true;
            end
          else
            begin
            //���� ��������, ���� � ��� �����, ������� ���������� � ������
            //(�� �����������, ��� �� ����������� ������)
            //�� ������ �� ���� ������!
            //�.�. � ��� ����� ������� ������ ��� ��������. ��������:
            // ChatViewChatViewChatViewChatViewChatViewChatViewChatViewChatView
            // +---------------------+  <--- ������� �������
            // |                     |
            // |ChatViewChatViewChatView  <-- ��������� �� ������
            // |                     |
            // ��������� ����� �� ���������� � ������, �� � ������� ��� �������� ���
            // ^^^^^^^^^^^^^^^^^ - ��� ���� ��� ��������!!!

            //����� ������������� ������ �����, ��� ��������, ��� ������ ���� �������
            //��� ������� ����� �� ��������� ��������� � ������:
            //����� ���������� �� ������ ���� ������� � ��� �������� ������������
            //�� ������� ���� �������. ��� ���� �� ���������, �.�. � ��� ���
            //�������� ������������. ��! ����� ���� ��� ��������� �������
            //����� ������ ���������� ����� �� ��������, �������� � ������ �������
            //� ������� ��� ��� ����� ������ ��������� ������� �� ������ ������ ������,
            //�.�. �� ��������� �� ��� ������� �� ������ ���� ������
            // +----------------------+  <--- ������� �������
            // |           __         |
            // | Chat LOL |__| ChatViewChat <-- �� ������ ����� ������� �������
            // |                      |         � �� �� ������.

            if x > 0 then max := 0;
            //��� ������ ����� �����! ���� x = 0 �� ���
            //������, ��� �� �������� ��������� ����� ������ �� � �������� �������
            //� � ������ ������, ��� ���� � ��� �� ������� �������!
            //������ � ���� ������ ������ ����� ������ �� ������. �� � ���� x > 0
            //�� � ��� ��� ��� ������ �� ������ ������� � ����� ��������� � ����
            //������� �� ����� ������!

            StrLCopy(strForAdd, sourceStrPtr, max);
            sourceStrPtr := @(sourceStrPtr[max]);
            sourceStrPtrLen := StrLen(sourceStrPtr);

            //����� ������������� ��������� ������
            newline := true;
            CreateDrawLine := true;
            end;
          end
        else
          begin
          //���� ����� ���������� �� ����� �������
          sourceStrPtr := nil;
          {s := '' + inttostr(0);
          Ondebug(s);}
          end;
        //��� �� ������� ��, ��� ����������� �� ���� �������
        //��� ��� �� �����������, ��������� ��� ��������� ������ FormatNextContainer
        //� �������������� ��������� ���� ���������
        info := TDrawContainerInfo.Create;
        info.LinkId := TContainerInfo(ContStorage.Objects[ContNum]).LinkId;
        info.ContainerNumber := ContNum;
        info.LineNum := @DrawLineInfo.LineNumber;

        baseline := PrevBaseLine + Ascent + metr.tmHeight;
        //���� ���� ������� AddCenterLine('')
        if Center then
          begin
          x := (Width - sz.cx) div 2;
          if x < 0 then x := 0;
          end;

        if (StyleNo = cvsJump1) or (StyleNo = cvsJump2) then
          begin
          jmpinfo := TJumpInfo.Create;
          jmpinfo.l := x + sad.LeftMargin;
          jmpinfo.t := baseline;
          jmpinfo.w := sz.cx;
          jmpinfo.h := sz.cy;
          jmpinfo.id := nJmps;
          jmpinfo.idx := DrawContainers.Count - 1;
          TContainerInfo(ContStorage.Objects[ContNum]).imgNo := nJmps;
          jumps.AddObject('', jmpinfo);
          inc(nJmps);
          end;


{MessageBox(0, PChar(inttostr(Ascent) + '   ' +
           inttostr(metr.tmHeight)
           ), 'Ascent � metr.tmHeight', mb_ok);}
//MessageBox(0, PChar(inttostr(BaseLine)), 'BaseLine', mb_ok);
        DrawLineInfo.BaseLine := BaseLine;

{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}

        info.Left   := x + sad.LeftMargin;
        info.Bottom    := @DrawLineInfo.BaseLine;
        info.Width  := canvas.TextWidth(strForAdd);//���� ����������� sz.cx;
        info.Height := sz.cy;
        info.pDrawLineInfo := DrawLineInfo;
        DrawContainers.AddObject(strForAdd, info);
        if DrawLineInfo.MaxHeight < info.Height then
          DrawLineInfo.MaxHeight := info.Height;

        x := x + sz.cx + 1;


{         if not newline then
           //���������� ������ ������
           begin //continue line
           if prevabove < metr.tmExternalLeading + metr.tmAscent then
             begin
             j := DrawContainers.Count-1;
             if j>=0 then
               repeat
                 inc(TDrawContainerInfo(DrawContainers.Objects[j]).Top,
                     metr.tmExternalLeading+metr.tmAscent - prevabove);
                 dec(j);
               until  TDrawContainerInfo(DrawContainers.Objects[j+1]).FromNewLine;
             inc(baseline,metr.tmExternalLeading+metr.tmAscent-prevabove);
             prevabove := metr.tmExternalLeading+metr.tmAscent;

         MessageBox(0, PChar('if j>=0 then '),
                         PChar('  TDrawContainerInfo(DrawContainers.Objects[j+1]) = ' + inttostr(j+1)
                          ) , mb_ok);

             end;
           y := baseline - metr.tmAscent;
           info.FromNewLine := False;
           end
         else
           begin // new line
           info.FromNewLine := True;
           if Center then
             x := (Width - sz.cx) div 2
           else
             x :=0;
           y := baseline + prevDesc + metr.tmExternalLeading;
           inc(baseline, prevDesc + metr.tmExternalLeading + metr.tmAscent);
           prevabove := metr.tmExternalLeading+metr.tmAscent;
           end;
         info.Left   :=x+sad.LeftMargin;;
         info.Top    := y;
         info.Width  := sz.cx;
         info.Height := sz.cy;
         DrawContainers.AddObject(strForAdd, info);

{         MessageBox(0, PChar('������� Object =' + inttostr(DrawContainers.Count) +
                      '  string=' + strForAdd),
                         PChar(
                      '  LineNum = ' + inttostr(LineNum)
                          ) , mb_ok);
}
{         if (StyleNo=cvsJump1) or (StyleNo=cvsJump2) then
           begin
           jmpinfo := TJumpInfo.Create;
           jmpinfo.l := x+sad.LeftMargin;
           jmpinfo.t := y;
           jmpinfo.w := sz.cx;
           jmpinfo.h := sz.cy;
           jmpinfo.id := nJmps;
           jmpinfo.idx := DrawContainers.Count-1;
           TContainerInfo(ContStorage.Objects[ContNum]).imgNo := nJmps;
           jumps.AddObject('',jmpinfo);
           end;
         sourceStrPtrLen := StrLen(sourceStrPtr);
         if newline or (prevDesc < metr.tmDescent) then prevDesc := metr.tmDescent;
         inc(x,sz.cx);
         newline := True;}
        end;
{       if (StyleNo=cvsJump1) or (StyleNo=cvsJump2) then inc(nJmps);}
    end;
  end;//caseend
end;

  {------------------------------------------------------------------}
{$I CV_Save.inc}
  {------------------------------------------------------------------}

end.

