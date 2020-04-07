program DreamChat;

{$DEFINE DisableDublicateRun}
//��������� ��������� 2� ����� ����
// ������ ���� ������ ��������� ��������� ������ ����� �.�. ����� ����� ������������� �� ��� ������
// � ������ ����� ������ �� ������������� �����

uses
  ExceptionLog,
  SysUtils,
  ComObj,
  Forms,
  Windows,
  Dialogs,
  Inifiles,
  uFormMain in 'uFormMain.pas' {FormMain},
  uFormDebug in 'uFormDebug.pas' {FormDebug},
  uFormStart in 'uFormStart.pas' {FormStart},
  uFormPassword in 'uFormPassword.pas' {FormPassword},
  uFormUserInfo in 'uFormUserInfo.pas' {FormUI},
  DreamChatMessageBox in '..\Common\DreamChatMessageBox.pas',
  USettings in 'USettings.pas' {FSettings},
  USoundFrame in 'USoundFrame.pas' {SoundFrame: TFrame},
  DreamChatConsts in '..\Common\DreamChatConsts.pas',
  UChatUser in 'UChatUser.pas',
  uBMPtoICO in 'uBMPtoICO.pas',
  UVTHeaderPopupMenu in 'UVTHeaderPopupMenu.pas',
  uChatLine in 'uChatLine.pas',
  uCommLine in 'uCommLine.pas',
  DreamChatTools in '..\Common\DreamChatTools.pas',
  DreamChatConfig in '..\Common\DreamChatConfig.pas',
  DreamChatProtocolMessage in '..\Common\DreamChatProtocolMessage.pas',
  UGifVirtualStringTree in 'UGifVirtualStringTree.pas',
  DreamChatTranslater in 'DreamChatTranslater.pas',
  uPathBuilder in 'uPathBuilder.pas',
  uFormAbout in 'uFormAbout.pas',
  uFormPopUpMessage in 'uFormPopUpMessage.pas' {FormPopUpMessage},
  ChatView in '..\Components\ChatView\ChatView.pas',
  uImageLoader in 'uImageLoader.pas',
  uFormSmiles in 'uFormSmiles.pas' {FormSmiles};

{$R *.RES}

var
  command: string;
  i: integer;
  info: TStartUpInfo;

{$IFDEF DisableDublicateRun}

{$ELSE}
  randomGUID: TGUID;
  randomString: string;

{$IFDEF USELOG4D}
  logger: TlogLogger;
{$ENDIF USELOG4D}

{$ENDIF DisableDublicateRun}

//  RegisterProc: Pointer;
//  CommunicationLibHandle: HMODULE;
//  TempChatConfig: TMemIniFile;
//  s: string;

begin
  IsMultiThread := True;
  //uFormMain.ExePath := ExtractFilePath(Application.ExeName);
  //ExceptionLog.CurrentEurekaLogOptions.OutputPath:=uFormMain.ExePath;

//������ ������ ��� � ���: ���� �� ��������� ��� ��� ������ �������,
//�� �� �� ����� ������� ���� � ������ (ERROR_ACCESS_DENIED)
//������� - ��������� � �������� ����������� ��� ������ �����.

{$IFDEF DisableDublicateRun}
  //Normal
  //� ���� ������ ���� �� ������ ��������� 2� ����� ����!
  // ��� ������ ����� �������� ��� �����
  CommandLine := TCommandLine.Create('CommandLine_' + GetUserLoginName());
{$ELSE}
  //For Debug
  //������������ ����� ��������� 2� ����� ����!

    {$IFDEF USELOG4D}
    TLogPropertyConfigurator.Configure(TPathBuilder.GetExePath() +'DreamChat.props');
    logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
    logger.Info('-------- DreamChat Started -------');
    {$ENDIF USELOG4D}
  try
    if CreateGuid(randomGUID) = S_OK then
      begin
      OleCheck(CreateGUID(randomGUID));
      randomString := GUIDToString(randomGUID);
      end
    else
      begin
      //���� ��� �������� �� ���� ��� ������������ �����������
      randomString := IntToStr(GetTickCount());
      end;
    //������� - ��������� � �������� ����������� ��������� ������ (GUID).
  except
    on E: EOleSysError do
    begin
    {$IFDEF USELOG4D}
      logger := TLogLogger.GetLogger(DREAMCHATLOGGER_NAME);
      logger.Error('[Main]', E);
    {$ENDIF USELOG4D}
      TDreamChatMessageBox.Show(E.Message);
      randomString := IntToStr(GetTickCount());
    end;
  end;

//  CommandLine := TCommandLine.Create('CommandLine_' + IntToStr(GetTickCount()));
  CommandLine := TCommandLine.Create('CommandLine_' + randomString);
{$ENDIF}

command := '';
i := pos('/', CmdLine);
if (i <> length(CmdLine)) and (i > 0) then
  begin
  command := copy(CmdLine, i, Length(CmdLine) - i + 1);
  //MessageBox(0, PChar(command), PChar('') ,mb_ok);
  end
else
  begin
  //���� ��������� ������ �����, �� � ��������� ������ ������ �� �������.
  //�������� ������� �������� ������ ����� ���� �� �������� �����
  command := '/show';
  //��� ������� ����� �������� ������ ����� ���� � ������������ � Edit1KeyPress()
  end;

if (CommandLine.FirstCopyApplication = false) then
  begin
  //�������� ������ �����
  //��������� ���� ��������� ������� exe �����?
  if (ParamCount > 0) or (command <> '') then CommandLine.Command := command;
  end
else
  begin
  //�������� ������ �����

  Application.Initialize;

  //������� �������� ���������� � ������ �����
  GetStartUpInfo(Info);
  Info.dwFlags := STARTF_USESHOWWINDOW;
  Info.wShowWindow := SW_HIDE and SW_SHOWMINIMIZED;
  ShowWindow(Application.Handle, Info.wShowWindow);

  Application.CreateForm(TFormMain, FormMain);
  Application.Title := CAPTIONVERSION;
  //��������� ���������� ����� ����� ��������
  Application.ShowMainForm := false;
  //��������� ���������� � ��������� Minimize
  Application.Minimize;

  Application.CreateForm(TFormUI, FormUI);

//  FormMain.WindowState := wsMinimized;

  Application.Run;
  end;

FreeAndNil(CommandLine);

{$IFDEF USELOG4D}
  logger.Info('-------- DreamChart Exiting -------');
{$ENDIF USELOG4D}

end.
