unit HostGame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, WindowsUtils,
  Constants, Languages;

type
  TFrmHostGame = class(TForm)
    BtnOK: TButton;
    txtNickname: TEdit;
    lblNickname: TLabel;
    txtSlots: TEdit;
    lblInitialMoney: TLabel;
    txtInitialMoney: TEdit;
    lblSlots: TLabel;
    lblPassword: TLabel;
    txtPassword: TEdit;
    udSlots: TUpDown;
    lblAis: TLabel;
    txtAis: TEdit;
    UdAis: TUpDown;
    GrpAdvanced: TGroupBox;
    lblCip: TLabel;
    txtCip: TEdit;
    lblPort: TLabel;
    txtPort: TEdit;
    lblTableName: TLabel;
    txtTableName: TEdit;
    BtnAdvanced: TButton;
    procedure FormCreate(Sender: TObject);
    procedure txtNicknameChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure udSlotsClick(Sender: TObject; Button: TUDBtnType);
    procedure BtnAdvancedClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure SetDefaultServerName;
  public
    AdvancedOpened: boolean;
  end;

var
  FrmHostGame: TFrmHostGame;

implementation

{$R *.dfm}

procedure TFrmHostGame.FormCreate(Sender: TObject);
begin
  { Assegna alla Textbox con il nickname l'utente di windows attivo }
  txtNickname.Text := GetFavouriteNick;

  { Assegna il valore di default al nome del server }
  SetDefaultServerName;
  txtPort.Text := IntToStr(DEFAULTPORT);

  BtnOK.Caption := GetStr(35);

  { Avanzate.. }
  AdvancedOpened := false;
end;

{ Procedura per impostare un valore di default al nome del server
(in base al nickname) }
procedure TFrmHostGame.SetDefaultServerName;
begin
  txtTableName.Text := txtNickname.Text + '''s game';
end;

procedure TFrmHostGame.txtNicknameChange(Sender: TObject);
begin
  { Refresha il nome del server in automatico }
  if txtNickname.Text <> '' then SetDefaultServerName
  else txtTableName.Text := 'game';
end;

procedure TFrmHostGame.BtnOKClick(Sender: TObject);
begin
  self.ModalResult := mrOk;
end;

procedure TFrmHostGame.udSlotsClick(Sender: TObject; Button: TUDBtnType);
begin
  if StrToInt(txtSlots.Text) < StrToInt(txtAis.Text)+1 then begin
    txtAis.Text := IntToStr(StrToInt(txtAis.Text) - 1);
    UdAis.Max := StrToInt(txtAis.Text);
  end
  else UdAis.Max := StrToInt(txtSlots.Text)-1;
end;

procedure TFrmHostGame.BtnAdvancedClick(Sender: TObject);
begin
  if not AdvancedOpened then begin
    AdvancedOpened := true;
    self.Height := 330;
    BtnAdvanced.Caption := GetStr(36) + ' <<';
  end
  else begin
    AdvancedOpened := false;
    self.Height := 211;
    BtnAdvanced.Caption := GetStr(36) + ' >>';
  end;
end;

procedure TFrmHostGame.FormActivate(Sender: TObject);
begin
  { Imposta la lingua }
  lblAis.Caption := GetStr(33) + ': ';
  lblInitialMoney.Caption := GetStr(34) + ': ';
  BtnOK.Caption := GetStr(35);
  BtnAdvanced.Caption := GetStr(36) + ' >>';
  self.Caption := GetStr(37);
  lblTableName.Caption := GetStr(38) + ': ';
  lblPort.Caption := GetStr(11) + ': ';
  lblCip.Caption := GetStr(178) + ': ';
  GrpAdvanced.Caption := GetStr(36);
end;

end.
