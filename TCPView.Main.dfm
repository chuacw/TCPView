object frmTCPView: TfrmTCPView
  Left = 0
  Top = 0
  Caption = 'TCPView'
  ClientHeight = 590
  ClientWidth = 964
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object VST: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 964
    Height = 564
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoHeaderClickAutoSort]
    TabOrder = 0
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = [toSaveCaptions, toShowStaticText, toAutoAcceptEditChange]
    OnCompareNodes = VSTCompareNodes
    OnGetText = VSTGetText
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 0
        Width = 118
        WideText = 'Process'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 1
        Width = 58
        WideText = 'PID'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 2
        Width = 66
        WideText = 'Protocol'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 3
        Width = 90
        WideText = 'Local Address'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 4
        Width = 71
        WideText = 'Local Port'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 5
        Width = 98
        WideText = 'Remote Address'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 6
        Width = 81
        WideText = 'Remote Port'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 7
        Width = 89
        WideText = 'State'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 8
        Width = 80
        WideText = 'Sent Packets'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 9
        Width = 74
        WideText = 'Sent Bytes'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 10
        Width = 94
        WideText = 'Rcvd Packets'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 11
        Width = 75
        WideText = 'Rcvd Bytes'
      end>
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 564
    Width = 964
    Height = 26
    Panels = <
      item
        Text = 'Endpoints: 0'
        Width = 90
      end
      item
        Text = 'Established: 0'
        Width = 90
      end
      item
        Text = 'Listening: 0'
        Width = 90
      end
      item
        Text = 'Time Wait: 0'
        Width = 90
      end
      item
        Text = 'Close Wait: 0'
        Width = 90
      end>
  end
  object ActionList1: TActionList
    Left = 152
    Top = 64
    object acApp: TAction
      Caption = 'App'
    end
    object acAppExit: TAction
      Caption = 'Exit'
      OnExecute = acAppExitExecute
    end
    object acRefresh: TAction
      Caption = 'Refresh'
      OnExecute = acRefreshExecute
    end
    object acView: TAction
      Caption = 'View'
    end
    object acRefresh1Sec: TAction
      Caption = '1 second'
      OnExecute = acRefresh1SecExecute
    end
    object acRefresh2Secs: TAction
      Caption = '2 seconds'
      OnExecute = acRefresh2SecsExecute
    end
    object acRefresh5Secs: TAction
      Caption = '5 seconds'
      OnExecute = acRefresh5SecsExecute
    end
    object acRefreshPaused: TAction
      Caption = 'Paused'
      OnExecute = acRefreshPausedExecute
    end
  end
  object MainMenu1: TMainMenu
    Left = 48
    Top = 64
    object App1: TMenuItem
      Caption = 'App'
      object Exit1: TMenuItem
        Action = acAppExit
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object Refresh1: TMenuItem
        Caption = 'Update Speed'
        OnClick = acRefreshExecute
        object N1second1: TMenuItem
          Action = acRefresh1Sec
        end
        object N2seconds1: TMenuItem
          Action = acRefresh2Secs
        end
        object N5seconds1: TMenuItem
          Action = acRefresh5Secs
        end
        object Paused1: TMenuItem
          Action = acRefreshPaused
        end
      end
    end
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 368
    Top = 72
  end
end
