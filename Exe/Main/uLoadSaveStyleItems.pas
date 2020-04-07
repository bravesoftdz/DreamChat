unit uLoadSaveStyleItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CVStyle, StdCtrls;

type
  TFontInfoLoadSave = class(TComponent)
  //������������ ������ ��� ��������/���������� ���������
  protected
    procedure DefineProperties(Filer: TFiler);override;
  private
    FFontInfos: TFontInfos;
    procedure ReadFontInfos(Reader: TReader);
    procedure WriteFontInfos(Writer: TWriter);
    //procedure DefineProperties(Filer: TFiler);override;
  public
    property TextStyles: TFontInfos read FFontInfos write FFontInfos;
    Constructor Create(Component: TComponent);override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent);override;{virtual;}
  end;

type
  TTXTStyle = class(TFontInfoLoadSave)
  //������������ �������������� ��������� �� TXT � OBJECT � �����
  private
  public
    Function SetStyleItems(i: integer; TXTSection: String): boolean;
    //Function SetStyleSection0(Sections: String): boolean;
    Function GetTXTStyleItems(i: integer): String;
    //Function GetStyleSection0(): String;
  end;

implementation

{.$R *.dfm}

function ComponentToString(Component: TComponent): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
begin
  ss := TStringStream.Create(' ');
  ms := TMemoryStream.Create;
  try
    ms.WriteComponent(Component);
    ms.position := 0;
    ObjectBinaryToText(ms, ss);
    ss.position := 0;
    Result := ss.DataString;
  finally
    ms.Free;
    ss.free;
  end;
end;

procedure StringToComponent(Component: TComponent; Value: string);
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
{==============================================================================}
Constructor TFontInfoLoadSave.Create(Component: TComponent);
begin
inherited Create(Component);
FFontInfos := TFontInfos.Create;
Name := 'FontInfoSave';//� ����� �� ��� ����������?!
end;

destructor TFontInfoLoadSave.Destroy;
begin
  FFontInfos.Free;
  inherited;
end;

procedure TFontInfoLoadSave.Assign(Source: TPersistent);
begin
  if Source is TFontInfoLoadSave then
    begin
    self.FFontInfos.Assign(TFontInfoLoadSave(Source).FFontInfos);
    end;
end;

procedure TFontInfoLoadSave.ReadFontInfos(Reader: TReader);
begin
Reader.ReadValue;
Reader.ReadCollection(FFontInfos);
end;

procedure TFontInfoLoadSave.WriteFontInfos(Writer: TWriter);
begin
Writer.WriteCollection(FFontInfos);
end;

procedure TFontInfoLoadSave.DefineProperties(Filer: TFiler);
begin
inherited;
Filer.DefineProperty('TextStyles', ReadFontInfos, WriteFontInfos, true);
end;
{==============================================================================}

Function TTXTStyle.SetStyleItems(i: integer; TXTSection: String): boolean;
var S: String;
    FontInfoSave: TFontInfoLoadSave;
    //n: integer;
    //StringList: TStringList;
Begin
//��������! ���������� ������ �� ����� ������ �� ���!!!!!!!!!!!!!
//� ������� ���������� TXTSection:
//      CharSet = ANSI_CHARSET
//      FontName = 'Arial'
//      Size = 10
//      Color = clBlue
//      Style = [fsBold]
if i < 0 then i := 0;
if (self.TextStyles.Count = 0) then
  begin
  self.TextStyles.Add;//��������� ����� ��������� �����. � ���� ����� ������ 0.
                      //���� �� ��� ������������ ��������!
  end;
if (i > self.TextStyles.Count - 1) then
  begin
  self.TextStyles.Add;//��������� ����� ��������� �����. � ���� ����� ������ 0.
                      //���� �� ��� ������������ ��������!
  i := self.TextStyles.Count - 1
  end;
//����������� TXT � ������ ����� � ���������� �� ����� � ������� i
//�� ������� ����������� �������������� �� �������� DFM
S := 'object FontInfoSave: TFontInfoSave'#13#10 +
     '  TextStyles = <'#13#10 +
     '    item'#13#10 +
     TXTSection + #13#10 +
     '    end>'#13#10 +
     'end';
//������ ������������!
//MessageBox(0, PChar(S), PChar(IntToStr(0)), MB_OK);
//������� "����������������"
FontInfoSave := TFontInfoLoadSave.Create(nil);
try
  StringToComponent(FontInfoSave, S);
  result := true;
except
  result := false;
end;
//������������ ����� � ������ ����� ��������� �������
self.TextStyles.Items[i].Assign(FontInfoSave.TextStyles.Items[0]);//<- ���� "0" �
//���� ����������� ������ ������� �� ���!
FontInfoSave.Free;
End;

{Function TTXTStyle.SetStyleSection0(Sections: String): boolean;
var S: String;
Begin
S := 'object FontInfoSave: TFontInfoSave'#13#10 +
     '  TextStyles = <'#13#10 +
     '    item'#13#10 +
     Sections + #13#10 +
     '    end>'#13#10 +
     'end';
try
  StringToComponent(self, s);
  result := true;
except
  result := false;
end;
end;
}
Function TTXTStyle.GetTXTStyleItems(i: integer): String;
var //S: String;
    FontInfoSave: TFontInfoLoadSave;
    StringList: TStringList;
Begin
//������ Self �������� � ���� �������� FFontInfos, � ������� ����� ������
//��������-������. ���� ������ �������� ��������� ������������� ������� ����� i
result := '';
if (i >= 0) and (i <= self.TextStyles.Count - 1) then
  begin
  StringList := TStringList.Create;//��������������� ����������))
  //�� ���������� ������ ������� ������ � ����������� ��� � TXT
  //������� "����������������"
  FontInfoSave := TFontInfoLoadSave.Create(nil);
  FontInfoSave.Name := 'TXTFontInfoSave';
  FontInfoSave.TextStyles.Add;
  FontInfoSave.TextStyles.Items[0].Assign(self.TextStyles.Items[i]);
  //� �������� TXT
  StringList.Text := ComponentToString(FontInfoSave);
  //������� ������ �� ���������� OBJECT ITEMS < > END END
  if StringList.Count > 5 then
    begin
    StringList.Delete(0);
    StringList.Delete(0);
    StringList.Delete(0);

    StringList.Delete(StringList.Count - 1);
    StringList.Delete(StringList.Count - 1);

    for i := 0 to StringList.Count - 1 do
      begin
      StringList.Strings[i] := TrimLeft(StringList.Strings[i]);
      end;
    end;
  result := StringList.Text;
  FontInfoSave.Free;
  StringList.Free;
  end;
End;

{Function TTXTStyle.GetStyleSection0(): String;
var StringList: TStringList;
Begin
StringList := TStringList.Create;
StringList.Text := ComponentToString(Self);
if StringList.Count > 5 then
  begin
  StringList.Delete(0);
  StringList.Delete(0);
  StringList.Delete(0);

  StringList.Delete(StringList.Count - 1);
  StringList.Delete(StringList.Count - 1);
  end;
result := StringList.Text;
StringList.Free;
end;}
{==============================================================================}

end.

