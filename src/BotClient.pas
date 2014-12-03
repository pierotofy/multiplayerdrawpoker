unit BotClient;

interface

uses Windows, IdTcpClient, Classes, SysUtils, Math,
  Card, Hand, ServerInfo, GameClient, Constants;


type
  TBotStyle = (bsCheap, bsNormal, bsAggressive);


{ Classe che implementa un AI bot in grado di giocare al
Multiplayer Poker }

type
  TBotClient = class(TGameClient)
  private
    InitialMoney: integer;
    CurrentMoney, CurrentMoneyTable: integer;
    BetMaxValue, BetMinValue: integer;
    Hand: THand;
    PlayersCount: integer;
    Style: TBotStyle;
    LocalId: integer;
    RelaunchCount: integer;
    WeHaveToCheat: boolean;
    WeCanRelaunch: boolean;
    MoneyArray: array [0 .. MAXSLOTS] of integer;
    PlayersWhoHaveMoney: integer;

    procedure ParsePanel(PanelMode: TPanelMode);
    function GetRandomNickname: string;
    function GetRandom(StartRange, EndRange: integer): integer;
    function GetPercentOnTotal(Percent: integer): integer;
    function GetPercentValueOnTotal(Value: integer): integer;
    function GetPermilOnTotal(Permil: integer): integer;
    function GetOpenBetValue: integer;
    function GetFirstBetValue: integer;
    function GetRelaunchValue: integer;
    procedure SelectCardsToChange;
    procedure SelectCardsToDoAStraight;
    function GetCardsCountToChangeToDoAStraight(StartFace: TFace; SelectCards: boolean): integer;
    procedure SelectCardsToDoATris;
    procedure SelectCardsToDoAFull;
    function GetPairFaceInHand: TFace;
    function GetTrisFaceInHand: TFace;
    function GetRelaunchCount: integer;
    function DoWeHaveToCheat: boolean;
    function GetRandomStyle: TBotStyle;
    function GetPlayersCountWhoHaveMoney: integer;
  public
    constructor Create(AOwner: TComponent; Host, Password: string; Port: integer);
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TBotClient }
constructor TBotClient.Create(AOwner: TComponent; Host, Password: string; Port: integer);
var
  Hours, Mins, Secs, MilliSecs : Word;
  C: integer;
begin
  { Setta il seme per la generazione di numeri casuali
  in base al numero di millisecondi dell'ora attuale }
  DecodeTime(now, Hours, Mins, Secs, MilliSecs);
  RandSeed := MilliSecs;

  self.AOwner := AOwner;
  self.Password := Password;
  self.Nickname := GetRandomNickname;
  self.RelaunchCount := -1;
  self.WeCanRelaunch := true;

  { Inizializza l'array del denaro.. }
  for C := 0 to MAXSLOTS do
    MoneyArray[C] := 0;

  { Generiamo il suo skill casualmente... }
  Style := GetRandomStyle;

  { Crea l'oggetto clientsocket }
  ClientSocket := TIdTcpClient.Create(AOwner);

  { Imposta le sue proprietà }
  ClientSocket.Host := Host;
  ClientSocket.Port := Port;
  ClientSocket.OnConnected := ClientSocket_Connected;

  try
    { Assegna all'istanza ServerInfo un oggetto
    Nota bene: non invertire l'ordine delle chiamate in questo blocco                          
    potrebbe causare errori di memoria (oggetti non inizializzati) }
    ServerInfo := TServerInfo.Create(AOwner,Host,Port);                                          

    { Connette la socket al server }
    ClientSocket.Connect(TIMEOUT);
  except
    raise Exception.Create('Impossibile connettersi a ' + Host + ':' + IntToStr(Port) + '.');
  end;

  inherited Create(false);
end;

{ Funzione per generare un numero casuale.. }
function TBotClient.GetRandom(StartRange, EndRange: integer): integer;
begin
  { Genera un numero casuale }
  Result := RandomRange(StartRange,EndRange);
end;

{ Funzione che ritorna quanti giocatori non hanno soldi }
function TBotClient.GetPlayersCountWhoHaveMoney: integer;
var
  C: integer;
begin
  Result := 0;
  for C := 0 to MAXSLOTS do
    if MoneyArray[C] > 0 then inc(Result);
end;

{ Funzione che ritorna il valore percentuale di un valore rispetto
al totale dei nostri soldi }
function TBotClient.GetPercentValueOnTotal(Value: integer): integer;
begin
  if CurrentMoney < 1 then Result := Value
  else Result := (100 * Value) div CurrentMoney;
end;

{ Entry Point }
procedure TBotClient.Execute;
var
  StrData, Command: string;
  C: integer;
  Face: TFace;
  Suit: TSuit;
  Card: TCard;
begin
  { Inizializza le variabili... }
  PlayersCount := 0;
  LocalId := -1;
  Hand := THand.Create;

  while ClientSocket.Connected do
  begin
    StrData := ReceiveText;
    Command := GetCommand(StrData);

    { Aumentiamo il numero di giocatori e salviamo il denaro iniziale... }
    if Command = '/PLAYERSPROJECTION' then begin
      { Se è la prima proiezione, prendiamo il nostro id }
      if PlayersCount = 0 then LocalId := StrToInt(GetToken(StrData,1));

      InitialMoney := StrToInt(GetToken(StrData,3));

      { Salviamo il denaro e incrementiamo alcune vars.. }
      MoneyArray[StrToInt(GetToken(StrData,1))] := StrToInt(GetToken(StrData,3));
      inc(PlayersCount);
      SetCurrentPlayingPlayers(PlayersCount);
    end


    { Quando sta per iniziare un nuovo turno, ci viene inviato
    come argomento al comando anche il numero di giocatori connessi al momento
    se sta cominciando il turno, cancella la mano }
    else if Command = '/BEGINNINGNEWTURN' then begin
      PlayersCount := StrToInt(GetToken(StrData,1));
      Hand.Clear;
      WeHaveToCheat := DoWeHaveToCheat;
      
      { Impostiamo una variabile per sapere chi ha e chi non ha denaro.. }
      PlayersWhoHaveMoney := PlayersCount - GetPlayersCountWhoHaveMoney;

      { Cambiamo lo style del bot ad ogni turno, così diventa ancora più imprevedibile }
      Style := GetRandomStyle;
    end

    { Qualcuno si è disconnesso? }
    else if Command = '/PLAYERDISCONNECTED' then begin
      dec(PlayersCount);
      SetCurrentPlayingPlayers(PlayersCount);
    end

    { Arrivano le carte? }
    else if Command = '/PLAYERHANDPROJECTION' then begin
      { Parsa il comando solamente se si tratta delle nostre carte }
      if StrToInt(GetToken(StrData,2)) = LocalId then begin

        { Se è la prima volta... }
        if GetToken(StrData,1) = 'FirstHand' then begin

          { Cancella la mano precedente.. }
          Hand.Clear;

          { Distribuisci le carte solamente se il giocatore non sta osservando }
          if not (GetToken(StrData,3) = 'Observing') then begin

            { Aggiunge le carte alla mano... }
            for C := 1 to 5 do Hand.PushCard(TFace(StrToInt(GetToken(StrData,C+C+1))),TSuit(StrToInt(GetToken(StrData,C+C+2))));
          end;
        end

        else begin
          { Altrimenti, se non è la prima volta che viene inviata la mano, si tratta di un cambio
          di carte oppure di una scoperta }

          { Se il giocatore ha la mano vuota, scatena un eccezzione }
          if Hand.IsEmpty then raise Exception.Create('Si è cercato di cambiare le carte, ma il giocatore aveva la mano vuota. Contattare il produttore.');

          { Cambia le carte secondo le indicazioni del server
          (solo se necessario) }
          for C := 1 to 5 do
          begin
            Face := TFace(StrToInt(GetToken(StrData,C+C+1)));
            Suit := TSuit(StrToInt(GetToken(StrData,C+C+2)));
            Card := Hand.GetCard(C-1);
            if not ((Card.Face = Face) and (Card.Suit = Suit)) then
              Card.ReplaceWith(Face,Suit,false);
          end;
        end;
        
        { Refresha il punteggio }
        Hand.CheckAndSetScore;
      end;
    end

    { Proiezione del denaro? }
    else if Command = '/MONEYPROJECTION' then begin
      if StrToInt(GetToken(StrData,1)) = LocalId then CurrentMoney := StrToInt(GetToken(StrData,2));

      { Salviamo il denaro.. }
      MoneyArray[StrToInt(GetToken(StrData,1))] := StrToInt(GetToken(StrData,3));
    end

    { Arriva la proiezione del piatto... }
    else if Command = '/MONEYTABLEPROJECTION' then begin
      CurrentMoneyTable := StrToInt(GetToken(StrData,1));
    end

    else if Command = '/ENABLERELAUNCHBUTTON' then begin
      WeCanRelaunch := StrToBool(GetToken(StrData,1));
    end

    { Il server ci informa che è cambiato il range delle puntate... }
    else if Command = '/BETRANGE' then begin
      BetMaxValue := StrToInt(GetToken(StrData,1));
      BetMinValue := StrToInt(GetToken(StrData,2));
    end


    { Se il server ci abilita ad usare un pannello,
    in base al pannello attivo decidiamo cosa fare... }
    else if Command = '/ENABLEPANEL' then begin
      ParsePanel(TPanelMode(Integer(StrToInt(GetToken(StrData,1)))));
    end;

  end;
end;


{ Procedura che simula l'intelligenza umana, decide quale
azione eseguire in base al pannello abilitato }
procedure TBotClient.ParsePanel(PanelMode: TPanelMode);
begin
  if PanelMode <> pmGeneralBet then Sleep(1000); //Sleep per "animare" il bot
  case PanelMode of
    { Il server di chiede di mettere un valore di apertura }
    pmOpenBet:
    begin
      SendText('/OPENBETVALUE'+SEPARATOR+IntToStr(GetOpenBetValue));
    end;

    { Abbiamo deciso di aprire, valutiamo le carte e quindi
    immettiamo la prima puntata...}
    pmFirstBet:
    begin
      SendText('/FIRSTBETVALUE'+SEPARATOR+IntToStr(GetFirstBetValue))
    end;

    { Apriamo sempre }
    pmOpenOrPass:
    begin
      SendText('/WHATIDO'+SEPARATOR+'IOPEN'); 
    end;

    { Passiamo sempre (non si può fare altro) -.- }
    pmPass:
    begin
      SendText('/WHATIDO'+SEPARATOR+'IPASS');
    end;

    { Dobbiamo giocare, rilanciare oppure passare... }
    pmPlayPassRelaunch:
    begin
      { Per evitare di entrare in un loop di rilanci, imposta il numero di volte
      che il bot rilancia la puntata ( -1 = mai rilanciato )}
      if RelaunchCount = -1 then RelaunchCount := 1;

      { Se il gioco si fa pesante (ultimo rilancio degli altri > (33 * Style)% dei nostri soldi)
      e non abbiamo delle buone carte in mano (doppia coppia), passa }
      if (GetPercentValueOnTotal(CurrentMoneyTable div PlayersCount) > (33 * (Integer(Style)+1))) and (not Hand.ScoreGreaterThan(TwoPair)) then begin
        SendText('/WHATIDO'+SEPARATOR+'IPASS');
        RelaunchCount := -1;
      end

      { Se è aggressivo o normale e abbiamo più di una coppia, rilancia, altrimenti
      gioca  }
      else if (Style = bsAggressive) and (Hand.ScoreGreaterThan(Pair)) and (RelaunchCount > 0) then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')
      else if (Style = bsNormal) and (Hand.ScoreGreaterThan(TwoPair)) and (RelaunchCount > 0) then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')
      else begin
        SendText('/WHATIDO'+SEPARATOR+'IPLAY');
        RelaunchCount := -1;
      end;
    end;

    { Dobbiamo fare un rilancio... }
    pmRelaunchBet:
    begin
      SendText('/RELAUNCHBETVALUE'+SEPARATOR+IntToStr(GetRelaunchValue));
      dec(RelaunchCount);
    end;

    { Dobbiamo rilanciare per vedere... }
    pmSeeBet:
    begin
      SendText('/SEEBETVALUE'+SEPARATOR+IntToStr(GetRelaunchValue));
    end;

    { Dobbiamo cambiare le carte... }
    pmChangeCards:
    begin
      SelectCardsToChange;
      SendText('/ICHANGETHECARDS');
    end;

    { Dobbiamo fare le varie operazioni di rilancio, cip, passo, ecc. }
    pmCipOrRelaunchOrSeeOrWordsOrPass:
    begin

      { Imposta i rilanci... }
      RelaunchCount := GetRelaunchCount;

      { Se qualcuno ha finito i soldi, permettiamogli di vedere (facciamo fuori uno alla volta :asd: ) }
      if GetPlayersCountWhoHaveMoney < PlayersWhoHaveMoney then SendText('/WHATIDO'+SEPARATOR+'ISEE')

      { Se ci sono rilanci da fare rilancia.. }
      else if RelaunchCount > 0 then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')

      { Se abbiamo meno di una doppia coppia ed è style aggressivo, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(Pair)) and (Style = bsAggressive) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
      { Se abbiamo meno di una coppia ed è style normale, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(HighCard)) and (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')


      { Se abbiamo meno di una doppia coppia non rilanciare,
      se possiamo chiama parole
      se stiamo giocando come aggressivo o normale chiama cip,
      se siamo deboli parole }
      else if not (Hand.ScoreGreaterThan(Pair)) then begin
        RelaunchCount := -1;
        if Style <> bsCheap then SendText('/WHATIDO'+SEPARATOR+'ICIP')
        else SendText('/WHATIDO'+SEPARATOR+'IWORDS');
      end

      { Se il gioco si fa acceso (ultimo rilancio degli altri > (7 * Style)% dei nostri soldi)
      e non abbiamo delle buone carte in mano (doppia coppia), passa }
      else if (GetPercentValueOnTotal(CurrentMoneyTable div PlayersCount) > (7 * (Integer(Style)+1))) and (not Hand.ScoreGreaterThan(TwoPair)) then begin
        SendText('/WHATIDO'+SEPARATOR+'IPASS');
        RelaunchCount := -1;
      end

      { Altrimenti vedi }
      else SendText('/WHATIDO'+SEPARATOR+'ISEE');
    end;

    pmRelaunchOrSeeOrWordsOrPass:
    begin
      { Imposta i rilanci... }
      RelaunchCount := GetRelaunchCount;

      { Se qualcuno ha finito i soldi, permettiamogli di vedere (facciamo fuori uno alla volta :asd: ) }
      if GetPlayersCountWhoHaveMoney < PlayersWhoHaveMoney then SendText('/WHATIDO'+SEPARATOR+'ISEE')

      { Se bisogna rilanciare rilancia.. }
      else if RelaunchCount > 0 then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')

      { Se abbiamo meno di una doppia coppia ed è style aggressivo, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(Pair)) and (Style = bsAggressive) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
      { Se abbiamo meno di una coppia ed è style normale, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(HighCard)) and (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')

      { Se il gioco si fa acceso (ultimo rilancio degli altri > (7 * Style)% dei nostri soldi)
      e non abbiamo delle buone carte in mano (doppia coppia), passa (se giochiamo con Cheap o Normal) }
      else if (GetPercentValueOnTotal(CurrentMoneyTable div PlayersCount) > (7 * (Integer(Style)+1))) and (not Hand.ScoreGreaterThan(TwoPair)) then begin
        if (Style = bsCheap) or (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
        else SendText('/WHATIDO'+SEPARATOR+'IWORDS');
        RelaunchCount := -1;
      end

      { Altrimenti vedi }
      else SendText('/WHATIDO'+SEPARATOR+'ISEE');
    end;

    pmRelaunchOrSeeOrPass:
    begin
      { Imposta i rilanci... }
      RelaunchCount := GetRelaunchCount;

      { Se qualcuno ha finito i soldi, permettiamogli di vedere (facciamo fuori uno alla volta :asd: ) }
      if GetPlayersCountWhoHaveMoney < PlayersWhoHaveMoney then SendText('/WHATIDO'+SEPARATOR+'ISEE')

      { Se bisogna rilanciare rilancia.. }
      else if RelaunchCount > 0 then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')

      { Se abbiamo meno di una doppia coppia ed è style aggressivo, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(Pair)) and (Style = bsAggressive) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
      { Se abbiamo meno di una coppia ed è style normale, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(HighCard)) and (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')


      { Se il gioco si fa acceso (ultimo rilancio degli altri > (7 * Style)% dei nostri soldi)
      e non abbiamo delle buone carte in mano (doppia coppia), passa (se giochiamo con Cheap o Normal) }
      else if (GetPercentValueOnTotal(CurrentMoneyTable div PlayersCount) > (7 * (Integer(Style)+1))) and (not Hand.ScoreGreaterThan(TwoPair)) then begin
        SendText('/WHATIDO'+SEPARATOR+'IPASS');
        RelaunchCount := -1;
      end

      { Altrimenti vedi }
      else SendText('/WHATIDO'+SEPARATOR+'ISEE');
    end;

    pmCipOrRelaunchOrSeeOrPass:
    begin
      { Imposta i rilanci... }
      RelaunchCount := GetRelaunchCount;

      { Se qualcuno ha finito i soldi, permettiamogli di vedere (facciamo fuori uno alla volta :asd: ) }
      if GetPlayersCountWhoHaveMoney < PlayersWhoHaveMoney then SendText('/WHATIDO'+SEPARATOR+'ISEE')

      { Se bisogna rilanciare rilancia.. }
      else if RelaunchCount > 0 then SendText('/WHATIDO'+SEPARATOR+'IRELAUNCH')

      { Se abbiamo meno di una doppia coppia ed è style aggressivo, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(Pair)) and (Style = bsAggressive) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
      { Se abbiamo meno di una coppia ed è style normale, esci in ogni modo... }
      else if (not Hand.ScoreGreaterThan(HighCard)) and (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')


      { Se il gioco si fa acceso (ultimo rilancio degli altri > (7 * Style)% dei nostri soldi)
      e non abbiamo delle buone carte in mano (doppia coppia), passa (se giochiamo con Cheap o Normal) }
      else if (GetPercentValueOnTotal(CurrentMoneyTable div PlayersCount) > (7 * (Integer(Style)+1))) and (not Hand.ScoreGreaterThan(TwoPair)) then begin
        if (Style = bsCheap) or (Style = bsNormal) then SendText('/WHATIDO'+SEPARATOR+'IPASS')
        else SendText('/WHATIDO'+SEPARATOR+'ICIP');
        RelaunchCount := -1;
      end

      { Altrimenti vedi }
      else SendText('/WHATIDO'+SEPARATOR+'ISEE');
    end;

    pmBeginTurn:
    begin
      { Ferma un po' per far vedere i risultati della partita... }
      Sleep(4000);
      SendText('/IWANTBEGINTHETURN');
    end;

    pmShowCardsOrDontShowCards:
    begin
      { Mostra sempre le carte, tanto il gioco di un bot è imprevedibile ;) }
      SendText('/DOISHOWTHECARDS'+SEPARATOR+'ISHOWTHECARDS');
    end;
  end;
end;

{ Funzione per prendere una puntata di apertura }
function TBotClient.GetOpenBetValue: integer;
begin
  { Se il gioco è aggressivo, punta tutto il cip, altrimenti la metà }
  if Style = bsAggressive then Result := ServerInfo.GetCip
  else Result := ServerInfo.GetCip div 2;

  { Se il valore è maggiore dei nostri soldi, punta 1 }
  if Result > CurrentMoney then Result := 1;
end;

{ Funzione che ritorna il valore della prima puntata }
function TBotClient.GetFirstBetValue: integer;
begin
  { Se abbiamo in mano più di una doppia coppia, apri forte
  (un numero tra il 2% del totale e il 3% del totale) }
  if Hand.ScoreGreaterThan(TwoPair) then begin
    Result := GetRandom(GetPercentOnTotal(2),GetPercentOnTotal(3));
  end

  { Altrimenti apri più piano (random tra 5 per mille del totale e il 10 per mille del totale) }
  else begin
    Result := GetRandom(GetPermilOnTotal(5),GetPermilOnTotal(10));
  end;
end;

{ Funzione che ritorna una percentuale sul totale del denaro }
function TBotClient.GetPercentOnTotal(Percent: integer): integer;
var
  DivVal: integer;
begin
  DivVal := InitialMoney div 100;
  if DivVal < 1 then DivVal := 1;
  Result := DivVal * Percent;
end;

{ Funzione che ritorna una millesima parte sul totale del denaro }
function TBotClient.GetPermilOnTotal(Permil: integer): integer;
var
  DivVal: integer;
begin
  DivVal := InitialMoney div 1000;
  if DivVal < 1 then DivVal := 1;
  Result := DivVal * Permil;
end;

{ Funzione per prendere il denaro da rilanciare... }
function TBotClient.GetRelaunchValue: integer;
begin
  { Intanto il rilancio dev'essere di un minimo... }
  Result := BetMinValue;

  { Poi aggiungiamo una percentuale in base al punteggio che abbiamo in mano
  e lo moltiplichiamo per il stile }
  Result := Result + GetPercentOnTotal((Integer(Hand.Score.ScoreType)+1) * (Integer(Style)+1));

  { Se lo stile è aggressivo, aggiungi un numero casuale tra 1% e X% dove X è il punteggio della mano }
  if Style = bsAggressive then Result := Result + GetRandom(GetPercentOnTotal(1),GetPercentOnTotal(Integer(Hand.Score.ScoreType)+1));

  { Se siamo sopra il limite massimo, imposta il tutto al limite massimo... }
  if Result > BetMaxValue then Result := BetMaxValue;

  { Visto che nelle ultime versioni non si puo' rilanciare fino alla morte (o almeno
  non è consentito se gli altri decidono di vedere, aumentiamo il rilancio di 1/3 }
  Result := Result + (Result div 3);
end;

{ Funzione che ritorna un nickname casuale... }
function TBotClient.GetRandomNickname: string;
var
  NickList: array [0 .. 10] of string;
begin
  NickList[0] := 'John';
  NickList[1] := 'Alex';
  NickList[2] := 'Jenny';
  NickList[3] := 'Foo';
  NickList[4] := 'Mike';
  NickList[5] := 'Sam';
  NickList[6] := 'Fox';
  NickList[7] := 'Jack';
  NickList[8] := 'Smith';
  NickList[9] := 'Neo';

  Result := NickList[GetRandom(0,9)];
end;


{ Procedura che seleziona le carte da cambiare... }
procedure TBotClient.SelectCardsToChange;
begin
  { Se stiamo bleffando, ovviamente siamo serviti :) }
  if WeHaveToCheat then exit;

  { Cambia le carte solamente se hai un punteggio inferiore ad una scala }
  if not Hand.ScoreGreaterThan(Tris) then begin
    { Abbiamo un punteggio "scarso", cambiamo le carte in base al nostro punteggio attuale }
    case Hand.Score.ScoreType of
      HighCard: SelectCardsToDoAStraight;
      Pair: SelectCardsToDoATris;
      TwoPair: SelectCardsToDoAFull;
      Tris: SelectCardsToDoAFull;
    end;                                           
  end;
end;


{ Procedura per selezionare le carte necessarie a fare una scala }
procedure TBotClient.SelectCardsToDoAStraight;
var
  CardsToChange: integer;
  Face: TFace;
  StartFace: TFace;
  CardsCount: integer;
  FaceToUse: TFace;
begin
  StartFace := GetMinCardFace;

  { Setta al massimo }
  CardsToChange := 4;

  { Imposta la faccia della prima carta della mano come predefinita... }
  FaceToUse := Hand.GetCard(0).Face;

  { Prova a fare una scala con tutti i valori (dal 10 indietro fino all'inizio) e sceglie la migliore... }
  for Face := Ten downto StartFace do
  begin
    CardsCount := GetCardsCountToChangeToDoAStraight(Face,false);
    if CardsCount < CardsToChange then begin
      CardsToChange := CardsCount;
      FaceToUse := Face;
    end;
  end;

  { A questo punto cambia le carte.. }
  GetCardsCountToChangeToDoAStraight(FaceToUse,true);
end;

{ Funzione per controllare quante carte sono da cambiare per fare
una scala. Se l'argomento è true, anche le seleziona }
function TBotClient.GetCardsCountToChangeToDoAStraight(StartFace: TFace; SelectCards: boolean): integer;
var
  C, D: integer;
  Card: TCard;
  CurFaceValue: integer;
  Face: TFace;
  CardFound: boolean;
begin
  Result := 4;

  for C := 0 to Hand.Count-1 do
  begin
    CurFaceValue := GetFaceValue(StartFace)+C;
    for D := 0 to Hand.Count-1 do
      if GetFaceValue(Hand.GetCard(D).Face) = CurFaceValue then dec(Result);
  end;

  if SelectCards then begin
    for C := 0 to Hand.Count-1 do
    begin
      Card := Hand.GetCard(C);
      CardFound := false;
      for Face := StartFace to TFace(Integer(StartFace)+Hand.Count-1) do
        if Card.Face = Face then CardFound := true;

      if not CardFound then SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(C));
    end;
  end;

  { Se c'è un errore che il bot cambia 5 carte...
  Deseleziona la prima (vabbè cambiamo 4 carte) }
  if Hand.GetSelectedCardsCount > 4 then SendText('/IDESELECTEDTHISCARD'+SEPARATOR+'0');
end;


{ Procedura per tentare un tris... }
procedure TBotClient.SelectCardsToDoATris;
var
  C: integer;
  PairFace: TFace;
begin
  { Per prima cosa individuiamo la coppia }
  PairFace := GetPairFaceInHand;

  { Quindi cambia tutte le carte che non hanno la stessa faccia }
  for C := 0 to Hand.Count-1 do
    if Hand.GetCard(C).Face <> PairFace then SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(C));
end;

{ Funzione che ritorna la faccia della coppia presente in mano }
function TBotClient.GetPairFaceInHand: TFace;
var
  C, D: integer;
  Card: TCard;
begin
  for C := 0 to Hand.Count-1 do
  begin
    Card := Hand.GetCard(C);
    for D := C+1 to Hand.Count-1 do
    begin
      if Card.Face = Hand.GetCard(D).Face then begin
        Result := Card.Face;
        exit;
      end;
    end;
  end;
end;

{ Funzione che ritorna la faccia del tris presente in mano }
function TBotClient.GetTrisFaceInHand: TFace;
var
  C,D: integer;
  Card: TCard;
  CardFound: integer;
begin
  for C := 0 to Hand.Count-1 do
  begin
    CardFound := 0;
    Card := Hand.GetCard(C);
    for D := 0 to Hand.Count-1 do
      if Hand.GetCard(D).Face = Card.Face then inc(CardFound);
    if CardFound >= 3 then Result := Card.Face;
  end;
end;

{ Procedura che tenta un full (o un poker) }
procedure TBotClient.SelectCardsToDoAFull;
var
  C, D: integer;
  Card: TCard;
  IsSingle: boolean;
  FaceToChange: TFace;
begin
  { Se è doppia coppia... individua la carta "singola" e cambiala }
  if Hand.Score.ScoreType = TwoPair then begin
    for C := 0 to Hand.Count-1 do
    begin
      IsSingle := true;
      Card := Hand.GetCard(C);
      for D := 0 to Hand.Count-1 do
        if (Hand.GetCard(D).Face = Card.Face) and (Hand.GetCard(D) <> Card) then IsSingle := false;

      if IsSingle then SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(C));
    end;
  end

  { Altrimenti se è un tris, prova a promuovere a full cambiando le due carte diverse }
  else if Hand.Score.ScoreType = Tris then begin
    FaceToChange := GetTrisFaceInHand;
    for C := 0 to Hand.Count-1 do
      if Hand.GetCard(C).Face <> FaceToChange then SendText('/ISELECTEDTHISCARD'+SEPARATOR+IntToStr(C));
  end;
end;

{ Funzione per prendere il numero di rilanci da fare.. }
function TBotClient.GetRelaunchCount: integer;
begin
  { Se non possiamo rilanciare, imposta a -1 }
  if (not WeCanRelaunch) or (CurrentMoney < BetMinValue) or (CurrentMoney < 1) then Result := -1

  { Se stiamo bleffando, aumenta i rilanci }
  else if WeHaveToCheat then Result := 9

  { Se abbiamo un full o più, rilancia almeno 4 volte }
  else if Hand.ScoreGreaterThan(Straight) then Result := 4

  { Altrimenti calcolali in maniera "ingelligente" }
  else if (RelaunchCount = -1) and (Hand.ScoreGreaterThan(TwoPair)) then begin
    if Style = bsAggressive then Result := GetRandom(2,Integer(Hand.Score.ScoreType))
    else if Style = bsNormal then Result := GetRandom(1,Integer(Hand.Score.ScoreType) div 2)
    else Result := GetRandom(1,Integer(Hand.Score.ScoreType) div 3);
  end
  else Result := -1;

  { In base al punteggio aumenta i rilanci se necessario... }
  if (Hand.ScoreGreaterThan(Tris)) and (Result > 0) then Result := Result + Integer(Style) + 1;
end;

{ Funzione per vedere se dobbiamo bleffare in questo turno... }
function TBotClient.DoWeHaveToCheat: boolean;
var
  N: integer;
  Range: integer;
begin
  { Se siamo aggressivi, 1 volta su 20, normali 1 su 40, "deboli" 1 su 60 }
  Range := 80 - (20 * (Integer(Style) + 1));

  { Generi un numero }
  N := GetRandom(1,Range);

  { Se il numero è 2 allora dobbimamo bleffare.. }
  Result := (N = 2);
end;

{ Funzione che ritorna uno style casuale da applicare al bot.. }
function TBotClient.GetRandomStyle: TBotStyle;
begin
  Result := TBotStyle(GetRandom(0,3));
end;


end.
 