unit TCPView.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, System.Actions,
  Vcl.ActnList, Vcl.Menus, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TfrmTCPView = class(TForm)
    VST: TVirtualStringTree;
    ActionList1: TActionList;
    acApp: TAction;
    acAppExit: TAction;
    acRefresh: TAction;
    MainMenu1: TMainMenu;
    App1: TMenuItem;
    Exit1: TMenuItem;
    acView: TAction;
    View1: TMenuItem;
    Refresh1: TMenuItem;
    acRefresh1Sec: TAction;
    acRefresh2Secs: TAction;
    acRefresh5Secs: TAction;
    acRefreshPaused: TAction;
    N1second1: TMenuItem;
    N2seconds1: TMenuItem;
    N5seconds1: TMenuItem;
    Paused1: TMenuItem;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    procedure acAppExitExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure acRefresh1SecExecute(Sender: TObject);
    procedure acRefresh2SecsExecute(Sender: TObject);
    procedure acRefresh5SecsExecute(Sender: TObject);
    procedure acRefreshPausedExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  type
    TRefreshSpeed = (rfRefreshPaused, rfRefresh1Sec, rfRefresh2Secs, rfRefresh5Secs);
  var
    { Private declarations }
    FRefreshSpeed: TRefreshSpeed;
    FActions: TArray<TAction>;
    procedure UncheckActions(ARefreshSpeed: TRefreshSpeed);
    function GetPIDName(hSnapShot: THandle; PID: DWORD): string;
  public
    { Public declarations }
  end;

var
  frmTCPView: TfrmTCPView;

implementation
uses
  TCPView.IPHelper, Winapi.IpHlpApi, Winapi.WinSock, Winapi.Winsock2,
  Winapi.TlHelp32;

{$R *.dfm}

type
  TProtocol = (tpTCP, tpTCPv6, tpUDP, tpUDPv6);
  TState    = (tsListening, tsEstablished, tsSyn_Rcvd, tsFin_Wait1, tsFin_Wait2);
  PData = ^TData;
  TData = record
    ProcessName: string;
    PID: Integer;
    Protocol: TProtocol;
    LocalAddress: string;
    LocalPort: Integer;
    RemoteAddress: string;
    RemotePort: string;
    State: string;
    SentPackets, SentBytes, RcvdPackets, RcvdBytes: UInt64;
  end;

const
  MIB_TCP_STATE: array[0..12] of string = ('UNKNOWN', 'CLOSED', 'LISTENING', 'SYN SENT',
   'SYN RECEIVED', 'ESTABLISHED', 'FIN WAIT-1', 'FIN WAIT-2', 'CLOSE WAIT',
   'CLOSING', 'LAST ACK', 'TIME WAIT', 'DELETED');

function TfrmTCPView.GetPIDName(hSnapShot: THandle; PID: DWORD): string;
var
  LFound: Boolean;
  ProcInfo: TProcessEntry32;
begin
  LFound := False;
  ProcInfo.dwSize := SizeOf(ProcInfo);
  if Process32First(hSnapShot, ProcInfo) then
    begin
      repeat
        if ProcInfo.th32ProcessID = PID then
          begin
            Result := ProcInfo.szExeFile;
            LFound := True;
            Break;
          end;
      until not Process32Next(hSnapShot, ProcInfo)
    end;
  if not LFound then
    Result := '[Unknown]';
end;

// Currently unused. Also, logic bug: LAppName is not initialized, so the
// comparison will always fail.
procedure ShowTCPPortsUsed(const AppName : string);
var
   Error      : DWORD;
   TableSize  : DWORD;
   i          : integer;
   pTcpTable  : PMIB_TCPTABLE_OWNER_PID;
   SnapShot   : THandle;
   LAppName   : string;
   LPorts     : TStrings;
begin
  LPorts := TStringList.Create;
  try
    TableSize := 0;
    //Get the size o the tcp table
    Error := GetExtendedTcpTable(nil, @TableSize, True, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
    if Error <> ERROR_INSUFFICIENT_BUFFER then exit;

    GetMem(pTcpTable, TableSize);
    try
     SnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
     try
       //get the tcp table data
       if GetExtendedTcpTable(pTcpTable, @TableSize, True, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
          for i := 0 to pTcpTable.dwNumEntries - 1 do
          begin
//             LAppName := GetPIDName(SnapShot, pTcpTable.Table[i].dwOwningPid);
             if SameText(LAppName, AppName) and (LPorts.IndexOf(IntToStr(pTcpTable.Table[i].dwLocalPort))=-1) then
               LPorts.Add(IntToStr(pTcpTable.Table[i].dwLocalPort));
          end;
     finally
       CloseHandle(SnapShot);
     end;
    finally
       FreeMem(pTcpTable);
    end;

    Writeln(LPorts.Text);

  finally
    LPorts.Free;
  end;

end;

procedure TfrmTCPView.acAppExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmTCPView.acRefresh1SecExecute(Sender: TObject);
begin
  FRefreshSpeed := rfRefresh1Sec;
  UncheckActions(rfRefresh1Sec);
  Timer1.Enabled := False;
  Timer1.Interval := 1000;
  Timer1.Enabled := True;
end;

procedure TfrmTCPView.acRefresh2SecsExecute(Sender: TObject);
begin
  FRefreshSpeed := rfRefresh2Secs;
  UncheckActions(rfRefresh2Secs);
  Timer1.Enabled := False;
  Timer1.Interval := 2000;
  Timer1.Enabled := True;
end;

procedure TfrmTCPView.acRefresh5SecsExecute(Sender: TObject);
begin
  FRefreshSpeed := rfRefresh5Secs;
  UncheckActions(rfRefresh5Secs);
  Timer1.Enabled := False;
  Timer1.Interval := 5000;
  Timer1.Enabled := True;
end;

procedure TfrmTCPView.acRefreshPausedExecute(Sender: TObject);
begin
  UncheckActions(rfRefreshPaused);
  Timer1.Enabled := False;
end;

procedure TfrmTCPView.FormCreate(Sender: TObject);
begin
  FActions := [acRefreshPaused, acRefresh1Sec, acRefresh2Secs, acRefresh5Secs];
  acRefresh.Execute;
end;

procedure TfrmTCPView.acRefreshExecute(Sender: TObject);

var
  LNode: PVirtualNode;
  LData: PData;
  LError: DWORD;
  LTableSize: DWORD;
  LTcpTable: PMIB_TCPTABLE_OWNER_PID;
  LTcpTablev6: PMIB_TCP6TABLE_OWNER_PID absolute LTcpTable;
  LUdpTable: PMIB_UDPTABLE_OWNER_PID;
  LUdpTablev6: PMIB_UDP6TABLE_OWNER_PID absolute LUdpTable;
  LSnapshot: THandle;
  LAppName: string;
  LAF: Cardinal;
  LAFs: TArray<Cardinal>;
  OldCursor: TCursor;
  LState, LEndpoints, LListening, LEstablished, LTimeWait, LCloseWait: Integer;
  LLocalAddress, LRemoteAddress: array[0..45] of Char;

  procedure TcpLoop;
  var
    I: Integer;
  begin
    LTableSize := 0;
    FillChar(LLocalAddress, SizeOf(LLocalAddress), 1);
    FillChar(LRemoteAddress, SizeOf(LRemoteAddress), 1);
    //Get the size of the tcp table
    LError := GetExtendedTcpTable(nil, @LTableSize, True, LAF, TCP_TABLE_OWNER_PID_ALL, 0);
    if LError = ERROR_INSUFFICIENT_BUFFER then
      begin
        GetMem(LTcpTable, LTableSize);
        try
          //get the tcp table data
          if GetExtendedTcpTable(LTcpTable, @LTableSize, True, LAF, TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
            begin
              for I := 0 to LTcpTable.dwNumEntries - 1 do
                begin
                  case LAF of
                    AF_INET:
                      begin
                        LState := LTcpTable.Table[I].dwState;
                        if LState = MIB_TCP_STATE_UNKNOWN then Continue;
                        LAppName := GetPIDName(LSnapshot, LTcpTable.Table[I].dwOwningPid);
                        LNode := VST.AddChild(nil);
                        LData := VST.GetNodeData(LNode);
                        LData.ProcessName := LAppName;
                        LData.PID := LTcpTable.Table[I].dwOwningPid;
                        LData.Protocol := tpTCP;
                        LData.LocalAddress  := string(inet_ntoa(in_addr(LTcpTable.Table[I].dwLocalAddr)));
                        LData.LocalPort     := ntohs(LTcpTable.Table[I].dwLocalPort);
                        case LState of
                          MIB_TCP_STATE_LISTEN: Inc(LListening);
                          MIB_TCP_STATE_ESTAB:  Inc(LEstablished);
                          MIB_TCP_STATE_TIME_WAIT: Inc(LTimeWait);
                          MIB_TCP_STATE_CLOSE_WAIT: Inc(LCloseWait);
                        end;
                        Inc(LEndpoints);
                        LData.State         := MIB_TCP_STATE[LState];
                        LData.RemoteAddress := string(inet_ntoa(in_addr(LTcpTable.Table[I].dwRemoteAddr)));// else
                        LData.RemotePort  := IntToStr(ntohs(LTcpTable.Table[I].dwRemotePort));
                      end;
                    AF_INET6:
                      begin
                        LState := LTcpTablev6.Table[I].dwState;
                        if LState = MIB_TCP_STATE_UNKNOWN then Continue;
                        LAppName := GetPIDName(LSnapshot, LTcpTablev6.Table[I].dwOwningPid);
                        LNode := VST.AddChild(nil);
                        LData := VST.GetNodeData(LNode);
                        LData.ProcessName := LAppName;
                        LData.PID := LTcpTablev6.Table[I].dwOwningPid;
                        LData.Protocol := tpTCPv6;
                        RtlIpv6AddressToString(@LTcpTablev6.Table[I].dwLocalAddr, @LLocalAddress);
                        LData.LocalAddress  := LLocalAddress;
                        LData.LocalPort     := ntohs(LTcpTablev6.Table[I].dwLocalPort);
                        case LState of
                          MIB_TCP_STATE_LISTEN: Inc(LListening);
                          MIB_TCP_STATE_ESTAB:  Inc(LEstablished);
                          MIB_TCP_STATE_TIME_WAIT: Inc(LTimeWait);
                          MIB_TCP_STATE_CLOSE_WAIT: Inc(LCloseWait);
                        end;
                        Inc(LEndpoints);
                        LData.State         := MIB_TCP_STATE[LState];
                        RtlIpv6AddressToString(@LTcpTablev6.Table[I].dwRemoteAddr, @LRemoteAddress);
                        LData.RemoteAddress := LRemoteAddress;
                        LData.RemotePort  := IntToStr(ntohs(LTcpTablev6.Table[I].dwRemotePort));
                      end;
                  end;
                end;
            end;
          StatusBar1.Panels[0].Text := Format('Endpoints: %d', [LEndpoints]);
          StatusBar1.Panels[1].Text := Format('Established: %d', [LEstablished]);
          StatusBar1.Panels[2].Text := Format('Listening: %d', [LListening]);
          StatusBar1.Panels[3].Text := Format('Time Wait: %d', [LTimeWait]);
          StatusBar1.Panels[4].Text := Format('Close Wait: %d', [LCloseWait]);
        finally
          FreeMem(LTcpTable);
        end;
      end;
  end;

  procedure UdpLoop;
  var
    I: Integer;
  begin
    LTableSize := 0;
    LError := GetExtendedUdpTable(nil, @LTableSize, True, LAF, UDP_TABLE_OWNER_PID_ALL, 0);
    if LError = ERROR_INSUFFICIENT_BUFFER then
      begin
        GetMem(LUdpTable, LTableSize);
        try
          //get the udp table data
          if GetExtendedUdpTable(LUdpTable, @LTableSize, True, LAF, UDP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
            begin
              for I := 0 to LUdpTable.dwNumEntries - 1 do
                begin
                  case LAF of
                    AF_INET:
                      begin
                        LAppName := GetPIDName(LSnapshot, LUdpTable.Table[I].dwOwningPid);
                        LNode := VST.AddChild(nil);
                        LData := VST.GetNodeData(LNode);
                        LData.ProcessName := LAppName;
                        LData.PID := LUdpTable.Table[I].dwOwningPid;
                        LData.Protocol := tpUDP;
                        LData.LocalAddress  := string(inet_ntoa(in_addr(LUdpTable.Table[I].dwLocalAddr)));
                        LData.LocalPort     := ntohs(LUdpTable.Table[I].dwLocalPort);
                        Inc(LEndpoints);
                        LData.State         := '';
                        LData.RemoteAddress := '*';
                        LData.RemotePort  := '*';
                      end;
                    AF_INET6:
                      begin
                        LAppName := GetPIDName(LSnapshot, LUdpTablev6.Table[I].dwOwningPid);
                        LNode := VST.AddChild(nil);
                        LData := VST.GetNodeData(LNode);
                        LData.ProcessName := LAppName;
                        LData.PID := LUdpTablev6.Table[I].dwOwningPid;
                        LData.Protocol := tpUDPv6;
                        RtlIpv6AddressToString(@LUdpTablev6.Table[I].dwLocalAddr, LLocalAddress);
                        LData.LocalAddress  := LLocalAddress;
                        LData.LocalPort     := ntohs(LUdpTablev6.Table[I].dwLocalPort);
                        Inc(LEndpoints);
                        LData.State         := '';
                        LData.RemoteAddress := '*';
                        LData.RemotePort  := '*';
                      end;
                  end;
                end;
            end;
          StatusBar1.Panels[0].Text := Format('Endpoints: %d', [LEndpoints]);
          StatusBar1.Panels[1].Text := Format('Established: %d', [LEstablished]);
          StatusBar1.Panels[2].Text := Format('Listening: %d', [LListening]);
          StatusBar1.Panels[3].Text := Format('Time Wait: %d', [LTimeWait]);
          StatusBar1.Panels[4].Text := Format('Close Wait: %d', [LCloseWait]);
        finally
          FreeMem(LUdpTable);
        end;
      end;
  end;

begin
  LEndpoints := 0; LListening := 0; LEstablished := 0; LTimeWait := 0; LCloseWait := 0;
  LTcpTable := nil; LUdpTable := nil;
  VST.NodeDataSize := SizeOf(TData);
  VST.BeginUpdate;
  VST.Clear;
  LAFs := [AF_INET, AF_INET6];
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    for LAF in LAFs do
      begin
        TcpLoop;
        UdpLoop;
      end;
  finally
    CloseHandle(LSnapshot);
  end;
  Screen.Cursor := OldCursor;
  VST.EndUpdate;
end;

procedure TfrmTCPView.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  acRefresh.Execute;
  Timer1.Enabled := True;
end;

procedure TfrmTCPView.UncheckActions(ARefreshSpeed: TRefreshSpeed);
var
  LAction: TAction;
begin
  FRefreshSpeed := ARefreshSpeed;
  for LAction in FActions do
    if LAction <> FActions[Ord(ARefreshSpeed)] then
      LAction.Checked := False;
  FActions[Ord(ARefreshSpeed)].Checked := True;
end;

procedure TfrmTCPView.VSTCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  LData1, LData2: PData;
begin
  //
  if Column >= 0 then
    begin
      LData1 := Node1.GetData;
      LData2 := Node2.GetData;
      case Column of
        0: Result := CompareText(LData1.ProcessName, LData2.ProcessName);
        1: if LData1.PID < LData2.PID then
             Result := -1 else
           if LData1.PID = LData2.PID then
             Result := 0 else
             Result := 1;
        2: if LData1.Protocol < LData2.Protocol then
             Result := -1 else
           if LData1.Protocol = LData2.Protocol  then
             Result := 0 else
             Result := 1;
        3: Result := CompareText(LData1.LocalAddress, LData2.LocalAddress);
        4: if LData1.LocalPort < LData2.LocalPort then
             Result := -1 else
           if LData1.LocalPort = LData2.LocalPort then
             Result := 0 else
             Result := 1;
        5: Result := CompareText(LData1.RemoteAddress, LData2.RemoteAddress);
        6: Result := CompareText(LData1.RemotePort, LData2.RemotePort);
//        if LData1.RemotePort < LData2.RemotePort then
//             Result := -1 else
//           if LData1.RemotePort = LData2.RemotePort then
//             Result := 0 else
//             Result := 1;
        7: Result := CompareText(LData1.State, LData2.State);
      end;
    end;
end;

procedure TfrmTCPView.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LData: PData;
begin
  LData := Node.GetData;
  if TextType = ttNormal then
    case Column of
      0: CellText := LData.ProcessName;
      1: CellText := IntToStr(LData.PID);
      2: case LData.Protocol of
           tpTCP: CellText := 'TCP';
           tpTCPv6: CellText := 'TCPv6';
           tpUdp: CellText := 'UDP';
           tpUDPv6: CellText := 'UDPv6';
         end;
      3: CellText := LData.LocalAddress;
      4: CellText := IntToStr(LData.LocalPort);
      5: CellText := LData.RemoteAddress;
      6: CellText := LData.RemotePort;
      7: CellText := LData.State;
      8: CellText := ''; // 'Sent Packets';
      9: CellText := ''; // 'Sent Bytes';
     10: CellText := ''; // 'Rcvd Packets';
     11: CellText := ''; // 'Rcvd Bytes';
    end;
end;

end.
