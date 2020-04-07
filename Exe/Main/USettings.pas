unit uSettings;

interface

uses
{$IFDEF USEFASTSHAREMEM}
//  FastShareMem,
{$ENDIF}
  Windows, Forms, SysUtils, Classes, Messages, Variants, Graphics, Controls,
  Dialogs, StdCtrls, IniFiles, sSkinProvider, sSkinManager, sButton, sMemo,
  sRadioButton, sGroupBox, sLabel, sEdit, ExtCtrls, sPanel, ComCtrls, sTreeView,
  Buttons, sBitBtn, Menus, sSpinEdit, Mask, sMaskEdit, sDialogs,
  ImgList, sCheckBox, sScrollBox, sFrameBar, Math, CVStyle, sCustomComboEdit,
  sTooledit, sTrackBar, sComboBox, sTabControl, ShellApi, USoundFrame,
  sListBox,
  uChatLine, uChatUser,
//DChat 1.0
  DChatPluginManager, DChatPlugin, DChatTestPlugin, DChatCommPlugin,
  DChatClientServerPlugin, sCheckListBox
//DChat 1.0
;

type

  TSPaths = record
    s0:  string;
    s1:  string;
    s2:  string;
    s3:  string;
    s4:  string;
    s5:  string;
    s6:  string;
    s7:  string;
    s8:  string;
    s9:  string;
    s10: string;
    s11: string;
  end;

  TMes = record
    St0: THashedStringList;
    St1: THashedStringList;
    St2: THashedStringList;
    St3: THashedStringList;
  end;

  TFSettings = class(TForm)
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    tPanelSel: TsTreeView;
    pButtons: TsPanel;
    pPodkluchenie: TsPanel;
    lPodkl:  TsLabel;
    pNameSel: TsRadioGroup;
    bOk:     TsBitBtn;
    bCancel: TsBitBtn;
    rFromName: TsRadioButton;
    rName:   TsRadioButton;
    lNames:  TsListBox;
    rFromLogon: TsRadioButton;
    PopupMenu1: TPopupMenu;
    mAdd:    TMenuItem;
    mChenge: TMenuItem;
    mDel:    TMenuItem;
    gServer: TsGroupBox;
    ePortNamb: TsDecimalSpinEdit;
    gSoedinenie: TsGroupBox;
    rVidelServ: TsRadioButton;
    rMailSlots: TsRadioButton;
    pFont:   TsPanel;
    lFonts:  TsLabel;
    CVStyle1: TCVStyle;
    FontDialog1: TFontDialog;
    sColorDialog1: TsColorDialog;
    pUsers:  TsPanel;
    lUser:   TsLabel;
    eIPAdr:  TsEdit;
    pMess:   TsPanel;
    lMess:   TsLabel;
    gReceived: TsGroupBox;
    eRes:    TsEdit;
    tcAutoM: TsTabControl;
    lbMessages: TsListBox;
    bbAdd:   TsBitBtn;
    bbUp:    TsBitBtn;
    bbDown:  TsBitBtn;
    bbEdit:  TsBitBtn;
    bbDel:   TsBitBtn;
    gbBoard: TsGroupBox;
    feMesBoard: TsFilenameEdit;
    bbEdBoard: TsBitBtn;
    ImageList1: TImageList;
    bAcept:  TsBitBtn;
    pLangSkin: TsPanel;
    gSkin:   TsGroupBox;
    lColor:  TsLabel;
    eSkinPath: TsDirectoryEdit;
    cbSkin:  TsComboBox;
    tColor:  TsTrackBar;
    lLangSkin: TsLabel;
    gbLanguage: TsGroupBox;
    cbLangChange: TsComboBox;
    tUsers:  TsTreeView;
    pF:      TsPanel;
    lNormal: TsLabel;
    lSystem: TsLabel;
    lPrivat: TsLabel;
    lBoard:  TsLabel;
    lLink:   TsLabel;
    lOnLink: TsLabel;
    lInfoName: TsLabel;
    lInfoText: TsLabel;
    lMeText: TsLabel;
    eMess:   TsEdit;
    gbUserFonts: TsGroupBox;
    gbSounds: TsGroupBox;
    pChatView: TsPanel;
    lNick:   TsLabel;
    lMouseOver: TsLabel;
    fbSounds: TsFrameBar;
    pCommon: TsPanel;
    lComm:   TsLabel;
    gbDifferent: TsGroupBox;
    cbCloseButton: TsCheckBox;

//DChat 1.0
    pPlugins: TsPanel;
    Label1: TsLabel;
    Label2: TsLabel;
    Label3: TsLabel;
    ButtonLoadPlugin: TsButton;
    ButtonUnloadPlugin: TsButton;
    ListBox2: TsListBox;
    Memo1: TsMemo;
    Memo2: TsMemo;
    CheckListBox1: TsCheckListBox;
    ListBox1: TsListBox;
    gbHotKey: TsGroupBox;
    eHotKey: TsEdit;
    gbCrypto: TsGroupBox;
    rbIChatKey: TsRadioButton;
    rbAntiHackKey: TsRadioButton;
    rbUserKey: TsRadioButton;
    eCryptoKey: TsEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonLoadPluginClick(Sender: TObject);
    procedure ButtonUnloadPluginClick(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure CheckListBox1DblClick(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure RefreshCheckersOfAutoLoadPluginList(DoLoadPlugin: boolean);
//DChat 1.0

    procedure bbEdBoardClick(Sender: TObject);
    procedure feMesBoardExit(Sender: TObject);
    procedure feMesBoardKeyPress(Sender: TObject; var Key: char);
    procedure feMesBoardButtonClick(Sender: TObject);
    procedure tPanelSelChange(Sender: TObject; Node: TTreeNode);
    procedure tcAutoMChanging(Sender: TObject; var AllowChange: boolean);
    procedure tcAutoMChange(Sender: TObject);
    procedure bbDownClick(Sender: TObject);
    procedure bbUpClick(Sender: TObject);
    procedure bbEditClick(Sender: TObject);
    procedure bbDelClick(Sender: TObject);
    procedure bbAddClick(Sender: TObject);
    procedure lbMessagesKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure lbMessagesDblClick(Sender: TObject);
    procedure lNamesDblClick(Sender: TObject);
    procedure lNamesKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure eSkinPathMouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure eSkinPathExit(Sender: TObject);
    procedure eSkinPathKeyPress(Sender: TObject; var Key: char);
    procedure cbSkinChange(Sender: TObject);
    procedure eSkinPathChange(Sender: TObject);
    procedure tColorChange(Sender: TObject);
    procedure BOkClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure rNameClick(Sender: TObject);
    procedure mAddClick(Sender: TObject);
    procedure mChengeClick(Sender: TObject);
    procedure mDelClick(Sender: TObject);
    procedure rVidelServClick(Sender: TObject);
    procedure rMailSlotsClick(Sender: TObject);
    procedure FontLabelClick(Sender: TObject);
    procedure pFClick(Sender: TObject);
    procedure tUsersClick(Sender: TObject);
    procedure eMessClick(Sender: TObject);
    procedure fbSoundsItems11FrameDestroy(Sender: TObject;
                       var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems11CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems0CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems1CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems2CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems3CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems4CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems5CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems6CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems0FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems1FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems2FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems3FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems4FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems5FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems6FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure eIPAdrKeyPress(Sender: TObject; var Key: char);
    procedure eIPAdrExit(Sender: TObject);
    procedure fbSoundsItems8CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems7CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems7FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems8FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems9CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems9FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure fbSoundsItems10CreateFrame(Sender: TObject; var Frame: TCustomFrame);
    procedure fbSoundsItems10FrameDestroy(Sender: TObject;
      var Frame: TCustomFrame; var CanDestroy: boolean);
    procedure bAceptClick(Sender: TObject);
    procedure cbLangChangeChange(Sender: TObject);
//DChat 1.0
    procedure pPluginsClick(Sender: TObject);
    function LoadingPlugin():boolean;
    procedure eHotKeyKeyPress(Sender: TObject; var Key: Char);
    procedure rbIChatKeyClick(Sender: TObject);
    procedure rbAntiHackKeyClick(Sender: TObject);
    procedure rbUserKeyClick(Sender: TObject);
//DChat 1.0
  private
    PNicksCount: integer;
    CurUser:  integer;
    CurrLang: string;
    Mes:      TMes;
    SPaths:   TSPaths;
    LangFiles, International: THashedStringList;
    DefUser:  TConfigChatUser;
       //��������� ������ ��������� ������ ������������� ����
    ConfUsers: array of TConfigChatUser;
    ConfUsersReady: boolean;

    procedure SavePrevNicks;
    { Private declarations }
  protected
  public
//DChat 1.0
    PluginManager: TPluginManager;
    PluginManagerConfig: TMemIniFile;
//DChat 1.0
    procedure ChangeLang(LangFile: string);
    procedure GenerateSkinsList;
    procedure Init;
    function IsSection(str: string): boolean;
    procedure SaveSet;
    procedure WriteNick(nick: string);
    procedure CreateSFrame(var f: TCustomFrame);
  end;

resourcestring
  rsdc     = 'Dream Chat';
  rsn      = '��� (���):';
  rsnnm    = 'NoNaMe';
  rsNoAvailabS = '��� ��������� ������';
  rsNoSkin = '��� �����';
  rsNoC    = '�� ���� ������� ����� ';
  rsNm     = '����� ���������:';
  rsVm     = '������� ���������:';
  rsM0     = '���� ������!';
  rsM1     = '�����!';
  rsM2     = '�� ����������!';
  rsM3     = '����!';
  rslUsers = '������������:';
  rsDefault = '��������� ���������';
  rsPath   = '���� � ��������� �����:';

const
  I_dc     = 0;
  I_n      = 1;
  I_nnm    = 2;
  I_NoAvailabS = 3;
  I_NoSkin = 4;
  I_NoC    = 5;
  I_Nm     = 6;
  I_Vm     = 7;
  I_M0     = 8;
  I_M1     = 9;
  I_M2     = 10;
  I_M3     = 11;
  I_lUsers = 12;
  I_Default = 13;
  I_Path   = 14;

implementation

uses UFormMain, uPathBuilder, DreamChatConfig, DreamChatTools;

{$R *.dfm}

//DChat 1.0
procedure TFSettings.RefreshCheckersOfAutoLoadPluginList(DoLoadPlugin: boolean);
var i: integer;
    NativePlugin: TDChatPlugin;
    res: boolean;
begin
//������� ����� ������ ���� �������� �������� ��� ������������
i := 0;
while i <= ChecklistBox1.Items.Count - 1 do
  begin
  NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[i]);
  //�����, ��� � ������� ����������� SomeFile.dll = 1 ��� 0
  CheckListBox1.Checked[i] := PluginManagerConfig.ReadBool('PluginAutoLoad', NativePlugin.Filename, false);
  if CheckListBox1.Checked[i] = true then
    begin
    if DoLoadPlugin = true then
      begin
      CheckListBox1.ItemIndex := i;
      res := LoadingPlugin;
      if res = false then
        begin
        //����� �������� ������� ������ � ������!
        //��������� � ���������� ������� � ������ ���������
        inc(i);
        end;
      //������, ��� ��� ������� ������ �������� ������! �� ����������� i!
      end
    else
      begin
      //DoLoadPlugin = false
      //���������� ��� ���������� ������� � ������ ��������
      //��� �� ������������.
      inc(i);
      end;
    end
  else
    begin
    //������ ������ �� ������� �������� ��� ��������
    //��������� � ���������� � ������
    inc(i);
    end;
  end;
end;

function TFSettings.LoadingPlugin():boolean;
var DChatPlugin: TDChatPlugin;
    Version: integer;
    e: EPluginLoadingError;
begin
result := true;
if ChecklistBox1.ItemIndex >= 0 then
  begin
    try
      Version := strtoint(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion);
      DChatPlugin := TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]);
      if (DChatPlugin.PluginInfo.PluginAPIVersion <> '') or
        (Version = PlaginManagerVersion) then
        begin
          try
            //��������� ������
            if PluginManager.LoadPlugin(DChatPlugin) = false then
              begin
              //������ ��������
              e := EPluginLoadingError.Create('Plugin load fail ' +
                                       PChar(string(DChatPlugin.Filename))
                                       );
              result := false;
              raise e;
              end;
          except
            messagebox(0, PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
                  PChar('Plugin load fail'), mb_ok);
            result := false;
            exit;
          end;
        CheckListBox1.Items := PluginManager.NativePluginList;
        listBox2.Items := PluginManager.PluginList;
        RefreshCheckersOfAutoLoadPluginList(false);
        end
      else
        begin
        messagebox(0,
               PChar('The plugin no have compatible version of API interface!! PluginManagerAPIVersion = ' +
               TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion +
               ' . Must be = ' + IntToStr(PlaginManagerVersion)),
               PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
               mb_ok);
        result := false;
        end;
    except
      messagebox(0,
               PChar('The plugin no have compatible version of API interface! PluginManagerAPIVersion = ' +
               TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).PluginInfo.PluginManagerAPIVersion +
               ' . Must be = ' + IntToStr(PlaginManagerVersion)),
               PChar(string(TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename)),
               mb_ok);
    result := false;
    end;
  end;
memo2.Lines.Clear;
end;

procedure TFSettings.ButtonLoadPluginClick(Sender: TObject);
begin
LoadingPlugin;
end;

procedure TFSettings.CheckListBox1DblClick(Sender: TObject);
begin
ButtonLoadPluginClick(Sender);
end;


procedure TFSettings.ButtonUnloadPluginClick(Sender: TObject);
begin
//��������� ����������� ������ � ��������� ��� � ������ Native
if listBox2.ItemIndex >= 0 then
  begin
  PluginManager.UnLoadPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
  CheckListBox1.Items.assign(PluginManager.NativePluginList);
  listBox2.Items := PluginManager.PluginList;
  RefreshCheckersOfAutoLoadPluginList(false);
  end;
end;

procedure TFSettings.CheckListBox1Click(Sender: TObject);
var NativePlugin: TDChatPlugin;
    s: string;
begin
if CheckListBox1.ItemIndex >= 0 then
  begin
  NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]);
  Memo1.Lines.Clear;
  Memo1.Lines.Add('PluginName: ' + NativePlugin.PluginInfo.PluginName);
  Memo1.Lines.Add('InternalPluginFileName: ' + NativePlugin.PluginInfo.InternalPluginFileName);
  case ord(NativePlugin.PluginInfo.PluginType) of
    0: s := 'Test';
    1: s := 'Visual';
    2: s := 'Communication';
    3: s := 'SoundEvents';
    4: s := 'Protocol';
    5: s := 'ClientServer';
  else
    begin
    s := 'Unknown';
    end;
  end;
  memo1.Lines.Add('PluginType: ' + s);
  if Length(NativePlugin.PluginInfo.PluginManagerAPIVersion) > 0 then
    memo1.Lines.Add('PluginManager (Native API Version): ' + NativePlugin.PluginInfo.PluginManagerAPIVersion)
  else
    memo1.Lines.Add('PluginManager (Native API Version): Unknown');
  if Length(NativePlugin.PluginInfo.PluginAPIVersion) > 0 then
    memo1.Lines.Add('PluginAPIVersion: ' + NativePlugin.PluginInfo.PluginAPIVersion)
  else
    memo1.Lines.Add('PluginAPIVersion: Unknown');
  if Length(NativePlugin.PluginInfo.PluginVersion) > 0 then
    memo1.Lines.Add('PluginVersion: ' + NativePlugin.PluginInfo.PluginVersion)
  else
    memo1.Lines.Add('PluginVersion: Unknown');
  memo1.Lines.Add('PluginAutorName: ' + NativePlugin.PluginInfo.PluginAutorName);
  memo1.Lines.Add('PluginComment: ' + NativePlugin.PluginInfo.PluginComment);
  end;
end;

procedure TFSettings.ListBox2Click(Sender: TObject);
var TestPlugin: TDChatTestPlugin;
    CommPlugin: TDChatCommPlugin;
    NativePlugin: TDChatPlugin;
    ClientServerPlugin: TDChatClientServerPlugin;
    s: string;
begin
//�������� ������� ������� ����������� ��������!

//������ �������� ������ � ���, ��� �������� AV ����� ����� � �������� ��������
//����������� ��������, � ���������� ��� �� ������ �����������.
//���� ������� �������� �� ������������� ������ TestFunction1
//��� �� ������ ������, �.�. ������ ���������� ���� �������� �� ������� ���� � ������
//��� ����� ������� ������� �� TestFunction1
                                            


if listBox2.ItemIndex >= 0 then
  begin
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatClientServerPlugin then
    begin
    //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
    //������� TestFunction1, TestFunction2
    ClientServerPlugin := TDChatClientServerPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    if ClientServerPlugin <> nil then
      begin
      s := ClientServerPlugin.ExecuteCommand('', '', 0);
      memo2.Lines.Add(s);
      end;
    end;
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatTestPlugin then
    begin
    //���� ������� ������ ���� TDChatTestPlugin, �� � ���� ����
    //������� TestFunction1, TestFunction2
    TestPlugin := TDChatTestPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    if TestPlugin <> nil then
      begin
      s := TestPlugin.ExecuteCommand(PChar('test'), PChar(''), 0);
      memo2.Lines.Add(s);
      end;
    end;
  if listBox2.Items.Objects[listBox2.ItemIndex] is TDChatCommPlugin then
    begin
    //���� ������� ������ ���� TDChatCommPlugin, �� � ���� ���� ���
    //������� ������� ���������
    CommPlugin := TDChatCommPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
    s := CommPlugin.SendCommText('iChat', '192.168.1.4/ANDREY/Admins', 'Andrey',
                                 'Message from plugin', 'gsMTCI', 1);
    //���� ��� ���� ��������� ���������, �� � DChat � DebugLog ������������
    //'Message from plugin' ���������.
    //����� ��������� ������ � ��� ���, ����� ��������� PluginManager ��
    //����� ������� ������������ (Run As) ����� ��� ������� ��� ��� ��� ���������
    if s = '' then s := 'SendCommText() executed!';
    memo2.Lines.Add(s);
    end;

  NativePlugin := TDChatPlugin(listBox2.Items.Objects[listBox2.ItemIndex]);
  if NativePlugin <> nil then
    begin
    memo1.Lines.Clear;
    memo1.Lines.Add('PluginName: ' + NativePlugin.PluginInfo.PluginName);
    memo1.Lines.Add('InternalPluginFileName: ' + NativePlugin.PluginInfo.InternalPluginFileName);
    memo1.Lines.Add('PluginAutorName: ' + NativePlugin.PluginInfo.PluginAutorName);
    memo1.Lines.Add('PluginComment: ' + NativePlugin.PluginInfo.PluginComment);
    end;
  end;
end;

procedure TFSettings.CheckListBox1ClickCheck(Sender: TObject);
begin
  //���������� ������ �������
  PluginManagerConfig.WriteBool('PluginAutoLoad', TDChatPlugin(CheckListBox1.Items.Objects[CheckListBox1.ItemIndex]).Filename, CheckListBox1.Checked[CheckListBox1.itemindex]);
  PluginManagerConfig.UpdateFile;
end;
//DChat 1.0


procedure TFSettings.BOkClick(Sender: TObject);
begin
SaveSet;
Close;
end;

procedure TFSettings.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFSettings.FormCreate(Sender: TObject);
var i, maxWidth: integer;
//    strlst: TStringlist;
//    s: string;
begin

  CurUser := -1;

  pButtons.SkinData.FSkinManager := sSkinManager1;
  bAcept.SkinData.FSkinManager  := sSkinManager1;
  bCancel.SkinData.FSkinManager := sSkinManager1;
  bOk.SkinData.FSkinManager     := sSkinManager1;
  pFont.SkinData.FSkinManager   := sSkinManager1;
  eMess.SkinData.FSkinManager   := sSkinManager1;
  pF.SkinData.FSkinManager      := sSkinManager1;
  tUsers.SkinData.FSkinManager  := sSkinManager1;
  gSkin.SkinData.FSkinManager   := sSkinManager1;
  cbSkin.SkinData.FSkinManager  := sSkinManager1;
  eSkinPath.SkinData.FSkinManager := sSkinManager1;
  tColor.SkinData.FSkinManager  := sSkinManager1;
  pMess.SkinData.FSkinManager   := sSkinManager1;
  gbBoard.SkinData.FSkinManager := sSkinManager1;
  bbEdBoard.SkinData.FSkinManager := sSkinManager1;
  feMesBoard.SkinData.FSkinManager := sSkinManager1;
  gReceived.SkinData.FSkinManager := sSkinManager1;
  eRes.SkinData.FSkinManager    := sSkinManager1;
  tcAutoM.SkinData.FSkinManager := sSkinManager1;
  bbAdd.SkinData.FSkinManager   := sSkinManager1;
  bbDel.SkinData.FSkinManager   := sSkinManager1;
  bbDown.SkinData.FSkinManager  := sSkinManager1;
  bbEdit.SkinData.FSkinManager  := sSkinManager1;
  bbUp.SkinData.FSkinManager    := sSkinManager1;
  lbMessages.SkinData.FSkinManager := sSkinManager1;
  pPodkluchenie.SkinData.FSkinManager := sSkinManager1;
  gServer.SkinData.FSkinManager := sSkinManager1;
  eIPAdr.SkinData.FSkinManager  := sSkinManager1;
  ePortNamb.SkinData.FSkinManager := sSkinManager1;
  gSoedinenie.SkinData.FSkinManager := sSkinManager1;
  rMailSlots.SkinData.FSkinManager := sSkinManager1;
  rVidelServ.SkinData.FSkinManager := sSkinManager1;
  lNames.SkinData.FSkinManager  := sSkinManager1;
  pNameSel.SkinData.FSkinManager := sSkinManager1;
  rFromLogon.SkinData.FSkinManager := sSkinManager1;
  rFromName.SkinData.FSkinManager := sSkinManager1;
  rName.SkinData.FSkinManager   := sSkinManager1;
  tPanelSel.SkinData.FSkinManager := sSkinManager1;
  pLangSkin.SkinData.FSkinManager := sSkinManager1;
  gbLanguage.SkinData.FSkinManager := sSkinManager1;
  cbLangChange.SkinData.FSkinManager := sSkinManager1;
  sSkinProvider1.SkinData.FSkinManager := sSkinManager1;
  pUsers.SkinData.FSkinManager  := sSkinManager1;
  gbSounds.SkinData.FSkinManager := sSkinManager1;
  fbSounds.SkinData.FSkinManager := sSkinManager1;
  gbUserFonts.SkinData.FSkinManager := sSkinManager1;
  pChatView.SkinData.FSkinManager := sSkinManager1;
//DChat 1.0
  pPlugins.SkinData.FSkinManager := sSkinManager1;
  eHotKey.SkinData.FSkinManager := sSkinManager1;
  eCryptoKey.SkinData.FSkinManager := sSkinManager1;
  gbCrypto.SkinData.FSkinManager := sSkinManager1;
  rbIChatKey.SkinData.FSkinManager := sSkinManager1;
  rbAntiHackKey.SkinData.FSkinManager := sSkinManager1;
  rbUserKey.SkinData.FSkinManager := sSkinManager1;
//DChat 1.0

  LangFiles     := THashedStringList.Create;
  International := THashedStringList.Create;
  International.Add(rsdc);
  International.Add(rsn);
  International.Add(rsnnm);
  International.Add(rsNoAvailabS);
  International.Add(rsNoSkin);
  International.Add(rsNoC);
  International.Add(rsNm);
  International.Add(rsVm);
  International.Add(rsM0);
  International.Add(rsM1);
  International.Add(rsM2);
  International.Add(rsM3);
  International.Add(rslUsers + ' ');
  International.Add(rsDefault);
  International.Add(rsPath);

  Mes.St0 := THashedStringList.Create;
  Mes.St1 := THashedStringList.Create;
  Mes.St2 := THashedStringList.Create;
  Mes.St3 := THashedStringList.Create;

  DefUser := TConfigChatUser.Create;

  //DChat 1.0
  //Creating PluginManager....
tPanelSel.Items.Add(tPanelSel.Items.Item[5], 'Plugins');
try
  PluginManagerConfig := TMemIniFile.Create(TPathBuilder.GetExePath() + 'plugins\PluginManager.ini');
except
  on E: Exception do begin
    sMessageDlg('PluginManagerConfig creating error: ', E.Message, mtError, [mbOk], 0);
  end;
end;
try
  PluginManager := TPluginManager.Create(TPathBuilder.GetExePath() + 'plugins\');
except
  on E: Exception do begin
    sMessageDlg('PluginManager creating error: ', E.Message, mtError, [mbOk], 0);
  end;
end;
Memo1.Lines.Clear;
Memo2.Lines.Clear;
ListBox1.Items := PluginManager.FileList;

//������� �������������� ������ ��������� � ListBox1
    maxWidth := 0;
      for i := 0 to ListBox1.Items.Count - 1 do
        begin
        if maxWidth < TsListBox(ListBox1).Canvas.TextWidth(ListBox1.Items.Strings[i]) then
          maxWidth := TsListBox(ListBox1).Canvas.TextWidth(ListBox1.Items.Strings[i]);
        end;
      TsListBox(ListBox1).Perform(LB_SETHORIZONTALEXTENT, maxWidth + TsListBox(ListBox1).Width, 0);

for i := 0 to PluginManager.FileList.Count - 1 do
  begin
  if PluginManager.LoadNativePlugin(PluginManager.FileList.Strings[i]) = false then
    begin
    ChecklistBox1.Items.Add('Load Plugin error!');
    end;
  end;
ChecklistBox1.Items := PluginManager.NativePluginList;

RefreshCheckersOfAutoLoadPluginList(true);
//DChat 1.0

end;

procedure TFSettings.rNameClick(Sender: TObject);
begin
  lNames.Enabled := rName.Checked;
end;

procedure TFSettings.mAddClick(Sender: TObject);
var
  s: string;
begin
  s := International.Strings[I_nnm];
  if sInputQuery(International.Strings[I_dc], International.Strings[I_n], s) then
    lNames.Items.Add(s);
end;

procedure TFSettings.mChengeClick(Sender: TObject);
begin
  if lNames.Items.Count > 0 then
  begin
    if lNames.ItemIndex = -1 then
      lNames.ItemIndex := 0;
    lNames.Items.Strings[lNames.ItemIndex] :=
      sInputBox(International.Strings[I_dc], International.Strings[I_n],
      lNames.Items.Strings[lNames.ItemIndex]);
  end;
end;

procedure TFSettings.mDelClick(Sender: TObject);
begin
  if lNames.Items.Count > 0 then
  begin
    if lNames.ItemIndex = -1 then
      lNames.ItemIndex := 0;
    lNames.Items.Delete(lNames.ItemIndex);
  end;
  lNames.ItemIndex := 0;
end;

procedure TFSettings.rVidelServClick(Sender: TObject);
begin
  gServer.Enabled   := rVidelServ.Checked;
  eIPAdr.Enabled    := rVidelServ.Checked;
  ePortNamb.Enabled := rVidelServ.Checked;
end;

procedure TFSettings.rMailSlotsClick(Sender: TObject);
begin
  gServer.Enabled   := rVidelServ.Checked;
  eIPAdr.Enabled    := rVidelServ.Checked;
  ePortNamb.Enabled := rVidelServ.Checked;
end;

procedure TFSettings.FontLabelClick(Sender: TObject);
begin
  FontDialog1.Font := TsLabel(Sender).Font;
  if FontDialog1.Execute then
    TsLabel(Sender).Font := FontDialog1.Font;
end;

procedure TFSettings.pFClick(Sender: TObject);
begin
{sColorDialog1.Color:=pf.Color;
if sColorDialog1.Execute then
pf.Color:=sColorDialog1.Color;}
end;

procedure TFSettings.tUsersClick(Sender: TObject);
begin
  FontDialog1.Font := tUsers.Font;
  if FontDialog1.Execute then
    tUsers.Font := FontDialog1.Font;
end;

procedure TFSettings.eMessClick(Sender: TObject);
begin
  FontDialog1.Font := eMess.Font;
  if FontDialog1.Execute then
    eMess.Font := FontDialog1.Font;
end;

procedure TFSettings.fbSoundsItems0CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s0;
end;

procedure TFSettings.fbSoundsItems1CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s1;
end;

procedure TFSettings.fbSoundsItems2CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s2;
end;

procedure TFSettings.fbSoundsItems3CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s3;
end;

procedure TFSettings.fbSoundsItems4CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s4;
end;

procedure TFSettings.fbSoundsItems5CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s5;
end;

procedure TFSettings.fbSoundsItems6CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s6;
end;

procedure TFSettings.fbSoundsItems0FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s0 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems1FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s1 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems2FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s2 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems3FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s3 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems4FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s4 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems5FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s5 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems6FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s6 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.eIPAdrKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in [#8, #13, '.', '0'..'9']) then
    key := #0;
  if key = #13 then
    eIPAdr.Text := CheckIP(eIPAdr.Text);
end;

procedure TFSettings.eHotKeyKeyPress(Sender: TObject; var Key: Char);
begin
//��� ���� ������� ����� ������������ ������ � ���� ������!
//  eHotKey.Text := FormMain.MultiTranslate(eHotKey.Text, RusToEng);
end;

procedure TFSettings.eIPAdrExit(Sender: TObject);
begin
  eIPAdr.Text := CheckIP(eIPAdr.Text);
end;

procedure TFSettings.fbSoundsItems8CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s8;
end;

procedure TFSettings.fbSoundsItems7CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s7;
end;

procedure TFSettings.fbSoundsItems7FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s7 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems8FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s8 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems9CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s9;
end;

procedure TFSettings.fbSoundsItems9FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s9 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.fbSoundsItems10CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s10;
end;

procedure TFSettings.fbSoundsItems10FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s10 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.tColorChange(Sender: TObject);
begin
  //if not aSkinChanging then // If not in skin changing (global variable from AC package used)
  sSkinManager1.HueOffset := tColor.Position;
  //uFormMain.FormMain.SkinManMain.HueOffset := tColor.Position;
end;

procedure TFSettings.eSkinPathChange(Sender: TObject);
var
  s: string;
begin
  if DirectoryExists(eSkinPath.Text) and (sSkinManager1.SkinDirectory <>
    eSkinPath.Text) then
  begin
    s := cbSkin.Text;
    sSkinManager1.SkinDirectory := eSkinPath.Text;
    GenerateSkinsList;
    if cbSkin.IndexOf(s) = -1 then
      cbSkin.ItemIndex := 0
    else
      cbSkin.ItemIndex := cbSkin.IndexOf(s);
    cbSkinChange(Sender);
  end;
end;

procedure TFSettings.GenerateSkinsList;
var
  sl: THashedStringList;
  i:  integer;
  //mi : TMenuItem;
begin
  sl := THashedStringList.Create;
  sSkinManager1.GetSkinNames(sl);
  cbSkin.Items.BeginUpdate;
  cbSkin.Clear;
  cbSkin.Items.Add(International.Strings[I_NoSkin]);
  for i := 0 to sl.Count - 1 do
  begin
    cbSkin.Items.Add(sl[i]);
  end;
  cbSkin.Items.EndUpdate;
  // If no available skins...
  if cbSkin.Items.Count <= 1 then
  begin
    cbSkin.Clear;
    cbSkin.Items.Add(International.Strings[I_NoAvailabS]);
  end;
  FreeAndNil(sl);
end;

procedure TFSettings.cbSkinChange(Sender: TObject);
begin
  if (International.Strings[I_NoSkin] <> cbSkin.Items[cbSkin.ItemIndex]) and
    (International.Strings[I_NoAvailabS] <> cbSkin.Items[cbSkin.ItemIndex]) then
  begin
    if sSkinManager1.SkinName <> cbSkin.Items[cbSkin.ItemIndex] then
      sSkinManager1.SkinName := cbSkin.Items[cbSkin.ItemIndex];
    sSkinManager1.Active := True;
  end
  else
  begin
    sSkinManager1.Active := False;
    //sSkinManager1.SkinName := '';
  end;
end;

procedure TFSettings.eSkinPathKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
    if not DirectoryExists(eSkinPath.Text) then
      eSkinPath.Text := '';
end;

procedure TFSettings.eSkinPathExit(Sender: TObject);
begin
  if not DirectoryExists(eSkinPath.Text) then
    eSkinPath.Text := '';
end;

procedure TFSettings.eSkinPathMouseActivate(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
  if not DirectoryExists(eSkinPath.Text) then
    eSkinPath.Text:=''
  else
    eSkinPath.InitialDir:=eSkinPath.Text;
end;

procedure TFSettings.lNamesKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  s: string;
begin
  if key = 46 then
  begin
    if lNames.Items.Count > 0 then
    begin
      if lNames.ItemIndex = -1 then
        lNames.ItemIndex := 0;
      lNames.Items.Delete(lNames.ItemIndex);
    end;
    lNames.ItemIndex := 0;
  end
  else
  if Key = 45 then
  begin
    s := International.Strings[I_nnm];
    if sInputQuery(International.Strings[I_dc], International.Strings[I_n], s) then
      lNames.Items.Add(s);
  end
  else
  if Key = 13 then
    if lNames.Count > 0 then
    begin
      if lNames.ItemIndex = -1 then
        lNames.ItemIndex := 0;
      lNames.Items.Strings[lNames.ItemIndex] :=
        sInputBox(International.Strings[I_dc], International.Strings[I_n],
        lNames.Items.Strings[lNames.ItemIndex]);
    end;
end;

procedure TFSettings.lNamesDblClick(Sender: TObject);
var
  s: string;
begin
  if lNames.Count > 0 then
  begin
    if lNames.ItemIndex = -1 then
      lNames.ItemIndex := 0;
    lNames.Items.Strings[lNames.ItemIndex] :=
      sInputBox(International.Strings[I_dc], International.Strings[I_n],
      lNames.Items.Strings[lNames.ItemIndex]);
  end
  else
  begin
    s := International.Strings[I_nnm];
    if sInputQuery(International.Strings[I_dc], International.Strings[I_n], s) then
      lNames.Items.Add(s);
  end;
end;

procedure TFSettings.FormDestroy(Sender: TObject);
//DChat 1.0
var i: integer;
    NativePlugin: TDChatPlugin;
begin
if ChecklistBox1.Items.Count > 0 then
  begin
  for i := 0 to ChecklistBox1.Items.Count - 1 do
    begin
    //���������� ������ �������
    NativePlugin := TDChatPlugin(CheckListBox1.Items.Objects[i]);
    PluginManagerConfig.WriteBool('PluginAutoLoad', NativePlugin.Filename, CheckListBox1.Checked[i]);
    end;
  PluginManagerConfig.UpdateFile;
  end;
PluginManager.Free;
PluginManagerConfig.Free;
//DChat 1.0

  LangFiles.Free;
  International.Free;

  Mes.St0.Free;
  Mes.St1.Free;
  Mes.St2.Free;
  Mes.St3.Free;

  DefUser.Free;
end;

procedure TFSettings.lbMessagesDblClick(Sender: TObject);
var
  s: string;
begin
  if lbMessages.Count > 0 then
  begin
    if lbMessages.ItemIndex = -1 then
      lbMessages.ItemIndex := 0;
    lbMessages.Items.Strings[lbMessages.ItemIndex] :=
      sInputBox(International.Strings[I_dc], International.Strings[I_Vm],
      lbMessages.Items.Strings[lbMessages.ItemIndex]);
  end
  else
  begin
    case tcAutoM.TabIndex of
      0: s := International.Strings[I_M0];
      1: s := International.Strings[I_M1];
      2: s := International.Strings[I_M2];
      else
        s := International.Strings[I_M3];
    end;
    if sInputQuery(International.Strings[I_dc], International.Strings[I_Nm], s) then
      lbMessages.Items.Add(s);
  end;
end;

procedure TFSettings.lbMessagesKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  s: string;
  i: integer;
begin
  if key = 46 then
  begin
    i := lbMessages.ItemIndex;
    if lbMessages.Items.Count > 0 then
    begin
      if lbMessages.ItemIndex = -1 then
        lbMessages.ItemIndex := 0;
      lbMessages.Items.Delete(lbMessages.ItemIndex);
    end;
    if lbMessages.Count > i then
      lbMessages.ItemIndex := i
    else
      lbMessages.ItemIndex := 0;
  end
  else
  if Key = 45 then
  begin
    case tcAutoM.TabIndex of
      0: s := International.Strings[I_M0];
      1: s := International.Strings[I_M1];
      2: s := International.Strings[I_M2];
      else
        s := International.Strings[I_M3];
    end;
    if sInputQuery(International.Strings[I_dc], International.Strings[I_Nm], s) then
      lbMessages.Items.Add(s);
  end
  else
  if Key = 13 then
    if lbMessages.Count > 0 then
    begin
      if lbMessages.ItemIndex = -1 then
        lbMessages.ItemIndex := 0;
      lbMessages.Items.Strings[lbMessages.ItemIndex] :=
        sInputBox(International.Strings[I_dc], International.Strings[I_Vm],
        lbMessages.Items.Strings[lbMessages.ItemIndex]);
    end;
end;

procedure TFSettings.bbAddClick(Sender: TObject);
var
  s: string;
begin
  case tcAutoM.TabIndex of
    0: s := International.Strings[I_M0];
    1: s := International.Strings[I_M1];
    2: s := International.Strings[I_M2];
    else
      s := International.Strings[I_M3];
  end;
  if sInputQuery(International.Strings[I_dc], International.Strings[I_Nm], s) then
    lbMessages.Items.Add(s);
end;

procedure TFSettings.bbDelClick(Sender: TObject);
var
  i: integer;
begin
  i := lbMessages.ItemIndex;
  if lbMessages.Items.Count > 0 then
  begin
    if lbMessages.ItemIndex = -1 then
      lbMessages.ItemIndex := 0;
    lbMessages.Items.Delete(lbMessages.ItemIndex);
  end;
  if lbMessages.Count > i then
    lbMessages.ItemIndex := i
  else
    lbMessages.ItemIndex := 0;
end;

procedure TFSettings.bbEditClick(Sender: TObject);
begin
  if lbMessages.Count > 0 then
  begin
    if lbMessages.ItemIndex = -1 then
      lbMessages.ItemIndex := 0;
    lbMessages.Items.Strings[lbMessages.ItemIndex] :=
      sInputBox(International.Strings[I_dc], International.Strings[I_Vm],
      lbMessages.Items.Strings[lbMessages.ItemIndex]);
  end;
end;

procedure TFSettings.bbUpClick(Sender: TObject);
begin
  if lbMessages.ItemIndex = -1 then
    lbMessages.ItemIndex := 0;
  if lbMessages.ItemIndex > 0 then
    lbMessages.Items.Exchange(lbMessages.ItemIndex, lbMessages.ItemIndex - 1);
end;

procedure TFSettings.bbDownClick(Sender: TObject);
begin
  if lbMessages.ItemIndex = -1 then
    lbMessages.ItemIndex := 0;
  if lbMessages.ItemIndex < lbMessages.Count - 1 then
    lbMessages.Items.Exchange(lbMessages.ItemIndex, lbMessages.ItemIndex + 1);
end;

procedure TFSettings.tcAutoMChange(Sender: TObject);
begin
  case tcAutoM.TabIndex of
    0: lbMessages.Items.Text := Mes.St0.Text;
    1: lbMessages.Items.Text := Mes.St1.Text;
    2: lbMessages.Items.Text := Mes.St2.Text;
    else
      lbMessages.Items.Text := Mes.St3.Text;
  end;
  if lbMessages.ItemIndex = -1 then
    lbMessages.ItemIndex := 0;
end;

procedure TFSettings.tcAutoMChanging(Sender: TObject; var AllowChange: boolean);
begin
  case tcAutoM.TabIndex of
    0: Mes.St0.Text := lbMessages.Items.Text;
    1: Mes.St1.Text := lbMessages.Items.Text;
    2: Mes.St2.Text := lbMessages.Items.Text;
    else
      Mes.St3.Text := lbMessages.Items.Text;
  end;
  AllowChange := True;
end;

function TFSettings.IsSection(str: string): boolean;
begin
  Result := False;
  if length(str) > 0 then
    if (str[1] = '[') and (str[length(str)] = ']') then
      Result := True;
end;

procedure TFSettings.tPanelSelChange(Sender: TObject; Node: TTreeNode);
var
  i: integer;
  RemoteUserConfigFile: TMemIniFile;
begin
//DChat 1.0
if tPanelSel.Selected.Parent <> nil then
  begin
  if ConfUsersReady then
    begin
    CurUser := tPanelSel.Selected.index;
//    MessageBox(0, PChar('CurUser = ' + inttostr(CurUser)), PChar(inttostr(0)) ,mb_ok);
//    MessageBox(0, PChar('fbSounds.Items.Count = ' + inttostr(fbSounds.Items.Count)), PChar(inttostr(0)) ,mb_ok);
    RemoteUserConfigFile := TMemIniFile.Create(ConfUsers[CurUser].UserConfigFileName);
    ConfUsers[CurUser].LoadUserSettingsFromIni(RemoteUserConfigFile);
    RemoteUserConfigFile.free;
    SPaths.s0     := ConfUsers[CurUser].SoundAlert;
    SPaths.s1     := ConfUsers[CurUser].SoundAlertToAll;
    SPaths.s2     := ConfUsers[CurUser].SoundBoard;
    SPaths.s3     := ConfUsers[CurUser].SoundText;
    SPaths.s4     := ConfUsers[CurUser].SoundConnect;
    SPaths.s5     := ConfUsers[CurUser].SoundDisconnect;
    SPaths.s6     := ConfUsers[CurUser].SoundRename;
    SPaths.s7     := ConfUsers[CurUser].SoundStatus;
    SPaths.s8     := ConfUsers[CurUser].SoundFindLine;
    SPaths.s9     := ConfUsers[CurUser].SoundCreate;
    SPaths.s10    := ConfUsers[CurUser].SoundReceived;
    SPaths.s11    := ConfUsers[CurUser].SoundRefresh;
    if (fbSounds.Items.Items[0].Frame) <> nil then
      ((fbSounds.Items.Items[0].Frame) as TSoundFrame).fePath.Text := SPaths.s0;
    if (fbSounds.Items.Items[1].Frame) <> nil then
      ((fbSounds.Items.Items[1].Frame) as TSoundFrame).fePath.Text := SPaths.s1;
    if (fbSounds.Items.Items[2].Frame) <> nil then
      ((fbSounds.Items.Items[2].Frame) as TSoundFrame).fePath.Text := SPaths.s2;
    if (fbSounds.Items.Items[3].Frame) <> nil then
      ((fbSounds.Items.Items[3].Frame) as TSoundFrame).fePath.Text := SPaths.s3;
    if (fbSounds.Items.Items[4].Frame) <> nil then
      ((fbSounds.Items.Items[4].Frame) as TSoundFrame).fePath.Text := SPaths.s4;
    if (fbSounds.Items.Items[5].Frame) <> nil then
      ((fbSounds.Items.Items[5].Frame) as TSoundFrame).fePath.Text := SPaths.s5;
    if (fbSounds.Items.Items[6].Frame) <> nil then
      ((fbSounds.Items.Items[6].Frame) as TSoundFrame).fePath.Text := SPaths.s6;
    if (fbSounds.Items.Items[7].Frame) <> nil then
      ((fbSounds.Items.Items[7].Frame) as TSoundFrame).fePath.Text := SPaths.s7;
    if (fbSounds.Items.Items[8].Frame) <> nil then
      ((fbSounds.Items.Items[8].Frame) as TSoundFrame).fePath.Text := SPaths.s8;
    if (fbSounds.Items.Items[9].Frame) <> nil then
      ((fbSounds.Items.Items[9].Frame) as TSoundFrame).fePath.Text := SPaths.s9;
    if (fbSounds.Items.Items[10].Frame) <> nil then
      ((fbSounds.Items.Items[10].Frame) as TSoundFrame).fePath.Text := SPaths.s10;
    if (fbSounds.Items.Items[11].Frame) <> nil then
      ((fbSounds.Items.Items[11].Frame) as TSoundFrame).fePath.Text := SPaths.s11;

    lUser.Caption := International.Strings[I_lUsers] + ConfUsers[CurUser].GetAllNicks;
    lMouseOver.Font.Assign(ConfUsers[CurUser].UserOnLineMouseOverFS);
    lNick.Font.Assign(ConfUsers[CurUser].UserOnLineFS);

    if not pUsers.Visible then
      begin
      pUsers.Show;
      pPodkluchenie.Hide;
      pCommon.Hide;
      pFont.Hide;
      pLangSkin.Hide;
      pMess.Hide;
      pPlugins.Hide;
      end;
    end;
  exit;
  end;

case (tPanelSel.Selected.index + 1) of
//DChat 1.0
    0:
    begin
      if ConfUsersReady then
      begin
        if CurUser = -1 then
        begin
          DefUser.UserOnLineFS.Assign(lNick.Font);
          DefUser.UserOnLineMouseOverFS.Assign(lMouseOver.Font);
          DefUser.SoundAlert    := SPaths.s0;
          DefUser.SoundAlertToAll := SPaths.s1;
          DefUser.SoundBoard    := SPaths.s2;
          DefUser.SoundText     := SPaths.s3;
          DefUser.SoundConnect  := SPaths.s4;
          DefUser.SoundDisconnect := SPaths.s5;
          DefUser.SoundRename   := SPaths.s6;
          DefUser.SoundStatus   := SPaths.s7;
          DefUser.SoundFindLine := SPaths.s8;
          DefUser.SoundCreate   := SPaths.s9;
          DefUser.SoundReceived := SPaths.s10;
          DefUser.SoundRefresh  := SPaths.s11;
        end
        else
        if (Length(ConfUsers) > CurUser) and (CurUser >= 0) then
        begin
          ConfUsers[CurUser].UserOnLineFS.Assign(lNick.Font);
          ConfUsers[CurUser].UserOnLineMouseOverFS.Assign(lMouseOver.Font);
          ConfUsers[CurUser].SoundAlert    := SPaths.s0;
          ConfUsers[CurUser].SoundAlertToAll := SPaths.s1;
          ConfUsers[CurUser].SoundBoard    := SPaths.s2;
          ConfUsers[CurUser].SoundText     := SPaths.s3;
          ConfUsers[CurUser].SoundConnect  := SPaths.s4;
          ConfUsers[CurUser].SoundDisconnect := SPaths.s5;
          ConfUsers[CurUser].SoundRename   := SPaths.s6;
          ConfUsers[CurUser].SoundStatus   := SPaths.s7;
          ConfUsers[CurUser].SoundFindLine := SPaths.s8;
          ConfUsers[CurUser].SoundCreate   := SPaths.s9;
          ConfUsers[CurUser].SoundReceived := SPaths.s10;
          ConfUsers[CurUser].SoundRefresh  := SPaths.s11;
        end;
        lNick.Font.Assign(TConfigChatUser(tPanelSel.Selected.Data).UserOnLineFS);
        lMouseOver.Font.Assign(
          TConfigChatUser(tPanelSel.Selected.Data).UserOnLineMouseOverFS);
        SPaths.s0     := TConfigChatUser(tPanelSel.Selected.Data).SoundAlert;
        SPaths.s1     := TConfigChatUser(tPanelSel.Selected.Data).SoundAlertToAll;
        SPaths.s2     := TConfigChatUser(tPanelSel.Selected.Data).SoundBoard;
        SPaths.s3     := TConfigChatUser(tPanelSel.Selected.Data).SoundText;
        SPaths.s4     := TConfigChatUser(tPanelSel.Selected.Data).SoundConnect;
        SPaths.s5     := TConfigChatUser(tPanelSel.Selected.Data).SoundDisconnect;
        SPaths.s6     := TConfigChatUser(tPanelSel.Selected.Data).SoundRename;
        SPaths.s7     := TConfigChatUser(tPanelSel.Selected.Data).SoundStatus;
        SPaths.s8     := TConfigChatUser(tPanelSel.Selected.Data).SoundFindLine;
        SPaths.s9     := TConfigChatUser(tPanelSel.Selected.Data).SoundCreate;
        SPaths.s10    := TConfigChatUser(tPanelSel.Selected.Data).SoundReceived;
        SPaths.s11    := TConfigChatUser(tPanelSel.Selected.Data).SoundRefresh;
        lUser.Caption := International.Strings[I_lUsers] + TConfigChatUser(
          tPanelSel.Selected.Data).GetAllNicks;
        if Length(ConfUsers) > 0 then
          for i := 0 to High(ConfUsers) do
            if ConfUsers[i].UserTreeNode = tPanelSel.Selected then
              CurUser := i;

        if not pUsers.Visible then
        begin
          pUsers.Show;
          pPodkluchenie.Hide;
          pCommon.Hide;
          pFont.Hide;
          pLangSkin.Hide;
          pMess.Hide;
//DChat 1.0
          pPlugins.Hide;
//DChat 1.0
        end;
      end;
    end;
    1:
    begin
      pPodkluchenie.Show;
      pCommon.Hide;
      pFont.Hide;
      pLangSkin.Hide;
      pUsers.Hide;
      pMess.Hide;
//DChat 1.0
      pPlugins.Hide;
//DChat 1.0
    end;
    2:
    begin
      pCommon.Show;
      pPodkluchenie.Hide;
      pFont.Hide;
      pLangSkin.Hide;
      pUsers.Hide;
      pMess.Hide;
    end;
    3:
    begin
      pFont.Show;
      pPodkluchenie.Hide;
      pCommon.Hide;
      pLangSkin.Hide;
      pUsers.Hide;
      pMess.Hide;
//DChat 1.0
      pPlugins.Hide;
//DChat 1.0
    end;
    4:
    begin
      pLangSkin.Show;
      pPodkluchenie.Hide;
      pCommon.Hide;
      pFont.Hide;
      pUsers.Hide;
      pMess.Hide;
//DChat 1.0
      pPlugins.Hide;
//DChat 1.0
    end;
    5:
    begin
      pMess.Show;
      pPodkluchenie.Hide;
      pCommon.Hide;
      pFont.Hide;
      pLangSkin.Hide;
      pUsers.Hide;
//DChat 1.0
      pPlugins.Hide;
//DChat 1.0
    end;
    6:
    begin
      if ConfUsersReady then
      begin
        if (Length(ConfUsers) > CurUser) and (CurUser >= 0) then
        begin
          ConfUsers[CurUser].UserOnLineFS.Assign(lNick.Font);
          ConfUsers[CurUser].UserOnLineMouseOverFS.Assign(lMouseOver.Font);
          ConfUsers[CurUser].SoundAlert    := SPaths.s0;
          ConfUsers[CurUser].SoundAlertToAll := SPaths.s1;
          ConfUsers[CurUser].SoundBoard    := SPaths.s2;
          ConfUsers[CurUser].SoundText     := SPaths.s3;
          ConfUsers[CurUser].SoundConnect  := SPaths.s4;
          ConfUsers[CurUser].SoundDisconnect := SPaths.s5;
          ConfUsers[CurUser].SoundRename   := SPaths.s6;
          ConfUsers[CurUser].SoundStatus   := SPaths.s7;
          ConfUsers[CurUser].SoundFindLine := SPaths.s8;
          ConfUsers[CurUser].SoundCreate   := SPaths.s9;
          ConfUsers[CurUser].SoundReceived := SPaths.s10;
          ConfUsers[CurUser].SoundRefresh  := SPaths.s11;
        end;
        if CurUser = -1 then
        begin
          lNick.Font.Assign(DefUser.UserOnLineFS);
          lMouseOver.Font.Assign(DefUser.UserOnLineMouseOverFS);
          SPaths.s0 := DefUser.SoundAlert;
          SPaths.s1 := DefUser.SoundAlertToAll;
          SPaths.s2 := DefUser.SoundBoard;
          SPaths.s3 := DefUser.SoundText;
          SPaths.s4 := DefUser.SoundConnect;
          SPaths.s5 := DefUser.SoundDisconnect;
          SPaths.s6 := DefUser.SoundRename;
          SPaths.s7 := DefUser.SoundStatus;
          SPaths.s8 := DefUser.SoundFindLine;
          SPaths.s9 := DefUser.SoundCreate;
          SPaths.s10 := DefUser.SoundReceived;
          SPaths.s11 := DefUser.SoundRefresh;
          lUser.Caption := International.Strings[I_lUsers] +
            International.Strings[I_Default];
          //CurUser := -1;
        end;

        if not pUsers.Visible then
        begin
          pUsers.Show;
          pPodkluchenie.Hide;
          pCommon.Hide;
          pFont.Hide;
          pLangSkin.Hide;
          pMess.Hide;
//DChat 1.0
          pPlugins.Hide;
//DChat 1.0
        end;
      end;
    end;
  7:begin  // ������ pPlugins
      pPlugins.Show;
      pMess.Hide;
      pPodkluchenie.Hide;
      pCommon.Hide;
      pFont.Hide;
      pLangSkin.Hide;
      pUsers.Hide;
      //bAcceptTo.Hide;
    end;
//DChat 1.0
  end;
end;

procedure TFSettings.feMesBoardButtonClick(Sender: TObject);
begin
  if not FileExists(TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text)) then
    feMesBoard.Text := ''
  else
    feMesBoard.InitialDir := TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text);
end;

procedure TFSettings.feMesBoardKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
    if not FileExists(TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text)) then
      feMesBoard.Text := ''
    else
      feMesBoard.Text := ExtractFileName(feMesBoard.Text);
  end;
end;

procedure TFSettings.feMesBoardExit(Sender: TObject);
begin
  if not FileExists(TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text)) then
    feMesBoard.Text := ''
  else
    feMesBoard.Text := ExtractFileName(feMesBoard.Text);
end;

procedure TFSettings.bbEdBoardClick(Sender: TObject);
begin
  if not FileExists(TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text)) then
    feMesBoard.Text := ''
  else
  begin
    //FSettings.SetZOrder(False);
    ShellExecute(0, 'open', PChar(TPathBuilder.GetExePath() + ExtractFileName(feMesBoard.Text)),
      '', PChar(TPathBuilder.GetExePath()), 1);
  end;
end;

procedure TFSettings.fbSoundsItems11CreateFrame(Sender: TObject;
  var Frame: TCustomFrame);
begin
  CreateSFrame(Frame);
  (Frame as TSoundFrame).fePath.Text := SPaths.s11;
end;

procedure TFSettings.fbSoundsItems11FrameDestroy(Sender: TObject;
  var Frame: TCustomFrame; var CanDestroy: boolean);
begin
  SPaths.s11 := (Frame as TSoundFrame).fePath.Text;
end;

procedure TFSettings.SaveSet;
var
  m0, m1, m2, m3: boolean;
  UserPresent: boolean;
  //int:integer;
  i, j:   integer;
  IniStr: THashedStringList;
  IniT:   TMemIniFile;
  CLine:  TChatLine;
begin
  TDreamChatConfig.SetProtoName('iChat');//���� ���� �������� �� ������������
  if rMailSlots.Checked
    then TDreamChatConfig.SetServer('No')
    else TDreamChatConfig.SetServer('Yes');

  TDreamChatConfig.SetIP(eIPAdr.Text);
  TDreamChatConfig.SetPort(round(ePortNamb.Value));

  uFormMain.MinimizeOnClose := cbCloseButton.Checked;
  TDreamChatConfig.SetAppBringToFront(eHotKey.Text);
  TDreamChatConfig.SetCryptoKey(eCryptoKey.Text);
  SetNewCryptoKey(@eCryptoKey.Text[1], length(eCryptoKey.Text));
  FormMain.RefreshButton.Click;

  CLine := FormMain.GetMainLine;
  if CLine <> nil then
    begin
    if CLine.GetLocalUser <> nil then
      begin
      SavePrevNicks;
      end;
    CLine.ChatLineTabSheet.UseCloseBtn := uFormMain.MinimizeOnClose;
    end;

  if cbCloseButton.Checked then
  begin
    FormMain.BorderIcons := FormMain.BorderIcons - [biMinimize];
    CloseBtnString:='   ';
  end
  else
  begin
    FormMain.BorderIcons := FormMain.BorderIcons + [biMinimize];
    CloseBtnString:='';
  end;

  TDreamChatConfig.SetMessageBoard(feMesBoard.Text);

  case tcAutoM.TabIndex of
    0: Mes.St0.Text := lbMessages.Items.Text;
    1: Mes.St1.Text := lbMessages.Items.Text;
    2: Mes.St2.Text := lbMessages.Items.Text;
    else
      Mes.St3.Text := lbMessages.Items.Text;
  end;

  IniStr := THashedStringList.Create;
  TDreamChatConfig.GetStrings(IniStr);

  m0 := False;
  m1 := False;
  m2 := False;
  m3 := False;
  for i := 0 to IniStr.Count - 1 do
  begin
    if IniStr.Strings[i] = '[MessagesState0]' then
      m0 := True;
    if IniStr.Strings[i] = '[MessagesState1]' then
      m1 := True;
    if IniStr.Strings[i] = '[MessagesState2]' then
      m2 := True;
    if IniStr.Strings[i] = '[MessagesState3]' then
      m3 := True;
  end;

  if not m0 then
    IniStr.Add('[MessagesState0]');
  if not m1 then
    IniStr.Add('[MessagesState1]');
  if not m2 then
    IniStr.Add('[MessagesState2]');
  if not m3 then
    IniStr.Add('[MessagesState3]');

  for i := 0 to IniStr.Count - 1 do
    if IniStr.Strings[i] = '[MessagesState0]' then
    begin
      if IniStr.Count - 1 > i then
      begin
        while not IsSection(IniStr.Strings[i + 1]) do
        begin
          IniStr.Delete(i + 1);
        end;
        IniStr.Insert(i + 1, '');
        if Mes.St0.Count > 0 then
          for j := Mes.St0.Count - 1 downto 0 do
            IniStr.Insert(i + 1, Mes.St0.Strings[j]);
      end
      else
      begin
        IniStr.Add('');
        if Mes.St0.Count > 0 then
          for j := Mes.St0.Count - 1 downto 0 do
            IniStr.Add(Mes.St0.Strings[j]);
      end;
      break;
    end;
  for i := 0 to IniStr.Count - 1 do
    if IniStr.Strings[i] = '[MessagesState1]' then
    begin
      if IniStr.Count - 1 > i then
      begin
        while not IsSection(IniStr.Strings[i + 1]) do
        begin
          IniStr.Delete(i + 1);
        end;
        IniStr.Insert(i + 1, '');
        if Mes.St1.Count > 0 then
          for j := Mes.St1.Count - 1 downto 0 do
            IniStr.Insert(i + 1, Mes.St1.Strings[j]);
      end
      else
      begin
        IniStr.Add('');
        if Mes.St1.Count > 0 then
          for j := Mes.St1.Count - 1 downto 0 do
            IniStr.Add(Mes.St1.Strings[j]);
      end;
      break;
    end;
  for i := 0 to IniStr.Count - 1 do
    if IniStr.Strings[i] = '[MessagesState2]' then
    begin
      if IniStr.Count - 1 > i then
      begin
        while not IsSection(IniStr.Strings[i + 1]) do
        begin
          IniStr.Delete(i + 1);
        end;
        IniStr.Insert(i + 1, '');
        if Mes.St2.Count > 0 then
          for j := Mes.St2.Count - 1 downto 0 do
            IniStr.Insert(i + 1, Mes.St2.Strings[j]);
      end
      else
      begin
        IniStr.Add('');
        if Mes.St2.Count > 0 then
          for j := Mes.St2.Count - 1 downto 0 do
            IniStr.Add(Mes.St2.Strings[j]);
      end;
      break;
    end;
  for i := 0 to IniStr.Count - 1 do
    if IniStr.Strings[i] = '[MessagesState3]' then
    begin
      if IniStr.Count - 1 > i then
      begin
        while not IsSection(IniStr.Strings[i + 1]) do
        begin
          IniStr.Delete(i + 1);
        end;
        IniStr.Insert(i + 1, '');
        if Mes.St3.Count > 0 then
          for j := Mes.St3.Count - 1 downto 0 do
            IniStr.Insert(i + 1, Mes.St3.Strings[j]);
      end
      else
      begin
        IniStr.Add('');
        if Mes.St3.Count > 0 then
          for j := Mes.St3.Count - 1 downto 0 do
            IniStr.Add(Mes.St3.Strings[j]);
      end;
      break;
    end;
  TDreamChatConfig.SetStrings(IniStr);
  IniStr.Free;

  // TODO: move to language file
  TDreamChatConfig.SetReceivedMessage(eRes.Text);

  if DirectoryExists(sSkinManager1.SkinDirectory) then
  begin
    if pos(TPathBuilder.GetExePath(), sSkinManager1.SkinDirectory) = 0 then
      TDreamChatConfig.SetSkinsPath(sSkinManager1.SkinDirectory)
    else
      TDreamChatConfig.SetSkinsPath(
        copy(sSkinManager1.SkinDirectory, pos(TPathBuilder.GetExePath(), sSkinManager1.SkinDirectory) +
        length(TPathBuilder.GetExePath()) - 1, Length(sSkinManager1.SkinDirectory) -
        length(TPathBuilder.GetExePath()) + 1));
  end
  else
  if DirectoryExists(TPathBuilder.GetDefaultSkinsDirFull) then
    TDreamChatConfig.SetSkinsPath(TPathBuilder.GetDefaultSkinsDirFull());

  TDreamChatConfig.SetEnable(sSkinManager1.Active);
  TDreamChatConfig.SetSkinName(sSkinManager1.SkinName);
  TDreamChatConfig.SetSkinColor(sSkinManager1.HueOffset);

  UFormMain.FormMain.SkinManMain.SkinName := sSkinManager1.SkinName;
  UFormMain.FormMain.SkinManMain.SkinDirectory := sSkinManager1.SkinDirectory;
  UFormMain.FormMain.SkinManMain.HueOffset := sSkinManager1.HueOffset;
  UFormMain.FormMain.SkinManMain.Active := sSkinManager1.Active;
  UFormMain.FormMain.SkinManMain.SkinableMenus.UpdateMenus;

  if (LangFiles.Count > 0) and (FileExists(LangFiles.Values[cbLangChange.Text])) and
    (UFormMain.CurrLang <> LangFiles.Values[cbLangChange.Text]) then
    UFormMain.FormMain.ChangeLang(LangFiles.Values[cbLangChange.Text]);

  fbSounds.CollapseAll(False);

  if CurUser = -1 then
  begin
    DefUser.UserOnLineFS.Assign(lNick.Font);
    DefUser.UserOnLineMouseOverFS.Assign(lMouseOver.Font);
    DefUser.SoundAlert    := SPaths.s0;
    DefUser.SoundAlertToAll := SPaths.s1;
    DefUser.SoundBoard    := SPaths.s2;
    DefUser.SoundText     := SPaths.s3;
    DefUser.SoundConnect  := SPaths.s4;
    DefUser.SoundDisconnect := SPaths.s5;
    DefUser.SoundRename   := SPaths.s6;
    DefUser.SoundStatus   := SPaths.s7;
    DefUser.SoundFindLine := SPaths.s8;
    DefUser.SoundCreate   := SPaths.s9;
    DefUser.SoundReceived := SPaths.s10;
    DefUser.SoundRefresh  := SPaths.s11;
  end
  else
    if (Length(ConfUsers) > CurUser) and (CurUser >= 0) then
    begin
      ConfUsers[CurUser].UserOnLineFS.Assign(lNick.Font);
      ConfUsers[CurUser].UserOnLineMouseOverFS.Assign(lMouseOver.Font);
      ConfUsers[CurUser].SoundAlert    := SPaths.s0;
      ConfUsers[CurUser].SoundAlertToAll := SPaths.s1;
      ConfUsers[CurUser].SoundBoard    := SPaths.s2;
      ConfUsers[CurUser].SoundText     := SPaths.s3;
      ConfUsers[CurUser].SoundConnect  := SPaths.s4;
      ConfUsers[CurUser].SoundDisconnect := SPaths.s5;
      ConfUsers[CurUser].SoundRename   := SPaths.s6;
      ConfUsers[CurUser].SoundStatus   := SPaths.s7;
      ConfUsers[CurUser].SoundFindLine := SPaths.s8;
      ConfUsers[CurUser].SoundCreate   := SPaths.s9;
      ConfUsers[CurUser].SoundReceived := SPaths.s10;
      ConfUsers[CurUser].SoundRefresh  := SPaths.s11;
    end;

  if DefUser.Changed then
    DefUser.SaveUserSettingsToIni(FormMain.DefaultUser);
  if Length(ConfUsers) > 0 then
    for i := 0 to High(ConfUsers) do
      if ConfUsers[i].Changed then
      begin
        UserPresent := False;
        if (CLine <> nil) and (CLine.UsersCount > 0) then
        //���� ���� ������������ ��-����, ����� ��
        //��������� ��������� � ���������� ��� �������
        begin
          for j := 0 to CLine.UsersCount - 1 do
            begin
            if ConfUsers[i].ComputerName = CLine.ChatLineUsers[j].ComputerName then
              begin
              UserPresent := True;
              CLine.ChatLineUsers[j].UserOnLineFS.CharSet := ConfUsers[i].UserOnLineFS.Charset;
              CLine.ChatLineUsers[j].UserOnLineFS.FontName := ConfUsers[i].UserOnLineFS.Name;
              CLine.ChatLineUsers[j].UserOnLineFS.Size := ConfUsers[i].UserOnLineFS.Size;
              CLine.ChatLineUsers[j].UserOnLineFS.Color := ConfUsers[i].UserOnLineFS.Color;
              CLine.ChatLineUsers[j].UserOnLineFS.Style := ConfUsers[i].UserOnLineFS.Style;
              CLine.ChatLineUsers[j].UserOnLineMouseOverFS.CharSet :=
                ConfUsers[i].UserOnLineMouseOverFS.Charset;
              CLine.ChatLineUsers[j].UserOnLineMouseOverFS.FontName :=
                ConfUsers[i].UserOnLineMouseOverFS.Name;
              CLine.ChatLineUsers[j].UserOnLineMouseOverFS.Size :=
                ConfUsers[i].UserOnLineMouseOverFS.Size;
              CLine.ChatLineUsers[j].UserOnLineMouseOverFS.Color :=
                ConfUsers[i].UserOnLineMouseOverFS.Color;
              CLine.ChatLineUsers[j].UserOnLineMouseOverFS.Style :=
                ConfUsers[i].UserOnLineMouseOverFS.Style;
              CLine.ChatLineUsers[j].SoundDisconnect := ConfUsers[i].SoundDisconnect;
              CLine.ChatLineUsers[j].SoundConnect := ConfUsers[i].SoundConnect;
              CLine.ChatLineUsers[j].SoundText := ConfUsers[i].SoundText;
              CLine.ChatLineUsers[j].SoundAlert := ConfUsers[i].SoundAlert;
              CLine.ChatLineUsers[j].SoundAlertToAll := ConfUsers[i].SoundAlertToAll;
              CLine.ChatLineUsers[j].SoundReceived := ConfUsers[i].SoundReceived;
              CLine.ChatLineUsers[j].SoundStatus := ConfUsers[i].SoundStatus;
              CLine.ChatLineUsers[j].SoundBoard := ConfUsers[i].SoundBoard;
              CLine.ChatLineUsers[j].SoundRefresh := ConfUsers[i].SoundRefresh;
              CLine.ChatLineUsers[j].SoundRename := ConfUsers[i].SoundRename;
              CLine.ChatLineUsers[j].SoundCreate := ConfUsers[i].SoundCreate;
              CLine.ChatLineUsers[j].SoundFindLine := ConfUsers[i].SoundFindLine;
              Break;
              end;
            end;
        end;
        if not UserPresent then
        begin
          IniT := TMemIniFile.Create(ConfUsers[i].UserConfigFileName);
          try
            ConfUsers[i].SaveUserSettingsToIni(IniT);
          finally
            IniT.Free;
          end;
        end;
      end;

  CVStyle1.TextStyles.Items[0].CharSet  := lNormal.Font.Charset;
  CVStyle1.TextStyles.Items[0].Color    := lNormal.Font.Color;
  CVStyle1.TextStyles.Items[0].FontName := lNormal.Font.Name;
  CVStyle1.TextStyles.Items[0].Size     := lNormal.Font.Size;
  CVStyle1.TextStyles.Items[0].Style    := lNormal.Font.Style;
  CVStyle1.TextStyles.Items[1].CharSet  := lSystem.Font.Charset;
  CVStyle1.TextStyles.Items[1].Color    := lSystem.Font.Color;
  CVStyle1.TextStyles.Items[1].FontName := lSystem.Font.Name;
  CVStyle1.TextStyles.Items[1].Size     := lSystem.Font.Size;
  CVStyle1.TextStyles.Items[1].Style    := lSystem.Font.Style;
  CVStyle1.TextStyles.Items[2].CharSet  := lPrivat.Font.Charset;
  CVStyle1.TextStyles.Items[2].Color    := lPrivat.Font.Color;
  CVStyle1.TextStyles.Items[2].FontName := lPrivat.Font.Name;
  CVStyle1.TextStyles.Items[2].Size     := lPrivat.Font.Size;
  CVStyle1.TextStyles.Items[2].Style    := lPrivat.Font.Style;
  CVStyle1.TextStyles.Items[3].CharSet  := lBoard.Font.Charset;
  CVStyle1.TextStyles.Items[3].Color    := lBoard.Font.Color;
  CVStyle1.TextStyles.Items[3].FontName := lBoard.Font.Name;
  CVStyle1.TextStyles.Items[3].Size     := lBoard.Font.Size;
  CVStyle1.TextStyles.Items[3].Style    := lBoard.Font.Style;
  CVStyle1.TextStyles.Items[4].CharSet  := lLink.Font.Charset;
  CVStyle1.TextStyles.Items[4].Color    := lLink.Font.Color;
  CVStyle1.TextStyles.Items[4].FontName := lLink.Font.Name;
  CVStyle1.TextStyles.Items[4].Size     := lLink.Font.Size;
  CVStyle1.TextStyles.Items[4].Style    := lLink.Font.Style;
  CVStyle1.TextStyles.Items[5].CharSet  := lOnLink.Font.Charset;
  CVStyle1.TextStyles.Items[5].Color    := lOnLink.Font.Color;
  CVStyle1.TextStyles.Items[5].FontName := lOnLink.Font.Name;
  CVStyle1.TextStyles.Items[5].Size     := lOnLink.Font.Size;
  CVStyle1.TextStyles.Items[5].Style    := lOnLink.Font.Style;
  CVStyle1.TextStyles.Items[6].CharSet  := lInfoName.Font.Charset;
  CVStyle1.TextStyles.Items[6].Color    := lInfoName.Font.Color;
  CVStyle1.TextStyles.Items[6].FontName := lInfoName.Font.Name;
  CVStyle1.TextStyles.Items[6].Size     := lInfoName.Font.Size;
  CVStyle1.TextStyles.Items[6].Style    := lInfoName.Font.Style;
  CVStyle1.TextStyles.Items[7].CharSet  := lInfoText.Font.Charset;
  CVStyle1.TextStyles.Items[7].Color    := lInfoText.Font.Color;
  CVStyle1.TextStyles.Items[7].FontName := lInfoText.Font.Name;
  CVStyle1.TextStyles.Items[7].Size     := lInfoText.Font.Size;
  CVStyle1.TextStyles.Items[7].Style    := lInfoText.Font.Style;
  CVStyle1.TextStyles.Items[8].CharSet  := lMeText.Font.Charset;
  CVStyle1.TextStyles.Items[8].Color    := lMeText.Font.Color;
  CVStyle1.TextStyles.Items[8].FontName := lMeText.Font.Name;
  CVStyle1.TextStyles.Items[8].Size     := lMeText.Font.Size;
  CVStyle1.TextStyles.Items[8].Style    := lMeText.Font.Style;

  for i := 0 to 8 do
    uFormMain.FormMain.CVStyle1.TextStyles.Items[i].Assign(
      Self.CVStyle1.TextStyles.Items[i]);

  uFormMain.FormMain.Edit1.Font.Assign(eMess.Font);

  for i := 0 to uFormMain.ChatLines.Count - 1 do
  begin
    CLine := TChatLine(uFormMain.ChatLines.Objects[i]);
    if CLine <> nil then CLine.ChatLineTree.Font.Assign(tUsers.Font);
  end;
end;

procedure TFSettings.bAceptClick(Sender: TObject);
begin
  SaveSet;
end;

procedure TFSettings.WriteNick(nick: string);
var MainLine: TChatLine;
    tLocalUser:TChatUser;
begin
MainLine := UFormMain.FormMain.GetMainLine();
if MainLine <> nil then
  begin
  tLocalUser := MainLine.GetLocalUser;
  if tLocalUser <> nil then
    begin
    if uFormMain.LocalNickName <> nick then
      begin
      UFormMain.FormMain.Edit1.Text := '/nickname ' + nick;
      PostMessage(UFormMain.FormMain.Edit1.Handle, WM_KEYUP, 13, 0);
      end;
    end;
  end;
end;

procedure TFSettings.Init;
var
  i, j:    cardinal;
  ComputerName:    PChar;
  UserPresent: boolean;
  int:     integer;
  stemp:   string;
  sr:      TSearchRec;
  TmpUserFont: TFont;
  UsrList: THashedStringList;
  IniT:    TMemIniFile;
  MainLine: TChatLine;
begin
  //if UFormMain.FormMain.ChatConfig.ReadString('ConnectionType', 'Server', 'No') = 'No' then
  if TDreamChatConfig.GetServer() = 'No' then //TODO: magic number!
  begin
    rVidelServ.Checked := False;
    rMailSlots.Checked := True;
  end
  else
  begin
    rMailSlots.Checked := False;
    rVidelServ.Checked := True;
  end;

  eIPAdr.Text     := CheckIP(TDreamChatConfig.GetIP() {UFormMain.FormMain.ChatConfig.ReadString(
    'ConnectionType', 'IP', '127.0.0.1')});
  ePortNamb.Value := TDreamChatConfig.GetPort(); //UFormMain.FormMain.ChatConfig.ReadInteger('ConnectionType', 'Port', 6666);

//dchat 1.0
  eHotKey.Text := TDreamChatConfig.GetAppBringToFront;
  eCryptoKey.Text := TDreamChatConfig.GetCryptoKey();

  eCryptoKey.Enabled := true;
  rbUserKey.Checked := true;
  if eCryptoKey.Text = 'tahci' then
    begin
    eCryptoKey.Enabled := false;
    rbIChatKey.Checked := true;
    end;
  if eCryptoKey.Text = 'tihci' then
    begin
    eCryptoKey.Enabled := false;
    rbAntiHackKey.Checked := true;
    end;
//TDreamChatConfig.SetProtoName('UserKey')

  lNames.Clear;
  //stemp := UFormMain.FormMain.ChatConfig.ReadString('Common', 'NickName', International.Strings[I_nnm]);
  stemp := TDreamChatConfig.GetNickName;

  if stemp = ''
    then stemp := International.Strings[I_nnm];

  try
    i := MAX_PATH;
    GetMem(ComputerName, i);
    GetComputerName(ComputerName, i);
    if string(ComputerName) = stemp then
    begin
      rFromName.Checked := True
    end
    else
    begin
      FreeMem(ComputerName);
      i := MAX_PATH;
      GetMem(ComputerName, i);
      GetUserName(ComputerName, i);
      if string(ComputerName) <> stemp then
      begin
        rName.Checked    := True;
        lNames.ItemIndex := lNames.Items.Add(stemp);
      end;
    end;
  finally
    FreeMem(ComputerName);
    stemp := '';
  end;

  feMesBoard.Text := TDreamChatConfig.GetMessageBoard(); //UFormMain.FormMain.ChatConfig.ReadString('Common', 'MessageBoard', feMesBoard.Text);

  PNicksCount := min(255, max(0, TDreamChatConfig.GetPrevNicksCount())); //UFormMain.FormMain.ChatConfig.ReadInteger('Common', 'PrevNicksCount', 0)));
  for i := 1 to PNicksCount do
    //lNames.Items.Add(UFormMain.FormMain.ChatConfig.ReadString('Common', 'PrevNick' + IntToStr(i), International.Strings[I_nnm]));
    lNames.Items.Add(TDreamChatConfig.GetPrevNick(i));

  cbCloseButton.Checked := uFormMain.MinimizeOnClose; // TODO: consider removing this global variable

{  UFormMain.FormMain.ChatConfig.ReadSectionValues('MessagesState0', Mes.St0);
  UFormMain.FormMain.ChatConfig.ReadSectionValues('MessagesState1', Mes.St1);
  UFormMain.FormMain.ChatConfig.ReadSectionValues('MessagesState2', Mes.St2);
  UFormMain.FormMain.ChatConfig.ReadSectionValues('MessagesState3', Mes.St3);}
  TDreamChatConfig.FillMessagesState0(Mes.St0);
  TDreamChatConfig.FillMessagesState1(Mes.St1);
  TDreamChatConfig.FillMessagesState2(Mes.St2);
  TDreamChatConfig.FillMessagesState3(Mes.St3);

  lbMessages.Items.Text := Mes.St0.Text;
  lbMessages.ItemIndex := 0;
  eRes.Text := TDreamChatConfig.GetReceivedMessage(); //UFormMain.FormMain.ChatConfig.ReadString('Common', 'ReceivedMessage', eRes.Text);

  eSkinPath.Text  := UFormMain.FormMain.SkinManMain.SkinDirectory;
  sSkinManager1.SkinDirectory := UFormMain.FormMain.SkinManMain.SkinDirectory;
  sSkinManager1.SkinName := UFormMain.FormMain.SkinManMain.SkinName;
  sSkinManager1.HueOffset := UFormMain.FormMain.SkinManMain.HueOffset;
  tColor.Position := sSkinManager1.HueOffset;
  sSkinManager1.Active := UFormMain.FormMain.SkinManMain.Active;
  if sSkinManager1.Active then
    cbSkin.ItemIndex := cbSkin.IndexOf(sSkinManager1.SkinName)
  else
    cbSkin.ItemIndex := 0;

  stemp := TDreamChatConfig.GetLanguageFileName();// UFormMain.FormMain.ChatConfig.ReadString('Common', 'Language', 'Languages\Russian.lng');
  //sshowmessage(stemp);
  if (stemp <> '') and (ExtractFileDrive(stemp) = '') then
    stemp := TPathBuilder.GetExePath() + stemp;
  //sshowmessage(stemp);
  if FileExists(stemp) then
  begin
    IniT := TMemIniFile.Create(stemp);
    ChangeLang(stemp);
    cbLangChange.Text := IniT.ReadString('Common', 'Name', '�������');
    IniT.Free;
    LangFiles.Clear;
    cbLangChange.Items.Clear;
    if FindFirst(ExtractFilePath(stemp) + '*.lng', faAnyFile, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faAnyFile) = sr.Attr then
        begin
          IniT := TMemIniFile.Create(ExtractFilePath(stemp) + sr.Name);
          cbLangChange.Items.Add(IniT.ReadString('Common', 'Name', '�������'));
          LangFiles.Add(IniT.ReadString('Common', 'Name', '�������') + '=' +
            ExtractFilePath(stemp) + sr.Name);
          IniT.Free;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end
  else
  if FileExists(TPathBuilder.GetExePath() + 'Languages\Russian.lng') then
  begin
    IniT := TMemIniFile.Create(TPathBuilder.GetExePath() + 'Languages\Russian.lng');
    ChangeLang(TPathBuilder.GetExePath() + 'Languages\Russian.lng');
    cbLangChange.Text := IniT.ReadString('Common', 'Name', '�������');
    IniT.Free;
    LangFiles.Clear;
    cbLangChange.Items.Clear;
    if FindFirst(TPathBuilder.GetExePath() + 'Languages\*.lng', faAnyFile, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faAnyFile) = sr.Attr then
        begin
          IniT := TMemIniFile.Create(TPathBuilder.GetExePath() + 'Languages\' + sr.Name);
          cbLangChange.Items.Add(IniT.ReadString('Common', 'Name', '�������'));
          LangFiles.Add(IniT.ReadString('Common', 'Name', '�������') +
            '=' + ExtractFilePath(stemp) + sr.Name);
          IniT.Free;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;

  MainLine := FormMain.GetMainLine;

  DefUser.LoadUserSettingsFromIni(FormMain.DefaultUser);
  DefUser.Changed := False;
  lNick.Font.Assign(DefUser.UserOnLineFS);
  lMouseOver.Font.Assign(DefUser.UserOnLineMouseOverFS);
  SPaths.s0  := DefUser.SoundAlert;
  SPaths.s1  := DefUser.SoundAlertToAll;
  SPaths.s2  := DefUser.SoundBoard;
  SPaths.s3  := DefUser.SoundText;
  SPaths.s4  := DefUser.SoundConnect;
  SPaths.s5  := DefUser.SoundDisconnect;
  SPaths.s6  := DefUser.SoundRename;
  SPaths.s7  := DefUser.SoundStatus;
  SPaths.s8  := DefUser.SoundFindLine;
  SPaths.s9  := DefUser.SoundCreate;
  SPaths.s10 := DefUser.SoundReceived;
  SPaths.s11 := DefUser.SoundRefresh;
  CurUser    := -1;

  int     := 0;
  IniT    := TMemIniFile.Create(TPathBuilder.GetExePath() + 'Users\FileList.txt');
  UsrList := THashedStringList.Create;
  IniT.ReadSectionValues('UsersID', UsrList);
  IniT.Free;
  TmpUserFont := TFont.Create;
  if UsrList.Count > 0 then
    for i := 0 to UsrList.Count - 1 do
    begin
      UserPresent := False;

      if MainLine.UsersCount > 0 then
        for j := 0 to MainLine.UsersCount - 1 do
          if UsrList.Names[i] = MainLine.ChatLineUsers[j].ComputerName then
          begin
            UserPresent := True;
            SetLength(ConfUsers, int + 1);
            ConfUsers[int] := TConfigChatUser.Create;
            uChatUser.FontInfoToFont(MainLine.ChatLineUsers[j].UserOnLineFS, TmpUserFont);
            ConfUsers[int].UserOnLineFS.Assign(TmpUserFont);
            uChatUser.FontInfoToFont(MainLine.ChatLineUsers[j].UserOnLineMouseOverFS,
              TmpUserFont);
            ConfUsers[int].UserOnLineMouseOverFS.Assign(TmpUserFont);
            ConfUsers[int].SoundDisconnect :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundDisconnect);
            ConfUsers[int].SoundConnect  :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundConnect);
            ConfUsers[int].SoundText     :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundText);
            ConfUsers[int].SoundAlert    :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundAlert);
            ConfUsers[int].SoundAlertToAll :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundAlertToAll);
            ConfUsers[int].SoundReceived :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundReceived);
            ConfUsers[int].SoundStatus   :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundStatus);
            ConfUsers[int].SoundBoard    :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundBoard);
            ConfUsers[int].SoundRefresh  :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundRefresh);
            ConfUsers[int].SoundRename   :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundRename);
            ConfUsers[int].SoundCreate   :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundCreate);
            ConfUsers[int].SoundFindLine :=
              ConfUsers[int].GetSoundFileName(MainLine.ChatLineUsers[j].SoundFindLine);
            ConfUsers[int].UserNickNames.Assign(MainLine.ChatLineUsers[j].UserNickNames);
            if FileExists(TPathBuilder.GetUsersFolderName() {UFormMain.ExePath + 'Users\'} + UsrList.ValueFromIndex[i] + '.txt') then
              ConfUsers[int].UserConfigFileName :=
                TPathBuilder.GetUsersFolderName() {UFormMain.ExePath + 'Users\'} + UsrList.ValueFromIndex[i] + '.txt';
            ConfUsers[int].ComputerName := UsrList.Names[i];
            ConfUsers[int].Changed := False;
            if ConfUsers[int].GetLastNick <> '' then
              ConfUsers[int].UserTreeNode :=
                tPanelSel.Items.AddChildObject(tPanelSel.Items.Item[5], ConfUsers[int].GetLastNick,
                ConfUsers[int])
            else
              ConfUsers[int].UserTreeNode :=
                tPanelSel.Items.AddChildObject(tPanelSel.Items.Item[5], International.Strings[I_nnm],
                ConfUsers[int]);
            Inc(int);
            Break;
          end;

      if (not UserPresent) and (FileExists(TPathBuilder.GetUsersFolderName() {UFormMain.ExePath + 'Users\'} +
        UsrList.ValueFromIndex[i] + '.txt')) then
      begin
        SetLength(ConfUsers, int + 1);
        ConfUsers[int] := TConfigChatUser.Create;
        try
          ConfUsers[int].UserConfigFileName :=
            TPathBuilder.GetUsersFolderName() {UFormMain.ExePath + 'Users\'} + UsrList.ValueFromIndex[i] + '.txt';
          IniT := TMemIniFile.Create(ConfUsers[int].UserConfigFileName);
          ConfUsers[int].LoadUserSettingsFromIni(IniT);
          ConfUsers[int].Changed := False;
        finally
          IniT.Free;
        end;
        ConfUsers[int].ComputerName := UsrList.Names[i];
        if ConfUsers[int].GetLastNick <> '' then
          ConfUsers[int].UserTreeNode :=
            tPanelSel.Items.AddChildObject(tPanelSel.Items.Item[5], ConfUsers[int].GetLastNick,
            ConfUsers[int])
        else
          ConfUsers[int].UserTreeNode :=
            tPanelSel.Items.AddChildObject(tPanelSel.Items.Item[5], International.Strings[I_nnm],
            ConfUsers[int]);
        Inc(int);
      end;
    end;
  ConfUsersReady := True;
  TmpUserFont.Free;
  UsrList.Free;

  for i := 0 to 8 do
    CVStyle1.TextStyles.Items[i].Assign(uFormMain.FormMain.CVStyle1.TextStyles.Items[i]);

  lNormal.Font.Charset:=CVStyle1.TextStyles.Items[0].CharSet;
  lNormal.Font.Color:=CVStyle1.TextStyles.Items[0].Color;
  lNormal.Font.Name:=CVStyle1.TextStyles.Items[0].FontName;
  lNormal.Font.Size:=CVStyle1.TextStyles.Items[0].Size;
  lNormal.Font.Style:=CVStyle1.TextStyles.Items[0].Style;
  lSystem.Font.Charset:=CVStyle1.TextStyles.Items[1].CharSet;
  lSystem.Font.Color:=CVStyle1.TextStyles.Items[1].Color;
  lSystem.Font.Name:=CVStyle1.TextStyles.Items[1].FontName;
  lSystem.Font.Size:=CVStyle1.TextStyles.Items[1].Size;
  lSystem.Font.Style:=CVStyle1.TextStyles.Items[1].Style;
  lPrivat.Font.Charset:=CVStyle1.TextStyles.Items[2].CharSet;
  lPrivat.Font.Color:=CVStyle1.TextStyles.Items[2].Color;
  lPrivat.Font.Name:=CVStyle1.TextStyles.Items[2].FontName;
  lPrivat.Font.Size:=CVStyle1.TextStyles.Items[2].Size;
  lPrivat.Font.Style:=CVStyle1.TextStyles.Items[2].Style;
  lBoard.Font.Charset:=CVStyle1.TextStyles.Items[3].CharSet;
  lBoard.Font.Color:=CVStyle1.TextStyles.Items[3].Color;
  lBoard.Font.Name:=CVStyle1.TextStyles.Items[3].FontName;
  lBoard.Font.Size:=CVStyle1.TextStyles.Items[3].Size;
  lBoard.Font.Style:=CVStyle1.TextStyles.Items[3].Style;
  lLink.Font.Charset:=CVStyle1.TextStyles.Items[4].CharSet;
  lLink.Font.Color:=CVStyle1.TextStyles.Items[4].Color;
  lLink.Font.Name:=CVStyle1.TextStyles.Items[4].FontName;
  lLink.Font.Size:=CVStyle1.TextStyles.Items[4].Size;
  lLink.Font.Style:=CVStyle1.TextStyles.Items[4].Style;
  lOnLink.Font.Charset:=CVStyle1.TextStyles.Items[5].CharSet;
  lOnLink.Font.Color:=CVStyle1.TextStyles.Items[5].Color;
  lOnLink.Font.Name:=CVStyle1.TextStyles.Items[5].FontName;
  lOnLink.Font.Size:=CVStyle1.TextStyles.Items[5].Size;
  lOnLink.Font.Style:=CVStyle1.TextStyles.Items[5].Style;
  lInfoName.Font.Charset:=CVStyle1.TextStyles.Items[6].CharSet;
  lInfoName.Font.Color:=CVStyle1.TextStyles.Items[6].Color;
  lInfoName.Font.Name:=CVStyle1.TextStyles.Items[6].FontName;
  lInfoName.Font.Size:=CVStyle1.TextStyles.Items[6].Size;
  lInfoName.Font.Style:=CVStyle1.TextStyles.Items[6].Style;
  lInfoText.Font.Charset:=CVStyle1.TextStyles.Items[7].CharSet;
  lInfoText.Font.Color:=CVStyle1.TextStyles.Items[7].Color;
  lInfoText.Font.Name:=CVStyle1.TextStyles.Items[7].FontName;
  lInfoText.Font.Size:=CVStyle1.TextStyles.Items[7].Size;
  lInfoText.Font.Style:=CVStyle1.TextStyles.Items[7].Style;
  lMeText.Font.Charset:=CVStyle1.TextStyles.Items[8].CharSet;
  lMeText.Font.Color:=CVStyle1.TextStyles.Items[8].Color;
  lMeText.Font.Name:=CVStyle1.TextStyles.Items[8].FontName;
  lMeText.Font.Size:=CVStyle1.TextStyles.Items[8].Size;
  lMeText.Font.Style:=CVStyle1.TextStyles.Items[8].Style;

  eMess.Font.Assign(uFormMain.FormMain.Edit1.Font);

  tUsers.Font.Assign(MainLine.ChatLineTree.Font);

  tUsers.Items.Item[0].Expand(True);
  tUsers.Items.Item[2].Expand(True);
end;

procedure TFSettings.ChangeLang(LangFile: string);
var
  MemIniStrings: TMemIniFile;
begin
  International.BeginUpdate;
  MemIniStrings := TMemIniFile.Create(LangFile);
  International.Strings[I_dc] := MemIniStrings.ReadString('Settings', 'dc', rsdc);
  International.Strings[I_n] := MemIniStrings.ReadString('Settings', 'n', rsn);
  International.Strings[I_nnm] := MemIniStrings.ReadString('Settings', 'nnm', rsnnm);
  International.Strings[I_NoAvailabS] :=
    MemIniStrings.ReadString('Settings', 'NoAvailabS', rsNoAvailabS);
  International.Strings[I_NoSkin] :=
    MemIniStrings.ReadString('Settings', 'NoSkin', rsNoSkin);
  International.Strings[I_NoC] := MemIniStrings.ReadString('Settings', 'NoC', rsNoC);
  International.Strings[I_Nm] := MemIniStrings.ReadString('Settings', 'Nm', rsNm);
  International.Strings[I_Vm] := MemIniStrings.ReadString('Settings', 'Vm', rsVm);
  International.Strings[I_M0] := MemIniStrings.ReadString('Settings', 'M0', rsM0);
  International.Strings[I_M1] := MemIniStrings.ReadString('Settings', 'M1', rsM1);
  International.Strings[I_M2] := MemIniStrings.ReadString('Settings', 'M2', rsM2);
  International.Strings[I_M3] := MemIniStrings.ReadString('Settings', 'M3', rsM3);
  International.Strings[I_lUsers] :=
    MemIniStrings.ReadString('Settings', 'lUsers', rslUsers) + ' ';
  International.Strings[I_Default] :=
    MemIniStrings.ReadString('Settings', 'Default', rsDefault);
  International.Strings[I_Path] := MemIniStrings.ReadString('Settings', 'Path', rsPath);

  Self.Caption := MemIniStrings.ReadString('Settings', 'FSettings', Self.Caption);
  bAcept.Caption  := MemIniStrings.ReadString('Settings', 'bAcept', bAcept.Caption);
  bCancel.Caption := MemIniStrings.ReadString('Settings', 'bCancel', bCancel.Caption);
  bOk.Caption     := MemIniStrings.ReadString('Settings', 'bOk', bOk.Caption);
  eMess.Text      := MemIniStrings.ReadString('Settings', 'eMess', eMess.Text);
  lBoard.Caption  := MemIniStrings.ReadString('Settings', 'lBoard', lBoard.Caption);
  lInfoName.Caption := MemIniStrings.ReadString('Settings', 'lInfoName', lInfoName.Caption);
  lInfoText.Caption := MemIniStrings.ReadString('Settings', 'lInfoText', lInfoText.Caption);
  lLink.Caption   := MemIniStrings.ReadString('Settings', 'lLink', lLink.Caption);
  lMeText.Caption := MemIniStrings.ReadString('Settings', 'lMeText', lMeText.Caption);
  lNormal.Caption := MemIniStrings.ReadString('Settings', 'lNormal', lNormal.Caption);
  lOnLink.Caption := MemIniStrings.ReadString('Settings', 'lOnLink', lOnLink.Caption);
  lPrivat.Caption := MemIniStrings.ReadString('Settings', 'lPrivat', lPrivat.Caption);
  lSystem.Caption := MemIniStrings.ReadString('Settings', 'lSystem', lSystem.Caption);
  tUsers.Items.Item[0].Text := MemIniStrings.ReadString(
    'Settings', 'tUsers_Item0', tUsers.Items.Item[0].Text);
  tUsers.Items.Item[3].Text := tUsers.Items.Item[0].Text;
  tUsers.Items.Item[1].Text := MemIniStrings.ReadString(
    'Settings', 'tUsers_Item1', tUsers.Items.Item[1].Text);
  tUsers.Items.Item[2].Text := tUsers.Items.Item[1].Text;
  lFonts.Caption  := MemIniStrings.ReadString('Settings', 'lFonts', lFonts.Caption);
  gSkin.Caption   := MemIniStrings.ReadString('Settings', 'gSkin', gSkin.Caption);
  cbSkin.Items.Strings[0] := International.Strings[I_NoSkin];
  cbSkin.BoundLabel.Caption := MemIniStrings.ReadString(
    'Settings', 'cbSkin_BoundLabel', cbSkin.BoundLabel.Caption);
  if sSkinManager1.Active then
    cbSkin.ItemIndex := cbSkin.IndexOf(sSkinManager1.SkinName)
  else
    cbSkin.ItemIndex := 0;
  eSkinPath.BoundLabel.Caption :=
    MemIniStrings.ReadString('Settings', 'eSkinPath_BoundLabel', eSkinPath.BoundLabel.Caption);
  lColor.Caption    := MemIniStrings.ReadString('Settings', 'lColor', lColor.Caption);
  lLangSkin.Caption := MemIniStrings.ReadString('Settings', 'lLangSkin', lLangSkin.Caption);
  gbBoard.Caption   := MemIniStrings.ReadString('Settings', 'gbBoard', gbBoard.Caption);
  bbEdBoard.Caption := MemIniStrings.ReadString('Settings', 'bbEdBoard', bbEdBoard.Caption);
  feMesBoard.BoundLabel.Caption :=
    MemIniStrings.ReadString('Settings', 'feMesBoard_BoundLabel',
    feMesBoard.BoundLabel.Caption);
  gReceived.Caption := MemIniStrings.ReadString('Settings', 'gReceived', gReceived.Caption);
  lMess.Caption     := MemIniStrings.ReadString('Settings', 'lMess', lMess.Caption);
  tcAutoM.Tabs.Strings[0] := MemIniStrings.ReadString(
    'Settings', 'tcAutoM_Tabs0', tcAutoM.Tabs.Strings[0]);
  tcAutoM.Tabs.Strings[1] := MemIniStrings.ReadString(
    'Settings', 'tcAutoM_Tabs1', tcAutoM.Tabs.Strings[1]);
  tcAutoM.Tabs.Strings[2] := MemIniStrings.ReadString(
    'Settings', 'tcAutoM_Tabs2', tcAutoM.Tabs.Strings[2]);
  tcAutoM.Tabs.Strings[3] := MemIniStrings.ReadString(
    'Settings', 'tcAutoM_Tabs3', tcAutoM.Tabs.Strings[3]);
  bbAdd.Caption     := MemIniStrings.ReadString('Settings', 'bbAdd', bbAdd.Caption);
  bbDel.Caption     := MemIniStrings.ReadString('Settings', 'bbDel', bbDel.Caption);
  bbDown.Caption    := MemIniStrings.ReadString('Settings', 'bbDown', bbDown.Caption);
  bbEdit.Caption    := MemIniStrings.ReadString('Settings', 'bbEdit', bbEdit.Caption);
  bbUp.Caption      := MemIniStrings.ReadString('Settings', 'bbUp', bbUp.Caption);
  PopupMenu1.Items.Items[0].Caption :=
    MemIniStrings.ReadString('Settings', 'PopupMenu1_Items0',
    PopupMenu1.Items.Items[0].Caption);
  PopupMenu1.Items.Items[1].Caption :=
    MemIniStrings.ReadString('Settings', 'PopupMenu1_Items1',
    PopupMenu1.Items.Items[1].Caption);
  PopupMenu1.Items.Items[2].Caption :=
    MemIniStrings.ReadString('Settings', 'PopupMenu1_Items2',
    PopupMenu1.Items.Items[2].Caption);
  gbCrypto.Caption := MemIniStrings.ReadString(
    'Settings', 'gbCrypto', gbCrypto.Caption);
//  cProto.Caption    := MemIniStrings.ReadString('Settings', 'cProto', cProto.Caption);
  gServer.Caption   := MemIniStrings.ReadString('Settings', 'gServer', gServer.Caption);
  eIPAdr.BoundLabel.Caption := MemIniStrings.ReadString(
    'Settings', 'eIPAdr_BoundLabel', eIPAdr.BoundLabel.Caption);
  ePortNamb.BoundLabel.Caption :=
    MemIniStrings.ReadString('Settings', 'ePortNamb_BoundLabel', ePortNamb.BoundLabel.Caption);
  gSoedinenie.Caption := MemIniStrings.ReadString(
    'Settings', 'gSoedinenie', gSoedinenie.Caption);
  rMailSlots.Caption := MemIniStrings.ReadString(
    'Settings', 'rMailSlots', rMailSlots.Caption);
  rVidelServ.Caption := MemIniStrings.ReadString(
    'Settings', 'rVidelServ', rVidelServ.Caption);
  lPodkl.Caption    := MemIniStrings.ReadString('Settings', 'lPodkl', lPodkl.Caption);
  pNameSel.Caption  := MemIniStrings.ReadString('Settings', 'pNameSel', pNameSel.Caption);
  rFromLogon.Caption := MemIniStrings.ReadString(
    'Settings', 'rFromLogon', rFromLogon.Caption);
  rFromName.Caption := MemIniStrings.ReadString('Settings', 'rFromName', rFromName.Caption);
  rName.Caption     := MemIniStrings.ReadString('Settings', 'rName', rName.Caption);
  if CurUser = -1 then
    lUser.Caption := International.Strings[I_lUsers] + International.Strings[I_Default]
  else
  if (Length(ConfUsers) > CurUser) and (CurUser >= 0) then
    lUser.Caption := International.Strings[I_lUsers] + ConfUsers[CurUser].GetAllNicks;
  gbUserFonts.Caption := MemIniStrings.ReadString(
    'Settings', 'gbUserFonts', gbUserFonts.Caption);
  lNick.Caption      := MemIniStrings.ReadString('Settings', 'lNick', lNick.Caption);
  lMouseOver.Caption := MemIniStrings.ReadString(
    'Settings', 'lMouseOver', lMouseOver.Caption);
  gbSounds.Caption   := MemIniStrings.ReadString('Settings', 'gbSounds', gbSounds.Caption);
  fbSounds.Items.Items[0].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item0', fbSounds.Items.Items[0].Caption);
  fbSounds.Items.Items[1].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item1', fbSounds.Items.Items[1].Caption);
  fbSounds.Items.Items[2].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item2', fbSounds.Items.Items[2].Caption);
  fbSounds.Items.Items[3].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item3', fbSounds.Items.Items[3].Caption);
  fbSounds.Items.Items[4].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item4', fbSounds.Items.Items[4].Caption);
  fbSounds.Items.Items[5].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item5', fbSounds.Items.Items[5].Caption);
  fbSounds.Items.Items[6].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item6', fbSounds.Items.Items[6].Caption);
  fbSounds.Items.Items[7].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item7', fbSounds.Items.Items[7].Caption);
  fbSounds.Items.Items[8].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item8', fbSounds.Items.Items[8].Caption);
  fbSounds.Items.Items[9].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item9', fbSounds.Items.Items[9].Caption);
  fbSounds.Items.Items[10].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item10', fbSounds.Items.Items[10].Caption);
  fbSounds.Items.Items[11].Caption :=
    MemIniStrings.ReadString('Settings', 'fbSounds_Item11', fbSounds.Items.Items[11].Caption);
  tPanelSel.Items.Item[0].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item0', tPanelSel.Items.Item[0].Text);
  tPanelSel.Items.Item[1].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item1', tPanelSel.Items.Item[1].Text);
  tPanelSel.Items.Item[2].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item2', tPanelSel.Items.Item[2].Text);
  tPanelSel.Items.Item[3].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item3', tPanelSel.Items.Item[3].Text);
  tPanelSel.Items.Item[4].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item4', tPanelSel.Items.Item[4].Text);
  tPanelSel.Items.Item[5].Text :=
    MemIniStrings.ReadString('Settings', 'tPanelSel_Item5', tPanelSel.Items.Item[5].Text);
  //DChat 1.0
  tPanelSel.Items.Item[6].Text:=
    MemIniStrings.ReadString('Settings','tPanelSel_Item6',tPanelSel.Items.Item[6].Text);
  gbCrypto.Caption :=
    MemIniStrings.ReadString('Settings','gbCrypto', gbCrypto.caption);
  gbHotKey.Caption :=
    MemIniStrings.ReadString('Settings','gbHotKey', gbHotKey.caption);
  rbIChatKey.Caption :=
    MemIniStrings.ReadString('Settings', 'rbIChatKey', rbIChatKey.Caption);
  rbAntiHackKey.Caption :=
    MemIniStrings.ReadString('Settings', 'rbAntiHackKey', rbAntiHackKey.Caption);
  //rbUserKey.Caption :=
  eCryptoKey.BoundLabel.Caption :=
    MemIniStrings.ReadString('Settings', 'rbUserKey', rbUserKey.Caption);
  lComm.Caption :=
    MemIniStrings.ReadString('Settings', 'lCommon', lComm.Caption);
  gbDifferent.Caption :=
    MemIniStrings.ReadString('Settings', 'gbDifferent', gbDifferent.Caption);
  cbClosebutton.Caption :=
    MemIniStrings.ReadString('Settings', 'cbClosebutton', cbClosebutton.Caption);
  eHotKey.BoundLabel.Caption :=
    MemIniStrings.ReadString('Settings', 'eHotKey', eHotKey.BoundLabel.Caption);
  //DChat 1.0
  gbLanguage.Caption := MemIniStrings.ReadString(
    'Settings', 'gbLanguage', gbLanguage.Caption);

  MemIniStrings.Free;
  International.EndUpdate;
  CurrLang := LangFile;
end;

procedure TFSettings.cbLangChangeChange(Sender: TObject);
begin
  if (LangFiles.Count > 0) and (FileExists(LangFiles.Values[cbLangChange.Text])) and
    (CurrLang <> LangFiles.Values[cbLangChange.Text]) then
    ChangeLang(LangFiles.Values[cbLangChange.Text]);
end;

procedure TFSettings.CreateSFrame(var f: TCustomFrame);
begin
  f := TSoundFrame.Create(nil);
  (f as TSoundFrame).sFrameAdapter1.SkinData.FSkinManager := sSkinManager1;
  (f as TSoundFrame).fePath.SkinData.FSkinManager := sSkinManager1;
  (f as TSoundFrame).sbPlay.SkinData.FSkinManager := sSkinManager1;
  (f as TSoundFrame).sbStop.SkinData.FSkinManager := sSkinManager1;
  (f as TSoundFrame).fePath.BoundLabel.Caption := International.Strings[I_Path];
end;

procedure TFSettings.SavePrevNicks;
var
  i: integer;
  j: Cardinal;
  tempName: PChar;
begin
  if rName.Checked then
  begin
    if lNames.ItemIndex = -1
      then lNames.ItemIndex := 0; // select first item in list of nicknames if nothing selected

    if (lNames.Count > 0) and (lNames.Items.Strings[lNames.ItemIndex] <> '') then
    begin
      //UFormMain.FormMain.ChatConfig.WriteString('Common','NickName',lNames.Items.Strings[lNames.ItemIndex]);
      WriteNick(lNames.Items.Strings[lNames.ItemIndex]);
      TDreamChatConfig.SetPrevNicksCount(lNames.Count - 1); //UFormMain.FormMain.ChatConfig.WriteInteger('Common', 'PrevNicksCount', lNames.Count - 1);
      j := 0;
      if lNames.Count - 1 > 0 then
        for i := 0 to lNames.Count - 1 do
        begin
          if i <> lNames.ItemIndex then
          begin
            Inc(j);
            //UFormMain.FormMain.ChatConfig.WriteString('Common', 'PrevNick' + IntToStr(j), lNames.Items.Strings[i]);
            TDreamChatConfig.SetPrevNick(j, lNames.Items.Strings[i]);
          end;
        end;

      // delete extra prev nicks
      if PNicksCount > lNames.Count - 1 then
        for i := lNames.Count to PNicksCount do
          //UFormMain.FormMain.ChatConfig.DeleteKey('Common', 'PrevNick' + IntToStr(i));
          TDreamChatConfig.DeletePrevNick(i);
    end
    else
    begin
      //UFormMain.FormMain.ChatConfig.WriteString('Common','NickName',nnm);
      WriteNick(International.Strings[I_nnm]);
      TDreamChatConfig.SetPrevNicksCount(0);
      // no prev nicks
      for i := 1 to PNicksCount do
        TDreamChatConfig.DeletePrevNick(i); // delete all prev nicks
    end;
  end
  else  // triggers when rName.Checked is False
  begin
    if rFromName.Checked then
    begin
      j := MAX_PATH;
      GetMem(tempName, j);
      GetComputerName(tempName, j);
      //UFormMain.FormMain.ChatConfig.WriteString('Common','NickName',string(name));
      WriteNick(string(tempName));
      FreeMem(tempName);
      TDreamChatConfig.SetPrevNicksCount(lNames.Count);
      //UFormMain.FormMain.ChatConfig.WriteInteger('Common', 'PrevNicksCount', lNames.Count);
      if lNames.Count > 0 then
        for i := 1 to lNames.Count do
          //UFormMain.FormMain.ChatConfig.WriteString('Common', 'PrevNick' + IntToStr(i), lNames.Items.Strings[i - 1]);
          TDreamChatConfig.SetPrevNick(i, lNames.Items.Strings[i - 1]);
    end
    else
    begin
      j := MAX_PATH;
      GetMem(tempName, j);
      GetUserName(tempName, j);
      //UFormMain.FormMain.ChatConfig.WriteString('Common','NickName',string(name));
      WriteNick(string(tempName));
      FreeMem(tempName);
      TDreamChatConfig.SetPrevNicksCount(lNames.Count);
      //UFormMain.FormMain.ChatConfig.WriteInteger('Common', 'PrevNicksCount', lNames.Count);
      if lNames.Count > 0 then
        for i := 1 to lNames.Count do
          //UFormMain.FormMain.ChatConfig.WriteString('Common', 'PrevNick' + IntToStr(i), lNames.Items.Strings[i - 1]);
          TDreamChatConfig.SetPrevNick(i, lNames.Items.Strings[i - 1]);
    end;
  end;
end;

procedure TFSettings.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  ConfUsersReady := False;
  tPanelSel.Items.BeginUpdate;
  if Length(ConfUsers) > 0 then
    for i := 0 to High(ConfUsers) do
      if ConfUsers[i] <> nil then
      begin
        tPanelSel.Items.Delete(ConfUsers[i].UserTreeNode);
        FreeAndNil(ConfUsers[i]);
      end;
  tPanelSel.Items.EndUpdate;
  SetLength(ConfUsers, 0);
end;

//DChat 1.0
procedure TFSettings.pPluginsClick(Sender: TObject);
begin
messagebox(0, PChar(''), PChar('pPluginsClick'), mb_ok);
end;

procedure TFSettings.rbAntiHackKeyClick(Sender: TObject);
begin
eCryptoKey.Text := 'tihci';
eCryptoKey.Enabled := false;
SetNewCryptoKey(@eCryptoKey.Text[1], length(eCryptoKey.Text));
end;

procedure TFSettings.rbIChatKeyClick(Sender: TObject);
begin
eCryptoKey.Text := 'tahci';
eCryptoKey.Enabled := false;
SetNewCryptoKey(@eCryptoKey.Text[1], length(eCryptoKey.Text));
end;

procedure TFSettings.rbUserKeyClick(Sender: TObject);
begin
eCryptoKey.Enabled := true;
SetNewCryptoKey(@eCryptoKey.Text[1], length(eCryptoKey.Text));
end;
//DChat 1.0

end.
