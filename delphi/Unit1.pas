unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Registry, CPort, StdCtrls, Gauges, Buttons, ComCtrls, CPortCtl,
  ExtCtrls, ShellAPI, Clipbrd;

type
  TForm1 = class(TForm)
    ComPort: TComPort;
    GroupBox1: TGroupBox;
    BitBtn2: TBitBtn;
    ProgressBar: TProgressBar;
    Label12: TLabel;
    BitBtn3: TBitBtn;
    ComComboBox1: TComComboBox;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Label7: TLabel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    BitBtn4: TBitBtn;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Edit1: TEdit;
    BitBtn5: TBitBtn;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
  public
    PageSize: Word;
    CurrBoardSig: Byte;
    function WaitCR: Boolean;
  end;

var
  Form1: TForm1;

implementation

uses Unit3;

{$R *.dfm}

function TForm1.WaitCR: Boolean;
var
  B: Byte;
begin
  if (ComPort.Read(B, 1) = 1) and (B = 13) then
    Result := True
  else begin
    Result := False;
    Label7.Caption := 'Chyba komunikace!';
  end;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  ComPort.WriteStr('E'); // Exit Bootloader
  ComPort.Close;
  Label7.Caption := 'Bootloader ukonèen';
  BitBtn1.Enabled := False;
  BitBtn2.Enabled := False;
  BitBtn3.Enabled := True;
  BitBtn4.Enabled := False;
  BitBtn5.Enabled := True;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  I, J: Integer;
  BlockCount: Integer;
  Buffer: array[0..1023] of Byte;
  Buffer2: array[0..1023] of Byte;
  Cmd: array[0..3] of Byte;
  DataFile: TFileStream;
begin
  if not OpenDialog1.Execute then Exit;

  DataFile := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
  BitBtn1.Enabled := False;
  BitBtn2.Enabled := False;
  BitBtn4.Enabled := False;
  try
    ProgressBar.Position := 0;
    Application.ProcessMessages;

    BlockCount := (DataFile.Size + PageSize - 1) div PageSize;
    ProgressBar.Max := BlockCount;

    Label7.Caption := 'Mazání procesoru...';
    Application.ProcessMessages;
    Sleep(5);
    ComPort.WriteStr('e'); // Chip Erase
    if not WaitCR then Exit;

    Label7.Caption := 'Programování FLASH...';
    Application.ProcessMessages;
    Sleep(5);
    ComPort.WriteStr('A'#0#0); // Set Address
    DataFile.Seek(0, soFromBeginning);
    if not WaitCR then Exit;
    for I := 1 to BlockCount do begin
      J := DataFile.Read(Buffer, PageSize);
      Cmd[0] := Ord('B');
      Cmd[1] := (J and $ff00) shr 8;
      Cmd[2] := (J and $00ff);
      Cmd[3] := Ord('F');
      Sleep(5);
      ComPort.Write(Cmd, 4); // Start Block Flash Load
      ComPort.Write(Buffer, J);
      if not WaitCR then Exit;
      ProgressBar.Position := I;
      Application.ProcessMessages;
    end;

    Label7.Caption := 'Ovìøování FLASH...';
    Application.ProcessMessages;
    Sleep(5);
    ComPort.WriteStr('A'#0#0); // Set Address
    DataFile.Seek(0, soFromBeginning);
    if not WaitCR then Exit;
    for I := 1 to BlockCount do begin
      J := DataFile.Read(Buffer, PageSize);
      Cmd[0] := Ord('g');
      Cmd[1] := (J and $ff00) shr 8;
      Cmd[2] := (J and $00ff);
      Cmd[3] := Ord('F');
      Sleep(5);
      ComPort.Write(Cmd, 4); //Start Block Flash Read
      if (ComPort.Read(Buffer2, J) <> J) or (not CompareMem(@Buffer, @Buffer2, J)) then begin
        Label7.Caption := 'Ovìøení FLASH selhalo!';
        Exit;
      end;
      ProgressBar.Position := I;
      Application.ProcessMessages;
    end;

    Label7.Caption := 'Firmware upgradován a ovìøen!';

  finally
    BitBtn1.Enabled := True;
    BitBtn2.Enabled := True;
    BitBtn4.Enabled := True;
    BitBtn5.Enabled := False;
    DataFile.Free;
  end;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
var
  BinBuf: array[0..127] of Byte;
  I: Integer;
begin
  try
    ComPort.Port := ComComboBox1.Text;
    ComPort.Open;
  except
    MessageDlg('Chyba: nelze otevøít port', mtError, [mbOk], 0);
    Exit;
  end;
  BitBtn3.Enabled := False;

  ProgressBar.Max := 500;
  I := 0;
  repeat
    Label7.Caption := 'Pøipojuji se...';
    Inc(I);
    ProgressBar.Position := I;
    Application.ProcessMessages;
    ComPort.ClearBuffer(True, True);
    ComPort.WriteStr('S' + Chr(StrToIntDef(Edit1.Text, 0))); // singon
    Sleep(10);
    if (ComPort.InputCount >= 1) and WaitCR then Break;
    if I > 500 then begin
      MessageDlg('Chyba: nelze se pøipojit k bootloaderu', mtError, [mbOk], 0);
      BitBtn3.Enabled := True;
      Exit;
    end;
  until False;

  ComPort.ClearBuffer(True, True);
  ProgressBar.Position := 0;
  Label7.Caption := 'Pøipraven';
  BitBtn1.Enabled := True;
  BitBtn2.Enabled := True;
  BitBtn4.Enabled := True;
  BitBtn5.Enabled := False;

  Sleep(500);
  ComPort.ClearBuffer(True, True);
  ComPort.WriteStr('s'); // Read Signature
  ComPort.Read(BinBuf, 4);
  PageSize := BinBuf[2] shl 8 + BinBuf[3];

  Label4.Caption := Format('ID: 0x%.2X', [BinBuf[0]]);
  Label1.Caption := Format('ID: %d', [BinBuf[1]]);
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  Form3.ShowModal;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var
  Cmd: array[0..4] of Byte;
begin
  try
    ComPort.Port := ComComboBox1.Text;
    ComPort.Open;
  except
    MessageDlg('Chyba: nelze otevøít port', mtError, [mbOk], 0);
    Exit;
  end;

  Cmd[0] := StrToIntDef(Edit1.Text, 0);
  Cmd[1] := 250;
  Cmd[2] := $CC;
  Cmd[3] := $CC;
  Cmd[4] := Cmd[0] xor Cmd[1] xor Cmd[2] xor Cmd[3];
  ComPort.Write(Cmd, 5); // reboot

  ComPort.Close;
end;

end.
