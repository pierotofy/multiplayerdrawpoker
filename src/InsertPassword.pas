unit InsertPassword;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Languages;

type
  TFrmInsertPassword = class(TForm)
    txtPassword: TEdit;
    BtnOK: TButton;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmInsertPassword: TFrmInsertPassword;

implementation

{$R *.dfm}

procedure TFrmInsertPassword.FormActivate(Sender: TObject);
begin
  self.Caption := GetStr(13);
end;

end.
