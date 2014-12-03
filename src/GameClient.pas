unit GameClient;

interface

uses Windows, Forms, StdCtrls, Controls, IdTcpClient, Classes, ComCtrls, SysUtils, Messages,
  ServerInfo, Card, Hand, PlayerList, Money, Player, ButtonPanel, Constants, Languages;

type
  TGameClient = class(TThread)
  private
    StatusBar: TStatusBar; { Riferimento alla status bar del form principale }
    //FrmChat: TFrmChat; { Riferimento al form chat }

    MoneyTable: TMoney;
    Players: TPlayerList;
    ButtonPanel: TButtonPanel;

    { Evento scatenato all'arrivo di un messaggio di status }
    m_OnStatusMessageArrival: TNotifyEvent;

    m_Name: string;
    function GetName: string;

    { Gestori d'evento }
    procedure Hand_CardSelected(Sender: TObject);
    procedure Hand_CardDeselected(Sender: TObject);
    procedure Hand_CardChoicePressed(Sender: TObject);

    { Gestori d'evento per i bottoni di buttonpanel}
    procedure ButtonStartGame_Click(Sender: TObject);
    procedure ButtonChangeCards_Click(Sender: TObject);
    procedure ButtonPanel_BetValueAssigned(Sender: TObject);
    procedure ButtonPlay_Click(Sender: TObject);
    procedure ButtonPass_Click(Sender: TObject);
    procedure ButtonOpen_Click(Sender: TObject);
    procedure ButtonRelaunch_Click(Sender: TObject);
    procedure ButtonSee_Click(Sender: TObject);
    procedure ButtonWords_Click(Sender: TObject);
    procedure ButtonCip_Click(Sender: TObject);
    procedure ButtonBeginTurn_Click(Sender: TObject);
    procedure ButtonShowCards_Click(Sender: TObject);
    procedure ButtonDontShowCards_Click(Sender: TObject);

    { Funzioni e procedure varie }
    function IAmTheHost: boolean; { Obsoleta }
    procedure LoadButtonPanel;
    function GetLocalPlayer: TPlayer;
    procedure ShowStatus(Text: string);
    procedure ClearPlayersHand;
  protected
    { Variabili }
    AOwner: TComponent; { Riferimento al form principale }
    Password: string;
    Nickname: string;
    ClientSocket: TIdTcpClient;
    ServerInfo: TServerInfo;

    { Procedure per la socket }
    procedure SendText(Text: string); overload;
    procedure SendText(Text: string; Loop: integer); overload;
    function ReceiveText: string;

    { Gestore d'evento per la socket }
    procedure ClientSocket_Connected(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; Host, Password, Nickname: string; Port: integer; StatusBar: TStatusBar); overload;
    constructor Create(CreateSuspended: boolean); overload;
    destructor Destroy; override;
    procedure Execute; override;
    property Name: string read GetName;
    property OnStatusMessageArrival: TNotifyEvent read m_OnStatusMessageArrival write m_OnStatusMessageArrival;
  end;

implementation

{ Costruttore per il client }
constructor TGameClient.Create(AOwner: TComponent; Host, Password, Nickname: string; Port: integer; StatusBar: TStatusBar);
begin
  inherited Create(false);
  { Imposta le variabili }
  self.AOwner := AOwner;
  self.StatusBar := StatusBar;
  self.Password := Password;
  self.Nickname := Nickname;

  { Crea la socket }
  ClientSocket := TIdTcpClient.Create(AOwner);

  { Imposta i gestori d'evento per la socket }
  ClientSocket.OnConnected := ClientSocket_Connected;

  ClientSocket.Host := Host;
  ClientSocket.Port := Port;

  try
    { Assegna all'istanza ServerInfo un oggetto
    Nota bene: non invertire l'ordine delle chiamate in questo blocco                          
    potrebbe causare errori di memoria (oggetti non inizializzati) }
    ServerInfo := TServerInfo.Create(AOwner,Host,Port,TIMEOUT);                                          

    { Connette la socket al server }
    ClientSocket.Connect(TIMEOUT);
  except
    raise Exception.Create(GetStr(85,Host + ',' + IntToStr(Port)));
  end;

  { Carica il panello con i bottoni }
  LoadButtonPanel;

  { Crea il piatto }
  MoneyTable := TMoney.Create(AOwner,TForm(AOwner),mpCenter,msNormal);

  { Aggiunge il gestore d'evento per selezionare le carte con la tastiera... }
  ButtonPanel.OnCardChoicePressed := Hand_CardChoicePressed;
end;

{ Costruttore da usare solamente da una classe derivata }
constructor TGameClient.Create(CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
end;

{ Distruttore }
destructor TGameClient.Destroy;
begin
  { Disconnette la socket }
  if ClientSocket.Connected then begin
    { Avvisa il server che ce ne andiamo }
    SendText('/IDISCONNECT');

    { Disconnetti }
    ClientSocket.Disconnect;
  end;
  inherited Destroy;
end;

{ Procedura per cancellare le mano dei giocatori.. }
procedure TGameClient.ClearPlayersHand;
var
  C: integer;
  Player: TPlayer;
begin
  for C := 0 to Players.Count-1 do
  begin
    Player := Players.GetPlayer(C);
    if not Player.Hand.IsEmpty then Player.Hand.Clear;
  end;
end;

function TGameClient.GetName: string;
begin
  Result := m_Name;
end;

{ Punto di avvio del thread }
procedure TGameClient.Execute;
var
  StrData: string;
  Command: string;
  Player: TPlayer;
  Positions: array [0 .. 3] of THandPosition;
  ProjectionCount: integer;
  C: integer;
  Face: TFace;
  Suit: TSuit;
  Card: TCard;
  PlayerScore: string;
begin
  { Variabile che contiene l'ordinamento dei posti sul tavolo }
  Positions[0] := hpBottom;
  Positions[1] := hpTop;
  Positions[2] := hpRight;
  Positions[3] := hpLeft;

  { Resetta playerscore }
  PlayerScore := '';

  { Variabile che tiene conto del numero di proiezioni inviate (sempre 4)
  ma serve per stabilire la posizione del giocatore }
  ProjectionCount := 0;
try
  while ClientSocket.Connected do
  begin
    StrData := ReceiveText;
    Command := GetCommand(StrData);

    { Stiamo per ricevere dal server la proiezione dei giocatori }
    if Command = '/PLAYERSPROJECTION' then begin
      { Comando: '/PLAYERSPROJECTION_Id_Nickname_Money' }

      Player := TPlayer.Create(TForm(AOwner),AOwner,GetToken(StrData,2),StrToInt(GetToken(StrData,3)),Positions[ProjectionCount],StrToInt(GetToken(StrData,1)));
      Players.AddPlayer(Player);
      inc(ProjectionCount);

      { Se arriva a 4 allora è terminato un ciclo, quindi resetta }
      if ProjectionCount = 4 then ProjectionCount := 0;
    end

    { Una proiezione bianca (quindi in questo posto non c'è nessuno
    semplicemente incrementiamo il contatore di proiezioni }
    else if Command = '/BLANKPLACE' then begin
      inc(ProjectionCount);

      { Se arriva a 4 allora è terminato un ciclo, quindi resetta }
      if ProjectionCount = 4 then ProjectionCount := 0;
    end

    { Il server ci informa che la proiezione dei giocatori è finita }
    else if Command = '/PLAYERSPROJECTIONFINISHED' then begin
      { Refresha lo schermo }
      TForm(AOwner).Refresh;

      SetCurrentPlayingPlayers(Players.Count);
    end

    { Il server ci sta informando che dobbiamo refreshare la proiezione dei giocatori }
    else if Command = '/PLAYERPROJECTIONREFRESHISNEEDED' then begin
      { Azzera la lista dei giocatori }
      Players.Clear;

      { Chiede al server di re-inviare la proiezione dei giocatori
      Obsoleto }
      //SendText('/RESENDMEPLAYERSPROJECTION');
    end

    { Un giocatore se n'è andato...
    Command = '/PLAYERDISCONNECTED_PlayerId' }
    else if Command = '/PLAYERDISCONNECTED' then begin
      { "Cancelliamo" la proiezione del giocatore con l'id corrispondente a playerid }
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Hide;
      Players.DeletePlayerWithId(StrToInt(GetToken(StrData,1)));
    end

    { Il server ci sta inviando la proiezione di una carta di un giocatore
    comando: /PLAYERCARDPROJECTION_FirstHand_PlayerId_Face_Suit_Face1_Suit1_Face2_Suit2... }
    else if Command = '/PLAYERHANDPROJECTION' then begin
      Player := Players.GetPlayerWithId(StrToInt(GetToken(StrData,2)));

      { Se è la prima volta... }
      if GetToken(StrData,1) = 'FirstHand' then begin

        { Cancella la mano precedente.. }
        Player.Hand.Clear;

        { Distribuisci le carte solamente se il giocatore non sta osservando }
        if not (GetToken(StrData,3) = 'Observing') then begin
          for C := 1 to 5 do
          begin

            { Aggiunge la carta alla mano... }
            Player.Hand.PushCard(TFace(StrToInt(GetToken(StrData,C+C+1))),TSuit(StrToInt(GetToken(StrData,C+C+2))));

            { Imposta il gestore d'evento che viene scatenato quando viene selezionata
            e deselezionata una carta... (per inviare i dati alla socket) }
            Player.Hand.OnCardSelected := Hand_CardSelected;
            Player.Hand.OnCardDeselected := Hand_CardDeselected;
          end;
        end;
      end

      else begin
        { Altrimenti, se non è la prima volta che viene inviata la mano, si tratta di un cambio
        di carte oppure di una scoperta }

        { Se il giocatore ha la mano vuota, scatena un eccezzione }
        if Player.Hand.IsEmpty then raise Exception.Create('Si è cercato di cambiare le carte, ma il giocatore aveva la mano vuota. Contattare il produttore.');

        { Cambia le carte secondo le indicazioni del server
        (solo se necessario) }
        for C := 1 to 5 do
        begin
          Face := TFace(StrToInt(GetToken(StrData,C+C+1)));
          Suit := TSuit(StrToInt(GetToken(StrData,C+C+2)));
          Card := Player.Hand.GetCard(C-1);
          if not ((Card.Face = Face) and (Card.Suit = Suit)) then begin
            Card.ReplaceWith(Face,Suit);
            if Player.IsLocalPlayer then begin
              PlayResSound(WAVDISTROCARD);
              Sleep(LOCALANIMATIONTIME);
            end;

            { Refreshamo.. }
            TForm(AOwner).Refresh;
          end;
        end;
      end;
    end

    { Il server ci avvisa che ha finito di inviare la proiezione delle carte }
    else if Command = '/PLAYERHANDPROJECTIONFINISHED' then begin
      { Disegna la mano coperta se si tratta di un altro giocatore,
      se è il giocatore locale invece mostrala... }
      for C := 0 to Players.Count-1 do
      begin
        Player := Players.GetPlayer(C);

        { Esegui queste operazioni solamente se la mano del giocatore è piena }
        if not Player.Hand.IsEmpty then begin
          if Player.IsLocalPlayer then Player.Hand.PaintHand(false,true)
          else Player.Hand.PaintHand(true); 
        end;
      end;
    end



    { Il server ci sta avvisando che una carta è stata selezionata...
    Command = '/THISPLAYERSELECTEDTHISCARD_PlayerId_CardId' }
    else if Command = '/THISPLAYERSELECTEDTHISCARD' then begin
      { Passando false come secondo argomento evitiamo di scatenare eventi e quindi
      rischiando di entrare in loop }
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Hand.SelectCard(StrToInt(GetToken(StrData,2)),false);
    end


    { Il server ci sta avvisando che una carta è stata deselezionata...
    Command = '/THISPLAYERDESELECTEDTHISCARD_PlayerId_CardId' }
    else if Command = '/THISPLAYERDESELECTEDTHISCARD' then begin
      { Passando false come secondo argomento evitiamo di scatenare eventi e quindi
      rischiando di entrare in loop }
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Hand.DeselectCard(StrToInt(GetToken(StrData,2)),false);
    end

    { Il server ci avvisa che dobbiamo deselezionare tutte le carte di un giocatore }
    else if Command = '/DESELECTALLCARDSOFPLAYER' then begin
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Hand.DeselectAllCards;
    end

    { Il server ci avvisa che bisogna abilitare un determinato pannello
    Command = '/ENABLEPANEL_PanelEnumId' }
    else if Command = '/ENABLEPANEL' then begin
      ButtonPanel.Show;
      ButtonPanel.EnableButtons(true);
      ButtonPanel.Mode := TPanelMode(Integer(StrToInt(GetToken(StrData,1))));

      

      { Suona il "ding" per avvisare che è il nostro turno.. }
      //PlaySound('ding', 1); //1 = asincrono
    end

    { Il server ci comunica che dobbiamo disabilitare il pannello
    Command = '/DISABLEPANEL_HideValue' }
    else if Command = '/DISABLEPANEL' then begin
      ButtonPanel.EnableButtons(false);

      { Se l'argomento passato al comando è true, allora nascondilo }
      if StrToBool(GetToken(StrData,1)) then ButtonPanel.Hide;
    end

    { Il server ci informa che sta arrivando una proiezione del denaro di un giocatore
    Command = '/MONEYPROJECTION_PlayerId_Money' }
    else if Command = '/MONEYPROJECTION' then begin
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Money.Value := StrToInt(GetToken(StrData,2)); 
    end

    { Il server ci informa che sta arrivando la proiezione del piatto
    Command = '/MONEYTABLEPROJECTION_Money' }
    else if Command = '/MONEYTABLEPROJECTION' then begin
      MoneyTable.Value := StrToInt(GetToken(StrData,1));
    end

    { Il server ci informa che sono cambiati i limiti massimi e minimi di una puntata
    Command = '/BETRANGE_MaxValue_MinValue' }
    else if Command = '/BETRANGE' then begin
      ButtonPanel.BetMaxValue := StrToInt(GetToken(StrData,1));
      ButtonPanel.BetMinValue := StrToInt(GetToken(StrData,2));
    end

    { Il server ci informa che c'è un messaggio da visualizzare nella status bar }
    else if Command = '/SHOWSTATUS' then begin
      ShowStatus(GetToken(StrData,1));
    end

    { Il server ci informa che c'è un messaggio da tradurre e successivamente da visualizzare
    nella status bar... }
    else if Command = '/TRANSLATEANDSHOWSTATUS' then begin
      { Se la variabile PlayerScore è impostata, allora aggiungila alla fine e poi toglila }
      if PlayerScore <> '' then begin
        ShowStatus(GetStr(StrToInt(GetToken(StrData,1)),GetToken(StrData,2)) + ' ' + PlayerScore);
        PlayerScore := '';
      end
      else ShowStatus(GetStr(StrToInt(GetToken(StrData,1)),GetToken(StrData,2)));
    end

    { Il server ci informa di quale punteggio ha in mano un giocatore..
    (il giocatore ha vinto con una doppia coppia, ecc. }
    else if Command = '/TRANSLATEPLAYERSCORE' then begin
      PlayerScore := GetStr(StrToInt(GetToken(StrData,1)));
    end

    { Il server ci ordina di non far o far selezionare all'utente le carte }
    else if Command = '/UCANSELECT' then begin
      GetLocalPlayer.Hand.CanSelect := StrToBool(GetToken(StrData,1));

      { Se siamo abilitati a selezionare le carte, mostra anche il suggerimento per
      gli utenti meno accorti... }
      if StrToBool(GetToken(StrData,1)) and (not GetLocalPlayer.Hand.IsEmpty) then GetLocalPlayer.Hand.ShowChangeCardsHint
      else GetLocalPlayer.Hand.HideChangeCardsHint;
    end

    { Il server ci comunica che dobbiamo togliere le carte di un giocatore.. }
    else if Command = '/CLEARHANDOFPLAYER' then begin
      Players.GetPlayerWithId(StrToInt(GetToken(StrData,1))).Hand.Clear; 
    end

    { Il server ci sta ordinando di mostrare le carte... }
    else if Command = '/REVEALCARDSOFPLAYER' then begin
      Player := Players.GetPlayerWithId(StrToInt(GetToken(StrData,1)));
      Player.Hand.PaintHand(false);
    end

    { Il server ci avvisa che sta per iniziare un nuovo turno }
    else if Command = '/BEGINNINGNEWTURN' then begin
      { Se necessario, togli le carte }
      ClearPlayersHand;
    end

    { Game Over! GG! }
    else if Command = '/GAMEOVER' then begin
      MessageBox(0,pchar(GetStr(166)),'Game Over',MB_OK);
    end

    { Il server ci avvisa che dobbiamo abilitare o disabilitare il pulsante per rilanciare }
    else if Command = '/ENABLERELAUNCHBUTTON' then begin
      ButtonPanel.EnableRelaunchButton(StrToBool(GetToken(StrData,1)));
    end

    { Il server se ne sta per andare... }
    else if Command = '/HOSTISDISCONNECTING' then begin
      MessageBox(0,pchar(GetStr(167)),'Game Over',MB_OK);
      ClearPlayersHand;
      ButtonPanel.Hide;
      ShowStatus(GetStr(86));
    end;
  end;

except
  raise Exception.Create(GetStr(87));
end;

end;

{ Implementazione eventi }

{ Ci siamo connessi? good }
procedure TGameClient.ClientSocket_Connected(Sender: TObject);
var
  StrData: string;
  Command: string;
begin
  { Chiediamo il permesso di entrare nella partita... }
  SendText('/CANIJOIN');

  { Invia la versione }
  SendText('/CLIENTVERSION'+SEPARATOR+PROGRAMVERSION);

  { Se è richiesta una password, inviamo pure quella... }
  if ServerInfo.IsPasswordRequired then SendText('/PASS'+SEPARATOR+Password);

  { Siamo stati accolti? }
  StrData := ReceiveText;
  Command := GetCommand(StrData);

  if Command = '/UCANJOIN' then begin
    { Ok siamo stati ammessi al tavolo }

    { Invia il nickname }
    SendText('/MYNICKNAMEIS'+SEPARATOR+Nickname);

    { Inizializza la lista dei giocatori }
    Players := TPlayerList.Create(ServerInfo.GetSlots);
  end

  { Non possiamo giocare? }
  else if Command = '/UCANTJOINCOZ' then begin
    MessageBox(0,pchar(GetStr(88,GetToken(StrData,1))),pchar(ServerInfo.GetServerName),MB_OK or MB_ICONINFORMATION);
  end;


end;

{ Procedura per inviare i dati alla socket }
procedure TGameClient.SendText(Text: string);
begin
  ClientSocket.WriteLn(Text);
end;

{ OLD: Procedura overloadata per inviare più volte i dati alla socket
Perchè questa cosa? Perchè quando i dati vengono inviati al server, essi vengono processati
automaticamente dalla procedura ServerExecute, cosa che invece non dovrebbe accadere (o almeno
non sarebbe dovuta accadere secondo i miei ragionamenti, tuttavia ho sbagliato). Quindi se il client ha
un leggero ritardo di risposta sul server (questo problema non sorge sull'utente localhost), la procedura
WaitForACommandReply la prima volta non è in grado di intercettare il messaggio del client. Questo
piccolo trick riesce ad evitare il problema, anche se non è semanticamente corretto ed è una tecnica
completamente sbagliata perchè sovvraccarica inutilmente la rete e non assicura la certezza che il
pacchetto venga conesgnato con successo. Se qualcuno è in grado di darmi una soluzione più efficace, me
la segnali a: admin@pierotofy.it

NOTA: FIXED! Funzione obsoleta/inutilizzata }
procedure TGameClient.SendText(Text: string; Loop: integer);
var
  C: integer;
begin
  for C := 0 to Loop do
  begin
    SendText(Text);
    Sleep(BUTTONDELAYTIMER);
  end;
end;

{ Funzone per ricevere i dati dalla socket }
function TGameClient.ReceiveText: string;
begin
  Result := ClientSocket.ReadLn;
end;

{ Chiede al server se siamo host }
function TGameClient.IAmTheHost: boolean;
var
  StrData: string;
begin
  SendText('/AMITHEHOST');
  StrData := ReceiveText;

  if StrData = '/UARETHEHOST' then Result := true
  else if StrData = '/UARENOTTHEHOST' then Result := false
  else raise Exception.Create('Il server ha risposto ' + StrData + ' alla richiesta /AMITHEHOST. Contattare il produttore.');
end;

{ Procedura che notifica alla socket che una carta è stata selezionata... }
procedure TGameClient.Hand_CardSelected(Sender: TObject);
begin
  SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(Integer(Sender)));
end;

{ Procedura che notifica alla socket che una carta è stata deselezionata... }
procedure TGameClient.Hand_CardDeselected(Sender: TObject);
begin
  SendText('/IDESELECTEDTHISCARD'+SEPARATOR+IntToStr(Integer(Sender)));
end;


{ Carica i comandi per interagire con il gioco }
procedure TGameClient.LoadButtonPanel;
begin
  { Crea di default i pulsanti per avviare la partita }
  ButtonPanel := TButtonPanel.Create(AOwner,pmStartGame);
  ButtonPanel.Hide;

  { Imposta i gestori d'evento }
  ButtonPanel.ButtonStartGame.OnClick := ButtonStartGame_Click;
  ButtonPanel.ButtonChangeCards.OnClick := ButtonChangeCards_Click;
  ButtonPanel.ButtonPlay.OnClick := ButtonPlay_Click;
  ButtonPanel.ButtonPass.OnClick := ButtonPass_Click;
  ButtonPanel.ButtonOpen.OnClick := ButtonOpen_Click;
  ButtonPanel.ButtonRelaunch.OnClick := ButtonRelaunch_Click;
  ButtonPanel.ButtonSee.OnClick := ButtonSee_Click;
  ButtonPanel.ButtonWords.OnClick := ButtonWords_Click;
  ButtonPanel.ButtonCip.OnClick := ButtonCip_Click;
  ButtonPanel.ButtonBeginTurn.OnClick := ButtonBeginTurn_Click;
  ButtonPanel.ButtonShowCards.OnClick := ButtonShowCards_Click;
  ButtonPanel.ButtonDontShowCards.OnClick := ButtonDontShowCards_Click;


  ButtonPanel.OnBetValueAssigned := ButtonPanel_BetValueAssigned;
end;

{ Questa procedura ritorna un oggetto TPlayer che fa riferimento al
giocatore locale }
function TGameClient.GetLocalPlayer: TPlayer;
var
  C: integer;
  Player: TPlayer;
begin
  for C := 0 to Players.Count-1 do
  begin
    Player := Players.GetPlayer(C);
    if Player.IsLocalPlayer then begin
      Result := Player;
      exit;
    end;
  end;

  { Se non è stato trovato, scatena un eccezzione }
  raise Exception.Create('Non si è potuto trovare il giocatore locale nella procedura TGameClient.GetLocalPlayer. Contattare il produttore.');
end;


{ Si è deciso di avviare il gioco }
procedure TGameClient.ButtonStartGame_Click(Sender: TObject);
begin
  SendText('/IWANTSTARTTHEGAME');
end;

{ Procedura per cambiare le carte della mano }
procedure TGameClient.ButtonChangeCards_Click(Sender: TObject);
begin
  SendText('/ICHANGETHECARDS');
end;

{ Procedura che viene evocata nonappena il giocatore ha inserito un valore valido
per una puntata }
procedure TGameClient.ButtonPanel_BetValueAssigned(Sender: TObject);
var
  BetResult: TBetResult;
begin
  { Scompone l'oggetto Sender nella classe per consentirci di leggere i dati }
  BetResult := TBetResult(Sender);

  if BetResult.Mode = pmOpenBet then
    SendText('/OPENBETVALUE'+SEPARATOR+IntToStr(BetResult.Value))
  else if BetResult.Mode = pmFirstBet then
    SendText('/FIRSTBETVALUE'+SEPARATOR+IntToStr(BetResult.Value))
  else if BetResult.Mode = pmRelaunchBet then
    SendText('/RELAUNCHBETVALUE'+SEPARATOR+IntToStr(BetResult.Value))
  else if BetResult.Mode = pmSeeBet then
    SendText('/SEEBETVALUE'+SEPARATOR+IntToStr(BetResult.Value));
end;

{ Il giocatore ha premuto il pulsante per giocare la mano }
procedure TGameClient.ButtonPlay_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'IPLAY');
end;

{ Il giocatore ha premuto il pulsante per lasciare la mano }
procedure TGameClient.ButtonPass_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'IPASS');
end;

{ Il giocatore ha premuto il pulsante per aprire la mano }
procedure TGameClient.ButtonOpen_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'IOPEN');
end;

{ Il giocatore ha premuto il pulsante per rilanciare... }
procedure TGameClient.ButtonRelaunch_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH');
end;

{ Il giocatore ha premuto il pulsante per vedere... }
procedure TGameClient.ButtonSee_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'ISEE');
end;

{ Il giocatore ha premuto il pulsante per chiamare parole... }
procedure TGameClient.ButtonWords_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'IWORDS');
end;

{ Il giocatore ha premuto il pulsante per puntare il cip... }
procedure TGameClient.ButtonCip_Click(Sender: TObject);
begin
  SendText('/WHATIDO'+SEPARATOR+'ICIP');
end;

{ Il giocatore vuole iniziare un nuovo turno }
procedure TGameClient.ButtonBeginTurn_Click(Sender: TObject);
begin
  SendText('/IWANTBEGINTHETURN');
end;

{ Il giocatore vuole mostrare le proprie carte }
procedure TGameClient.ButtonShowCards_Click(Sender: TObject);
begin
  SendText('/DOISHOWTHECARDS'+SEPARATOR+'ISHOWTHECARDS');
end;

{ Il giocatore non vuole mostrare le proprie carte }
procedure TGameClient.ButtonDontShowCards_Click(Sender: TObject);
begin
  SendText('/DOISHOWTHECARDS'+SEPARATOR+'IDONTSHOWTHECARDS');
end;

{ Procedura per mostrare un testo nella Statusbar }
procedure TGameClient.ShowStatus(Text: string);
begin
  Statusbar.Panels[0].Text := Text;

  try
    OnStatusMessageArrival(TObject(Text));
  except
    //Se non c'è un gestore, non fare nulla
  end;
end;

{ Procedura scatenata quando un utente preme i pulsanti da 1 a 5 per selezionare una carta.. }
procedure TGameClient.Hand_CardChoicePressed(Sender: TObject);
var
  Card: TCard;
  Hand: THand;
begin
  Hand := GetLocalPlayer.Hand;
  Card := Hand.GetCard(Integer(Sender));

  { Se non è selezionata selezionala
  e non ho gia selezionato piu di 4 carte... }
  if (not Card.Selected) and (not (Hand.GetSelectedCardsCount = 4)) then begin
    SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(Integer(Sender)));
    Hand.SelectCard(Card);
  end

  { Altrimenti deselezionala }
  else if Card.Selected then begin
    SendText('/IDESELECTEDTHISCARD'+SEPARATOR+IntToStr(Integer(Sender)));
    Hand.DeselectCard(Card); 
  end;
end;


end.
