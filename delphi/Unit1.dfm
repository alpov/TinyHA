object Form1: TForm1
  Left = 468
  Top = 115
  Width = 574
  Height = 238
  Anchors = [akLeft, akTop, akRight]
  Caption = 'Bootloader'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    566
    211)
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 10
    Top = 165
    Width = 70
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Nep'#345'ipojeno'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 10
    Top = 10
    Width = 547
    Height = 141
    Caption = ' Aktualizace firmware '
    TabOrder = 0
    DesignSize = (
      547
      141)
    object Label12: TLabel
      Left = 15
      Top = 20
      Width = 41
      Height = 13
      Caption = 'P'#345'ipojit k'
    end
    object Label2: TLabel
      Left = 300
      Top = 20
      Width = 40
      Height = 13
      Caption = 'Za'#345#237'zen'#237
    end
    object Label4: TLabel
      Left = 300
      Top = 35
      Width = 146
      Height = 13
      AutoSize = False
      Caption = '(neur'#269'eno)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 300
      Top = 75
      Width = 146
      Height = 13
      AutoSize = False
      Caption = '(neur'#269'eno)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 300
      Top = 60
      Width = 60
      Height = 13
      Caption = 'EEPROM ID'
    end
    object Label5: TLabel
      Left = 140
      Top = 20
      Width = 54
      Height = 13
      Caption = 'ID jednotky'
    end
    object BitBtn2: TBitBtn
      Left = 15
      Top = 105
      Width = 151
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Restartovat'
      Enabled = False
      TabOrder = 0
      OnClick = BitBtn2Click
    end
    object BitBtn3: TBitBtn
      Left = 15
      Top = 65
      Width = 106
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'P'#345'ipojit'
      TabOrder = 1
      OnClick = BitBtn3Click
    end
    object ComComboBox1: TComComboBox
      Left = 15
      Top = 35
      Width = 106
      Height = 21
      ComPort = ComPort
      ComProperty = cpPort
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = -1
      TabOrder = 2
    end
    object BitBtn1: TBitBtn
      Left = 180
      Top = 105
      Width = 229
      Height = 25
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Spustit upgrade firmwaru'
      Enabled = False
      TabOrder = 3
      OnClick = BitBtn1Click
    end
    object BitBtn4: TBitBtn
      Left = 423
      Top = 105
      Width = 109
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'EEPROM'
      Enabled = False
      TabOrder = 4
      OnClick = BitBtn4Click
    end
    object Edit1: TEdit
      Left = 140
      Top = 35
      Width = 86
      Height = 21
      TabOrder = 5
      Text = '0'
    end
    object BitBtn5: TBitBtn
      Left = 180
      Top = 80
      Width = 96
      Height = 20
      Anchors = [akLeft, akBottom]
      Caption = 'Povel reboot'
      TabOrder = 6
      OnClick = BitBtn5Click
    end
  end
  object ProgressBar: TProgressBar
    Left = 11
    Top = 183
    Width = 546
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
  end
  object ComPort: TComPort
    BaudRate = br19200
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalConstant = 3000
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    Left = 530
    Top = 5
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Bin'#225'rky|*.bin|V'#353'echny soubory|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 535
    Top = 35
  end
end
