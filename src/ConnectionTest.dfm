object FrmConnectionTest: TFrmConnectionTest
  Left = 357
  Top = 193
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Verifica della connessione in corso...'
  ClientHeight = 85
  ClientWidth = 299
  Color = clSkyBlue
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
  PixelsPerInch = 96
  TextHeight = 13
  object lblOpenTest: TLabel
    Left = 32
    Top = 8
    Width = 257
    Height = 20
    AutoSize = False
    Caption = 'Apertura del server di test sulla porta 1500'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblConnectionTest: TLabel
    Left = 32
    Top = 32
    Width = 265
    Height = 20
    AutoSize = False
    Caption = 'Verifica della connessione con il client'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblSendReceiveTest: TLabel
    Left = 32
    Top = 56
    Width = 265
    Height = 20
    AutoSize = False
    Caption = 'Prova di invio/ricezione dei messaggi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object ImgOpenTest: TImage
    Left = 8
    Top = 9
    Width = 18
    Height = 18
    Transparent = True
  end
  object ImgConnectionTest: TImage
    Left = 8
    Top = 33
    Width = 18
    Height = 18
    Transparent = True
  end
  object ImgSendReceiveTest: TImage
    Left = 8
    Top = 57
    Width = 18
    Height = 18
    Transparent = True
  end
end