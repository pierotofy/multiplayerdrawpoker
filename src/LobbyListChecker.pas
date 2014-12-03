unit LobbyListChecker;

interface

uses Windows, LanScanner, Classes, ServerInfoList, StdCtrls, AsyncServerInfo, ServerInfo,
  Constants, Languages;

{ Classe derivata da TLanScanner, stessa base, solamente che deve operare in internet
e non in intranet }

type
  TLobbyListChecker = class(TLanScanner)
  public
    procedure Execute; override;
  end;

implementation

{ Implementazione classe TLobbyListChecker }
procedure TLobbyListChecker.Execute;
var
  C: integer;
  ServerListChecked: TServerInfoList;
begin
  { Inizializza le variabili }
  ServerListChecked := TServerInfoList.Create;

  { Imposta lo stile della ListBox }
  ListBox.Clear;
  ListBox.AddItem(GetStr(146),nil);
  ListBox.Enabled := false;
  ListBox.Refresh;

  { NOTA: Servers è ereditata e contiene una lista NON controllata,
  ServerListChecked è locale e contiene la lista CONTROLLATA }
  for C := 0 to Servers.Count-1 do
    TAsyncServerInfo.Create(AOwner,Servers.GetServerInfo(C).Host, Servers.GetServerInfo(C).Port, ServerListChecked, INTERNETTIMEOUT);

  { Attende il timeout predefinito + un tot in attesa che tutti i thread finiscano... }
  Sleep(INTERNETTIMEOUT + 2000);

  { Riempie la listbox }
  ServerListChecked.FillListBox(ListBox);

  { E riabilita il suo uso }
  ListBox.Enabled := true;
  ListBox.Refresh;
end;


end.
