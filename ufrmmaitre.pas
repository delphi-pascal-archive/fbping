unit ufrmmaitre;

// |===========================================================================|
// | UNITE ufrmmaitre                                                          |
// | F.BASSO 2016                                                              |
// |___________________________________________________________________________|
// | unite g�rant la fen�tre principale de fbping                               |
// |___________________________________________________________________________|
// | Ce programme est libre, vous pouvez le redistribuer et ou le modifier     |
// | selon les termes de la Licence Publique G�n�rale GNU publi�e par la       |
// | Free Software Foundation .                                                |
// | Ce programme est distribu� car potentiellement utile,                     |
// | mais SANS AUCUNE GARANTIE, ni explicite ni implicite,                     |
// | y compris les garanties de commercialisation ou d'adaptation              |
// | dans un but sp�cifique.                                                   |
// | Reportez-vous � la Licence Publique G�n�rale GNU pour plus de d�tails.    |
// |                                                                           |
// | anbasso@wanadoo.fr                                                        |
// |___________________________________________________________________________|
// | Versions                                                                  |
// |  _________                                                                |
// | /  1.0.0  \______________________________________________________________ |
// || 2016/11/11 F.BASSO                                                      ||
// || Cr�ation de l'unit�                                                     ||
// ||_________________________________________________________________________||
// |===========================================================================|

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Dialogs, StdCtrls, ComCtrls, Controls, Forms;

type
  TfrmMaitre = class(TForm)
    cmdPinger: TButton;
    memApinger: TMemo;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    edtTimeOut: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtTaillePaquet: TEdit;
    ListView1: TListView;
    procedure cmdPingerClick(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  frmMaitre: TfrmMaitre;

implementation

{$R *.dfm}
uses
  ufbping,
  winsock{, ufbfonctionsdiv};

function IPAddrToName(IPAddr: string): string;

//  ___________________________________________________________________________
// | function IPAddrToName                                                     |
// | _________________________________________________________________________ |
// || Permet de resoudre l'adresse ip en nom d'h�tes                          ||
// ||_________________________________________________________________________||
// || Entr�es | IPAddr: string                                                ||
// ||         |   adresse ip a� r�soudre                                      ||
// ||_________|_______________________________________________________________||
// || Sorties | result : string                                               ||
// ||         |   nom d'h�te, vide si r�solusion nok                          ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  WSAStartup($101, WSAData);
  SockAddrIn.sin_addr.s_addr := inet_addr(PansiChar(AnsiString(IPAddr)));
  HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
  if HostEnt <> nil then
    Result := StrPas(Hostent^.h_name)
  else
    Result := '';
  WSACleanup;
end;

procedure TfrmMaitre.cmdPingerClick(Sender: TObject);

//  ___________________________________________________________________________
// | procedure TfrmMaitre.cmdPingerClick                                       |
// | _________________________________________________________________________ |
// || Permet de lancer le ping sur les host                                   ||
// ||_________________________________________________________________________||
// || Entr�es | Sender: TObject                                               ||
// ||         |   Objet g�n�rant l'�v�nement                                  ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  index: Integer;
  fbPing : tfbping;
  nitem: TListItem;
begin

// ****************************************************************************
// *  Cr�ation et param�trage de l'instance fbping                            *
// ****************************************************************************

  fbping := tfbping.Create;
  fbping.Timeout := strtoint(edtTimeOut.Text);
  fbping.Size    := strtoint(edtTaillePaquet.Text);

// ****************************************************************************
// *  Nettoyage du memo de resultat initialisation de la barre de progression *
// ****************************************************************************

  ListView1.Items.Clear;
  ProgressBar1.Position := 0 ;
  ProgressBar1.Max := memApinger.Lines.Count;

// ****************************************************************************
// *  Pour chaque host lance un ping                                          *
// ****************************************************************************

  for index := 0 to memApinger.Lines.Count-1 do
  begin
    fbping.Address := memApinger.Lines[index];

// ****************************************************************************
// *  pinf ok affichage des stat                                              *
// ****************************************************************************

    if fbping.Ping <> 0 then
    begin
      nitem:=ListView1.Items.Add;
      nitem.Caption:=memApinger.Lines[index];
      nitem.SubItems.Add('OK');
      nitem.SubItems.Add(IPAddrToName(fbPing.HostIP));
      nitem.SubItems.Add(fbPing.HostIP);
      nitem.SubItems.Add(IntToStr(fbPing.rtt));
    end
    else
// ****************************************************************************
// *  Ping ko affichage de l'erreur                                           *
// ****************************************************************************
    begin
      nitem:=ListView1.Items.Add;
      nitem.Caption:=memApinger.Lines[index];
      nitem.SubItems.Add('Error');
      nitem.SubItems.Add('-');
      nitem.SubItems.Add('-');
      nitem.SubItems.Add(fbPing.GetErrorString);
    end;

    ProgressBar1.Position := index+1;
    Application.ProcessMessages;
  end;

// ****************************************************************************
// *  Liberration de l'instance fbping                                        *
// ****************************************************************************

  fbping.Free;

// ****************************************************************************
// *  demande d'enregistrement du resultat dans un fichier CSV                *
// ****************************************************************************

  // if SaveDialog1.Execute then
    // memresultat.Lines.SaveToFile(SaveDialog1.FileName);
end;

end.
