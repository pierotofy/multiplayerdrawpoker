unit LanScanner;

interface

uses Classes, ServerInfoList, StdCtrls, Windows, ScanNetwork,
  Constants;

type
  TLanScanner = class(TThread)
  protected
    AOwner: TComponent;
    m_Servers: TServerInfoList;
    ListBox: TListBox;
  public
    constructor Create(AOwner: TComponent; ListBox: TListBox; ServerList: TServerInfoList);
    procedure Execute; override;
    property Servers: TServerInfoList read m_Servers;
  end;

implementation

{ Costruttore }
constructor TLanScanner.Create(AOwner: TComponent; ListBox: TListBox; ServerList: TServerInfoList);
begin
  { Inzializza la lista dei servers }
  m_Servers := ServerList;
  self.AOwner := AOwner;
  self.ListBox := ListBox;

  { Richiama il costruttore base }
  inherited Create(false);
end;

{ Entry Point }
procedure TLanScanner.Execute;
begin
  ScanLocalAreaNetwork(AOwner,ListBox,m_Servers);
end;


end.
