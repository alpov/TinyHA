object Form3: TForm3
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Nastaven'#237' EEPROM'
  ClientHeight = 203
  ClientWidth = 194
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 10
    Top = 10
    Width = 171
    Height = 66
    Caption = ' Obecn'#233' '
    TabOrder = 0
    object Button1: TButton
      Left = 10
      Top = 25
      Width = 146
      Height = 25
      Caption = 'Vymazat EEPROM'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 10
    Top = 85
    Width = 171
    Height = 66
    Caption = ' Dohled '
    TabOrder = 1
    object Button4: TButton
      Left = 10
      Top = 25
      Width = 75
      Height = 25
      Caption = 'Nastavit ID'
      TabOrder = 0
      OnClick = Button4Click
    end
    object Edit1: TEdit
      Left = 95
      Top = 27
      Width = 61
      Height = 21
      TabOrder = 1
      Text = '0'
    end
  end
  object BitBtn1: TBitBtn
    Left = 60
    Top = 165
    Width = 75
    Height = 25
    Caption = 'Zav'#345#237't'
    TabOrder = 2
    Kind = bkClose
  end
end
