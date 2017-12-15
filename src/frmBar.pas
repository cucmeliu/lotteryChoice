unit frmBar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, RzPanel, RzDlgBtn, barGraphi, defineUnit;

type
  TBarForm = class(TForm)
    RzDialogButtons1: TRzDialogButtons;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    StatGraphiGrid: TStatGraphiGrid;
  public
    { Public declarations }
    procedure setData(ancra:TNumCntRecArray);
    procedure setBarColor(acolor: TColor);
  end;

var
  BarForm: TBarForm;

implementation

{$R *.dfm}

procedure TBarForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        StatGraphiGrid.Free;
        action := cafree;
end;

procedure TBarForm.FormCreate(Sender: TObject);
begin
        StatGraphiGrid := TStatGraphiGrid.Create(self);
        StatGraphiGrid.Align := alClient;
        StatGraphiGrid.MaxCount := 100;
end;

procedure TBarForm.FormPaint(Sender: TObject);
begin
  StatGraphiGrid.Reset;
end;

procedure TBarForm.setBarColor(acolor: TColor);
begin
  StatGraphiGrid.BarColor := acolor;
end;

procedure TBarForm.setData(ancra: TNumCntRecArray);
begin
  StatGraphiGrid.setData(ancra);
end;

end.
