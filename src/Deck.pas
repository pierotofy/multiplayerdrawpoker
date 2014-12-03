unit Deck;

interface

uses Forms, Classes, Math, SysUtils,
  Card, Constants;

{ Classe TDeck (mazzo) }
type
  TDeck = class(TList)
  private
    FrmParent: TForm; { riferimento al form principale }
    AOwner: TComponent; { riferimento al componente che ha creato il mazzo }
    Players: integer;
    m_StartFace: TFace; { Prima carta del mazzo a seconda dei giocatori }

    procedure PushCard(Card: TCard);
    function ExtractCard(Index: integer): TCard;
    procedure FillDeck;
    procedure ShuffleDeck;
    procedure CutDeck;    
  public
    constructor Create(AOwner: TComponent; FrmParent: TForm; Players: integer);
    function PopCard: TCard;
    function HasCards: boolean;

    property StartFace: TFace read m_StartFace;
  end;

implementation

{ Implementazioni classe TDeck }
constructor TDeck.Create(AOwner: TComponent; FrmParent: TForm; Players: integer);
var
  Count: integer;
begin
  inherited Create; { Costruttore della classe genitore TList }

  self.AOwner := AOwner;
  self.FrmParent := FrmParent;
  self.Players := Players;

  { Riempie il mazzo }
  FillDeck;

  { Lo mescola }
  for Count := 0 to SHUFFLEREPEAT do ShuffleDeck;

  { E lo taglia }
  CutDeck;
end;

{ Inserisce una carta in cima alla lista }
procedure TDeck.PushCard(Card: TCard);
begin
  self.Add(Card);
end;

{ Prende una carta dalla cima della lista }
function TDeck.PopCard: TCard;
begin
  Result := self.Last;
  self.Delete(self.Count-1);
end;

{ Prende una carta dal mezzo della lista }
function TDeck.ExtractCard(Index: integer): TCard;
begin
  Result := self.Get(Index);
  self.Delete(Index);
end;

{ Riempie il mazzo di carte }
procedure TDeck.FillDeck;
var
  Face: TFace;
  Suit: TSuit;
begin
  { Svuota il mazzo e lo ricompone (ordinato) }
  self.Clear;
  SetCurrentPlayingPlayers(Players);
  m_StartFace := GetMinCardFace;
  
  for Suit := Clubs to Spades do
  begin
    { Aggiunge tutte le carte }
    for Face := StartFace to King do
      PushCard(TCard.Create(AOwner,FrmParent,Face,Suit));
    { E l'asso }
    PushCard(TCard.Create(AOwner,FrmParent,Ace,Suit));
  end;

end;

{ Procedura per tagliare il mazzo }
procedure TDeck.CutDeck;
var
  C, RndNum: integer;
  Card: TCard;
begin
  { Genera un numero casuale }
  RndNum := RandomRange(0,self.Count);

  for C := self.Count-1 downto RndNum do
  begin
    { Estrae tutti i numeri sotto il numero generato e li mette in cima }
    Card := ExtractCard(C);
    PushCard(Card);
  end;
end;


{ Procedura per mescolare il mazzo }
procedure TDeck.ShuffleDeck;
var
  Count, Items, RndNum: integer;
  Card: TCard;
  Hours, Mins, Secs, MilliSecs : Word;
begin
  Items := self.Count-1;

  { Setta il seme per la generazione di numeri casuali
  in base al numero di millisecondi dell'ora attuale }
  DecodeTime(now, Hours, Mins, Secs, MilliSecs);
  RandSeed := MilliSecs;

  for Count := 0 to Items do
  begin
    { Genera un numero casuale }
    RndNum := RandomRange(0,Items+1);

    { Estrae una carta dal mazzo }
    Card := ExtractCard(RndNum);
    
    { E la rimette in cima }
    PushCard(Card);
  end;
end;

{ Funzione per vedere se un mazzo possiede ancora carte.. }
function TDeck.HasCards: boolean;
begin
  if self.Count = 0 then Result := false
  else Result := true;
end;

end.
