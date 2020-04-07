unit uFormAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, sSkinProvider, ShellApi,
  ChatView, sChatView, cvStyle, CVScroll, litegifX2;

type
  TFormAbout = class(TPersistent)
  protected
    FFormAbout     :TForm;
    FChatView      :TsChatView;
    FCVStyle       :TCVStyle;
    FTimer         :TTimer;
    FSkinProvider  :TsSkinProvider;
  private
    { Private declarations }
  public
    { Public declarations }
    SmilesGIFImages                     :array of TGif;
    property FormAbout	        	      :TForm read FFormAbout write FFormAbout;
    property ChatLineView		            :TsChatView read FChatView write FChatView;
    property CVStyle		                :TCVStyle read FCVStyle write FCVStyle;
    property Timer		                  :TTimer read FTimer write FTimer;
    property SkinProvider               :TsSkinProvider read FSkinProvider write FSkinProvider;
    constructor Create(ownForm:TForm; DfmPath, GifPath: string);
    destructor Destroy;override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringToComponent(Component: TComponent; Value: string);
    procedure Timer1Timer(Sender: TObject);
    procedure OnLinkMouseMoveProcessing(SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��������� ����� �� ��v���
    procedure OnLinkMouseDownProcessing(Button: TMouseButton; X, Y: Integer; SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��������� ����� �� ��v���
  end;

const br: String = ' ' + chr(13) + chr(10);
      NORMALTEXTSTYLE = 0;
      REDTEXTSTYLE = 1;
      BLACKTEXTSTYLE = 2;
      LINKTEXTSTYLE = 3;
      ONLINKTEXTSTYLE = 4;

implementation

uses uFormMain;

constructor TFormAbout.Create(ownForm:TForm; DfmPath, GifPath: string);
var Canvas: TCanvas;
    n: integer;
    strlist: TStringList;
//    Link: String;
    MS: TMemoryStream;
    LinkText, OverLinkText: TFontInfo;
begin
//inherited Create(ownForm);
inherited Create();

strlist := TStringList.Create;
{������� TFormPopUp}

FFormAbout := TForm.Create(nil);
  FFormAbout.Name := 'FormAbout';
  //  Self.parent := ownForm;
  strlist.LoadFromFile(DfmPath + 'FormAbout.txt');
  self.StringToComponent(FFormAbout, strlist.text);
  FFormAbout.ParentWindow := 0;
  FFormAbout.parent := nil;//
  FFormAbout.OnClose := FormClose;
{/������� ChatLineView}

{������� CVStyle}
FCVStyle := TCVStyle.Create(FFormAbout);
  FCVStyle.Name := 'CVStyle';
//  FCVStyle.parent := FFormAbout;
//  FCVStyle.ParentWindow := FFormAbout.Handle;
  strlist.LoadFromFile(DfmPath + 'FormAboutStyle.txt');
  self.StringToComponent(FCVStyle, strlist.text);
{/������� CVStyle}

{������� SkinProvider}
FSkinProvider := TsSkinProvider.Create(FFormAbout);
  FSkinProvider.Form := FFormAbout;
  FSkinProvider.PrepareForm;
{/������� SkinProvider}

{������� ChatLineView}
FChatView := TsChatView.Create(FFormAbout);
  FChatView.Name := 'ChatView';
  FChatView.parent := FFormAbout;
  FChatView.ParentWindow := FFormAbout.Handle;
  FChatView.Style := self.FCVStyle;//��� ����!
  strlist.LoadFromFile(DfmPath + 'FormAboutCV.txt');
  self.StringToComponent(FChatView, strlist.text);
  FChatView.Style := self.FCVStyle;//��� ����!
  FChatView.CursorSelection := false;
//  ChatLineView.OnVScrolled := OnVScrolled;
//  ChatLineView.OnMouseDown := ChatLineViewMouseDown;
{/������� ChatLineView}

strlist.Free;

//����� �������� ������� ��������� ������, ����� ����� �������� ����� ���� �������
FChatView.Style := self.FCVStyle;
FChatView.VScrollVisible := false;

setLength(SmilesGIFImages, 5);
SmilesGIFImages[0] := TGif.Create;
SmilesGIFImages[1] := TGif.Create;
SmilesGIFImages[2] := TGif.Create;
SmilesGIFImages[3] := TGif.Create;
SmilesGIFImages[4] := TGif.Create;

MS := TMemoryStream.Create;
try
  MS.LoadFromFile(GifPath + 'notworthy.gif');
  SmilesGIFImages[0].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'russian_ru.gif');
  SmilesGIFImages[1].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'girl_witch.gif');
  SmilesGIFImages[2].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'friends.gif');
  SmilesGIFImages[3].LoadFromStream(ms);
  MS.Clear;
  MS.LoadFromFile(GifPath + 'snoozer_19.gif');
  SmilesGIFImages[4].LoadFromStream(ms);
  MS.Clear;
except
  on E: Exception do
    begin
    MessageBox(0, PChar(E.Message), PChar('GIF image loading  error!'), mb_ok);
    end;
end;
MS.Free;

Canvas := FChatView.GetCanvas;
with FChatView.Style.TextStyles[0] do
  begin
  Canvas.Font.Style   := Style;
  Canvas.Font.Size    := Size;
  Canvas.Font.Name    := FontName;
  Canvas.Font.CharSet := CharSet;
  end;

//FFormAbout.Caption := inttostr(FFormAbout.Height) + ' / ' + inttostr(Canvas.TextHeight(crlf)) + ' = ' +
//                      inttostr(round(FFormAbout.Height/Canvas.TextHeight(crlf)));
for n := 0 to trunc(FFormAbout.Height/Canvas.TextHeight(br)) - 2 do
  begin
  FChatView.AddTextFromNewLine(br, 0, nil);
  end;
//      NORMALTEXTSTYLE = 0;
//      REDTEXTSTYLE = 1;
//      BLACKTEXTSTYLE = 2;
//      LINKTEXTSTYLE = 4;
//      ONLINKTEXTSTYLE = 5;

LinkText := FCVStyle.TextStyles.Items[LINKTEXTSTYLE];
OverLinkText := FCVStyle.TextStyles.Items[ONLINKTEXTSTYLE];

with FChatView do
  begin
  AddCenterLine('��� ������������ �������', BLACKTEXTSTYLE, nil);
  AddCenterLine('������������� DreamChat!', BLACKTEXTSTYLE, nil);
  AddTextFromNewLine(br, 0, nil);
  AddTextFromNewLine('������� ������� ��������� ���� � �������. ������� ������ ���� ��� � 2004 ���� ��� ���� � � �� ���' +
  ' ������������, ��� �� �������� ���� Open Source Software.' +
  ' �� � ���, ��� ��� ���������! ��� �������, ��� � ���� ���� ���� ��� ����,' +
  ' ������� ����� ��������� �� ������ ���� �����, �� � ���' +
  ' ����!', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('������� �������� �� �� ���� �������������' +
  ' � ������ ������� ���� � ������ ������������� Intranet Chat. ' +
                     '��������� �������, ������� ��� �� ���������� ���! �� �������� ������� ������������� ' +
                     '������� ������� �� ������� � ����!', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('�������� � ���������: ', NORMALTEXTSTYLE, nil);
  AddText('http://vnalex.tripod.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vnalex.tripod.com/'));
  AddTextFromNewLine('�������� � Wikipedia: ', NORMALTEXTSTYLE, nil);
  AddText('http://ru.wikipedia.org/wiki/IChat', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://ru.wikipedia.org/wiki/IChat'));
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);

  AddTextFromNewLine('������� ������� ���� ���������� ������� DreamChat:', BLACKTEXTSTYLE, nil);
  AddTextFromNewLine('����� DreamChat.exe: ', REDTEXTSTYLE, nil);
  AddText(           '������� ������ (aka Neyro[RUS])', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('��� �������� � ���� Internet: ', NORMALTEXTSTYLE, nil);
  AddText('http://neyro.h15.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://neyro.h15.ru'));
  AddTextFromNewLine('��� �����: ', NORMALTEXTSTYLE, nil);
  AddText('neyro@mail.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'mailto:neyro@mail.ru'));
  AddTextFromNewLine('� � ��������: ', NORMALTEXTSTYLE, nil);
  AddText('http://vk.com/bajenov', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vk.com/bajenov'));
  AddTextFromNewLine('����� ������ ��������: ', REDTEXTSTYLE, nil);
  AddText(           '���������� ������� (aka Torbins)', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('������� � ��������: ', NORMALTEXTSTYLE, nil);
  AddText('http://vk.com/id9399979', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://vk.com/id9399979'));
  AddTextFromNewLine('����� DreamChat Server: ', REDTEXTSTYLE, nil);
  AddText(           '������ ���������� (aka LaserSquard)', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('������ � ��������������: ', NORMALTEXTSTYLE, nil);
  AddText('hhttp://www.odnoklassniki.ru/profile/156729022749', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.odnoklassniki.ru/profile/156729022749'));
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('���� �� ������������ ��������, ������� � ����� ����������������� ������� ����� �������������� ��� ���� �� ��� �������� ������ IChat.', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);

//  AddTextFromNewLine('������:', BLACKTEXTSTYLE, -1);
  AddTextFromNewLine('�������� ������ ������� � ���� Internet: ', NORMALTEXTSTYLE, nil);
  AddText('http://sourceforge.net/projects/dreamchat', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://sourceforge.net/projects/dreamchat'));
  AddTextFromNewLine('��� ��������� ����, ������� � ��������� ������ �� ��� �����: ', NORMALTEXTSTYLE, nil);
  AddText('http://dreamchat.flybb.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://dreamchat.flybb.ru/'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);


  AddTextFromNewLine('���� ������� ������� �������:' , BLACKTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[3], false, nil);
  AddText( '���������� ������� (aka Torbins) �� ��������� � ������ ������' +
  ' (AlphaControls), �������� ������ �������� � ��' +
  ' ���������� ������� � ��������� ����� � ������ � DreamChat. � �������� ��' +
  ' ����������� � ������� �������� EurekaLog.' +
  ' C ���� �������� ���� �� ��������� ����� ������� ���������� � ������� �����.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[3], false, nil);
  AddText( '������ ���������� (aka LaserSquard) �� ��������� DreamChat Server,' +
  ' ����������� tcpkrnl.dll, �� ���������������� ���������������� �������,' +
  ' �� ����������� � ��������� ������� �� SourceForge.net,' +
  ' �� ��������, ����� ����������� ��������� ���� �������� ������� ������ �' +
  ' SourceForge.net, � ����� �� ������ � ������������ ����� � DreamChat.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[1], false, nil);
  AddText( '������ �������� Aiwan (�� ����� ������ �����)! ��� ����� ������� ' +
  ' � ���� �� ���� ������! ', NORMALTEXTSTYLE, nil);
  AddText('http://www.kolobok.us', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.kolobok.us'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Sergey Tkachenko (', NORMALTEXTSTYLE, nil);
  AddText('http://www.trichview.com', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.trichview.com'));
  AddText( ') �� ��������� TRichView, TRVStyle and TRVPrint ' +
           'Components ver 0.5.2 FREEWARE, �.�. ������ ���� ���� ������� ��� �������� TsChatView.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Mike Lischke and Delphi Gems software solutions (', NORMALTEXTSTYLE, nil);
  AddText('http://www.delphi-gems.com', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.delphi-gems.com'));
  AddText( ') �� ������������� ��������� Virtual ' +
           'Treeview 3.5.0 (Mozilla Public License (MPL) or Lesser General Public License (LGPL))', NORMALTEXTSTYLE, nil);

             AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( '���������� ������� ������������� ����������� Alpha Controls (', NORMALTEXTSTYLE, nil);
  AddText('http://alphaskins.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://alphaskins.com/'));
  AddText( ') �� ������ ������ ��� ����!', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( '������������� ������-����� �� ������������� ���������� � ��������� ����������� RXLIB (', NORMALTEXTSTYLE, nil);
  AddText('http://www.rxlib.ru', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.rxlib.ru'));
  AddText( ')', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( '������� ������ Delphi ������������� (�������� ������� "�����������") ', NORMALTEXTSTYLE, nil);
  AddText('http://delphimaster.ru/cgi-bin/forum.pl?n=3', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://delphimaster.ru'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( '���������� Delphi ������������� ', NORMALTEXTSTYLE, nil);
  AddText('http://www.delphi-jedi.org/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.delphi-jedi.org/'));

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( 'Eurekalog �� ������������ Bugs Tracer ', NORMALTEXTSTYLE, nil);
  AddText('http://www.eurekalog.com/', LINKTEXTSTYLE,
          AddLink(0, OnLinkMouseMoveProcessing,
                     OnLinkMouseDownProcessing,
                     LinkText, OverLinkText,
                     'http://www.eurekalog.com/'));

//  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
//  AddGifAni('', SmilesGIFImages[2], false, nil);
//  AddText( '��������������, ������������ ����������� ����, �� ��������� �����. ���� �� �� �� ���� ��� �� �������� �� ������.', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[0], false, nil);
  AddText( '� ��� �� ���� �������������, ��� ��������, ��������� � ����� ��������� ������� � ���� �������.', NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine('[update 2012] ���� ������� ���-�� ������� ����� ������ �����, ' +
  '������� � �������-�� ����� ����� ��� DChat! (�����)' +
  ' � ���� ��������, �� � ������ ������ ������ �� ������������. � �� ���� ����������� ' +
  '��������� ������� ���������� ��������� � ���� �������. ' +
  '��-�� �������� ���������� ������� ������ ����������� ������ ������. ' +
  '������� ���������� ������ �� �������� ������, � ����� � ������ ��� ' +
  '����������. ���� �� ���� ��� ������� �������� ����� � �����������...(', NORMALTEXTSTYLE, nil);

  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddTextFromNewLine(br, NORMALTEXTSTYLE, nil);
  AddCenterLine('', NORMALTEXTSTYLE, nil);
  AddGifAni('', SmilesGIFImages[4], false, nil);
  AddCenterLine('����� DreamChat - ������� ������', NORMALTEXTSTYLE, nil);
  AddCenterLine('�����-��������� 2004-2012(�)', NORMALTEXTSTYLE, nil);
  end;
for n := 0 to round(FFormAbout.Height/Canvas.TextHeight(br)) - 1 do
  begin
  //��������� � ����� ������ �����
  FChatView.AddTextFromNewLine(br, 0, nil);
  end;
FChatView.Format;
FChatView.Repaint;
FTimer := TTimer.Create(FFormAbout);
FTimer.OnTimer := Timer1Timer;
FTimer.Interval := 50;
//FChatView.ScrollTo(430);

FFormAbout.Visible := true;

SetForegroundWindow(FFormAbout.Handle);
SetWindowPos(FFormAbout.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE);
end;


destructor TFormAbout.Destroy;
var n: integer;
begin
FTimer.Free;
FTimer := nil;

self.FFormAbout.Visible := false;
FChatView.Clear;
if self.FFormAbout <> nil then
  begin
  self.FFormAbout.Release;
  //FFormPopUp.free;
  self.FFormAbout := nil;
  end;

if self.FCVStyle <> nil then FCVStyle.Free;
if self.FChatView <> nil then FChatView.free;
if self.FSkinProvider <> nil then FSkinProvider.free;

//SmilesGIFImages[0].Free;
for n := 0 to Length(SmilesGIFImages) - 1 do
  begin
  SmilesGIFImages[n].Free;
  end;
Setlength(SmilesGIFImages, 0);
inherited Destroy;
end;

procedure TFormAbout.StringToComponent(Component: TComponent; Value: string);
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

procedure TFormAbout.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//self.Destroy;
//FormAbout := nil;
FreeAndNil(uFormMain.FormAbout);
end;

procedure TFormAbout.Timer1Timer(Sender: TObject);
begin
if FChatView.VScrollPos <> FChatView.VScrollMax then
  FChatView.VScrollPos := FChatView.VScrollPos + 1
else
  FChatView.VScrollPos := 0;
end;

procedure TFormAbout.OnLinkMouseMoveProcessing(SenderCV: TComponent;
                              DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);
BEGIN
//Form1.Caption := LinkInfo.LinkText;
//Memo1.Lines.Add('Processing : ' + inttostr(DrawCont.ContainerNumber));
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

procedure TFormAbout.OnLinkMouseDownProcessing(Button: TMouseButton; X, Y: Integer;
              SenderCV: TComponent; DrawCont: TDrawContainerInfo; LinkInfo:TLinkInfo);//��������� ����� �� ��v���
var
StartupInfo: TStartupInfo;
ProcessInfo: TProcessInformation;
CommandLine: string;
BEGIN
FillChar(StartupInfo, SizeOf(StartupInfo), #0);
StartupInfo.cb := SizeOf(StartupInfo);
StartupInfo.dwFlags := STARTF_USESTDHANDLES;
StartupInfo.wShowWindow := SW_SHOWNORMAL;//SW_HIDE;
StartupInfo.hStdOutput := 0;
StartupInfo.hStdInput := 0;

//CommandLine := 'explorer.exe ' + LinkInfo.LinkText;
//CreateProcess(nil, PChar(CommandLine), nil, nil, True,
//              CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
//              nil, nil, StartupInfo, ProcessInfo);
ShellExecute(0,'Open', PChar(LinkInfo.LinkText), nil, nil, SW_SHOWNORMAL);


//DebugForm.DebugMemo1.Lines.Add('ContainerNumber = ' + inttostr(DrawCont.ContainerNumber) + '  LinkInfo.LinkText = ' +
//              LinkInfo.LinkText);
//MessageBox(0, PChar('LinkProcessing'), PChar(inttostr(1)) ,mb_ok);
END;

end.
