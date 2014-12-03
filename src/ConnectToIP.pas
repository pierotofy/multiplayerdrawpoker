unit ConnectToIP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Languages;

type
  TFrmConnectToIP = class(TForm)
    BtnOK: TButton;
    lblIP: TLabel;
    txtIP: TEdit;
    lblPort: TLabel;
    txtPort: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConnectToIP: TFrmConnectToIP;

implementation

{$R *.dfm}

procedure TFrmConnectToIP.FormActivate(Sender: TObject);
begin
  { Assegna il focus }
  txtIP.SetFocus;

  { Imposta la lingua... }
  self.Caption := GetStr(12);
  lblPort.Caption := GetStr(11);
end;

end.
