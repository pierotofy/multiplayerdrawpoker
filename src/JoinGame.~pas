unit JoinGame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  Constants, ConnectToIP, ServerInfo, ServerInfoList, WindowsUtils, LanScanner,
  ComCtrls, Languages;

type
  TFrmJoinGame = class(TForm)
    GrpSelectServer: TGroupBox;
    lstServers: TListBox;
    BtnConnectAtIP: TButton;
    GrpServerInfo: TGroupBox;
    lblServerInfoName: TLabel;
    lblShowServerInfoName: TLabel;
    lblServerInfoPasswordRequired: TLabel;
    lblShowServerInfoPasswordRequired: TLabel;
    lblServerInfoSlots: TLabel;
    lblShowServerInfoSlots: TLabel;
    lblServerInfoVersion: TLabel;
    lblShowServerInfoVersion: TLabel;
    lblServerInfoPort: TLabel;
    lblShowServerInfoPort: TLabel;
    lblServerInfoIP: TLabel;
    lblShowServerInfoIP: TLabel;
    lblServerInfoCip: TLabel;
    lblShowServerInfoCip: TLabel;
    BtnOK: TButton;
    txtNickname: TEdit;
    lblNickname: TLabel;
    procedure lstServersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnConnectAtIPClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    ServerList: TServerInfoList;
    procedure ShowServerInfo(ServerInfo: TServerInfo);
  public
    { Public declarations }
  end;

var
  FrmJoinGame: TFrmJoinGame;

implementation

{$R *.dfm}

procedure TFrmJoinGame.lstServersClick(Sender: TObject);
var
  C: integer;
begin
  { Itera per trovare l'elemento della lista selezionato... }
  for C := 0 to lstServers.Items.Count-1 do
  begin
    if lstServers.Selected[C] then begin

      { Una volta trovato lo visualizza }
      ShowServerInfo(TServerInfo(lstServers.Items.Objects[C]));
      BtnOK.Enabled := true;
      exit;
    end;
  end;
end;

{ Procedura per mostrare il contenuto di un oggetto ServerInfo sul riepilogo }
procedure TFrmJoinGame.ShowServerInfo(ServerInfo: TServerInfo);
begin
  lblShowServerInfoName.Caption := ServerInfo.GetServerName;

  if ServerInfo.IsPasswordRequired then lblShowServerInfoPasswordRequired.Caption := GetStr(27)
  else lblShowServerInfoPasswordRequired.Caption := GetStr(28);

  lblShowServerInfoSlots.Caption := IntToStr(ServerInfo.GetPlayersConnected) + '/' + IntToStr(ServerInfo.GetSlots);
  lblShowServerInfoCip.Caption := IntToStr(ServerInfo.GetCip);
  lblShowServerInfoIP.Caption := ServerInfo.Host;
  lblShowServerInfoPort.Caption := IntToStr(ServerInfo.Port);
  lblShowServerInfoVersion.Caption := ServerInfo.GetServerVersion;
end;

procedure TFrmJoinGame.FormCreate(Sender: TObject);
begin
  { Crea la lista di server }
  ServerList := TServerInfoList.Create;

  { Disabilita il pulsante di OK visto che all'inizio non ci sono partite }
  BtnOK.Enabled := false;

  { Setta il nome utente... }
  txtNickname.Text := GetFavouriteNick;

  { Imposta la lingua... }
  GrpSelectServer.Caption := GetStr(42);
  BtnConnectAtIP.Caption := GetStr(43);
  GrpServerInfo.Caption := GetStr(25);
  lblServerInfoName.Caption := GetStr(44);
  lblServerInfoPasswordRequired.Caption := GetStr(26) + ':';

  lblServerInfoCip.Caption := GetStr(30) + ':';
  lblServerInfoPort.Caption := GetStr(11) + ':';
  lblServerInfoVersion.Caption := GetStr(31) + ':';

  BtnOK.Caption := GetStr(45);
  self.Caption := GetStr(46);
end;

procedure TFrmJoinGame.BtnConnectAtIPClick(Sender: TObject);
var
  ConnectToIP: TFrmConnectToIP;
  ServerInfo: TServerInfo;
begin
  { Richiama la finestra di dialogo  }
  ConnectToIP := TFrmConnectToIP.Create(self);

  if ConnectToIP.ShowModal = mrOK then begin
    { OK, connettiamoci all'Host/IP selezionato }
    ServerInfo := TServerInfo.Create(self,ConnectToIP.txtIP.Text,StrToInt(ConnectToIP.txtPort.Text));

    { E' disponibile il server? }
    if ServerInfo.IsAvaible then begin

      { Visualizza le informazioni nel riepilogo }
      ShowServerInfo(ServerInfo);

      { Aggiunge l'oggetto ServerInfo nella lista }
      ServerList.AddServerInfo(ServerInfo);

      { Riempie la listbox }
      ServerList.FillListBox(lstServers);

      { E abilita il pulsante per entrare... }
      BtnOK.Enabled := true;
    end
    else
      MessageBox(0,pchar(GetStr(165,ConnectToIP.txtIP.Text + ',' + ConnectToIP.txtPort.Text)),pchar(GetStr(164)),MB_OK or MB_ICONINFORMATION);
    end;
end;

procedure TFrmJoinGame.BtnOKClick(Sender: TObject);
begin
  { Continua solamente se è selezionata una partita }
  if lblShowServerInfoName.Caption <> '' then begin
    self.ModalResult := mrOK;
  end;
end;

procedure TFrmJoinGame.FormShow(Sender: TObject);
var
  LanScanner: TLanScanner;
begin
  { Crea un oggetto LanScanner che
  setaccera' la rete locale in cerca di un server attivo }
  LanScanner := TLanScanner.Create(self,lstServers, ServerList);
end;

end.
