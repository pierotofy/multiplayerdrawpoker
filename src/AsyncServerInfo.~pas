unit AsyncServerInfo;

interface

uses ServerInfo, Classes, Windows, ServerInfoList,
  Constants;

{ Classe che istanzia un oggetto ServerInfo in maniera asincrona }

type
  TAsyncServerInfo = class(TThread)
  private
    AOwner: TComponent;
    Host: string;
    Port: integer;
    m_Timeout: integer;
    m_ServerInfo: TServerInfo;
    ServerListToFill: TServerInfoList;
  public
    constructor Create(AOwner: TComponent; Host: string; Port: integer; ServerListToFill: TServerInfoList; Timeout: integer = TIMEOUT);
    procedure Execute; override;
    property ServerInfo: TServerInfo read m_ServerInfo;
  end;

implementation

{ Implementazione classe TAsyncServerInfo }
constructor TAsyncServerInfo.Create(AOwner: TComponent; Host: string; Port: integer; ServerListToFill: TServerInfoList; Timeout: integer = TIMEOUT);
begin
  self.AOwner := AOwner;
  self.Host := Host;
  self.Port := Port;
  self.ServerListToFill := ServerListToFill;
  m_Timeout := Timeout;
  inherited Create(false);
end;

{ Entry Point del thread }
procedure TAsyncServerInfo.Execute;
begin
  { Inzializza l'oggetto serverinfo }
  m_ServerInfo := TServerInfo.Create(AOwner,Host,Port,m_Timeout);

  { Attende che abbia finito... }
  repeat
    Sleep(50); { Per non sovvracaricare la cpu }
  until (ServerInfo.IsAvaible) or (ServerInfo.Timeouted);

  { Ok, se ha trovato qualcosa inserisci l'elemento nella lista }
  if ServerInfo.IsAvaible then ServerListToFill.AddServerInfo(ServerInfo); 
end;


end.
