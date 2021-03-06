unit NewGame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Constants, jpeg, ExtCtrls,
  WindowsUtils, GhostDlg, Languages;

type
  TFrmNewGame = class(TForm)
    PanelHost: TPanel;
    ImgHost: TImage;
    PanelJoin: TPanel;
    ImgJoin: TImage;
    PanelLobby: TPanel;
    ImgLobby: TImage;
    procedure ImgHostMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgJoinMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgLobbyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgHostClick(Sender: TObject);
    procedure ImgJoinClick(Sender: TObject);
    procedure ImgLobbyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    WinXPRunning: boolean;
    GhostDlg: TFrmGhostDlg;
  public
    Choice: TGameChoice;
  end;

var
  FrmNewGame: TFrmNewGame;

Const BGCOLOR = clWhite;
Const SELCOLOR = clSilver;

Const MOUSETOPADJUST = 50;
Const MOUSELEFTADJUST = 20;


implementation

{$R *.dfm}

procedure TFrmNewGame.ImgHostMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  PanelHost.Color := SELCOLOR;
  PanelJoin.Color := BGCOLOR;
  PanelLobby.Color := BGCOLOR;

  GhostDlg.Visible := true;
  GhostDlg.lblText.Caption := GetStr(41);
  GhostDlg.Color := clSkyBlue;
  GhostDlg.lblText.Color := clSkyBlue;
  GhostDlg.Top := Y + PanelHost.Top + self.Top + MOUSETOPADJUST;
  GhostDlg.Left := X + PanelHost.Left + self.Left + MOUSELEFTADJUST;
end;
procedure TFrmNewGame.ImgJoinMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  PanelHost.Color := BGCOLOR;
  PanelJoin.Color := SELCOLOR;
  PanelLobby.Color := BGCOLOR;

  GhostDlg.Visible := true;
  GhostDlg.lblText.Caption := GetStr(40);
  GhostDlg.Color := clMoneyGreen;
  GhostDlg.lblText.Color := clMoneyGreen;
  GhostDlg.Top := Y + PanelJoin.Top + self.Top + MOUSETOPADJUST;
  GhostDlg.Left := X + PanelJoin.Left + self.Left + MOUSELEFTADJUST;
end;
procedure TFrmNewGame.ImgLobbyMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  PanelHost.Color := BGCOLOR;
  PanelJoin.Color := BGCOLOR;
  PanelLobby.Color := SELCOLOR;

  GhostDlg.Visible := true;
  GhostDlg.lblText.Caption := GetStr(39);
  GhostDlg.Color := clMedGray;
  GhostDlg.lblText.Color := clMedGray;
  GhostDlg.Top := Y + PanelLobby.Top + self.Top + MOUSETOPADJUST;
  GhostDlg.Left := X + PanelLobby.Left + self.Left + MOUSELEFTADJUST;
end;


procedure TFrmNewGame.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  PanelHost.Color := BGCOLOR;
  PanelJoin.Color := BGCOLOR;
  PanelLobby.Color := BGCOLOR;
  GhostDlg.Visible := false;
end;

procedure TFrmNewGame.ImgHostClick(Sender: TObject);
begin
  GhostDlg.Visible := false;
  self.Choice := gcHost;
  self.ModalResult := mrOK;
end;

procedure TFrmNewGame.ImgJoinClick(Sender: TObject);
begin
  GhostDlg.Visible := false;
  self.Choice := gcJoin;
  self.ModalResult := mrOK;
end;

procedure TFrmNewGame.ImgLobbyClick(Sender: TObject);
begin
  GhostDlg.Visible := false;
  self.Choice := gcConnectLobby;
  self.ModalResult := mrOK;
end;

procedure TFrmNewGame.FormCreate(Sender: TObject);
begin
  WinXPRunning := IsWindowsXP;
  GhostDlg := TFrmGhostDlg.Create(self);
  GhostDlg.Show;
  GhostDlg.Visible := false;
  if not WinXPRunning then GhostDlg.AlphaBlend := false;

  { Imposta la lingua... }
  self.Caption := GetStr(37);
end;

end.
