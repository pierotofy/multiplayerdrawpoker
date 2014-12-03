unit Donate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ShellApi, Constants,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Languages, Registry;

type
  TFrmDonate = class(TForm)
    ImgPiero: TImage;
    lblDidULiked: TLabel;
    lblDescr: TLabel;
    lblMakeDonation: TLabel;
    BtnOK: TButton;
    TmrCountdown: TTimer;
    ImgDonate: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure TmrCountdownTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject); 
    procedure ImgDonateClick(Sender: TObject);
  private
    ButtonOKPressed: boolean;
    DoCountdownLock: boolean;
  public
    constructor Create(AOwner: TComponent; DoCountdownLock: boolean);
  end;


Const COUNTDOWNTIME = 60; //60 secondi
Const EXECUTECOUNTBEFORESHOW = 30;

var
  FrmDonate: TFrmDonate;

function IsTimeToDonate: boolean;

implementation

{$R *.dfm}

{ Costruttore personalizzato }
constructor TFrmDonate.Create(AOwner: TComponent; DoCountdownLock: boolean);
begin
  self.DoCountdownLock := DoCountdownLock;
  inherited Create(AOwner);
end;

procedure TFrmDonate.FormShow(Sender: TObject);
begin
  { Imposta la variabile per vedere se l'utente sta uscendo con il pulsante OK }
  ButtonOKPressed := false;

  { Se c'è il countdown da fare, abilita il timer.. }
  if DoCountdownLock then begin
    BtnOK.Caption := IntToStr(COUNTDOWNTIME);
    BtnOK.Enabled := false;
    TmrCountdown.Enabled := true;
  end;
end;

procedure TFrmDonate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (not ButtonOKPressed) and DoCountdownLock then Action := TCloseAction(0);
end;                                                                        

procedure TFrmDonate.BtnOKClick(Sender: TObject);
begin
  ButtonOKPressed := true;
end;


{ Procedura richiamata ogni secondo dal timer...
Se c'è ancora tempo, decrementa il contatore
altrimenti stoppa il timer e riabilita l'utente all'uscita }
procedure TFrmDonate.TmrCountdownTimer(Sender: TObject);
var
  SecsRemaining: integer;
begin
  SecsRemaining := StrToInt(BtnOK.Caption);

  if SecsRemaining > 1 then BtnOK.Caption := IntToStr(SecsRemaining-1)
  else begin
    BtnOK.Caption := GetStr(17);
    BtnOK.Enabled := true;
    TmrCountdown.Enabled := false;
    DoCountdownLock := false;
  end;
end;

{ Funzione per vedere se è ora di visualizzare la form di donazione... }
function IsTimeToDonate: boolean;
var
  Reg: TRegistry;
  Count: integer;
begin
  { Apre la chiave }
  Reg := TRegistry.Create;
  Reg.CreateKey('\Software\MultiplayerPoker\');
  Reg.OpenKey('\Software\MultiplayerPoker',true);

  { Esiste il valore ExecuteCount? Se si allora leggi il suo contenuto }
  if Reg.ValueExists('ExecuteCount') then begin
    Count := Reg.ReadInteger('ExecuteCount');

    { E' tempo di mostrare la finestra? }
    if Count >= EXECUTECOUNTBEFORESHOW then begin
      Result := true;
      Reg.WriteInteger('ExecuteCount',1);
    end

    { No, semplicemente incrementa il contatore }
    else begin
      Result := false;
      Reg.WriteInteger('ExecuteCount',Count+1);
    end;
  end

  { Non esiste? Creala e impostala a 1 }
  else begin
    Result := false;
    Reg.WriteInteger('ExecuteCount',1);
  end;

  { Chiude.. }
  Reg.CloseKey;
end;

procedure TFrmDonate.FormCreate(Sender: TObject);
begin
  self.Caption := Languages.GetStr(170);
  lblDidULiked.Caption := Languages.GetStr(171);
  lblDescr.Caption := Languages.GetStr(172);
  lblMakeDonation.Caption := Languages.GetStr(173);
  btnOK.Caption := Languages.GetStr(17);
end;

procedure TFrmDonate.ImgDonateClick(Sender: TObject);
begin
    ShellExecute(Handle, 'open',DONATEPAGE,nil,nil, SW_SHOWNORMAL);
end;

end.
