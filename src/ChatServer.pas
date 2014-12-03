unit ChatServer;

interface

uses Windows, IdTcpServer, Classes, SysUtils, Math,
  Constants, Languages;

{ Classe che contiene l'astrazione di un utente della chat }
type
  TChatUser = class
  public
    Nickname: string;
    AThread: TIdPeerThread;
    Ip: string;
    IsAdmin: boolean;
    
    constructor Create(AThread: TIdPeerThread; Nickname: string);
  end;

{ Classe per gestire il server di chat
NB: Chiunque può loggarsi al server e chattare anche non essendo un giocatore della partita }
type
  TChatServer = class
  private
    { Gestore d'evento per il server }
    procedure ServerExecute(AThread: TIdPeerThread);
  protected
    Clients: TList;
    ServerSocket: TIdTcpServer;

    procedure AddUser(User: TChatUser);
    function GetUser(Index: integer): TChatUser; overload;
    function GetUser(AThread: TIdPeerThread): TChatUser; overload;
    procedure RemoveUser(AThread: TIdPeerThread);

    procedure SendToAll(Command: string);
    procedure SendMsgToAll(Msg: string);
    function IsThisPeerThreadInList(AThread: TIdPeerThread): boolean;
    procedure SendTo(AThread: TIdPeerThread; Command: string);
    procedure ProcessCommand(StrData: string; AThread: TIdPeerThread); virtual;
    procedure DoDisconnectOperation(User: TChatUser); virtual;
    procedure DoLoginOperation(User: TChatUser); virtual;
    procedure SendMsgTo(User: TChatUser; Msg: string); virtual;
    function NicknameAlreadyExists(Nickname: string): boolean;
  public
    constructor Create(AOwner: TComponent; Port: integer = CHATPORT);
    destructor Destroy; override;
  end;

implementation

{ Implementazione classe TChatUser }
constructor TChatUser.Create(AThread: TIdPeerThread; Nickname: string);
begin
  self.AThread := AThread;
  self.Nickname := Nickname;
  self.Ip := AThread.Connection.Socket.Binding.PeerIP;
  self.IsAdmin := false;
end;

{ Implementazione classe TChatServer }
constructor TChatServer.Create(AOwner: TComponent; Port: integer = CHATPORT);
begin
  { Inizializza la lista... }
  Clients := TList.Create;

  { Setta la porta ed mette il server in ascolto }
  ServerSocket := TIdTcpServer.Create(AOwner);
  ServerSocket.Bindings.Add.Port := Port;
  ServerSocket.Bindings.Add.IP := '127.0.0.1';

  //ServerSocket.MaxConnections := MAXSLOTS;

  { Imposta il gestore d'evento per il server }
  ServerSocket.OnExecute := ServerExecute;
  try
    ServerSocket.Active := true;
  except
    raise Exception.Create(GetStr(119,IntToStr(Port)));
  end;
end;

{ Distruttore }
destructor TChatServer.Destroy;
begin
  { Se è presente il server fermalo }
  if ServerSocket.Active then ServerSocket.Active := false;

  inherited Destroy;
end;

{ Se esiste già un giocatore con questo nickname... }
function TChatServer.NicknameAlreadyExists(Nickname: string): boolean;
var
  C: integer;
begin
  Result := false;
  for C := 0 to Clients.Count-1 do
    if GetUser(C).Nickname = Nickname then Result := true;
end;


{ Procedura per inviare a tutti gli utenti un comando }
procedure TChatServer.SendToAll(Command: string);
var
  C: integer;
begin
  for C := 0 to Clients.Count-1 do
    SendTo(GetUser(C).AThread,Command);
end;

{ Procedura per inviare a tutti gli utenti un messaggio }
procedure TChatServer.SendMsgToAll(Msg: string);
var
  C: integer;
begin
  for C := 0 to Clients.Count -1 do
    SendMsgTo(GetUser(C),Msg);
end;

{ Funzione che ritorna true se un peerthread corrisponde nella lista degli utenti connessi }
function TChatServer.IsThisPeerThreadInList(AThread: TIdPeerThread): boolean;
var
  C: integer;
begin
  for C := 0 to Clients.Count-1 do
  begin
    if GetUser(C).AThread.Handle = AThread.Handle then begin
      Result := true;
      exit;
    end;
  end;
  Result := false;
end;

{ Funzione che ritorna un oggetto TChatUser a partire dal suo indice nella lista }
function TChatServer.GetUser(Index: integer): TChatUser;
begin
  Result := TChatUser(Clients.Items[Index]);
end;

{ Funzione che ritorna un oggetto TChatUser a partire dal suo PeerThread }
function TChatServer.GetUser(AThread: TIdPeerThread): TChatUser;
var
  C: integer;
  User: TChatUser;
begin
  for C := 0 to Clients.Count-1 do
  begin
    User := GetUser(C);
    if User.AThread.Handle = AThread.Handle then begin
      Result := User;
      exit;
    end;
  end;

  { Questo non dovrebbe mai venir eseguito }
  raise Exception.Create('Non è stato possibile trovare l''utente della chat a partire dal suo PeerThread in TChatServer.GetUser. Contattare il produttore.');
end;

{ Procedura per aggiungere un utente alla lista }
procedure TChatServer.AddUser(User: TChatUser);
begin
  Clients.Add(User);
end;

{ Gestore d'evento che riceve tutti i messaggi del server }
procedure TChatServer.ServerExecute(AThread: TIdPeerThread);
begin
  ProcessCommand(AThread.Connection.ReadLn,AThread);
end;

{ Procedura per inviare un comando ad un client }
procedure TChatServer.SendTo(AThread: TIdPeerThread; Command: string);
begin
  { Usiamo la gestione degli errori silenziosa per non interferire con il gioco }
  try
    AThread.Connection.WriteLn(Command);
  except
  end;
end;

{ Procedura per eliminare un PeerThread dalla lista dei clients }
procedure TChatServer.RemoveUser(AThread: TIdPeerThread);
var
  C: integer;
begin
  for C := 0 to Clients.Count - 1 do
  begin
    if GetUser(C).AThread.Handle = AThread.Handle then begin
      Clients.Delete(C);
      exit;
    end;
  end;
end;

{ Procedura che processa i comandi in arrivo }
procedure TChatServer.ProcessCommand(StrData: string; AThread: TIdPeerThread);
var
  Command: string;
  User: TChatUser;
  Nickname: string;
begin
  Command := GetCommand(StrData);

  { Interpreta i comandi solamente se è un giocatore nella lista }
  if IsThisPeerThreadInList(AThread) then begin

    { Per il momento teniamo solamente una chat base... }
    if Command = '/MSG' then begin
      SendMsgToAll('<'+GetUser(AThread).Nickname +'> '+GetToken(StrData,1));
    end

    { Se un utente si disconnette... }
    else if Command = '/IDISCONNECT' then begin
      DoDisconnectOperation(GetUser(AThread));
      RemoveUser(AThread);
    end
  end

  { Altrimenti parsa il comando di login anche se non è un client loggato }
  { Command = '/LOGIN_Nickname' }
  else if Command = '/LOGIN' then begin
    Nickname := GetToken(StrData,1);

    { Se esiste gia un giocatore con questo nickname, aggiungigli un numero casuale accanto }
    if NicknameAlreadyExists(Nickname) then Nickname := Nickname + IntToStr(RandomRange(0,999));

    User := TChatUser.Create(AThread,Nickname);
    AddUser(User);

    { Notifica l'entrata nella chat a tutti... }
    DoLoginOperation(User);
  end;
end;

{ Procedura vuota ma serve per l'erediterietà }
procedure TChatServer.DoLoginOperation(User: TChatUser); 
begin
  
end;

{ Procedura vuota ma serve per l'ereditarietà }
procedure TChatServer.DoDisconnectOperation(User: TChatUser);
begin

end;

{ Procedura per inviare un messaggio ad un utente }
procedure TChatServer.SendMsgTo(User: TChatUser; Msg: string);
begin
  SendTo(User.AThread,'/MSG'+SEPARATOR+Msg);
end;


end.
