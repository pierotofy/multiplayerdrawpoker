unit GhostDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmGhostDlg = class(TForm)
    lblText: TLabel;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblTextMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmGhostDlg: TFrmGhostDlg;

implementation

{$R *.dfm}

procedure TFrmGhostDlg.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  self.Visible := false;
end;

procedure TFrmGhostDlg.lblTextMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  self.Visible := false;
end;

end.
