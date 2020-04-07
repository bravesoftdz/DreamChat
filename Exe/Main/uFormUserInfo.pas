unit uFormUserInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CVScroll, sChatView, CVStyle, sSkinProvider, sDialogs, ChatView;

type
  TFormUI = class(TForm)
    UserInfoChatView: TsChatView;
    sSkinProvider1: TsSkinProvider;
    procedure Debug(Mess, Mess2: String);
    procedure UserInfoChatViewKeyDown(Sender: TObject; var Key: Word;
                               Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    //PROCEDURE GetUserInfo(Line: TObject; UserID: Cardinal);
    PROCEDURE GetUserInfo(Line: TObject; User: TObject);
    procedure UserInfoChatViewClick(Sender: TObject);
    procedure UserInfoChatViewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    Capt: string;
  public
    PROCEDURE LoadComponents(Sender: TObject);
    { Public declarations }
  end;

var
  FormUI: TFormUI;

implementation

uses uFormMain, uChatLine, uChatUser, DreamChatTools, uPathBuilder;

{$R *.DFM}

PROCEDURE TFormUI.LoadComponents(Sender: TObject);
var sc: string;
    strlist: TStringList;
BEGIN
  //s := ExtractFilePath(Application.ExeName);
  //sc := s + 'Components\';
  strlist := TStringList.Create;
  try
    sc := TPathBuilder.GetComponentsFolderName();
    strlist.LoadFromFile(sc + 'FormUserInfo.txt');
    StringToComponent(FormUI, strlist.text);
    Capt := Caption;
  except
    on E: Exception do sMessageDlg('FormUserInfo.txt settings loading error!', E.Message, mtError, [mbOk], 0);
  end;

  strlist.Free;
END;

procedure TFormUI.FormCreate(Sender: TObject);
var
    Myinfo: TStartUpInfo;
begin
//GetStartUpInfo(MyInfo);
//MyInfo.wShowWindow := SW_MINIMIZE;
//MyInfo.wShowWindow := SW_HIDE;
//ShowWindow(Handle, MyInfo.wShowWindow);

UserInfoChatView.Style := FormMain.CVStyle1;
UserInfoChatView.OnDebug := FormUI.Debug;
FormUI.LoadComponents(Sender);
FormUI.Caption := fmInternational.Strings[I_USERINFO];
//ChatView1.AddText('', 1, -1);
UserInfoChatView.Format;
UserInfoChatView.Repaint;

UserInfoChatView.CursorSelection := false;
end;

//PROCEDURE TFormUI.GetUserInfo(Line: TObject; UserID: Cardinal);
PROCEDURE TFormUI.GetUserInfo(Line: TObject; User: TObject);
VAR
   tLocalUser: tChatUser;
   tUser: TChatUser;
   MainLine: TChatLine;
   LinkText, OverLinkText: TFontInfo;
BEGIN
    LinkText := FormMain.CVStyle1.TextStyles.Items[LINKTEXTSTYLE];
    OverLinkText := FormMain.CVStyle1.TextStyles.Items[ONLINKTEXTSTYLE];

    tUser := TChatUser(User);
    FormUI.UserInfoChatView.Clear;
    FormUI.UserInfoChatView.AddText(fmInternational.Strings[I_DisplayNickName] + ' ', INFONAMESTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.DisplayNickName, INFOTEXTSTYLE, nil);
    FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_NickName] + ' ', INFONAMESTYLE, nil);
//    FormUI.UserInfoChatView.AddText(TChatLine(Line).ChatLineUsers[UserId].NickName, INFOTEXTSTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.NickName, INFOTEXTSTYLE, nil);
    FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_IP] + ' ', INFONAMESTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.IP, LINKTEXTSTYLE,
                             FormUI.UserInfoChatView.AddLink(0,
                             FormMain.OnLinkMouseMoveProcessing,
                             FormMain.OnLinkMouseUpProcessing,
                             LinkText, OverLinkText,
                             '\\' + tUser.IP + '\'));
    FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_ComputerName] + ' ', INFONAMESTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.ComputerName, INFOTEXTSTYLE, nil);
    FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_Login] + ' ', INFONAMESTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.Login, INFOTEXTSTYLE, nil);
    FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_ChatVer] + ' ', INFONAMESTYLE, nil);
    FormUI.UserInfoChatView.AddText(tUser.Version, INFOTEXTSTYLE, nil);

    MainLine := FormMain.GetMainLine;
    tLocalUser := MainLine.GetLocalUser;
    if tLocalUser <> nil then
      begin
      if tLocalUser = tUser then
        begin
        FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_CommDllVer] + ' ', INFONAMESTYLE, nil);
        FormUI.UserInfoChatView.AddText(copy(FullVersion, Length(tUser.Version) + 1,
                                      Length(FullVersion) - Length(tUser.Version)), INFOTEXTSTYLE, nil);
        end;
      end;

//    FormUI.UserInfoChatView.AddTextFromNewLine('ProtoName: ', INFONAMESTYLE, nil);
//    FormUI.UserInfoChatView.AddText(TChatLine(Line).ChatLineUsers[UserId].ProtoName, INFOTEXTSTYLE, nil);

    if tUser.MessageStatus.Count - 1 >= Ord(tUser.Status)  then
      begin
      FormUI.UserInfoChatView.AddTextFromNewLine(fmInternational.Strings[I_STATE] + ' ', INFONAMESTYLE, nil);
      FormUI.UserInfoChatView.AddText(tUser.MessageStatus.Strings[Ord(tUser.Status)], INFOTEXTSTYLE, nil);
      end
    else
      begin
      if tLocalUser <> nil then
        SendCommStatus_Req(PChar(tLocalUser.ProtoName), PChar(tUser.ComputerName));
      end;
    FormUI.UserInfoChatView.Format;
    FormUI.UserInfoChatView.Repaint;
END;

procedure TFormUI.Debug(Mess, Mess2: String);
//var n:word;
BEGIN
//Form2.Caption := Mess2;
//Label1.Caption := Mess;
END;

procedure TFormUI.UserInfoChatViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if (Key = VK_Escape) then
  begin
  ModalResult := mrOK;
  end;
if (Key = VK_Return) then
  begin
  FormMain.Edit1.Text := FormMain.Edit1.Text +
                      UserInfoChatView.DrawContainers.Strings[UserInfoChatView.CursorContainer];
  FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
  ModalResult := mrOK;
  end;
end;

procedure TFormUI.UserInfoChatViewClick(Sender: TObject);
begin
  FormMain.Edit1.Text := FormMain.Edit1.Text +
                    UserInfoChatView.DrawContainers.Strings[UserInfoChatView.CursorContainer];
  FormMain.Edit1.SelStart := length(FormMain.Edit1.Text);
  ModalResult := mrOK;
end;

procedure TFormUI.UserInfoChatViewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Caption := Capt + UserInfoChatView.DrawContainers.Strings[UserInfoChatView.CursorContainer];
end;

end.
