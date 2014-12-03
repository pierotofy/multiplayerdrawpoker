unit LobbyServerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UpdateChecker,
  Constants, LobbyServer, Languages;

type
  TFrmLobbyServer = class(TForm)
    BtnStart: TButton;
    GrpSettings: TGroupBox;
    lblMotd: TLabel;
    txtMotd: TEdit;
    txtPort: TEdit;
    Label1: TLabel;
    lblPort: TLabel;
    Label2: TLabel;
    txtAdminPassword: TEdit;
    procedure BtnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    Lobby: TLobbyServer;  //Riferimento all'oggetto TLobbyServer
  end;

var
  FrmLobbyServer: TFrmLobbyServer;

implementation

{$R *.dfm}

procedure TFrmLobbyServer.BtnStartClick(Sender: TObject);
var
  UpdateChecker: TUpdateChecker;
begin
  { Qualsiasi cosa tu faccia, controlliamo per gli aggiornamenti... }
  UpdateChecker := TUpdateChecker.Create(self,false,true);

  { Avviamo o fermiamo? }
  if BtnStart.Caption = GetStr(19) then begin
    Lobby := TLobbyServer.Create(self,StrToInt(txtPort.Text),txtMotd.Text,txtAdminPassword.Text);
    BtnStart.Caption := GetStr(20);;
  end
  else begin
    { Se dobbiamo fermare il server, distruggiamolo! (lol) }
    Lobby.Destroy;
    BtnStart.Caption := GetStr(19);
  end;
end;

procedure TFrmLobbyServer.FormCreate(Sender: TObject);
begin
  self.Caption := self.Caption + ' ' + LOBBYVERSION;
  self.txtPort.Text := IntToStr(LOBBYPORT);

  { Imposta la lingua }
  lblPort.Caption := GetStr(11);
  GrpSettings.Caption := GetStr(18);
  BtnStart.Caption := GetStr(19);
  txtMotd.Text := GetStr(123);
end;

{ Se viene chiuso, distruggi l'applicazione intera }
procedure TFrmLobbyServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

end.
