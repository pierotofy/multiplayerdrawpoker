unit ServerInfo;

interface

uses Windows, IdTcpClient, Classes, SysUtils, StrUtils,
  Constants;

type
  TServerInfo = class
  private
    { Socket }
    ClientSocket: TIdTcpClient;

    m_Host: string;
    m_Port: integer;
    m_Timeouted: boolean;
    m_Timeout: integer;

    { Variabili }
    PasswordRequired: boolean;
    PlayersConnected: integer;
    Slots: integer;
    ServerName: string;
    GameStarted: boolean;
    Cip: integer;
    Avaible: boolean;
    ServerVersion: string;

  public
    constructor Create(AOwner: TComponent; Host: string; Port: integer; Timeout: integer = TIMEOUT);
    destructor Destroy; override;
    procedure WaitForReply;
    function IsPasswordRequired: boolean;
    function IsAvaible: boolean;
    function GetPlayersConnected: integer;
    function GetSlots: integer;
    function GetServerName: string;
    function GetCip: integer;
    function IsTheGameStarted: boolean;
    function GetServerVersion: string;

    property Host: string read m_Host;
    property Port: integer read m_Port;
    property Timeouted: boolean read m_Timeouted;
  end;

implementation

{ Implementazione classe TServerInfo }

constructor TServerInfo.Create(AOwner: TComponent; Host: string; Port: integer; Timeout: integer = TIMEOUT);
begin
  { Per prima cosa controlliamo se l'host inizia con '//' in tal caso dobbiamo troncare... }
  if AnsiStartsStr('\\',Host) then Host := AnsiRightStr(Host,Length(Host)-2);

  { Crea la socket }
  ClientSocket := TIdTcpClient.Create(AOwner);
  ClientSocket.Host := Host;
  ClientSocket.Port := Port;
  m_Host := Host;
  m_Port := Port;
  m_Timeout := Timeout;
                                                                                                  
  { Connessioneeee!}
  try
    ClientSocket.Connect(m_Timeout);

    { Si è connesso, imposta Avaible a true }
    Avaible := true;

    { Avvia la procedura che si mette in ascolto di messaggi... }
    WaitForReply;
  except
    { Non si è potuto connettere, Avaible = false }
    Avaible := false;
    GameStarted := false;
    m_Timeouted := true;
  end;


end;

destructor TServerInfo.Destroy;
begin
  { Se eravamo connessi disconnetti plz }
  if ClientSocket.Connected then ClientSocket.Disconnect;
  inherited Destroy;
end;

{ Ritorna true se nel server è richiesta una password
altrimenti false }
function TServerInfo.IsPasswordRequired: boolean;
begin
  Result := PasswordRequired;
end;

{ Ritorna il numero di giocatori connessi al server }
function TServerInfo.GetPlayersConnected: integer;
begin
  Result := PlayersConnected;
end;

{ Ritorna il numero di slots disponibili nel server }
function TServerInfo.GetSlots: integer;
begin
  Result := Slots;
end;

{ Ritorna il valore Avaible (se il server risponde o no) }
function TServerInfo.IsAvaible: boolean;
begin
  Result := Avaible;
end;

{ Ritorna true se il gioco è avviato, altrimenti false }
function TServerInfo.IsTheGameStarted: boolean;
begin
  Result := GameStarted;
end;

{ Ritorna il nome del server }
function TServerInfo.GetServerName: string;
begin
  Result := ServerName;
end;

{ Ritorna il valore del cip }
function TServerInfo.GetCip: integer;
begin
  Result := Cip;
end;

{ Ritorna il valore della versione del server }
function TServerInfo.GetServerVersion: string;
begin
  Result := ServerVersion;
end;

{ Ci stanno arrivando dei dati...
(contengono l'analisi completa del server) }
procedure TServerInfo.WaitForReply;
var
  StrData: string;
  Command: string;
  PasswordRequiredStatus, PlayersConnectedStatus, SlotsStatus, CipStatus, ServerVersionStatus, GameStartedStatus, ServerNameStatus: boolean;
begin
  { Azzera le variabili di status }
  PasswordRequiredStatus := false;
  PlayersConnectedStatus := false;
  SlotsStatus := false;
  ServerNameStatus := false;
  GameStartedStatus := false;
  CipStatus := false;
  ServerVersionStatus := false;

  { Manda la richiesta }
  ClientSocket.WriteLn('/GETSERVERINFO');

  { Rimane in attesa di messaggi }
  while ClientSocket.Connected do
  begin
    StrData := ClientSocket.ReadLn;

    { Analizza il comando }
    Command := GetCommand(StrData);

    { Richiesta la password? }
    if Command = '/PASSWORDREQUIRED' then begin
      if GetToken(StrData,1) = '0' then PasswordRequired := false
      else PasswordRequired := true;
      PasswordRequiredStatus := true;
    end
    else if Command = '/PLAYERSCONNECTED' then begin
      PlayersConnected := StrToInt(GetToken(StrData,1));
      PlayersConnectedStatus := true;
    end
    else if Command = '/SLOTS' then begin
      Slots := StrToInt(GetToken(StrData,1));
      SlotsStatus := true;
    end
    else if Command = '/SERVERNAME' then begin
      ServerName := GetToken(StrData,1);
      ServerNameStatus := true;
    end
    else if Command = '/GAMESTARTED' then begin
      if GetToken(StrData,1) = '0' then GameStarted := false
      else GameStarted := true;
      GameStartedStatus := true;
    end
    else if Command = '/CIP' then begin
      Cip := StrToInt(GetToken(StrData,1));
      CipStatus := true;
    end
    else if Command = '/SERVERVERSION' then begin
      ServerVersion := GetToken(StrData,1);
      ServerVersionStatus := true;
    end;

    { Abbiamo preso tutto? }
    if PasswordRequiredStatus and
        PlayersConnectedStatus and
        SlotsStatus and
        ServerNameStatus and
        GameStartedStatus and
        ServerVersionStatus and
        CipStatus then begin
      { Possiamo chiudere la socket, grazie! }
      ClientSocket.Disconnect;
    end;
  end;

end;


end.
