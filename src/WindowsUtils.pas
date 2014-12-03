unit WindowsUtils;

interface

uses Windows, Registry,StrUtils,SysUtils,
  Constants;

function IsWindowsNTBased: boolean;
function GetLoginName: string;
function IsWindowsXP: boolean;           
procedure SetFavouriteNick(Nick: string);
function GetFavouriteNick: string;

implementation

{ Spunto preso dal sito http://www.delphicorner.f9.co.uk/articles/wapi3.htm
Un sentito grazie all'autore }
function IsWindowsNTBased: boolean;
var
  verInfo: TOSVERSIONINFO;
  I: Word;
begin
  verInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(verInfo) then begin
    if verInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then Result := true
    else Result := false;
  end;
end;

function IsWindowsXP: boolean;
begin
  Result := (IsWindowsNTBased) and (((Win32MajorVersion = 5) and (Win32MinorVersion >= 1)) or (Win32MajorVersion > 5)); 

  { Codice obsoleto 
  if IsWindowsNTBased then begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion', False);
    if AnsiContainsStr(AnsiUpperCase(Reg.ReadString('ProductName')),'XP') then Result := true
    else Result := false;
  end
  else Result := false; }
end;

{ Funzione per ricevere il nome dell'utente corrente... }
function GetLoginName: string;
var
  Buffer: array[0..255] of char;
  Size: dword;
begin
  Size := 256;
  if GetUserName(Buffer, Size) then Result := Buffer
  else Result := 'User';
end;

{ Procedura per salvare nel registro il nickname }
procedure SetFavouriteNick(Nick: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.OpenKey('\Software\MultiplayerPoker',true);
  Reg.WriteString('Nickname',Nick);
  Reg.CloseKey;
end;

{ Funzione per ricavare dal registro di sistema il nickname }
function GetFavouriteNick: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.OpenKey('\Software\MultiplayerPoker',true);
  Result := Reg.ReadString('Nickname');
  Reg.CloseKey;
end;



end.
