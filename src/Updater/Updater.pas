unit Updater;

interface

uses Windows, Classes, IdBaseComponent, SysUtils, ShellApi, ComCtrls, StdCtrls, Graphics, IdComponent, StrUtils,
  IdTCPConnection, IdTCPClient, IdHTTP;

Const SEPARATOR = '¿';
Const INSTRUCTIONFILE = 'http://www.pierotofy.it/data/projects/27/update.php';


{ Template Update.php

1.0 beta
7 //numero di operazioni...
mkdir¿~\nomedirectory
rmdir¿~\nomedirectory
cpfile¿url¿destinazione
rmfile¿nomefile
showmessage¿ciao¿3000
launch¿filename
ren¿oldfile¿newfile

}


type
  TUpdater = class(TThread)
  private
    AOwner: TComponent; //Riferimento al form principale
    PokerVersion, PokerPath: string;
    TotalOp, PositionStep: integer;
    StatusLabel: TLabel;
    ProgressBar: TProgressBar;
    IdHTTP: TIdHTTP;

    Thread_Finished: TNotifyEvent; //Scatenato quando viene finito il thread...

    procedure ShowStatus(Status: string; Color: TColor = clBlack);
    procedure WaitForPokerClose;
    function GetResponseFromUrl(Url: string): string;
    function ReadLnFromStr(var Str: string): string;
    procedure ParseData(StrData: string);
    function GetAbsPath(Path: string): string;
    procedure IncProgressBar(Value: integer);

    function GetToken(StrData: string; Index: integer): string;
    function GetCommand(StrData: string): string;
  public
    constructor Create(AOwner: TComponent; PokerVersion, PokerPath: string; StatusLabel: TLabel; ProgressBar: TProgressBar; Thread_Finished: TNotifyEvent);
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TUpdater }

constructor TUpdater.Create(AOwner: TComponent; PokerVersion, PokerPath: string; StatusLabel: TLabel; ProgressBar: TProgressBar; Thread_Finished: TNotifyEvent);
begin
  { Setta le variabili }
  self.AOwner := AOwner;
  self.PokerVersion := PokerVersion;
  self.StatusLabel := StatusLabel;
  self.ProgressBar := ProgressBar;
  self.PokerPath := PokerPath;
  self.Thread_Finished := Thread_Finished;

  { Costruisce il controllo IdHTTP... }
  IdHTTP := TIdHTTP.Create(AOwner);

  inherited Create(false);
end;

{ Entry Point }
procedure TUpdater.Execute;
var
  Response: string;
  OnlineVersion: string;
  StrData: string;
begin
  { Gestione delle eccezioni... }
  try
    IncProgressBar(1);

    { Aspetta la conclusione dell'istanza del poker }
    WaitForPokerClose;

    IncProgressBar(1);

    { Riceve il file contenente le istruzioni da eseguire... }
    Response := GetResponseFromUrl(INSTRUCTIONFILE);

    { La prima riga del file contiene il numero di versione... se
    il numero di versione corrisponde alla versione attuale, avvisa l'utente ed esci dal thread
    (tuttavia questa cosa non dovrebbe mai verificarsi...) }
    OnlineVersion := ReadLnFromStr(Response);
    if OnlineVersion = PokerVersion then begin
      ShowStatus('La versione in uso del poker è già aggiornata all''ultima release. Non sono necessari aggiornamenti.');
    end

    { Altrimenti inizia il processo di aggiornamento seguendo
    le istruzioni del file }
    else begin
      { La seconda riga contiene il numero di operazioni da eseguire...
      (mi serve per il calcolo della proporzione sulla progressbar) }
      TotalOp := StrToInt(ReadLnFromStr(Response));

      IncProgressBar(8); //Rimangono 90 posizioni da distribuire...
      PositionStep := 90 div TotalOp;
      ShowStatus('Il programma di aggiornamento sta eseguendo le operazioni necessarie, attendere...');

      repeat
        StrData := ReadLnFromStr(Response);
        ParseData(StrData);
      until StrData = '';

    end;

    Thread_Finished(TObject(0)); //0 = tutto ok
    
  except
    on E: exception do
    begin
      //Qualcosa è andato storto.. segnaliamolo..
      ShowStatus(e.Message,clRed);
      Thread_Finished(TObject(1)); //1 = errore
    end;
  end;
end;

{ Procedura per analizzare un comando... }
procedure TUpdater.ParseData(StrData: string);
var
  Command: string;
  FileStream: TFileStream;
begin
  Command := AnsiUpperCase(GetCommand(StrData));

  { Copia un file da una sorgente ad una destinazione... }
  if Command = 'CPFILE' then begin
    FileStream := TFileStream.Create(GetAbsPath(GetToken(StrData,2)),fmCreate);
    IdHTTP.Get(GetToken(StrData,1),FileStream);
    FileStream.Free;
  end

  { Cancella un file... }
  else if Command = 'RMFILE' then begin
    DeleteFile(GetAbsPath(GetToken(StrData,1)));
  end

  { Crea una directory }
  else if Command = 'MKDIR' then begin
    MkDir(GetAbsPath(GetToken(StrData,1)));
  end

  { Rimuove una directory }
  else if Command = 'RMDIR' then begin
    RmDir(GetAbsPath(GetToken(StrData,1)));
  end

  { Rinominare un file o una directory... }
  else if Command = 'REN' then begin
    RenameFile(GetAbsPath(GetToken(StrData,1)),GetAbsPath(GetToken(StrData,2)));
  end

  { Visualizza un messaggio... }
  else if Command = 'SHOWMESSAGE' then begin
    ShowStatus(GetToken(StrData,1));
    Sleep(StrToInt(GetToken(StrData,2)));
  end

  { Lancia un applicazione... }
  else if Command = 'LAUNCH' then begin
    ShellExecute(Handle, 'open',pchar(GetAbsPath(GetToken(StrData,1))),nil,nil, SW_SHOWNORMAL);
  end;

  { Siccome sono l'autore del file contenente le istruzioni dell'update.php,
  si suppone che non faccia errori di digitazione e che quindi ogni comando è valido.. }
  if Command <> '' then IncProgressBar(PositionStep);
end;

{ Procedura per mostrare lo status... }
procedure TUpdater.ShowStatus(Status: string; Color: TColor = clBlack);
var
  Font: TFont;
begin
  Font := TFont.Create;
  Font.Color := Color;
  StatusLabel.Font := Font;
  StatusLabel.Caption := Status;
end;

{ Procedura che restituisce il percorso assoluto di un file sostituendo ~ con il percorso del poker... }
function TUpdater.GetAbsPath(Path: string): string;
begin
  Result := AnsiReplaceStr(Path,'~',PokerPath);
end;

{ Caricamento un cavolo, assicuriamoci che l'applicazione MultiplayerPoker.exe
sia chiusa in maniera definitiva...}
procedure TUpdater.WaitForPokerClose;
begin
  ShowStatus('Caricamento del sistema di aggiornamento in corso...');
  Sleep(3000);
end;

{ Funzione che ritorna il file del server con l'elenco delle cose
da fare durante l'update }
function TUpdater.GetResponseFromUrl(Url: string): string;
begin
  ShowStatus('Awaiting server connection...');

  try
    Result := IdHTTP.Get(Url);
  except
    raise Exception.Create('Connection failed. The server might be offline, try again later.');
  end;
end;

{ Funzione che legge una riga da una stringa e ritorna tale riga come valore
di ritorno, contemporaneamente tronca la stringa }
function TUpdater.ReadLnFromStr(var Str: string): string;
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

{ Incrementa il valore della progressbar... }
procedure TUpdater.IncProgressBar(Value: integer);
begin
  ProgressBar.Position := ProgressBar.Position + Value;
end;




{ Due belle funzioncine prese da Constants.pas di multiplayer poker... }
function TUpdater.GetToken(StrData: string; Index: integer): string;
var
  C, Len, TokenCount: integer;
  StrToken: string;
begin
  Len := Length(StrData);
  TokenCount := 0;
  Result := '';

  for C := 1 to Len do
  begin
    if (StrData[C] = #10) or (StrData[C] = #13) then continue;

    if StrData[C] = SEPARATOR then begin
      if TokenCount = Index then begin
        Result := Trim(StrToken);
        exit;
      end;

      StrToken := '';
      inc(TokenCount);
    end
    else StrToken := StrToken + StrData[C];
  end;

  Result := Trim(StrToken);

end;

function TUpdater.GetCommand(StrData: string): string;
begin
  Result := Trim(GetToken(StrData,0));
end;




end.
 