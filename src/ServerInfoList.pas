unit ServerInfoList;

interface

uses Classes, SysUtils, StdCtrls, ServerInfo,
  Constants;

type
  TServerInfoList = class(TList)
  public
    procedure AddServerInfo(ServerInfo: TServerInfo);
    function GetServerInfo(Index: integer): TServerInfo;

    procedure FillListBox(ListBox: TListBox);
  end;

implementation

{ Implementazione classe TServerInfoList }

{ Procedura per inserire un nuovo oggetto ServerInfo }
procedure TServerInfoList.AddServerInfo(ServerInfo: TServerInfo);
begin
  self.Add(ServerInfo);
end;

{ Funzione per prelevare un oggetto ServerInfo }
function TServerInfoList.GetServerInfo(Index: integer): TServerInfo;
begin
  Result := TServerInfo(self.Get(Index));
end;


{ Procedura per riempire una listbox con il contenuto della lista }
procedure TServerInfoList.FillListBox(ListBox: TListBox);
var
  C: integer;
begin
  { Svuota la listbox }
  ListBox.Clear;

  { E la riempie }
  for C := 0 to self.Count-1 do
    ListBox.AddItem(GetServerInfo(C).GetServerName,TObject(GetServerInfo(C)));
end;

end.
