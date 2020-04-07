unit DreamChatTranslater;

interface

uses Classes;

type

TDreamChatTranslaterIDs =
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

  TDreamChatTranslater = class
  private
    FStrings: TStrings;
    function GetData(index: integer): string;
    constructor Create;
    destructor Destroy; override;
  public
    procedure Load(IniFileName: string);
    property Data[index: integer]: string read GetData; default;
    class function Translate(id: TDreamChatTranslaterIDs): string;
  end;

implementation

uses IniFiles, SysUtils, DreamChatConfig, uPathBuilder;

{ TDreamChatStrings }

constructor TDreamChatTranslater.Create;
begin
  inherited Create;
  FStrings := TStringList.Create;
end;

destructor TDreamChatTranslater.Destroy;
begin
  FreeAndNil(FStrings);
  inherited Destroy;
end;

function TDreamChatTranslater.GetData(index: integer): string;
var
  id: string;
begin
  id := IntToStr(index);
  Result := FStrings.Values[id];

  if Result = '' //additionally check value names like '01' '02' etc
    then Result := FStrings.Values['0'+ id];

  if Result = '' //additionally check value names like '001' '002' etc
    then Result := FStrings.Values['00'+ id];
end;

procedure TDreamChatTranslater.Load(IniFileName: string);
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

var
  instance: TDreamChatTranslater = nil;

class function TDreamChatTranslater.Translate(id: TDreamChatTranslaterIDs): string;
begin
  if instance = nil then begin
    instance := TDreamChatTranslater.Create();
//    instance.Load(TPathBuilder.GetExePath() + ChatConfig.ReadString(TDreamChatConfig.Common {'Common'}, TDreamChatConfig.Language {'Language'}, 'Languages\English.lng'););
  end;

end;

end.

