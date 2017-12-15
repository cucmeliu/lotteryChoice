unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzTabs, jpeg, ExtCtrls, RzPanel, RzButton, RzBorder, StdCtrls,
  RzLabel, RzLstBox, ComCtrls, RzListVw, RzRadChk, Mask, RzEdit, RzSpnEdt,
  ActnList, defineUnit;

type   

  TForm1 = class(TForm)
    RzPageControl1: TRzPageControl;
    TabSheet1: TRzTabSheet;
    RzStatusBar1: TRzStatusBar;
    RzToolbar1: TRzToolbar;
    RzLEDDisplay1: TRzLEDDisplay;
    RzLEDDisplay2: TRzLEDDisplay;
    RzLEDDisplay3: TRzLEDDisplay;
    RzLEDDisplay4: TRzLEDDisplay;
    RzLEDDisplay5: TRzLEDDisplay;
    RzLEDDisplay6: TRzLEDDisplay;
    RzLEDDisplay7: TRzLEDDisplay;
    RzLabel1: TRzLabel;
    RzBitBtn1: TRzBitBtn;
    Timer1: TTimer;
    RzBitBtn2: TRzBitBtn;
    RzLabel2: TRzLabel;
    RzLabel3: TRzLabel;
    RzListBox1: TRzListBox;
    RzListView1: TRzListView;
    RzListView2: TRzListView;
    RzBitBtn4: TRzBitBtn;
    RzBitBtn5: TRzBitBtn;
    RzCheckBox1: TRzCheckBox;
    RzBitBtn6: TRzBitBtn;
    RzSpinEdit1: TRzSpinEdit;
    Timer2: TTimer;
    RzLabel4: TRzLabel;
    RzLEDDisplay8: TRzLEDDisplay;
    RzLabel5: TRzLabel;
    RzToolButton1: TRzToolButton;
    RzLVStats: TRzListView;
    RzURLLabel1: TRzURLLabel;
    ActionList1: TActionList;
    actCalc: TAction;
    actGenRandom: TAction;
    actGenOnce: TAction;
    actGenTimes: TAction;
    actResetData: TAction;
    Action6: TAction;
    RzURLLabel2: TRzURLLabel;
    RzURLLabel3: TRzURLLabel;
    RzURLLabel4: TRzURLLabel;
    procedure actResetDataExecute(Sender: TObject);
    procedure RzURLLabel3Click(Sender: TObject);
    procedure RzURLLabel4Click(Sender: TObject);
    procedure actGenTimesExecute(Sender: TObject);
    procedure actGenOnceExecute(Sender: TObject);
    procedure actGenRandomExecute(Sender: TObject);
    procedure RzURLLabel2Click(Sender: TObject);
    procedure RzLEDDisplay8DblClick(Sender: TObject);
    procedure RzSpinEdit1Change(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure RzBitBtn4Click(Sender: TObject);
    procedure RzBitBtn5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    redNums:array[1..33] of byte; // 一组双色球中的红号
    blueNum: byte; // 蓝号
    fRunTimes, fCurTimes: integer;
    fTotalTimes: integer;//
    fRedNCRA, fBlueNCRA: TNumCntRecArray;

    //blueNums:array[1..16] of byte;
    procedure reset();
    procedure genBlueNum();
    procedure genRedNums();
    procedure showSSQ();
    procedure start();
    procedure init();
    procedure CreateListRed();
    procedure CreateListblue();
    procedure createListStat();
    procedure createLists();
    procedure resetListRed();
    procedure resetListBlue();
    procedure resetLEDTotal();
    procedure UpdateListRed();
    procedure UpdateListBlue();
    procedure UpdateListStat();
    procedure UpdateLists();
    function getStr(num: byte): string;
    function getMostBlue(): TNumCntRec;
    procedure getMostRed(var mr: TNumCntRecArray);

    
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses frmBar;

{$R *.dfm}

{ TForm1 }


procedure TForm1.actGenOnceExecute(Sender: TObject);
begin
  reset;
  genRedNums;           
  genBlueNum;
  showSSQ;
  UpdateLists();
end;

procedure TForm1.actGenRandomExecute(Sender: TObject);
begin
  Timer1.Enabled := not Timer1.Enabled;
  if not timer1.Enabled then
  begin
    UpdateLists();
  end;
end;

procedure TForm1.actGenTimesExecute(Sender: TObject);
begin 
  fCurTimes := 0;
  fRunTimes := RzSpinEdit1.IntValue;
  Timer2.Enabled := true;
  actGenTimes.Enabled := false;
end;

procedure TForm1.actResetDataExecute(Sender: TObject);
begin
  init();
  reset();
  resetLEDTotal();
  resetListRed();
  resetListBlue();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  fCurTimes := 0;
  fRunTimes := RzSpinEdit1.IntValue;;
  fTotalTimes := 0;
  setLength(fRedNCRA, 33);
  setLength(fBlueNCRA, 16);
  init;
  
  reset();

  CreateLists();

end;

procedure TForm1.genBlueNum;
begin
  randomize();
  blueNum := 1+random(16);
  inc(fBlueNCRA[blueNum-1].Rcount);
end;

procedure TForm1.genRedNums;
var
  i, num: byte; 
begin
  randomize();
  i := 0;
  while (i<6) do
  begin
    num := 1+random(33);
    if redNums[num] = 1 then
      continue
    else begin
       redNums[num] := 1;
       inc(i);
       inc(fRedNCRA[num-1].Rcount );
    end;    

  end;

end;

function TForm1.getMostBlue: TNumCntRec;
var
  i: integer;
  rst: TNumCntRec;
begin
  rst := fBlueNCRA[0];
  for i := 1 to length(fBlueNCRA) - 1 do
  begin
    if fBlueNCRA[i].Rcount>rst.Rcount then
      rst := fBlueNCRA[i];
  end;
  result := rst;
    
end;

procedure TForm1.getMostRed(var mr: TNumCntRecArray);
begin

end;

function TForm1.getStr(num: byte): string;
begin
  if num<10 then
    result := '0'+ inttostr(num)
  else result := inttostr(num);
end;

procedure TForm1.reset;
var
  i: byte;
begin
  blueNum := 0;
  
  for i := 1 to 33 do
    redNums[i] := 0;

  RzLEDDisplay1.Caption := getStr(0);
  RzLEDDisplay2.Caption := getStr(0);
  RzLEDDisplay3.Caption := getStr(0);
  RzLEDDisplay4.Caption := getStr(0);
  RzLEDDisplay5.Caption := getStr(0);
  RzLEDDisplay6.Caption := getStr(0);
  RzLEDDisplay7.Caption := getStr(0);

  //initListCol;
end;

procedure TForm1.resetLEDTotal;
begin
  fTotalTimes := 0;
  RzLEDDisplay8.Caption := inttostr(fTotalTimes);
end;

procedure TForm1.resetListBlue;
var
  item: TListItem;
  i: integer;
begin
  item := RzListView2.Items.Item[0];
    for i := 0 to 15 do
  begin
    item.SubItems[i] := '0';
  end;
end;

procedure TForm1.resetListRed;
var
  item: TListItem;
  i: integer;
begin
  item := RzListView1.Items.Item[0];
    for i := 0 to 32 do
  begin
    item.SubItems[i] := '0';
  end;
end;

procedure TForm1.init;
var
  i: integer;
begin
  for i := 0 to length(fRedNCRA) - 1 do
  begin
    fRedNCRA[i].Number := i+1;
    fRedNCRA[i].Rcount := 0;
  end;
  for i := 0 to length(fBlueNCRA) - 1 do
  begin
    fBlueNCRA[i].Number := i+1;
    fBlueNCRA[i].Rcount := 0;
  end;
end;

procedure TForm1.CreateListblue;
var
  i: integer;
  col: TListColumn;
  item: TListItem;
begin
  col := RzListView2.Columns.Add();
    col.Width := 5;
    col.Caption := '';
  for I := 1 to 16 do
  begin      
    col := RzListView2.Columns.Add();
    col.Width := 25;
    col.Caption := inttostr(i);
  end;
  
  item := RzListView2.Items.Add();
  for i := 1 to 16 do
  begin
    item.SubItems.Add('0')
  end; 

end;

procedure TForm1.CreateListRed;
var
  i: integer;
  col: TListColumn;
  item: TListItem;
begin
    col := RzListView1.Columns.Add();
    col.Width := 5;
    col.Caption := '';
  for I := 1 to 33 do
  begin      
    col := RzListView1.Columns.Add();
    col.Width := 25;
    col.Caption := inttostr(i);
  end;
  
  item := RzListView1.Items.Add();
  for i := 1 to 33 do
  begin
    item.SubItems.Add('0')
  end;

end;

procedure TForm1.createLists;
begin
  CreateListRed();
  CreateListblue();
  createListStat();
end;

procedure TForm1.createListStat;
var
  i: integer;
  item: TListItem;
begin
  for i := 0 to 6 do
  begin
    item := RzLVStats.Items[i];
    item.SubItems.Add('');
    item.SubItems.Add('');
  end;
    

end;

procedure TForm1.RzBitBtn4Click(Sender: TObject);
var
  frm: TBarForm;
begin
  frm := TBarForm.Create(nil);
  frm.setData(fBlueNCRA);

  frm.ShowModal;
  frm.Free;
end;

procedure TForm1.RzBitBtn5Click(Sender: TObject);
var
  frm: TBarForm;
begin
  frm := TBarForm.Create(nil);
  frm.setData(fRedNCRA);
  frm.setBarColor(clRed);
  frm.ShowModal;
  frm.Free;
end;

procedure TForm1.RzLEDDisplay8DblClick(Sender: TObject);
begin
  resetLEDTotal();

end;

procedure TForm1.RzSpinEdit1Change(Sender: TObject);
begin
  fRunTimes :=RzSpinEdit1.IntValue;
end;

procedure TForm1.RzURLLabel2Click(Sender: TObject);
begin
  RzListBox1.Clear;
end;

procedure TForm1.RzURLLabel3Click(Sender: TObject);
begin
  resetListRed;
end;

procedure TForm1.RzURLLabel4Click(Sender: TObject);
begin
  resetListBlue;
end;

procedure TForm1.showSSQ;
var
  i, count: integer;
  redseled: array[1..6] of byte; 
begin

  count := 0;
  for i := 1 to 6 do
    redseled[i] := 0;
    
  for i := 1 to 33 do
  begin
    if redNums[i]=1 then
    begin
      inc(count);
      redseled[count] := i;
    end;
  end;

  RzLEDDisplay1.Caption := getStr(redseled[1]);
  RzLEDDisplay2.Caption := getStr(redseled[2]);
  RzLEDDisplay3.Caption := getStr(redseled[3]);
  RzLEDDisplay4.Caption := getStr(redseled[4]);
  RzLEDDisplay5.Caption := getStr(redseled[5]);
  RzLEDDisplay6.Caption := getStr(redseled[6]);
  RzLEDDisplay7.Caption := getStr(blueNum);  


  //在列表框中显示
  if not RzCheckBox1.Checked then
    RzListBox1.Items.Insert(0,getStr(redseled[1]) + ' '
            + getStr(redseled[2]) + ' '
            + getStr(redseled[3]) + ' '
            + getStr(redseled[4]) + ' '
            + getStr(redseled[5]) + ' '
            + getStr(redseled[6]) + ' - '
            + getStr(blueNum)
            );

  //统计总次数
  inc(fTotalTimes);
  RzLEDDisplay8.Caption := inttostr(fTotalTimes);
  
end;


procedure TForm1.start;
begin
  reset;
  genRedNums;
  genBlueNum;
  showSSQ;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  start;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if fCurTimes < fRunTimes then
  begin
    start;
    inc(fCurTimes);
  end else begin
    actGenTimes.Enabled := true;
    Timer2.Enabled := false;
    UpdateLists();
  end;
end;

procedure TForm1.UpdateListBlue;
var
  i: integer;
  item: TListItem;

begin
   //统计红色球
  item := RzListView2.Items.Item[0];
  for i := 0 to length(fBlueNCRA)-1 do
  begin
    item.SubItems[i] := inttostr(fBlueNCRA[i].Rcount);
  end;

end;

procedure TForm1.UpdateListRed;
var
  i: integer;
  item: TListItem;
begin
   //统计红色球
  item := RzListView1.Items.Item[0];
  for i := 0 to length(fRedNCRA)-1 do
  begin
    item.SubItems[i] := inttostr(fRedNCRA[i].Rcount);
  end;
end;

procedure TForm1.UpdateLists;
begin
  UpdateListBlue();
  UpdateListRed();
  UpdateListStat();

end;

procedure TForm1.UpdateListStat;
var
  mb: TNumCntRec;
  mr: TNumCntRecArray;
  i: integer;
begin

  // 蓝号
  mb := getMostBlue();
  RzLVStats.Items.Item[6].SubItems[0] := inttostr(mb.Number);
  RzLVStats.Items.Item[6].SubItems[1] := inttostr(mb.Rcount);
  // 红号
  setLength(mr, 6);
  getMostRed(mr);
  for i := 0 to 5 do
    begin
      RzLVStats.Items.Item[i].SubItems[0] := inttostr(mr[i].Number);
      RzLVStats.Items.Item[i].SubItems[1] := inttostr(mr[i].Rcount);
    end;
  
end;

end.
