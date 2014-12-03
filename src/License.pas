unit License;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  Constants, ComCtrls, Languages;

type
  TFrmLicense = class(TForm)
    txtGnugpl: TMemo;
    BtnAgree: TButton;
    ChkGnugpl: TCheckBox;
    txtConditions: TMemo;
    ChkConditions: TCheckBox;
    procedure ChkGnugplClick(Sender: TObject);
    procedure ChkConditionsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLicense: TFrmLicense;

implementation

{$R *.dfm}

procedure TFrmLicense.ChkGnugplClick(Sender: TObject);
begin
  BtnAgree.Enabled := ChkGnugpl.Checked and ChkConditions.Checked;
end;

procedure TFrmLicense.ChkConditionsClick(Sender: TObject);
begin
  ChkGnugplClick(Sender);
end;

procedure TFrmLicense.FormActivate(Sender: TObject);
begin
  { Imposta la lingua }
  self.Caption := GetStr(55);
  ChkGnugpl.Caption := GetStr(52);
  ChkConditions.Caption := GetStr(53);
  BtnAgree.Caption := GetStr(54);
  txtConditions.Text := GetStr(51);
end;

end.
