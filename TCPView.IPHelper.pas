unit TCPView.IPHelper platform;

interface
uses Winapi.Windows, Winapi.IpHlpApi, Winapi.IpExport;

const
  ANY_SIZE = 1;

  TCP_TABLE_BASIC_LISTENER           = 0;
  TCP_TABLE_BASIC_CONNECTIONS        = 1;
  TCP_TABLE_BASIC_ALL                = 2;
  TCP_TABLE_OWNER_PID_LISTENER       = 3;
  TCP_TABLE_OWNER_PID_CONNECTIONS    = 4;
  TCP_TABLE_OWNER_PID_ALL            = 5;
  TCP_TABLE_OWNER_MODULE_LISTENER    = 6;
  TCP_TABLE_OWNER_MODULE_CONNECTIONS = 7;
  TCP_TABLE_OWNER_MODULE_ALL         = 8;

  UDP_TABLE_OWNER_PID_ALL            = 1;

  MIB_TCP_STATE_UNKNOWN    = 0;
  MIB_TCP_STATE_CLOSED     = 1;
  MIB_TCP_STATE_LISTEN     = 2;
  MIB_TCP_STATE_SYN_SENT   = 3;
  MIB_TCP_STATE_SYN_RCVD   = 4;
  MIB_TCP_STATE_ESTAB      = 5;
  MIB_TCP_STATE_FIN_WAIT1  = 6;
  MIB_TCP_STATE_FIN_WAIT2  = 7;
  MIB_TCP_STATE_CLOSE_WAIT = 8;
  MIB_TCP_STATE_CLOSING    = 9;
  MIB_TCP_STATE_LAST_ACK   = 10;
  MIB_TCP_STATE_TIME_WAIT  = 11;
  MIB_TCP_STATE_DELETE_TCB = 12;

  UDP_TABLE_OWNER_PID = 5;

type
  TCP_TABLE_CLASS = Integer;

  PMibTcpRowOwnerPid = ^TMibTcpRowOwnerPid;
  TMibTcpRowOwnerPid  = record
    dwState     : DWORD;
    dwLocalAddr : DWORD;
    dwLocalPort : DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid : DWORD;
  end;

  PMIB_TCPTABLE_OWNER_PID  = ^MIB_TCPTABLE_OWNER_PID;
  MIB_TCPTABLE_OWNER_PID = record
   dwNumEntries: DWORD;
   Table: array [0..ANY_SIZE - 1] of TMibTcpRowOwnerPid;
  end;

  PMIB_TCP6ROW_OWNER_PID = ^MIB_TCP6ROW_OWNER_PID;
  MIB_TCP6ROW_OWNER_PID = record
    dwLocalAddr     : IN6_ADDR    ;
    dwLocalScopeId  : DWORD       ;
    dwLocalPort     : DWORD       ;
    dwRemoteAddr    : IN6_ADDR    ;
    dwRemoteScopeId : DWORD       ;
    dwRemotePort    : DWORD       ;
    dwState         : DWORD       ;
    dwOwningPid     : DWORD       ;
  end;

  PMIB_TCP6TABLE_OWNER_PID = ^MIB_TCP6TABLE_OWNER_PID;
  MIB_TCP6TABLE_OWNER_PID = packed record
    dwNumEntries : DWORD;
    Table: array[0..ANY_SIZE - 1] of MIB_TCP6ROW_OWNER_PID;
  end;

  UDP_TABLE_CLASS = Integer;

  PMIB_UDPROW_OWNER_PID = ^MIB_UDPROW_OWNER_PID;
  MIB_UDPROW_OWNER_PID  = record//packed record
    dwLocalAddr : DWORD;
    dwLocalPort : DWORD;
    dwOwningPid : DWORD;
  end;

  PMIB_UDP6ROW_OWNER_PID = ^MIB_UDP6ROW_OWNER_PID;
  MIB_UDP6ROW_OWNER_PID = record
    dwLocalAddr     : IN6_ADDR    ;
    dwLocalScopeId  : DWORD       ;
    dwLocalPort     : DWORD       ;
    dwOwningPid     : DWORD       ;
  end;

  PMIB_UDPTABLE_OWNER_PID = ^MIB_UDPTABLE_OWNER_PID;
  MIB_UDPTABLE_OWNER_PID = record// packed record
    dwNumEntries: DWORD;
    Table: array[0..ANY_SIZE - 1] of MIB_UDPROW_OWNER_PID;
  end;

  PMIB_UDP6TABLE_OWNER_PID = ^MIB_UDP6TABLE_OWNER_PID;
  MIB_UDP6TABLE_OWNER_PID = record
    dwNumEntries: DWORD;
    Table: array[0..ANY_SIZE - 1] of MIB_UDP6ROW_OWNER_PID;
  end;

function GetExtendedTcpTable(pTcpTable: PMIB_TCPTABLE_OWNER_PID; dwSize: PDWORD; bOrder: BOOL;
  lAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWord; stdcall;

function GetExtendedUdpTable(pUdpTable: PMIB_UDPTABLE_OWNER_PID; dwSize: PDWORD; bOrder: BOOL;
  uAlf: ULONG; TableClass: UDP_TABLE_CLASS; Reserved: ULONG): DWORD; stdcall;

//function RtlIpv4AddressToString(const Addr: PInAddr; S: PChar): PChar; stdcall;
//  external 'ntdll.dll' name {$IFDEF UNICODE}'RtlIpv4AddressToStringW'{$ELSE}'RtlIpv4AddressToStringA'{$ENDIF};
function RtlIpv6AddressToString(const Addr: PIn6Addr; S: PChar): PChar; stdcall;
  external 'ntdll.dll' name {$IFDEF UNICODE}'RtlIpv6AddressToStringW'{$ELSE}'RtlIpv6AddressToStringA'{$ENDIF} delayed;

implementation
const
  iphlpapilib = 'iphlpapi.dll';

function GetExtendedTcpTable; external iphlpapilib name 'GetExtendedTcpTable' delayed;

function GetExtendedUdpTable; external iphlpapilib name 'GetExtendedUdpTable' delayed;

end.
