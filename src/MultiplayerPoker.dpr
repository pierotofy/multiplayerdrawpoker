program MultiplayerPoker;

uses
  Forms,
  Main in 'Main.pas' {FrmMain},
  Constants in 'Constants.pas',
  Deck in 'Deck.pas',
  Hand in 'Hand.pas',
  Card in 'Card.pas',
  MultiplayerPoker_TLB in 'MultiplayerPoker_TLB.pas',
  Player in 'Player.pas',
  Money in 'Money.pas',
  GameServer in 'GameServer.pas',
  GameClient in 'GameClient.pas',
  ServerInfo in 'ServerInfo.pas',
  Client in 'Client.pas',
  ClientList in 'ClientList.pas',
  PlayerList in 'PlayerList.pas',
  ButtonPanel in 'ButtonPanel.pas',
  ServerInfoList in 'ServerInfoList.pas',
  ConnectToIP in 'ConnectToIP.pas' {FrmConnectToIP},
  InsertPassword in 'InsertPassword.pas' {FrmInsertPassword},
  Chat in 'Chat.pas' {FrmChat},
  About in 'About.pas' {FrmAbout},
  LanScanner in 'LanScanner.pas',
  AsyncServerInfo in 'AsyncServerInfo.pas',
  KeyListener in 'KeyListener.pas',
  ChatServer in 'ChatServer.pas',
  ChatClient in 'ChatClient.pas',
  TelephoneRing in 'TelephoneRing.pas',
  ScanNetwork in 'ScanNetwork.pas',
  LobbyServer in 'LobbyServer.pas',
  LobbyServerForm in 'LobbyServerForm.pas' {FrmLobbyServer},
  LobbyScanner in 'LobbyScanner.pas',
  LobbyClientForm in 'LobbyClientForm.pas' {FrmLobbyClient},
  WindowsUtils in 'WindowsUtils.pas',
  HostGame in 'HostGame.pas' {FrmHostGame},
  NewGame in 'NewGame.pas' {FrmNewGame},
  JoinGame in 'JoinGame.pas' {FrmJoinGame},
  LobbyClient in 'LobbyClient.pas',
  LobbyListChecker in 'LobbyListChecker.pas',
  TestServer in 'TestServer.pas',
  TestClient in 'TestClient.pas',
  ConnectionTest in 'ConnectionTest.pas' {FrmConnectionTest},
  UpdateChecker in 'UpdateChecker.pas',
  License in 'License.pas' {FrmLicense},
  BotClient in 'BotClient.pas',
  StatusViewerForm in 'StatusViewerForm.pas' {FrmStatusViewer},
  GhostDlg in 'GhostDlg.pas' {FrmGhostDlg},
  Languages in 'Languages.pas',
  SelectLanguage in 'SelectLanguage.pas' {FrmSelectLanguage},
  Donate in 'Donate.pas' {FrmDonate};

{$R *.TLB}

{$R MultiplayerPoker.res}
{$R PokerImages.res}
{$R Sounds.res}
{$R WindowsXP.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmConnectToIP, FrmConnectToIP);
  Application.CreateForm(TFrmInsertPassword, FrmInsertPassword);
  Application.CreateForm(TFrmChat, FrmChat);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.CreateForm(TFrmLobbyServer, FrmLobbyServer);
  Application.CreateForm(TFrmHostGame, FrmHostGame);
  Application.CreateForm(TFrmNewGame, FrmNewGame);
  Application.CreateForm(TFrmJoinGame, FrmJoinGame);
  Application.CreateForm(TFrmLobbyClient, FrmLobbyClient);
  Application.CreateForm(TFrmConnectionTest, FrmConnectionTest);
  Application.CreateForm(TFrmLicense, FrmLicense);
  Application.CreateForm(TFrmStatusViewer, FrmStatusViewer);
  Application.CreateForm(TFrmGhostDlg, FrmGhostDlg);
  Application.CreateForm(TFrmSelectLanguage, FrmSelectLanguage);
  Application.CreateForm(TFrmDonate, FrmDonate);
  Application.Run;
end.
