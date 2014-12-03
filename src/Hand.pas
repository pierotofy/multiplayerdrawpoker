unit Hand;

interface

uses Windows, Forms, Classes, Variants, Sysutils, ExtCtrls, Controls,
 Deck, Card, Constants, Languages;

{ Classe TScore }
type
  TScore = class
  public
    ScoreType: THandScore;
    ScoreValue: integer;
    TwoPairSingleCardValue: integer;
    TwoPairFirstCompareCard: TCard;
    TwoPairSecondCompareCard: TCard;

    function ToString: string;
    function ToDataIndex: integer;
    constructor Create(ScoreType: THandScore; ScoreValue: integer);
  end;

{ Classe THand }
type
  THand = class(TList)
  private
    FrmParent: TForm; { riferimento al form principale }
    AOwner: TComponent; { riferimento al componente che ha creato il mazzo }
    m_Score: TScore;
    Position: THandPosition;
    m_CanSelect: boolean;
    m_CardsChanged: integer;
    SelectHint: TImage;

    { Evento scatenato durante la selezione della carta... }
    m_OnCardSelected: TNotifyEvent;

    { Evento scatenato durante la deselezione della carta... }
    m_OnCardDeselected: TNotifyEvent;

    function GetScore: TScore;
    
    function GetPair: integer;
    function GetTwoPair: integer;
    function GetTris: integer;
    function GetStraight: integer;
    function GetFull: integer;
    function GetFlush: integer;
    function GetPoker: integer;
    function GetRoyalFlush: integer;
    procedure ChangeCard(Index: integer; NewCard: TCard);
    function GetCardIndex(Card: TCard): integer;
  public
    constructor Create(AOwner: TComponent; FrmParent: TForm; Position: THandPosition); overload;
    constructor Create; overload;
    function PushCard(Card: TCard): boolean; overload;
    function PushCard(Face: TFace; Suit: TSuit): boolean; overload;
    procedure RemoveCard(Index: integer);
    procedure PaintHand(Covered: boolean; PlayCardSound: boolean = false);
    procedure CheckAndSetScore;

    function GetCard(Index: integer): TCard;
    function GetMinCard: TCard;
    function GetMaxCard: TCard;
    function GetMaxCardThatIsntAce: TCard;
    function GetCardWhosUnique: TCard;
    function HaveWeThisFace(Face: TFace): boolean;
    function ScoreGreaterThan(HandScore: THandScore): boolean;
    function IsGreaterThan(Hand: THand): boolean;
    function GetSelectedCardsCount: integer;
    function HasAtLeastAPairOf(Face: TFace): boolean;
    function HasAPossibleRoyalFlush(MinFace: TFace): boolean;
    function CanOpen(MinFace: TFace; MinPairFaceNeeded: TFace): boolean;
    procedure SetCanSelect(Value: boolean);
    procedure SelectCard(Card: TCard); overload;
    procedure SelectCard(Card: TCard; RaiseEvent: boolean); overload;
    procedure SelectCard(Index: integer); overload;
    procedure SelectCard(Index: integer; RaiseEvent: boolean); overload;
    procedure DeselectCard(Card: TCard); overload;
    procedure DeselectCard(Card: TCard; RaiseEvent: boolean); overload;
    procedure DeselectCard(Index: integer); overload;
    procedure DeselectCard(Index: integer; RaiseEvent: boolean); overload;
    procedure SelectCardWithoutGraphicsOp(Index: integer);
    procedure DeselectCardWithoutGraphicsOp(Index: integer);
    procedure DeselectAllCards;
    procedure ShowChangeCardsHint;
    procedure HideChangeCardsHint;
    procedure ChangeCards(Deck: TDeck);
    procedure FillHand(Deck: TDeck);
    function IsEmpty: boolean;
    procedure Hide;
    procedure Clear; override;
    procedure ResetScore;

    procedure CardClick(Sender: TObject);
    procedure CardClickDoNothing(Sender: TObject);

    property Score: TScore read GetScore;
    property OnCardSelected: TNotifyEvent read m_OnCardSelected write m_OnCardSelected;
    property OnCardDeselected: TNotifyEvent read m_OnCardDeselected write m_OnCardDeselected;
    property CanSelect: boolean read m_CanSelect write SetCanSelect;
    property CardsChanged: integer read m_CardsChanged;
  end;

implementation

{ Implementazione classe TScore }
constructor TScore.Create(ScoreType: THandScore; ScoreValue: integer);
begin
  self.ScoreType := ScoreType;
  self.ScoreValue := ScoreValue;
end;

{ Funzione per vedere il valore del punteggio della mano in formato stringa }
function TScore.ToString: string;
begin
  case ScoreType of
    HighCard: Result := GetStr(57);
    Pair: Result := GetStr(58);
    TwoPair: Result := GetStr(122);
    Tris: Result := GetStr(59);
    Straight: Result := GetStr(60);
    Full: Result := GetStr(61);
    Flush: Result := GetStr(62);
    Poker: Result := GetStr(63);
    RoyalFlush: Result := GetStr(64);
  end;
end;

{ Funzione per vedere il valore del punteggio in formato multilingua (DataIndex) }
function TScore.ToDataIndex: integer;
begin
  case ScoreType of
    HighCard: Result := 57;
    Pair: Result := 58;
    TwoPair: Result := 122;
    Tris: Result := 59;
    Straight: Result :=60;
    Full: Result := 61;
    Flush: Result := 62;
    Poker: Result := 63;
    RoyalFlush: Result := 64;
  end;
end;

{ Implementazione classe THand }
constructor THand.Create(AOwner: TComponent; FrmParent: TForm; Position: THandPosition);
begin
  self.AOwner := AOwner;
  self.FrmParent := FrmParent;
  self.Position := Position;
  CanSelect := false;

  { L'immagine che mostra una manina a fianco delle carte è disponibile solo con hpBottom }
  if Position = hpBottom then begin
    SelectHint := TImage.Create(AOwner);
    SelectHint.Picture.Bitmap.LoadFromResourceName(hInstance,'HAND');
    SelectHint.AutoSize := true;
    SelectHint.Visible := false;
    SelectHint.Parent := FrmParent;
    SelectHint.Top := (FrmParent.ClientHeight - CARDBORDERSPACING - CDllHeight - STATUSBARHEIGHT);
    SelectHint.Left := (FrmParent.ClientWidth div 2 - ((CARDSPACING * 5 + CDllWidth)div 2)) - 2 - SelectHint.Width;
  end;
end;

{ Costruttore overloadata, richiamando questo costruttore non è possibile
richiamare PaintHand e le procedure legate alla selezione/deselezione delle carte
non spostano graficamente le carte }
constructor THand.Create;
begin

end;

{ Inserisce una carta alla mano se ci sono meno di 5 carte }
function THand.PushCard(Card: TCard): boolean;
begin
  if self.Count < 5 then begin
    self.Add(Card);
    { Imposta il gestore dell'evento click se si tratta del giocatore locale (quindi posizionato in basso) }
    if Position = hpBottom then Card.OnClick := CardClick;
    Result := true;
  end
  else Result := false;
end;

{ Procedura per visualizzare la manina di aiuto }
procedure THand.ShowChangeCardsHint;
begin
  if Position = hpBottom then SelectHint.Show;
end;

{ Procedura per nascondere la manina di aiuto }
procedure THand.HideChangeCardsHint;
begin
  if Position = hpBottom then SelectHint.Hide;
end;


{ Inserisce una carta alla mano se ci sono meno di 5 carte
(versione overloadata, si puo' passare direttamente il seme e il numero
della carta anzichè l'oggetto Card }
function THand.PushCard(Face: TFace; Suit: TSuit): boolean;
begin
  if self.Count < 5 then begin
    self.Add(TCard.Create(AOwner,FrmParent,Face,Suit));
    { Imposta il gestore dell'evento click se si tratta del giocatore locale (quindi posizionato in basso) }
    if Position = hpBottom then TCard(self.Get(self.Count-1)).OnClick := CardClick;
    Result := true;
  end
  else Result := false;
end;

{ Procedura per stampare sul form le carte }
procedure THand.PaintHand(Covered: boolean; PlayCardSound: boolean = false);
var
  X, Y: integer; { coordinate di partenza per disegnare la prima carta }
  Count: integer;
begin
  { Se è stato richiamato il 2° costruttore, non è possibile
  richiamare questa procedura }
  if not (Assigned(AOwner)) then raise Exception.Create('Si è cercato di richiamare la procedura THand.PaintHand, ma la variabile AOwner non è stata settata. Contattare il produttore.');

  { Se il numero di carte presenti nella mano è minore di 5 allora scatena un eccezzione }
  if self.Count < 5 then raise Exception.Create('Si è cercato di disegnare la mano quando essa possedeva meno di 5 carte. Contattare il produttore.');

  X := 0;
  Y := 0;

  { Se è la mano in alto o in basso, calcola la X, altrimenti la Y }
  case Position of
    hpTop:
    begin
        Y := CARDBORDERSPACING;
        X := FrmParent.ClientWidth div 2 - ((CARDSPACING * (self.Count-1) + CDllWidth)div 2);
    end;
    hpBottom:
    begin
        Y := FrmParent.ClientHeight - CARDBORDERSPACING - CDllHeight - STATUSBARHEIGHT;
        X := FrmParent.ClientWidth div 2 - ((CARDSPACING * (self.Count-1) + CDllWidth)div 2);
    end;
    hpLeft:
    begin
        Y := (FrmParent.ClientHeight - STATUSBARHEIGHT) div 2 - ((CARDSPACING * (self.Count-1) + CDllHeight) div 2);
        X := CARDBORDERSPACING;
    end;
    hpRight:
    begin
        Y := (FrmParent.ClientHeight - STATUSBARHEIGHT) div 2 - ((CARDSPACING * (self.Count-1) + CDllHeight) div 2);
        X := FrmParent.ClientWidth - CARDBORDERSPACING - CDllWidth;
    end;
  end;

  { Disegna le carte partendo dal punto X,Y }
  for Count := 0 to self.Count-1 do
  begin
    GetCard(Count).Draw(X,Y, Covered);
    if Covered then GetCard(Count).CoverCard;

    { Mette la carta in primo piano }
    GetCard(Count).BringToFront;

    { A seconda della posizione, incrementa o decrementa la X o la Y }
    case Position of
      hpTop:
        X := X + CARDSPACING;
      hpBottom:
        X := X + CARDSPACING;
      hpRight:
        Y := Y + CARDSPACING;
      hpLeft:
        Y := Y + CARDSPACING;
    end;

    { Se siamo il giocatore locale (position = hpBottom) e le carte
    non sono coperte, allora suona }
    if (Position = hpBottom) and PlayCardSound then begin
      PlayResSound(WAVDISTROCARD);
      Sleep(LOCALANIMATIONTIME);
    end
    else Sleep(ENEMYANIMATIONTIME);
  end;

  { Refresha }
  FrmParent.Refresh;
end;

{ Funzione che ritorna una carta dalla lista }
function THand.GetCard(Index: integer): TCard;
begin
  Result := TCard(self.Items[Index]);
end;

{ Funzione che trova la carta minore }
function THand.GetMinCard: TCard;
var
  Count: integer;
  CompareCard: TCard;
begin
  CompareCard := GetCard(0);
  for Count := 1 to self.Count-1 do
    if CompareCard.Value > GetCard(Count).Value then CompareCard := GetCard(Count);
  Result := CompareCard;
end;

{ Funzione che trova la carta maggiore }
function THand.GetMaxCard: TCard;
var
  Count: integer;
  CompareCard: TCard;
begin
  CompareCard := GetCard(0);
  for Count := 1 to self.Count-1 do
    if CompareCard.Value < GetCard(Count).Value then CompareCard := GetCard(Count);
  Result := CompareCard;
end;

{ Funzione che trova la carta maggiore che non sia un asso }
function THand.GetMaxCardThatIsntAce: TCard;
var
  Count: integer;
  CompareCard: TCard;
begin
  for Count := 0 to self.Count-1 do
    if GetCard(Count).Face <> Ace then begin
      CompareCard := GetCard(Count);
      break;
    end;

  for Count := 0 to self.Count-1 do
    if (GetCard(Count).Face <> Ace) and (CompareCard.Value < GetCard(Count).Value) then CompareCard := GetCard(Count);
  Result := CompareCard;
end;

{ Funzione che trova l'unica carta nella mano con seme unico }
function THand.GetCardWhosUnique: TCard;
var
  C, D: integer;
  Card: TCard;
  PairFound: boolean;
begin
  for C := 0 to self.Count-1 do
  begin
    PairFound := false;
    Card := GetCard(C);
    for D := 0 to self.Count-1 do
      if (GetCard(D).Face = Card.Face) and (GetCard(D) <> Card) then PairFound := true;

    if not PairFound then begin
      Result := Card;
      exit;
    end;
  end;

  { Siccome questa funzione viene richiamata anche quando
  si controlla il full, impostiamo un valore di default di ritorno
  nel caso che non venisse trovata una carta unica.. }
  Result := GetCard(0);
  //raise Exception.Create('Non è stata trovata una carta unica nella mano, errore nella procedura GetCardWhosUnique. Contattare il produttore.');
end;

{ Funzione che ritorna vero se è presente almeno una carta con una faccia
altrimenti false }
function THand.HaveWeThisFace(Face: TFace): boolean;
var
  CurrentCardCount: integer;
begin
  for CurrentCardCount := 0 to self.Count-1 do
  begin
    if GetCard(CurrentCardCount).Face = Face then begin
      Result := true;
      exit;
    end;
  end;
  Result := false;
end;

{ Funzione che assegna il punteggio della mano }
procedure THand.CheckAndSetScore;
var
  ScoreValue: integer;
begin
  { Comincia dalla scala reale per finire con la carta singola,
  se trova un punteggio valido, esce dalla procedura }

  ScoreValue := GetRoyalFlush;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(RoyalFlush,ScoreValue); exit; end;

  ScoreValue := GetPoker;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Poker,ScoreValue); exit; end;

  ScoreValue := GetFlush;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Flush,ScoreValue); exit; end;

  ScoreValue := GetFull;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Full,ScoreValue); exit; end;

  ScoreValue := GetStraight;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Straight,ScoreValue); exit; end;

  ScoreValue := GetTris;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Tris,ScoreValue); exit; end;

  ScoreValue := GetTwoPair;
  //Eccezzione per la doppia coppia, se troviamo una doppia coppia, il punteggio viene creato nella funzione
  if ScoreValue <> 0 then exit;

  ScoreValue := GetPair;
  if ScoreValue <> 0 then begin m_Score := TScore.Create(Pair,ScoreValue); exit; end;

  { Se non ha trovato dei punteggi, il valore è quello della carta più alta }
  ScoreValue := GetMaxCard.Value;
  m_Score := TScore.Create(HighCard,ScoreValue);
end;

{ Funzione che ritorna il punteggio della mano }
function THand.GetScore: TScore;
begin
  { Se il punteggio non è stato ancora assegnato, assegnalo }
  if not Assigned(m_Score) then CheckAndSetScore;

  Result := m_Score;
end;

{ E' una coppia?
Restituisce 0 se è una coppia
altrimenti il valore della carta facente parte della coppia }
function THand.GetPair: integer;
var
  CurrentCardCount, CompareCardCount: integer;
  CurrentCard: TCard;
begin
  for CurrentCardCount := 0 to self.Count-1 do
  begin
    CurrentCard := GetCard(CurrentCardCount);
    for CompareCardCount := CurrentCardCount+1 to self.Count-1 do
      if CurrentCard.Face = GetCard(CompareCardCount).Face then begin
        Result := CurrentCard.Value;
        exit;
      end;
  end;
  Result := 0;
end;


{ E' una doppia coppia?
La funzione restituisce 0 se non è una doppia coppia,
altrimenti il valore dalla carta più alta che non è parte di una coppia
(inizializza comunque da se il punteggio...) }
function THand.GetTwoPair: integer;
var
  CurrentCardCount, CompareCardCount, EqualFaceFound: integer;
  CurrentCard: TCard;
  FaceFound: TFace;
  MaxCardOfCouple: TCard;
  SecondCouple: TCard;
begin
  EqualFaceFound := 0;
  CurrentCardCount := 0;

  for CurrentCardCount := 0 to self.Count-1 do
  begin
    CurrentCard := GetCard(CurrentCardCount);
    for CompareCardCount := CurrentCardCount+1 to self.Count-1 do
    begin
      if (CurrentCard.Face = GetCard(CompareCardCount).Face) and (GetCard(CompareCardCount).Face <> FaceFound) then begin

        { Se è la prima volta inizializza la carta da prendere in confronto per
        il successivo calcolo del punteggio }
        if EqualFaceFound = 0 then MaxCardOfCouple := GetCard(CompareCardCount)
        else if EqualFaceFound = 1 then SecondCouple := GetCard(CompareCardCount);

        FaceFound := CurrentCard.Face;
        inc(EqualFaceFound);

        { Se la nuova carta trovata fra le coppie è più alta di quella precedente,
        salva il suo valore che ci servirà in seguito per il calcolo dei punteggi }
        if GetCard(CompareCardCount).Value > MaxCardOfCouple.Value then begin
          SecondCouple := MaxCardOfCouple;
          MaxCardOfCouple := GetCard(CompareCardCount);
        end;

        { Se abbiamo trovato 2 coppie fermati, siamo a posto }
        if EqualFaceFound >= 2 then break;
      end;
    end;
  end;

  { Se non abbiamo trovato una doppia coppia esci con 0 }
  if EqualFaceFound < 2 then Result := 0


  { Altrimenti crea il punteggio con il valore della carta più alta fra le due coppie e
   salva il valore della carta singola }
  else begin
    m_Score := TScore.Create(TwoPair,MaxCardOfCouple.Value);
    m_Score.TwoPairFirstCompareCard := MaxCardOfCouple;
    m_Score.TwoPairSecondCompareCard := SecondCouple;
    m_Score.TwoPairSingleCardValue := GetCardWhosUnique.Value;
    Result := m_Score.TwoPairSingleCardValue;
  end;
end;

{ E' un tris?
0 se non è un tris
il valore di una delle carte del tris (quindi non moltiplicato per 3) }
function THand.GetTris: integer;
var
  CurrentCardCount, CompareCardCount, SameFaceFound: integer;
  CurrentCard: TCard;
begin
  for CurrentCardCount := 0 to self.Count-1 do
  begin
    SameFaceFound := 1;
    CurrentCard := GetCard(CurrentCardCount);
    for CompareCardCount := CurrentCardCount+1 to self.Count-1 do
      if CurrentCard.Face = GetCard(CompareCardCount).Face then inc(SameFaceFound);

    if SameFaceFound = 3 then begin
      Result := CurrentCard.Value;
      exit;
    end;
  end;
  Result := 0;
end;

{ E' una scala?
Ritorna 0 se non è una scala
Il valore della carta più alta se è una scala }
function THand.GetStraight: integer;
var
  CurrentCardCount, Count: integer;
  StartFrom: integer;
  MaxCard: TCard;
  FaceFound: array [0 .. 15] of boolean;
  MinFace: TFace;
  FaceToCmp: TFace;
  MinStraightFound: boolean;
begin
  MinStraightFound := true;
  Result := 0;
  MaxCard := GetMaxCard;
  MinFace := GetMinCardFace;

  { Prima di tutto vediamo se c'è la scala minima con l'asso in testa... }

  { Azzera l'array }
  for Count := 0 to 13 do
    FaceFound[Count] := false;

  for CurrentCardCount := 0 to self.Count-1 do
  begin
    if GetCard(CurrentCardCount).Face = Ace then FaceToCmp := TFace(Integer(MinFace)-1)
    else FaceToCmp := GetCard(CurrentCardCount).Face;                                                  
    FaceFound[GetFaceValue(FaceToCmp)] := true;
  end;

  { Comincia dalla carta più alta... }
  StartFrom := GetFaceValue(GetMaxCardThatIsntAce.Face);

  for CurrentCardCount := StartFrom downto StartFrom - self.Count+1 do
    { Trovata una faccia sbagliata! }
    if FaceFound[CurrentCardCount] = false then begin
      MinStraightFound := false;
      break;
    end;

  { Se abbiamo trovato una scala minima esci }
  if MinStraightFound then Result := GetMaxCardThatIsntAce.Value

  { Altrimenti procedi ad analizzare le altre scale }
  else begin

    { Azzera l'array }
    for Count := 0 to 13 do
      FaceFound[Count] := false;

    for CurrentCardCount := 0 to self.Count-1 do
      FaceFound[GetFaceValue(GetCard(CurrentCardCount).Face)] := true;

    { Comincia dalla carta più alta... }
    StartFrom := GetFaceValue(MaxCard.Face);

    for CurrentCardCount := StartFrom downto StartFrom - self.Count+1 do
      { Trovata una faccia sbagliata! }
      if FaceFound[CurrentCardCount] = false then exit;
    Result := MaxCard.Value;
  end;
end;

{ E' un full?
Ritorna 0 se non è un full
Il valore di una carta del tris se è un full }
function THand.GetFull: integer;
var
  TrisValue: integer;
begin
  Result := 0;
  TrisValue := GetTris;
  { Se c'è un tris e se c'è una doppia coppia (math rulezzz :) }
  if TrisValue <> 0 then
    if GetTwoPair <> 0 then Result := TrisValue;
end;

{ E' colore?
Ritorna 0 se non è colore
Il valore della carta più alta se è colore }
function THand.GetFlush: integer;
var
  CurrentCardCount: integer;
  CompareSuit: TSuit;
begin
  Result := 0;
  CompareSuit := GetCard(0).Suit;

  for CurrentCardCount := 1 to self.Count-1 do
    if GetCard(CurrentCardCount).Suit <> CompareSuit then exit;
  Result := GetMaxCard.Value;
end;

{ E' un poker?
0 se non è un poker
altrimenti il valore di una delle carte del poker (quindi non moltiplicato per 4) }
function THand.GetPoker: integer;
var
  CurrentCardCount, CompareCardCount, SameFaceFound: integer;
  CurrentCard: TCard;
begin
  for CurrentCardCount := 0 to self.Count-1 do
  begin
    SameFaceFound := 1;
    CurrentCard := GetCard(CurrentCardCount);
    for CompareCardCount := CurrentCardCount+1 to self.Count-1 do
      if CurrentCard.Face = GetCard(CompareCardCount).Face then inc(SameFaceFound);

    if SameFaceFound = 4 then begin
      Result := CurrentCard.Value;
      exit;
    end;
  end;
  Result := 0;
end;

{ E' una scala reale?
Ritorna 0 se non è una scala reale
Il valore della carta più alta se è una scala reale }
function THand.GetRoyalFlush: integer;
var
  StraightValue, CurrentCardCount: integer;
  MaxCard: TCard;
begin
  Result := 0;

  StraightValue := GetStraight;
  if StraightValue <> 0 then begin
    MaxCard := GetMaxCard;
    { Controlla che le carte siano tutte di stesso seme... }
    for CurrentCardCount := 0 to self.Count-1 do
      if GetCard(CurrentCardCount).Suit <> MaxCard.Suit then exit;
    Result := MaxCard.Value;
  end;
end;

{ Funzione per comparare due mani }
function THand.IsGreaterThan(Hand: THand): boolean;
begin
  if Integer(self.Score.ScoreType) > Integer(Hand.Score.ScoreType) then Result := true

  { Se è doppia coppia dobbiamo fare un procedura leggermente diversa...
  confrontiamo i semi dei due punteggi, se corrispondono, controlla la carta singola più alta }
  else if (self.Score.ScoreType = TwoPair) and (Hand.Score.ScoreType = TwoPair) then begin
    if GetFaceValue(self.Score.TwoPairFirstCompareCard.Face) > GetFaceValue(Hand.Score.TwoPairFirstCompareCard.Face) then Result := true
    else if (self.Score.TwoPairFirstCompareCard.Face = Hand.Score.TwoPairFirstCompareCard.Face) and (GetFaceValue(self.Score.TwoPairSecondCompareCard.Face) > GetFaceValue(Hand.Score.TwoPairSecondCompareCard.Face)) then Result := true
    else if (self.Score.TwoPairFirstCompareCard.Face = Hand.Score.TwoPairFirstCompareCard.Face) and (self.Score.TwoPairSecondCompareCard.Face = Hand.Score.TwoPairSecondCompareCard.Face) then Result := (self.Score.TwoPairSingleCardValue > Hand.Score.TwoPairSingleCardValue)
    else Result := false;
  end

  { Altrimenti confronto tra i punti... }
  else if Integer(self.Score.ScoreType) = Integer(Hand.Score.ScoreType) then Result := Integer(self.Score.ScoreValue) > Integer(Hand.Score.ScoreValue)
  else Result := false;
end;

{ Gestore dell'evento click di ogni carta della mano }
procedure THand.CardClick(Sender: TObject);
var
  Card: TCard;
begin
  Card := TCard(Sender);
  
  { Se si clicca su una carta selezionata, deselezionala
  altrimenti, se una carta non è selezionata e
  non sono state selezionate al max. 4 carte, selezionala }
  if Card.Selected then DeselectCard(Card)
  else if not Card.Selected and (GetSelectedCardsCount < 4) then SelectCard(Card);
end;

{ Funzione che ritorna il numero di carte selezionate nella mano }
function THand.GetSelectedCardsCount: integer;
var
  c: integer;
begin
  Result := 0;
  for c := 0 to self.Count-1 do
    if GetCard(c).Selected then inc(Result);
end;

{ Procedura che seleziona una carta}
procedure THand.SelectCard(Card: TCard);
begin
  { Richiama la funzione base }
  SelectCard(Card,true);
end;

{ Procedura overloadata che permette di scatenare un evento alla selezione della carta }
procedure THand.SelectCard(Card: TCard; RaiseEvent: boolean);
begin
  { Sposta la carta solamente se AOwner è stato impostato
  (quindi non è stato richiamato il costruttore senza parametri) e la carta non è
  ancora stata selezionata }

  if Assigned(AOwner) and not Card.Selected then begin
    { In base alla posizione sposta la carta }
    case Position of
      hpTop: Card.MoveTo(Card.Left,Card.Top + CARDMOVEVALUE);
      hpBottom: Card.MoveTo(Card.Left,Card.Top - CARDMOVEVALUE);
      hpLeft: Card.MoveTo(Card.Left + CARDMOVEVALUE,Card.Top);
      hpRight: Card.MoveTo(Card.Left - CARDMOVEVALUE,Card.Top);
    end;
  end;

  Card.Selected := true;
  
  { Refresha }
  FrmParent.Refresh;

  { Scatena l'evento se necessario }
  if RaiseEvent then OnCardSelected(TObject(GetCardIndex(Card)));
end;

{ Procedura overloadata per selezionare una carta }
procedure THand.SelectCard(Index: integer);
begin
  SelectCard(Index,true);
end;

{ Procedura overloadata per selezionare una carta a partire dal suo index e
poter scegliere se scatenare o meno l'evento collegato alla carta }
procedure THand.SelectCard(Index: integer; RaiseEvent: boolean);
begin
  { Se l'index è minore di 0 o maggiore di 4 scatena un eccezzione }
  if (Index < 0) or (Index > 4) then raise Exception.Create('Si è cercato di selezionare la carta con index: ' + IntToStr(Index) + ', ma tale carta non esiste nella mano. Contattare il produttore')
  else begin
    SelectCard(GetCard(Index),RaiseEvent);
  end;
end;


{ Procedura che deseleziona una carta }
procedure THand.DeselectCard(Card: TCard);
begin
  { Richiama la procedura base }
  DeselectCard(Card,true);
end;

{ Procedura overloadata che permette di scatenare un evento alla deselezione della carta }
procedure THand.DeselectCard(Card: TCard; RaiseEvent: boolean);
begin
  { Sposta la carta solamente se AOwner è stato impostato
  (quindi non è stato richiamato il costruttore senza parametri) e la carta non è
  ancora stata deselezionata }

  if Assigned(AOwner) and Card.Selected then begin
    { In base alla posizione sposta la carta }
    case Position of
      hpTop: Card.MoveTo(Card.Left,Card.Top - CARDMOVEVALUE);
      hpBottom: Card.MoveTo(Card.Left,Card.Top + CARDMOVEVALUE);
      hpLeft: Card.MoveTo(Card.Left - CARDMOVEVALUE,Card.Top);
      hpRight: Card.MoveTo(Card.Left + CARDMOVEVALUE,Card.Top);
    end;
  end;

  Card.Selected := false;
 
  { Refresha }
  FrmParent.Refresh;

  { Scatena l'evento se necessario mandando come parametro l'id della carta }
  if RaiseEvent then OnCardDeselected(TObject(GetCardIndex(Card)));
end;

{ Procedura overloadata per deselezionare una carta }
procedure THand.DeselectCard(Index: integer);
begin
  { Richiama la procedura base }
  SelectCard(Index,true);
end;

{ Procedura overloadata per deselezionare una carta a partire dal suo index e
poter scegliere se scatenare o meno l'evento collegato alla carta }
procedure THand.DeselectCard(Index: integer; RaiseEvent: boolean);
begin
  { Se l'index è minore di 0 o maggiore di 4 scatena un eccezzione }
  if (Index < 0) or (Index > 4) then raise Exception.Create('Si è cercato di deselezionare la carta con index: ' + IntToStr(Index) + ', ma tale carta non esiste nella mano. Contattare il produttore')
  else begin
    DeselectCard(GetCard(Index),RaiseEvent);
  end;
end;


{ Procedura per selezionare una carta senza muovere graficamente gli oggetti }
procedure THand.SelectCardWithoutGraphicsOp(Index: integer);
begin
  { Se l'index è minore di 0 o maggiore di 4 scatena un eccezzione }
  if (Index < 0) or (Index > 4) then raise Exception.Create('Si è cercato di selezionare la carta con index: ' + IntToStr(Index) + ', ma tale carta non esiste nella mano. Contattare il produttore')
  else begin
    GetCard(Index).Selected := true;
  end;
end;

{ Procedura per deselezionare una carta senza muovere graficamente gli oggetti }
procedure THand.DeselectCardWithoutGraphicsOp(Index: integer);
begin
  { Se l'index è minore di 0 o maggiore di 4 scatena un eccezzione }
  if (Index < 0) or (Index > 4) then raise Exception.Create('Si è cercato di deselezionare la carta con index: ' + IntToStr(Index) + ', ma tale carta non esiste nella mano. Contattare il produttore')
  else begin
    GetCard(Index).Selected := false;
  end;
end;

{ Procedura per deselezionare tutte le carte }
procedure THand.DeselectAllCards;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    if GetCard(C).Selected then DeselectCard(C,false);
end;


{ Procedura per cambiare le carte della mano }
procedure THand.ChangeCards(Deck: TDeck);
var
  c: integer;
begin
  m_CardsChanged := 0;

  for c := 0 to self.Count-1 do begin
    if GetCard(c).Selected then begin
      ChangeCard(c,Deck.PopCard);
      inc(m_CardsChanged);
    end;
  end;
end;

{ Procedura per cambiare una carta }
procedure THand.ChangeCard(Index: integer; NewCard: TCard);
begin
  RemoveCard(Index);
  { Imposta il gestore d'evento }
  NewCard.OnClick := CardClick;
  self.Insert(Index,NewCard);
end;

{ Procedura per rimuovere una carta }
procedure THand.RemoveCard(Index: integer);
var
  Card: TCard;
begin
  Card := GetCard(Index);
  self.Delete(Index);
  Card.Destroy;
end;

{ Procedura per riempire una mano di carte }
procedure THand.FillHand(Deck: TDeck);
var
  C: integer;
begin
  if self.Count > 0 then raise Exception.Create('La procedura THand.FillHand è stata richiamata quando c''erano già delle carte nella mano. Contattare il produttore.');

  for C := 0 to 4 do
    PushCard(Deck.PopCard);
end;

{ Funzione per controllare che la mano sia vuota }
function THand.IsEmpty: boolean;
begin
  if self.Count <= 0 then Result := true
  else Result := false;
end;

{ Procedura per nascondere la mano }
procedure THand.Hide;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetCard(C).Hide;
end;

{ Funzione che ritorna l'index (rispetto alla lista) della carta }
function THand.GetCardIndex(Card: TCard): integer;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
  begin
    if GetCard(C) = Card then begin
      Result := C;
      exit;
    end;
  end;

  { Se non è stato trovato nessun index valido, scatena un eccezzione }
  raise Exception.Create('Non è stato possibile trovare una carta nella mano all''interno della procedura THand.GetCardIndex. Contattare il produttore');
end;

{ Funzione per vedere se nella mano è presente una coppia di Jack }
function THand.HasAtLeastAPairOf(Face: TFace): boolean;
var
  C, D: integer;
  CmpFace: TFace;
  Card: TCard;
begin
  for C := 0 to self.Count-2 do
  begin
    Card := GetCard(C);
    for D := C+1 to self.Count-1 do
    begin
      if (Card.Face = GetCard(D).Face) and (GetFaceValue(Card.Face) >= GetFaceValue(Face)) then begin
        Result := true;
        exit;
      end;
    end;
  end;

  Result := false;
end;

{ Funzione per vedere se nella mano è presente almeno un tentativo di
scala reale }
function THand.HasAPossibleRoyalFlush(MinFace: TFace): boolean;
var
  C: integer;
  Face: TFace;
  Card: TCard;
  Found: array [0 .. 15] of boolean;
  ContinuousFound: integer;
begin
  { Azzera l'array }
  for C := 0 to 15 do
    Found[C] := false;

  { Lo imposta }
  for C := 0 to self.Count-1 do
  begin
    Card := GetCard(C);
    Found[GetFaceValue(Card.Face)] := true;

    { Se è un asso, vale anche come carta in fondo alla scala }
    if Card.Face = Ace then Found[GetFaceValue(TFace(Integer(MinFace)-1))] := true;
  end;

  { Se riusciamo a trovare almeno 4 carte in fila, il tentativo è valido }
  ContinuousFound := 0;

  for C := 0 to 15 do
  begin
    if not Found[C] then ContinuousFound := 0
    else inc(ContinuousFound);

    if ContinuousFound = 4 then begin
      Result := true;
      exit;
    end;
  end;

  { Niente da fare, non è un tentativo valido }
  Result := false;
end;

{ Funzione per vedere se la mano del giocatore puo' essere aperta }
function THand.CanOpen(MinFace: TFace; MinPairFaceNeeded: TFace): boolean;
begin
  if HasAtLeastAPairOf(MinPairFaceNeeded) or HasAPossibleRoyalFlush(MinFace) or (Integer(self.Score.ScoreType) >= Integer(TwoPair)) then Result := true
  else Result := false;
end;

{ Procedura per impostare se un giocatore puo' selezionare le carte dalla mano }
procedure THand.SetCanSelect(Value: boolean);
var
  C: integer;
begin
  m_CanSelect := Value;
  if Position = hpBottom then begin
    if CanSelect then begin
      for C := 0 to self.Count-1 do begin
        GetCard(C).OnClick := CardClick;
        //GetCard(C).Cursor := crHandPoint;
      end;
    end
    else begin
      for C := 0 to self.Count-1 do
      begin
        GetCard(C).OnClick := CardClickDoNothing;
        //GetCard(C).Cursor := crArrow;
      end;
    end;
  end;
end;

{ Gestore d'evento per non fare nulla se viene cliccata una carta }
procedure THand.CardClickDoNothing(Sender: TObject);
begin

end;

{ Funzione che restituisce true se il punteggio passato come argomento è minore
del punteggio della mano }
function THand.ScoreGreaterThan(HandScore: THandScore): boolean;
begin
  Result := Integer(self.Score.ScoreType) > Integer(HandScore);
end; 

{ Procedura per resettare il punteggio di una mano }
procedure THand.ResetScore;
begin
  //if Assigned(m_Score) then
  m_Score := nil;
end;


procedure THand.Clear;
begin
  self.Hide;
  inherited Clear;
end;



end.
