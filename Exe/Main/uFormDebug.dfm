object FormDebug: TFormDebug
  Left = 204
  Top = 70
  AutoScroll = False
  Caption = 'FormDebug'
  ClientHeight = 359
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TsSplitter
    Left = 0
    Top = 35
    Width = 640
    Height = 17
    Cursor = crVSplit
    Align = alBottom
    SkinData.SkinSection = 'SPLITTER'
  end
  object DebugMemo1: TsMemo
    Left = 0
    Top = 0
    Width = 640
    Height = 35
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    OnMouseDown = DebugMemo1MouseDown
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -16
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
  end
  object DebugMemo2: TsMemo
    Left = 0
    Top = 52
    Width = 640
    Height = 307
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
    OnMouseDown = DebugMemo2MouseDown
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -16
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
  end
  object sSkinProvider1: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 8
    Top = 40
  end
end
