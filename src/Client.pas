unit Client;

interface

uses Classes, SysUtils, IdTcpServer,
  Hand, Constants;

type
  TClient = class
  private
    m_Nickname: string;
    m_Id: integer;
    m_Hand: THand;
    m_IsPlaying: boolean;
    m_HasChangedCards: boolean;
    m_MoneyToBet: integer;
    m_WannaSee: boolean;
    m_CalledWords: boolean;
    m_CalledCip: boolean;
    m_ShowedCards: boolean;

    function GetNickname: string;
    function GetId: integer;
    function GetHand: THand;
    function GetIsPlaying: boolean;
    procedure SetIsPlaying(IsPlaying: boolean);
    function GetHasChangedCards: boolean;
    procedure SetHasChangedCards(HasChangedCards: boolean);
  public
    Money: integer;
    AThread: TIdPeerThread;

    procedure AddMoneyToBet(Money: integer);
    
    constructor Create(AThread: TIdPeerThread; Id: integer; Nickname: string; Money: integer);

    property Nickname: string read GetNickname;
    property Id: integer read GetId;
    property Hand: THand read GetHand;
    property IsPlaying: boolean read GetIsPlaying write SetIsPlaying;
    property HasChangedCards: boolean read GetHasChangedCards write SetHasChangedCards;
    property MoneyToBet: integer read m_MoneyToBet write m_MoneyToBet;
    property WannaSee: boolean read m_WannaSee write m_WannaSee;
    property CalledWords: boolean read m_CalledWords write m_CalledWords;
    property CalledCip: boolean read m_CalledCip write m_CalledCip;
    property ShowedCards: boolean read m_ShowedCards write m_ShowedCards;
  end;

implementation

{ Implementazione classe TClient }
constructor TClient.Create(AThread: TIdPeerThread; Id: integer; Nickname: string; Money: integer);
begin
  self.AThread := AThread;
  self.m_Id := Id;
  self.Money := Money;
  self.m_Nickname := Nickname;
  self.m_Hand := THand.Create;
  MoneyToBet := 0;
  WannaSee := false;
  CalledWords := false;
  CalledCip := false;
end;

{ Funzione che restituisce il nickname }
function TClient.GetNickname: string;
begin
  Result := m_Nickname;
end;

{ Funzione che restituisce l'id }
function TClient.GetId: integer;
begin
  try
    Result := m_Id
  except
    raise Exception.Create('Si è verificato un errore di accesso alla memoria per la variabile m_Id in TClient.GetId. Contattare il produttore');
  end;
end;

{ Funzione che restituisce la variabile che controlla
se il giocatore sta giocando la mano oppure si è ritirato }
function TClient.GetIsPlaying: boolean;
begin
  Result := m_IsPlaying;
end;

{ Procedura che setta il valore della variabile m_IsPlaying }
procedure TClient.SetIsPlaying(IsPlaying: boolean);
begin
  m_IsPlaying := IsPlaying;
end;

{ Funzione che restituisce la variabile che controlla se il giocatore
ha gia cambiato le carte oppure no }
function TClient.GetHasChangedCards: boolean;
begin
  Result := m_HasChangedCards;
end;

{ Procedura che setta il valore della variabile m_HasChangedCards }
procedure TClient.SetHasChangedCards(HasChangedCards: boolean);
begin
  m_HasChangedCards := HasChangedCards;
end;

{ Procedura per aggiungere del denaro da puntare }
procedure TClient.AddMoneyToBet(Money: integer);
begin
  MoneyToBet := MoneyToBet + Money;
end;


{ Funzione che restituisce la mano }
function TClient.GetHand: THand;
begin
  if Assigned(m_Hand) then Result := m_Hand
  else raise Exception.Create('L''oggetto Hand è stato richiamato ma non è ancora inizializzato. Contattare il produttore.');
end;





end.
