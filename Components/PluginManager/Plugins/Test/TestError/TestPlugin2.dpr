//Autor Bajenov Andrey
//All right reserved.
//Saint-Petersburg, Russia
//2007.02.03

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
  SysUtils,
  Classes;

Type
  TPluginType = (Test, Visual, Communication, SoundEvents, Protocol);

Type
  TPluginInfo = record
  PluginComment: shortstring;           // �������� �������
  PluginAutorName: shortstring;         // ��� ������
  PluginName: shortstring;              // �������� �������
  InternalPluginFileName: shortstring;  // ��������� �����
  PluginType: TPluginType;              // ��� �������
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
PluginInfo.PluginComment := '� ���� ������� ��� TestFunction1';
PluginInfo.PluginAutorName := 'Bajenov';
PluginInfo.PluginName := '���� ������';
PluginInfo.InternalPluginFileName := 'Plugin_err2.dll';
PluginInfo.PluginType := Test;
result := @PluginInfo;
end;

Function TestFunction1(i:integer):PChar;
begin
result := 'TestFunction1 executed!';
end;

Function TestFunction2(i:integer):PChar;
begin
result := 'TestFunction2 executed!';
end;
{------------------------------------------------------------------------------}

exports
Init index 0 name 'Init',
ShutDown index 1 name 'ShutDown',
GetPluginType index 2 name 'GetPluginType',
GetPluginInfo index 3 name 'GetPluginInfo',
//TestFunction1 index 4 name 'TestFunction1',
TestFunction2 index 5 name 'TestFunction2';

begin
end.
