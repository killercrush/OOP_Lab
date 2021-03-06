unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, FigureClass, ComCtrls, ToolWin, Menus, ImgList;

type
  TForm1 = class(TForm)
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Panel2: TPanel;
    edInfo: TEdit;
    bColor: TButton;
    ColorDialog1: TColorDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    bDelete: TButton;
    ToolButton5: TToolButton;
    Label4: TLabel;
    tbAngle: TTrackBar;
    tbSize: TTrackBar;
    MainMenu1: TMainMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ImageList1: TImageList;
    bNext: TButton;
    Timer1: TTimer;
    Image1: TImage;
    N5: TMenuItem;
    RichEdit1: TRichEdit;
    procedure Form1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure bColorClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure bColorOkClick(Sender: TObject);
    procedure RefreshInfo(Figure: TDot);
    procedure CanvasChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbAngleChange(Sender: TObject);
    procedure tbSizeChange(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure tbAngleEnter(Sender: TObject);
    procedure tbSizeEnter(Sender: TObject);
    procedure bNextClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MakeFigure(FigureClass: TDotClass; X, Y, Color: Integer;
      Canvas: TCanvas; Size: Integer = 1; Angle: Integer = 0);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ClearCanvas;
    procedure N5Click(Sender: TObject);
  private
    procedure CMDialogKey(var msg: TCMDialogKey); message CM_DIALOGKEY;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  FigureList: TList;
  ClickPos: TPoint;
  Canv: TCanvas;
  Buf: TBitmap;
  IsCanvasChanged: boolean;

implementation

uses ABOUT, Unit2;
{$R *.dfm}

procedure TForm1.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then
    inherited;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FigureList);
  Buf.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FigureList := TList.Create;
  Buf := TBitmap.Create;
  Canv := Buf.Canvas;
  Randomize;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  X, Y, Size, Color, Angle, Step: Integer;
  tb: TTrackBar;
  Fgr: TDot;
begin
  if not Assigned(FigureList) then
    FigureList := TList.Create;
  Size := Random(50) + 50; // Random(tbSize.Max - tbSize.Min) + tbSize.Min;
  Angle := Random(tbAngle.Max - tbAngle.Min) + tbAngle.Min;
  X := Random(Buf.Width - 2 * Size) + Size;
  Y := Random(Buf.Height - 2 * Size) + Size;
  Color := RGB(Random(256), Random(256), Random(256));
  Step := 10;
  tb := tbSize;
  if ssShift in Shift then
  begin
    Step := 50;
    tb := tbAngle;
  end;
  if ssCtrl in Shift then
    Step := 1;
  case Key of
    49:
      MakeFigure(TCircle, X, Y, Color, Canv, Size);
    50:
      MakeFigure(TSquare, X, Y, Color, Canv, Size, Angle);
    51:
      MakeFigure(TStar, X, Y, Color, Canv, Size, Angle);
    VK_SPACE:
      bColor.Click;
    VK_TAB:
      bNext.Click;
    VK_DELETE:
      bDelete.Click;
    VK_ADD:
      tb.Position := tb.Position + 1;
    VK_SUBTRACT:
      tb.Position := tb.Position - 1;
  end;
  if FigureList.IsEmpty then
    exit;
  Fgr := FigureList.CurrentItem.Item;
  if Fgr.Selected then
    case Key of
      VK_RIGHT:
        Fgr.Shift(Step, 0);
      VK_LEFT:
        Fgr.Shift(-Step, 0);
      VK_UP:
        Fgr.Shift(0, -Step);
      VK_DOWN:
        Fgr.Shift(0, Step);
    end;
  IsCanvasChanged := true;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Buf.Width := Image1.Width;
  Buf.Height := Image1.Height;
end;

procedure TForm1.CanvasChange(Sender: TObject);
var
  ListItem, CurrItem: PListItem;
begin
  if not Assigned(FigureList) then
    FigureList := TList.Create;
  ClearCanvas;
  if not FigureList.IsEmpty then
  begin
    CurrItem := FigureList.CurrentItem;
    FigureList.Reset;
    ListItem := FigureList.CurrentItem;
    repeat
      ListItem.Item.Draw;
      ListItem.Item.DrawSelection;
      ListItem := ListItem.NextItem;
    until ListItem = nil;
    FigureList.CurrentItem := CurrItem;
  end;
  Image1.Picture.Bitmap := Buf;
end;

procedure TForm1.ClearCanvas;
var
  pen_col: Integer;
begin
  pen_col := Canv.Pen.Color;
  Canv.Brush.Color := $FFFFFF;
  Canv.Pen.Color := $FFFFFF;
  Canv.Rectangle(0, 0, Buf.Width, Buf.Height);
  Canv.Brush.Style := bsClear;
  Canv.Pen.Color := pen_col;
end;

procedure TForm1.bColorClick(Sender: TObject);
begin
  ColorDialog1.Color := Label1.Color;
  if ColorDialog1.Execute then
    Label1.Color := ColorDialog1.Color;
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.CurrentItem.Item.Color := Label1.Color;
  IsCanvasChanged := true;
end;

procedure TForm1.bColorOkClick(Sender: TObject);
begin
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.CurrentItem.Item.Color := Label1.Color;
  IsCanvasChanged := true;
end;

procedure TForm1.bDeleteClick(Sender: TObject);
begin
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.DeleteItem(FigureList.CurrentItem);
  IsCanvasChanged := true;
  FigureList.Reset;
  edInfo.Clear;
end;

procedure TForm1.bNextClick(Sender: TObject);
begin
  if FigureList.IsEmpty then
    exit;
  FigureList.CurrentItem.Item.Selected := false;
  if FigureList.CurrentItem.NextItem = nil then
    FigureList.CurrentItem := FigureList.GetFirstItem
  else
    FigureList.CurrentItem := FigureList.CurrentItem.NextItem;
  FigureList.CurrentItem.Item.Selected := true;
  RefreshInfo(FigureList.CurrentItem.Item);
  IsCanvasChanged := true;
end;

procedure TForm1.RefreshInfo(Figure: TDot);
begin
  edInfo.Clear;
  if not Figure.Selected then
    exit;
  tbSize.Position := Figure.Size;
  tbAngle.Position := Figure.Angle;
  Label1.Color := Figure.Color;
  edInfo.Text := Figure.Info;
end;

procedure TForm1.tbAngleChange(Sender: TObject);
begin
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.CurrentItem.Item.Angle := tbAngle.Position;
  IsCanvasChanged := true;
end;

procedure TForm1.tbAngleEnter(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TForm1.tbSizeChange(Sender: TObject);
begin
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.CurrentItem.Item.Size := tbSize.Position;
  IsCanvasChanged := true;
end;

procedure TForm1.tbSizeEnter(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if IsCanvasChanged then
    CanvasChange(self);
  IsCanvasChanged := false;
end;

procedure TForm1.MakeFigure(FigureClass: TDotClass; X, Y, Color: Integer;
  Canvas: TCanvas; Size: Integer = 1; Angle: Integer = 0);
var
  Fgr: TDot;
begin
  if not FigureList.IsEmpty then
    FigureList.CurrentItem.Item.Selected := false;
  Fgr := FigureClass.Create(X, Y, Color, Canvas, Size, Angle);
  FigureList.AddItem(Fgr);
  RefreshInfo(Fgr);
end;

procedure TForm1.Form1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ListItem: PListItem;
  FigureSelected: boolean;
begin
  if not Assigned(FigureList) then
    FigureList := TList.Create;
  ClickPos.X := X;
  ClickPos.Y := Y;
  if Button = mbLeft then
  begin
    if ToolButton1.Down then
    begin
      if FigureList.IsEmpty then
        exit;
      FigureList.Reset;
      ListItem := FigureList.CurrentItem;
      FigureSelected := false;
      repeat
        if not FigureSelected then
        begin
          ListItem.Item.Selected := ListItem.Item.PointInFugure(X, Y);
          FigureList.CurrentItem := ListItem;
          FigureSelected := ListItem.Item.Selected;
        end
        else
          ListItem.Item.Selected := false;
        ListItem := ListItem.NextItem;
      until ListItem = nil;
      RefreshInfo(FigureList.CurrentItem.Item);
    end;
    if ToolButton2.Down then
      MakeFigure(TDot, X, Y, Label1.Color, Canv);
    if ToolButton3.Down then
      MakeFigure(TCircle, X, Y, Label1.Color, Canv, tbSize.Position);
    if ToolButton4.Down then
      MakeFigure(TSquare, X, Y, Label1.Color, Canv, tbSize.Position,
        tbAngle.Position);
    if ToolButton5.Down then
      MakeFigure(TStar, X, Y, Label1.Color, Canv, tbSize.Position,
        tbAngle.Position);
    IsCanvasChanged := true;
  end;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  if (not FigureList.IsEmpty) and (FigureList.CurrentItem.Item.Selected) then
    FigureList.CurrentItem.Item.MoveTo(ClickPos.X, ClickPos.Y);
  IsCanvasChanged := true;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
  FreeAndNil(FigureList);
  IsCanvasChanged := true;
end;

end.
