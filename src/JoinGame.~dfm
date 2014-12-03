object FrmJoinGame: TFrmJoinGame
  Left = 393
  Top = 161
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Entra nella partita'
  ClientHeight = 375
  ClientWidth = 265
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
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblNickname: TLabel
    Left = 48
    Top = 12
    Width = 51
    Height = 13
    Caption = 'Nickname:'
  end
  object GrpSelectServer: TGroupBox
    Left = 11
    Top = 32
    Width = 246
    Height = 145
    Caption = 'Seleziona la partita'
    Color = clMoneyGreen
    Ctl3D = True
    ParentColor = False
    ParentCtl3D = False
    TabOrder = 1
    object lstServers: TListBox
      Left = 6
      Top = 24
      Width = 227
      Height = 81
      ItemHeight = 13
      TabOrder = 0
      OnClick = lstServersClick
    end
    object BtnConnectAtIP: TButton
      Left = 56
      Top = 108
      Width = 137
      Height = 29
      Caption = 'Aggiungi un Host/IP'
      TabOrder = 1
      OnClick = BtnConnectAtIPClick
    end
  end
  object GrpServerInfo: TGroupBox
    Left = 11
    Top = 183
    Width = 246
    Height = 146
    Caption = 'Informazioni sulla partita'
    TabOrder = 2
    object lblServerInfoName: TLabel
      Left = 8
      Top = 24
      Width = 31
      Height = 13
      Caption = 'Nome:'
    end
    object lblShowServerInfoName: TLabel
      Left = 40
      Top = 24
      Width = 105
      Height = 13
      AutoSize = False
    end
    object lblServerInfoPasswordRequired: TLabel
      Left = 8
      Top = 40
      Width = 91
      Height = 13
      Caption = 'Password richiesta:'
    end
    object lblShowServerInfoPasswordRequired: TLabel
      Left = 100
      Top = 40
      Width = 25
      Height = 13
      AutoSize = False
    end
    object lblServerInfoSlots: TLabel
      Left = 8
      Top = 56
      Width = 74
      Height = 13
      Caption = 'Slots disponibili:'
    end
    object lblShowServerInfoSlots: TLabel
      Left = 86
      Top = 56
      Width = 57
      Height = 13
      AutoSize = False
    end
    object lblServerInfoVersion: TLabel
      Left = 8
      Top = 120
      Width = 44
      Height = 13
      Caption = 'Versione:'
    end
    object lblShowServerInfoVersion: TLabel
      Left = 54
      Top = 120
      Width = 104
      Height = 13
      AutoSize = False
    end
    object lblServerInfoPort: TLabel
      Left = 8
      Top = 104
      Width = 28
      Height = 13
      Caption = 'Porta:'
    end
    object lblShowServerInfoPort: TLabel
      Left = 38
      Top = 104
      Width = 104
      Height = 13
      AutoSize = False
    end
    object lblServerInfoIP: TLabel
      Left = 8
      Top = 88
      Width = 40
      Height = 13
      Caption = 'Host/IP:'
    end
    object lblShowServerInfoIP: TLabel
      Left = 52
      Top = 88
      Width = 117
      Height = 13
      AutoSize = False
    end
    object lblServerInfoCip: TLabel
      Left = 8
      Top = 72
      Width = 18
      Height = 13
      Caption = 'Cip:'
    end
    object lblShowServerInfoCip: TLabel
      Left = 28
      Top = 72
      Width = 104
      Height = 13
      AutoSize = False
    end
  end
  object BtnOK: TButton
    Left = 88
    Top = 336
    Width = 97
    Height = 33
    Caption = '&Entra'
    TabOrder = 3
    OnClick = BtnOKClick
  end
  object txtNickname: TEdit
    Left = 104
    Top = 8
    Width = 113
    Height = 21
    TabOrder = 0
    Text = 'pierotofy'
  end
end
