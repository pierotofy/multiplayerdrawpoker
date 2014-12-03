unit Chat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  TelephoneRing, Constants, Languages;

type
  TFrmChat = class(TForm)
    txtChat: TMemo;
    txtMessage: TEdit;
    BtnSend: TButton;
    procedure FormActivate(Sender: TObject);
  private
    FirstActivation: boolean; //Per tener traccia della prima apertura della form
    FrmParent: TForm;
    TelephoneRing: TTelephoneRing; //Istanza dell'oggetto che si occupa dello squillio del telefono
  public
    constructor Create(AOwner: TComponent; FrmParent: TForm; TelephoneRing: TTelephoneRing); overload;
  end;

var
  FrmChat: TFrmChat;

implementation

{$R *.dfm}

{ Costruttore personalizzato }
constructor TFrmChat.Create(AOwner: TComponent; FrmParent: TForm; TelephoneRing: TTelephoneRing);
begin
  inherited Create(AOwner);

  self.FrmParent := FrmParent;
  self.TelephoneRing := TelephoneRing;
  FirstActivation := true;
end;

procedure TFrmChat.FormActivate(Sender: TObject);
begin
  { Se è la prima volta non notificare nulla, il gioco si sta inizializzando }
  if FirstActivation then FirstActivation := false
  else TelephoneRing.StopRinging;

  { Imposta la lingua.. }
  BtnSend.Caption := GetStr(14);
  
  //FrmParent.Caption := PROGRAMNAME;

end;

end.
