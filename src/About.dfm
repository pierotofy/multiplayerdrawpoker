object FrmAbout: TFrmAbout
  Left = 370
  Top = 241
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Informazioni su MultiplayerPoker...'
  ClientHeight = 208
  ClientWidth = 320
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000000020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    000000000000000000000000000000000000000000000000000FF00000000000
    00000000000000000FFF9F0000000000FF0000000000000FFFF9990000000000
    FF0F00000F000FFFFFF9990000000000FF0FF0FF0F0FFFFFFFFF9F000000000F
    FF0FF0FF0FF0FFFFFFFFFFF00000000FFF0FF0FF0FF0FFFFFFFFF9F00000000F
    FF0FF0FFF0F0FFFFFFFF99F00000000FFF0FF0FFF0FF0FFF99FF99F00000000F
    FF0FF0FFF0FF0FFF999999FF0000000FF0FFF0FFF0FF0FFF999F99FF0000000F
    F0FFF0FFF0FF0FFFF99F99FF0000000FF0FFF0FFF0FFF0FFF99999FFF00000FF
    F0FFF0FFFF0FF0FFFF9999FFF00000FFF0FFF0FFFF0FF0FFFFF999FFF00000FF
    F0FFF0FFFF0FFF0FFFF999FFF00000FFF0FFF0FFFF0FFF0FFFFF9FFFFF0000FF
    F0FF10FFFF0FFF0FFFFFFFFFFF000FF9F0FFF0FFFF0FFFF0FF9FFFFFFF000F99
    9FF9F0FFFFF0FF90F999FFFFFF000F999F9990FFF9F0F9990999FFFFFFF00FF9
    FF9990FF9990F9990F9FFFFFFFF00FFF0FF9F0FF9990FF9F0FFFFFFFF000000F
    0FFFF0FFF9F0FFFF0FFFFFF000000000000000FFFFF0F0F00FFF000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FE7FFFFFF83FE0FFC01FE07B001FE000001FE000001FC000000FC000000FC000
    000FC000000FC0000007C0000007C0000007C000000380000003800000038000
    0003800000018000000100000001000000010000000000000000000000010000
    0007C000001FFF80003FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblProgramName: TLabel
    Left = 8
    Top = 8
    Width = 305
    Height = 24
    Alignment = taCenter
    AutoSize = False
    Caption = 'Scritta Multiplayer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblLicense: TLabel
    Left = 8
    Top = 40
    Width = 313
    Height = 49
    AutoSize = False
    Caption = 
      'Questo software '#232' concesso sotto licenza GNU GPL, tuttavia vi pr' +
      'ego di segnalarmi via e-mail qualsiasi eventuale modifica al cod' +
      'ice sorgente.'
    WordWrap = True
  end
  object lblNotes: TLabel
    Left = 8
    Top = 88
    Width = 305
    Height = 57
    AutoSize = False
    Caption = 
      'Note dell'#39'autore: "Il motivo che mi ha spinto a costruire questo' +
      ' programma, '#232' stata la mancanza di un gioco simile ad Hearts, ma' +
      ' emozionante come il poker per passare serenamente le ore di inf' +
      'ormatica a scuola."'
    WordWrap = True
  end
  object lblMail: TLabel
    Left = 8
    Top = 160
    Width = 22
    Height = 13
    Caption = 'Mail:'
  end
  object lblWeb: TLabel
    Left = 8
    Top = 176
    Width = 26
    Height = 13
    Caption = 'Web:'
  end
  object lblShowMail: TLabel
    Left = 32
    Top = 160
    Width = 87
    Height = 13
    Cursor = crHandPoint
    Caption = 'admin@pierotofy.it'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblShowMailClick
  end
  object lblShowWeb: TLabel
    Left = 40
    Top = 176
    Width = 106
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://www.pierotofy.it'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblShowWebClick
  end
  object lblPieroTofy: TLabel
    Left = 264
    Top = 144
    Width = 48
    Height = 13
    Caption = 'Piero Tofy'
  end
  object BtnClose: TButton
    Left = 216
    Top = 168
    Width = 97
    Height = 33
    Caption = '&Chiudi'
    ModalResult = 1
    TabOrder = 0
  end
end
