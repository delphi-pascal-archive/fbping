object frmMaitre: TfrmMaitre
  Left = 227
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'fbPing'
  ClientHeight = 529
  ClientWidth = 977
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 17
  object Label1: TLabel
    Left = 10
    Top = 112
    Width = 89
    Height = 16
    Caption = 'Liste a pinger : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 10
    Top = 51
    Width = 81
    Height = 16
    Caption = 'Timeout (ms):'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 10
    Top = 78
    Width = 72
    Height = 16
    Caption = 'Packet size:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object cmdPinger: TButton
    Left = 8
    Top = 8
    Width = 201
    Height = 25
    Caption = 'Pinger'
    TabOrder = 0
    OnClick = cmdPingerClick
  end
  object memApinger: TMemo
    Left = 8
    Top = 136
    Width = 201
    Height = 385
    Lines.Strings = (
      'delphisources.ru'
      'yandex.ru'
      'google.com'
      'mail.ru'
      'rambler.ru'
      'nigma.ru'
      'bing.com'
      'yahoo.com'
      'www.msn.com'
      'ask.com'
      'vk.com'
      'facebook.com'
      'ok.ru'
      'hh.ru'
      'habrahabr.ru'
      'aliexpress.com'
      'fl.ru'
      'freelancim.ru'
      'weblancer.net'
      'https://www.sberbank.ru/'
      'www.gazprombank.ru'
      'alfabank.ru'
      'https://www.vtb24.ru/')
    TabOrder = 1
    WordWrap = False
  end
  object ProgressBar1: TProgressBar
    Left = 216
    Top = 8
    Width = 753
    Height = 25
    TabOrder = 2
  end
  object edtTimeOut: TEdit
    Left = 104
    Top = 40
    Width = 105
    Height = 25
    TabOrder = 3
    Text = '1000'
  end
  object edtTaillePaquet: TEdit
    Left = 104
    Top = 72
    Width = 105
    Height = 25
    TabOrder = 4
    Text = '32'
  end
  object ListView1: TListView
    Left = 216
    Top = 40
    Width = 753
    Height = 481
    Columns = <
      item
        Caption = 'Host'
        Width = 200
      end
      item
        Alignment = taCenter
        Caption = 'Status'
        Width = 60
      end
      item
        Alignment = taCenter
        Caption = 'DNS'
        Width = 200
      end
      item
        Alignment = taCenter
        Caption = 'IP'
        Width = 120
      end
      item
        Alignment = taRightJustify
        Caption = 'Time response (ms)'
        Width = 140
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 5
    ViewStyle = vsReport
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'fichier csv|*.csv'
    Left = 112
    Top = 8
  end
end
