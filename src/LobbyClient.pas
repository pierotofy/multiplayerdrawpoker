unit LobbyClient;

interface

uses Windows, SysUtils, IdTcpClient, IdHTTP, LobbyClientForm, Graphics, Classes, StrUtils,
  Constants, ChatClient, LobbyListChecker, ServerInfoList, ServerInfo, HostGame, Controls, WindowsUtils,
  ConnectionTest, TestServer, Languages;

{ Classe TLobbyGateway }
type
  TLobbyGateway = class
  public
    Host: string;
    Port: integer;

    constructor Create(Host: string; Port: integer);
  end;

{ Classe TLobbyClient }
type
  TLobbyClient = class(TThread)
  private
    GatewayList: TList;
    AOwner: TComponent; //Riferimento ad aowner
    FrmLobbyClient: TFrmLobbyClient;
    ClientSocket: TIdTcpClient;
    Nickname: string;
    Disconnecting: boolean;

    { Variabili per il test di connessione }
    FrmConnectionTest: TFrmConnectionTest;
    IAmAbleToHost: boolean;
    ConnectionTestDone: boolean;
    TestServer: TTestServer;

    procedure ReceiveGatewayList;
    procedure AddGateway(Host: string; Port: string);
    function PopGateway: TLobbyGateway;
    procedure Disconnect;

    { Gestore d'evento per i pulsanti }
    procedure BtnSend_Click(Sender: TObject);
    procedure BtnHost_Click(Sender: TObject);
    procedure BtnJoin_Click(Sender: TObject);

    { Gestore d'evento per la fine del test di connessione }
    procedure ConnectionTest_Finished(Sender: TObject);

    { Gestore d'evento per la connessione }
    procedure ClientSocket_Connected(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; FrmLobbyClient: TFrmLobbyClient; Nickname: string);
    procedure Execute; override;
    destructor Destroy; override;
  end;

implementation

{ Implementazione classe TLobbyGateway }
constructor TLobbyGateway.Create(Host: string; Port: integer);
begin
  self.Host := Host;
  self.Port := Port;
end;

{ Implementazione classe TLobbyClient }
constructor TLobbyClient.Create(AOwner: TComponent; FrmLobbyClient: TFrmLobbyClient; Nickname: string);
begin
  self.AOwner := AOwner;
  self.FrmLobbyClient := FrmLobbyClient;
  self.Nickname := Nickname;
  FrmLobbyClient.Nickname := Nickname;

  { Imposta il gestore d'evento per il pulsante send della chat }
  FrmLobbyClient.BtnSend.OnClick := BtnSend_Click;
  FrmLobbyClient.BtnSend.Enabled := false;

  { E quello per hostare e joinare }
  FrmLobbyClient.BtnHost.OnClick := BtnHost_Click;
  FrmLobbyClient.BtnHost.Enabled := false;
  FrmLobbyClient.BtnJoin.OnClick := BtnJoin_Click;
                                                                                                    
  { Crea la socket }                                                                              
  ClientSocket := TIdTcpClient.Create(AOwner);

  { Imposta i gestori d'evento per la socket }
  ClientSocket.OnConnected := ClientSocket_Connected;

  { Imposta una variabile che serve per vedere se ci stiamo disconnettendo }
  Disconnecting := false;

  { Richiama il costruttore base }
  inherited Create(false);
end;

{ Distruttore }
destructor TLobbyClient.Destroy;
begin
  { Se siamo connessi avvisa che ce ne stiamo andando... }
  Disconnect;

  inherited Destroy;
end;

{ Procedura per prendere un Gateway dalla lista }
function TLobbyClient.PopGateway: TLobbyGateway;
begin
  if GatewayList.Count = 0 then raise Exception.Create('Si è cercato di prendere un gateway dalla lista quando essa era vuota. Contattare il produttore.');
  Result := TLobbyGateway(GatewayList.Items[0]);
  GatewayList.Delete(0);
end;

{ Procedura per disconnettersi }
procedure TLobbyClient.Disconnect;
begin
  if ClientSocket.Connected then begin
    Disconnecting := true;
    ClientSocket.WriteLn('/IDISCONNECT');
    ClientSocket.Disconnect;
  end;
end;

{ Entry Point del thread }
procedure TLobbyClient.Execute;
var
  LobbyGateway: TLobbyGateway;
begin
  { Prima di tutto, riceviamo il file contentente la lista dei gateway disponibili... }
  FrmLobbyClient.ShowStatus(GetStr(153),clNavy);
  ReceiveGatewayList;
  //GatewayList := TList.Create;
  //AddGateway('localhost','1400');


  { Proviamo a connetterci ai gateway, uno alla volta con un timeout minimo }
  while (GatewayList.Count > 0) and (not ClientSocket.Connected) and (not Disconnecting) do
  begin
    LobbyGateway := PopGateway;
    ClientSocket.Host := LobbyGateway.Host;
    ClientSocket.Port := LobbyGateway.Port;

    FrmLobbyClient.ShowStatus(GetStr(154,ClientSocket.Host+','+IntToStr(ClientSocket.Port)));

    try
      { Prova a coonnettersi al gateway selezionato }
      ClientSocket.Connect(GATEWAYTIMEOUT);
    except
      on E: exception do
      begin
        { Gestione degli errori silenziosa, se non si è potuto connettere allora
        disabilitiamo la chat e informiamo l'utente }
        FrmLobbyClient.ShowStatus('Fallito - ' + E.Message,clGray);
        FrmLobbyClient.BtnJoin.Enabled := false;
        FrmLobbyClient.BtnHost.Enabled := false;
        FrmLobbyClient.BtnSend.Enabled := false;
      end;
    end;
  end;

  { Se abbiamo finito i gateway, notifica un messaggio di errore...(e qui finisce il thread...) }
  if not ClientSocket.Connected then FrmLobbyClient.ShowStatus(GetStr(155),clRed);
end;

{ Procedura per ricevere la lista dei gateway da internet }
procedure TLobbyClient.ReceiveGatewayList;
var
  HttpSocket: TIdHTTP;
  Response: string;
  Host, Port: string;
begin
  { Crea l'oggetto TIdHTTP }
  HttpSocket := TIdHTTP.Create(AOwner);
  HttpSocket.ReadTimeout := INTERNETTIMEOUT;

  { Inizializza la lista dei gateway }
  GatewayList := TList.Create;

  { Esegue la richiesta }                            
  Response := HttpSocket.Get(GATEWAYLISTFILE);

  { Se il file è vuoto, non c'è nessun gateway disponibile, altrimenti splitta la risposta }
  if Response = '' then FrmLobbyClient.ShowStatus(GetStr(156),clNavy)
  else begin

    { Response = 'Host Port_Host Port_Host Port..' }
    while Trim(Response) <> '' do         
    begin
      { Prende l'host, tronca, prende la porta e tronca, e così via... }
      Host := AnsiLeftStr(Response,AnsiPos(' ',Response)-1);
      Response := AnsiRightStr(Response,Length(Response)-AnsiPos(' ',Response));
      Port := AnsiLeftStr(Response,AnsiPos(GATEWAYSEPARATOR,Response)-1);
      Response := AnsiRightStr(Response,Length(Response)-AnsiPos(GATEWAYSEPARATOR,Response));

      { Aggiunge il gateway alla lista... }
      AddGateway(Host,Port);
    end;
  end;
end;

{ Procedura per aggiungere un gateway alla lista... }
procedure TLobbyClient.AddGateway(Host: string; Port: string);
begin
  GatewayList.Add(TLobbyGateway.Create(Host,StrToInt(Port)));
  FrmLobbyClient.ShowStatus(GetStr(157,Host+','+Port));
end;


{ Procedura per inviare un messaggio di chat al lobby }
procedure TLobbyClient.BtnSend_Click(Sender: TObject);
begin
  if FrmLobbyClient.txtMessage.Text <> '' then begin
    ClientSocket.WriteLn('/MSG'+SEPARATOR+FrmLobbyClient.txtMessage.Text);
    FrmLobbyClient.txtMessage.Text := '';
  end;
end;

{ Procedura che viene eseguita al momento della connessione remota con il server }
procedure TLobbyClient.ClientSocket_Connected(Sender: TObject);
var
  StrData: string;
  Command: string;
  C: integer;
  LobbyListChecker: TLobbyListChecker;
  ServerInfoList: TServerInfoList;
  OldUserListCount: integer;
  ServerMsg: string;
begin
  { OKK, abbiamo trovato un gateway! Evvai lol }
  FrmLobbyClient.ShowStatus(GetStr(158,ClientSocket.Host+','+IntToStr(ClientSocket.Port)),clGreen);

  { Abilitiamo i comandi ... }
  FrmLobbyClient.BtnSend.Enabled := true;
  FrmLobbyClient.BtnHost.Enabled := true;

  { Per PRIMA cosa controlliamo che il numero di versione del lobby corrisponda.. }
  ClientSocket.WriteLn('/MYLOBBYVERSIONIS'+SEPARATOR+LOBBYVERSION);
  StrData := ClientSocket.ReadLn;
  if GetCommand(StrData) = '/URLOBBYVERSIONISNOTSUPPORTED' then raise Exception.Create(GetStr(159,GetToken(StrData,1)+','+LOBBYVERSION));

  { Tutto a posto, chiediamo di loggarci al server }
  ClientSocket.WriteLn('/LOGIN'+SEPARATOR+Nickname);

  try
    while ClientSocket.Connected do
    begin
      StrData := ClientSocket.ReadLn;
      Command := GetCommand(StrData);

      { Il server ci avvisa che è in arrivo un messaggio di chat..
      Command = '/MSG_Message'  }
      if Command = '/MSG' then begin
        FrmLobbyClient.AppendMsg(GetToken(StrData,1));

        { Se la finestra non è attiva e il messaggio è di chat, riproduci un segnale acustico }
        if AnsiContainsStr(StrData,'<') and (not FrmLobbyClient.Active) then PlayResSound(WAVNEWMESSAGE);
      end

      { Il server ci sta inviando la lista degli utenti
      Command = '/USERLIST_Count_User_User_User...}
      else if Command = '/USERLIST' then begin
        { Salva il numero di utenti connessi... }
        OldUserListCount := FrmLobbyClient.LstUsers.Count;

        { Azzera la lista }
        FrmLobbyClient.LstUsers.Clear;

        { E la riempie }
        for C := 0 to StrToInt(GetToken(StrData,1))-1 do
          FrmLobbyClient.LstUsers.AddItem(GetToken(StrData,C+2),nil);

        { Se ci sono più elementi di prima nella lista, allora avvia la notifica sonora }
        if FrmLobbyClient.LstUsers.Count > OldUserListCount then PlayResSound(WAVPLAYERCONNECTED);
      end

      { Il server ci sta inviando la lista delle partite...
      Command = '/GAMELIST_Count_Host_Port_Host_Port...}
      else if Command = '/GAMELIST' then begin

        { Costruisci la lista se c'è almeno un game }
        if StrToInt(GetToken(StrData,1)) > 0 then begin

          { Inizializziamo le variabili necessarie... }
          ServerInfoList := TServerInfoList.Create;

          { Riempie la lista dei servers... }
          C := 2;
          while C <= (StrToInt(GetToken(StrData,1))*2+1) do
          begin
            ServerInfoList.AddServerInfo(TServerInfo.Create(AOwner,GetToken(StrData,C),StrToInt(GetToken(StrData,C+1))));
            C := C + 2;
          end;

          { E la analizza... }
          LobbyListChecker := TLobbyListChecker.Create(AOwner,FrmLobbyClient.LstGames,ServerInfoList);
        end
        else begin
          { Cancella la lista se non ci sono games e disabilita il pulsante... }
          FrmLobbyClient.LstGames.Clear;
          FrmLobbyClient.BtnJoin.Enabled := false;
        end;
      end

      { Il server ci sta inviando i risultati del test di connessione...
      NOTA: attenzione all'ordine, non invertirlo... }
      else if Command = '/CONNECTIONTESTRESULT' then begin
        if StrToBool(GetToken(StrData,1)) then
          FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgConnectionTest,true)
        else begin
          IAmAbleToHost := false;
          FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgConnectionTest,false);
        end;
      end

      else if Command = '/MESSAGETESTRESULT' then begin
        if StrToBool(GetToken(StrData,1)) then
          FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgSendReceiveTest,true)
        else begin
          IAmAbleToHost := false;
          FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgSendReceiveTest,false);
        end;

        { Ok, fine del test }
        Sleep(2000); //Piccola pausa per non far sfarfallare la finestra
        ConnectionTestDone := true;
        TestServer.StopServer;
        FrmConnectionTest.Hide;

        { Scatena l'evento associato alla fine del test }
        ConnectionTest_Finished(nil);
      end

      { Il server ha cambiato il nostro nickname...
      Command = '/NICKNAMECHANGEDSUCCESSFUL_Nickname' }
      else if Command = '/NICKNAMECHANGEDSUCCESSFUL' then begin
        Nickname := GetToken(StrData,1);
        FrmLobbyClient.Nickname := Nickname;
        SetFavouriteNick(Nickname);
      end

      { Il server ci sta inviando un messaggio da tradurre prima di visualizzarlo
      /TRANSLATEMSG_DataIndex_Arguments_IsServerMessage }
      else if Command = '/TRANSLATEMSG' then begin
        ServerMsg := GetStr(StrToInt(GetToken(StrData,1)),GetToken(StrData,2));
        if StrToBool(GetToken(StrData,3)) then  FrmLobbyClient.AppendMsg(MakeServerMessage(ServerMsg))
        else FrmLobbyClient.AppendMsg(ServerMsg);

      end

      { Un amministratore ci sta per cacciare dal server lol
      andiamocene per conto nostro così gli risparmiamo la fatica
      (Hackers: venite comunque disconnessi dal lato server :-)) }
      else if Command = '/UAREGONNABEKICKEDCOZ' then begin
        raise Exception.Create(GetStr(160,GetToken(StrData,1)));
      end;

    end;
  except
    on E: exception do
    begin          
      { Gestione silenziosa degli errori }
      FrmLobbyClient.BtnSend.Enabled := false;
      FrmLobbyClient.BtnHost.Enabled := false;
      raise Exception.Create(GetStr(161,ClientSocket.Host+','+IntToStr(ClientSocket.Port)) + ' - ' + E.Message);
    end;
  end;

end;


{ Evento richiamato quando è finito il test }
procedure TLobbyClient.ConnectionTest_Finished(Sender: TObject);
begin
  { Una volta finito il test, apri la finestra per hostare se siamo abilitati a farlo }
  if IAmAbleToHost then begin

    { Ritorna il controllo alla form principale ... }
    //FrmLobbyClient.ShowStatus('Test della connessione eseguito con successo! Sei abilitato ad hostare partite sulla rete internet.',clGreen);

    { Ma prima comunica al server di aggiunge la partita all'elenco... }
    ClientSocket.WriteLn('/ISTARTANEWGAME'+SEPARATOR+FrmLobbyClient.HostGame.txtPort.Text);

    FrmLobbyClient.Choice := gcHost;
    FrmLobbyClient.ModalResult := mrOK;

    Disconnect;
  end
  else begin
    FrmLobbyClient.ShowStatus(GetStr(162),clRed);
  end;
end;

{ Procedura per hostare un game }
procedure TLobbyClient.BtnHost_Click(Sender: TObject);
begin
  FrmLobbyClient.HostGame := TFrmHostGame.Create(AOwner);
  FrmLobbyClient.HostGame.txtNickname.Text := Nickname;
  FrmLobbyClient.HostGame.txtTableName.Text := Nickname + '''s game';

  if FrmLobbyClient.HostGame.ShowModal = mrOK then begin
    { Prima di autorizzare il client ad avviare una partita, eseguiamo un test per verificare
    l'autorevolezza del client ad hostare un game }
    ConnectionTestDone := false;

    { Supponiamo che il test vada bene.. }
    IAmAbleToHost := true;

    { Crea la form di visualizzazione del test }
    FrmConnectionTest := TFrmConnectionTest.Create(AOwner);
    FrmConnectionTest.lblOpenTest.Caption := GetStr(47,FrmLobbyClient.HostGame.txtPort.Text);
    FrmConnectionTest.Show;
    FrmConnectionTest.Refresh;
    FrmLobbyClient.Refresh;

    { Prima di avviare il test fai una pausa per permettere all'utente di leggere
    quel che sta accadendo }
    Sleep(2000);

    { Avvia il server di test... }
    TestServer := TTestServer.Create(AOwner);
    if TestServer.StartServer(StrToInt(FrmLobbyClient.HostGame.txtPort.Text)) then begin
      FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgOpenTest,true);

      { Avvisa il lobby multiplayer di eseguire il test... }
      ClientSocket.WriteLn('/IMREADYFORTHECONNECTIONTEST'+SEPARATOR+FrmLobbyClient.HostGame.txtPort.Text);
    end
    else begin
      FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgOpenTest,false);
      Sleep(200);
      FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgConnectionTest,false);
      Sleep(200);
      FrmConnectionTest.SetImageOnControl(FrmConnectionTest.ImgSendReceiveTest,false);

      { Se fallise ad avviare il server, ferma tutto il processo, non si può continuare }
      IAmAbleToHost := false;

      Sleep(2000); //Piccola pausa per non far sfarfallare la finestra
      ConnectionTestDone := true;
      FrmConnectionTest.Hide;

      FrmLobbyClient.ShowStatus(GetStr(169),clRed);
    end;

    //Togli per generare un errore di connessione... (debug)
    //ClientSocket.WriteLn('/IMREADYFORTHECONNECTIONTEST'+SEPARATOR+IntToStr(1400));
  end;
end;

{ L'utente ha deciso di partecipare ad una partita esistente... }
procedure TLobbyClient.BtnJoin_Click(Sender: TObject);
begin
  FrmLobbyClient.Choice := gcJoin;
  FrmLobbyClient.ModalResult := mrOK;
  Disconnect;
end;


end.
