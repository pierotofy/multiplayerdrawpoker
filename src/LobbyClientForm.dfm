object FrmLobbyClient: TFrmLobbyClient
  Left = 229
  Top = 161
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Lobby Multiplayer'
  ClientHeight = 366
  ClientWidth = 463
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GrpUsers: TGroupBox
    Left = 328
    Top = 0
    Width = 129
    Height = 129
    Caption = 'Utenti connessi'
    TabOrder = 0
    object LstUsers: TListBox
      Left = 8
      Top = 16
      Width = 113
      Height = 105
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = LstUsersDblClick
    end
  end
  object GrpGames: TGroupBox
    Left = 328
    Top = 136
    Width = 129
    Height = 201
    Caption = 'Partite disponibili'
    TabOrder = 1
    object LstGames: TListBox
      Left = 8
      Top = 16
      Width = 113
      Height = 113
      ItemHeight = 13
      TabOrder = 0
      OnClick = LstGamesClick
      OnDblClick = LstGamesDblClick
    end
    object BtnJoin: TButton
      Left = 8
      Top = 136
      Width = 113
      Height = 25
      Caption = '&Partecipa'
      Enabled = False
      TabOrder = 1
    end
    object BtnHost: TButton
      Left = 8
      Top = 168
      Width = 113
      Height = 25
      Caption = '&Crea partita'
      Enabled = False
      TabOrder = 2
    end
  end
  object txtMessage: TEdit
    Left = 8
    Top = 312
    Width = 257
    Height = 21
    TabOrder = 2
  end
  object BtnSend: TButton
    Left = 272
    Top = 310
    Width = 49
    Height = 25
    Caption = '&Invia'
    Default = True
    TabOrder = 3
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 343
    Width = 463
    Height = 23
    Color = clMoneyGreen
    Panels = <
      item
        Width = 50
      end>
  end
  object txtChat: TMemo
    Left = 8
    Top = 8
    Width = 313
    Height = 297
    ReadOnly = True
    TabOrder = 5
  end
end
