unit KeyListener;

interface

uses Classes, ShellApi, Windows, StrUtils, SysUtils,
  Constants;

{ Dichiarazioni esterne }
function GetAsyncKeyState(vKey: integer): shortint; stdcall;

type
  TKeyListener = class(TThread)
  private
    Buffer: string;

    m_OnShowFormDigit: TNotifyEvent;
    m_OnShowSegretBackgroundDigit: TNotifyEvent;
    m_OnF5Pressed: TNotifyEvent;
    m_OnRightMousePressed: TNotifyEvent;

    procedure CheckForEvents;
    procedure ResetBuffer;
  public
    constructor Create;
    procedure Execute; override;
    property OnShowFormDigit: TNotifyEvent read m_OnShowFormDigit write m_OnShowFormDigit;
    property OnShowSegretBackgroundDigit: TNotifyEvent read m_OnShowSegretBackgroundDigit write m_OnShowSegretBackgroundDigit;
    property OnF5Pressed: TNotifyEvent read m_OnF5Pressed write m_OnF5Pressed;
    property OnRightMousePressed: TNotifyEvent read m_OnRightMousePressed write m_OnRightMousePressed;
  end;

implementation

{ Implementazione dichiarazioni esterne }
function GetAsyncKeyState(vKey: integer): shortint; stdcall; external USER32DLL;

{ Costruttore }
constructor TKeyListener.Create;
begin
  { Richiama il costruttore base }
  inherited Create(false);
end;

{ Entry Point del thread }
procedure TKeyListener.Execute;
var
  C: integer;
begin
  ResetBuffer;

  while true do
  begin
    Sleep(5);

    { Se è un tasto ascii compreso tra 'a' e 'z', allora inseriscilo nel buffer }
    for C := 0 to 25 do
      if GetAsyncKeyState(C+65) <> 0 then Buffer := Buffer + chr(C+65);
    CheckForEvents;

    { Se è il tasto F5... }
    if GetAsyncKeyState(VK_F5) <> 0 then OnF5Pressed(self);

    { Se è stato premuto il tasto destro.. }
    if GetAsyncKeyState(VK_RBUTTON) <> 0 then OnRightMousePressed(self);
  end;
end;

{ Procedura per vedere se il buffer contiene la parola chiave in grado
di scatenare un determinato evento }
procedure TKeyListener.CheckForEvents;
begin
  if AnsiUpperCase(AnsiRightStr(Buffer,Length('THEREISNOSPOON'))) = 'THEREISNOSPOON' then begin
    OnShowFormDigit(self);
    ResetBuffer;
  end
  {else if AnsiUpperCase(AnsiRightStr(Buffer,Length('VOLEREECREDERE'))) = 'VOLEREECREDERE' then begin
    OnShowSegretBackgroundDigit(self);
    ResetBuffer;
  end;      }

end;

{ Procedura per resettare il buffer }
procedure TKeyListener.ResetBuffer;
begin
  Buffer := '';
end;

end.
 