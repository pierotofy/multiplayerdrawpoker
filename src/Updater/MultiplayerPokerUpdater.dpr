program MultiplayerPokerUpdater;

uses
  Forms,
  Main in 'Main.pas' {FrmMain},
  Updater in 'Updater.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
