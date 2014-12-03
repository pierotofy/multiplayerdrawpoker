unit ConnectionTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Constants, Languages;

type
  TFrmConnectionTest = class(TForm)
    lblOpenTest: TLabel;
    lblConnectionTest: TLabel;
    lblSendReceiveTest: TLabel;
    ImgOpenTest: TImage;
    ImgConnectionTest: TImage;
    ImgSendReceiveTest: TImage;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetImageOnControl(Control: TImage; Ok: boolean);
  end;

var
  FrmConnectionTest: TFrmConnectionTest;

implementation

{$R *.dfm}

procedure TFrmConnectionTest.SetImageOnControl(Control: TImage; Ok: boolean);
begin
  if Ok then Control.Picture.Bitmap.LoadFromResourceName(hInstance,'OK')
  else Control.Picture.Bitmap.LoadFromResourceName(hInstance,'NO');
  self.Refresh;
end;

procedure TFrmConnectionTest.FormActivate(Sender: TObject);
begin
  { Imposta la lingua }
  self.Caption := GetStr(50);
  lblConnectionTest.Caption := GetStr(48);
  lblSendReceiveTest.Caption := GetStr(49);
end;

end.
