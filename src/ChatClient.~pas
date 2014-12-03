unit ChatClient;

interface

uses Classes, IdTcpClient, Chat, SysUtils, Messages,
  Constants, Languages;

type
  TChatClient = class(TThread)
  private
    FrmChat: TFrmChat;
    ClientSocket: TIdTcpClient;
    Host: string;
    Port: integer;
    Nickname: string;

    { Evento che viene scatenato all'arrivo di un messaggio }
    m_OnChatMessageArrival: TNotifyEvent;

    procedure AppendMsg(Msg: string);

    { Gestore d'evento per il pulsane della chat }
    procedure BtnSend_Click(Sender: TObject);

    { Gestore d'evento per la connessione }
    procedure ClientSocket_Connected(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; FrmChat: TFrmChat; ChatMessage_Arrival: TNotifyEvent; Nickname: string; Host: string; Port: integer = 6667);
    procedure Execute; override;
    destructor Destroy; override;
    property OnChatMessageArrival: TNotifyEvent read m_OnChatMessageArrival write m_OnChatMessageArrival;
  end;

implementation

{ Implementazione classe TChatClient }
constructor TChatClient.Create(AOwner: TComponent; FrmChat: TFrmChat; ChatMessage_Arrival: TNotifyEvent; Nickname: string; Host: string; Port: integer = 6667);
begin
  { Richiama il costruttore base }
  inherited Create(false);

  self.FrmChat := FrmChat;
  self.OnChatMessageArrival := ChatMessage_Arrival;
  self.Host := Host;
  self.Port := Port;
  self.Nickname := Nickname;

  { Imposta il gestore d'evento per il pulsante send della chat }
  FrmChat.BtnSend.OnClick := BtnSend_Click;
  FrmChat.BtnSend.Enabled := true;

  { Crea la socket }
  ClientSocket := TIdTcpClient.Create(AOwner);

  { Imposta i gestori d'evento per la socket }
  ClientSocket.OnConnected := ClientSocket_Connected;

  ClientSocket.Host := Host;
  ClientSocket.Port := Port;

  try
    { Connette la socket al server }
    ClientSocket.Connect(TIMEOUT);
  except
    { Gestione degli errori silenziosa, se non si è potuto connettere allora
    disabilitiamo la chat e informiamo l'utente }
    AppendMsg(GetStr(120,Host + ',' + IntToStr(Port)));
    FrmChat.BtnSend.Enabled := false;
  end;
end;

{ Distruttore dell'oggetto }
destructor TChatClient.Destroy;
begin
  { Disconnette la socket }
  if ClientSocket.Connected then begin
    { Avvisa il server che ce ne andiamo }
    ClientSocket.WriteLn('/IDISCONNECT');

    { Disconnetti }
    ClientSocket.Disconnect;
  end;
  inherited Destroy;
end;

{ Entry Point del Thread }
procedure TChatClient.Execute;
var
  StrData: string;
  Command: string;
begin
  try
    while ClientSocket.Connected do
    begin
      StrData := ClientSocket.ReadLn;
      Command := GetCommand(StrData);

      { Il server ci avvisa che è in arrivo un messaggio di chat..
      Command = '/MSG_Message'  }
      if Command = '/MSG' then begin
        AppendMsg(GetToken(StrData,1));
        { Scatena l'evento }
        OnChatMessageArrival(TObject(0));
      end;

    end;
  except
    { Gestione silenziosa degli errori }
    FrmChat.BtnSend.Enabled := false;
    AppendMsg(GetStr(121,Host + ',' + IntToStr(Port)));
  end;

end;

{ Procedura che aggiunge un testo alla chat }
procedure TChatClient.AppendMsg(Msg: string);
begin
  FrmChat.txtChat.Lines.Append(Msg);
  FrmChat.txtChat.Perform(EM_SCROLLCARET,0,0);
end;


{ Procedura per inviare un messaggio di chat al server }
procedure TChatClient.BtnSend_Click(Sender: TObject);
begin
  if FrmChat.txtMessage.Text <> '' then begin
    ClientSocket.WriteLn('/MSG'+SEPARATOR+FrmChat.txtMessage.Text);
    FrmChat.txtMessage.Text := '';
  end;
end;

{ Procedura che viene eseguita al momento della connessione remota con il server }
procedure TChatClient.ClientSocket_Connected(Sender: TObject);
begin
  { Chiediamo di loggarci al server }
  ClientSocket.WriteLn('/LOGIN'+SEPARATOR+Nickname);
end;


end.
