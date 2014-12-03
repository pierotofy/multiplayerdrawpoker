unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ShellApi,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, StrUtils, Updater;

type
  TFrmMain = class(TForm)
    ImgPoker: TImage;
    ProgressBar: TProgressBar;
    lblStatus: TLabel;
    BtnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Initialized: boolean;
    PokerVersion: string;
    Updater: TUpdater;

    procedure Thread_Finished(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.FormPaint(Sender: TObject);
var
  AppPath: string;
begin
  if not Initialized then begin
    Initialized := true;
    AppPath := AnsiLeftStr(Application.ExeName,LastDelimiter('\',Application.ExeName)-1);
    Updater := TUpdater.Create(self,PokerVersion,AppPath,lblStatus,ProgressBar,Thread_Finished);
  end;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  Initialized := false;
  if (AnsiUpperCase(ParamStr(1)) = '-POKERVERSION') and (ParamStr(2) <> '') then PokerVersion := ParamStr(2)
  else begin
    //quanto mi piace fare il "falso" lol
    MessageBox(0,'This application must be run by a valid instance of MultiplayerPoker.exe','Init failed!',0);
    Application.Terminate;
  end;
end;

{ Procedura richiamata quando si è concluso il thread  }
procedure TFrmMain.Thread_Finished(Sender: TObject);
begin
  BtnCancel.Caption := '&End';

  //Togli questo se vuoi che l'utente possa chiudere autonomamente la finestra...
  //ExitProcess(0);
end;


{ Procedura per cancellare l'esecuzione... (DANGEROUS! lol) }

procedure TFrmMain.BtnCancelClick(Sender: TObject);
begin
  { Se è gia stato creato il thread e il caption corrisponde ad "annulla"... possiamo interromperlo, ma è pericoloso
  (per il poker)... }
  if Assigned(Updater) and (BtnCancel.Caption = '&Cancel') then begin
    { Stoppa il thread e avvisa l'utente... }
    Updater.Suspend;

    { Se un utente vuole annullare lo stesso... }
    if MessageBox(0,'Exiting the process could damage multiplayer draw poker. It is raccomanded to wait until the end of the update process. Exit anyway?','Warning!',MB_YESNO or MB_ICONWARNING) = ID_YES then begin
      Updater.Terminate;
      Application.Terminate;
    end

    { Altrimenti se è più saggio e attende la fine del processo...
    riprendi l'esecuzione del thread }
    else Updater.Resume;
  end

  { Altrimenti, se l'update è finito...
  possiamo uscire }
  else if BtnCancel.Caption = '&End' then begin
    { Presumiamo che non cambieremo mai il nome da "MultiplayerPoker.exe" }
    ShellExecute(Handle, 'open','MultiplayerPoker.exe',nil,nil, SW_SHOWNORMAL);

    Application.Terminate;
  end;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone; //Ferma!
  BtnCancelClick(Sender);
end;

end.
