unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ShellApi,
  Constants, Languages;

type
  TFrmAbout = class(TForm)
    lblProgramName: TLabel;
    lblLicense: TLabel;
    lblNotes: TLabel;
    BtnClose: TButton;
    lblPieroTofy: TLabel;
    lblMail: TLabel;
    lblWeb: TLabel;
    lblShowMail: TLabel;
    lblShowWeb: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblShowWebClick(Sender: TObject);
    procedure lblShowMailClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

{$R *.dfm}

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
  lblProgramName.Caption := PROGRAMNAME;
end;


procedure TFrmAbout.lblShowWebClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open','http://www.pierotofy.it',nil,nil, SW_SHOWNORMAL);
end;

procedure TFrmAbout.lblShowMailClick(Sender: TObject);
begin
  ShellExecute(Handle,'open', 'mailto:admin@pierotofy.it', nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmAbout.FormActivate(Sender: TObject);
begin
  { Imposta la lingua... }
  lblLicense.Caption := GetStr(15);
  lblNotes.Caption := GetStr(16);
  BtnClose.Caption := GetStr(17);
  self.Caption := GetStr(10);
end;

end.
