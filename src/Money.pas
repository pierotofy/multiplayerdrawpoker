unit Money;

interface

uses Forms, Classes, StdCtrls, ExtCtrls, Graphics, SysUtils,
  Constants;

{ Classe TMoney }
type
  TMoney = class(TPanel)
  private
    FrmParent: TForm; { riferimento al form principale }
    AOwner: TComponent; { riferimento al componente che ha creato la classe }
    ComponentsInitialized: boolean;

    Position: TMoneyPosition;
    Size: TMoneySize;
    m_Money: integer;
    MoneyImage: TImage;
    MoneyLabel: TLabel;
    
    MoneyTable: TImage;

    procedure SetMoney(Money: integer);
    function GetMoney: integer;

  public
    constructor Create(AOwner: TComponent; FrmParent: TForm; Position: TMoneyPosition; Size: TMoneySize); overload;
    constructor Create(AOwner: TComponent; FrmParent: TForm; Position: TMoneyPosition; Size: TMoneySize; InitialMoney: integer); overload;

    procedure InitGraphicComponents;
    procedure ShowMoneyToLabel;

    procedure Show;
    procedure Hide;
    
    property Value: integer read GetMoney write SetMoney;
  end;

implementation

{ Implementazione classe TMoney }
constructor TMoney.Create(AOwner: TComponent; FrmParent: TForm; Position: TMoneyPosition; Size: TMoneySize);
begin
  inherited Create(AOwner);
  
  self.AOwner := AOwner;
  self.FrmParent := FrmParent;
  self.Position := Position;
  self.Size := Size;
  Value := 0;
  ComponentsInitialized := false;

  InitGraphicComponents;
  ShowMoneyToLabel;
end;
constructor TMoney.Create(AOwner: TComponent; FrmParent: TForm; Position: TMoneyPosition; Size: TMoneySize; InitialMoney: integer);
begin
  { Richiama il costruttore base }
  Create(AOwner,FrmParent,Position,Size);

  { E salva il numero inziale di monete }
  Value := InitialMoney;

  ShowMoneyToLabel;
end;

{ Setta il numero di monete }
procedure TMoney.SetMoney(Money: integer);
begin    
  self.m_Money := Money;
  ShowMoneyToLabel;
end;

{ Prende il numero di monete }
function TMoney.GetMoney: integer;
begin
  Result := m_Money;
end;

{ Mostra sul form la classe TMoney }
procedure TMoney.Show;
begin
  MoneyImage.Visible := true;
  MoneyLabel.Visible := true;
end;

{ Nasconde dal form la classe TMoney }
procedure TMoney.Hide;
begin
  MoneyImage.Visible := false;
  MoneyLabel.Visible := false;
end;

{ Crea gli oggetti TImage e TLabel e li visualizza sul form }
procedure TMoney.InitGraphicComponents;
var
  Font: TFont;
  Pen: TPen;

begin
  { Se sono già stati inizializzati, esci }
  if ComponentsInitialized then exit;

  { Inizializza il Font }
  Font := TFont.Create;
  Font.Name := 'Comic Sans MS';

  { Inizializza l'immagine }
  MoneyImage := TImage.Create(AOwner);
  with MoneyImage do
  begin
    Parent := FrmParent;
    Picture.Bitmap.LoadFromResourceName(hInstance,'MONEY');
    AutoSize := true;
  end;

  { E la label }
  MoneyLabel := TLabel.Create(AOwner);
  MoneyLabel.Parent := FrmParent;
  MoneyLabel.AutoSize := false;

  { Se le dimensioni sono piccole... }
  if Size = msSmall then begin
    with MoneyImage do
    begin
      AutoSize := false;
      Stretch := true;
      Width := Width - (Width div 3);
      Height := Height - (Width div 3);
    end;
  
    MoneyLabel.Height := LABELNORMALHEIGHT - (LABELNORMALHEIGHT div 3);
    MoneyLabel.Width := LABELNORMALWIDTH - (LABELNORMALWIDTH div 3);
    Font.Size := 8;

  end else begin
  { Altrimenti, se sono normali... }
    MoneyLabel.Height := LABELNORMALHEIGHT;
    MoneyLabel.Width := LABELNORMALWIDTH;
    Font.Size := 12;
  end;

  { Muove l'immagine in base alla posizione  }
  with MoneyImage do
  begin
    case Position of
      mpCenter:
      begin
        Left := (FrmParent.ClientWidth div 2) - (Width div 2);
        Top := (FrmParent.ClientHeight div 2) - (Height div 2) - STATUSBARHEIGHT;

        { Attenzione: se è centrale, costruisce anche il tavolo }
        MoneyTable := TImage.Create(AOwner);
        with MoneyTable do
        begin
          Parent := FrmParent;
          Width := MoneyImage.Width + TABLEEXTRASPACING + TABLEEXTRAWIDTH;
          Height := MoneyImage.Height + MoneyLabel.Height + LABELSPACING + TABLEEXTRASPACING;
          Left := (FrmParent.ClientWidth div 2) - (Width div 2) + TABLELEFTADJUSTVALUE;
          Top := (FrmParent.ClientHeight div 2) - (Height div 2) - STATUSBARHEIGHT + TABLETOPADJUSTVALUE;

          { Ora dobbiamo disegnare il tavolo, inizializza la penna... }
          Pen := TPen.Create;
          Pen.Color := clBlack;

          Canvas.RoundRect(0,0,Width-1,Height-1,10,10);
          Transparent := true;
          BringToFront;
        end;
      end;
      mpLeftBottom:
      begin
        Left := MONEYBORDERSPACING + MONEYEXTRAVALUE;
        Top := FrmParent.ClientHeight - MONEYBORDERSPACING - STATUSBARHEIGHT - Height - MoneyLabel.Height
      end;
      mpLeftTop:
      begin
        Left := MONEYBORDERSPACING;
        Top := MONEYBORDERSPACING + MONEYEXTRAVALUE;
      end;
      mpRightTop:
      begin
        Left := FrmParent.ClientWidth - MONEYBORDERSPACING - Width - MONEYEXTRAVALUE;
        Top := MONEYBORDERSPACING;
      end;
      mpRightBottom:
      begin
        Left := FrmParent.ClientWidth - MONEYBORDERSPACING - Width;
        Top := FrmParent.ClientHeight - MONEYBORDERSPACING - STATUSBARHEIGHT - Height - MoneyLabel.Height - MONEYEXTRAVALUE;
      end;
    end;
  end;


  MoneyLabel.Alignment := taCenter;
  { Piccolo algoritmo per centrare la label rispetto all'immagine }
  MoneyLabel.Left := MoneyImage.Left + (MoneyImage.Width div 2) - (MoneyLabel.Width div 2);
  MoneyLabel.Top := MoneyImage.Top + LABELSPACING + MoneyImage.Height;

  { Imposta il font }
  MoneyLabel.Font := Font;

  { Imposta la variabile di controllo a true }
  ComponentsInitialized := true;

  { Li porta in 1° piano }
  //MoneyImage.BringToFront;
  //MoneyLabel.BringToFront;
end;

procedure TMoney.ShowMoneyToLabel;
begin
  MoneyLabel.Caption := IntToStr(m_Money) + ' $';
  //if m_Money < 0 then MoneyLabel.Color := clRed
  //else MoneyLabel.Color := clBlack;
end;

end.
