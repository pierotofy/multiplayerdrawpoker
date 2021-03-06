unit ClientList;

interface

uses Windows, Classes, SysUtils, Client, IdTcpServer,
  Constants;

type
  TClientList = class(TList)
  private
    MaxPlayers: integer;
  public
    constructor Create(MaxPlayers: integer);

    procedure AddClient(Client: TClient);
    function GetClient(Index: integer): TClient; overload;
    function GetClient(AThread: TIdPeerThread): TClient; overload;
    function GetClientWithId(Id: integer): TClient;
    function IdExists(Id: integer): boolean;
    procedure DeleteClient(AThread: TIdPeerThread);
    procedure AddMoneyToBetExcept(Money: integer; Client: TClient);
    procedure AddMoneyToBet(Money: integer);
    procedure ResetMoneyToBet;
    function AllWannaSee: boolean;
    function AllWannSeeExcept(ExpClient: TClient): boolean;
    function AllBetTheirSum: boolean;
    function AllCalledWords: boolean;
    function AllCalledCip: boolean;
    function OnlyOnePlayerIsPlaying: boolean;
    function SomeoneWannaSee: boolean;
    procedure ResetWannaSee;
    procedure ResetCalledWords;
    procedure ResetCalledCip;
    function IsThisPeerThreadInList(AThread: TIdPeerThread): boolean;
  end;

implementation

{ Implementazione classe TClientList }
constructor TClientList.Create(MaxPlayers: integer);
begin
  self.MaxPlayers := MaxPlayers;
end;

{ Procedura che inserisce un client nella lista }
procedure TClientList.AddClient(Client: TClient);
begin
  if self.Count < MaxPlayers then
    self.Add(Client)
  else raise Exception.Create('Si � tentato di aggiungere un elemento di troppo nella lista dei clients. Contattare il produttore.');
end;

{ Funzione che restituisce un oggetto TClient }
function TClientList.GetClient(Index: integer): TClient;
begin
  Result := TClient(self.Get(Index));
end;

{ Funzione che ritorna true se qualcuno ha chiamato vedo }
function TClientList.SomeoneWannaSee: boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := false;

  for C := 0 to self.Count-1 do
  begin
    Client := GetClient(C);
    if (Client.IsPlaying) and (Client.WannaSee) then begin
      Result := true;
      exit;
    end;
  end;
end;

{ Funzione che restituisce un oggetto TClient a partire
dal suo id }
function TClientList.GetClientWithId(Id: integer): TClient;
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to self.Count - 1 do
  begin
    Client := GetClient(C);
    if Client.Id = Id then begin
      Result := Client;
      exit;
    end;
  end;
end;


{ Funzione che ritorna true quando tutti i giocatori hanno puntato
le loro somme }
function TClientList.AllBetTheirSum: boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := true;
  for C := 0 to self.Count-1 do
  begin
    Client := GetClient(C);
    if (Client.IsPlaying) and (Client.MoneyToBet > 0) then begin
      Result := false;
      exit;
    end;
  end;
end;

{ Funzione che ritorna true se tutti i giocatori tranna quello
passato come argomento hanno chiamato "Vedo" }
function TClientList.AllWannSeeExcept(ExpClient: TClient): boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := true;

  for C := 0 to self.Count - 1 do
  begin
    Client := GetClient(C);
    if (ExpClient.Id <> Client.Id) and (Client.IsPlaying) and (not Client.WannaSee) then begin
      Result := false;
      exit;
    end;
  end;
end;

{ Funzione che restituisce un oggetto TClient (overloadato)
a partire dal suo peerthread }
function TClientList.GetClient(AThread: TIdPeerThread): TClient;
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to self.Count - 1 do
  begin
    Client := GetClient(C);
    if Client.AThread.Handle = AThread.Handle then begin
      Result := Client;
      exit;
    end;
  end;
end;

{ Funzione che restituisce true se il PeerThread corrisponde ad uno
degli oggetti PeerThread in TClient (quindi per vedere se � una connessione
appartenente ad un client connesso e loggato correttamente) }
function TClientList.IsThisPeerThreadInList(AThread: TIdPeerThread): boolean;
var
  C: integer;
begin
  Result := false;
  for C := 0 to self.Count-1 do
    if GetClient(C).AThread.Handle = AThread.Handle then begin
      Result := true;
      exit;
    end;
end;

{ Procedura per eliminare un client a partire dal suo peerthread }
procedure TClientList.DeleteClient(AThread: TIdPeerThread);
var
  C: integer;
  Client: TClient;
begin
  for C := 0 to self.Count - 1 do
  begin
    Client := GetClient(C);
    if Client.AThread.Handle = AThread.Handle then begin
      self.Delete(C);
      exit;
    end;
  end;
end;

{ Funzione per sapere se esiste nella lista un certo ID }
function TClientList.IdExists(Id: integer): boolean;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
  begin
    if GetClient(C).Id = Id then begin
      Result := true;
      exit;
    end;
  end;
  Result := false;
end;

{ Procedura che aggiunge del denaro da puntare a tutti i giocatori
tranne uno }
procedure TClientList.AddMoneyToBetExcept(Money: integer; Client: TClient);
var
  C: integer;
  ClientToBet: TClient;
begin
  for C := 0 to self.Count-1 do
  begin
    ClientToBet := GetClient(C);
    if ClientToBet.Id <> Client.Id then ClientToBet.AddMoneyToBet(Money);
  end;
end;

{ Procedura che aggiunge del denaro da puntare a tutti i giocatori }
procedure TClientList.AddMoneyToBet(Money: integer);
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetClient(C).AddMoneyToBet(Money);
end;

{ Procedura che setta a zero il valore da puntare }
procedure TClientList.ResetMoneyToBet;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetClient(C).MoneyToBet := 0;
end;

{ Funzione per vedere se tutti hanno chiamato parole }
function TClientList.AllCalledWords: boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := true;

  for C := 0 to self.Count-1 do
  begin
    Client := GetClient(C);
    if Client.IsPlaying and (not Client.CalledWords) then begin
      Result := false;
      exit;
    end;
  end;
end;

{ Funzione per vedere se tutti vogliono vedere... }
function TClientList.AllWannaSee: boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := true;

  for C := 0 to self.Count-1 do
  begin
    Client := GetClient(C);
    if Client.IsPlaying and (not Client.WannaSee) then begin
      Result := false;
      exit;
    end;
  end;
end;

{ Funzione per vedere se tutti hanno chiamato Cip... }
function TClientList.AllCalledCip: boolean;
var
  C: integer;
  Client: TClient;
begin
  Result := true;

  for C := 0 to self.Count-1 do
  begin
    Client := GetClient(C);
    if Client.IsPlaying and (not Client.CalledCip) then begin
      Result := false;
      exit;
    end;
  end;
end;

{ Procedura per resettare lo stato di volont� per vedere }
procedure TClientList.ResetWannaSee;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetClient(C).WannaSee := false;
end;

{ Procedura per resettare lo stato di chiamata Parole }
procedure TClientList.ResetCalledWords;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetClient(C).CalledWords := false;
end;

{ Procedura per resettare lo stato di chiamata Cip }
procedure TClientList.ResetCalledCip;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetClient(C).CalledCip := false;
end;

{ Funzione per vedere se � rimasto un solo giocatore a giocare }
function TClientList.OnlyOnePlayerIsPlaying: boolean;
var
  C: integer;
  PlayerPlayingCount: integer;
begin
  PlayerPlayingCount := 0;

  for C := 0 to self.Count-1 do
  begin
    if GetClient(C).IsPlaying then inc(PlayerPlayingCount);
  end;

  if PlayerPlayingCount = 1 then Result := true
  else Result := false;
end;


end.
 