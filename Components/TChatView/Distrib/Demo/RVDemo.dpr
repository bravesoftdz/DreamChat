program RVDemo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  BackStyl in 'BackStyl.pas' {frmBackStyle},
  PrintFrm in 'PrintFrm.pas' {frmPrint};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmBackStyle, frmBackStyle);
  Application.CreateForm(TfrmPrint, frmPrint);
  Application.Run;
end.
