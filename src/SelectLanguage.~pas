unit SelectLanguage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, Languages;

type
  TFrmSelectLanguage = class(TForm)
    ImgWorld: TImage;
    LstLanguages: TListBox;
    BtnOK: TButton;
    procedure BtnOKClick(Sender: TObject);
    procedure LstLanguagesClick(Sender: TObject);
  private

  public
    SelectedLang: string;
    constructor Create(AOwner: TComponent; SupportedLanguages: TList);
  end;

var
  FrmSelectLanguage: TFrmSelectLanguage;

implementation

{$R *.dfm}

{ Costruttore personalizzato }
constructor TFrmSelectLanguage.Create(AOwner: TComponent; SupportedLanguages: TList);
var
  C: integer;
begin
  inherited Create(AOwner);

  for C := 0 to SupportedLanguages.Count-1 do
    LstLanguages.Items.AddObject(TLangFile(SupportedLanguages.Items[C]).ToString,TObject(SupportedLanguages.Items[C]));
end;

procedure TFrmSelectLanguage.BtnOKClick(Sender: TObject);
var
  C: integer;
begin
  for C := 0 to LstLanguages.Count-1 do
  begin
    if LstLanguages.Selected[C] then begin
      SelectedLang := TLangFile(LstLanguages.Items.Objects[C]).ToString;
      break;
    end;
  end;

  self.ModalResult := mrOK;
end;

procedure TFrmSelectLanguage.LstLanguagesClick(Sender: TObject);
begin
  BtnOK.Enabled := true;
end;

end.
