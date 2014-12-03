unit Player;

interface

uses Forms, Classes, StdCtrls,
  Hand, Money, Constants;

{ Classe TPlayer }
type
  TPlayer = class
  private
    FrmParent: TForm; { riferimento al form principale }
    AOwner: TComponent; { riferimento al componente che ha creato il giocatore }

    NickLabel: TLabel; { Oggetto TLabel che contiene il nickname }
    m_Nickname: string;
    m_Money: TMoney;
    m_Hand: THand;
    m_Id: integer;
    Position: THandPosition;

    function GetMoney: TMoney;
    function GetHand: THand;
    function GetId: integer;
    function GetNickname: string;
    procedure ShowNickname;
    function GetSpacedNickname: string;
  public
    constructor Create(FrmParent: TForm; AOwner: TComponent; Nickname: string; Money: integer; Position: THandPosition; Id: integer);

    procedure Hide;
    function IsLocalPlayer: boolean;


    property Money: TMoney read GetMoney;
    property Hand: THand read GetHand;
    property Id: integer read GetId;
    property Nickname: string read GetNickname;
  end;

implementation

{ Implementazioni classe TPlayer }
constructor TPlayer.Create(FrmParent: TForm; AOwner: TComponent; Nickname: string; Money: integer; Position: THandPosition; Id: integer);
var
  mPosition: TMoneyPosition;
begin
  self.FrmParent := FrmParent;
  self.AOwner := AOwner;
  self.m_Nickname := Nickname;
  self.Position := Position;
  self.m_Id := Id;

  { Costruisce la mano }
  self.m_Hand := THand.Create(AOwner,FrmParent,Position);

  { Inserisce il nickname }
  ShowNickname;

  { Costruisce la classe Money per il giocatore
  in base alla posizione del giocatore, setta la posizione del denaro }
  case Position of
    hpBottom: mPosition := mpLeftBottom;
    hpTop: mPosition := mpRightTop;
    hpLeft: mPosition := mpLeftTop;
    hpRight: mPosition := mpRightBottom;
  end;
  m_Money := TMoney.Create(AOwner, FrmParent, mPosition, msSmall,Money);
end;

{ Ritorna l'istanza della classe TMoney associata al giocatore }
function TPlayer.GetMoney: TMoney;
begin
  Result := m_Money;
end;

{ Ritorna la mano del giocatore }
function TPlayer.GetHand: THand;
begin
  Result := m_Hand;
end;

{ Funzione che mostra il nickname in base alla posizione }
procedure TPlayer.ShowNickname;
var
  X, Y, Width, Height, Nicklen: integer;
begin
  X := 0;
  Y := 0;
  Width := 0;
  Height := 0;
  Nicklen := Length(Nickname);
  
  { Inserisce una label a seconda della posizione }
  case Position of
    hpTop:
    begin
      Width := Nicklen * NICKPX4ONECHAR;
      Height := NICKHEIGHT;
      X := (FrmParent.ClientWidth div 2) - (Width div 2);
      Y := NICKBORDERSPACING; 
    end;
    hpBottom:
    begin
      Width := Nicklen * NICKPX4ONECHAR;
      Height := NICKHEIGHT;
      X := (FrmParent.ClientWidth div 2) - (Width div 2);
      Y := FrmParent.ClientHeight - NICKBORDERSPACING - STATUSBARHEIGHT - Height;
    end;
    hpRight:
    begin
      Width := NICKPX4ONECHAR;
      Height := Nicklen * NICKHEIGHT;
      X := FrmParent.ClientWidth - NICKBORDERSPACING - Width-3; { -3 per aggiustare... }
      Y := ((FrmParent.ClientHeight - STATUSBARHEIGHT) div 2) - (Height div 2);
    end;
    hpLeft:
    begin
      Width := NICKPX4ONECHAR;
      Height := Nicklen * NICKHEIGHT;
      X := NICKBORDERSPACING+3; { +3 per aggiustare... }
      Y := ((FrmParent.ClientHeight - STATUSBARHEIGHT) div 2) - (Height div 2);
    end;

  end;

  NickLabel := TLabel.Create(AOwner);
  NickLabel.Parent := FrmParent;
  NickLabel.Left := X;
  NickLabel.Top := Y;
  NickLabel.Width := Width;
  NickLabel.Height := Height;
  NickLabel.AutoSize := false;
  NickLabel.WordWrap := true;
  NickLabel.Alignment := taCenter;
  { Se è a destra o a sinistra, il nickname dev'essere composto da una lettera e da uno spazio (x il word wrap) }
  if (Position = hpLeft) or (Position = hpRight) then NickLabel.Caption := GetSpacedNickname
  else NickLabel.Caption := Nickname;
end;

{ Funzione per mostrare il nickname con gli spazi }
function TPlayer.GetSpacedNickname: string;
var
  c: integer;
begin
  for c := 1 to Length(Nickname) do
    Result := Result + Nickname[c] + ' ';
end;

{ Funzione per la proprietà Id }
function TPlayer.GetId: integer;
begin
  Result := m_Id;
end;

{ Funzione per la proprietà Nickname }
function TPlayer.GetNickname: string;
begin
  Result := m_Nickname;
end;

procedure TPlayer.Hide;
begin
  { TODO: non si possono distruggere gli oggetti, il proprietario è il form principale
  distruggendoli da qua si causa un Access Violation Exception }

  if not (NickLabel = nil) then NickLabel.Hide;
  if not (m_Money = nil) then m_Money.Hide;
  if not (m_Hand = nil) then m_Hand.Hide;
end;

{ Se la sua posizione è hpBottom allora si tratta del giocatore locale }
function TPlayer.IsLocalPlayer: boolean;
begin
  if Position = hpBottom then Result := true
  else Result := false;
end;


end.
 