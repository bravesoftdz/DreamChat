//Autor Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03 ver 1
//2011.08.12 ver 1.1

//DreamChat is published under a double license. You can choose which one fits
//better for you, either Mozilla Public License (MPL) or Lesser General Public
//License (LGPL). For more info about MPL read the MPL homepage. For more info
//about LGPL read the LGPL homepage.

library TestPlugin2;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ExceptionLog,
  SysUtils,
  Classes;

const
   DChatTestPluginVersion = 1;

Type
  TPluginType = (Test, Visual, Communication, SoundEvents, Protocol, ClientServer);

Type
  TPluginInfo = packed record
  PluginComment: shortstring;           // �������� �������
  PluginAutorName: shortstring;         // ��� ������
  PluginName: shortstring;              // �������� �������
  InternalPluginFileName: shortstring;  // ��������� �����
  PluginType: TPluginType;              // ��� �������
  PluginAPIVersion: shortstring;        // ������ ������ ������������ ������� �������
  PluginManagerAPIVersion: shortstring; // ������ ���������� ������ ������������ ������� (������ ������ ���������)
end;
PPluginInfo = ^TPluginInfo;

{type
  TInitFunction = function(i:integer):PChar;
  TShutDownFunction = function(i:integer):PChar;}

var
  PluginInfo: TPluginInfo;

{$R *.res}

Function Init(ModuleHandle: HMODULE; pCallBackFunction:pointer; ExePath:PChar):PChar;
begin
result := 'Init ok!';
end;

Function ShutDown():PChar;
begin
result := 'ShutDown ok!';
end;

Function GetPluginType(var PluginTypeNote: PChar):byte;
Var MyNote: String;
begin
MyNote := ' �������� ������ �� PluginManagera: ' + PluginTypeNote;
PluginTypeNote := PChar(MyNote);
result := 255;
end;

{------------------------------------------------------------------------------}
Function GetPluginInfo():PPluginInfo;
begin
PluginInfo.PluginComment := '����������� ��������� ������� 2';
PluginInfo.PluginAutorName := 'Bajenov';
PluginInfo.PluginName := '���������� 2';
PluginInfo.InternalPluginFileName := 'TestPlugin2.dll';
PluginInfo.PluginType := Test;
PluginInfo.PluginAPIVersion := inttostr(DChatTestPluginVersion);// ������ ������ ������������ ������� �������
//PluginInfo.PluginAPIVersion := '1';//������� ������
PluginInfo.PluginManagerAPIVersion := '4';// ������ ������ ������������ ������� �������
result := @PluginInfo;
end;

Function ExecuteCommand(Command: PChar; Data: PChar; DataSize: cardinal):PChar;//Return errorcode or 0 if succef
begin
result := Pchar('ExecuteCommand ' + Command);
end;

{------------------------------------------------------------------------------}

exports
Init name 'Init',
ShutDown name 'ShutDown',
GetPluginInfo name 'GetPluginInfo',
ExecuteCommand name 'ExecuteCommand';

begin
end.
