unit GameServer;

interface

uses Windows, Classes, IdTcpServer, SysUtils, Forms,
  Deck, Card, Player, Client, ClientList, Constants, Languages;

type
  TGameServer = class
  private
    AOwner: TComponent; { Riferimento al form principale }

    m_Cip: integer;
    m_InitialMoney: integer;
    m_Port: integer;
    m_Password: string;
    m_Name: string;
    m_Slots: integer;
    m_GameStarted: boolean;

    ServerSocket: TIdTcpServer;

    { Variabile che contiene memorizzato il valore del piatto }
    MoneyTable: integer;

    { Lista dei thread dei giocatori }
    Players: TClientList;

    { Variabile che contiene LA copia del mazzo }
    Deck: TDeck;

    { Variabile che memorizza l'id del mazziere }
    DeckerId: integer;

    { Valori che memorizzano i valori minimi e massimi di una puntata }
    BetMaxValue, BetMinValue: integer;

    { Valori che memorizzano l'ultima puntata di un giocatore }
    LastRelaunch: integer;

    { Variabile per tener conto del valore di apertura della mano }
    OpenValue: integer;

    { Variabile per sapere se qualcuno ha rilanciato }
    SomeoneRelaunched: boolean;

    { Variabile per sapere qual'è il tipo di coppia minima per aprire }
    MinPairFaceToOpen: TFace;

    { Questa variabile tiene conto del totale del denaro che è stato
    rilanciato durante una fase di gioco }
    RelaunchActionValue: integer;

    function GetCip: integer;
    function GetInitialMoney: integer;
    function GetPort: integer;
    function GetPassword: string;
    function GetName: string;
    function GetSlots: integer;
    function GetGameStarted: boolean;
    procedure SetGameStarted(GameStarted: boolean);

    { Procedure per la socket }
    procedure SendToAll(Command: string);
    procedure SendToAllExcept(Command: string; AThread: TIdPeerThread);
    procedure SendTo(AThread: TIdPeerThread; Command: string); overload;
    procedure SendTo(PlayerId: integer; Command: string); overload;
    function ReceiveFrom(AThread: TIdPeerThread): string; overload;
    function ReceiveFrom(PlayerId: integer): string; overload;

    { Gestori d'evento per il server }
    procedure ServerExecute(AThread: TIdPeerThread);
    procedure Server_ClientDisconnect(AThread: TIdPeerThread);

    procedure ProcessCommand(StrData: string; AThread: TIdPeerThread); overload;
    procedure ProcessCommand(StrData: string; PlayerId: integer); overload;
    function IsPasswordRequired: boolean;
    procedure SendPlayersProjection(AThread: TIdPeerThread);
    procedure SendPlayersProjectionToAll;
    procedure SendServerInfo(AThread: TIdPeerThread);
    procedure DoClientLoginOperation(AThread: TIdPeerThread);
    procedure StartGame;
    function GetNextDeckerId: integer;
    function GetPlayerIdOnTheLeftOf(PlayerId: integer): integer;
    function GetPlayerIdOnTheRightOf(PlayerId: integer): integer;
    procedure DistroCardsToPlayers;
    procedure SendPlayersHandProjection(CoveredMode: boolean);
    procedure SendPlayerHandProjection(CoveredMode: boolean; Client: TClient; ClientToSend: TClient; FirstHand: boolean);
    procedure SelectCard(AThread: TIdPeerThread; CardIndex: integer);
    procedure DeselectCard(AThread: TIdPeerThread; CardIndex: integer);
    procedure ChangeCards(AThread: TIdPeerThread);
    procedure EnablePanelTo(PanelMode: TPanelMode; AThread: TIdPeerThread); overload;
    procedure EnablePanelTo(PanelMode: TPanelMode; PlayerId: integer); overload;
    procedure DisablePanelTo(AThread: TIdPeerThread; Hide: boolean); overload;
    procedure DisablePanelTo(PlayerId: integer; Hide: boolean); overload;
    procedure DisplayStartGameButtonIfNeeded(AThread: TIdPeerThread; CheckForHost: boolean);
    function GetHost: TClient;
    procedure SendMoneyProjection;
    procedure SendPlayerMoneyProjection(Client: TClient; ClientToSend: TClient);
    function AskForOpenValue: integer;
    procedure AskForStartGame;
    procedure AskForPlayOrPassOrRelaunch(PlayerIdStarter: integer);
    procedure InitProcAskForPlayOrPassOrRelaunch(PlayerIdStarter: integer);
    function AskForCipOrRelaunchOrSeeOrWordsOrPass(PlayerIdStarter: integer): boolean;
    procedure AskForRevealCards(PlayerIdStarter: integer);
    function InitProcAskForCipOrRelaunchOrSeeOrWordsOrPass(PlayerIdStarter: integer): boolean;
    function AskForOpenOrPass: integer;
    procedure SetBetRange(BetMaxValue, BetMinValue: integer);
    function WaitForACommandReply(AThread: TIdPeerThread; Command: string): string; overload;
    function WaitForACommandReply(PlayerId: integer; Command: string): string; overload;
    procedure WaitForCardsChangedByPlayers;
    procedure AskForChangeCards;
    procedure SetAllPlayersToPlay;
    procedure BeginTurn;
    procedure ClientsCanSelectCards(CanSelect: boolean);
    procedure ClientCanSelectCards(AThread: TIdPeerThread; CanSelect: boolean);
    procedure TranslateMoneyFromPlayerToTable(AThread: TIdPeerThread; Money: integer); overload;
    procedure TranslateMoneyFromPlayerToTable(PlayerId: integer; Money: integer); overload;
    procedure TranslateMoneyFromTableToPlayer(PlayerId: integer);
    procedure TranslateMoneyFromAllPlayingPlayersToTable(Money: integer);
    procedure TranslateMoneyFromTableToAllPlayingPlayers;
    procedure TogglePlayerFromTurn(Client: TClient);
    function FindTheWinner: integer;
    function GetWinnerId: integer;
    procedure SetAllVarsToBeginATurn;
    procedure ToggleCardsFromPlayerIfHandNotEmpty;
    procedure AskForBeginNewTurn(PlayerId: integer);
    procedure SendStatus(Text: string); overload;
    procedure SendStatus(DataIndex: integer; Arguments: string); overload;
    procedure SendStatus(DataIndex: integer); overload;
    procedure EnableRelaunchButton(Client: TClient; Enabled: boolean);
    function GetPlayingPlayersCount: integer;
    procedure SetPlayersMoneyToInitialValue;

    procedure DisconnectPlayer(AThread: TIdPeerThread); overload;
    procedure DisconnectPlayer(PlayerId: integer); overload;
  public

    constructor Create(AOwner: TComponent; Name, Password: string; Port, Cip, InitialMoney, Slots: integer);
    destructor Destroy; override;

    property Cip: integer read GetCip;
    property InitialMoney: integer read GetInitialMoney;
    property Port: integer read GetPort;
    property Password: string read GetPassword;
    property Name: string read GetName;
    property Slots: integer read GetSlots;
    property GameStarted: boolean read GetGameStarted write SetGameStarted;

    end;

implementation

{ Implementazione classe TGame }

{ Costruttore per il server }
constructor TGameServer.Create(AOwner: TComponent; Name, Password: string; Port, Cip, InitialMoney, Slots: integer);
begin
  self.AOwner := AOwner;
  m_Name := Name;
  m_Password := Password;
  m_Port := Port;
  m_Cip := Cip;
  m_InitialMoney := InitialMoney;
  m_Slots := Slots;
  m_GameStarted := false;
  DeckerId := -1;
  BetMaxValue := 0;
  BetMinValue := 0;
  LastRelaunch := 0;
  MoneyTable := 0;
  RelaunchActionValue := 0;
  SomeoneRelaunched := false;
  MinPairFaceToOpen := Jack; //Di default basta una coppia di jack

  Players := TClientList.Create(Slots);

  { Setta la porta ed mette il server in ascolto }
  ServerSocket := TIdTcpServer.Create(AOwner);
  ServerSocket.Bindings.Add.Port := Port;
  ServerSocket.Bindings.Add.IP := '127.0.0.1';

  { Imposta i gestori d'evento per il server }
  ServerSocket.OnExecute := ServerExecute;
  try
    ServerSocket.Active := true;
  except
    raise Exception.Create(GetStr(65,IntToStr(Port)));
  end;
end;

{ Inizio funzioni per proprietà readonly }
function TGameServer.GetCip: integer;
begin
  Result := m_Cip;
end;
function TGameServer.GetInitialMoney: integer;
begin
  Result := m_InitialMoney;
end;
function TGameServer.GetPort: integer;
begin
  Result := m_Port;
end;
function TGameServer.GetPassword: string;
begin
  Result := m_Password;
end;
function TGameServer.GetName: string;
begin
  Result := m_Name;
end;
function TGameServer.GetSlots: integer;
begin
  Result := m_Slots;
end;
function TGameServer.GetGameStarted: boolean;
begin
  Result := m_GameStarted;
end;
{ Fine funzioni per proprietà readonly }

procedure TGameServer.SetGameStarted(GameStarted: boolean);
begin
  m_GameStarted := GameStarted;
end;


{ Procedure utili per la socket }
procedure TGameServer.SendToAll(Command: string);
var
  C: integer;
begin
  for C := 0 to Players.Count-1 do
    SendTo(Players.GetClient(C).AThread,Command);
end;

procedure TGameServer.SendToAllExcept(Command: string; AThread: TIdPeerThread);
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if Client.AThread.Handle <> AThread.Handle then SendTo(Client.AThread,(Command));
  end;

end;

{ Procedura richiamata quando viene disconnesso un client...
NOTA: inutilizzata }
procedure TGameServer.Server_ClientDisconnect(AThread: TIdPeerThread);
begin
  { Benissimo... disconnetti il giocatore se si tratta di un thread
  presente nella partita... :) }
  if Players.IsThisPeerThreadInList(AThread) then DisconnectPlayer(AThread);
end;

{ Questa procedura viene invocata ad ogni ricezione di un pacchetto primitivo dal client
la quale passa immediatamente l'esecuzione alla procedura processcommand }
procedure TGameServer.ServerExecute(AThread: TIdPeerThread);
begin
  { Per non intasare la cpu... }
  Sleep(10);

  { Elabora il comando solamente se si tratta di un nuovo giocatore }
  //or (not GameStarted)
  if (not Players.IsThisPeerThreadInList(AThread)) then ProcessCommand(ReceiveFrom(AThread),AThread);
end;

{ Procedura per processare i comandi
in questa procedura vengono smistate le richieste dei vari clients connessi al server
e vengono effettuate le operazioni necessarie al server per rispondere correttamente }
procedure TGameServer.ProcessCommand(StrData: string; AThread: TIdPeerThread);
var
  Command: string;
begin
  Command := GetCommand(StrData);

  { Ok, abbiamo una richiesta da un oggetto ServerInfo }
  if Command = '/GETSERVERINFO' then SendServerInfo(AThread)

  { Puo' un client connettersi? }
  else if Command = '/CANIJOIN' then DoClientLoginOperation(AThread)

  { Se la socket corrisponde ad uno dei clients connessi
  allora elabora i messaggi, altrimenti disconnetti il furbo
  che cerca di mandarti in tilt il server :) }
  else if Players.IsThisPeerThreadInList(AThread) then begin



    { Un client GIA connesso sta ri-chiedendo la proiezione dei giocatori }

    //Inutilizzata
    if Command = '/RESENDMEPLAYERSPROJECTION' then begin
      SendPlayersProjection(AThread);
    end

    { E' arrivato un messaggio di chat, reindirizzalo a tutti i clients
    Obsoleta/inutilizzata }
    //else if Command = '/CHATMESSAGE' then begin
    //  SendToAll('/CHATMESSAGE'+SEPARATOR+Players.GetClient(AThread).Nickname + SEPARATOR+ GetToken(StrData,1));
    //end


    { Un client ci sta chiedendo se è lui l'host
    (l'host ha sempre Id 0) }
    else if Command = '/AMITHEHOST' then begin
      if Players.GetClient(AThread).Id = 0 then SendTo(AThread,'/UARETHEHOST')
      else SendTo(AThread,'/UARENOTTHEHOST');
    end

    { Un client ci sta avvisando che ha selezionato una carta... }
    else if (Command = '/ISELECTEDTHISCARD') and GameStarted then begin
      SelectCard(AThread,StrToInt(GetToken(StrData,1)));
    end

    { Un client ci sta avvisando che ha deselezionato una carta.. }
    else if (Command = '/IDESELECTEDTHISCARD') and GameStarted then begin
      DeselectCard(AThread,StrToInt(GetToken(StrData,1)));
    end

    { Un client ci avvisa che vuole cambiare le carte }
    //else if (Command = '/ICHANGETHECARDS') and GameStarted then begin
    //  ChangeCards(AThread);
    //end

    { Un client se ne vuole andare }
    else if Command = '/IDISCONNECT' then begin
      DisconnectPlayer(AThread);
    end
  end
  //else CommandList.AddCommand(AThread,StrData);

end;

{ Versione overloadata di processcommand che accetta come argomento l'id di un giocatore }
procedure TGameServer.ProcessCommand(StrData: string; PlayerId: integer);
begin
  ProcessCommand(StrData,Players.GetClientWithId(PlayerId).AThread);
end;

{ E' richiesta la password in questo server? }
function TGameServer.IsPasswordRequired: boolean;
begin
  if Password <> '' then Result := true
  else Result := false;
end;

{ Procedura per inviare alla socket la proiezione dei giocatori,
quindi la loro posizione nel tavolo di gioco }
procedure TGameServer.SendPlayersProjection(AThread: TIdPeerThread);
var
  C: integer;
  Client: TClient;
  ClientId: integer;
  ClientToSend: TClient;
  ClientIdToSend: integer;
  StrOrder: string;

begin
  { Otteniamo un oggetto TClient a partire dal suo peerthread }
  Client := Players.GetClient(AThread);
  ClientId := Client.Id;

  { A seconda del suo id, otteniamo la stringa di ordinamento
  (indica l'ordine in cui devono essere visualizzati gli altri clients) }
  case ClientId of
    0: StrOrder := '0123';
    1: StrOrder := '1032';
    2: StrOrder := '2310';
    3: StrOrder := '3201';
  end;

  { Invia al client la proiezione...  }
  for C := 0 to MAXSLOTS-1 do
  begin
    ClientIdToSend := StrToInt(StrOrder[C+1]);

    { Se tale ID non esiste,
    vuol dire che il posto del tavolo è vuoto (quindi informiamo il client) }
    if not (Players.IdExists(ClientIdToSend)) then
      SendTo(AThread,'/BLANKPLACE'+SEPARATOR+IntToStr(ClientIdToSend))
    else begin
      ClientToSend := Players.GetClientWithId(ClientIdToSend);
      SendTo(AThread,'/PLAYERSPROJECTION'+SEPARATOR+IntToStr(ClientToSend.Id)+SEPARATOR+ClientToSend.Nickname+SEPARATOR+IntToStr(ClientToSend.Money));
    end;
  end;

  SendTo(AThread,'/PLAYERSPROJECTIONFINISHED');
end;

{ Procedura per inviare una striga a un peerthread }
procedure TGameServer.SendTo(AThread: TIdPeerThread; Command: string);
begin
  { Se abbiamo perso la connessione... cancella l'utente... }
  try
    AThread.Connection.WriteLn(Command);
  except
    DisconnectPlayer(AThread);
  end;
end;

{ Versione overloadata che riceve l'id del giocatore }
procedure TGameServer.SendTo(PlayerId: integer; Command: string);
begin
  SendTo(Players.GetClientWithId(PlayerId).AThread,Command);
end;

{ Funzione per ricevere una stringa da un peerthread }
function TGameServer.ReceiveFrom(AThread: TIdPeerThread): string;
begin
  Result := AThread.Connection.ReadLn;
end;

{ Versione overloadata che accetta l'id di un giocatore al posto del peerthread }
function TGameServer.ReceiveFrom(PlayerId: integer): string;
begin
  Result := ReceiveFrom(Players.GetClientWithId(PlayerId).AThread);
end;

{ Procedura che invia le informazioni a un oggetto ServerInfo }
procedure TGameServer.SendServerInfo(AThread: TIdPeerThread);
var
  DataToSend: string;
begin
  { Invia se è necessaria la password }
  DataToSend := '/PASSWORDREQUIRED'+SEPARATOR;
  if Password = '' then DataToSend := DataToSend + '0'
  else DataToSend := DataToSend + '1';
  SendTo(AThread,DataToSend );

  { Invia il numero di slots }
  SendTo(AThread,'/SLOTS'+SEPARATOR+IntToStr(Slots));

  { Invia il numero di giocatori connessi }
  SendTo(AThread,'/PLAYERSCONNECTED'+SEPARATOR+IntToStr(Players.Count));

  { Invia il nome del server }
  SendTo(AThread,'/SERVERNAME'+SEPARATOR+GetName);

  { Invia se il gioco è già avviato }
  DataToSend := '/GAMESTARTED'+SEPARATOR;
  if GameStarted then DataToSend := DataToSend + '1'
  else DataToSend := DataToSend + '0';
  SendTo(AThread,DataToSend);

  { Invia il cip }
  SendTo(AThread,'/CIP'+SEPARATOR+IntToStr(Cip));

  { Invia la versione del server }
  SendTo(AThread,'/SERVERVERSION'+SEPARATOR+PROGRAMVERSION);
end;

{ Procedura che verifica la corretta connessione di un client }
procedure TGameServer.DoClientLoginOperation(AThread: TIdPeerThread);
var
  ClientPassword: string;
  PasswordIsCorrect: boolean;
  Client: TClient;
  ClientVersion: string;
begin
  { Prima cosa in assoluto: confronta la versione del client e del server
  se non corrispondono, disconnetti }
  ClientVersion := GetToken(WaitForACommandReply(AThread,'/CLIENTVERSION'),1);
  if ClientVersion <> PROGRAMVERSION then begin
    SendTo(AThread,'/UCANTJOINCOZ'+SEPARATOR+GetStr(91,PROGRAMVERSION+','+ClientVersion))
  end;

  { Se è richiesta la password, chiediamola al client
  (comando = '/PASS'+SEPARATOR+PASSWORD) quindi Token = 1}
  PasswordIsCorrect := false;
  if IsPasswordRequired then begin
    ClientPassword := GetToken(WaitForACommandReply(AThread,'/PASS'),1);

    { Quindi confrontiamola... }
    if ClientPassword = Password then PasswordIsCorrect := true
    else PasswordIsCorrect := false;
  end;

  { Solo se il numero di giocatori è inferiore alle slots disponibili
  e se richiesta, solo se la password corrisponde
  e se il gioco non è gia stato avviato.. }
  if (Players.Count < Slots) and (not IsPasswordRequired or PasswordIsCorrect) and (not GameStarted) then begin
    { Ok puo' connettersi, diciamoglielo }
    SendTo(AThread,'/UCANJOIN');

    { Costruiamo un oggetto TClient }
    Client := TClient.Create(AThread,Players.Count,GetToken(WaitForACommandReply(AThread,'/MYNICKNAMEIS'),1),InitialMoney);

    { Salviamo l'oggetto nella lista dei clients }
    Players.AddClient(Client);

    { Invia al giocatore la proiezione dei giocatori... }
    //SendPlayersProjection(AThread);

    { Bisogna refreshare tutti i clients eccetto quello che
    ha appena richiesto la proiezione }
    SendToAllExcept('/PLAYERPROJECTIONREFRESHISNEEDED',AThread);

    { Invia a tutti i giocatori la nuova proiezione }
    SendPlayersProjectionToAll;

    { Richiama la procedura per visualizzare il pulsante di avvio qualora necessario }
    DisplayStartGameButtonIfNeeded(AThread,true);
  end

  else begin
    { Mi spiace, ma il giocatore non puo' entrare... }

    { Se è colpa delle slots }
    if (Players.Count >= Slots) then SendTo(AThread,'/UCANTJOINCOZ'+SEPARATOR+GetStr(92))

    { Se è colpa che il gioco è gia stato avviato.. }
    else if GameStarted then SendTo(AThread,'/UCANTJOINCOZ'+SEPARATOR+GetStr(93))

    { Se è colpa della password }
    else if not PasswordIsCorrect then SendTo(AThread,'/UCANTJOINCOZ'+SEPARATOR+GetStr(94));

    { Disconnette la socket }
    AThread.Connection.Disconnect;
  end;
end;

{ Procedura che coordina le operazioni di inizio gioco una volta avviato }
procedure TGameServer.StartGame;
begin
  { Prima di iniziare, re-imposta il denaro iniziale... }
  SetPlayersMoneyToInitialValue;

  { Invia la proiezione... }
  SendMoneyProjection;

  while GameStarted do
  begin
    BeginTurn;
  end;
end;

{ Questa funzione ritorna l'id del giocatore a cui tocca distribuire le carte
nota che il valore di ritorno viene automaticamente assegnato
anche alla variabile Decker }
function TGameServer.GetNextDeckerId: integer;
begin
  { Se è la prima volta, il valore del Decker è -1 }
  if DeckerId = -1 then DeckerId := 0

  { Non è la prima volta, ritornami l'id del prossimo mazziere }
  else DeckerId := GetPlayerIdOnTheLeftOf(DeckerId);

  { Se il mazziere non sta giocando (squalificato) allora prendi il prossimo mazziere }
  if not Players.GetClientWithId(DeckerId).IsPlaying then Result := GetNextDeckerId
  else Result := DeckerId;
end;

{ Funzione che ritorna l'id del giocatore subito alla sinistra
di un altro giocatore }
function TGameServer.GetPlayerIdOnTheLeftOf(PlayerId: integer): integer;
begin
  { L'ordine rispetto a 0 è: 0312 }
  case PlayerId of
    0: Result := 3;
    3: Result := 1;
    1: Result := 2;
    2: Result := 0;
    else Result := 0;
  end;

  { Controlla che questo id esista, altrmenti richiama in ricorsione la funzione }
  if not Players.IdExists(Result) then Result := GetPlayerIdOnTheLeftOf(Result);
end;

{ Funzione che ritorna l'id del giocatore subito alla destra di un altro giocatore }
function TGameServer.GetPlayerIdOnTheRightOf(PlayerId: integer): integer;
begin
  { L'ordine rispetto a 0 è: 0312 }
  case PlayerId of
    0: Result := 2;
    2: Result := 1;
    1: Result := 3;
    3: Result := 0;
    else Result := 0;
  end;

  { Controlla che questo id esista, altrmenti richiama in ricorsione la funzione }
  if not Players.IdExists(Result) then Result := GetPlayerIdOnTheRightOf(Result);
end;

{ Procedura per distribuire le carte ai giocatori }
procedure TGameServer.DistroCardsToPlayers;
var
  C, CardsCount: integer;
  Client: TClient;
  LastPlayerId: integer;
begin
  { Se il mazzo non è stato creato scatena un eccezzione }
  if not Assigned(Deck) then raise Exception.Create('Si è tentato di distribuire le carte ai giocatori mentre il mazzo non era stato ancora inizializzato. Contattare il produttore.');

  { Se le mani dei giocatori hanno delle carte, scatena un eccezzione,
  le carte vanno distribuite solamente quando inizia un nuovo giro }
  for C := 0 to Players.Count-1 do
    if not Players.GetClient(C).Hand.IsEmpty then raise Exception.Create('Si è tentato di distribuire le carte quando uno dei giocatori aveva già delle carte in mano. Contattare il produttore.');

  { Setta l'id del mazziere... }
  LastPlayerId := DeckerId;

  { Ok è andato tutto a buon fine, possiamo distribuire le carte in senso antiorario partendo dal
  giocatore alla sinistra del mazziere }
  for CardsCount := 1 to 5 do
  begin
    for C := 0 to Players.Count-1 do
    begin
      Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastPlayerId));
      LastPlayerId := Client.Id;

      { Distribuisci le carte solo a chi sta giocando.. }
      if Client.IsPlaying then Client.Hand.PushCard(Deck.PopCard);
    end;
  end;

  { Invia la proiezione delle mani ai clients }
  SendPlayersHandProjection(true);

  { Ordina ai clients di non selezionare le carte... }
  ClientsCanSelectCards(false);
end;

{ Procedura per inviare ai clients la proiezione delle mani
se CoveredMode è impostato a true, la vera mano del giocatore viene inviata
solamente al giocatore locale, la proiezione degli altri giocatori non viene inviata
(vengono inviati 5 assi di cuori per ingannare la grafica) in questo modo l'unico modo
per scoprire le carte avversarie è quello di implementare uno sniffer (mentre se ciò non avvenisse,
bastarebbe un piccolo hack al codice del client) }
procedure TGameServer.SendPlayersHandProjection(CoveredMode: boolean);
var
  C, D: integer;
  Client: TClient;
  ClientToSend: TClient;
  CoverPlayerHand: boolean;
begin
  { Itera per ogni giocatore per due volte (invia a tutti i giocatori la mano di tutti i giocatori) }
  for C := 0 to Players.Count-1 do
  begin
    { Salva l'id e l'istanza del giocatore corrispondende ad index C }
    Client := Players.GetClient(C);

    for D := 0 to Players.Count-1 do
    begin
      ClientToSend := Players.GetClient(D);

      { Se è abilitata la CoverMode e se si tratta del giocatore che invia a se stesso le carte (gli id devono corrispondere)
      allora non coprire le carte, altrimenti coprile perchè si tratta di un altro giocatore }
      if CoveredMode then begin
        if ClientToSend.Id = Client.Id then CoverPlayerHand := false
        else CoverPlayerHand := true;
      { Se la modalità CoverMode è false, allora automaticamente invia in chiaro le carte a tutti i giocatori }
      end else CoverPlayerHand := false;

      //Abilita il commento qua sotto per vedere le carte..
      //CoverPlayerHand := false;


      SendPlayerHandProjection(CoverPlayerHand, Client, ClientToSend,true);
    end;
  end;

  { Informiamo i clients che abbiamo finito la proiezione
  (se CoveredMode è impostato a false, allora non avvvisare i clients) }
  if CoveredMode then SendToAll('/PLAYERHANDPROJECTIONFINISHED');
end;

{ Procedura che invia a un giocatore la proiezione della mano di un altro }
procedure TGameServer.SendPlayerHandProjection(CoveredMode: boolean; Client: TClient; ClientToSend: TClient; FirstHand: boolean);
var
  C: integer;
  DataToSend: string;
begin
  { Inizializza la stringa da inviare al client di destinazione }
  DataToSend := '/PLAYERHANDPROJECTION' + SEPARATOR;

  { Se FirstHand è true allora il client dovrà creare una nuova mano
  altrimenti userà quella esistente }
  if FirstHand then DataToSend := DataToSend + 'FirstHand' + SEPARATOR
  else DataToSend := DataToSend + '!FirstHand' + SEPARATOR;

  DataToSend := DataToSend + IntToStr(Client.Id);

  { Invia la proiezione solamente se il giocatore sta giocando... }
  if Client.IsPlaying then begin
    { Se il numero di carte presenti nella mano del giocatore è inferiore a 5,
    scatena un eccezzione }
    if Client.Hand.Count < 5 then raise Exception.Create('Si è tentato di inviare la proiezione delle carte di un giocatore quando il numero di carte nella sua mano era inferiore a 5. Contattare il produttore.');

    { Tutto a posto, possiamo inviare le carte al client }
    for C := 0 to Client.Hand.Count-1 do
    begin
      { Se CoveredMode è impostato a true allora non inviare la vera carta del giocatore, ma un asso di cuori }
      if CoveredMode then
        DataToSend := DataToSend + SEPARATOR + IntToStr(Integer(Ace)) + SEPARATOR + IntToStr(Integer(Hearts))
      else
        DataToSend := DataToSend + SEPARATOR + IntToStr(Integer(Client.Hand.GetCard(C).Face)) + SEPARATOR + IntToStr(Integer(Client.Hand.GetCard(C).Suit));
    end;
  end

  { Altrimenti avvisa che il giocatore sta solamente osservando e non ha carte }
  else DataToSend := DataToSend + SEPARATOR + 'Observing';

  SendTo(ClientToSend.AThread,DataToSend);
end;

{ Procedura che si occupa della selezione delle carte e della notifica a tutti i clients }
procedure TGameServer.SelectCard(AThread: TIdPeerThread; CardIndex: integer);
var
  Client: TClient;
begin
  Client := Players.GetClient(AThread);
  Client.Hand.SelectCardWithoutGraphicsOp(CardIndex);
  SendToAllExcept('/THISPLAYERSELECTEDTHISCARD'+SEPARATOR+IntToStr(Client.Id)+SEPARATOR+IntToStr(CardIndex),AThread);
end;

{ Procedura che si occupa della deselezione delle carte e della notifica a tutti i clients }
procedure TGameServer.DeselectCard(AThread: TIdPeerThread; CardIndex: integer);
var
  Client: TClient;
begin
  Client := Players.GetClient(AThread);
  Client.Hand.DeselectCardWithoutGraphicsOp(CardIndex);
  SendToAllExcept('/THISPLAYERDESELECTEDTHISCARD'+SEPARATOR+IntToStr(Client.Id)+SEPARATOR+IntToStr(CardIndex),AThread);
end;

{ Procedura per cambiare una carta e notificare il cambiamento ai clients... }
procedure TGameServer.ChangeCards(AThread: TIdPeerThread);
var
  Client: TClient;
begin
  { Cambia le carte sul server }
  Client := Players.GetClient(AThread);
  Client.Hand.ChangeCards(Deck);

  { Notifica a tutti i giocatori di deselezionare le carte }
  SendToAll('/DESELECTALLCARDSOFPLAYER'+SEPARATOR+IntToStr(Client.Id));

  { Invia le nuove carte solamente al giocatore }
  SendPlayerHandProjection(false,Client,Client,false);
end;

{ Procedura che si occupa della disconnessione di un giocatore... }
procedure TGameServer.DisconnectPlayer(AThread: TIdPeerThread);
var
  ClientId: integer;
  Nickname: string;
  Client: TClient;
begin
  Client := Players.GetClient(AThread);
  Nickname := Client.Nickname;

  { Prende l'id del giocatore che si è disconnesso.. }
  ClientId := Client.Id;

  if ClientId = 0 then exit;

  { Ok cancelliamolo dalla lista }
  Players.DeleteClient(AThread);

  { Disconnette il thread }
  AThread.Terminate;

  { Informiamo i clients connessi che devono riaggiornare le
  proiezioni dei giocatori.. }
  //SendToAll('/PLAYERPROJECTIONREFRESHISNEEDED');

  { Informiamo i clients che un giocatore se n'è andato... }
  SendToAll('/PLAYERDISCONNECTED'+SEPARATOR+IntToStr(ClientId));

  { Setta lo status }
  SendStatus(66,Nickname);

  { Richiama la procedura per visualizzare il pulsante di avvio qualora necessario }
  DisplayStartGameButtonIfNeeded(GetHost.AThread,false);

  { Ridistribuisce il denaro }
  TranslateMoneyFromTableToAllPlayingPlayers;

  { Cominciamo dei nuovi turni di gioco... }
  while GameStarted do BeginTurn;
end;


{ Versione overlodata che accetta l'id di un giocatore }
procedure TGameServer.DisconnectPlayer(PlayerId: integer);
begin
  DisconnectPlayer(Players.GetClientWithId(PlayerId).AThread);
end;

{ Procedura che ordina al client di aprire un determinato pannello }
procedure TGameServer.EnablePanelTo(PanelMode: TPanelMode; AThread: TIdPeerThread);
begin
  SendTo(AThread,'/ENABLEPANEL'+SEPARATOR+IntToStr(Integer(PanelMode)));
end;

{ Versione overloadata che accetta come parametro l'id del giocatore }
procedure TGameServer.EnablePanelTo(PanelMode: TPanelMode; PlayerId: integer);
begin
  EnablePanelTo(PanelMode,Players.GetClientWithId(PlayerId).AThread);
end;

{ Procedura che ordina al client di disabilitare un determinato pannello }
procedure TGameServer.DisablePanelTo(AThread: TIdPeerThread; Hide: boolean);
begin
  SendTo(AThread,'/DISABLEPANEL'+SEPARATOR+BoolToStr(Hide));
end;

{ Versione overloadata che accetta l'id del giocatore come parametro }
procedure TGameServer.DisablePanelTo(PlayerId: integer; Hide: boolean);
begin
  DisablePanelTo(Players.GetClientWithId(PlayerId).AThread, Hide);
end;

{ Funzione che ritorna il giocatore che è host della partita }
function TGameServer.GetHost: TClient;
begin
  { Se la lista è vuota, allora scatena un eccezzione }
  if Players.Count = 0 then raise Exception.Create('Si è cercato di prendere il riferimento all''host nella funzione TGameServer.GetHost, ma la lista di giocatori è vuota. Contattare il produttore.')

  { Altrimenti ritorna il primo elemento della lista che corrisponde SEMPRE all'host }
  else Result := Players.GetClientWithId(0);
end;

procedure TGameServer.DisplayStartGameButtonIfNeeded(AThread: TIdPeerThread; CheckForHost: boolean);
begin

  { Se si tratta dell'host (id sempre 0), allora abilitagli il pannello per avviare il gioco }
  if CheckForHost then
    if Players.GetClient(AThread).Id = 0 then EnablePanelTo(pmStartGame,AThread);

  { E controlla se ci sono più di 1 giocatore in modo da disabilitare/abilitare il pannello }
  { Ma se non c'è nessun giocatore, oppure il gioco è gia stato avviato, non fare niente }
  if (Players.Count > 0) and not GameStarted then begin
    if Players.Count < 2 then begin
      DisablePanelTo(GetHost.AThread,false);
      SendStatus(67);
    end
    else begin
      EnablePanelTo(pmStartGame,GetHost.AThread);
      SendStatus(68);
    end;

    { Se si tratta dell'host, andiamo alla procedura che deve ricevere la risposta... }
    if Players.GetClient(AThread).Id = 0 then AskForStartGame;
  end;
end;

{ Procedura per inviare la proiezione del denaro di un giocatore ad un altro }
procedure TGameServer.SendPlayerMoneyProjection(Client: TClient; ClientToSend: TClient);
begin
  SendTo(ClientToSend.AThread,'/MONEYPROJECTION'+SEPARATOR+IntToStr(Client.Id)+SEPARATOR+IntToStr(Client.Money));
end;

{ Procedura per refreshare la proiezione del denaro a tutti i giocatori }
procedure TGameServer.SendMoneyProjection;
var
  C, D: integer;
begin
  for C := 0 to Players.Count-1 do
  begin
    { Invia le proiezioni del denaro dei giocatori }
    for D := 0 to Players.Count-1 do
      SendPlayerMoneyProjection(Players.GetClient(C),Players.GetClient(D));

    { Invia la proiezione del piatto }
    SendTo(Players.GetClient(C).AThread,'/MONEYTABLEPROJECTION'+SEPARATOR+IntToStr(MoneyTable));
  end;
end;

{ Funzione che interroga il client per ricevere il valore minimo
per giocare una mano }
function TGameServer.AskForOpenValue: integer;
var
  Client: TClient;
begin
  { Massimo = Cip
  Minimo = 1 }
  SetBetRange(Cip,1);

  { Mostra lo status }
  Client := Players.GetClientWithId(DeckerId);
  SendStatus(69,Client.Nickname);

  EnablePanelTo(pmOpenBet,DeckerId);
  Result := StrToInt(GetToken(WaitForACommandReply(DeckerId,'/OPENBETVALUE'),1));
  DisablePanelTo(DeckerId,true);

  { Controlliamo che il valore non esca fuori da quelli pre-stabiliti
  altrimenti si tratta di qualcuno che sta facendo il furbo con qualche hackz ;) }
  if (Result > BetMaxValue) or (Result < BetMinValue) then DisconnectPlayer(DeckerId);

  { Mostra lo status }
  SendStatus(70,Client.Nickname + ',' + IntToStr(Result));
end;


{ Procedura che imposta le variabili e richiama la procedura per rilanciare, passare, vedere, ecc.
Ritorna true nel caso sia possibile stabilire il vincitore
false nel caso che la mano sia da rifare }
function TGameServer.InitProcAskForCipOrRelaunchOrSeeOrWordsOrPass(PlayerIdStarter: integer): boolean;
begin
  { Se c'è un solo giocatore esci dalla procedura }
  if Players.OnlyOnePlayerIsPlaying then begin
    Result := true;
    exit;
  end;

  { Resetta il denaro che i giocatori devono puntare... }
  Players.ResetMoneyToBet;
  LastRelaunch := 0;

  { Resetta lo stato delle volontà }
  Players.ResetWannaSee;
  Players.ResetCalledWords;
  Players.ResetCalledCip;

  { Resetta la variabile di controllo }
  SomeoneRelaunched := false;

  { Se il giocatore è rimasto solo, salta questa fase }
  if Players.OnlyOnePlayerIsPlaying then begin
    Result := true;
    exit;
  end;

  { Richiama la procedura per rilanciare, passare, vedere, ecc. }
  Result := AskForCipOrRelaunchOrSeeOrWordsOrPass(PlayerIdStarter);
end;


{ Funzione che si occupa della fase di gioco in cui passare, rilanciare, vedere, ecc.
Ritorna true nel caso sia possibile stabilire il vincitore
false nel caso che la mano sia da rifare }
function TGameServer.AskForCipOrRelaunchOrSeeOrWordsOrPass(PlayerIdStarter: integer): boolean;
var
  C: integer;
  Client: TClient;
  LastClientId: integer;
  PlayerAction: string;
  SeePanelEnabled: boolean;
begin
  { Se tutti hanno chiamato parole }
  if Players.AllCalledWords then begin
    Result := false;
    exit;
  end;

  { Imposta l'ultimo Id sul giocatore che ha aperto il gioco }
  LastClientId := PlayerIdStarter;

  for C := 0 to Players.Count-1 do
  begin
    { Prende il giocatore alla sinistra dell'ultimo }
    Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastClientId));
    LastClientId := Client.Id;

    { Esegui queste operazioni solamente se il giocatore sta giocando, altrimenti saltale }
    if Client.IsPlaying then begin

      { Se il denaro del giocatore è minore dell'ultimo rilancio
      o il suo denaro è zero, non permettergli di rilanciare }
      if (Client.Money <= (LastRelaunch+1)) or (Client.Money < 1) then EnableRelaunchButton(Client,false)

      { Se tutti gli altri giocatori vogliono vedere e hanno pareggiato
      le puntate, disabilita il rilancio }
      else if (Players.AllWannSeeExcept(Client)) and (Players.AllBetTheirSum) then EnableRelaunchButton(Client,false)
      else EnableRelaunchButton(Client,true);


      { Se qualcuno ha rilanciato, il giocatore non puo' chiamare cip
      così come se il giocatore ha gia chiamato parole, non puo' più chiamarlo }

      if (Players.SomeoneWannaSee or SomeoneRelaunched) then EnablePanelTo(pmRelaunchOrSeeOrPass,Client.AThread)
      //else if (Players.SomeoneWannaSee or SomeoneRelaunched) then EnablePanelTo(pmRelaunchOrSeeOrWordsOrPass, Client.AThread)
      else if Client.CalledWords then EnablePanelTo(pmCipOrRelaunchOrSeeOrPass,Client.AThread)
      else EnablePanelTo(pmCipOrRelaunchOrSeeOrWordsOrPass,Client.AThread);

      PlayerAction := GetToken(WaitForACommandReply(Client.AThread,'/WHATIDO'),1);

      { Il giocatore ha chiamato parole? Sposta il gioco al giocatore alla sua sinistra }
      if PlayerAction = 'IWORDS' then begin
        Client.CalledWords := true;
        DisablePanelTo(Client.AThread,true);

        { Mostra lo status }
        SendStatus(71,Client.Nickname);

        Result := AskForCipOrRelaunchOrSeeOrWordsOrPass(Client.Id);
        exit;
      end

      { Il giocatore ha chiamato Vedo? Punta quanto deve puntare e imposta le variabili }
      else if PlayerAction = 'ISEE' then begin
        { Se non c'è neanche un soldo puntato, chiedi al giocatore
        la puntata per vedere... }
        SeePanelEnabled := false;

        if LastRelaunch = 0 then begin
          { Se il suo denaro è sottozero, vedi con 1$ }
          if Client.Money > 0 then SetBetRange(Client.Money,1)
          else SetBetRange(1,1);

          { Operazioni per la puntata per vedere }
          EnablePanelTo(pmSeeBet,Client.AThread);
          LastRelaunch := StrToInt(GetToken(WaitForACommandReply(Client.AThread,'/SEEBETVALUE'),1));
          Players.AddMoneyToBet(LastRelaunch);
          DisablePanelTo(Client.AThread,true);
          SeePanelEnabled := true;
        end;

        TranslateMoneyFromPlayerToTable(Client.AThread,Client.MoneyToBet);
        Client.MoneyToBet := 0;
        Client.WannaSee := true;

        { Mostra lo status }
        if SeePanelEnabled then SendStatus(72,Client.Nickname + ',' +IntToStr(LastRelaunch))
        else SendStatus(73,Client.Nickname);
      end

      { Il giocatore ha chiamato Cip? Vuole puntare solamente il minimo necessario }
      else if PlayerAction = 'ICIP' then begin

        { Inseriamo un piccolo controllo anti-hack contro i furbastri :) }
        if SomeoneRelaunched then DisconnectPlayer(Client.AThread);

        { Imposta le variabili e punta il denaro }
        LastRelaunch := Cip;
        Players.AddMoneyToBetExcept(Cip,Client); 
        TranslateMoneyFromPlayerToTable(Client.AThread,LastRelaunch);
        Client.CalledCip := true;

        { Mostra lo status }
        SendStatus(74,Client.Nickname);
      end

      { il giocatore ha rilanciato? }
      else if PlayerAction = 'IRELAUNCH' then begin

        { Abilitagli il pannello per rilanciare }
        SetBetRange(Client.Money,LastRelaunch+1);
        EnablePanelTo(pmRelaunchBet,Client.AThread);

        { Aspetta la risposta e chiude il pannello }
        LastRelaunch := StrToInt(GetToken(WaitForACommandReply(Client.AThread,'/RELAUNCHBETVALUE'),1));
        DisablePanelTo(Client.AThread,true);

        { Mostra lo status }
        SendStatus(75,Client.Nickname + ',' + IntToStr(LastRelaunch));

        { Aggiunge a tutti i giocatori la somma di denaro da giocare }
        Players.AddMoneyToBet(LastRelaunch);

        { Punta il denaro e passa la parola al giocatore successivo }
        TranslateMoneyFromPlayerToTable(Client.AThread,Client.MoneyToBet);
        Client.MoneyToBet := 0;

        { Impostiamo la variabile di controllo }
        SomeoneRelaunched := true;

        { Richiama in ricorsione }
        Result := AskForCipOrRelaunchOrSeeOrWordsOrPass(Client.Id);

        { Usciamo dalla procedura per non entrare in loop }
        exit;
      end
      else begin
        Client.IsPlaying := false;

        { Toglie il giocatore dal turno }
        TogglePlayerFromTurn(Client);

        { Mostra lo status }
        SendStatus(76,Client.Nickname);
      end;

      { Disabilitagli i pulsanti... }
      DisablePanelTo(Client.AThread,true);


      { Parte finale della funzione
      in questa parte vengono controllate le fasi del gioco
      per vedere se è necessario uscire dalla procedura perchè il game è sul punto di finire
      e bisogna solamente controllare i punti e trovare il vincitore }

      { Se tutti vogliono vedere... }
      if Players.AllWannaSee or Players.AllCalledCip then begin
        Result := true;
        exit;
      end

      { Se è rimasto un solo giocatore... }
      else if Players.OnlyOnePlayerIsPlaying then begin
        Result := true;
        exit;
      end;
    end;
  end;
  
  Result := true; //Questo non dovrebbe mai accadere
end;



{ Funzione che imposta le variabili e richiama la procedura per chiedere se si vuole giocare
passare o rilanciare }
procedure TGameServer.InitProcAskForPlayOrPassOrRelaunch(PlayerIdStarter: integer);
var
  C: integer;
  Client: TClient;
begin
  { Imposta la somma di denaro da puntare ad ogni giocatore tranne a chi ha aperto
  che ha gia puntato prima }
  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if Client.Id <> PlayerIdStarter then Client.MoneyToBet := OpenValue;
  end;

  LastRelaunch := 0;

  { Resetta la variabile di controllo }
  SomeoneRelaunched := false;

  { Richiama la procedura per Giocare, Passare o Rilanciare }
  AskForPlayOrPassOrRelaunch(PlayerIdStarter);
end;


{ Procedura che si occupa della fase in cui Giocare, Passare o Rilanciare }
procedure TGameServer.AskForPlayOrPassOrRelaunch(PlayerIdStarter: integer);
var
  C: integer;
  Client: TClient;
  LastClientId: integer;
  PlayerAction: string;
begin
  { Imposta l'ultimo Id sul giocatore che ha aperto il gioco }
  LastClientId := PlayerIdStarter;

  for C := 0 to Players.Count-1 do
  begin
    { Prende il giocatore alla sinistra dell'ultimo }
    Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastClientId));
    LastClientId := Client.Id;

    { Esegui queste operazioni solamente se il giocatore sta giocando, altrimenti saltale }
    if Client.IsPlaying then begin

      { Se il denaro del giocatore è minore dell'ultimo rilancio, non permettergli di rilanciare }
      if (Client.Money <= (LastRelaunch+1)) or (Client.Money < 1)  then EnableRelaunchButton(Client,false)

      { Se tutti hanno puntato la loro somma dopo un rilancio, non permettere il rilancio }
      else if Players.AllBetTheirSum and SomeoneRelaunched then EnableRelaunchButton(Client,false)
      else EnableRelaunchButton(Client,true);

      EnablePanelTo(pmPlayPassRelaunch,Client.AThread);

      PlayerAction := GetToken(WaitForACommandReply(Client.AThread,'/WHATIDO'),1);

      { Il giocatore vuole giocare la partita? }
      if PlayerAction = 'IPLAY' then begin
        Client.IsPlaying := true;

        { Trasferisce il denaro... }
        TranslateMoneyFromPlayerToTable(Client.AThread,Client.MoneyToBet);
        Client.MoneyToBet := 0;

        { Mostra lo status }
        SendStatus(77,Client.Nickname);
      end

      { il giocatore ha rilanciato? }
      else if PlayerAction = 'IRELAUNCH' then begin

        { Abilitagli il pannello per rilanciare }
        SetBetRange(Client.Money,LastRelaunch+1);
        EnablePanelTo(pmRelaunchBet,Client.AThread);

        { Aspetta la risposta e chiude il pannello }
        LastRelaunch := StrToInt(GetToken(WaitForACommandReply(Client.AThread,'/RELAUNCHBETVALUE'),1));
        DisablePanelTo(Client.AThread,true);

        { Aggiunge a tutti i giocatori la somma di denaro da giocare }
        Players.AddMoneyToBet(LastRelaunch);

        { Mostra lo status }
        SendStatus(75,Client.Nickname + ',' + IntToStr(LastRelaunch));

        { Impostiamo una variabile di controllo }
        SomeoneRelaunched := true;

        { Punta il denaro e passa la parola al giocatore successivo }
        TranslateMoneyFromPlayerToTable(Client.AThread,Client.MoneyToBet);
        Client.MoneyToBet := 0;
        AskForPlayOrPassOrRelaunch(Client.Id);

        { Usciamo dalla procedura per non entrare in loop }
        exit;
      end
      else begin
        Client.IsPlaying := false;

        { Toglie il giocatore dal turno }
        TogglePlayerFromTurn(Client);

        { Mostra lo status }
        SendStatus(76,Client.Nickname);
      end;

      { Disabilitagli i pulsanti... }
      DisablePanelTo(Client.AThread,true);

      if Players.OnlyOnePlayerIsPlaying then exit;
    end;
  end;
end;

{ Procedura per settare i valori minimi e massimi che si possono puntare }
procedure TGameServer.SetBetRange(BetMaxValue, BetMinValue: integer);
begin
  { Se BetMaxValue è negativo, allora fallo diventare positivo }
  if BetMaxValue < 0 then BetMaxValue := -BetMaxValue;

  { Memorizza i valori nelle variabili globali del server }
  self.BetMaxValue := BetMaxValue;
  self.BetMinValue := BetMinValue;

  { E avvisa tutti i clients del cambiamento }
  SendToAll('/BETRANGE'+SEPARATOR+IntToStr(BetMaxValue)+SEPARATOR+IntToStr(BetMinValue));
end;

{ Funzione di fondamentale importanza: essa resta in ascolto per la ricezione dei comandi
da parte del client. Se il client invia il comando specificato come argomento, essa ritorna
il valore del comando del client alla procedura che l'ha invocata, altrimenti rimanda il comando
alla procedura per processare i comandi generali e si rimette in ascolto. In questo modo si possono
inviare più comandi diversi senza creare situazioni di confusione }
function TGameServer.WaitForACommandReply(AThread: TIdPeerThread; Command: string): string;
var
  StrData: string;
  ClientCommand: string;
begin
  { Prima di tutto, contrlla se il nostro peerthread esiste ancora.. altrimenti esci disconnettendolo }
  if (not AThread.Connection.Connected) or (AThread.Terminated) then DisconnectPlayer(AThread); 

  StrData := ReceiveFrom(AThread);
  ClientCommand := GetCommand(StrData);

  if ClientCommand = Command then Result := StrData
  else begin
    ProcessCommand(StrData,AThread);

    { Richiama in ricorsione se stessa }
    Result := WaitForACommandReply(AThread,Command);
  end;
end;

{ Versione overloadata che accetta come argomento l'id del giocatore }
function TGameServer.WaitForACommandReply(PlayerId: integer; Command: string): string;
begin
  Result := WaitForACommandReply(Players.GetClientWithId(PlayerId).AThread,Command);
end;

{ Questa procedura freeza in attesa che tutti i giocatori abbiano cambiato le carte... }
procedure TGameServer.WaitForCardsChangedByPlayers;
var
  C: integer;
  Client: TClient;
  AllPlayersHasChangedTheCards: boolean;
begin
  { TODO: inutilizzata }
  { Per non sovvracaricare la cpu }
  Sleep(200);

  { Parte dal presupposto che tutti hanno cambiato le carte... }
  AllPlayersHasChangedTheCards := true;

  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);

    { Se c'è qualcuno che sta giocando e non ha ancora cambiato le carte, modifica la variabile
    di controllo }
    if Client.IsPlaying and (not Client.HasChangedCards) then AllPlayersHasChangedTheCards := false;
  end;

  { Se manca ancora qualcuno che deve cambiare le carte, riparti in ricorsione }
  if not AllPlayersHasChangedTheCards then WaitForCardsChangedByPlayers;
end;

{ Procedura che abilita il pannello di cambio delle carte e cambia le carte
ai giocatori in senso antiorario }
procedure TGameServer.AskForChangeCards;
var
  C: integer;
  Client: TClient;
  LastClientId: integer;
begin
  { Se c'è un solo giocatore esci dalla procedura }
  if Players.OnlyOnePlayerIsPlaying then exit;

  { Abilita i clients per selezionare le carte... }
  ClientsCanSelectCards(true);

  { Imposta l'ultimo Id sul mazziere... }
  LastClientId := DeckerId;

  for C := 0 to Players.Count-1 do
  begin
    { Prende il giocatore alla sinistra dell'ultimo }
    Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastClientId));
    LastClientId := Client.Id;

    { Esegui queste operazioni solamente se il giocatore sta giocando, altrimenti saltale }
    if Client.IsPlaying then begin

      EnablePanelTo(pmChangeCards,Client.AThread);

      { Il gicatore ci informa che ha scelto quali carte cambiare... }
      if WaitForACommandReply(Client.AThread,'/ICHANGETHECARDS') = '/ICHANGETHECARDS' then ChangeCards(Client.AThread);

      { Disabilitagli i pulsanti... }
      DisablePanelTo(Client.AThread,true);

      { Disabilitagli la possibilità di cambiare le carte... }
      ClientCanSelectCards(Client.AThread,false);

      { Mostra lo status }
      if Client.Hand.CardsChanged = 0 then SendStatus(78,Client.Nickname)
      else if Client.Hand.CardsChanged = 1 then SendStatus(79,Client.Nickname)
      else SendStatus(89,Client.Nickname + ',' + IntToStr(Client.Hand.CardsChanged));
    end;
  end;
end;

{ Procedura che abilita ai giocatori il pannello per passare o aprire la mano
e svolge le operazioni ad esso connesse }
function TGameServer.AskForOpenOrPass: integer;
var
  C: integer;
  Client: TClient;
  LastClientId: integer;
begin
  { Imposta l'ultimo Id sul mazziere... }
  LastClientId := DeckerId;

  for C := 0 to Players.Count-1 do
  begin
    { Prende il giocatore alla sinistra dell'ultimo }
    Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastClientId));
    LastClientId := Client.Id;

    { Se il giocatore non sta giocando, skippa... }
    if not Client.IsPlaying then continue;

    { Se il giocatore puo' aprire, abilita il pannello per aprire e passare }
    if Client.Hand.CanOpen(Deck.StartFace, MinPairFaceToOpen) then EnablePanelTo(pmOpenOrPass,Client.AThread)

    { Altrimenti solo quello per passare }
    else EnablePanelTo(pmPass,Client.AThread);

    { Il giocatore ha deciso di aprire }
    if GetToken(WaitForACommandReply(Client.AThread,'/WHATIDO'),1) = 'IOPEN' then begin
      Result := Client.Id;

      { Bene, allora deve anche inserire una puntata a piacere... }
      SetBetRange(Client.Money,1);
      EnablePanelTo(pmFirstBet,Client.AThread);
      OpenValue := StrToInt(GetToken(WaitForACommandReply(Client.AThread,'/FIRSTBETVALUE'),1));

      { Controlla che qualcuno non stia facendo il furbo... }
      if (OpenValue > BetMaxValue) or (OpenValue < BetMinValue) then DisconnectPlayer(Client.Id);

      { Tutto OK, procedi alla puntata }
      TranslateMoneyFromPlayerToTable(Client.AThread,OpenValue);

      { Mostra lo status }
      SendStatus(90,Client.Nickname + ',' + IntToStr(OpenValue));

      DisablePanelTo(Client.AThread,true);
      exit;
    end

    { Altrimenti vuol dire che ha passato, semplicemente disabilitiamogli i pulsanti }
    else begin
      DisablePanelTo(Client.AThread,true);

      { Mostra lo status }
      SendStatus(176,Client.Nickname);
    end;
  end;

  { attenzione, nessuno ha aperto, devi rifare la mano! }
  Result := -1;
end;

{ Procedura che imposta tutti i giocatori allo stato di gioco
solamente se il loro denaro è maggiore di 0 }
procedure TGameServer.SetAllPlayersToPlay;
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if Client.Money > 0 then Client.IsPlaying := true
    else Client.IsPlaying := false;
  end;
end;

{ Procedura che si occupa delle fasi di un turno }
procedure TGameServer.BeginTurn;
var
  InitialGameBet: integer;
  OpenerId: integer;
  WinnerId: integer;
  C: integer;
begin
  { Imposta le variabili per iniziare allo stato iniziale }
  SetAllVarsToBeginATurn;

  { Inizialmente disattiva a tutti i giocatori i pulsanti.. }
  for C := 0 to Players.Count-1 do DisablePanelTo(Players.GetClient(C).AThread,true);

  { Avvisa i giocatori che si è avviato un nuovo turno }
  SendToAll('/BEGINNINGNEWTURN'+SEPARATOR+IntToStr(GetPlayingPlayersCount));

  { Se il giocatore rimasto è uno solo... avvisiamo che la partita è finita... }
  if GetPlayingPlayersCount < 2 then begin
    SendToAll('/GAMEOVER');
    GameStarted := false;
    DisplayStartGameButtonIfNeeded(GetHost.AThread,true);
  end

  { Altrimenti avvia il turno... }
  else begin
    { Imposta il nuovo mazziere }
    GetNextDeckerId;

    { Chiede al mazziere il valore minimo per giocare... }
    InitialGameBet := AskForOpenValue;

    { Tutti i giocatori DEVONO puntare la somma versata dal mazziere altrimenti devono
    essere cacciati dal gioco alla fine della partita se non tornano in positivo }
    TranslateMoneyFromAllPlayingPlayersToTable(InitialGameBet);

    { Crea il mazzo (le funzioni di riempimento e rimescolamento sono nel costruttore...) }
    Deck := TDeck.Create(AOwner,TForm(AOwner),GetPlayingPlayersCount);

    { Distribuisce le carte ai giocatori }
    DistroCardsToPlayers;

    { Controlla che un giocatore possa aprire la mano oppure obbligalo a passare }
    OpenerId := AskForOpenOrPass;

    { Se OpenerId = -1 significa che tutti hanno passato e bisogna rifare la mano,
    ridistribuire i soldi ai giocatori e cambiare i criteri di apertura }
    if OpenerId = -1 then begin
      TranslateMoneyFromTableToAllPlayingPlayers;

      case MinPairFaceToOpen of
        Jack: MinPairFaceToOpen := Queen;
        Queen: MinPairFaceToOpen := King;
      end;

      exit;
    end;

    { Chiedi ai giocatori chi vuole giocare... }
    InitProcAskForPlayOrPassOrRelaunch(OpenerId);

    { Cambia le carte ai giocatori... }
    AskForChangeCards;

    { Inzia la procedura che si occupa dei vari rilanci, vedo, puntate, ecc.
    Se ritorna true, possiamo stabilire un vincitore
    Se false, bisogna rigiocare la mano senza annullare il piatto (tutti hanno chiamato parole) }
    if not InitProcAskForCipOrRelaunchOrSeeOrWordsOrPass(GetPlayerIdOnTheRightOf(OpenerId))then begin

      { Quando si chiama parole, la mano successiva bisogna aprirla con almeno 2 Kings }
      MinPairFaceToOpen := King;

      { Esci dalla procedura per re-iniziarla nuovamente in automatico }
      exit;
    end;

    { Chiede ai giocatori di rivelare le carte o no... }
    AskForRevealCards(GetPlayerIdOnTheRightOf(OpenerId));

    { Trova il vincitore }
    WinnerId := FindTheWinner;

    { Abilita i pulsanti al vincitore per sbloccare il gioco }
    AskForBeginNewTurn(WinnerId);

    { Se siamo arrivati qua in fondo, ripristina i criteri standard di apertura.. }
    MinPairFaceToOpen := Jack;
  end;
end;

{ Procedura per trasferire del denaro dal giocatore al piatto }
procedure TGameServer.TranslateMoneyFromPlayerToTable(AThread: TIdPeerThread; Money: integer);
var
  Client: TClient;
begin
  Client := Players.GetClient(AThread);
  Client.Money := Client.Money - Money;
  MoneyTable := MoneyTable + Money;

  { Aggiorna la proiezione dei soldi sui clients }
  SendMoneyProjection;
end;

{ Procedura overloadata per trasferire del denaro dal giocatore al piatto }
procedure TGameServer.TranslateMoneyFromPlayerToTable(PlayerId: integer; Money: integer);
begin
  TranslateMoneyFromPlayerToTable(Players.GetClientWithId(PlayerId).AThread,Money);
end;

{ Procedura per trasferire tutto il denaro dal piatto al giocatore }
procedure TGameServer.TranslateMoneyFromTableToPlayer(PlayerId: integer);
var
  Client: TClient;
begin
  Client := Players.GetClientWithId(PlayerId);
  Client.Money := Client.Money + MoneyTable;
  MoneyTable := 0;

  { Aggiorna la proiezione dei soldi sui clients }
  SendMoneyProjection;
end;

{ Procedura per far puntare del denaro da parte di tutti i giocatori che stanno giocando }
procedure TGameServer.TranslateMoneyFromAllPlayingPlayersToTable(Money: integer);
var
  C: integer;
begin
  for C := 0 to Players.Count-1 do
    if Players.GetClient(C).IsPlaying then TranslateMoneyFromPlayerToTable(Players.GetClient(C).AThread,Money);
end;

{ Procedura che comanda ai clients se possono selezionare le carte... }
procedure TGameServer.ClientsCanSelectCards(CanSelect: boolean);
var
  C: integer;
begin
  for C := 0 to Players.Count-1 do
    SendTo(Players.GetClient(C).AThread,'/UCANSELECT'+SEPARATOR+BoolToStr(CanSelect));
end;

{ Procedura che comanda ad un client se puo' selezionare le carte.. }
procedure TGameServer.ClientCanSelectCards(AThread: TIdPeerThread; CanSelect: boolean);
begin
  SendTo(AThread,'/UCANSELECT'+SEPARATOR+BoolToStr(CanSelect));
end;

{ Procedura per togliere un giocatore dalla mano }
procedure TGameServer.TogglePlayerFromTurn(Client: TClient);
begin
  Client.IsPlaying := false;
  if not Client.Hand.IsEmpty then SendToAll('/CLEARHANDOFPLAYER'+SEPARATOR+IntToStr(Client.Id));
end;

{ Funzione per trovare il vincitore della partita, trasferirgli il denaro e mostrare le carte
a tutti i giocatori }
function TGameServer.FindTheWinner: integer;
var
  WinnerId: integer;
  WinnerClient: TClient;
begin
  { Prende l'id del vincitore }
  WinnerId := GetWinnerId;

  { Assegna a WinnerClient il giocatore con id WinnerId }
  WinnerClient := Players.GetClientWithId(WinnerId);

  { Mostra lo status a seconda delle sue volontà }
  if WinnerClient.ShowedCards then begin
    SendToAll('/TRANSLATEPLAYERSCORE'+SEPARATOR+IntToStr(WinnerClient.Hand.Score.ToDataIndex));
    SendStatus(82,WinnerClient.Nickname + ',' + IntToStr(MoneyTable));
  end
  else SendStatus(81,WinnerClient.Nickname + ',' + IntToStr(MoneyTable));

  { Transla il denaro }
  TranslateMoneyFromTableToPlayer(WinnerId);

  { Ritorna alla main }
  Result := WinnerId;
end;

{ Procedura che ritorna l'id del vincitore }
function TGameServer.GetWinnerId: integer;
var
  C: integer;
  Client: TClient;
  WinnerClient: TClient;
begin
  { Solo per questioni di compilazione... }
  WinnerClient := Players.GetClient(0);

  { Trova il primo giocatore che sta giocando.. }
  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if Client.IsPlaying then begin
      WinnerClient := Client;
      break;
    end;
  end;

  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    { Esegui questa parte solo se il giocatore sta giocando e se non si tratta del vincitore stesso }
    if (Client.IsPlaying) and (Client.Id <> WinnerClient.Id) then begin
      if Client.Hand.IsEmpty then raise Exception.Create('Si è richiamata la funzione GetWinnerId ma la mano di un giocatore sembra vuota. Contattare il produttore.');

      { Se la mano del client selezionato è più alta di quella del vincitore, allora imponilo come vincitore }
      if Client.Hand.IsGreaterThan(WinnerClient.Hand) then WinnerClient := Client;
    end;
  end;

  { Ritorna alla main }
  Result := WinnerClient.Id;
end;

{ Procedura per inizializzare tutte le variabili per un nuovo turno }
procedure TGameServer.SetAllVarsToBeginATurn;
var
  C: integer;
  Client: TClient;
begin
  { Imposta tutti i giocatori allo stato di gioco
  (tranne quelli che hanno pochi soldi...) }
  SetAllPlayersToPlay;

  { Resetta l'ultimo rilancio }
  LastRelaunch := 0;

  { Toglie le carte ai giocatori se presenti }
  ToggleCardsFromPlayerIfHandNotEmpty;

  { Imposta la variabile relativa al cambio delle carte
  e la variabile relativa alla volontà di mostrare o meno le carte
  e toglie qualsiasi punteggio precedente dalla mano }
  for C := 0 to Players.Count-1 do begin
    Client := Players.GetClient(C);
    Client.HasChangedCards := false;
    Client.ShowedCards := false;
    Client.Hand.ResetScore;
    Client.MoneyToBet := 0;
    Client.WannaSee := false;
    Client.CalledWords := false;
    Client.CalledCip := false;
  end;
end;

{ Procedura per togliere le carte ai giocatori se la loro mano è piena }
procedure TGameServer.ToggleCardsFromPlayerIfHandNotEmpty;
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if not Client.Hand.IsEmpty then Client.Hand.Clear;
  end;
end;

{ Procedura per ridistribuire in maniera equa il denaro presente sul piatto }
procedure TGameServer.TranslateMoneyFromTableToAllPlayingPlayers;
var
  MoneyForEachPlayer: integer;
  C: integer;
  Client: TClient;
begin
  MoneyForEachPlayer := MoneyTable div GetPlayingPlayersCount;

  for C := 0 to Players.Count-1 do
  begin
    Client := Players.GetClient(C);
    if Client.IsPlaying then Client.Money := Client.Money + MoneyForEachPlayer;
  end;

  MoneyTable := 0;

  { Aggiorna la proiezione dei soldi sui clients }
  SendMoneyProjection;
end;

{ Procedura che chiede ai giocatori se rivelare o meno il punteggio della loro mano }
procedure TGameServer.AskForRevealCards(PlayerIdStarter: integer);
var
  C, D: integer;
  Client: TClient;
  LastClientId: integer;
  ClientToSend: TClient;
begin
  { Imposta l'ultimo Id ... }
  LastClientId := PlayerIdStarter;

  for C := 0 to Players.Count-1 do
  begin
    { Prende il giocatore alla sinistra dell'ultimo }
    Client := Players.GetClientWithId(GetPlayerIdOnTheLeftOf(LastClientId));
    LastClientId := Client.Id;

    { Esegui queste operazioni solamente se il giocatore sta giocando, altrimenti saltale }
    if Client.IsPlaying then begin

      { Se è rimasto un solo giocatore in gioco allora esci dalla procedura
      (senza rivelare le carte) }
      if Players.OnlyOnePlayerIsPlaying then exit;

      EnablePanelTo(pmShowCardsOrDontShowCards,Client.AThread);

      { Il gicatore ci informa che ha scelto quali carte cambiare... }
      if GetToken(WaitForACommandReply(Client.AThread,'/DOISHOWTHECARDS'),1) = 'ISHOWTHECARDS' then begin
        { Aggiorna il punteggio }
        Client.Hand.CheckAndSetScore;

        { Mostra lo status }
        SendToAll('/TRANSLATEPLAYERSCORE'+SEPARATOR+IntToStr(Client.Hand.Score.ToDataIndex));
        SendStatus(83,Client.Nickname);

        { Imposta la variabile relativa alla sua volontà }
        Client.ShowedCards := true;

        { Invia le sue vere carte a tutti i giocatori }
        for D := 0 to Players.Count-1 do
        begin
          ClientToSend := Players.GetClient(D);

          { Tranne che a se stesso ovviamente  }
          if ClientToSend.Id <> Client.Id then begin
            SendPlayerHandProjection(false, Client, ClientToSend,false);
          end;
        end;

        { Ordina ai clients di rivelare le carte del giocatore }
        SendToAll('/REVEALCARDSOFPLAYER'+SEPARATOR+IntToStr(Client.Id));
      end
      else begin
        Client.IsPlaying := false;
        TogglePlayerFromTurn(Client);

        { Mostra lo status }
        SendStatus(84,Client.Nickname);
      end;

      { Disabilitagli i pulsanti... }
      DisablePanelTo(Client.AThread,true);
    end;
  end;
end; 

{ Procedura che abilita i pulsanti per avviare una nuova mano }
procedure TGameServer.AskForBeginNewTurn(PlayerId: integer);
begin
  EnablePanelTo(pmBeginTurn,PlayerId);
  WaitForACommandReply(PlayerId,'/IWANTBEGINTHETURN');
  DisablePanelTo(PlayerId,true);
end;

{ Procedura per inviare lo status di gioco a tutti i giocatori }
procedure TGameServer.SendStatus(Text: string);
begin
  SendToAll('/SHOWSTATUS'+SEPARATOR+Text);
end;

{ Versione overloadata per garantire la compatibilità fra lingue... }
procedure TGameServer.SendStatus(DataIndex: integer; Arguments: string);
begin
  SendToAll('/TRANSLATEANDSHOWSTATUS'+SEPARATOR+IntToStr(DataIndex)+SEPARATOR+Arguments);
end;

{ Altra versione con un solo argomento intero... }
procedure TGameServer.SendStatus(DataIndex: integer);
begin
  SendStatus(DataIndex,'');
end;

{ Procedura per resettare allo stato iniziale il denaro dei giocatori }
procedure TGameServer.SetPlayersMoneyToInitialValue;
var
  C: integer;
begin
  for C := 0 to Players.Count-1 do
    Players.GetClient(C).Money := InitialMoney; 
end;

{ Procedura per abilitare/disabilitare il pulsante per rilanciare
a un giocatore }
procedure TGameServer.EnableRelaunchButton(Client: TClient; Enabled: boolean);
begin
  SendTo(Client.AThread,'/ENABLERELAUNCHBUTTON'+SEPARATOR+BoolToStr(Enabled));
end;

{ Procedura che rimane in ascolto fino a che l'host non decide di far
partire la partita }
procedure TGameServer.AskForStartGame;
var
  AThread: TIdPeerThread;
begin
  { L'host ha sempre Id 0 }
  AThread := Players.GetClientWithId(0).AThread;

  if WaitForACommandReply(AThread,'/IWANTSTARTTHEGAME') = '/IWANTSTARTTHEGAME' then begin
    GameStarted := true;
    DisablePanelTo(AThread,true);
    StartGame;
  end;
end;

{ Funzione che ritorna il numero di giocatori che stanno
giocando la partita... }
function TGameServer.GetPlayingPlayersCount: integer;
var
  C: integer;
  PlayingCount: integer;
begin
  PlayingCount := 0;
  for C := 0 to Players.Count-1 do
    if Players.GetClient(C).IsPlaying then inc(PlayingCount);

  Result := PlayingCount;
end;

{ Procedura per inviare a tutti i clients connessi
la proiezione dei giocatori }
procedure TGameServer.SendPlayersProjectionToAll;
var
  C: integer;
begin
  for C := 0 to Players.Count-1 do
    SendPlayersProjection(Players.GetClient(C).AThread);
end;


{ Distruttore }
destructor TGameServer.Destroy;
begin
  { Stiamo distruggendo tutto! Notifica i clients connessi }
  SendToAll('/HOSTISDISCONNECTING');

  ServerSocket.Active := false;
  inherited Destroy;
end;

end.
