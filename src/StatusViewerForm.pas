unit StatusViewerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Languages;

type
  TFrmStatusViewer = class(TForm)
    LstStatus: TListBox;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmStatusViewer: TFrmStatusViewer;

implementation

{$R *.dfm}

procedure TFrmStatusViewer.FormActivate(Sender: TObject);
begin
  { Imposta la lingua }
  self.Caption := GetStr(56);
end;

end.
