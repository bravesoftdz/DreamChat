unit uFormPopUpMessage;
//���� ���� ������� ���� ����������� ���������
//���� ����� ���� ���� �����:
//���� ��� �� ������, �� ��������� ������� ���� ���������� ������
//���� ��� �����, �� ��������� ����������� �� ������� ����.


//��������!!! ��� ������ Create(FormPopUpMessageId:cardinal;...)
//FormPopUpMessageId <- ������ ���� ����������, ����������������������!!!!
//�.�. FormPopUpMessageList.AddObject(inttostr(MessageId), self);
//��������� �� ���������������� ���� ��������� � ������� StringList ������
//� ��������� ������ �� ����������� �����.
//������� �� ����!!

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, sChatView, cvStyle, uChatUser, uChatLine, CVScroll,
  sButton, sPanel, sSkinProvider;

type //��������� ��������� ����
  TPopUpState = (stGoingUp,   //����� �����
                 stGoingDown, //����� ����
                 stSysTray,   //�������� �����-����, ����� � ����
                 stNormal);   //������ ���������� ������

type
  TFormPopUpMessage = class(TPersistent)
  protected
    FFormPopUp     :TForm;
    FChatView      :TsChatView;
    FPanel1        :TsPanel;
    FPanel2        :TsPanel;
    FButton1       :TsButton;
    FButton2       :TsButton;
    FTimer1		     :TTimer;
    FTimer2		     :TTimer;
    FTimer3		     :TTimer;
    FSkinProvider1 :TsSkinProvider;
  private
    { Private declarations }
    Procedure SetState(PopUpState: TPopUpState);
  public
    { Public declarations }
    MessageId                           :integer;//����� ��������� � ������ unit1_FormPopUpMessageList
    OwnerChatLineId                     :cardinal;
    FromChatUserId                      :cardinal;
    MaxTop                              :integer;//��������� ���� �� ��������� ���� ����������
    FromChatUserCompName                :string;
    FormScrollingStyle                  :boolean;//�������������, ���� ��������� �� ����
    FState                              :TPopUpState;//��������� ��������� ����
    property Timer1		            :TTimer read FTimer1 write FTimer1;//������ ��������� ������
    property Timer2		            :TTimer read FTimer2 write FTimer2;//������ ����������/��������� ����
    property Timer3		            :TTimer read FTimer3 write FTimer3;//������� ��������������� �������� ��������� �� systray
    property FormPopUp	        	:TForm read FFormPopUp write FFormPopUp;
    property ChatView	            :TsChatView read FChatView write FChatView;
    property Panel1		            :TsPanel read FPanel1 write FPanel1;
    property Panel2		            :TsPanel read FPanel2 write FPanel2;
    property Button1    		      :TsButton read FButton1 write FButton1;
    property Button2	            :TsButton read FButton2 write FButton2;
    property State                :TPopUpState read FState write SetState;
    property SkinProvider1	      :TsSkinProvider read FSkinProvider1 write FSkinProvider1;
    constructor Create(ownForm:TForm;
                       ownChatLineId:cardinal; SenderUserId:cardinal;
                       sMessage: String);
    destructor Destroy;override;
    procedure FormResize(Sender: TObject);
    procedure ChatViewMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure ChatViewMouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

const br: String = ' ' + chr(13) + chr(10);

implementation

uses uFormMain, DreamChatTools, uPathBuilder;

{$R *.DFM}
constructor TFormPopUpMessage.Create(ownForm:TForm;
                                     ownChatLineId:cardinal;
                                     SenderUserId:cardinal;
                                     sMessage: String);
var
  strlist: TStringList;
  n: cardinal;
  i: integer;
  si, sc{, SmileFileName}:string;
  //MS: TMemoryStream;
  ChatLine: TChatLine;
  tLocalUser{, tUser}: TChatUser;
//  hMenuHandle: HMENU;
begin
inherited Create();
state := stGoingUp;
MaxTop := 0;

FormScrollingStyle := false;//������� ����� �������������� ����

self.OwnerChatLineId := ownChatLineId;
self.FromChatUserId := SenderUserId;

si := TPathBuilder.GetImagesFolderName(); //ExtractFilePath(Application.ExeName) + 'images\';
sc := TPathBuilder.GetComponentsFolderName(); //ExtractFilePath(Application.ExeName) + 'Components\';

strlist := TStringList.Create;
if FormMain.Visible then
  begin
  //���� ����� ���� ����� �� ������, �� ������� ������� ���� ������� ���������
  //���� ���, �� ������� ����������� ���� � ������������ � ��� ����� ���������
  {������� TFormPopUp}
  FFormPopUp := TForm.Create(nil);
  FFormPopUp.Name := 'FormPopUp_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  //  Self.parent := ownForm;
  strlist.LoadFromFile(sc + 'FormPopUpMessage.txt');
  StringToComponent(FormPopUp, strlist.text);
  ShowWindow(FormPopUp.Handle, SW_HIDE);
  FormPopUp.ParentWindow := 0;
  FormPopUp.parent := nil;//
  FormPopUp.OnClose := FormClose;
  MaxTop := FormPopUp.Top;
  {/������� ChatLineView}

  {/������� Panel1}
  Panel1 := TsPanel.Create(FormPopUp);
  Panel1.Name := 'FormPopUpPanel1_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpPanel1.txt');
  StringToComponent(Panel1, strlist.text);
  Panel1.parent := FormPopUp;
  Panel1.ParentWindow := FormPopUp.Handle;
  Panel1.Caption := '';
  {/������� Panel1}
  {������� Panel2}
  Panel2 := TsPanel.Create(FormPopUp);
  Panel2.Name := 'FormPopUpPanel2_' + inttostr(ownChatLineID) + '_' +
                                      inttostr(FromChatUserID) + '_' +
                                      inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpPanel2.txt');
  StringToComponent(Panel2, strlist.text);
  Panel2.parent := FormPopUp;
  Panel2.ParentWindow := FormPopUp.Handle;
  Panel2.Caption := '';
  {/������� Panel2}

  {������� ChatLineView}
  FChatView := TsChatView.Create(Panel2);
  FChatView.Name := 'FormPopUpChatView_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FChatView.parent := Panel2;
  //  ChatLineView.ParentWindow := 0;
  FChatView.ParentWindow := Panel2.Handle;
  FChatView.Style := FormMain.CVStyle1;//��� ����!
  strlist.LoadFromFile(sc + 'CLChatLineView.txt');
  StringToComponent(FChatView, strlist.text);
  FChatView.Style := FormMain.CVStyle1;//��� ����!
  FChatView.Align := alClient;
  FChatView.CursorSelection := false;
  //  ChatLineView.OnVScrolled := OnVScrolled;
  //  ChatLineView.OnMouseDown := ChatLineViewMouseDown;
  {/������� ChatLineView}

  {/������� Button1}
  Button1 := TsButton.Create(Panel1);
  Button1.Name := 'FormPopUpButton1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpButtonOk.txt');
  StringToComponent(Button1, strlist.text);
  Button1.parent := Panel1;
  Button1.ParentWindow := Panel1.Handle;
  Button1.OnClick := Button1Click;
  {/������� Button1}

  {/������� Button2}
  Button2 := TsButton.Create(Panel1);
  Button2.Name := 'FormPopUpButton2_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  strlist.LoadFromFile(sc + 'FormPopUpButtonAnswer.txt');
  StringToComponent(Button2, strlist.text);
  Button2.parent := Panel1;
  Button2.ParentWindow := Panel1.Handle;
  Button2.OnClick := Button2Click;
  {/������� Button2}

  {������� SkinProvider1}
  SkinProvider1 := TsSkinProvider.Create(FormPopUp);
  SkinProvider1.Name := 'FormPopUpSkinProvider1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  {/������� SkinProvider1}
  RxTrayMess.Interval := 500;
  RxTrayMess.Animated := true;
  RxTrayMess.Show;
  end
else
  begin
  //���� ���, �� ������� ����������� ���� � ������������ � ��� ����� ���������
  {������� TFormPopUp}
  FormScrollingStyle := true;
  FFormPopUp := TForm.Create(nil);

  FFormPopUp.Name := 'FormPopUp_' + inttostr(ownChatLineID) + '_' +
                                    inttostr(FromChatUserID) + '_' +
                                    inttostr(GetTickCount());
  //Self.parent := ownForm;
  strlist.LoadFromFile(sc + 'FormPopUpMessage.txt');
  StringToComponent(FormPopUp, strlist.text);
  //ShowWindow(FormPopUp.Handle, SW_HIDE);

  FormPopUp.ParentWindow := GetDesktopWindow();
  FormPopUp.parent := nil;//
  FormPopUp.FormStyle := fsStayOnTop;{fsNormal;}
  FormPopUp.Position := poDefault;
  FormPopUp.BorderStyle := bsSingle;// bsToolWindow;//bsNone;
  FormPopUp.OnClose := self.FormClose;
  {/������� TFormPopUp}

  {������� SkinProvider1}
  SkinProvider1 := TsSkinProvider.Create(FormPopUp);
  SkinProvider1.Name := 'FormPopUpSkinProvider1_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FormPopUp.BorderIcons := [];
  {/������� SkinProvider1}

  {������� ChatLineView}
  FChatView := TsChatView.Create(FormPopUp);
  FChatView.Name := 'FormPopUpChatView_' + inttostr(ownChatLineID) + '_' +
                                     inttostr(FromChatUserID) + '_' +
                                     inttostr(GetTickCount());
  FChatView.Style := FormMain.CVStyle1;//��� ����!
  FChatView.Parent := nil;
  FChatView.ParentWindow := FormPopUp.Handle;
  strlist.LoadFromFile(sc + 'CLChatLineView.txt');
  StringToComponent(FChatView, strlist.text);
  FChatView.CursorSelection := false;
  //FChatView.Align := alClient;
  FChatView.Width := FormPopUp.ClientWidth;
  FChatView.Height := FormPopUp.ClientHeight;
  FChatView.VScrollVisible := false;//����� ���������
  FChatView.OnMouseUp := ChatViewMouseUp;
  FChatView.OnMouseDown := ChatViewMouseDown;
  {/������� ChatLineView}
  FormPopUp.Left := Screen.DesktopWidth - FormPopUp.Width;
  FormPopUp.Top := Screen.WorkAreaHeight - 1;// - FormPopUp.Height;
  //��������� ������ ������ ����� �������, ����� ��������� ��������� �� �����.
  for n := 0 to trunc(FChatView.Height/FChatView.GetCanvas.TextHeight(br) - 2) do
    begin
    FChatView.AddTextFromNewLine(br, 0, nil);
    end;

  end;
  strlist.Free;

  FormPopUp.OnResize := FormResize;

  ChatLine := FormMain.GetChatLineById(ownChatLineId);
if ChatLine <> nil then
  begin
  FromChatUserCompName := ChatLine.ChatLineUsers[FromChatUserId].ComputerName;
  tLocalUser := ChatLine.GetUserInfo(ChatLine.GetLocalUserId());
  MessageId := tLocalUser.PrivateMessCount;
  tLocalUser.PrivateMessCount := tLocalUser.PrivateMessCount + 1;
  FormPopUp.Caption := '[' + ChatLine.DisplayChatLineName +
                       '] ' + ChatLine.ChatLineUsers[FromChatUserId].ComputerName;
  sMessage := '<' + ChatLine.ChatLineUsers[FromChatUserId].DisplayNickName + '> ' + sMessage;
  end
else
  begin
  FromChatUserCompName := 'Unknown user';
  MessageId := GetTickCount();//� ������������ � 99.99% ��� ����� ���������� �����
  end;

//��������� ��� ����� � ������ ����
FormPopUpMessageList.AddObject(inttostr(MessageId), self);
//����� ���� ���������
FormMain.ParseAllChatView(sMessage, nil, FormMain.CVStyle1.TextStyles.Items[PRIVATETEXTSTYLE], nil, self.FChatView, false, true);

if FormScrollingStyle then
  begin
  //��������� ������ ������ ����� ���������, ����� ��� ��������� �������������� �����.
  for n := 0 to trunc(FChatView.Height/FChatView.GetCanvas.TextHeight(br)) - 1 do
    begin
    FChatView.AddTextFromNewLine(br, 0, nil);
    end;
  FChatView.VScrollPos := 0;

  MaxTop := Screen.WorkAreaHeight - FormPopUp.Height;
  for i := 0 to FormPopUpMessageList.Count - 1 do
    begin
    if TFormPopUpMessage(FormPopUpMessageList.Objects[i]).MessageId <> self.MessageId then
      begin
      //� ����� ����� ���������� �� ����
      if MaxTop > TFormPopUpMessage(FormPopUpMessageList.Objects[i]).FFormPopUp.Top then
        begin
        //�� ������ ��� ���� ���������, �������� ��������� ����
        MaxTop := TFormPopUpMessage(FormPopUpMessageList.Objects[i]).FFormPopUp.Top - self.FormPopUp.Height;
        if MaxTop < 0 then
          begin
          //���� ��� ������� ������� ������, � �� �� ����������(( ������� �������� �����
          MaxTop := Screen.WorkAreaHeight - FormPopUp.Height;
          end;
        end;
      end;
    end;

  Timer1 := TTimer.Create(FormPopUp);
  Timer1.OnTimer := Timer1Timer;
  Timer2 := TTimer.Create(FormPopUp);
  Timer2.OnTimer := Timer2Timer;
  Timer3 := TTimer.Create(FormPopUp);
  Timer3.OnTimer := Timer3Timer;
  Timer3.Enabled := false;

  Timer1.Interval := 70;//������� ������ ����������
  Timer2.Interval := 10;//������� ������ ���������� ����
  end;
FChatView.FormatTail;
FChatView.Repaint;

if FormScrollingStyle = false then
  begin
  //���� ��� ������������ ����
  //��������� �����, ������� ������ ������������ ���� � ������������ ����� � ������������ ����.
  SetForegroundWindow(FormPopUp.Handle);
  SetWindowPos(FormPopUp.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE);
  FormPopUp.Visible := true;
  end
else
  begin
  //���� ��� ������� ������������� ����
  //Style := GetWindowLong(FormPopUp.Handle, GWL_STYLE);
  //Style := Style And Not WS_SYSMENU;
  //SetWindowLong(FormPopUp.Handle, GWL_STYLE, Style);
  //������� �����, ������� �� �������� ����� � ������������
  //ShowWindow(FormPopUp.Handle, SW_SHOWNA);
  FormPopUp.Visible := true;
  ShowWindow(FormPopUp.Handle, SW_SHOWNOACTIVATE);
  end;
ShowWindow(Application.Handle, SW_HIDE);//������� ������� ����� � ������ �����
end;


destructor TFormPopUpMessage.Destroy;
var n:integer;
begin
self.FormPopUp.Visible := false;

FChatView.Clear;
{
FChatLineView.Free;//�.�. ��� ��� Parent �� FFormPopUp, �� �� �� ���� ����������!
self.FButton1.free;//��� ���� ����������� ��� self.FFormPopUp.Release
self.FButton2.free;//� ����� AV!!!!
self.FPanel1.free;
self.FPanel2.free;
}
if self.FFormPopUp <> nil then
  begin
  if FChatView <> nil then FChatView.Free;
  n := FormPopUpMessageList.IndexOf(inttostr(Self.MessageId));
  if n >= 0 then
    begin
    //FormPopUpMessageList.Objects[n] := nil;
    FormPopUpMessageList.Delete(n);
    end;
  self.FFormPopUp.free;
  self.FFormPopUp := nil;
  end;

RxTrayMess.Animated := false;
RxTrayMess.Hide;
inherited Destroy;
end;

procedure TFormPopUpMessage.Button1Click(Sender: TObject);
begin
self.FFormPopUp.Close;
RxTrayMess.Animated := false;
RxTrayMess.Hide;
end;

procedure TFormPopUpMessage.Button2Click(Sender: TObject);
var
   ChatLine: TChatLine;
   tUser: TChatUser;
begin
//����� �������� ��� ����� �����, �� �� ��� ��� ����...
ChatLine := FormMain.GetChatLineById(Self.OwnerChatLineId);
if ChatLine <> nil then
  begin
  if ChatLine.GetUserIdByCompName(FromChatUserCompName) = FromChatUserId then
    begin
    tUser := ChatLine.GetUserInfo(FromChatUserId);
    if tUser <> nil then
      begin
      FormMain.Edit1.Text := '/msg "' + tUser.DisplayNickName + '" ';
      FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
      end;
    end;
  end;
FormPopUp.Close;
if Application.MainForm.Visible = false then
  begin
  //Application.MainForm.Visible := True;
  Application.Restore;
  //�������� ��������� ����, ����� ��� ������ ���� ��������� � ������ �����
  //ShowWindow(Application.Handle, SW_HIDE);
  Application.BringToFront;
  end;
RxTrayMess.Animated := false;
RxTrayMess.Hide;
end;

procedure TFormPopUpMessage.Timer1Timer(Sender: TObject);
begin
if FChatView.VScrollPos < FChatView.VScrollMax then
  begin
  //������� ����
  FChatView.VScrollPos := FChatView.VScrollPos + 1;
  FChatView.Paint; //� ������ AC5.08 �������� ����� � �����������
  end
else
  begin
  //���������� ���� �� �����
  FChatView.VScrollPos := 0;
  Timer3.Interval := 1;//10*1000;//������� ������ ������������ ����
  Timer3.Enabled := true;
  end;
end;

procedure TFormPopUpMessage.Timer2Timer(Sender: TObject);
begin
//������ ��������/���������� ���� �� ����
if State = stGoingUp then
  begin
  //���� ���� ��������� �����
  if FormPopUp.Top > MaxTop then
    FormPopUp.Top := FormPopUp.Top - 5
  else
    Timer2.Interval := 0;
  end;
if State = stGoingDown then
  begin
  //���� ���� ��������� ����
  if FormPopUp.Top < Screen.WorkAreaHeight then
    begin
    FormPopUp.Top := FormPopUp.Top + 5;
    end
  else
    begin
    //��������� �������� ����� ������, �����������))

    //postmessage(FormPopUp.Handle, wm_close, 0, 0);
    //������ �������� �������� �������� FormPopUp.Close �.�. ��� ��������� ChatView
    //� � ���������� ��� ������ ���������� ���������� ��������� MouseUp
    Timer2.Enabled := false;
    state := stSysTray;
    end;
  end;
end;

procedure TFormPopUpMessage.Timer3Timer(Sender: TObject);
begin
Timer3.Enabled := false;
//������������� ��������� ���� �� systray
//showing := false;
state := stGoingDown;
end;

procedure TFormPopUpMessage.ChatViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{if Button = mbLeft then
  begin
  FormMain.Visible := true;
  FormMain.BringToFront;
  end;}
//postmessage(FormPopUp.Handle, wm_close, 0, 0);
//������ �������� �������� �������� FormPopUp.Close �.�. ��� ��������� ChatView
//� � ���������� ��� ������ ���������� ���������� ��������� MouseDown
end;

procedure TFormPopUpMessage.ChatViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ChatLine: TChatLine;
   tUser: TChatUser;
begin
if Button = mbLeft then
  begin
  //FormMain.Visible := true;
  Application.MainForm.Visible := True;
  Application.Restore;
  Application.BringToFront;
  ShowWindow(Application.Handle, SW_HIDE);
//  Showing := false;
  state := stGoingDown;

//����� �������� ��� ����� �����, �� �� ��� ��� ����...
ChatLine := FormMain.GetChatLineById(Self.OwnerChatLineId);
if ChatLine <> nil then
  begin
  if ChatLine.GetUserIdByCompName(FromChatUserCompName) = FromChatUserId then
    begin
    tUser := ChatLine.GetUserInfo(FromChatUserId);
    if tUser <> nil then
      begin
      FormMain.Edit1.Text := '/msg "' + tUser.DisplayNickName + '" ';
      FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
      end;
    end;
  end;

  end
else
  begin
  if FormScrollingStyle then postmessage(FormPopUp.Handle, wm_close, 0, 0);
  //������ �������� �������� �������� FormPopUp.Close �.�. ��� ��������� ChatView
  //� � ���������� ��� ������ ���������� ���������� ��������� MouseUp
  end;
end;

procedure TFormPopUpMessage.FormResize(Sender: TObject);
begin
if not FormScrollingStyle then
  begin
  self.Button1.Left := Round((panel1.Width/2 - self.Button1.Width)/2);
  self.Button2.Left := Round(panel1.Width/2 + (panel1.Width/2 - self.Button1.Width)/2);
  end;
end;

procedure TFormPopUpMessage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
self.Destroy;
end;

Procedure TFormPopUpMessage.SetState(PopUpState: TPopUpState);
begin
//(stGoingUp, stGoingDown, stSysTray, stNormal);
if PopUpState = stGoingUp then
  begin
  FState := stGoingUp;
  end;
if PopUpState = stGoingDown then
  begin
  FState := stGoingDown;
  FTimer2.Interval := 10;//������� ������ ��������� ����
  end;
if PopUpState = stSysTray then
  begin
  //����� ����� �� ��������� ����. �������� � ���� ������ � ��� ������� �� ���
  //������� �������� ���� � ������� � ������� ��� ������ �� Normal.
  //��� ��������� ��� �� ������.
  FormPopUp.Close;
  RxTrayMess.Interval := 500;
  RxTrayMess.Animated := true;
  RxTrayMess.Show;
  end;
end;

end.
