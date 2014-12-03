unit Constants;

interface

uses Windows, Mmsystem;

{ Costanti usate nel programma }

Const PROGRAMVERSION = '3.2';
Const PROGRAMNAME = 'Multiplayer Draw Poker' + ' ' + PROGRAMVERSION;
Const LOBBYVERSION = '1.0';

const SHUFFLEREPEAT = 18;

{ Costante che indica il numero massimo di Slots }
Const MAXSLOTS = 4;

{ Enumerazione per la modalità selezionata }
type TGameChoice = (gcHost, gcJoin, gcConnectLobby);


const CARDSDLL = 'cards.dll';
  USER32DLL = 'user32.dll';

const WAVPLAYERCONNECTED = 1;
  WAVDISTROCARD = 2;
  WAVNEWMESSAGE = 3;

const FRONTCARD = 0;
  BACKGROUNDCARD = 1;

const FACECOUNT = 4;

const MAXNICKNAMELENGTH = 9;

type
  TFace = (Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King);
type
  TSuit = (Clubs, Diamonds, Hearts, Spades);
type
  TBackground = (CrossHatch = 53, Weave1, Weave2, Robot, Flowers, Vine1, Vine2, Fish1, Fish2, Shells, Castle, Island, Cardhand, Unused, The_X, The_O);

const CARDSPACING = 15;
  NICKBORDERSPACING = 3;
  NICKPX4ONECHAR = 6;
  NICKHEIGHT = 16;
  CARDBORDERSPACING = 20;
  STATUSBARHEIGHT = 20;
  CARDMOVEVALUE = 12;

type
  THandPosition = (hpBottom, hpLeft, hpTop, hpRight);
type
  THandScore = (HighCard, Pair, TwoPair, Tris, Straight, Full, Flush, Poker, RoyalFlush);

type
  TMoneyPosition = (mpCenter, mpLeftBottom, mpLeftTop, mpRightBottom, mpRightTop);
type
  TMoneySize = (msNormal, msSmall);

type
  TPanelMode = (pmStartGame, pmChangeCards, pmPlayPassRelaunch, pmOpenOrPass, pmPass, pmCipOrRelaunchOrSeeOrWordsOrPass, pmRelaunchOrSeeOrWordsOrPass, pmRelaunchOrSeeOrPass, pmCipOrRelaunchOrSeeOrPass, pmBeginTurn, pmShowCardsOrDontShowCards, pmGeneralBet, pmOpenBet, pmFirstBet, pmRelaunchBet, pmSeeBet);

type
  TF5State = (fsActive, fsNotActive);

Const LABELNORMALHEIGHT = 23;
  LABELNORMALWIDTH = 130;
  LABELSPACING = 1;
Const MONEYBORDERSPACING = 20;
  MONEYEXTRAVALUE = 70;

Const TABLEEXTRASPACING = 80;
  TABLETOPADJUSTVALUE = 10;
  TABLELEFTADJUSTVALUE = 0;
  TABLEEXTRAWIDTH = 40;

Const BUTTONPANELBORDERSPACING = 15;
  BUTTONBORDERSPACING = 5;
  BUTTONTOPADJUSTVALUE = 2;
  BUTTONEXTRASIZE = 10;
  CONTROLSSPACING = 8;

Const DEFAULTPORT = 1500;
  CHATPORT = 6667;
  LOBBYPORT = 1501;

Const PROJECTHOMEPAGE = 'http://www.multiplayer-draw-poker.org';
Const DONATEPAGE = 'https://sourceforge.net/project/project_donations.php?group_id=300479';
Const SUBMITBUGPAGE = 'https://sourceforge.net/tracker/?func=add&group_id=300479&atid=1267293';
Const GATEWAYLISTFILE = 'http://www.pierotofy.it/data/projects/27/gatewaylist.php';
Const UPDATEFILE = 'http://www.pierotofy.it/data/projects/27/update.php';

Const LOBBYSCANNERSLEEP = 5000;

Const SEPARATOR = '¿';
Const GATEWAYSEPARATOR = '¿';

Const SERVERMESSAGESTART = '***';

Const TIMEOUT = 1000;
Const INTERNETTIMEOUT = 8000;
Const GATEWAYTIMEOUT = 2000;
Const READTIMEOUT = 200;

Const LOCALANIMATIONTIME = 380;
  ENEMYANIMATIONTIME = 50;

Const BUTTONDELAYTIMER = 10;
Const LOOPTIMES = 2;

{ Variabile globale per tener traccia dei giocatori che stanno giocando
in modo da poter sapere qual'è la carta più piccola.. }
var
  CurrentPlayingPlayers: integer;

function GetFaceValue(Face: TFace): integer;
function GetSuitValue(Suit: TSuit): integer;

function GetToken(StrData: string; Index: integer): string;
function GetCommand(StrData: string): string;

procedure SetCurrentPlayingPlayers(Value: integer);
function GetMinCardFace: TFace;

function MakeServerMessage(Msg: string): string;
procedure PlayResSound(ResIndex: integer);

implementation

function GetFaceValue(Face: TFace): integer;
begin
  if Face = Ace then Result := Integer(King)+2
  else Result := Integer(Face)+1;
end;

function GetSuitValue(Suit: TSuit): integer;
begin
  case Suit of
    Hearts:
      Result := 3;
    Diamonds:
      Result := 2;
    Clubs:
      Result := 1;
    Spades:
      Result := 0;
    { Solo per questioni di compilazione... }
    else Result := 0;
  end;
end;

{ Funzione per settare il numero di giocatori che stanno giocando... }
procedure SetCurrentPlayingPlayers(Value: integer);
begin
  CurrentPlayingPlayers := Value;
end;

{ Funzione che ritorna la faccia della carta più piccola... }
function GetMinCardFace: TFace;
begin
  Result := Seven; { Default }
  case CurrentPlayingPlayers of
    3: Result := Eight;
    2: Result := Nine;
  end;
end;

{ Funzione che ritorna un token a partire da una stringa }
function GetToken(StrData: string; Index: integer): string;
var
  C, Len, TokenCount: integer;
  StrToken: string;
begin
  Len := Length(StrData);
  TokenCount := 0;
  Result := '';

  for C := 1 to Len do
  begin
    if (StrData[C] = #10) or (StrData[C] = #13) then continue;

    if StrData[C] = SEPARATOR then begin
      if TokenCount = Index then begin
        Result := StrToken;
        exit;
      end;

      StrToken := '';
      inc(TokenCount);
    end
    else StrToken := StrToken + StrData[C];
  end;

  Result := StrToken;

end;

{ Funzione che ritorna il comando di un buffer }
function GetCommand(StrData: string): string;
begin
  Result := GetToken(StrData,0);
end;

{ Funzione che aggiunge la stringa di inizio e di fine predefinita per
i messaggi di sistema e del server }
function MakeServerMessage(Msg: string): string;
begin
  Result := SERVERMESSAGESTART + ' ' + Msg + ' ' + SERVERMESSAGESTART;
end;

{ Funzione per suonare un suono del file .res }
procedure PlayResSound(ResIndex: integer);
begin
  PlaySound(PChar(ResIndex),HInstance, snd_ASync or snd_Memory or snd_Resource);
end;

end.
