unit StatGrid;
(**
*  ��Unit������TNumCntRecΪԪ�ص�һ������ͼ��
  TNumCntRec = record
    Number: byte;       //����
    Rcount: integer;    //���ֳ��ֵĴ���
  end;
*
*)


interface

uses Controls, Classes, Messages, Types, Graphics, Forms, windows, SysUtils,
     sgr_misc, defineUnit;

type

  TZoomState = (PanState, ZoomInState, ZoomOutState); //��ǰ״̬���ƶ����Ŵ���С

  TZoomData = record
    R:TRect;
    State: byte;
  end;

  TStatGrid = class(TCustomControl)
  private
    BitMap: TMemBitmap;                             //�ڴ��ͼ������
    
    FResize,                                        //�Ƿ�ߴ�ı���
    FNeedRedraw: Boolean;                           //�ж��Ƿ�Ҫ�ػ��ڴ����ı�־

    MapRect,
    FromRect,                                       //Դ����
    ToRect,                                         //Ŀ������
    GridDrawRect                                    //�����������
            : TRect;

    FScale: double;                                 //���ű�

    FXDistence, FYDistence: double;
    MapWidth, MapHeight,                            //�ڴ�������ͼ�εĳߴ�
    UIMapWidth, UIMapHeight    : integer;           //�û�������Ҫ��ʾ�ĳߴ�

    MousePosition: TPoint;                          //��ǰ�������λ��

    FZoomState: TZoomState;                       //��ǰ״̬���ƶ����Ŵ���С
    FZoomData: TZoomData;
    FBorderStyle: TBorderStyle;

    //fBaseNumber: byte;                            //Ҫͳ�ƵĻ�����(��)
    //FNumCount: TNumCount;
    fMaxCount: integer;
    //fBaseOnly: boolean;                          //�Ƿ�ֻ��ʾ������

    procedure DrawCord(myCanvas: TCanvas;  originPoint, termPoint: TPoint;
        xCordCnt, yCordCnt: integer); //������
    procedure DrawNotRect(MyRect: TRect);

    procedure InitParam;
    procedure ReSizeParameter;
    procedure CorrectFromRect;

    procedure Clear(Mycanvas:TCanvas;MyRect:TRect);
    procedure DrawMap(MyCanvas: TCanvas);
    //procedure DrawZigZag(myCanvas: TCanvas; originPoint: TPoint);
    //procedure SetBaseNumber(const Value: byte);
    //procedure SetNumCount(const Value: TNumCount);
    procedure SetMaxCount(const Value: integer);
//    procedure SetBaseOnly(const Value: boolean);

  protected
    procedure WMResize(var Message: TWMSize); message WM_Size;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ZoomPan;    

  public
    //fLotteryBuilder: TLotteryBuilder;
    fNumCountArray: TNumCntRecArray;
                               
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    Procedure Reset;
    procedure Maxam;

    //property BaseNumber: byte read FBaseNumber write SetBaseNumber;
    //property NumCount: TNumCount read FNumCount write SetNumCount;
    //property MaxCount: integer read FMaxCount write SetMaxCount;
    //property BaseOnly: boolean read FBaseOnly write SetBaseOnly;
  published
    procedure SetZoomIn;
    procedure SetZoomOut;
    procedure SetZoomPan; 
    property Align;
  end;

const
  crZoomIn = 1; crZoomOut = 2;
  zsNone = 0; zsZoomStart = 1; zsZoomRect = 2; zsStartPan = 3; zsPaning = 4;


implementation

{ TStatGrid }

//********************************************************************
//  function����������ϵ�ͼ��
//  Description�������ָ����С�ľ��η�Χ
//  Parms��MyCanvas������ MyRect����������
//  Note��
//  Update��
//********************************************************************
procedure TStatGrid.Clear(Mycanvas: TCanvas; MyRect: TRect);
begin
        MyCanvas.Brush.Color:=clBlack;
        myCanvas.FillRect(MyRect); 
end;

procedure TStatGrid.CorrectFromRect;
var
  tlPoint, brPoint,
  mouseInMap: TPoint;
begin
        mouseInMap.X := Trunc(MousePosition.X * FScale);
        mouseInMap.Y := Trunc(MousePosition.Y * FScale);
        tlPoint.X    := (mouseInMap.X - width div 2);
        tlPoint.Y    := (mouseInMap.Y - Height div 2);
        brPoint.X    := (mouseInMap.X + width div 2);
        brPoint.Y    := (mouseInMap.Y + Height div 2);

        if tlPoint.X < 0 then
        begin
              tlPoint.X := 0;
              brPoint.X := Width;
        end;
        if tlPoint.Y < 0 then
        begin
              tlPoint.Y := 0;
              brPoint.Y := Height;
        end;
        if brPoint.X > Mapwidth then
        begin
              brPoint.X := Mapwidth;
              tlPoint.X := MapWidth - Width;
        end;
        if brPoint.Y > MapHeight then
        begin
              brPoint.Y := MapHeight;
              tlPoint.Y := MapHeight - Height;
        end;

        FromRect := Rect(tlPoint.X, tlPoint.Y, brPoint.X, brPoint.Y);

end;

constructor TStatGrid.Create(AOwner: TComponent);
begin
  inherited;
    try
        ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
          csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
        Self.Parent := (AOwner as TwinControl);
        screen.cursors[crZoomIn]:=Loadcursor(hinstance,'zoomin');
        screen.cursors[crZoomOut]:=Loadcursor(hinstance,'zoomout');
    except
    end;
        FNeedRedraw := true;
        FZoomState := PanState;
        
        InitParam;

end;

procedure TStatGrid.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
        inherited CreateParams(Params);
        with Params do
        begin
                Style := Style or BorderStyles[FBorderStyle];
                if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
                begin
                        Style := Style and not WS_BORDER;
                        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
                end;
                WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
        end; 
end;

destructor TStatGrid.Destroy;
begin
        BitMap.Free;
  inherited;
end;

(*********************************************************************
//  func��
//  Desc�������꣬����դ��
//  Parm��
//  Note��
//  Auth��Loafer.Liu @ 2004.9.
//  Updt��
//*******************************************************************)
procedure TStatGrid.DrawCord(myCanvas: TCanvas; originPoint, termPoint: TPoint;
        xCordCnt, yCordCnt: integer);
var
  i: integer;
  distance: double;//integer;
  txtPoint, sPoint, ePoint: TPoint;
begin
        with myCanvas.Pen do
        begin
                Color := clGreen;
                Style := psSolid;
                Width := 1;
        end;
        myCanvas.MoveTo(originPoint.X, termPoint.Y);
        myCanvas.LineTo(originPoint.X, originPoint.Y);
        myCanvas.LineTo(termPoint.X, originPoint.Y);
        
        myCanvas.Brush.Color := clBlack;
        with myCanvas.Font do
        begin
                Color := clBlue;
                Size  := Trunc(5 * FScale);
        end;
        //��x��������ֵ
        distance := (termPoint.X - originPoint.X)/(xCordCnt);//+1); //��1��Ϊ������ռ�
        FXDistence := distance;
        sPoint.Y := originPoint.Y;
        ePoint.Y := termPoint.Y;
        txtPoint.Y := originPoint.Y + canvas.TextHeight('1') div 2;
        for i := 0 to xCordCnt do
        begin
                sPoint.X := originPoint.X + Trunc(i*distance);
                ePoint.X := sPoint.X;
                myCanvas.MoveTo(sPoint.X, sPoint.Y);
                myCanvas.LineTo(ePoint.X, ePoint.Y);
                txtPoint.X := originPoint.X + Trunc(i*distance);
                myCanvas.TextOut(txtPoint.X, txtPoint.Y, IntToStr(i));
        end;
        //��y��������ֵ
        distance := (originPoint.Y - termPoint.Y)/(yCordCnt);//+1); //��1��Ϊ������ռ�
        FYDistence := distance;
        sPoint.X := originPoint.X;
        ePoint.X := termPoint.X;
        txtPoint.X := originPoint.X - canvas.TextWidth('100');
        for i:=1 to yCordCnt do
        begin
                sPoint.Y := originPoint.Y - Trunc(i*distance);
                ePoint.Y := sPoint.Y;
                myCanvas.MoveTo(sPoint.X, sPoint.Y);
                myCanvas.LineTo(ePoint.X, ePoint.Y);
                txtPoint.Y := originPoint.Y - Trunc(i*distance);
                myCanvas.TextOut(txtPoint.X, txtPoint.Y, IntToStr(i));
        end; 

end;

procedure TStatGrid.DrawMap(MyCanvas: TCanvas);
var
  aPoint, bPoint: TPoint;
  xCnt, yCnt: integer;
begin
        aPoint.X := GridDrawRect.Left;
        aPoint.Y := GridDrawRect.Bottom;
        bPoint.X := GridDrawRect.Right;
        bPoint.Y := GridDrawRect.Top;
        xCnt := Length(fNumCountArray);
        yCnt := fMaxCount;//Length(fLotteryBuilder.FLotteryStyle) div 2; //���赥������Ĵ������ᳬ��������һ��
        if yCnt = 0 then     //Ĭ�������
        begin
                xCnt := 32;
                yCnt := 16;
        end;
        DrawCord(MyCanvas, aPoint, bPoint, xCnt, yCnt); //������
        //DrawZigZag(MyCanvas, aPoint);              //������
end;

(*********************************************************************
//  function��{������ʱ�����߿�}
//  Description����
//  Parms������
//  Note��
//  Update��
//*******************************************************************)
procedure TStatGrid.DrawNotRect(MyRect: TRect);
begin
        with Canvas do
        begin
                with Pen do
                begin
                        width := 1;
                        Style := psDot;
                        Color := clBlack;
                        Mode  := pmNotXor;
                end;
                Brush.Color:=clWhite;
                with MyRect do
                        PolyLine([TopLeft, Point(Right,Top),
                                BottomRight, Point(Left,Bottom),TopLeft]);
        end;
end;

(*********************************************************************
//  func��DrawZigZag
//  Desc��������
//  Parm��originPointԭ��λ��
//  Note��Ŀǰֻ���˻�����
//  Auth��Loafer.Liu @ 2004.9.
//  Updt��
//*******************************************************************)
(*
procedure TStatGrid.DrawZigZag(myCanvas: TCanvas; originPoint: TPoint);
var
  i, j, tmpIdx,
  numCnt, LenArray: integer;      //��ǰ�ŵĵ�ǰ����
  sPoint, ePoint: TPoint;
begin
        //if fBaseNumber = 0 then exit;
        numCnt := 0;
        sPoint := originPoint; //ԭ��
        ePoint := sPoint;
        myCanvas.Pen.Color := clRed;
        myCanvas.MoveTo(sPoint.X, sPoint.Y);
//        LenArray := Length(fLotteryBuilder.FLotteryStyle);

        for i:= LenArray-1 downto 0 do
        begin
                //��Ϊ��¼��˳�������������ǰ����������Ҫ����
                for j:=Low(fLotteryBuilder.FLotteryStyle[i].BaseNumber) to
                        High(fLotteryBuilder.FLotteryStyle[i].BaseNumber) do
                begin
                        if (fLotteryBuilder.FLotteryStyle[i].BaseNumber[j] = fBaseNumber)
                                or ((not FBaseOnly) and (fLotteryBuilder.FLotteryStyle[i].SpecNumber = fBaseNumber)) then
                        begin
                                numCnt := numCnt + 1;
                                tmpIdx := LenArray - i;
                                ePoint.X := sPoint.X + Trunc(FXDistence*tmpIdx);
                                ePoint.Y := sPoint.Y - Trunc(FYDistence*(numCnt));
                                myCanvas.LineTo(ePoint.X, ePoint.Y);
                                myCanvas.TextOut(ePoint.X, ePoint.Y, intToStr(numCnt));
                                myCanvas.MoveTo(ePoint.X, ePoint.Y);  //�粻�Ӵ˾䣬��һ�߶ν������ֵĽ��Ͽ�ʼ��
                                break;
                        end;
                end;

        end;
        
end;
 *)
procedure TStatGrid.InitParam;
begin
        //FNumCount.TotalCount := 0;
        //FNumCount.NumCount   := 0;
        FMaxCount := 0;
        FScale       := 1;
        UIMapWidth   := 800;
        UIMapHeight  := 600;
        ToRect       := Rect(0, 0, UIMapWidth, UIMapHeight);
        BitMap       := TMemBitmap.Create(UIMapWidth, UIMapHeight);
        //fBaseNumber  := 0;
        FXDistence   := 0;
        FYDistence   := 0;
        //fBaseOnly := false;

end;

procedure TStatGrid.Maxam;
begin
        FScale := 10.0;
        FNeedRedraw := true;
        ResizeParameter;
end;

procedure TStatGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
        if (Button <> mbLeft) then exit;
  
        MousePosition := Point(x,y);
        if (FZoomState = ZoomOutState) then
        begin
                ZoomOut;
                Paint;
        end else if ((Shift=[ssShift,ssLeft]) or (FZoomState = ZoomInState))then{and (fZoomData.State=zsNone)}
                begin
                        with fZoomData do
                        begin
                                R.Left:=X;
                                R.Top:=Y;
                                R.Right:=X;
                                R.Bottom:=Y;
                                State:=zsZoomStart;
                                if (FZoomState <> ZoomInState) then
                                        Screen.Cursor := crZoomIn;
                        end; 
                end else if ((Shift=[ssCtrl,ssLeft]) or (FZoomState = PanState)) then { and     (fZoomData.State=zsNone)  }
                        with fZoomData do
                        begin
                                R.Left:=X;
                                R.Top:=Y;
                                State:=zsStartPan;
                                if FZoomState <> PanState then
                                        Screen.Cursor := crHandPoint;
                        end


end;

procedure TStatGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
        if fZoomData.State = zsNone then exit;
        with fZoomData do
                case State of
                  zsZoomStart:
                          if (abs(R.Left-X)>3) or (abs(R.Top-Y)>3) then
                          begin
                            State:=zsZoomRect;
                            R.Right:=X;
                            R.Bottom:=Y;
                            DrawNotRect(R);
                          end;
                  zsZoomRect:
                          begin
                            DrawNotRect(R);
                            R.Right:=X;
                            R.Bottom:=Y;
                            DrawNotRect(R);
                          end;
                  zsStartPan: with R do
                          if (Left<>X) or (Top<>Y) then
                          begin
                            Right:=Left;
                            Bottom:=Top;
                            Left:=X; Top:=Y;
                            State:=zsPaning;
                          end;
                  zsPaning : with R do
                          begin
                            Right:=Left;
                            Bottom:=Top;
                            Left:=X; Top:=Y;
                            ZoomPan;
                            Paint;
                          end;
                end
end;

procedure TStatGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
    try
        with fZoomData do
            case State of
                zsZoomStart: ZoomIn;
{                zsZoomRect:
                        begin
                        DrawNotRect(R);
                        ZoomRect();
                        end;    }
                zsStartPan: ;
                zsPaning:
                begin
                end;
            end;
    finally
        fZoomData.State:=zsNone;
        if (fZoomState <> PanState) and (fZoomState <> ZoomInState) then
                Screen.Cursor := crDefault;
        Paint;
    end;
end;

procedure TStatGrid.Paint;
begin
  inherited;   (*
        if not assigned(fLotteryBuilder) then exit;
        if FNeedRedraw then
        begin
                Bitmap.ReCreate(MapWidth, MapHeight);
                Clear(BitMap.Canvas, MapRect);
                DrawMap(BitMap.Canvas);

                FNeedRedraw := False;
        end;
        ToRect := Rect(0, 0, Width, Height);
        Canvas.CopyRect(ToRect,Bitmap.Canvas,FromRect);
         *)
end;

procedure TStatGrid.Reset;
begin
        FScale := 1.0;
        FNeedRedraw := true;
        ResizeParameter;
end;

procedure TStatGrid.ReSizeParameter; 
begin
        MapWidth     := Trunc(Width * FScale);
        MapHeight    := Trunc(Height * FScale);
        MapRect      := Rect(0, 0, MapWidth, MapHeight);
        CorrectFromRect;
        with GridDrawRect do
        begin
              Left   := MapRect.Left + Trunc(20*FScale);
              top    := MapRect.Top  + Trunc(20*FScale);
              Right  := Left + MapWidth - Trunc(40*FScale);
              Bottom := Top + MapHeight - Trunc(40*FScale);
        end;
        Paint;

end;
          (*
procedure TStatGrid.SetBaseNumber(const Value: byte);
begin
        FBaseNumber := Value;
        fNeedRedraw := true;
        paint;
end;    *)
             (*
procedure TStatGrid.SetBaseOnly(const Value: boolean);
begin
        FBaseOnly := Value;
end;   *)

procedure TStatGrid.SetMaxCount(const Value: integer);
begin
        FMaxCount := Value;
end;
          (*
procedure TStatGrid.SetNumCount(const Value: TNumCount);
begin
        FNumCount := Value;
end;  *)

procedure TStatGrid.SetZoomIn;
begin
        FZoomState := ZoomInState;
end;

procedure TStatGrid.SetZoomOut;
begin
        FZoomState := ZoomOutState;
end;

procedure TStatGrid.SetZoomPan;
begin
        FZoomState := PanState;
        fZoomData.State := zsStartPan;
end;

procedure TStatGrid.WMResize(var Message: TWMSize);
begin
        fNeedRedraw := true;
        fReSize     := true;
        ReSizeParameter;
end;

procedure TStatGrid.ZoomIn;
begin
        if fScale >= 10.0 then exit;
        fScale := fScale * 1.5;
        if fScale > 10.0 then fScale := 10.0;
        FNeedRedraw := true;
        ReSizeParameter;
end;

procedure TStatGrid.ZoomOut;
begin
        if fScale <= 1.0 then exit;
        fScale := fScale / 1.5;
        if fScale < 1.0 then fScale := 1.0;
        FNeedRedraw := true;
        ReSizeParameter;
end;

procedure TStatGrid.ZoomPan;
begin
        CorrectFromRect;
        paint;
end;

end.