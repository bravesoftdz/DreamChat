//�������� � ���, ��� � �������� � ���������� ����������� � *.dpr ������
//�������� ������ �� ������������ ������� *.pas
//������� ����� ������ ����� ������ � ������ �����������
unit uCommonUnitObj;

interface

uses  Classes;

type
  TPersonalCrypto = packed record
    PersonalOpenKey     : array [0..255] of byte;
    LenPersonalOpenKey  : word;
    PersonalSecretKey   : array [0..255] of byte;
    LenPersonalSecretKey: word;
end;
  pPersonalCrypto = ^TPersonalCrypto;

var
  CryptoKeyForRemoteComputers                                    :TStringList;

implementation

end.


