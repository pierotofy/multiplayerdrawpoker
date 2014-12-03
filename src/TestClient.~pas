unit TestClient;

interface

uses Windows, IdTcpClient, Classes, IdTcpServer, SysUtils,
  Constants;

type
  TTestClient = class(TThread)
  private
    ClientSocket: TIdTcpClient;
    AThread: TIdPeerThread;
  public
    constructor Create(AOwner: TComponent; Host: string; Port: integer; AThread: TIdPeerThread); overload;
    function DoConnectTest: boolean;
    function DoMessageTest: boolean;
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TTestClient }
constructor TTestClient.Create(AOwner: TComponent; Host: string; Port: integer; AThread: TIdPeerThread);
begin
  ClientSocket := TIdTcpClient.Create(AOwner);

  ClientSocket.Host := Host;
  ClientSocket.Port := Port;
  self.AThread := AThread;

  inherited Create(false);
end;

{ Entry Point del thread }
procedure TTestClient.Execute;
begin
  AThread.Connection.WriteLn('/CONNECTIONTESTRESULT'+SEPARATOR+BoolToStr(DoConnectTest));
  AThread.Connection.WriteLn('/MESSAGETESTRESULT'+SEPARATOR+BoolToStr(DoMessageTest));
end;

{ Test di connessione... }
function TTestClient.DoConnectTest: boolean;
begin
  { Se era gia connesso, disconnetti prima... }
  if ClientSocket.Connected then ClientSocket.Disconnect;

  { Assumiamo che funzioni... }
  Result := true;
  try
    { Connette la socket al server }
    ClientSocket.Connect(TIMEOUT);
  except
    Result := false;
  end;
end;

{ Test di invio messaggi... }
function TTestClient.DoMessageTest: boolean;
begin
  { Usiamo il test di connessione per connettere la socket.. }
  if DoConnectTest then begin
    try
      ClientSocket.WriteLn('/DOESITWORK');
      if ClientSocket.ReadLn(#$A,TIMEOUT) = '/TESTPASSED' then Result := true
      else Result := false;
    except
      Result := false;
    end;
  end
  else Result := false;

  if ClientSocket.Connected then ClientSocket.Disconnect;
end;

end.
