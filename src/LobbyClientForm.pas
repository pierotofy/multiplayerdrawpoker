unit LobbyClientForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, HostGame, UpdateChecker,
  Constants, ExtCtrls, WindowsUtils, ServerInfo, Languages;

type
  TFrmLobbyClient = class(TForm)
    GrpUsers: TGroupBox;
    GrpGames: TGroupBox;
    LstUsers: TListBox;
    LstGames: TListBox;
    BtnJoin: TButton;
    BtnHost: TButton;
    txtMessage: TEdit;
    BtnSend: TButton;
    StatusBar: TStatusBar;
    txtChat: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LstGamesClick(Sender: TObject);
    procedure LstGamesDblClick(Sender: TObject);
    procedure LstUsersDblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    Choice: TGameChoice;
    HostGame: TFrmHostGame;
    ServerInfo: TServerInfo;
    Nickname: string;
    
    procedure ShowStatus(Status: string; Color: TColor = clBlack);
    procedure AppendMsg(Msg: string; Color: TColor = clBlack);
  end;

var
  FrmLobbyClient: TFrmLobbyClient;

implementation

uses LobbyClient;

var
  LobbyClient: TLobbyClient;

{$R *.dfm}

procedure TFrmLobbyClient.FormCreate(Sender: TObject);
begin
  { Setta il caption con il numero di versione }
  self.Caption := 'Lobby Multiplayer ' + LOBBYVERSION;
end;

{ Procedura per mostrare uno status nella statusbar }
procedure TFrmLobbyClient.ShowStatus(Status: string; Color: TColor = clBlack);
begin
  { Aggiunge lo status anche nella textbox }
  AppendMsg(MakeServerMessage(Status),Color);

  StatusBar.Panels.Items[0].Text := Status;
end;

{ Procedura per aggiungere un messaggio alla chat }
procedure TFrmLobbyClient.AppendMsg(Msg: string; Color: TColor = clBlack);
begin
  txtChat.SelStart := Length(txtChat.Text);
  txtChat.SelLength := Length(txtChat.Text) + Length(Msg);
  //txtChat.SelAttributes.Color := Color; Disponibile solo con il RichEdit, ma da problemi questo controllo..

  txtChat.Lines.Append(Msg);
  txtChat.Perform(EM_SCROLLCARET,0,0);
end;

procedure TFrmLobbyClient.FormShow(Sender: TObject);
var
  UpdateChecker: TUpdateChecker;
begin
  { Crea l'oggetto TLobbyClient }
  LobbyClient := TLobbyClient.Create(self,self,GetFavouriteNick);

  { Controlla gli aggiornamenti... }
  UpdateChecker := TUpdateChecker.Create(self,false);
end;

{ Sull'evento di chiusura della form, distruggi l'oggetto LobbyClient }
procedure TFrmLobbyClient.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  LobbyClient.Free;
end;

{ Se viene selezionato un game, abilita il pulsante per joinare }
procedure TFrmLobbyClient.LstGamesClick(Sender: TObject);
var
  C: integer;
begin
  { Itera per trovare l'elemento della lista selezionato... }
  for C := 0 to LstGames.Items.Count-1 do
  begin
    if lstGames.Selected[C] then begin
      ServerInfo := TServerInfo(lstGames.Items.Objects[C]);
      BtnJoin.Enabled := true;
      exit;
    end;
  end;
end;

{ Se viene fatto doppio click, mostra le informazioni del game... }
procedure TFrmLobbyClient.LstGamesDblClick(Sender: TObject);
var
  C: integer;
begin
  { Itera per trovare l'elemento della lista selezionato... }
  for C := 0 to LstGames.Items.Count-1 do
  begin
    if lstGames.Selected[C] then begin
      ServerInfo := TServerInfo(lstGames.Items.Objects[C]);

      AppendMsg(''); //Riga vuota
      AppendMsg(GetStr(25) + ' ' + ServerInfo.GetServerName);
      if ServerInfo.IsPasswordRequired then AppendMsg(GetStr(26) + ': ' + GetStr(27))
      else AppendMsg(GetStr(26) + ': ' + GetStr(28));
      AppendMsg(GetStr(29) + ': ' + IntToStr(ServerInfo.GetPlayersConnected) + '/' + IntToStr(ServerInfo.GetSlots));
      AppendMsg(GetStr(30) + ': ' + IntToStr(ServerInfo.GetCip));
      AppendMsg('Ip/Host: ' + ServerInfo.Host);
      AppendMsg(GetStr(11) + ': ' + IntToStr(ServerInfo.Port));
      AppendMsg(GetStr(31) + ': ' + ServerInfo.GetServerVersion);
      AppendMsg(''); //Riga vuota
    end;
  end;
end;

{ Se viene fatto doppio click, mostra id e nickname dell'utente selezionato }
procedure TFrmLobbyClient.LstUsersDblClick(Sender: TObject);
var
  C: integer;
begin
  { Itera per trovare l'elemento della lista selezionato... }
  for C := 0 to LstUsers.Items.Count-1 do
  begin
    if LstUsers.Selected[C] then begin
      AppendMsg(''); //Riga vuota
      AppendMsg(GetStr(32) + ' ' + LstUsers.Items[C]);
      AppendMsg('Id: ' + IntToStr(C));
      AppendMsg(''); //Riga vuota
    end;
  end;
end;

procedure TFrmLobbyClient.FormActivate(Sender: TObject);
begin
  { Imposta la lingua }
  GrpUsers.Caption := GetStr(21);
  GrpGames.Caption := GetStr(22);
  BtnHost.Caption := GetStr(23);
  BtnJoin.Caption := GetStr(24);
  BtnSend.Caption := GetStr(14);
end;

end.
