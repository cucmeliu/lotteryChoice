unit MyGraphi;

interface

uses
   Controls, Classes, Messages, Types, Graphics, Forms, windows, SysUtils,
     sgr_misc;

type

  TZoomState = (PanState, ZoomInState, ZoomOutState); //当前状态：移动，放大，缩小

  TZoomData = record
    R:TRect;
    State: byte;
  end;

  TMyGraph = class(TCustomControl)
  private

    fReSize,                                        //判断窗体是否调整大小
    FNeedRedraw: Boolean;                           //判断是否要重画内存区的标志
    MapRect,                                        //内存中的绘图区
    FromRect,                                       //复制的源区域
    ToRect : TRect;                                 //复制目的区域

    FScale: double;                                 //缩放比
    MapWidth, MapHeight: integer;
    
    MousePosition: TPoint;                          //当前鼠标所在位置
    FZoomState: TZoomState;                         //当前状态：移动，放大，缩小
    FZoomData: TZoomData;
    fScaleMax, fScaleRate: double;                  //最大放大倍数和单级放大倍数

    FBorderStyle: TBorderStyle;

    FReadyForDraw: boolean;

    procedure Clear(Mycanvas: TCanvas; MyRect: TRect);
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ZoomPan;
    procedure SetScaleMax(const Value: double);
    procedure SetScaleRate(const Value: double);

    procedure ReSizeParameter;

    procedure DrawNotRect(MyRect: TRect);
  protected
    BitMap: TMemBitmap;                             //内存绘图区对象

    procedure DrawMap(MyCanvas: TCanvas; DrawRect: TRect); virtual; abstract;
    procedure WMResize(var Message: TWMSize); message WM_Size;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;

  published

    property Align;
    property ScaleMax: double read FScaleMax write SetScaleMax;
    property ScaleRate: double read FScaleRate write SetScaleRate;

  end;

const
  crZoomIn = 1; crZoomOut = 2;
  zsNone = 0; zsZoomStart = 1; zsZoomRect = 2; zsStartPan = 3; zsPaning = 4;

implementation

{ TStatGrid }

{ TMyGraph }

procedure TMyGraph.Clear(Mycanvas: TCanvas; MyRect: TRect);
begin
        MyCanvas.Brush.Color:=clBlack;
        myCanvas.FillRect(MyRect);
end;

constructor TMyGraph.Create(AOwner: TComponent);
begin
  inherited;
    try
        ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
          csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
        Parent := (AOwner as TwinControl);
        screen.cursors[crZoomIn]:=Loadcursor(hinstance,'zoomin');
        screen.cursors[crZoomOut]:=Loadcursor(hinstance,'zoomout');
    except
    end;

        FReadyForDraw := true;
        FNeedRedraw := true;
        FResize := true;
        fScale := 1.0;
        fScaleMax := 10.0;
        fScaleRate := 1.8;
        BitMap := TMemBitmap.Create(Width, Height);
end;

procedure TMyGraph.CreateParams(var Params: TCreateParams);
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

destructor TMyGraph.Destroy;
begin
        BitMap.Free;
  inherited;
end;

procedure TMyGraph.DrawNotRect(MyRect: TRect);
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

procedure TMyGraph.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
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

procedure TMyGraph.MouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TMyGraph.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
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

procedure TMyGraph.Paint;
begin
  inherited;
        if FNeedRedraw then
        begin
                Bitmap.ReCreate((MapRect.Right - MapRect.Left),
                        (MapRect.Bottom-MapRect.Top));
                Clear(BitMap.Canvas, MapRect);
                DrawMap(BitMap.Canvas, MapRect);

                FNeedRedraw := False;
        end;
        ToRect := Rect(0, 0, Width, Height);
        Canvas.CopyRect(ToRect,Bitmap.Canvas, FromRect);
end;

procedure TMyGraph.Reset;
begin
        FScale := 1.0;
        FNeedRedraw := true;
        ResizeParameter;
//        paint;
end;

procedure TMyGraph.ReSizeParameter;
begin
        MapWidth     := Trunc(Width * FScale);
        MapHeight    := Trunc(Height * FScale);
        MapRect      := Rect(0, 0, MapWidth, MapHeight);
        FromRect := MapRect;
        paint;

//        CorrectFromRect;
      {  with GridDrawRect do
        begin
              Left   := MapRect.Left + Trunc(20*FScale);
              top    := MapRect.Top  + Trunc(20*FScale);
              Right  := Left + MapWidth - Trunc(40*FScale);
              Bottom := Top + MapHeight - Trunc(40*FScale);
        end;      }
end;

procedure TMyGraph.SetScaleMax(const Value: double);
begin
        FScaleMax := Value;
end;

procedure TMyGraph.SetScaleRate(const Value: double);
begin
        FScaleRate := Value;
end;

procedure TMyGraph.WMResize(var Message: TWMSize);
begin
        //因为在TMyGraph的Create事件之前就会接到 WM_Size消息
        //此时如果执行paint方法将发生异常，因为还没有实例化对象
        // FReadyForDraw 未赋值时默认值为false
        //在执行Create事件时为FReadyForDraw赋值为true表示可以执行paint方法
        if FReadyForDraw then
        begin
                fNeedRedraw := true;
                fReSize     := true;
                ReSizeParameter;
//                paint;
        end;
end;

procedure TMyGraph.ZoomIn;
begin
        if fScale >= fScaleMax then exit;
        fScale := fScale * fScaleRate;
        if fScale > 10.0 then fScale := 10.0;
        FNeedRedraw := true;
        ReSizeParameter;
end;

procedure TMyGraph.ZoomOut;
begin

end;

procedure TMyGraph.ZoomPan;
begin

end;

end.
