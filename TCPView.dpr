program TCPView;

uses
  Vcl.Forms,
  TCPView.Main in 'TCPView.Main.pas' {frmTCPView},
  TCPView.IPHelper in 'TCPView.IPHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTCPView, frmTCPView);
  Application.Run;
end.
