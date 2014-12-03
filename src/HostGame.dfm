object FrmHostGame: TFrmHostGame
  Left = 301
  Top = 123
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Nuova Partita'
  ClientHeight = 184
  ClientWidth = 214
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
  object lblNickname: TLabel
    Left = 8
    Top = 12
    Width = 51
    Height = 13
    Caption = 'Nickname:'
  end
  object lblInitialMoney: TLabel
    Left = 8
    Top = 92
    Width = 73
    Height = 13
    Caption = 'Denaro Iniziale:'
  end
  object lblSlots: TLabel
    Left = 8
    Top = 118
    Width = 26
    Height = 13
    Caption = 'Slots:'
  end
  object lblPassword: TLabel
    Left = 8
    Top = 36
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object lblAis: TLabel
    Left = 8
    Top = 62
    Width = 157
    Height = 13
    Caption = 'Giocatori controllati dal computer:'
  end
  object BtnOK: TButton
    Left = 8
    Top = 144
    Width = 113
    Height = 33
    Caption = '&Avvia la partita'
    Default = True
    TabOrder = 0
    OnClick = BtnOKClick
  end
  object txtNickname: TEdit
    Left = 64
    Top = 8
    Width = 137
    Height = 21
    TabOrder = 1
    Text = 'pierotofy'
    OnChange = txtNicknameChange
  end
  object txtSlots: TEdit
    Left = 40
    Top = 114
    Width = 17
    Height = 21
    ReadOnly = True
    TabOrder = 2
    Text = '4'
  end
  object txtInitialMoney: TEdit
    Left = 88
    Top = 88
    Width = 97
    Height = 21
    MaxLength = 7
    TabOrder = 3
    Text = '1000'
  end
  object txtPassword: TEdit
    Left = 64
    Top = 32
    Width = 113
    Height = 21
    PasswordChar = '*'
    TabOrder = 4
  end
  object udSlots: TUpDown
    Left = 57
    Top = 114
    Width = 15
    Height = 21
    Associate = txtSlots
    Min = 2
    Max = 4
    Position = 4
    TabOrder = 5
    OnClick = udSlotsClick
  end
  object txtAis: TEdit
    Left = 176
    Top = 58
    Width = 17
    Height = 21
    ReadOnly = True
    TabOrder = 6
    Text = '0'
  end
  object UdAis: TUpDown
    Left = 193
    Top = 58
    Width = 15
    Height = 21
    Associate = txtAis
    Max = 3
    TabOrder = 7
  end
  object GrpAdvanced: TGroupBox
    Left = 8
    Top = 184
    Width = 193
    Height = 113
    Caption = 'Avanzate'
    TabOrder = 8
    object lblCip: TLabel
      Left = 8
      Top = 80
      Width = 75
      Height = 13
      Caption = 'Puntata minima:'
    end
    object lblPort: TLabel
      Left = 8
      Top = 48
      Width = 28
      Height = 13
      Caption = 'Porta:'
    end
    object lblTableName: TLabel
      Left = 8
      Top = 20
      Width = 80
      Height = 13
      Caption = 'Nome del tavolo:'
    end
    object txtCip: TEdit
      Left = 88
      Top = 76
      Width = 49
      Height = 21
      MaxLength = 7
      TabOrder = 0
      Text = '10'
    end
    object txtPort: TEdit
      Left = 40
      Top = 44
      Width = 49
      Height = 21
      MaxLength = 5
      TabOrder = 1
      Text = '1500'
    end
    object txtTableName: TEdit
      Left = 96
      Top = 16
      Width = 89
      Height = 21
      TabOrder = 2
    end
  end
  object BtnAdvanced: TButton
    Left = 128
    Top = 148
    Width = 81
    Height = 25
    Caption = '&Avanzate >>'
    TabOrder = 9
    OnClick = BtnAdvancedClick
  end
end
