unit DreamChatStrings;

interface

uses Classes;

type

TDreamChatStringIDs =
(
//[Form]
  I_COMMONCHAT,          //'�����'
  I_PRIVATE,             //'������'
  I_LINE,                //'�����'
  I_MESSAGESBOARD,       //����� ����������
  I_MESSAGESBOARDUPDATE, //��������� ����� ����������
  I_USERCONNECTED,       //� ��� ��������:
  I_USERDISCONNECTED,    //��� ������� :
  I_NOTANSWERING,
  I_PRIVATEWITH,         //������ ��� �
  I_USERRENAME,          //�������� ��� ��
//[PopUpMenu]
  I_CLOSE,               //�������
  I_REFRESH,             //��������
  I_SAVELOG,             //��������� ���
  I_PRIVATEMESSAGE,      //������ ���������
  I_PRIVATEMESSAGETOALL, //������ ��������� ����
  I_CREATELINE,          //������� �����
  I_TOTALIGNOR,          //������������ ��� ���������
  I_USERINFO,            //� ������������
  I_COMETOPRIVATE,       //����� � ������
  I_COMETOLINE,          //����� � �����
//[UserInfo]
  I_DISPLAYNICKNAME,
  I_NICKNAME,
  I_IP,
  I_COMPUTERNAME,
  I_LOGIN,
  I_CHATVER,
  I_COMMDLLVER,
  I_STATE,
//[NewLine]
  I_INPUTPASSWORD,
  I_COMING,               //�����
  I_INPUTPASSANDLINENAME, //������� �������� � ������ ��� ����� �����:
  I_CREATE,
  I_NEWLINE,
  I_CANCEL,
  I_LINENAME,
  I_PASSWORD,
//[MainPopUpMenu]
  I_EXIT,

  I_SEESHARE,             //������� � �������� ����������
  I_WRITENICKNAME         //�������� ��� �����
  );

  TDreamChatStrings = class
  private
    FStrings: TStrings;
    function GetData(index: integer): string;
    procedure SetData(index: integer; value: string);
    constructor Create;
    destructor Destroy; override;
  public

    procedure Load(IniFileName: string);
    property Data[index: integer]: string read GetData write SetData; default;
  end;

implementation

uses IniFiles, SysUtils;

{ TDreamChatStrings }

constructor TDreamChatStrings.Create;
begin
  inherited Create;
  FStrings := TStringList.Create;
end;

destructor TDreamChatStrings.Destroy;
begin
  FreeAndNil(FStrings);
  inherited Destroy;
end;

function TDreamChatStrings.GetData(index: integer): string;
begin
  Result := FStrings.Values[IntToStr(index)];
end;

procedure TDreamChatStrings.Load(IniFileName: string);
var
  MemIniStrings: TMemIniFile;
  //i, i_end: integer;
begin
  MemIniStrings := TMemIniFile.Create(IniFileName);

  //CurrLang := ExePath + ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.Language {'Language'}, 'Languages\English.lng');

  MemIniStrings.ReadSection('Strings', FStrings);

{  i_end := Section.Count - 1;
  for i := 0 to i_end do
    begin
    FStrings.Add(MemIniStrings.ReadString('Strings', InttoStr(i + 10), ''));//Strings
    //EInternational.Add(MemIniStrings.ReadString('ErrorStrings', InttoStr(i + 10), ''));
    end;}
end;

procedure TDreamChatStrings.SetData(index: integer; value: string);
begin

end;

end.

