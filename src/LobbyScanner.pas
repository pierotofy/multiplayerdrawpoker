unit LobbyScanner;

interface

uses LobbyServer, Constants, Classes, Windows;

{ TLobbyScanner eredita da TThread }
type
  TLobbyScanner = class(TThread)
  private
    LobbyServer: TLobbyServer; //Riferimento all'oggetto LobbyServer
  public
    constructor Create(LobbyServer: TLobbyServer);
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TLobbyScanner }
constructor TLobbyScanner.Create(LobbyServer: TLobbyServer);
begin
  { Salva il riferimento alla lista e richiama il costruttore base }
  self.LobbyServer := LobbyServer;
  inherited Create(false);
end;

{ Entry Point del Thread }
procedure TLobbyScanner.Execute;
var
  C: integer;
begin
  { Ciclo infinito che analizza l'esistenza o meno delle partite }
  while true do
  begin
    { Se ci sono elementi comincia ad analizzare }
    if LobbyServer.GetGamesCount > 0 then begin

      { Adoperiamo il sistema sincrono per controllare l'esistenza effettiva di un game, cos�
      evitiamo di sovvracaricare eccessivamente la rete e la cpu (anche se perdiamo un po'
      in real time) }
      for C := 0 to LobbyServer.GetGamesCount-1 do
      begin

        { Se abbiamo trovato una partita che non � disponibile, cancelliamola
        e avvisiamo i clients del cambiamento }
        if not LobbyServer.GetGame(C).IsAvaible then begin
          LobbyServer.DeleteGame(C);
          LobbyServer.SendGameListToAll;
        end;
      end;
    end
    { Altrimenti riposa un po'.. }
    else begin
      Sleep(LOBBYSCANNERSLEEP);
    end;
  end;
end;

end.
 