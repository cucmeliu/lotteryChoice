program lottery;

uses
  Forms,
  frmMain in 'frmMain.pas' {Form1},
  sgr_misc in 'sgr_misc.pas',
  defineUnit in 'defineUnit.pas',
  barGraphi in 'barGraphi.pas',
  MyGraphi in 'MyGraphi.pas',
  frmBar in 'frmBar.pas' {BarForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '²ÊÆ±Ñ¡ºÅ»ú';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TBarForm, BarForm);
  Application.Run;
end.
