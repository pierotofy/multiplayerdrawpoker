unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, Menus, ExtCtrls, StdCtrls, StrUtils, ComCtrls, ImgList, ShellApi, Registry,
  Card, Hand, GameServer, Player, GameClient, ServerInfo, NewGame, LobbyServerForm, LobbyClientForm,
  HostGame, JoinGame, License, Languages, SelectLanguage, BotClient, StatusViewerForm, UpdateChecker, WindowsUtils, InsertPassword, ChatServer, ChatClient, Chat, TelephoneRing, About, KeyListener,
  Constants, Grids, Donate;

type
  TFrmMain = class(TForm)
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    cmdExit: TMenuItem;
    StatusBar: TStatusBar;
    mnuTools: TMenuItem;
    cmdShowChat: TMenuItem;
    mnuAbout: TMenuItem;
    cmdAbout: TMenuItem;
    cmdRules: TMenuItem;
    TelImage: TImage;
    cmdMakeADonation: TMenuItem;
    cmdCheckUpdates: TMenuItem;
    N1: TMenuItem;
    CmdNewGame: TMenuItem;
    cmdViewStatusForm: TMenuItem;
    cmdVisitWebSite: TMenuItem;
    mnuLanguage: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmdExitClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure cmdShowChatClick(Sender: TObject);
    procedure cmdAboutClick(Sender: TObject);
    procedure cmdRulesClick(Sender: TObject);
    procedure TelImageClick(Sender: TObject);
    procedure cmdMakeADonationClick(Sender: TObject);
    procedure cmdCheckUpdatesClick(Sender: TObject);
    procedure CmdNewGameClick(Sender: TObject);
    procedure cmdViewStatusFormClick(Sender: TObject);
    procedure cmdVisitWebSiteClick(Sender: TObject);
  private
    FrmChat: TFrmChat;
    StatusViewerForm: TFrmStatusViewer;
    GameServer: TGameServer;
    GameClient: TGameClient;
    BotClient: array [1 .. MAXSLOTS] of TBotClient;
    GameInitialized: boolean;
    ChatServer: TChatServer;
    ChatClient: TChatClient;
    TelephoneRing: TTelephoneRing;
    FrmInsertPassword: TFrmInsertPassword;
    StartLobby: boolean;
    F5State: TF5State;

    procedure ApplyLanguageToForm;
    procedure CheckCurrentLanguageOnMenu;
    procedure LoadLanguageVoicesToMenu;
    procedure InitGraphics;
    procedure StartKeyListener;
    procedure mnuLanguageVoiceClick(Sender: TObject);
    procedure ChatMessage_Arrival(Sender: TObject);
    procedure StatusMessage_Arrival(Sender: TObject);
    procedure KeyListener_ShowFormDigit(Sender: TObject);
    procedure KeyListener_ShowSegretBackgroundDigit(Sender: TObject);
    procedure KeyListener_RightMousePressed(Sender: TObject);
    procedure KeyListener_F5Pressed(Sender: TObject);
    procedure StartHosting(TableName,Password,Nickname: string; Port,Cip,InitialMoney,Slots,Bots: integer);
    procedure StartJoining(Host: string; Port: integer; Nickname: string; PasswordRequired: boolean);
    function LicenseAgreed: boolean;
    procedure SetLicenseAgreed;
    procedure HideOrShowDonateButtonOnNeeded;
    function ItalianLanguageSelected: boolean;
  public
    procedure ShowStatus(StrMessage: string);
    function GetStatusBarHeight: integer;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
var
  Lobby: TFrmLobbyServer;
  License: TFrmLicense;
  C: integer;
  CurParam: string;
  NextParam: string;
  Motd: string;
  HideLobby: boolean;
  Port: integer;
  AdminPassword: string;
  FrmSelectLanguage: TFrmSelectLanguage;
  FavouriteLanguage: string;
  FrmDonate: TFrmDonate;
  hand1: THand;
  hand2: THand;
begin
 { Score test debug snippet 
  hand1 := THand.Create(self,self,hpBottom);
  hand2 := THand.Create(self,self,hpTop);

  hand1.PushCard(TCard.Create(self,self,Ace,Hearts));
  hand1.PushCard(TCard.Create(self,self,Seven,Hearts));
  hand1.PushCard(TCard.Create(self,self,Eight,Clubs));
  hand1.PushCard(TCard.Create(self,self,Nine,Hearts));
  hand1.PushCard(TCard.Create(self,self,Ten,Hearts));

  hand2.PushCard(TCard.Create(self,self,Ten,Hearts));
  hand2.PushCard(TCard.Create(self,self,Ten,Hearts));
  hand2.PushCard(TCard.Create(self,self,Ace,Clubs));
  hand2.PushCard(TCard.Create(self,self,Ace,Hearts));
  hand2.PushCard(TCard.Create(self,self,Seven,Hearts));
  }

  { Inizializza alcune vars.. }
  self.Caption := PROGRAMNAME;
  GameInitialized := false;
  StartLobby := false;
  Motd := '';
  AdminPassword := '';
  HideLobby := false;
  Port := 0;

  { Prima di tutto carichiamo la lista delle lingue supportate.. }
  SupportedLanguages := GetSupportedLanguages(ExtractFilePath(Application.ExeName));

  { Imposta la lingua preferita (se c'è..) }
  FavouriteLanguage := GetFavouriteLanguage;

  { Se non c'è una lingua preferita, mostra la form per selezionarla }
  if FavouriteLanguage = '' then begin
    FrmSelectLanguage := TFrmSelectLanguage.Create(self,SupportedLanguages);
    if FrmSelectLanguage.ShowModal = mrOK then begin
      SetFavouriteLanguage(FrmSelectLanguage.SelectedLang);
      FavouriteLanguage := FrmSelectLanguage.SelectedLang;
    end
    else ExitProcess(0);
  end;

  { Carica nel menu le lingue, e applichiamo alla form la lingua }
  LoadLanguageVoicesToMenu;
  SetCurrentLanguage(GetLanguageFile(FavouriteLanguage));
  CheckCurrentLanguageOnMenu;
  ApplyLanguageToForm;

  { Per secondissima cosa, controlliamo se l'utente non ha ancora accettato i termini della licenza... }
  if not LicenseAgreed then begin

    { Visualizza la form della licenza d'uso, se l'utente rifiuta, esci dal programma }
    License := TFrmLicense.Create(self);
    if License.ShowModal = mrOK then SetLicenseAgreed
    else Application.Terminate;
  end;

  { E' tempo di donare e la lingua è quella italiana? Se si mostra la form... }
  if IsTimeToDonate and ItalianLanguageSelected then begin
    FrmDonate := TFrmDonate.Create(self,true);
    FrmDonate.ShowModal;
  end;

  { Per terza cosa controlliamo se l'utente vuole avviare l'applicazione
  in modalità normale o lobby... }
  for C := 0 to ParamCount do
  begin
    CurParam := AnsiUpperCase(ParamStr(C));
    NextParam := AnsiUpperCase(ParamStr(C+1));

    if (CurParam = '-ENABLE') and (NextParam = 'SERVERLOBBY') then begin
      { Se è stato passato l'argomento per avviare il lobby, non ci servono ulteriori
      inizializzazioni di gioco, ma dobbiamo avviare la form per controllare l'avvio del lobby }
      StartLobby := true;
    end

    else if CurParam = '-MOTD' then Motd := ParamStr(C+1)

    else if CurParam = '-HIDE' then HideLobby := true

    else if CurParam = '-PORT' then Port := StrToInt(NextParam)

    else if CurParam = '-ADMINPWD' then AdminPassword := ParamStr(C+1);

  end;

  { Procede a controllare i parametri analizzati... }
  if StartLobby then begin
    GameInitialized := true;

    { Nasconde la finestra di gioco e visualizza quella del lobby }
    Lobby := TFrmLobbyServer.Create(self);
    Lobby.Show;

    if AdminPassword <> '' then Lobby.txtAdminPassword.Text := AdminPassword;
    if Motd <> '' then Lobby.txtMotd.Text := Motd;
    if Port <> 0 then Lobby.txtPort.Text := IntToStr(Port);
    if HideLobby then begin
      Lobby.Hide;
      Lobby.BtnStart.OnClick(nil);
    end;
  end;
                      
  { Impostiamo il nickname preferito come quello di sistema
  se non c'è ne già uno in memoria... }
  if GetFavouriteNick = '' then SetFavouriteNick(GetLoginName);
end;

{ Procedura che controlla se la lingua selezionata è l'italiano, in caso positivo
abilita il menu per donare, altrimenti no }
procedure TFrmMain.HideOrShowDonateButtonOnNeeded;
begin
  cmdMakeADonation.Visible := ItalianLanguageSelected;
end;

{ Funzione per vedere se è stata selezionata la lingua italiana }
function TFrmMain.ItalianLanguageSelected: boolean;
begin
  Result := CurrentLangFile.ToString = 'Italiano';
end;

{ Procedura per caricare il menu con le lingue disponibili... }
procedure TFrmMain.LoadLanguageVoicesToMenu;
var
  C: integer;
  MenuItem: TMenuItem;
  LangFile: TLangFile;
begin
  for C := 0 to SupportedLanguages.Count-1 do
  begin
    LangFile := GetLanguageFile(C);

    MenuItem := TMenuItem.Create(self);
    MenuItem.Caption := LangFile.ToString;
    MenuItem.OnClick := mnuLanguageVoiceClick;
    mnuLanguage.Add(MenuItem);
  end;
end;

{ Procedura evocata alla pressione di una voce del menu Lingua }
procedure TFrmMain.mnuLanguageVoiceClick(Sender: TObject);
begin
  { Imposta la lingua corrente, le applica allo stile della form }
  SetCurrentLanguage(GetLanguageFile(TMenuItem(Sender).Caption));
  SetFavouriteLanguage(AnsiReplaceStr(TMenuItem(Sender).Caption,'&',''));
  ApplyLanguageToForm;

  { Seleziona la voce corrispondente nel menu }
  CheckCurrentLanguageOnMenu;
end;

{ Procedura per selezionare visivamente sul menu la lingua corrente }
procedure TFrmMain.CheckCurrentLanguageOnMenu;
var
  C: integer;
  MenuItem: TMenuItem;
begin
  for C := 0 to mnuLanguage.Count-1 do
  begin
    MenuItem := mnuLanguage.Items[C];
    MenuItem.Checked := AnsiReplaceStr(MenuItem.Caption,'&','') = CurrentLangFile.ToString;
  end;
end;

{ Procedura per applicare alla finestra lo stile della lingua corrente }
procedure TFrmMain.ApplyLanguageToForm;
begin
  cmdNewGame.Caption := GetStr(0);
  cmdExit.Caption := GetStr(1);
  cmdShowChat.Caption := GetStr(2);
  cmdViewStatusForm.Caption := GetStr(3);
  cmdCheckUpdates.Caption := GetStr(4);
  mnuTools.Caption := GetStr(5);
  mnuLanguage.Caption := GetStr(6);
  cmdRules.Caption := GetStr(7);
  cmdMakeADonation.Caption := GetStr(8);
  cmdVisitWebSite.Caption := GetStr(9);
  cmdAbout.Caption := GetStr(10);
end;

{ Funzione che controlla che sia già stata accettata la licenza... }
function TFrmMain.LicenseAgreed: boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.OpenKey('\Software\MultiplayerPoker',true);
  Result := Reg.ReadString('LicenseAgreed') = PROGRAMVERSION;
  Reg.CloseKey;
end;

{ Procedura per settare nel registro l'accettazione della licenza }
procedure TFrmMain.SetLicenseAgreed;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.CreateKey('\Software\MultiplayerPoker\');
  Reg.OpenKey('\Software\MultiplayerPoker',true);
  Reg.WriteString('LicenseAgreed',PROGRAMVERSION);
  Reg.CloseKey;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  { Termina la dll esterna cards.dll }
  TermCardsDotDll;

  { Distrugge il GameClient se necessario }
  if not (GameClient = nil) then GameClient.Destroy;

  { E anche il server }
  GameServer.Free;

  { E anche la chat }
  if not (ChatClient = nil) then ChatClient.Destroy;
  ChatServer.Free;
end;

{ Procedura per mostrare una stringa nella status bar }
procedure TFrmMain.ShowStatus(StrMessage: string);
begin
  StatusBar.Panels.Items[0].Text := StrMessage;
end;

{ Procedura per ricavare la Height della status bar }
function TFrmMain.GetStatusBarHeight: integer;
begin
  Result := StatusBar.Height;
end;

{ Esce }
procedure TFrmMain.cmdExitClick(Sender: TObject);
begin
  ExitProcess(0);
end;

{ Inizializza la grafica }
procedure TFrmMain.InitGraphics;
begin

end;


procedure TFrmMain.FormPaint(Sender: TObject);
var
  NewGame: TFrmNewGame;
  HostGame: TFrmHostGame;                                                                            
  JoinGame: TFrmJoinGame;
  LobbyClientForm: TFrmLobbyClient;
begin
  { Se è avviato il lobby, nascondi la finestra }
  if StartLobby then self.Hide;

  { Questa procedura dev'essere richiamata una sola volta durante l'esecuzione del programma
  mentre l'evento onpaint viene richiamato anche quando l'utente ripristina la finestra
  ridotta a icona oppure quando è necessario ridisegnare gli oggetti sul canvas del form }
  if not GameInitialized then begin
    GameInitialized := true;

    { Inizializza la dll esterna cards.dll }
    InitCardsDotDll;
    InitGraphics;

    { Inizializza la classe per gestire lo squillio del telefono }
    TelephoneRing := TTelephoneRing.Create(TelImage,500);

    { Crea la finestra di chat (senza mostrarla) }
    FrmChat := TFrmChat.Create(self,self, TelephoneRing);
    FrmChat.Show;
    FrmChat.Visible := false;

    { Crea la finestra per loggare gli status (senza mostrarla) }
    FrmStatusViewer := TFrmStatusViewer.Create(self);
    FrmStatusViewer.Show;
    FrmStatusViewer.Visible := false;

    { Richiama la finestra di dialogo  }
    NewGame := TFrmNewGame.Create(self);
    if NewGame.ShowModal = mrOK then begin

      { Cosa ha scelto l'utente? }
      if NewGame.Choice = gcHost then begin

        { L'utente ha scelto di hostare una partita, avvia la form per settare
        le impostazioni del server... }
        HostGame := TFrmHostGame.Create(self);
        if HostGame.ShowModal = mrOK then begin
        with HostGame do
              StartHosting(txtTableName.Text,txtPassword.Text,txtNickname.Text, StrToInt(txtPort.Text),StrToInt(txtCip.Text),StrToInt(txtInitialMoney.Text),StrToInt(txtSlots.Text),StrToInt(txtAis.Text))
        end;
      end

      { L'utente ha scelto di connettersi ad una partita in LAN? }
      else if NewGame.Choice = gcJoin then begin
        { Avvia la form per gestire la connessione ad un server... }

        JoinGame := TFrmJoinGame.Create(self);
        if JoinGame.ShowModal = mrOK then begin
          with JoinGame do             
            StartJoining(lblShowServerInfoIP.Caption,StrToInt(lblShowServerInfoPort.Caption),txtNickname.Text,lblShowServerInfoPasswordRequired.Caption = 'si');
        end;
      end

      { L'utente ha scelto di avviare il lobby? }
      else if NewGame.Choice = gcConnectLobby then begin
        { Avvia la form per connettersi al lobby multiplayer... }

        LobbyClientForm := TFrmLobbyClient.Create(self);
        if LobbyClientForm.ShowModal = mrOK then begin

          { Se ha deciso di hostare... }
          if LobbyClientForm.Choice = gcHost then begin
            with LobbyClientForm.HostGame do
              StartHosting(txtTableName.Text,txtPassword.Text,txtNickname.Text, StrToInt(txtPort.Text),StrToInt(txtCip.Text),StrToInt(txtInitialMoney.Text),StrToInt(txtSlots.Text),StrToInt(txtAis.Text))
          end

          { Oppure di entrare in una partita esistente... }
          else if LobbyClientForm.Choice = gcJoin then begin
            with LobbyClientForm.ServerInfo do
              StartJoining(Host,Port,LobbyClientForm.Nickname,IsPasswordRequired);
          end;
        end;
      end;

      { Avvia il keylistener... }
      StartKeyListener;
    end;
  end;
end;



procedure TFrmMain.cmdShowChatClick(Sender: TObject);
begin
  FrmChat.Visible := true;
end;


{ Procedura che viene scatenata all'arrivo di un messaggio nella chat }
procedure TFrmMain.ChatMessage_Arrival(Sender: TObject);
begin
  { Modifica il caption solamente se la chat non è attiva
  if not FrmChat.Active then begin
    self.Caption := PROGRAMNAME + ' - nuovi messaggi nella chat';
  end;     }

  { Attiva lo squillio del telefono solamente se la chat non è visibile }
  if not FrmChat.Visible then begin
    TelephoneRing.StartRinging;
  end;
end;

{ Procedura scatenata all'arrivo di un messaggio di status }
procedure TFrmMain.StatusMessage_Arrival(Sender: TObject);
begin
  FrmStatusViewer.LstStatus.Items.Insert(0,string(Sender))
end;

procedure TFrmMain.cmdAboutClick(Sender: TObject);
var
  FrmAbout: TFrmAbout;
begin
  FrmAbout := TFrmAbout.Create(self);
  FrmAbout.ShowModal;
end;

procedure TFrmMain.cmdRulesClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',PAnsiChar(Languages.GetStr(174)),nil,nil, SW_SHOWNORMAL);
end;

{ Se viene premuto il pulsante destro del mouse... }
procedure TFrmMain.KeyListener_RightMousePressed(Sender: TObject);
begin
  if F5State = fsActive then begin
    AnimateWindow(self.Handle,400,AW_BLEND or AW_HIDE);
    self.Hide;
  end;
end;

{ Modifica lo stato della variabile F5State alla pressione di F5 }
procedure TFrmMain.KeyListener_F5Pressed(Sender: TObject);
begin
  if F5State = fsNotActive then begin
    ShowStatus('Shadow Mode On');
    F5State := fsActive;
  end
  else begin
    ShowStatus('Shadow Mode Off');
    F5State := fsNotActive;
  end;
end;



{ L'utente ha digitato la parola magica per rivelare la form }
procedure TFrmMain.KeyListener_ShowFormDigit(Sender: TObject);
begin
  self.Show;
end;

{ L'utente ha digitato la parola magica per svelare lo sfondo segreto :) }
procedure TFrmMain.KeyListener_ShowSegretBackgroundDigit(Sender: TObject);
begin
  //self.Canvas.Draw((self.ClientWidth div 2) - (AdminImage.Width div 2),(self.ClientHeight div 2) - (AdminImage.Height div 2),AdminImage.Picture.Bitmap);
end;

{ Procedura che si occupa dell'avvio del keylistener }
procedure TFrmMain.StartKeyListener;
var
  KeyListener: TKeyListener;
begin
  { Avvia il keylistener }
  KeyListener := TKeyListener.Create;
  KeyListener.OnShowFormDigit := KeyListener_ShowFormDigit;
  //KeyListener.OnShowSegretBackgroundDigit := KeyListener_ShowSegretBackgroundDigit;
  KeyListener.OnF5Pressed := KeyListener_F5Pressed;
  KeyListener.OnRightMousePressed := KeyListener_RightMousePressed;

  { Imposta il valore di default per la variabile F5State }
  F5State := fsNotActive;
end;

{ Se viene premuto il telefono... }
procedure TFrmMain.TelImageClick(Sender: TObject);
begin
  FrmChat.Visible := true;
end;

{ Apre il browser alla pagina per segnalare bugs.. }
procedure TFrmMain.cmdMakeADonationClick(Sender: TObject);
var
  Donate: TFrmDonate;
begin
  Donate := TFrmDonate.Create(self,false);
  Donate.ShowModal;
end;

{ Procedura per hostare una partita }
procedure TFrmMain.StartHosting(TableName,Password,Nickname: string; Port,Cip,InitialMoney,Slots,Bots: integer);
var
  C: integer;
begin
  { Avviamo il server di gioco e quello di chat... }
  try
    GameServer := TGameServer.Create(self,TableName,Password,Port,Cip,InitialMoney,Slots);
    ChatServer := TChatServer.Create(self);
  except
    raise Exception.Create('Si è verificato un errore durante l''avvio del server. Questo errore può essere dovuto ad un firewall attivo sul pc locale o dalla mancata disponibilità di permessi sull''account di Windows.');
  end;

  { Se è stata avviato il server, avvia il client
  inserendo localhost e porta definita nel server }
  GameClient := TGameClient.Create(self,'localhost',Password,Nickname,Port,StatusBar);
  GameClient.OnStatusMessageArrival := StatusMessage_Arrival;

  { Avvia il client della chat su localhost }
  ChatClient := TChatClient.Create(self,FrmChat,ChatMessage_Arrival,Nickname, 'localhost');

  { Crea i bots... }
  for C := 1 to Bots do BotClient[C] := TBotClient.Create(self,'localhost',Password,Port);

  { Salva il nickname come preferito... }
  SetFavouriteNick(Nickname);
end;

{ Procedura per joinare una partita }
procedure TFrmMain.StartJoining(Host: string; Port: integer; Nickname: string; PasswordRequired: boolean);
var
  Password: string;
begin
  { Se è richiesta la password, richiedila all'utente }
  if PasswordRequired then begin
    FrmInsertPassword := TFrmInsertPassword.Create(self);
    if FrmInsertPassword.ShowModal = mrOK then Password := FrmInsertPassword.txtPassword.Text;
  end;

  GameClient := TGameClient.Create(self,Host,Password,Nickname,Port,StatusBar);
  GameClient.OnStatusMessageArrival := StatusMessage_Arrival;

  { Avvia il client della chat specificando l'host a cui connettersi }
  ChatClient := TChatClient.Create(self,FrmChat,ChatMessage_Arrival,Nickname, Host);

  { Salva il nickname come preferito... }
  SetFavouriteNick(Nickname);
end;

{ Se è disponibile una nuova versione... }
procedure TFrmMain.cmdCheckUpdatesClick(Sender: TObject);
var
  UpdateChecker: TUpdateChecker;
begin
  UpdateChecker := TUpdateChecker.Create(self,true);
end;

{ Facciamo pulizia totale, chiudendo e riaprendo il programma... }
procedure TFrmMain.CmdNewGameClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open','MultiplayerPoker.exe',nil,nil, SW_SHOWNORMAL);
  Application.Terminate;
end;

procedure TFrmMain.cmdViewStatusFormClick(Sender: TObject);
begin
  FrmStatusViewer.Visible := true;
end;

procedure TFrmMain.cmdVisitWebSiteClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',PROJECTHOMEPAGE,nil,nil, SW_SHOWNORMAL);
end;


end.
