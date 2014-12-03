unit UpdateChecker;

interface

uses Windows, Classes, SysUtils, ShellApi, IdHTTP, DateUtils, StrUtils,
  Constants, Languages;

type
  TUpdateChecker = class(TThread)
  private
    AOwner: TComponent; //Riferimento al componente padre...
    IdHTTP: TIdHTTP;
    NotifyNoNewVersion: boolean;
    SleepOneHourBeforeStarting: boolean;

    function ReadLnFromStr(var Str: string): string;
  public
    constructor Create(AOwner: TComponent; NotifyNoNewVersion: boolean; SleepOneHourBeforeStarting: boolean = false);
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TUpdateChecker }
constructor TUpdateChecker.Create(AOwner: TComponent; NotifyNoNewVersion: boolean; SleepOneHourBeforeStarting: boolean = false);
begin
  self.AOwner := AOwner;
  self.NotifyNoNewVersion := NotifyNoNewVersion;
  self.SleepOneHourBeforeStarting := SleepOneHourBeforeStarting;

  { Inizializza il controllo IdHTTP e richiama il costruttore base
  per avviare il thread }
  IdHTTP := TIdHTTP.Create(AOwner);

  inherited Create(false);
end;

{ Entry Point }
procedure TUpdateChecker.Execute;
var
  Response: string;
  NewVersionFound: boolean;
  StartDate: TDateTime;
  StopDate: TDateTime;
begin
  { Prima di tutto, se bisogna fermare il thread per un'ora... }
  if SleepOneHourBeforeStarting then begin
    StartDate := Now;
    StopDate := IncMinute(StartDate, 60);

    while TimeToStr(StartDate) <> TimeToStr(StopDate) do begin
      Sleep(25);
      StartDate := Now;
    end;
  end;

  try
    Response := IdHTTP.Get(UPDATEFILE);

    { Se la nostra versione è differente da quella online... new version found XD! }
    NewVersionFound := Trim(ReadLnFromStr(Response)) <> PROGRAMVERSION;
  except
    NewVersionFound := false;
  end;


  { Se c'è una nuova versione, chiedi conferma all'utente... }
  if NewVersionFound then begin

    { Ma prima controlliamo se il nostro programma d'aggiornamento c'è
    oppure qualcuno trasportando il poker via dischetto o in rete si è "dimenticato" di metterlo...
    Se non c'è, usciamo }
    if not FileExists('Update.exe') then begin
      if NotifyNoNewVersion then MessageBox(0,pchar(GetStr(147)),pchar(GetStr(148)),MB_OK or MB_ICONWARNING);
      exit;
    end;

    { Se l'utente acconsente ad aggiornarsi, avviamo il programma di aggiornamento... }
    if MessageBox(0,pchar(GetStr(149)),pchar(GetStr(150)),MB_YESNO or MB_ICONQUESTION) = ID_YES then begin

      ShellExecute(Handle, 'open','Update.exe','-POKERVERSION ' + PROGRAMVERSION,nil,SW_SHOWNORMAL);

      { E inviamo la richiesta al chiamante di chiudere l'applicazione }
      ExitProcess(0);
    end;
  end

  { Altrimenti se richiesto, avvisa l'utente che non c'è nessuna nuova versione... }
  else if NotifyNoNewVersion then MessageBox(0,pchar(GetStr(151)),pchar(GetStr(152)),MB_ICONINFORMATION);
end;

{ Funzione che legge una riga da una stringa e ritorna tale riga come valore
di ritorno, contemporaneamente tronca la stringa (from Updater by Piero Tofy) }
function TUpdateChecker.ReadLnFromStr(var Str: string): string;
var
  C: integer;
begin
  Result := '';
  
  { Esegui queste operazioni solo se la stringa esiste... }
  if Length(Str) > 0 then begin
    C := 1;
    while (Str[C] <> #0) and (Str[C] <> #10) do
    begin
      Result := Result + Str[C];
      inc(C);
    end;
    Str := AnsiRightStr(Str,Length(Str)-C);
  end;
end;

end.
 