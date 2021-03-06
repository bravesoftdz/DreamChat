object FormManage: TFormManage
  Left = 196
  Top = 106
  Caption = 'Plugins manager 5 (API ver 4)'
  ClientHeight = 428
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 32
    Height = 13
    Caption = 'FileList'
  end
  object Label2: TLabel
    Left = 200
    Top = 8
    Width = 115
    Height = 13
    Caption = 'Loaded NativePluginList'
  end
  object Label3: TLabel
    Left = 392
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Loaded Plugins'
  end
  object ButtonLoadPlugin: TButton
    Left = 240
    Top = 400
    Width = 145
    Height = 25
    Caption = 'Load plugin'
    TabOrder = 0
    OnClick = ButtonLoadPluginClick
  end
  object ButtonUnloadPlugin: TButton
    Left = 392
    Top = 400
    Width = 137
    Height = 25
    Caption = 'Unload plugin'
    TabOrder = 1
    OnClick = ButtonUnloadPluginClick
  end
  object ListBox2: TListBox
    Left = 392
    Top = 32
    Width = 137
    Height = 161
    ItemHeight = 13
    TabOrder = 2
    OnClick = ListBox2Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 200
    Width = 377
    Height = 193
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
  object Memo2: TMemo
    Left = 392
    Top = 200
    Width = 137
    Height = 193
    Lines.Strings = (
      'Memo2')
    TabOrder = 4
  end
  object CheckListBox1: TCheckListBox
    Left = 200
    Top = 32
    Width = 185
    Height = 161
    OnClickCheck = CheckListBox1ClickCheck
    ItemHeight = 13
    PopupMenu = VTHeaderPopupMenu1
    TabOrder = 5
    OnClick = CheckListBox1Click
    OnDblClick = CheckListBox1DblClick
    OnMouseDown = CheckListBox1MouseDown
  end
  object ListBox1: TListBox
    Left = 8
    Top = 32
    Width = 185
    Height = 161
    ItemHeight = 13
    PopupMenu = VTHeaderPopupMenu1
    TabOrder = 6
    OnMouseDown = ListBox1MouseDown
  end
  object VTHeaderPopupMenu1: TVTHeaderPopupMenu
    Left = 32
    Top = 48
  end
end
