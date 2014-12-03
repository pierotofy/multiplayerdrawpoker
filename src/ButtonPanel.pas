unit ButtonPanel;

interface

uses Forms, SysUtils, Classes, StdCtrls, Graphics, Windows,
  Constants, Languages;

type
  TButtonPanel = class(TGroupBox)
  private
    { Vars }
    AOwner: TComponent; { Riferimento al form principale }
    m_Mode: TPanelMode;
    BetMode: TPanelMode;

    { Variabile per tenere lo stato del controllo di rilancio }
    RelaunchButtonEnabled: boolean;


    { Bottoni }
    m_ButtonStartGame: TButton;
    m_ButtonChangeCards: TButton;
    m_ButtonBet: TButton;
    m_ButtonPlay: TButton;
    m_ButtonPass: TButton;
    m_ButtonOpen: TButton;
    m_ButtonRelaunch: TButton;
    m_ButtonSee: TButton;
    m_ButtonWords: TButton;
    m_ButtonCip: TButton;
    m_ButtonBeginTurn: TButton;
    m_ButtonShowCards: TButton;
    m_ButtonDontShowCards: TButton;

    { Controlli della modalità pmBet }
    m_EditBet: TEdit;
    LabelBet: TLabel;

    { Variabili per la modalità pmBet }
    m_BetMinValue, m_BetMaxValue: integer;
    m_BetDescription: string;

    { Evento scatenato dopo la verifica dei dati inseriti dall'utente
    nella fase di puntata }
    m_OnBetValueAssigned: TNotifyEvent;

    { Gestore d'evento per il pulsante Bet }
    procedure ButtonBet_Click(Sender: TObject);

    { Gestire d'evento scatenato alla pressione di un tasto sul bottone cambio carte... }
    procedure ButtonChangeCards_KeyPress(Sender: TObject; var Key: Char);

    { Gestore d'evento scatenato alla pressione di un tasto nella casella di testo
    per puntare }
    procedure EditBet_KeyPress(Sender: TObject; var Key: Char);

    procedure InitGraphicsComponents;
    procedure PaintButtons;
    procedure HideAllButtons;
    procedure ResizeButton(Button: TButton);
    procedure ApplyStyle(Button: TButton);


    procedure SetMode(Mode: TPanelMode);
    function GetMode: TPanelMode;

    function GetButtonStartGame: TButton;
    function GetButtonChangeCards: TButton;
    function GetButtonBet: TButton;
    function GetEditBet: TEdit;
    function GetButtonPlay: TButton;
    function GetButtonPass: TButton;
    function GetButtonOpen: TButton;
    function GetButtonRelaunch: TButton;
    function GetButtonSee: TButton;
    function GetButtonWords: TButton;
    function GetButtonCip: TButton;
    function GetButtonBeginTurn: TButton;
    function GetButtonShowCards: TButton;
    function GetButtonDontShowCards: TButton;
  public
    OnCardChoicePressed: TNotifyEvent;

    constructor Create(AOwner: TComponent; Mode: TPanelMode);
    procedure EnableButtons(Enable: boolean);
    procedure EnableRelaunchButton(Enabled: boolean);

    property Mode: TPanelMode read GetMode write SetMode;
    property ButtonStartGame: TButton read GetButtonStartGame;
    property ButtonChangeCards: TButton read GetButtonChangeCards;
    property ButtonRelaunch: TButton read GetButtonRelaunch;
    property ButtonSee: TButton read GetButtonSee;
    property ButtonBeginTurn: TButton read GetButtonBeginTurn;
    property ButtonWords: TButton read GetButtonWords;
    property ButtonCip: TButton read GetButtonCip;
    property ButtonShowCards: TButton read GetButtonShowCards;
    property ButtonDontShowCards: TButton read GetButtonDontShowCards;
    property ButtonBet: TButton read GetButtonBet;
    property EditBet: TEdit read GetEditBet;
    property ButtonPlay: TButton read GetButtonPlay;
    property ButtonPass: TButton read GetButtonPass;
    property ButtonOpen: TButton read GetButtonOpen;
    property BetMinValue: integer read m_BetMaxValue write m_BetMaxValue;
    property BetMaxValue: integer read m_BetMinValue write m_BetMinValue;
    property BetDescription: string read m_BetDescription write m_BetDescription;
    property OnBetValueAssigned: TNotifyEvent read m_OnBetValueAssigned write m_OnBetValueAssigned;
  end;

type
  TBetResult = class
  public
    Value: integer;
    Mode: TPanelMode;
  end;

implementation

{ Implementazione classe TButtonPanel }
constructor TButtonPanel.Create(AOwner: TComponent; Mode: TPanelMode);
begin
  inherited Create(AOwner);

  self.AOwner := AOwner;
  m_Mode := Mode;

  { Imposta i valori di default alle variabili }
  BetMinValue := 1;
  BetMaxValue := 1000;
  BetDescription := 'Descrizione assente';

  RelaunchButtonEnabled := true;

  InitGraphicsComponents;
  PaintButtons;
end;

procedure TButtonPanel.InitGraphicsComponents;
var
  FrmParent: TForm;
  Font: TFont;
begin
  { Costruisce il contenitore }
  FrmParent := TForm(AOwner);
  self.Parent := FrmParent;
  self.Width := 145;
  self.Height := 70; //57;
  self.Top := FrmParent.ClientHeight - self.Height - STATUSBARHEIGHT - BUTTONPANELBORDERSPACING;
  self.Left := FrmParent.ClientWidth - self.Width - BUTTONPANELBORDERSPACING;

  { Imposta il font }
  Font := TFont.Create;
  Font.Color := clYellow;
  self.Font := Font;

  { Costruisce tutti i bottoni... }

  { ButtonStartGame }
  m_ButtonStartGame := TButton.Create(self);
  ButtonStartGame.Caption := 'Avvia';
  ButtonStartGame.Parent := self;
  ApplyStyle(ButtonStartGame);
  ResizeButton(ButtonStartGame);
  ButtonStartGame.Left := self.ClientWidth div 2 - ButtonStartGame.Width div 2;
  ButtonStartGame.Top := self.ClientHeight div 2 - ButtonStartGame.Height div 2 + BUTTONTOPADJUSTVALUE;

  { ChangeCards }
  m_ButtonChangeCards := TButton.Create(self);
  ButtonChangeCards.Caption := 'Cambia';
  ButtonChangeCards.Parent := self;
  ApplyStyle(ButtonChangeCards);
  ResizeButton(ButtonChangeCards);
  ButtonChangeCards.Left := self.ClientWidth div 2 - ButtonChangeCards.Width div 2;
  ButtonChangeCards.Top := self.ClientHeight div 2 - ButtonChangeCards.Height div 2 + BUTTONTOPADJUSTVALUE;
  ButtonChangeCards.OnKeyPress := ButtonChangeCards_KeyPress;

  { PlayPassRelaunch }
  m_ButtonPlay := TButton.Create(self);
  ButtonPlay.Caption := 'Gioco';
  ButtonPlay.Parent := self;
  ApplyStyle(ButtonPlay);
  ResizeButton(ButtonPlay);
  ButtonPlay.Left := self.ClientWidth div 4 - ButtonPlay.Width div 2 - CONTROLSSPACING;
  ButtonPlay.Top := self.ClientHeight div 2 - ButtonPlay.Height div 2 + BUTTONTOPADJUSTVALUE;

  m_ButtonPass := TButton.Create(self);
  ButtonPass.Caption := 'Passo';
  ButtonPass.Parent := self;
  ApplyStyle(ButtonPass);
  ResizeButton(ButtonPass);
  ButtonPass.Left := ButtonPlay.Left + ButtonPlay.Width + CONTROLSSPACING;
  ButtonPass.Top := self.ClientHeight div 2 - ButtonPass.Height div 2 + BUTTONTOPADJUSTVALUE;

  m_ButtonRelaunch := TButton.Create(self);
  ButtonRelaunch.Caption := 'Rilan.';
  ButtonRelaunch.Parent := self;
  ButtonRelaunch.ShowHint := true;
  //ButtonRelaunch.Hint := 'Rilancio';
  ApplyStyle(ButtonRelaunch);
  ResizeButton(ButtonRelaunch);
  ButtonRelaunch.Left := ButtonPass.Left + ButtonPass.Width + CONTROLSSPACING;
  ButtonRelaunch.Top := self.ClientHeight div 2 - ButtonRelaunch.Height div 2 + BUTTONTOPADJUSTVALUE;

  { OpenOrPass }
  m_ButtonOpen := TButton.Create(self);
  ButtonOpen.Caption := 'Apro';
  ButtonOpen.Parent := self;
  ApplyStyle(ButtonOpen);
  ResizeButton(ButtonOpen);
  ButtonOpen.Left := self.ClientWidth div 3 - ButtonOpen.Width div 2 - CONTROLSSPACING;
  ButtonOpen.Top := self.ClientHeight div 2 - ButtonOpen.Height div 2 + BUTTONTOPADJUSTVALUE;

  { ShowCardsOrDontShowCards }
  m_ButtonShowCards := TButton.Create(self);
  ButtonShowCards.Caption := '  Si  ';
  ButtonShowCards.Parent := self;
  ApplyStyle(ButtonShowCards);
  ResizeButton(ButtonShowCards);
  ButtonShowCards.Left := self.ClientWidth div 3 - ButtonShowCards.Width div 2 - CONTROLSSPACING;
  ButtonShowCards.Top := self.ClientHeight div 2 - ButtonShowCards.Height div 2 + BUTTONTOPADJUSTVALUE;

  m_ButtonDontShowCards := TButton.Create(self);
  ButtonDontShowCards.Caption := '  No  ';
  ButtonDontShowCards.Parent := self;
  ApplyStyle(ButtonDontShowCards);
  ResizeButton(ButtonDontShowCards);
  ButtonDontShowCards.Left := self.ClientWidth div 3 - ButtonDontShowCards.Width div 2 + ButtonDontShowCards.Width + CONTROLSSPACING;
  ButtonDontShowCards.Top := self.ClientHeight div 2 - ButtonDontShowCards.Height div 2 + BUTTONTOPADJUSTVALUE;


  { BeginTurn }
  m_ButtonBeginTurn := TButton.Create(self);
  ButtonBeginTurn.Caption := 'Comincia';
  ButtonBeginTurn.Parent := self;
  ApplyStyle(ButtonBeginTurn);
  ResizeButton(ButtonBeginTurn);
  ButtonBeginTurn.Left := self.ClientWidth div 2 - ButtonBeginTurn.Width div 2;
  ButtonBeginTurn.Top := self.ClientHeight div 2 - ButtonBeginTurn.Height div 2 + BUTTONTOPADJUSTVALUE;


  { CipOrRelaunchOrSeeOrWordsOrPass }
  m_ButtonCip := TButton.Create(self);
  ButtonCip.Caption := 'Cip';
  ButtonCip.Parent := self;
  ApplyStyle(ButtonCip);
  ResizeButton(ButtonCip);

  m_ButtonSee := TButton.Create(self);
  ButtonSee.Caption := 'Vedo';
  ButtonSee.Parent := self;
  ApplyStyle(ButtonSee);
  ResizeButton(ButtonSee);

  m_ButtonWords := TButton.Create(self);
  ButtonWords.Caption := 'Parole';
  ButtonWords.Parent := self;
  ApplyStyle(ButtonWords);
  ResizeButton(ButtonWords);


  { Controlli di bet }
  m_ButtonBet := TButton.Create(self);
  ButtonBet.Caption := 'OK';
  ButtonBet.TabOrder := 1;
  ButtonBet.Parent := self;
  ApplyStyle(ButtonBet);
  ResizeButton(ButtonBet);
  ButtonBet.OnClick := ButtonBet_Click;

  LabelBet := TLabel.Create(self);
  LabelBet.Caption := '$';
  LabelBet.Color := clGreen;
  LabelBet.Parent := self;
  Font.Color := clBlack;
  Font.Name := 'Comic Sans MS';
  Font.Size := 12;
  LabelBet.Font := Font;
  LabelBet.AutoSize := true;
  LabelBet.Layout := tlCenter;

  m_EditBet := TEdit.Create(self);
  EditBet.OnKeyPress := EditBet_KeyPress;
  Font.Color := clBlack;
  Font.Name := 'MS Sans Serif';
  EditBet.Font := Font;
  EditBet.TabOrder := 0;
  EditBet.Text := '';
  EditBet.Parent := self;
  EditBet.Height := ButtonBet.Height;
  EditBet.Width := self.ClientWidth - LabelBet.Width - ButtonBet.Width - CONTROLSSPACING*3;
  EditBet.Left := CONTROLSSPACING;
  EditBet.Top := self.ClientHeight div 2 - EditBet.Height div 2 + BUTTONTOPADJUSTVALUE;

  LabelBet.Left := EditBet.Width + EditBet.Left + 1;
  LabelBet.Top := self.ClientHeight div 2 - EditBet.Height div 2 + BUTTONTOPADJUSTVALUE;

  ButtonBet.Left := LabelBet.Left + LabelBet.Width + CONTROLSSPACING;
  ButtonBet.Top := self.ClientHeight div 2 - ButtonBet.Height div 2 + BUTTONTOPADJUSTVALUE;
end;

{ Procedura che disegna i bottoni a seconda della modalità }
procedure TButtonPanel.PaintButtons;
var
  FrmParent: TForm;

begin
  FrmParent := TForm(AOwner);

  { Nasconde tutti i pulsanti }
  HideAllButtons;

  { Se la modalità è una "sotto" modalità, imposta alcune variabili e
  re-imposta la modalità a quella generale }
  case Mode of
    pmOpenBet:
    begin
      BetDescription := GetStr(110);
      BetMode := pmOpenBet;
      Mode := pmGeneralBet;
    end;
    pmFirstBet:
    begin
      BetDescription := GetStr(111);
      BetMode := pmFirstBet;
      Mode := pmGeneralBet;
    end;
    pmRelaunchBet:
    begin
      BetDescription := GetStr(112);
      BetMode := pmRelaunchBet;
      Mode := pmGeneralBet;
    end;
    pmSeeBet:
    begin
      BetDescription := GetStr(113);
      BetMode := pmSeeBet;
      Mode := pmGeneralBet;
    end;
  end;

  { A seconda della modalità, visulizza i bottoni e imposta il titolo }
  case Mode of
    pmStartGame:
    begin
      self.Caption := ' ' + GetStr(114) + ' ';
      ButtonStartGame.Show;
      ButtonStartGame.Caption := GetStr(95);
      ResizeButton(ButtonStartGame);
    end;
    pmChangeCards:
    begin
      self.Caption := ' ' + GetStr(115) + ' ';
      ButtonChangeCards.Show;
      ButtonChangeCards.Caption := GetStr(96);
      ResizeButton(ButtonChangeCards);
    end;
    pmPlayPassRelaunch:
    begin
      ButtonPass.Caption := GetStr(98);
      ButtonRelaunch.Caption := GetStr(99);
      ButtonPlay.Caption := GetStr(97);

      ResizeButton(ButtonPlay);
      ResizeButton(ButtonPass);
      ResizeButton(ButtonRelaunch);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonPlay.Left := self.ClientWidth div 4 - ButtonPlay.Width div 2 - CONTROLSSPACING;
      ButtonPlay.Top := self.ClientHeight div 2 - ButtonPlay.Height div 2 + BUTTONTOPADJUSTVALUE;

      ButtonPass.Left := ButtonPlay.Left + ButtonPlay.Width + CONTROLSSPACING;
      ButtonPass.Top := self.ClientHeight div 2 - ButtonPass.Height div 2 + BUTTONTOPADJUSTVALUE;

      ButtonRelaunch.Left := ButtonPass.Left + ButtonPass.Width + CONTROLSSPACING;
      ButtonRelaunch.Top := self.ClientHeight div 2 - ButtonRelaunch.Height div 2 + BUTTONTOPADJUSTVALUE;

      ButtonPlay.Show;
      ButtonPass.Show;
      ButtonRelaunch.Show;
    end;
    pmOpenOrPass:
    begin
      ButtonPass.Caption := GetStr(175);
      ButtonOpen.Caption := GetStr(100);
      ResizeButton(ButtonOpen);
      ResizeButton(ButtonPass);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonPass.Left := self.ClientWidth div 3 - ButtonPass.Width div 2 + ButtonPlay.Width + CONTROLSSPACING;
      ButtonPass.Top := self.ClientHeight div 2 - ButtonPass.Height div 2 + BUTTONTOPADJUSTVALUE;
      ButtonOpen.Show;
      ButtonPass.Show;

    end;
    pmBeginTurn:
    begin
      self.Caption := ' ' + GetStr(117) + ' ';
      ButtonBeginTurn.Show;
      ButtonBeginTurn.Caption := GetStr(103);
      ResizeButton(ButtonBeginTurn);
    end;
    pmShowCardsOrDontShowCards:
    begin
      self.Caption := ' ' + GetStr(118) + ' ';
      ButtonShowCards.Show;
      ButtonShowCards.Caption := '  ' + GetStr(106) + '  ';
      ResizeButton(ButtonShowCards);
      ButtonDontShowCards.Show;
      ResizeButton(ButtonDontShowCards);
      ButtonDontShowCards.Caption := '  ' + GetStr(107) + '  ';
      ResizeButton(ButtonDontShowCards);
    end;
    pmPass:
    begin
      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonPass.Caption := GetStr(175);
      ResizeButton(ButtonPass);
      ButtonPass.Left := self.ClientWidth div 2 - ButtonPass.Width div 2;
      ButtonPass.Top := self.ClientHeight div 2 - ButtonPass.Height div 2 + BUTTONTOPADJUSTVALUE;
      ButtonPass.Show;
    end;
    pmCipOrRelaunchOrSeeOrWordsOrPass:
    begin
      ButtonCip.Caption := GetStr(30);
      ButtonSee.Caption := GetStr(104);
      ButtonRelaunch.Caption := GetStr(99);
      ButtonWords.Caption := GetStr(105);
      ButtonPass.Caption := GetStr(98);

      ResizeButton(ButtonCip);
      ResizeButton(ButtonSee);
      ResizeButton(ButtonRelaunch);
      ResizeButton(ButtonWords);
      ResizeButton(ButtonPass);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonCip.Left := self.ClientWidth div 4 - ButtonCip.Width div 2 - CONTROLSSPACING;
      ButtonCip.Top := self.ClientHeight div 3 - ButtonCip.Height div 2 + BUTTONTOPADJUSTVALUE + 2;

      ButtonRelaunch.Left := ButtonCip.Left + ButtonCip.Width + CONTROLSSPACING;
      ButtonRelaunch.Top := ButtonCip.Top;

      ButtonSee.Left := ButtonRelaunch.Left + ButtonRelaunch.Width + CONTROLSSPACING;
      ButtonSee.Top := ButtonCip.Top;

      ButtonWords.Left := self.ClientWidth div 3 - ButtonCip.Width div 2 - CONTROLSSPACING;
      ButtonWords.Top := ButtonCip.Top + ButtonCip.Height + 2;

      ButtonPass.Left := ButtonWords.Left + ButtonWords.Width + CONTROLSSPACING;
      ButtonPass.Top := ButtonWords.Top;

      ButtonCip.Show;
      ButtonRelaunch.Show;
      ButtonSee.Show;
      ButtonWords.Show;
      ButtonPass.Show;
    end;
    pmRelaunchOrSeeOrWordsOrPass:
    begin
      ButtonRelaunch.Caption := GetStr(99);
      ButtonSee.Caption := GetStr(104);
      ButtonWords.Caption := GetStr(105);
      ButtonPass.Caption := GetStr(98);

      ResizeButton(ButtonSee);
      ResizeButton(ButtonRelaunch);
      ResizeButton(ButtonWords);
      ResizeButton(ButtonPass);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonRelaunch.Left := self.ClientWidth div 4 - ButtonCip.Width div 2 - CONTROLSSPACING - 7;
      ButtonRelaunch.Top := self.ClientHeight div 3 - ButtonCip.Height div 2 + BUTTONTOPADJUSTVALUE + 2;

      ButtonSee.Left := ButtonRelaunch.Left + ButtonRelaunch.Width + CONTROLSSPACING;
      ButtonSee.Top := ButtonRelaunch.Top;

      ButtonWords.Left := ButtonSee.Left + ButtonSee.Width + CONTROLSSPACING;
      ButtonWords.Top := ButtonRelaunch.Top;


      ButtonPass.Left := self.ClientWidth div 2 - ButtonCip.Width div 2 - CONTROLSSPACING;
      ButtonPass.Top := ButtonRelaunch.Top + ButtonRelaunch.Height + 2;

      ButtonRelaunch.Show;
      ButtonSee.Show;
      ButtonWords.Show;
      ButtonPass.Show;
    end;
    pmRelaunchOrSeeOrPass:
    begin
      ButtonRelaunch.Caption := GetStr(99);
      ButtonSee.Caption := GetStr(177);
      ButtonPass.Caption := GetStr(98);

      ResizeButton(ButtonSee);
      ResizeButton(ButtonRelaunch);
      ResizeButton(ButtonPass);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonRelaunch.Left := self.ClientWidth div 4 - ButtonRelaunch.Width div 2 - CONTROLSSPACING;
      ButtonRelaunch.Top := self.ClientHeight div 2 - ButtonRelaunch.Height div 2 + BUTTONTOPADJUSTVALUE;
      ButtonSee.Left := ButtonRelaunch.Left + ButtonRelaunch.Width + CONTROLSSPACING;
      ButtonSee.Top := self.ClientHeight div 2 - ButtonSee.Height div 2 + BUTTONTOPADJUSTVALUE;
      ButtonPass.Left := ButtonSee.Left + ButtonSee.Width + CONTROLSSPACING;
      ButtonPass.Top := self.ClientHeight div 2 - ButtonRelaunch.Height div 2 + BUTTONTOPADJUSTVALUE;
      ButtonRelaunch.Show;
      ButtonSee.Show;
      ButtonPass.Show;
    end;
    pmCipOrRelaunchOrSeeOrPass:
    begin
      ButtonCip.Caption := GetStr(30);
      ButtonSee.Caption := GetStr(104);
      ButtonRelaunch.Caption := GetStr(99);
      ButtonPass.Caption := GetStr(98);

      ResizeButton(ButtonCip);
      ResizeButton(ButtonSee);
      ResizeButton(ButtonRelaunch);
      ResizeButton(ButtonPass);

      self.Caption := ' ' + GetStr(116) + ' ';
      ButtonCip.Left := self.ClientWidth div 4 - ButtonCip.Width div 2 - CONTROLSSPACING + 4;
      ButtonCip.Top := self.ClientHeight div 3 - ButtonCip.Height div 2 + BUTTONTOPADJUSTVALUE + 2;
      ButtonRelaunch.Left := ButtonCip.Left + ButtonCip.Width + CONTROLSSPACING;
      ButtonRelaunch.Top := ButtonCip.Top;
      ButtonSee.Left := ButtonRelaunch.Left + ButtonRelaunch.Width + CONTROLSSPACING;
      ButtonSee.Top := ButtonCip.Top;
      ButtonPass.Left := self.ClientWidth div 2 - ButtonCip.Width div 2 - CONTROLSSPACING;
      ButtonPass.Top := ButtonCip.Top + ButtonCip.Height + 2;

      ButtonCip.Show;
      ButtonRelaunch.Show;
      ButtonSee.Show;
      ButtonPass.Show;
    end;
    pmGeneralBet:
    begin
      self.Caption := ' ' +  BetDescription + ' ';
      EditBet.Text := '';
      ButtonBet.Show;
      EditBet.Show;
      LabelBet.Show;
    end;
  end;

  { Imposta il focus simulando la pressione di TAB (scomodo)... }
  //keybd_event(VK_TAB, MapVirtualKey(VK_TAB, 0), 0, 0);
  //keybd_event(VK_TAB, MapVirtualKey(VK_TAB, 0), KEYEVENTF_KEYUP, 0);
end;

{ Questa procedura nasconde tutti i bottoni }
procedure TButtonPanel.HideAllButtons;
var
  C: integer;
begin
  for C := 0 to self.ControlCount-1 do
    self.Controls[C].Hide;
end;

{ Procedura per la proprietà Mode }
procedure TButtonPanel.SetMode(Mode: TPanelMode);
begin
  m_Mode := Mode;
  PaintButtons;
end;

{ Funzione per la proprietà Mode }
function TButtonPanel.GetMode: TPanelMode;
begin
  Result := m_Mode;
end;

{ Procedura per rimpicciolire un bottone in base al caption }
procedure TButtonPanel.ResizeButton(Button: TButton);
var
  Width: integer;
  Height: integer;
  Caption: string;
begin
  Caption := Button.Caption;
  Width := TForm(AOwner).Canvas.TextWidth(Caption) + BUTTONEXTRASIZE;
  Height := TForm(AOwner).Canvas.TextHeight(Caption) + BUTTONEXTRASIZE;

  Button.Width := Width;
  Button.Height := Height;
end;

{ Procedura per applicare degli stili particolari al bottone... }
procedure TButtonPanel.ApplyStyle(Button: TButton);
begin

end;

{ Procedura per abilitare/disabilitare tutti i pulsanti }
procedure TButtonPanel.EnableButtons(Enable: boolean);
var
  C: integer;
begin
  for C := 0 to self.ControlCount-1 do
  begin
    if self.Controls[C] = ButtonRelaunch then ButtonRelaunch.Enabled := RelaunchButtonEnabled
    else self.Controls[C].Enabled := Enable;
  end;

end;


{ Start - Proprietà }
function TButtonPanel.GetButtonStartGame: TButton;
begin
  Result := m_ButtonStartGame
end;

{ ChangeCards - Proprietà }
function TButtonPanel.GetButtonChangeCards: TButton;
begin
  Result := m_ButtonChangeCards
end;

{ Bet - Proprietà }
function TButtonPanel.GetButtonBet: TButton;
begin
  Result := m_ButtonBet;
end;

function TButtonPanel.GetEditBet: TEdit;
begin
  Result := m_EditBet;
end;

{ PlayOrPass - Proprietà }
function TButtonPanel.GetButtonPlay: TButton;
begin
  Result := m_ButtonPlay;
end;

function TButtonPanel.GetButtonPass: TButton;
begin
  Result := m_ButtonPass;
end;

{ OpenPassRelaunch - Proprietà }
function TButtonPanel.GetButtonOpen: TButton;
begin
  Result := m_ButtonOpen;
end;

function TButtonPanel.GetButtonRelaunch: TButton;
begin
  Result := m_ButtonRelaunch;
end;

{CipOrRelaunchOrSeeOrWordsOrPass - Proprietà }
function TButtonPanel.GetButtonSee: TButton;
begin
  Result := m_ButtonSee;
end;
function TButtonPanel.GetButtonWords: TButton;
begin
  Result := m_ButtonWords;
end;
function TButtonPanel.GetButtonCip: TButton;
begin
  Result := m_ButtonCip;
end;

{ BeginTurn - Proprietà }
function TButtonPanel.GetButtonBeginTurn: TButton;
begin
  Result := m_ButtonBeginTurn;
end;

{ ShowCardsOrDontShowCards - Proprietà }
function TButtonPanel.GetButtonShowCards: TButton;
begin
  Result := m_ButtonShowCards;
end;
function TButtonPanel.GetButtonDontShowCards: TButton;
begin
  Result := m_ButtonDontShowCards;
end;

{ Procedura che viene scatenata alla pressione del pulsante
ButtonBet }
procedure TButtonPanel.ButtonBet_Click(Sender: TObject);
var
  BetResult: TBetResult;
begin
  { Se il campo testo è vuoto, esci dalla procedura }
  if EditBet.Text = '' then exit;
  
  { Inizializza la classe BetResult }
  BetResult := TBetResult.Create;
  BetResult.Mode := BetMode;

  { Se i dati inseriti dall'utente rientrano nei
  parametri minimi e massimi, allora scatena l'evento, altrimenti
  visualizza una box di errore }
  BetResult.Value := StrToInt(EditBet.Text);

  { Piccolo bug: se uno rimane senza soldi, si blocca il giooo:
  con quest'istruzione condizionale fixiamo il bug puntando un solo $ }
  if (BetMaxValue = 0) then BetMaxValue :=1;

  if (BetResult.Value <= BetMaxValue) and (BetResult.Value >= BetMinValue) then OnBetValueAssigned(TObject(BetResult))
  else MessageBox(0,pchar(GetStr(109,IntToStr(BetMaxValue)+','+ IntToStr(BetMinValue))),pchar(GetStr(108)),MB_OK);
end;

{ Procedura scatenata alla pressione di un tasto quando
il focus è puntato sulla editbet }
procedure TButtonPanel.EditBet_KeyPress(Sender: TObject; var Key: Char);
begin
  //Intercetta tutti i tasti tranne il backspace e l'invio..
  if Integer(Key) = 8 then exit
  else if Integer(Key) = 13 then begin
    ButtonBet.OnClick(nil);
    Key := chr(0);
  end
  else if (Integer(Key) < 48) or (Integer(Key) > 57) then Key := chr(0);
end;

{ Procedura per disabilitare/abilitare il bottone per rilanciare }
procedure TButtonPanel.EnableRelaunchButton(Enabled: boolean);
begin
  RelaunchButtonEnabled := Enabled;
end;

{ Evento scatenato alla pressione di un pulsante... }
procedure TButtonPanel.ButtonChangeCards_KeyPress(Sender: TObject; var Key: char);
begin
  { Se è un tasto da 1 a 5... scatena l'evento associato }
  if Integer(Key) in [49 .. 53] then begin
  
    { Passa come argomento Key - 49, quindi un valore da 0 a 4 per sapere quale carta ha
    selezionato l'utente... }
    try
      OnCardChoicePressed(TObject(Integer(Key)-49));
    except
      //Se non c'è un gestore non fare nulla..
    end;
  end;
end;




end.
