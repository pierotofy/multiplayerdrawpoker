unit TestServer;

interface

uses SysUtils, IdTcpServer,
  Constants;

type
  TTestServer = class(TIdTcpServer)
  private
    { Gestore d'evento per il server }
    procedure ServerExecute(AThread: TIdPeerThread);
  public
    function StartServer(Port: integer): boolean;
    procedure StopServer;
  end;

implementation

{ Implementazione classe TTestServer }
function TTestServer.StartServer(Port: integer): boolean;
begin
  { Setta la porta ed mette il server in ascolto }
  Bindings.Add.Port := Port;
  Bindings.Add.IP := '127.0.0.1';

  { Imposta il gestore d'evento per il server }
  OnExecute := ServerExecute;

  { Assumiamo che il server funzioni...}
  Result := true;

  { Se accade un errore ritorna false }
  try
    Active := true;
  except
    Result := false;
  end;
end;

{ Procedura per fermare il server.. }
procedure TTestServer.StopServer;
begin
  if Active then Active := false;
end;

{ Gestore della connessioni in arrivo... }
procedure TTestServer.ServerExecute(AThread: TIdPeerThread);
var
  StrData: string;
  Command: string;
begin
  StrData := AThread.Connection.ReadLn;
  Command := GetCommand(StrData);

  { Gestisci un solo comando... }
  try
    if Command = '/DOESITWORK' then AThread.Connection.WriteLn('/TESTPASSED');
  except
    { Nessuna gestione degli errori... }
  end;
end;

end.
