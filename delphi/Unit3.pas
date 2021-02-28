unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    Button1: TButton;
    Button4: TButton;
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var
  I: Integer;
  BlockCount: Integer;
  Buffer: array[0..1023] of Byte;
  Cmd: array[0..3] of Byte;
begin
  Screen.Cursor := crHourGlass;
  BlockCount := $1FF div Form1.PageSize;
  FillChar(Buffer, Form1.PageSize, $FF);
  Form1.ComPort.WriteStr('A'#0#0); // Set Address
  if not Form1.WaitCR then Exit;
  for I := 1 to BlockCount do begin
    Cmd[0] := Ord('B');
    Cmd[1] := (Form1.PageSize and $ff00) shr 8;
    Cmd[2] := (Form1.PageSize and $00ff);
    Cmd[3] := Ord('E');
    Sleep(5);
    Form1.ComPort.Write(Cmd, 4); // Start Block EEPROM Load
    Form1.ComPort.Write(Buffer, Form1.PageSize);
    if not Form1.WaitCR then Exit;
  end;
  Screen.Cursor := crDefault;
end;

procedure TForm3.Button4Click(Sender: TObject);
var
  Addr, Count: Integer;
  Buffer: array[0..3] of Byte;
  Cmd: array[0..3] of Byte;
begin
  Addr := $1FF;
  Count := 1;
  Buffer[0] := StrToIntDef(Edit1.Text, 0);
  if (Buffer[0] = 0) or (Buffer[0] = 255) then begin
    ShowMessage('Neplatné ID');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  Form1.ComPort.WriteStr('A'+Chr(Addr shr 8)+Chr(Addr and $FF)); // Set Address
  if not Form1.WaitCR then Exit;
  Cmd[0] := Ord('B');
  Cmd[1] := (Count and $ff00) shr 8;
  Cmd[2] := (Count and $00ff);
  Cmd[3] := Ord('E');
  Sleep(5);
  Form1.ComPort.Write(Cmd, 4); // Start Block EEPROM Load
  Form1.ComPort.Write(Buffer, Count);
  if not Form1.WaitCR then Exit;
  Screen.Cursor := crDefault;
end;

end.
