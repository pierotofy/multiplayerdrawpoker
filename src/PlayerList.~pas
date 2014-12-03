unit PlayerList;

interface

uses Windows, Classes, SysUtils, Player,
  Constants;

type
  TPlayerList = class(TList)
  private
    MaxPlayers: integer;
  public
    constructor Create(MaxPlayers: integer);

    procedure AddPlayer(Player: TPlayer);
    function GetPlayer(Index: integer): TPlayer;
    function GetPlayerWithId(Id: integer): TPlayer;
    procedure DeletePlayerWithId(Id: integer);
    function PlayerIdExists(Id: integer): boolean;
    procedure Clear; override;
  end;

implementation

{ Implementazione classe TPlayerList }
constructor TPlayerList.Create(MaxPlayers: integer);
begin
  self.MaxPlayers := MaxPlayers;
end;

{ Procedura che inserisce un client nella lista }
procedure TPlayerList.AddPlayer(Player: TPlayer);
begin
  { Se un giocatore con questo id esiste già, non fare nulla (errore di threading)
  e nascondi il giocatore "fantasma" }
  if PlayerIdExists(Player.Id) then begin
    GetPlayerWithId(Player.Id).Hide;
    DeletePlayerWithId(Player.Id);
  end;

  if self.Count < MaxPlayers then
    self.Add(Player)
  else begin
    { Obsoleto: Stiamo cercando di aggiungere un giocatore di troppo, problema del multithreading,
    ma noi che siamo furbi, cancelliamo il giocatore "clone" e lo inseriamo correttamente }
    //DeletePlayerWithId(Player.Id);
    //self.Add(Player);
  end;
  // raise Exception.Create('Si è tentato di aggiungere un elemento di troppo nella lista dei giocatori. Contattare il produttore.');
end;

{ Funzione che restituisce un oggetto TPlayer in base all'index }
function TPlayerList.GetPlayer(Index: integer): TPlayer;
begin
  Result := TPlayer(self.Get(Index));
end;

{ Funzione che restituisce un oggetto TPlayer in base all'id }
function TPlayerList.GetPlayerWithId(Id: integer): TPlayer;
var
  C: integer;
  Player: TPlayer;
begin
  for C := 0 to self.Count-1 do
  begin
    Player := GetPlayer(C);
    if Player.Id = Id then begin
      Result := Player;
      exit;
    end;
  end;

  { Non è stato trovato nessun giocatore con questo id, scatena un eccezzione }
  raise Exception.Create('Si è cercato di recuperare dalla lista il giocatore con Id: ' + IntToStr(Id) + ', ma non è stato trovato. Contattare il produttore');
end;

{ Procedura per cancellare un giocatore con un determinato Id }
procedure TPlayerList.DeletePlayerWithId(Id: integer);
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
  begin
    if GetPlayer(C).Id = Id then begin
      Delete(C);
      exit;
    end;
  end;

  { Non è stato trovato nessun giocatore con questo id, scatena un eccezzione }
  raise Exception.Create('Si è cercato di cancellare dalla lista il giocatore con Id: ' + IntToStr(Id) + ', ma non è stato trovato. Contattare il produttore');
end;

{ Procedura che elimina tutti i giocatori
(prima di eliminarli, li nasconde per non visualizzarli nel form) }
procedure TPlayerList.Clear;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    GetPlayer(C).Hide;

  inherited Clear;
end;

{ Funzione che ritorna true se un giocatore
con un determinato id esiste }
function TPlayerList.PlayerIdExists(Id: integer): boolean;
var
  C: integer;
begin
  for C := 0 to self.Count-1 do
    if GetPlayer(C).Id = Id then begin
      Result := true;
      exit;
    end;
  Result := false;
end;

end.
 