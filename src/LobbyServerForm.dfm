object FrmLobbyServer: TFrmLobbyServer
  Left = 340
  Top = 154
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Server Lobby'
  ClientHeight = 158
  ClientWidth = 250
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
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 60
    Width = 27
    Height = 13
    Caption = 'Motd:'
  end
  object BtnStart: TButton
    Left = 72
    Top = 120
    Width = 121
    Height = 33
    Caption = '&Avvia'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = BtnStartClick
  end
  object GrpSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 105
    Caption = 'Impostazioni'
    TabOrder = 1
    object lblMotd: TLabel
      Left = 8
      Top = 28
      Width = 27
      Height = 13
      Caption = 'Motd:'
    end
    object lblPort: TLabel
      Left = 8
      Top = 52
      Width = 28
      Height = 13
      Caption = 'Porta:'
    end
    object Label2: TLabel
      Left = 8
      Top = 76
      Width = 81
      Height = 13
      Caption = 'Admin Password:'
    end
    object txtMotd: TEdit
      Left = 40
      Top = 24
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'Benvenuto nel server!'
    end
  end
  object txtPort: TEdit
    Left = 48
    Top = 56
    Width = 41
    Height = 21
    MaxLength = 5
    TabOrder = 2
    Text = '1500'
  end
  object txtAdminPassword: TEdit
    Left = 104
    Top = 80
    Width = 129
    Height = 21
    MaxLength = 12
    PasswordChar = '*'
    TabOrder = 3
  end
end