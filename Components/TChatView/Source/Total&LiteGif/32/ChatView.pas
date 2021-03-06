unit ChatView;
//� ���� ����� ���������� ������� �������! BaseLine ��� ������ ����� ������
//� �������� ��� ��������� ��� BOTTOM � � ������ Paint ����� ���������� ������
//��������� �������� ������ ���� ������� ��� .Bottom^ - .Heigth
//� ������ � BreakLine ��� ��������

interface
{$I CV_Defs.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  CVStyle, CVScroll, ClipBrd, ImgList,
  litegif1, CVLiteGifAni, ExtCtrls;
  {------------------------------------------------------------------}



const
  cvVersion     = 'TChatView v0.32 by Bajenov Andrey';
  cvsBreak      = -1;
  cvsCheckPoint = -2;
  cvsPicture    = -3;
  cvsHotSpot    = -4;
  cvsComponent  = -5;
  cvsBullet     = -6;
  cvsGif        = -7;
  cvsGifAni     = -8;
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
  TDrawContainerInfo = class
  {������-���������, ������� �������� ���� � ��� � ����� ���������� X,Y
   ������� ���� ����������. ����������, � ����������� �� ������ �����
   ���� �������, GIF, Control � �.�.}
     Left, Width, Height: Integer;
     {Top ������ ������� �� TDrawLineInfo}
     Bottom, LineNum: PInteger;
     ContainerNumber, Offs: Integer;
     FromNewLine: Boolean;
     pDrawLineInfo: TDrawLineInfo;
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
  TDebugEvent = procedure (Mess: String) of object;
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
    ScrollDelta: Integer;
    ScrollTimer: TTimer;
    FAllowSelection, FSingleClick: Boolean;
    FDelimiters: String;
    DrawHover, Selection: Boolean;
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
    FSelStartNo, FSelEndNo, FSelStartOffs, FSelEndOffs: Integer;
    FGifAniObjNo : word;
    procedure InvalidateJumpRect(no: Integer);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
//    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMVScroll); message WM_HSCROLL;
//    procedure CMInvalidate(var Message: TMessage); message CM_INVALIDATE;
    function FindItemAtPos(X,Y: Integer): Integer;//���� �� ����� ������� ��������
    function FindItemAtScreenPos(X,Y: Integer): Integer;//���� �� ������������� �������
    procedure FindItemForSel(X,Y: Integer; var No, Offs: Integer);
    function GetLineCount: Integer;
    procedure SetGifAniCanvas(DestionationCanvas: TCanvas);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
    procedure StoreSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
    procedure RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
    function GetMaxHeight(Line, FromObject:integer):Integer;
    function GetMinHeight(Line, FromObject:integer):Integer;
  protected
    { Protected declarations }
    DrawContainers:TStringList;
    checkpoints: TStringList;
    jumps: TStringList;
    FStyle: TCVStyle;
    nJmps: Integer;
    TextWidth, TextHeight: Integer;
    LastJumpMovedAbove, LastContFormatted: Integer;
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
    procedure AdjustChildrenCoords;
    procedure ClearTemporal;
    function GetFirstVisibleContainer: cardinal;
    function GetLastVisibleContainer: cardinal;
    function GetLastContainerInLine(FromContainerNumber: cardinal): cardinal;
    function GetFirstContainerInLine(FromContainerNumber: cardinal): cardinal;
    procedure Format_(OnlyResized:Boolean; depth: Integer; Canvas: TCanvas; OnlyTail: Boolean);
    procedure SetBackBitmap(Value: TBitmap);
    procedure DrawBack(DC: HDC; Rect: TRect; Width,Height:Integer);
    procedure SetBackgroundStyle(Value: TBackgroundStyle);
    procedure SetVSmallStep(Value: Integer);
    function GetNextFileName(Path: String): String; virtual;
    procedure ShareLinesFrom(Source: TChatView);
    procedure OnScrollTimer(Sender: TObject);
//    procedure SetOnDebug(OnDebug: TDebugEvent);
    procedure Loaded; override;
  public
    { Public declarations }
    DrawLinesInfo:TStringList;
    ContStorage:TStringList;
    {� ���� ������ ��������� ���������� ��������� �� ��� ����������!!!!
    ���������� ��� ��������� �������, ������� ������������ �� �������� ����� ������
    ���� ��� �����, �� ������ ��������� �������, � ��������� ��������� ��
    ��������� �� ������. ���� ��� ��������, �� ������ '', � ��������� ���������
    �� ������, ���������� �������� ��������}
    DisplayOptions: TCVDisplayOptions;
    FClientTextWidth: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
    procedure Paint; override;
    procedure DefaultDebug(Mess: String);
    FUNCTION GetCanvas():TCanvas;
    procedure AddFromNewLine(s: String;StyleNo:Integer);
    procedure Add(s: String;StyleNo:Integer);
    procedure AddCenterLine(s: String;StyleNo:Integer);
    procedure AddText(s: String;StyleNo:Integer);
    procedure AddTextFromNewLine(s: String;StyleNo:Integer);
    procedure AddBreak;
    function AddCheckPoint: Integer; { returns cp # }
    function AddNamedCheckPoint(CpName: String): Integer; { returns cp # }
    function GetCheckPointY(no: Integer): Integer;
    function GetJumpPointY(no: Integer): Integer;
    procedure AddPicture(gr: TGraphic);
    procedure AddHotSpot(imgNo: Integer; lst: TImageList; fromnewline: Boolean);
    procedure AddBullet (imgNo: Integer; lst: TImageList; fromnewline: Boolean);
    procedure AddWinControl(ctrl: TWinControl; center: Boolean);
//    procedure AddControl(ctrl: TWinControl; center: Boolean);
    procedure AddGifAni(imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);

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

    procedure CopyText;
    function GetSelText: String;
    function SelectionExists: Boolean;
    procedure Deselect;
    procedure SelectAll;

    property LineCount: Integer read GetLineCount;
    property FirstVisibleContainer: cardinal read GetFirstVisibleContainer;
    property LastVisibleContainer: cardinal read GetLastVisibleContainer;
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
    property AllowSelection: Boolean read FAllowSelection write FAllowSelection;
    property SingleClick: Boolean read FSingleClick write FSingleClick;
  end;

procedure InfoAboutSaD(var sad:TScreenAndDevice; Canvas: TCanvas);

implementation
{-------------------------------------}

{procedure TChatView.CMInvalidate(var Message: TMessage);
//var n:integer;
begin
//MessageBox(0, '', PChar(Inttostr(1)), mb_ok);
//DrawFrame;
inherited;
end;}

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
//��� ���� ��� �����? ��...      
end;
{==================================================================}
constructor TChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVersion := cvVersion;
  FOnDebug := DefaultDebug;
  BufferVirtCanv := TBitmap.Create;

  FClientTextWidth := False;
  FLeftMargin    := 5;
  FRightMargin   := 5;
  FMaxTextWidth  := 0;
  FMinTextWidth  := 0;
  TextWidth      := -1;
  TextHeight     := 0;
  LastJumpMovedAbove := -1;
  FStyle         := nil;
  LastJumpDowned := -1;
  DrawLinesInfo  := TStringList.Create;
  DrawContainers := TStringList.Create;
  ContStorage    := TStringList.Create;
  checkpoints    := TStringList.Create;
  jumps          := TStringList.Create;
  FBackBitmap    := TBitmap.Create;
  FBackGroundStyle := bsNoBitmap;
  nJmps          :=0;
  FirstJumpNo    :=0;
  skipformatting := False;
  OldWidth       := 0;
  OldHeight      := 0;
  Width          := 100;
  Height         := 40;
  DisplayOptions := [cvdoImages, cvdoComponents, cvdoBullets];
  ShareContents  := False;
  FDelimiters    := ' .;,:(){}"';
  DrawHover      := False;
  FSelStartNo    := -1;
  FSelEndNo      := -1;
  FSelStartOffs  := 0;
  FSelEndOffs    := 0;
  Selection      := False;
  FAllowSelection:= True;
  LastContFormatted := -1;
  ScrollTimer    := nil;
  FGifAniObjNo   := 0;
  AddFromNewLine('', 0);
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
  DrawLinesInfo.Free;
  DrawContainers.Free;
  checkpoints.Free;
  jumps.Free;
  if not ShareContents then ContStorage.Free;
  inherited Destroy;
end;
{-------------------------------------}
procedure TChatView.WMSize(var Message: TWMSize);
begin
  Format_(True, 0, Canvas, False);
  if Assigned(FOnResized) then FOnResized(Self);
//  Paint;
end;
{-------------------------------------}
procedure TChatView.DefaultDebug(Mess: String);
begin
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
  FSelStartNo := -1;
  FSelEndNo := -1;
  FSelStartOffs := 0;
  FSelEndOffs := 0;
  if Assigned(FOnSelect) then OnSelect(Self);  
end;
{-------------------------------------}
procedure TChatView.SelectAll;
begin
  FSelStartNo := 0;
  FSelEndNo := DrawContainers.Count-1;
  FSelStartOffs := 0;
  FSelEndOffs := 0;
  if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[FSelEndNo]).ContainerNumber]).StyleNo>=0 then
    FSelEndOffs := Length(DrawContainers[FSelEndNo])+1;
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
  AddFromNewLine('', 0);
end;
{-------------------------------------}
{����� ��������� �������� �� ����������.... �� ������ ���� �� ���
procedure TChatView.SetOnDebug(OnDebug: TDebugEvent);
begin
FOnDebug := OnDebug;
end;}
{-------------------------------------}
procedure TChatView.AddFromNewLine(s: String; StyleNo:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := False;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.Add(s: String; StyleNo:Integer);
var info: TContainerInfo;
begin
//��������� ������ ������ ��� ����, �.�. #10#13
//����� ������������ �����������
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  if ContStorage.Count = 0 then
    info.SameAsPrev := false
  else
    info.SameAsPrev := true;
  info.Center := False;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddText(s: String;StyleNo:Integer);
var p: Integer;
begin
//���� � ������ ������ ���� #10#13,
//�� ���������� ������� ������ �� ��������� ������
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     if s<>'' then Add(s,StyleNo);
     exit;
   end;
   Add(Copy(s,1,p-1), StyleNo);
   Delete(s,1, p+1);
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s,StyleNo);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddTextFromNewLine(s: String;StyleNo:Integer);
var p: Integer;
begin
   s:=AdjustLineBreaks(s);
   p := Pos(chr(13)+chr(10),s);
   if p=0 then begin
     AddFromNewLine(s,StyleNo);
     exit;
   end;
   while s<>'' do begin
     p := Pos(chr(13)+chr(10),s);
     if p=0 then begin
        AddFromNewLine(s,StyleNo);
        break;
     end;
     AddFromNewLine(Copy(s,1,p-1), StyleNo);
     Delete(s,1, p+1);
   end;
end;
{-------------------------------------}
procedure TChatView.AddCenterLine(s: String;StyleNo:Integer);
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := StyleNo;
  info.SameAsPrev := False;
  info.Center := True;
  ContStorage.AddObject(s, info);
end;
{-------------------------------------}
procedure TChatView.AddBreak;
var info: TContainerInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -1;
  ContStorage.AddObject('', info);
end;
{-------------------------------------}
function TChatView.AddNamedCheckPoint(CpName: String): Integer;
var info: TContainerInfo;
    cpinfo: TCPInfo;
begin
  info := TContainerInfo.Create;
  info.StyleNo := -2;
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
procedure TChatView.AddPicture(gr: TGraphic); { gr not copied, do not free it!}
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
procedure TChatView.AddGifAni(imgNo: Integer; GifAniObject: TGifAni; fromnewline: Boolean);
var info: TContainerInfo;
//    r:TRect;
begin
//  if GifAniObject.GifImage.Count = 0 then AddGif(imgNo, GifAniObject.GifImage,fromnewline);
  GifAniObject.AddMirrorImages;
  info := TContainerInfo.Create;
  info.StyleNo := -8;
  info.gr := GifAniObject;
  if imgNo = 0 then
    begin
    info.imgNo := Length(GifAniObject.MirrorImagesX) - 1;
    end;
//  info.imgNo := imgNo;
  info.SameAsPrev := not FromNewLine;
  ContStorage.AddObject('', info);
  GifAniObject.BeginAnimate(Self.GetCanvas, Self.Style.Color);
end;
{-------------------------------------}
//procedure TChatView.AddControl(ctrl: TControl; center: Boolean); { do not free ctrl! }
procedure TChatView.AddWinControl(ctrl: TWinControl; center: Boolean); { do not free ctrl! }
var info: TContainerInfo;
begin
  ctrl.ParentWindow := Self.Handle;
  info := TContainerInfo.Create;
  info.StyleNo := -5;
  info.gr := ctrl;
//  info.SameAsPrev := false;//true;//
  info.SameAsPrev := true;
  info.Center := center;
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
procedure TChatView.AdjustChildrenCoords;
var i: Integer;
    dli: TDrawContainerInfo;
    li : TContainerInfo;
begin
  for i:=0 to DrawContainers.Count-1 do
   begin
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
   li := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]);
   if li.StyleNo = -5 then {wincontrol}
     begin
     TWinControl(li.gr).Left := dli.Left;
     TWinControl(li.gr).Tag := dli.Bottom^ - dli.Height;
     Tag2Y(TWinControl(li.gr));
     end;
   end;
end;
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
function TChatView.GetFirstContainerInLine(FromContainerNumber: cardinal): cardinal;
var n, CurrentLine: cardinal;
    dli : TDrawLineInfo;
begin
result := 0;
if FromContainerNumber > 0 then
  begin
  n := FromContainerNumber;
  CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
  while n >= 0 do
    begin
    dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
    if dli.LineNumber < CurrentLine then
      begin
      result := CurrentLine;
      break;
      end;
    n := n - 1;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetLastContainerInLine(FromContainerNumber: cardinal): cardinal;
var n, CurrentLine: cardinal;
    dli : TDrawLineInfo;
begin
//��� ��������� ������� ����� ����������, �������� � ����� ����� (������)
//�����������. �� ����� ����� ����������, �� ������ ���� ����� ���������� �
//������� ����������������� ����������� DrawContainers.
CurrentLine := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.LineNumber;
result := 0;
if FromContainerNumber > 0 then
  begin
  n := FromContainerNumber;
  while n < (DrawContainers.count - 1) do
    begin
    dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
    if dli.LineNumber < CurrentLine then
      begin
      result := CurrentLine;
      break;
      end;
    n := n - 1;
    end;
  end;
end;
{-------------------------------------}
function TChatView.GetFirstVisibleContainer: cardinal;
var n: cardinal;
    dli : TDrawLineInfo;
begin
//� ��� ���� ����� ����������������� �������� DrawContainers, ��� ����� ����������
//� ������ ������� ������ ����� �� ������. ��� ����� ��� ���� ������ ����� ������
//��������� ���� ��� VPOS
result := 0;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if dli.BaseLine > VPOS then
    begin
    result := n;
    break;
    end;
//  else
  n := n + 1;
  end;
//MessageBox(0, PChar(inttostr(DrawContainers.Count - 1)), 'DrawContainers.Count - 1', mb_ok);
FDebugText :='VPOS=' + inttostr(VPOS) + ' GetFirstVisibleContainer = ' + inttostr(result);
//self.OnDebug(FDebugText);
end;
{-------------------------------------}
function TChatView.GetLastVisibleContainer: cardinal;
var n: cardinal;
dli : TDrawLineInfo;
begin
//���� ���� ����� ��������� ��������� ���������� � VPOS + Y ������ �������, ��
result := DrawContainers.Count - 1;
n := 0;
while n <= DrawContainers.Count - 1 do
  begin
  dli := TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo;
  if (dli.BaseLine - TDrawContainerInfo(DrawContainers.Objects[n]).pDrawLineInfo.MaxHeight) > (VPOS + self.Canvas.ClipRect.BottomRight.y {* 2}) then
    begin
    result := n - 1;
    break;
    end;
  n := n + 1;
  end;
end;
{----------------------------------------------------}
procedure TChatView.InvalidateJumpRect(no: Integer);
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
         rec.Left := l - Hpos - 5;
         rec.Top  := t - VPos * VScrollStep - 5;
         rec.Right := l + w - Hpos + 5;
         rec.Bottom := t + h - VPos * VScrollStep + 5;
         InvalidateRect(Handle, @rec, False);
       end;
   end;
   Update;
end;
  {------------------------------------------------------------------}
procedure TChatView.CMMouseLeave(var Message: TMessage);
begin
   if DrawHover and (LastJumpMovedAbove<>-1) then begin
     DrawHover := False;
     InvalidateJumpRect(LastJumpMovedAbove);
   end;
   if Assigned(FOnCVMouseMove) and
      (LastJumpMovedAbove<>-1) then begin
      LastJumpMovedAbove := -1;
      OnCVMouseMove(Self,-1);
   end;
end;
  {------------------------------------------------------------------}
procedure TChatView.MouseMove(Shift: TShiftState; X, Y: Integer);
var i, no, offs,ys: Integer;
begin
    ScrollDelta := 0;
    if Y<0 then ScrollDelta := -1;
    if Y<-20 then ScrollDelta := -10;
    if Y>ClientHeight then ScrollDelta := 1;
    if Y>ClientHeight+20 then ScrollDelta := 10;
    inherited MouseMove(Shift, X, Y);
    if Selection then
      begin
      XMouse := x;
      YMouse := y;
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(X + HPos, ys + VPos * VScrollStep, no, offs);
      FSelEndNo   := no;
      FselEndOffs    := offs;
      Invalidate;
      end;
    for i:=0 to jumps.Count-1 do
      begin
      if (X>=TJumpInfo(jumps.objects[i]).l-HPos) and
         (X<=TJumpInfo(jumps.objects[i]).l+TJumpInfo(jumps.objects[i]).w-HPos) and
         (Y>=TJumpInfo(jumps.objects[i]).t - VPos * VScrollStep) and
         (Y<=TJumpInfo(jumps.objects[i]).t + TJumpInfo(jumps.objects[i]).h - VPos * VScrollStep) then
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

FDebugText := 'DrawContainer = ' + inttostr(FindItemAtScreenPos(x, y));
self.OnDebug(FDebugText);
end;
{-------------------------------------}
procedure TChatView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i, StyleNo, no, offs, ys: Integer;
    clickedword: String;
    p: TPoint;
begin
    if ScrollTimer<> nil then begin
      ScrollTimer.Free;
      ScrollTimer := nil;
    end;
    XClicked := X;
    YClicked := Y;
    if Selection and (Button = mbLeft) then begin
      ys := y;
      if ys<0 then y:=0;
      if ys>ClientHeight then ys:=ClientHeight;
      FindItemForSel(XClicked + HPos, ys + VPos * VScrollStep, no, offs);
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
         (X>=l-HPos) and
         (X<=l+w-HPos) and
         (Y >= t - VPos * VScrollStep) and
         (Y <= t + h - VPos * VScrollStep) then
          begin
            OnJump(Self,id+FirstJumpNo);
            break;
          end;
    LastJumpDowned:=-1;

    inherited MouseUp(Button, Shift, X, Y);
end;
{-------------------------------------}
procedure TChatView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i,no, StyleNo: Integer;
    clickedword: String;

   n, yshift, xshift: Integer;
   dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
    lastline: Boolean;
begin
  if Button <> mbLeft then exit;
  XClicked := X;
  YClicked := Y;
  //if Assigned(FOnJump) then begin
    LastJumpDowned := -1;
    for i:=0 to jumps.Count-1 do
     with jumps.objects[i] as TJumpInfo do
      if (X>=l-HPos) and
         (X<=l+w-HPos) and
         (Y >= t - VPos * VScrollStep) and
         (Y <= t + h - VPos * VScrollStep) then
           begin
             LastJumpDowned := id;
             break;
           end;
    if AllowSelection then
      begin
      FindItemForSel(XClicked + HPos, YClicked + VPos * VScrollStep, no, FSelStartOffs);
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

    inherited MouseDown(Button, Shift, X, Y);
end;
{-------------------------------------}
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
           AddPicture(gr);
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
               AddCenterLine(Source.ContStorage[i], li.StyleNo)
          else
             if li.SameAsPrev then
                Add(Source.ContStorage[i], li.StyleNo)
             else
                AddFromNewLine(Source.ContStorage[i], li.StyleNo)
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
       for i := (Rect.Top + VPos * VScrollStep) div FBackBitmap.Height to
               (Rect.Bottom + VPos * VScrollStep) div FBackBitmap.Height do
         for j := (Rect.Left+HPos) div FBackBitmap.Width to
                  (Rect.Right+HPos) div FBackBitmap.Width do
           BitBlt(DC, j*FBackBitmap.Width-HPos-Rect.Left,i*FBackBitmap.Height-VPos*VScrollStep-Rect.Top, FBackBitmap.Width,
                  FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
   end
end;
{-------------------------------------}
procedure TChatView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var r1: TRect;
begin
  if (csDesigning in ComponentState) then exit;
  Message.Result := 1;
  if (OldWidth<ClientWidth) or (OldHeight<ClientHeight) then begin
      GetClipBox(Message.DC, r1);
      DrawBack(Message.DC, r1, ClientWidth, ClientHeight);
  end;
  OldWidth := ClientWidth;
  OldHeight := ClientHeight;
end;
{-------------------------------------}
procedure TChatView.SetVSmallStep(Value: Integer);
begin
   if (Value<=0) or (TextHeight div Value > 30000) then exit;
   VScrollStep := Value;
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
function TChatView.FindItemAtScreenPos(X,Y: Integer): Integer;
begin
result := FindItemAtPos(X + HPos,Y + VPos);
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
{------------------------------------------------------------------}
procedure TChatView.FindItemForSel(X,Y: Integer; var No, Offs: Integer);
var
    styleno,i, a,b,mid, midtop, midbottom, midleft, midright, beginline, endline: Integer;
    dli: TDrawContainerInfo;
    arr: array[0..1000] of integer;
    sz: TSIZE;
begin
  if DrawContainers.Count = 0 then
    begin
    No := -1;
    exit;
    end;
  dli := TDrawContainerInfo(DrawContainers.Objects[0]);
//  if (dli.Top^ <=Y) and (dli.Top^ +dli.Height>Y) and
//     (dli.Left<=X) and (dli.Left+dli.Width>X) then begin
  if (dli.Bottom^ - dli.Height <=Y) and (dli.Bottom^ > Y) and
     (dli.Left <= X) and (dli.Left + dli.Width > X) then
     mid := 0
  else begin
    a := 1;
    b := DrawContainers.Count-1;
    while (b-a)>1 do begin
      mid := (a+b) div 2;
//      if (TDrawContainerInfo(DrawContainers.Objects[mid]).top^ <=Y) then
      if (TDrawContainerInfo(DrawContainers.Objects[mid]).Bottom^ -
          TDrawContainerInfo(DrawContainers.Objects[mid]).Height) <=Y then
        a := mid
      else
        b := mid;
    end;
    mid := a;
//    if TDrawContainerInfo(DrawContainers.Objects[b]).top^ <=Y then mid := b;
    if TDrawContainerInfo(DrawContainers.Objects[b]).Bottom^ -
       TDrawContainerInfo(DrawContainers.Objects[b]).Height <=Y then mid := b;
  end;
//  midtop := TDrawContainerInfo(DrawContainers.Objects[mid]).top^;
  midtop := TDrawContainerInfo(DrawContainers.Objects[mid]).Bottom^ -
            TDrawContainerInfo(DrawContainers.Objects[mid]).Height;
  midbottom := midtop + TDrawContainerInfo(DrawContainers.Objects[mid]).Height;
  // searching beginning of line "mid" belong to
  beginline := mid;
  while (beginline>=1) and
//         (TDrawContainerInfo(DrawContainers.Objects[beginline-1]).top^ +
//         TDrawContainerInfo(DrawContainers.Objects[beginline-1]).Height>midtop) do dec(beginline);
         (TDrawContainerInfo(DrawContainers.Objects[beginline-1]).Bottom^ > midtop) do dec(beginline);
  // searching end of line "mid" belong to
  endline := mid;
  while (endline < DrawContainers.Count-1) and
//         (TDrawContainerInfo(DrawContainers.Objects[endline+1]).top^ < midbottom) do inc(endline);
         (TDrawContainerInfo(DrawContainers.Objects[endline+1]).Bottom^ -
          TDrawContainerInfo(DrawContainers.Objects[endline+1]).Height < midbottom) do inc(endline);
  // calculating line bounds
  midleft := TDrawContainerInfo(DrawContainers.Objects[mid]).Left;
  midright := midleft+TDrawContainerInfo(DrawContainers.Objects[mid]).Width;
  for i:= beginline to endline do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
//    if dli.top^  < midtop then midtop := dli.top^ ;
    if dli.Bottom^ - dli.Height < midtop then midtop := dli.Bottom^ - dli.Height ;
//    if dli.top^ + dli.Height > midbottom then midbottom := dli.top^ + dli.Height;
    if dli.Bottom^ > midbottom then midbottom := dli.Bottom^;
    if dli.Left < midleft then midleft := dli.Left;
    if dli.Left + dli.Width > midright then midright := dli.Left + dli.Width;
  end;
  if (Y<midtop) or (X<midleft) then begin
  {
     No := beginline-1;
     if No<0 then begin
       No := 0;
       Offs := 1;
       end
     else begin
       if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).LineNo]).StyleNo<0 then
         Offs := 2
       else
         Offs := Length(DrawContainers[No])+1;
     end;
     exit;
  }
     No := beginline;
     if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).ContainerNumber]).StyleNo<0 then
         Offs := 0
       else
         Offs := 1;
     exit;
  end;
  if (Y>midbottom) or (X>midright) then begin
     No := endline+1;
     Offs := 1;
     if No>=DrawContainers.Count then begin
       No := DrawContainers.Count-1;
       Offs := Length(DrawContainers[No])+1;
       end
     else begin
       if TContainerInfo(ContStorage.Objects[TDrawContainerInfo(DrawContainers.Objects[No]).ContainerNumber]).StyleNo<0 then
         Offs := 0;
     end;
     exit;
  end;
  for i:= beginline to endline do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
    if (dli.Left<=X) and (dli.Left+dli.Width>=X) then begin
      styleno := TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo;
      No := i;
      Offs := 0;
      if styleno>=0 then begin
        with FStyle.TextStyles[StyleNo] do begin
         Canvas.Font.Style := Style;
         Canvas.Font.Size  := Size;
         Canvas.Font.Name  := FontName;
         Canvas.Font.CharSet  := CharSet;
       end;
       GetTextExtentExPoint(Canvas.Handle,  PChar(DrawContainers[i]),  Length(DrawContainers[i]),
                            X-dli.Left,
                            @Offs, nil,
//                            Offs, arr[0],
                             sz);
       inc(Offs);
       if Offs>Length(DrawContainers[i]) then Offs := Length(DrawContainers[i]);
       if (Offs < 1) and (Length(DrawContainers[i])>0) then Offs := 1;
       end
      else
       Offs := 1;
    end;
  end;
end;
  {------------------------------------------------------------------}
function TChatView.FindClickedWord(var clickedword: String; var StyleNo: Integer): Boolean;
var no, lno: Integer;
    arr: array[0..1000] of integer;
    sz: TSIZE;
    max,first,len: Integer;
begin
  FindClickedWord := False;
  no := FindItemAtPos(XClicked+HPos, YClicked+VPos*VScrollStep);
  if no<>-1 then begin
     lno := TDrawContainerInfo(DrawContainers.Objects[no]).ContainerNumber;
     clickedword := DrawContainers[no];
     styleno := TContainerInfo(ContStorage.Objects[lno]).StyleNo;
     if styleno>=0 then begin
        with FStyle.TextStyles[StyleNo] do begin
         Canvas.Font.Style := Style;
         Canvas.Font.Size  := Size;
         Canvas.Font.Name  := FontName;
         Canvas.Font.CharSet  := CharSet;
       end;
       GetTextExtentExPoint(Canvas.Handle,  PChar(clickedword),  Length(clickedword),
                            XClicked+HPos-TDrawContainerInfo(DrawContainers.Objects[no]).Left,
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
procedure TChatView.GetSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
begin
   if FSelStartNo <= FSelEndNo then begin
     StartNo := FSelStartNo;
     EndNo   := FSelEndNo;
     if not ((StartNo=EndNo) and (FSelStartOffs>FSelEndOffs)) then begin
         StartOffs := FSelStartOffs;
         EndOffs   := FSelEndOffs;
       end
     else begin
         StartOffs := FSelEndOffs;
         EndOffs   := FSelStartOffs;
       end;
     end
   else begin
     StartNo := FSelEndNo;
     EndNo   := FSelStartNo;
     StartOffs := FSelEndOffs;
     EndOffs   := FSelStartOffs;
   end;
end;
  {------------------------------------------------------------------}
procedure TChatView.StoreSelBounds(var StartNo, EndNo, StartOffs, EndOffs: Integer);
var dli: TDrawContainerInfo;
begin
  GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  if StartNo<>-1 then begin
    dli := TDrawContainerInfo(DrawContainers.Objects[StartNo]);
    if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo>=0 then
        inc(StartOffs, dli.Offs-1);
    StartNo := dli.ContainerNumber;
    dli := TDrawContainerInfo(DrawContainers.Objects[EndNo]);
    if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo>=0 then
        inc(EndOffs, dli.Offs-1);
    EndNo := dli.ContainerNumber;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs: Integer);
var i: Integer;
    dli, dli2, dli3: TDrawContainerInfo;
begin
  if StartNo = -1 then exit;
  for i :=0 to DrawContainers.Count-1 do begin
    dli := TDrawContainerInfo(DrawContainers.Objects[i]);
    if dli.ContainerNumber = StartNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelStartNo := i;
        FSelStartOffs := StartOffs;
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
          FSelStartNo := i;
          FSelStartOffs := StartOffs-dli.Offs+1;
          if FSelStartOffs<0 then FSelStartOffs := 0;
          if FSelStartOffs>dli.Offs+Length(DrawContainers[i]) then FSelStartOffs := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
    if dli.ContainerNumber = EndNo then
      if TContainerInfo(ContStorage.Objects[dli.ContainerNumber]).StyleNo<0 then begin
        FSelEndNo := i;
        FSelEndOffs := EndOffs;
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
          FSelEndNo := i;
          FSelEndOffs := EndOffs-dli.Offs+1;
          if FSelEndOffs<0 then FSelEndOffs := 0;
          if FSelEndOffs>dli.Offs+Length(DrawContainers[i]) then FSelEndOffs := dli.Offs+Length(DrawContainers[i]);
        end;
      end;
  end;
end;
  {------------------------------------------------------------------}
function TChatView.GetLineCount: Integer;
begin
  GetLineCount := ContStorage.Count;
end;
  {------------------------------------------------------------------}
function TChatView.SelectionExists: Boolean;
var StartNo, EndNo, StartOffs, EndOffs: Integer;
begin
  GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  if (StartNo = -1) or (EndNo = -1) or ((StartNo=EndNo) and (StartOffs=EndOffs)) then
    Result := False
  else
    Result := True;
end;
  {------------------------------------------------------------------}
function TChatView.GetSelText: String;
var StartNo, EndNo, StartOffs, EndOffs, i: Integer;
    s : String;
    li : TContainerInfo;
begin
  Result := '';
  if not SelectionExists then exit;
  { getting selection as ContStorage indices }
  StoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);
  if StartNo = EndNo then begin
    li := TContainerInfo(ContStorage.Objects[StartNo]);
    if li.StyleNo < 0 then exit;
    Result := Copy(ContStorage[StartNo], StartOffs, EndOffs-StartOffs);
    exit;
    end
  else begin
    li := TContainerInfo(ContStorage.Objects[StartNo]);
    if li.StyleNo < 0 then
      s := ''
    else
      s := Copy(ContStorage[StartNo], StartOffs, Length(ContStorage[StartNo]));
    for i := StartNo+1 to EndNo do begin
      li := TContainerInfo(ContStorage.Objects[i]);
      if (li.StyleNo<>cvsCheckpoint) and not li.SameAsPrev then
          s := s+chr(13);
      if li.StyleNo >= 0 then
        if i<>EndNo then
          s := s + ContStorage[i]
        else
          s := s + Copy(ContStorage[i], 1, EndOffs-1);
    end;
    Result := AdjustLineBreaks(s);
    exit;
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.CopyText;
begin
  if SelectionExists then begin
    ClipBoard.Clear;
    Clipboard.SetTextBuf(PChar(GetSelText));
  end;
end;
  {------------------------------------------------------------------}
procedure TChatView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SelectionExists and (ssCtrl in Shift) then begin
    if (Key = ord('C')) or (Key = VK_INSERT) then CopyText;
    end
  else
    inherited KeyDown(Key,Shift)
end;
  {------------------------------------------------------------------}
procedure TChatView.OnScrollTimer(Sender: TObject);
begin
  if ScrollDelta<>0 then begin
    VScrollPos := VScrollPos+ScrollDelta;
    MouseMove([], XMouse, YMouse);
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
//  SetGifAniCanvas(BufferVirtCanv.Canvas);
//  SetGifAniCanvas(Canvas);
//FDebugText := 'TChatView.Click';
//self.OnDebug(FDebugText);
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
    r :TRect;
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
{-------------------------------------}
{procedure TChatView.WMVScroll(var Message: TWMVScroll);
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//��� ���� ��� ���:
//��� ������������� �� ���������� �-��� Paint, ��-�� �� ���������� ����������
//������� GifAni. ���������� ����������� ��������� � ��������� ����������.
inherited;
SetGifAniCanvas(self.Canvas);
end;}
procedure TChatView.WMHScroll(var Message: TWMVScroll);
//��������������!!!!
//��������! ��������� HPos!!!
var i : Integer;
    dli:TDrawContainerInfo;
    li: TContainerInfo;
    r :TRect;
begin
//��� ���� ��� ���:
//��� ������������� �� ���������� �-��� Paint, ��-�� �� ���������� ����������
//������� GifAni. ���������� ����������� ��������� � ��������� ����������.
inherited;
Invalidate;
//SetGifAniCanvas(self.Canvas);
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
    StartNo, EndNo, StartOffs, EndOffs: Integer;
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

 GetSelBounds(StartNo, EndNo, StartOffs, EndOffs);
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
 yshift := VPos{ * VScrollStep};
 r.Top := r.Top + yshift;
 r.Bottom := r.Bottom + yshift;
 yshift := yshift + Canvas.ClipRect.Top;
 xshift := HPos + Canvas.ClipRect.Left;
 canv.Brush.Style := bsClear;

//FDebugText := 'r.Top  = ' + inttostr(r.TopLeft.y) +
//              'r.Bottom = ' + inttostr(r.BottomRight.y);
//self.OnDebug(FDebugText);


//�������� ����������� ���������!!!!!!!!
//� �������� ���������� ���������� 1 ������ �� r. ������ ����!!!!
FirstVisible := GetFirstVisibleContainer;
LastVisible := GetLastVisibleContainer;
 for i := FirstVisible to LastVisible do
   begin
   //� i � ����� �������������� ������ �����, ������� �� ������
   //DrawContainers - ��� ������ �����, ������� ����� �� ������ ���� TStringList
   dli := TDrawContainerInfo(DrawContainers.Objects[i]);
   if (lastline = True) and (dli.Left <= TDrawContainerInfo(DrawContainers.Objects[i-1]).left) then break;
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
     if (StartNo > i) or (EndNo < i) then
       begin
       canv.Font.Color := textcolor;
       //���� ����� ��������� ������ �����
       //canv.TextOut(dli.Left - xshift, dli.Top - yshift, DrawContainers.Strings[i])
       canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
       end
     else
       begin
       if ((StartNo<i) and (EndNo>i)) or
          ((StartNo=i) and (EndNo<>i) and (StartOffs<=1)) or
          ((StartNo<>i) and (EndNo=i) and (EndOffs>Length(DrawContainers.Strings[i]))) then
         begin
         canv.Brush.Style := bsSolid;
         canv.Brush.Color := FStyle.SelColor;
         if not hovernow then canv.Font.Color := FStyle.SelTextColor;
         //canv.TextOut(dli.Left-xshift, dli.top^ - yshift, DrawContainers.Strings[i]);
         canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, DrawContainers.Strings[i]);
         canv.Brush.Style := bsClear;
         end
       else
         begin
         if (StartNo=i) then
           begin
           canv.Font.Color := textcolor;
           s := Copy(DrawContainers.Strings[i], 1, StartOffs-1);
//           canv.TextOut(dli.Left-xshift, dli.Top^ - yshift, s);
           canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
           canv.Brush.Style := bsSolid;
           canv.Brush.Color := FStyle.SelColor;
           if not hovernow then canv.Font.Color := FStyle.SelTextColor;
           if (i<>EndNo) or (EndOffs>Length(DrawContainers[i])) then
             begin
//             canv.TextOut(dli.Left-xshift+canv.TextWidth(s), dli.top^ - yshift,
//                          Copy(DrawContainers.Strings[i], StartOffs,
//                          Length(DrawContainers.Strings[i])));
             canv.TextOut(dli.Left - xshift + canv.TextWidth(s), dli.Bottom^ - dli.Height - yshift,
                          Copy(DrawContainers.Strings[i], StartOffs,
                          Length(DrawContainers.Strings[i])));
             canv.Brush.Style := bsClear;
             end
           else
             begin
             s1 := Copy(DrawContainers.Strings[i], StartOffs, EndOffs-StartOffs);
//             canv.TextOut(dli.Left-xshift+canv.TextWidth(s), dli.Bottom^ - yshift, s1);
             canv.TextOut(dli.Left - xshift + canv.TextWidth(s), dli.Bottom^ - dli.Height - yshift, s1);
             canv.Font.Color := textcolor;
             canv.Brush.Style := bsClear;
//             canv.TextOut(dli.Left - xshift + canv.TextWidth(s + s1), dli.Bottom^ - yshift,
             canv.TextOut(dli.Left - xshift + canv.TextWidth(s + s1), dli.Bottom^ - dli.Height - yshift,
             Copy(DrawContainers.Strings[i], EndOffs, Length(DrawContainers[i])));
             end;
           end
         else
           begin
           if (EndNo=i) then
             begin
             s := Copy(DrawContainers.Strings[i], 1, EndOffs-1);
             canv.Brush.Style := bsSolid;
             canv.Brush.Color := FStyle.SelColor;
             if not hovernow then canv.Font.Color := FStyle.SelTextColor;
//             canv.TextOut(dli.Left-xshift, dli.top^ - yshift, s);
             canv.TextOut(dli.Left - xshift, dli.Bottom^ - dli.Height - yshift, s);
             canv.Brush.Style := bsClear;
             canv.Font.Color := textcolor;
//             canv.TextOut(dli.Left-xshift+canv.TextWidth(s), dli.top^ - yshift,
//                          Copy(DrawContainers.Strings[i], EndOffs,
//                          Length(DrawContainers.Strings[i])));
             canv.TextOut(dli.Left-xshift+canv.TextWidth(s), dli.Bottom^ - dli.Height - yshift,
                          Copy(DrawContainers.Strings[i], EndOffs,
                          Length(DrawContainers.Strings[i])));
             end;
           end;
         end;
       end;
       continue;
     end;
{===============================================================================}
   if (no = -8)  then // gifanimate
     begin
     //���� ���
//     TGifAni(li.gr).MirrorImagesY[li.imgNo] := dli.Bottom^ - dli.Height - yshift;
     //� ������ ��� ���... ������ ����� �� ��������, ���� ��������
     //��� �������� �� ����� ������ ����� :-)
     TGifAni(li.gr).MirrorImagesY[li.imgNo] := dli.Bottom^ - dli.Height - VPos {* VScrollStep};
     TGifAni(li.gr).MirrorImagesX[li.imgNo] := dli.Left - HPos;
     TGifAni(li.gr).DestCanvas := canv;
     TGifAni(li.gr).DrawFrame(li.imgNo, xshift - HPos, dli.Bottom^ - dli.Height - yshift);
     end;
{===============================================================================}
   if (no = -7)  then // gif }
     begin
     end;
{===============================================================================}
   if (no = -5)  then // WinControl
     begin
     //������, �� �� ������� � ������ �������� ����, � ��� ���� ������� ����� ��
     //������ ��������
     TWinControl(li.gr).Top := dli.Bottom^ - dli.Height - VPos {* VScrollStep};
     TWinControl(li.gr).Left := dli.Left - HPos;

     FDebugText2 := FDebugText + #10#13 +
                   'paint: TWinControl(li.gr).Top =' + Inttostr(TWinControl(li.gr).Top) + #10#13 +
                   'paint: TWinControl(li.gr).Left =' + Inttostr(TWinControl(li.gr).Left);
     self.OnDebug(FDebugText2);
     end;
{===============================================================================}
   if (no = -4) or (no = -6)  then
     begin // hotspots and bullets
     if (StartNo<=i) and (EndNo>=i) and
        not ((EndNo=i) and (EndOffs=0)) and
        not ((StartNo=i) and (StartOffs=2)) then
       begin
       TImageList(li.gr).BlendColor := FStyle.SelColor;
       TImageList(li.gr).DrawingStyle := dsSelected;
     end;
//     TImageList(li.gr).Draw(canv, dli.Left-xshift, dli.top^ -yshift, li.imgNo);
     TImageList(li.gr).Draw(canv, dli.Left - xshift - HPos, dli.Bottom^ - dli.Height - yshift, li.imgNo);
     TImageList(li.gr).DrawingStyle := dsNormal;
     continue;
   end;
{===============================================================================}
   if (no = -3)  then
     begin // graphics
     canv.Draw(dli.Left - xshift - HPos, dli.Bottom^  - yshift, TGraphic(li.gr));
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
var i, j, Ycorrectirovka: Integer;
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
begin
   if VScrollStep = 0 then exit;
   if (csDesigning in ComponentState) or
      not Assigned(FStyle) or
      skipformatting or
      (depth>1)
      then exit;
   skipformatting := True;

   if depth = 0 then StoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);

//   OldY := self.VPos {* self.VScrollStep};
   OldY := self.VPos {- self.VScrollStep};

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
       StartContainer := self.LastContFormatted + 1;
       MessageBox(0, Pchar(inttostr(StartContainer)),
                   'LastContFormatted + 1', mb_ok);
       MessageBox(0, Pchar(inttostr(ContStorage.Count - 1)),
                   'ContStorage.Count - 1', mb_ok);
       b:= self.TextHeight;
       end
     else
       begin
       StartContainer := 0;
       b := 0;
       ClearTemporal;
       end;
     x := 0;
     d := 0;
     a := 0;
     line := 0;
     LineInfo := nil;

     InfoAboutSaD(sad, Canvas);
     sad.LeftMargin := MulDiv(self.FLeftMargin,  sad.ppixDevice, sad.ppixScreen);

     pPartStr := nil;
     if DrawLinesInfo.Count > 0 then
       begin
       for i := 0 to DrawLinesInfo.Count - 1 do
         begin
         TDrawLineInfo(DrawLinesInfo.Objects[i]).Free;
         end;
       DrawLinesInfo.clear;
       end;
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
     LastContFormatted := ContStorage.Count - 1;
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
     AdjustChildrenCoords;
     //��� �������������� ���������� ���� ������ ������� �������������� ���������
     SetHPos(0);
     end;
   cw := ClientWidth;
   ch := ClientHeight;
   UpdateScrollBars(mx + FLeftMargin + FRightMargin, TextHeight {div VScrollStep});
   if (cw<>ClientWidth) or (ch<>ClientHeight) then
     begin
     skipformatting := False;
     ScrollTo(OldY);
     Format_(OnlyResized, depth + 1, Canvas, False);
     end;
   if OnlyResized then ScrollTo(OldY);
   if OnlyTail then ScrollTo(TextHeight);
   if depth = 0 then RestoreSelBounds(StartNo, EndNo, StartOffs, EndOffs);
   skipformatting := False;
//   LastContFormatted := ContStorage.Count - 1;
end;
{------------------------------------------------------------------}
procedure TChatView.FormatNextContainer(var DrawLineInfo:TDrawLineInfo;
                                  var LineNum, ContNum, x, baseline, Ascent:Integer;
                                  var sourceStrPtr:PChar;
                                  var newline{, CreateDrawLine}:boolean;
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
    max,j, y, ctrlw, ctrlh : Integer;
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
    width, y5, Offs : Integer;
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
//      DrawLineInfo.BaseLine := baseline;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      inc(LineNum);
      NewLine := true;
      CreateDrawLine := False;
//      MessageBox(0, Pchar(inttostr(0)), 'DrawLineInfo <> nil', mb_ok);
      end
    else
      begin
      //DrawLineInfo ��������� �������
      DrawLineInfo := TDrawLineInfo.Create;
      DrawLineInfo.LineNumber := LineNum;
//      DrawLineInfo.BaseLine := baseline;
      DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
      inc(LineNum);
      PrevBaseLine := 0;
      NewLine := true;
      CreateDrawLine := False;
//      MessageBox(0, Pchar(inttostr(0)), 'DrawLineInfo = nil', mb_ok);
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
           inc(LineNum);
           x := sad.LeftMargin;//������
           PrevBaseLine := TDrawLineInfo(DrawLinesInfo.Objects[DrawLinesInfo.Count - 1]).BaseLine;
           DrawLineInfo := TDrawLineInfo.Create;
           DrawLineInfo.LineNumber := LineNum;
           DrawLineInfo.MaxHeight := info.Height;
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
//           info.LineNum := @DrawLineInfo.LineNumber;
{s := 'ContNum = ' + inttostr(ContNum) +
     '   info.Height = ' + inttostr(info.Height) +
     '   baseline = ' + inttostr(baseline);
Ondebug(s);}
           end
         else
           begin
           //���������� ������ ������
           x := x + 1 + sad.LeftMargin;
//           info.LineNum := @DrawLineInfo.LineNumber;
           if DrawLineInfo.MaxHeight < info.Height then
             DrawLineInfo.MaxHeight := info.Height;
           end;
         end;
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('', info);
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
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
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
       info.Width  := ctrlw;

       info.Height := ctrlh + 1;
       info.LineNum     := @DrawLineInfo.LineNumber;
       info.pDrawLineInfo := DrawLineInfo;
       //��������� ����� �������� �� ������v ���������� (��������� �� ������???)

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
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
           info.LineNum := @DrawLineInfo.LineNumber;
           inc(LineNum);
//s := 'ContNum = ' + inttostr(ContNum) +
//     '   info.Height = ' + inttostr(info.Height) +
//     '   baseline = ' + inttostr(baseline);
//Ondebug(s);
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
       info.Left   := x;
       info.Bottom := @DrawLineInfo.BaseLine;
       info.ContainerNumber := ContNum;
       info.pDrawLineInfo := DrawLineInfo;
       DrawContainers.AddObject('', info);
       TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top := info.Bottom^;
       TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Left := x;

s := {'TControl(TContainerInfo(ContStorage}'.Objects[' +
     inttostr(ContNum) +
//     ']).gr).Top =' + inttostr(info.Bottom^);
     ']).gr).Top =' + inttostr(TWinControl(TContainerInfo(ContStorage.Objects[ContNum]).gr).Top);
Ondebug(s);

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
           DrawLinesInfo.AddObject(inttostr(LineNum), DrawLineInfo);
           baseline := PrevBaseLine + Ascent + info.Height;
           DrawLineInfo.BaseLine := baseline;
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
        {$IFDEF ChatViewDEF3}
        Canvas.Font.CharSet  := CharSet;
        {$ENDIF}
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
        GetTextExtentExPoint(Canvas.Handle,  sourceStrPtr,  sourceStrPtrLen, Width - x,
                               {$IFDEF ChatViewDEF4}
                                 @max, nil,//� D5 ����������� ��� ������
                               {$ELSE}
                                 max, arr[0],
                               {$ENDIF}
                             sz);
        //�-��� ���������� � max ���������� ��������, ������������ �� ����� �������


        //�������� ��� ���������� �������� � strForAdd
        StrLCopy(strForAdd, sourceStrPtr, max);

        if max = 0 then max := 1;//�������� � �������������, ���� ������ �� ����������

        if max < sourceStrPtrLen then
        //���� max ������, ��� ����� ������ (�.�. ����� �� ���������� �� ����� �������)
          begin
          //������� �������� � ���� ����� ��������� ��������� ������
          strSpacePos := StrRScan(strForAdd, ' ');
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
            // |ChatViewChatViewChatV
            // |                     |
            // ��������� ����� �� ���������� � ������, �� � ������� ��� �������� ���

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
        info.Width  := sz.cx;
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

