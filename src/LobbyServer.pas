unit LobbyServer;

interface

uses Windows, SysUtils, ChatServer, Classes, IdTcpServer, ServerInfo, TestClient, StrUtils, Math, DateUtils,
  Constants, Languages;

var SeedId: longint;

{ TLobbyGame contiene le informazioni di una partita }
type
  TLobbyGame = class
  private
    AOwner: TComponent;
    m_Id: longint;
    m_Host: string;
    m_Port: integer;

  public
    constructor Create(AOwner: TComponent; Host: string; Port: integer);

    function IsAvaible: boolean;
    property Host: string read m_Host;
    property Port: integer read m_Port;
    property Id: longint read m_Id;
  end;

{ TLobbyServer eredita da TChatServer }
type
  TLobbyServer = class(TChatServer)
  private
    Games: TList;
    AOwner: TComponent;
    Motd: string;
    LastNicknameConnected: string;
    DateOfLastConnection: string;
    BannedList: TList;
    AdminPassword: string;

    function GetMsgToken(StrData: string; Index: integer): string;
    function StrContainsBadWords(Str: string): boolean;
  protected
    procedure ProcessCommand(StrData: string; AThread: TIdPeerThread); override;
    procedure DoLoginOperation(User: TChatUser); override;
    procedure DoDisconnectOperation(User: TChatUser); override;
    procedure SendMsgTo(User: TChatUser; Msg: string); override;
    procedure SendMsgToTranslateTo(User: TChatUser; DataIndex: integer; Arguments: string; ServerMessage: boolean);
    procedure SendMsgToTranslateToAll(DataIndex: integer; Arguments: string; ServerMessage: boolean);

    { Gestore d'evento per la disconnessione... }
    procedure Client_Disconnected(AThread: TIdPeerThread);
  public
    constructor Create(AOwner: TComponent; Port: integer); overload;
    constructor Create(AOwner: TComponent; Port: integer; Motd: string); overload;
    constructor Create(AOwner: TComponent; Port: integer; Motd: string; AdminPassword: string); overload;
    procedure SendUserListTo(AThread: TIdPeerThread);
    procedure SendUserListToAll;
    procedure SendGameListTo(AThread: TIdPeerThread);
    procedure SendGameListToAll;
    procedure AddGame(Game: TLobbyGame);
    function GetGame(Index: integer): TLobbyGame;
    function GetGameFromId(Id: integer): TLobbyGame;
    procedure DeleteGame(Index: integer);
    procedure DeleteGameWithId(Id: integer);
    function GetGamesCount: integer;
    procedure Kick(User: TChatUser; Motivation: string);
    procedure Ban(User: TChatUser; Motivation: string);
    function IsBanned(Ip: string): boolean;
  end;

implementation

uses LobbyScanner;

{ Implementazione classe TLobbyGame }
constructor TLobbyGame.Create(AOwner: TComponent; Host: string; Port: integer);
begin
  self.AOwner := AOwner;
  self.m_Host := Host;
  self.m_Port := Port;


  { Assegna un valore id al game e incrementa il contatore }
  self.m_Id := SeedId;
  inc(SeedId);
end;

{ Funzione che controlla l'esistenza effettiva nella rete di una partita
chiamata bloccante }
function TLobbyGame.IsAvaible: boolean;
var
  ServerInfo: TServerInfo;
begin
  ServerInfo := TServerInfo.Create(AOwner,Host,Port,INTERNETTIMEOUT);
  if ServerInfo.IsAvaible and (not ServerInfo.IsTheGameStarted) then Result := true
  else Result := false;
end;



{ Implementazione classe TLobbyServer }
constructor TLobbyServer.Create(AOwner: TComponent; Port: integer);
var
  LobbyScanner: TLobbyScanner;
begin
  { Inizializza la lista delle partite }
  Games := TList.Create;

  { Inizializza la lista degli IP bannati }
  BannedList := TList.Create;

  { Di default amministrazione remota disabilitata }
  self.AdminPassword := '';

  { Salva il riferimento ad AOwner }
  self.AOwner := AOwner;

  { Setta un messaggio di benvenuto predefinito... }
  self.Motd := GetStr(123);

  { Inizializza alcune vars... }
  LastNicknameConnected := '';
  DateOfLastConnection := '';

  inherited Create(AOwner, Port);

  { Inzializza il LobbyScanner }
  LobbyScanner := TLobbyScanner.Create(self);

  { Imposta il gestore d'evento per la disconnessione... }
  ServerSocket.OnDisconnect := Client_Disconnected;
end;

{ Versione overloadata che aggiunge il motd }
constructor TLobbyServer.Create(AOwner: TComponent; Port: integer; Motd: string);
begin
  Create(AOwner, Port);
  self.Motd := Motd;
end;

{ Versione overloadata che aggiunge l'adminpassword }
constructor TLobbyServer.Create(AOwner: TComponent; Port: integer; Motd: string; AdminPassword: string);
begin
  { Richiama il costruttore base }
  Create(AOwner,Port,Motd);

  { Imposta la password per l'amministratore... }
  self.AdminPassword := AdminPassword;
end;

{ Aggiunge una partita alla lista }
procedure TLobbyServer.AddGame(Game: TLobbyGame);
begin
  Games.Add(Game);
end;

{ Rimuove una partita dalla lista }
procedure TLobbyServer.DeleteGame(Index: integer);
begin
  Games.Delete(Index);
end;

{ Rimuove una partita dalla lista partendo dal suo id }
procedure TLobbyServer.DeleteGameWithId(Id: integer);
var
  C: integer;
begin
  for C := 0 to Games.Count-1 do
    if GetGame(C).Id = Id then Games.Delete(C);
end;

{ Prende una partita partendo dal suo index }
function TLobbyServer.GetGame(Index: integer): TLobbyGame;
begin
  Result := TLobbyGame(Games.Items[Index]);
end;

{ Prende una partita partendo dal suo id }
function TLobbyServer.GetGameFromId(Id: integer): TLobbyGame;
var
  C: integer;
  Game: TLobbyGame;
begin
  for C := 0 to Games.Count-1 do
  begin
    Game := GetGame(C);
    if Game.Id = Id then begin
      Result := Game;
      exit;
    end;
  end;
  raise Exception.Create('Si è cercato di prendere l''oggetto TLobbyGame con Id: ' + IntToStr(Id) + ', ma non è stato trovato nell''elenco. Contattare il produttore.');
end;


{ Procedura per inviare un messaggio da tradurre prima di essere visualizzato }
procedure TLobbyServer.SendMsgToTranslateTo(User: TChatUser; DataIndex: integer; Arguments: string; ServerMessage: boolean);
begin
  SendTo(User.AThread,'/TRANSLATEMSG'+SEPARATOR+IntToStr(DataIndex)+SEPARATOR+Arguments+SEPARATOR+BoolToStr(ServerMessage));
end;

{ Procedura per inviare un messaggio da tradurre prima di essere visualizzato
a tutti i clients }
procedure TLobbyServer.SendMsgToTranslateToAll(DataIndex: integer; Arguments: string; ServerMessage: boolean);
var
  C: integer;
begin
  for C := 0 to Clients.Count-1 do
    SendMsgToTranslateTo(GetUser(C),DataIndex,Arguments,ServerMessage);
end;

{ Ridefiniamo la procedura process command per aggiungere nuovi comandi... }
procedure TLobbyServer.ProcessCommand(StrData: string; AThread: TIdPeerThread);
var
  Command: string;
  TestClient: TTestClient;
  NewNickname: string;
  OldNickname: string;
  User: TChatUser;
  CommandToken: string;
  Motivation: string;
begin
  { Ok, aggiungiamo quel che ci serve, il resto lo ereditiamo dalla chat base }
  Command := GetCommand(StrData);

  { Parsa questi pacchetti solamente se sono di un utente loggato }
  if IsThisPeerThreadInList(AThread) then begin

    { Chi sei? }
    User := GetUser(AThread);

    { Un utente ha richiesto la lista... }
    if Command = '/GIMMETHEUSERLIST' then begin
      SendUserListTo(AThread);
    end

    { Elaboriamo i comandi digitati dalla chat... irc mode }
    else if Command = '/MSG' then begin

      { Per prima cosa, controlliamo che non ci siano parole volgari...
      Detesto quelli che usano parolaccie in chat }
      if StrContainsBadWords(GetToken(StrData,1)) then begin
        { Trovato un utente volgare? Bene, kick immediato }
        Kick(User,GetStr(145));
        SendMsgToTranslateToAll(124,User.Nickname,true);
        SendUserListToAll;
        exit;
      end;

      
      { Un giocatore ha digitato il comando /NICK }
      if AnsiUpperCase(GetMsgToken(StrData,0)) = '/NICK' then begin
        OldNickname := User.Nickname;
        NewNickname := Trim(AnsiRightStr(GetToken(StrData,1),Length(GetToken(StrData,1)) - Length('/NICK ')));

        { Se qualcuno cerca di farmi un buffer overflow... }
        if Length(NewNickname) > 20 then NewNickname := AnsiLeftStr(NewNickname,20);

        { Togli le @ dal nickname... (riservato agli amministratori) }
        NewNickname := AnsiReplaceStr(NewNickname,'@','');

        { Se il nickname esiste gia, aggiungi un numero casuale alla fine... }
        if NicknameAlreadyExists(NewNickname) then NewNickname := NewNickname + IntToStr(RandomRange(0,9999));
        User.Nickname := NewNickname;

        SendTo(AThread,'/NICKNAMECHANGEDSUCCESSFUL'+SEPARATOR+NewNickname);
        SendMsgToTranslateToAll(125,OldNickname+','+NewNickname,true);
        SendUserListToAll;

        { Previene che questo messaggio venga elaborato dalla classe base }
        exit;
      end

      { Un giocatore ha digitato il comando /ADMINLOGIN }
      else if AnsiUpperCase(GetMsgToken(StrData,0)) = '/ADMINLOGIN' then begin

        { Se non c'è password, non è possibile amministrare il gateway }
        if AdminPassword = '' then SendMsgToTranslateTo(User,126,'',true)

        { Altrimenti se la password è corretta, abbiamo un amministratore... }
        else if GetMsgToken(StrData,1) = AdminPassword then begin
          User.IsAdmin := true;

          { Notifica nella finestra di chat e modifica il nickname }
          SendMsgToTranslateToAll(127,User.Nickname,true);
          SendMsgToTranslateTo(User,128,'',false);
          SendMsgToTranslateTo(User,129,'',false);
          SendMsgToTranslateTo(User,130,'',false);
          User.Nickname := '@'+User.Nickname;
          SendUserListToAll;
        end

        else SendMsgToTranslateTo(User,131,'',true);

        { Previene che questo messaggio venga elaborato dalla classe base }
        exit;
      end

      { Un giocatore ha digitato il comando /KICK }
      else if AnsiUpperCase(GetMsgToken(StrData,0)) = '/KICK' then begin

        { Se l'utente è un amministratore, allora continua con il parsing }
        if User.IsAdmin then begin
          CommandToken := Trim(GetMsgToken(StrData,1));
          Motivation := Trim(AnsiRightStr(GetToken(StrData,1),Length(GetToken(StrData,1)) - Length('/KICK ') - Length(CommandToken + ' ')));

          { Se il parametro non è un intero cattura
          le eccezzioni... }
          try
            User := GetUser(StrToInt(CommandToken));
            Kick(User,Motivation);
            SendMsgToTranslateToAll(132,User.Nickname+','+Motivation,true);
            SendUserListToAll;
          except
            SendMsgToTranslateTo(User,133,'',true);
          end;
        end

        { Altrimenti avvisalo che solo gli amministratori possono fare queste operazioni }
        else SendMsgToTranslateTo(User,134,'',true);


        { Previene che questo messaggio venga elaborato dalla classe base }
        exit;
      end

      { Un giocatore ha digitato il comando /BAN }
      else if AnsiUpperCase(GetMsgToken(StrData,0)) = '/BAN' then begin

        { Se l'utente è un amministratore, allora continua con il parsing }
        if User.IsAdmin then begin
          CommandToken := Trim(GetMsgToken(StrData,1));
          Motivation := Trim(AnsiRightStr(GetToken(StrData,1),Length(GetToken(StrData,1)) - Length('/BAN ') - Length(CommandToken + ' ')));

          { Se il parametro non è un intero cattura
          le eccezioni... }
          try
            User := GetUser(StrToInt(CommandToken));
            Ban(User, Motivation);
            SendMsgToTranslateToAll(135,User.Nickname+','+Motivation,true);
            SendUserListToAll;
          except
            SendMsgToTranslateTo(User,136,'',true);
          end;
        end

        { Altrimenti avvisalo che solo gli amministratori possono fare queste operazioni }
        else SendMsgToTranslateTo(User,134,'',true);


        { Previene che questo messaggio venga elaborato dalla classe base }
        exit;
      end

      { Un giocatore ha digitato il comando /CLEARBANLIST }
      else if AnsiUpperCase(GetMsgToken(StrData,0)) = '/CLEARBANLIST' then begin
        BannedList.Clear;
        SendMsgToTranslateTo(User,137,'',true);

        { Previene che questo messaggio venga elaborato dalla classe base }
        exit;
      end;

    end

    { Un giocatore vuole avviare una nuova partita
    Command = '/ISTARTANEWGAME_Port' }
    else if Command = '/ISTARTANEWGAME' then begin
      { Comunica ai clients che il giocatore ha avviato una nuova partita }
      SendMsgToTranslateToAll(168,User.Nickname,true);

      AddGame(TLobbyGame.Create(AOwner,GetUser(AThread).Ip,StrToInt(GetToken(StrData,1))));

      { Comunica ai clients la nuova lista... }
      SendGameListToAll;
    end

    else if Command = '/GIMMETHEGAMELIST' then begin
      SendGameListTo(AThread);
    end

    { C'è un client che ha bisogno del test di connessione...
    Command = '/IMREADYFORTHECONNECTIONTEST_PortToTest' }
    else if Command = '/IMREADYFORTHECONNECTIONTEST' then begin
      { l'oggetto TestClient opera in un thread secondario e notifica in maniera autonoma il risultato
      del test }
      TestClient := TTestClient.Create(AOwner,GetUser(AThread).Ip,StrToInt(GetToken(StrData,1)),AThread);
    end;
  end
  else begin
    { Altrimenti parsa pure questi (se è di un utente non loggato) }

    { La versione di questo client combacia con la nostra? }
    if Command = '/MYLOBBYVERSIONIS' then begin
      if GetToken(StrData,1) = LOBBYVERSION then SendTo(AThread,'/URLOBBYVERSIONISSUPPORTED')
      else SendTo(AThread,'/URLOBBYVERSIONISNOTSUPPORTED'+SEPARATOR+LOBBYVERSION);
    end;
  end;

  inherited ProcessCommand(StrData,AThread);
end;

{ Se un giocatore si è disconnesso senza notificare nulla... }
procedure TLobbyServer.Client_Disconnected(AThread: TIdPeerThread);
begin
  { Se non si è disconnesso con la procedura standard... disconnettilo }
  if IsThisPeerThreadInList(AThread) then DoDisconnectOperation(GetUser(AThread));
end;

{ Ridefinisce la procedura per inviare i messaggi agli utenti }
procedure TLobbyServer.SendMsgTo(User: TChatUser; Msg: string);
begin
  { Se il messaggio è di un utente (comincia con '<') aggiungi la data, altrimenti niente }
  if AnsiStartsStr('<',Msg) then inherited SendMsgTo(User,'['+TimeToStr(Time)+'] ' + Msg)
  else inherited SendMsgTo(User,Msg);
end;


{ Procedura per inviare la lista degli utenti connessi ad un utente }
procedure TLobbyServer.SendUserListTo(AThread: TIdPeerThread);
var
  UserListStr: string;
  C: integer;
begin
  UserListStr := '/USERLIST' + SEPARATOR + IntToStr(Clients.Count);

  { Creiamo la lista in un formato stringa }
  for C := 0 to Clients.Count-1 do
    UserListStr := UserListStr + SEPARATOR + GetUser(C).Nickname;

  { E inviamola all'utente }
  SendTo(AThread,UserListStr);
end;

{ Procedura per inviare a tutti i clients connessi la lista degli utenti }
procedure TLobbyServer.SendUserListToAll;
var
  C: integer;
begin
  for C := 0 to Clients.Count-1 do
    SendUserListTo(GetUser(C).AThread);
end;

{ Procedura per inviare la lista della partite a tutti gli utenti }
procedure TLobbyServer.SendGameListToAll;
var
  C: integer;
begin
  for C := 0 to Clients.Count-1 do
    SendGameListTo(GetUser(C).AThread);
end;

{ Funzione per inviare la lista delle partite ad un utente }
procedure TLobbyServer.SendGameListTo(AThread: TIdPeerThread);
var
  GameListStr: string;
  Game: TLobbyGame;
  C: integer;
begin
  GameListStr := '/GAMELIST' + SEPARATOR + IntToStr(Games.Count);

  { Crea la lista in formato stringa }
  for C := 0 to Games.Count-1 do
  begin
    Game := GetGame(C);
    GameListStr := GameListStr + SEPARATOR + Game.Host + SEPARATOR + IntToStr(Game.Port);
  end;

  { E la invia }
  SendTo(AThread,GameListStr);
end;

{ Funzione che ritorna il numero di partite presenti nella lista  }
function TLobbyServer.GetGamesCount: integer;
begin
  Result := Games.Count;
end;

{ Procedura richiamata subito dopo il login }
procedure TLobbyServer.DoLoginOperation(User: TChatUser);
begin
  { Prima di tutto, vediamo se l'amico è bannato o no... }
  if IsBanned(User.Ip) then begin
    Kick(User,GetStr(138));
    exit;
  end;

  { Se l'utente ha un nick sgarbato, riadattiamolo... }
  if StrContainsBadWords(User.Nickname) then User.Nickname := GetStr(139);

  { Invia la lista degli utenti, quella delle partite,
  invia il messaggio di benvenuto al client e notifica l'entrata nel lobby
  a tutti quanti, mostra l'ultimo utente connesso e quando }

  SendUserListToAll;
  SendGameListTo(User.AThread);

  SendMsgTo(User,''); //Riga vuota

  { Messaggio personalizzato in base al numero di utenti connessi... }
  //if Clients.Count < 2 then SendMsgTo(User,MakeServerMessage('Se non ci sono giocatori connessi al lobby, aspetta una decina di minuti prima di andartene.'))
  //SendMsgTo(User,MakeServerMessage('Questo server lobby è aggiornato alla versione ' + LOBBYVERSION + ', vi prego di segnalare qualsiasi malfunzionamento del gioco all''indirizzo ' + SUBMITBUGPAGE));

  SendMsgToTranslateTo(User,140,'',false);
  SendMsgToTranslateTo(User,141,'',false);
  SendMsgTo(User,''); //Riga vuota
  SendMsgTo(User,MakeServerMessage(Motd));


  { Se qualcuno si è già connesso e non ci sono giocatori nel lobby,
  vuol dire che abbiamo qualcosa da stampare }
  if (LastNicknameConnected <> '') and (Clients.Count < 2) then SendMsgToTranslateTo(User,142,LastNicknameConnected+','+DateOfLastConnection,true);

  { Salva il nuovo nickname dell'ultimo utente, e la data di connessione }
  LastNicknameConnected := User.Nickname;
  DateOfLastConnection := TimeToStr(Time);


  SendMsgToTranslateToAll(143,User.Nickname,true);
end;

{ Un client se n'è andato.. }
procedure TLobbyServer.DoDisconnectOperation(User: TChatUser);
var
  AThread: TIdPeerThread;
begin
  AThread := User.AThread;
  SendMsgToTranslateToAll(144,User.Nickname,true);
  RemoveUser(AThread);
  SendUserListToAll;
  AThread.Connection.Disconnect;
end;

{ Procedura per kickare un utente.. }
procedure TLobbyServer.Kick(User: TChatUser; Motivation: string);
begin
  SendTo(User.AThread,'/UAREGONNABEKICKEDCOZ'+SEPARATOR+Motivation);
  RemoveUser(User.AThread);
  User.AThread.Connection.Disconnect;
end;

{ Procedura per bannare un utente.. }
procedure TLobbyServer.Ban(User: TChatUser; Motivation: string);
begin
  BannedList.Add(User);
  Kick(User,Motivation);
end;

{ Funzione per controllare se un utente è bannato... }
function TLobbyServer.IsBanned(Ip: string): boolean;
var
  C: integer;
begin
  Result := false;
  
  for C := 0 to BannedList.Count-1 do
  begin
    if TChatUser(BannedList.Items[C]).Ip = Ip then begin
      Result := true;
      exit;
    end;
  end;
end;

{ Funzione che ritorna il token di un messaggio di chat
(quindi con header '/MSG') }
function TLobbyServer.GetMsgToken(StrData: string; Index: integer): string;
begin
  StrData := AnsiReplaceStr(StrData,' ',SEPARATOR);
  Result := GetToken(StrData,Index+1); //Index + 1 perchè 1 è il /MSG
end;

{ Funzione per controllare se nel messaggio sono presenti parolacce }
function TLobbyServer.StrContainsBadWords(Str: string): boolean;
var
  BadWordsDictionary: array [0 .. 11] of string;
  C: integer;
begin
  Result := false;

  { Crea il dizionario di termini volgari... }
  BadWordsDictionary[0] := 'fancul';
  BadWordsDictionary[1] := 'stronz';
  BadWordsDictionary[2] := 'puttan';
  BadWordsDictionary[3] := 'troia';
  BadWordsDictionary[4] := 'gay';
  BadWordsDictionary[5] := 'deficente';
  BadWordsDictionary[6] := 'culatt';
  BadWordsDictionary[7] := 'merd';
  BadWordsDictionary[8] := 'fuck';
  BadWordsDictionary[9] := 'fotti';
  BadWordsDictionary[10] := 'idiot';
  BadWordsDictionary[11] := 'cazz';

  for C := 0 to 11 do
    if AnsiContainsStr(AnsiLowerCase(Str),BadWordsDictionary[C]) then begin
      Result := true;
      exit;
    end;
end;



initialization

SeedId := 0;

end.
