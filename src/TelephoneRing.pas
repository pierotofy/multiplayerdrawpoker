unit TelephoneRing;

interface

uses Classes, ExtCtrls, Windows, SysUtils,
  Constants;

{ Classe per simulare l'effetto visto/non visto del telefono
per notificare l'arrivo di un messaggio }
type
  TTelephoneRing = class(TThread)
  private
    TelImage: TImage;
    MsecsInterval: integer;

    Ringing: boolean;
    Running: boolean;
  public
    constructor Create(TelImage: TImage; MsecsInterval: integer = 500);
    destructor Destroy; override;
    procedure Execute; override;
    procedure StartRinging;
    procedure StopRinging;
  end;

implementation

{ Implementazione classe TTelephoneRing }
constructor TTelephoneRing.Create(TelImage: TImage; MsecsInterval: integer = 500);
begin
  { Richiama il costruttore base }
  inherited Create(false);

  self.TelImage := TelImage;
  self.MsecsInterval := MsecsInterval;

  Ringing := false;
  Running := true;
end;

{ Entry Point del Thread }
procedure TTelephoneRing.Execute;
begin
  while Running do
  begin
    { Per non sovvracaricare la cpu... }
    Sleep(500);

    while Ringing do
    begin
      if TelImage.Visible = true then TelImage.Visible := false
      else TelImage.Visible := true;
      Sleep(MsecsInterval);
    end;
  end;
end;

{ Distruttore dell'oggetto }
destructor TTelephoneRing.Destroy;
begin
  { Ferma il thread e nasconde l'immagine }
  Running := false;
  TelImage.Visible := false;
end;

{ Procedura per avviare lo squillio }
procedure TTelephoneRing.StartRinging;
begin
  Ringing := true;
end;

{ Procedura per terminare lo squillio }
procedure TTelephoneRing.StopRinging;
begin
  Ringing := false;
  TelImage.Visible := false;
end;

end.
 