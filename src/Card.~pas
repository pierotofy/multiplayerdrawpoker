unit Card;

interface

uses Windows, SysUtils, Graphics, ExtCtrls, Classes, Forms,
  Constants;

var
  CDllWidth, CDllHeight: integer;


{ Dichiarazioni esterne }
function cdtAnimate(DC: HDC; Card,X,Y,Etat: integer):Integer; stdcall;
function cdtDraw(DC: HDC; X,Y,Card,Typ: integer; Color: TColor): integer; stdcall;
function cdtDrawExt(DC: HDC; X,Y,CardWidth,CardHeight,Card,Typ: integer; Color: TColor): integer; stdcall;
function cdtInit(var Width,Height: integer): integer; stdcall;
function cdtTerm: integer; stdcall;

{ Dichiarazioni interne }
procedure InitCardsDotDll;
procedure TermCardsDotDll;


{ Classe TCard }
type
  TCard = class(TImage)
  private
    CardFace: TFace;
    CardSuit: TSuit;
    CardCovered: boolean;
    CardSelected: boolean;

    RepaintCount: integer;

    FrmParent: TForm; { Riferimento al form principale }
    function GetCardValue: integer;
    procedure CreateStdCard(AOwner: TComponent; FrmParent: TForm; CardFace: TFace; CardSuit: TSuit);
    procedure FillImageCanvas;
    function GetFace: TFace;
    function GetSuit: TSuit;
    function GetValue: integer;
    function GetSelected: boolean;
    procedure SetSelected(Selected: boolean);
  public
    constructor Create(AOwner: TComponent; FrmParent: TForm;  CardFace: TFace; CardSuit: TSuit); overload;
    constructor Create(AOwner: TComponent; FrmParent: TForm;  CardFace: TFace; CardSuit: TSuit; CardCovered: boolean); overload;

    procedure Draw(X,Y: integer); overload;
    procedure Draw(X,Y: integer; Covered: boolean); overload;
    procedure MoveTo(X,Y: integer);
    procedure ReplaceWith(Card: TCard); overload;
    procedure ReplaceWith(Face: TFace; Suit: TSuit; DoIFillTheImageCanvas: boolean = true); overload;
    procedure CoverCard;
    procedure ShowCard;

    property Face: TFace read GetFace;
    property Suit: TSuit read GetSuit;
    property Value: integer read GetValue;
    property Selected: boolean read GetSelected write SetSelected;
  end;

implementation

{ Implementazione funzioni esterne }

function cdtAnimate(DC: HDC; Card,X,Y,Etat: integer):Integer; stdcall; external CARDSDLL;
function cdtDraw(DC: HDC; X,Y,Card,Typ: integer; Color: TColor): integer; stdcall; external CARDSDLL;
function cdtDrawExt(DC: HDC; X,Y,CardWidth,CardHeight,Card,Typ: integer; Color: TColor): integer; stdcall; external CARDSDLL;
function cdtInit(var Width,Height: integer): integer; stdcall; external CARDSDLL;
function cdtTerm: integer; stdcall; external CARDSDLL;

{ Implementazione funzioni interne }
procedure InitCardsDotDll;
begin
  cdtInit(CDllWidth, CDllHeight);
end;

procedure TermCardsDotDll;
begin
  cdtTerm;
end;

{ Implementazioni metodi classe TCard }

{ Costruttori }
constructor TCard.Create(AOwner: TComponent; FrmParent: TForm; CardFace: TFace; CardSuit: TSuit);
begin
  CreateStdCard(AOwner,FrmParent,CardFace,CardSuit);
end;
constructor TCard.Create(AOwner: TComponent; FrmParent: TForm;  CardFace: TFace; CardSuit: TSuit; CardCovered: boolean);
begin
  CreateStdCard(AOwner,FrmParent,CardFace,CardSuit);
  self.CardCovered := CardCovered;
end;

{ Salva le variabili passate al costruttore
 richiama il costruttore base }
procedure TCard.CreateStdCard(AOwner: TComponent; FrmParent: TForm; CardFace: TFace; CardSuit: TSuit);
begin
  inherited Create(AOwner);

  self.FrmParent := FrmParent;
  self.CardFace := CardFace;
  self.CardSuit := CardSuit;
  { Imposta a false la proprietà selected }
  Selected := false;

  RepaintCount := 0;
end;

{ Stampa la carta sull'oggetto Parent }
procedure TCard.Draw(X,Y: integer);
begin
  FillImageCanvas;
  self.Left := X;
  self.Top := Y;
  self.Parent := FrmParent;
end;

{ Stampa la carta sull'oggetto Parent (versione overloadata) }
procedure TCard.Draw(X,Y: integer; Covered: boolean);
begin
  self.CardCovered := Covered;
  Draw(X,Y);
end;

{ Muove la carta per lo schermo }
procedure TCard.MoveTo(X,Y: integer);
begin
  self.Left := X;
  self.Top := Y;
end;

{ Funzione per ricavare il valore intero della carta (per la DLL) }
function TCard.GetCardValue: integer;
begin
  Result := Integer(CardFace) * 4 + Integer(CardSuit);
end;

{ Procedura per "dipingere" la carta sul canvas dell'oggetto TImage }
procedure TCard.FillImageCanvas;
var
  Pen: TPen;
  RepaintCount: integer;
begin
  FrmParent.Canvas.Lock;
  self.Canvas.Lock;

  self.Width := CDllWidth;
  self.Height := CDllHeight;

   { Seleziona la penna e la imposta a verde }
  Pen := TPen.Create;
  Pen.Color := clGreen;
  Pen.Width := 5;

  { Applica la penna al canvas }
  self.Canvas.Pen := Pen;

  { Disegna un rettangolo smussato }
  self.Canvas.RoundRect(0,0,self.Width,self.Height,10,10);

  { Ridisegna due volte la grafica perchè ho rinscontrato degli errori di disegno
  meglio prevenire che curare no? :)

  { Carta coperta? Disogna il retro
  altrimenti disegna la carta }
  if CardCovered then cdtDraw(self.Canvas.Handle,0,0,Integer(Fish1),BACKGROUNDCARD,clWhite)
  else cdtDraw(self.Canvas.Handle,0,0,GetCardValue,FRONTCARD,clWhite);

  self.Canvas.UnLock;
  FrmParent.Canvas.Unlock;
end;

{ Procedura per coprire una carta senza ridipingerla sul form }
procedure TCard.CoverCard;
begin
  CardCovered := true;
  FillImageCanvas;
end;

{ Procedura per scoprire una carta senza ridipingerla sul form }
procedure TCard.ShowCard;
begin
  CardCovered := false;
  FillImageCanvas;
end;

{ Funzione che ritorna la faccia della carta.. }
function TCard.GetFace: TFace;
begin
  Result := CardFace;
end;

{ Funzione che ritorna il seme della carta }
function TCard.GetSuit: TSuit;
begin
  Result := CardSuit;
end;

{ Funzione che ritorna il valore della carta (piccolo algoritmo matematico) }
function TCard.GetValue: integer;
begin
  Result := GetFaceValue(Face) * FACECOUNT + GetSuitValue(Suit);
end;

{ Metodi per la proprietà Selected }
function TCard.GetSelected: boolean;
begin
  Result := CardSelected;
end;
procedure TCard.SetSelected(Selected: boolean);
begin
  CardSelected := Selected;
end;

{ Procedura per sostituire la carta corrente con un altra carta }
procedure TCard.ReplaceWith(Card: TCard);
begin
  self.CardFace := Card.Face;
  self.CardSuit := Card.Suit;
  self.CardSelected := Card.Selected;
  FillImageCanvas;
end;

{ Procedura per sostituire la carta corrente con un altra carta,
versione overloadata che richiede solamente il seme e il numero nuovo }
procedure TCard.ReplaceWith(Face: TFace; Suit: TSuit; DoIFillTheImageCanvas: boolean = true);
begin
  self.CardFace := Face;
  self.CardSuit := Suit;
  if DoIFillTheImageCanvas then FillImageCanvas;
end;

end.

