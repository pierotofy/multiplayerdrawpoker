{ Unit presa e modificata da http://www.aldyn.ru/
Un sentito grazie all'autore,
dal momento che non è completamente mia, è fatta abbastanza male dal punto di vista
del codice :/ }

//******************************************************************************
// Walk over network
// WNetOpenEnum example
//
// (c) 2000, Alexey Dynnikov <aldyn@aldyn.ru>
// http://www.aldyn.ru/
// Delphi components, examples and articles: services, performance, security...
//
// Feel free to use any or all source code, provided you retain the
// credit under my name.
//******************************************************************************

unit ScanNetwork;

interface

uses
  Windows, Classes, StrUtils, StdCtrls, AsyncServerInfo,
  Constants, ServerInfoList, Languages;

procedure ScanLocalAreaNetwork(AOwner: TComponent; ListBox: TListBox; Servers: TServerInfoList);
procedure LoadNetNode(NetNode: PNetResourceA);

var
  m_ListBox: TListBox;
  m_Servers: TServerInfoList;
  m_AOwner: TComponent;

implementation

uses
  SysUtils;

const InitialSize = $1;  // Any positive value is acceptable.

{ Funzione per scansionare la rete locale in cerca di partite... }
procedure ScanLocalAreaNetwork(AOwner: TComponent; ListBox: TListBox; Servers: TServerInfoList);
begin
  m_ListBox := ListBox;
  m_Servers := Servers;
  m_AOwner := AOwner;

  { Imposta lo stile della ListBox }
  ListBox.Enabled := false;
  ListBox.Clear;
  ListBox.Refresh;

  LoadNetNode(nil);

  { Attende il doppio del timeout predefinito in attesa che tutti i thread finiscano... }
  Sleep(TIMEOUT*2);

  { Riempie la listbox }
  Servers.FillListBox(ListBox);

  { E riabilita il suo uso }
  ListBox.Enabled := true;
  ListBox.Refresh;
end;

procedure LoadNetNode(NetNode: PNetResourceA);
var hEnum : THandle;
    Count,BufSize, Usage: DWORD;
    NR,Buf: PNetResourceA;
    R: Integer;
begin
    R:=WNetOpenEnum(RESOURCE_GLOBALNET,RESOURCETYPE_ANY,0{RESOURCEUSAGE_CONTAINER},NetNode,hEnum);
    if R <> NO_ERROR then exit;

    BufSize:=InitialSize; GetMem(Buf,BufSize);
    try
        while True do
        begin
            Count:=$FFFFFFFF; // I wish to read ALL items
            R:=WNetEnumResource(hEnum,Count, Buf, BufSize);

            if R = ERROR_MORE_DATA then // Oops ! The InitialSize is too small !
            begin
                Count:=$FFFFFFFF; // I wish to read ALL items
                FreeMem(Buf); GetMem(Buf,BufSize);
                R:=WNetEnumResource(hEnum,Count, Buf, BufSize);
            end;

            if R = ERROR_NO_MORE_ITEMS then Break; // All items are processed
            if R <> NO_ERROR then Abort; // R is the error code. Process it!

            NR:=Buf;

            while Count > 0 do
            begin
                { Elminina i nomi delle risorse... }
                if (NR.dwType <> RESOURCETYPE_DISK) and (NR.dwType <> RESOURCETYPE_PRINT) then begin
                    m_ListBox.Clear;
                    m_ListBox.AddItem(GetStr(163,NR.lpRemoteName),nil);
                    TAsyncServerInfo.Create(m_AOwner,NR.lpRemoteName,DEFAULTPORT,m_Servers);
                end;

                if AnsiStartsStr('\\',NR.lpRemoteName) then break;

                LoadNetNode(NR);

                // Go to the next record
                INC(NR);
                DEC(Count);
            end;
        end;
    finally
        WNetCloseEnum(hEnum); // Close handle
        FreeMem(Buf); // Free memory1
    end;
end;


initialization

finalization

end.
