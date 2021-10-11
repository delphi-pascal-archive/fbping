unit ufbPing;

// |===========================================================================|
// | UNITE ufbPing                                                             |
// | F.BASSO 2014                                                              |
// |___________________________________________________________________________|
// | Unit� contenant la classe fbPing permettant de faire du ping via icmp     |
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
// | /  2.0.0  \______________________________________________________________ |
// || 2016/11/11 F.BASSO                                                      ||
// || Ajout fonction trace route                                              ||
// || _________                                                               ||
// ||/  1.4.0  \______________________________________________________________||
// || 2016/09/24 F.BASSO                                                      ||
// || Adaptation du code pour Prise en charge du 64 bits                      ||
// || _________                                                               ||
// ||/  1.3.0  \______________________________________________________________||
// || 2016/08/15 F.BASSO                                                      ||
// || Prise en charge code de retour TIcmpEchoReply.Status  pour afiner le    ||
// || resultat                                                                ||
// || _________                                                               ||
// ||/  1.2.0  \______________________________________________________________||
// || 2014/07/30 F.BASSO                                                      ||
// || Cr�ation unit� pour Delphi XE3                                          ||
// || _________                                                               ||
// ||/  1.1.0  \______________________________________________________________||
// || 2007/08/13 F.BASSO                                                      ||
// || Cr�ation unit� pour Delphi 2005                                         ||
// || _________                                                               ||
// ||/  1.0.0  \______________________________________________________________||
// || 1997/01/06 Fran�ois PIETTE francois.piette@overbyte.be                  ||
// || Cr�ation original de l'unit�    http://www.overbyte.be                  ||
// ||_________________________________________________________________________||
// |===========================================================================|

interface

uses
  windows,
  SysUtils,
  Classes,
  WinSock,
  math;

const
  IcmpDLL = 'icmp.dll';                                      // Dll � utiliser pour win 2000 voir MSDN
  IphlpapiDLL = 'Iphlpapi.dll';                              // Dll � utiliser � partir de XP voir MSDN

  ICMP_SUCCESS                                = 0 ;          // Pas d'erreur
  ICMP_STATUS_BUFFER_TO_SMALL                 = 11001 ;      // Buffer trop petit
  ICMP_STATUS_DESTINATION_NET_UNREACH         = 11002 ;      // R�seau de destination non atteignable
  ICMP_STATUS_DESTINATION_HOST_UNREACH        = 11003 ;      // H�te destination non atteignable
  ICMP_STATUS_DESTINATION_PROTOCOL_UNREACH    = 11004 ;      // protocole de destination non atteignable
  ICMP_STATUS_DESTINATION_PORT_UNREACH        = 11005 ;      // port de destination non atteignable
  ICMP_STATUS_NO_RESOURCE                     = 11006 ;      // Pas de resources
  ICMP_STATUS_BAD_OPTION                      = 11007 ;      // Mauvaises options
  ICMP_STATUS_HARDWARE_ERROR                  = 11008 ;      // Erreur mat�riel
  ICMP_STATUS_LARGE_PACKET                    = 11009 ;      // Paquet trop grand
  ICMP_STATUS_REQUEST_TIMED_OUT               = 11010 ;      // Request timed out
  ICMP_STATUS_BAD_REQUEST                     = 11011 ;      // Mauvaise requ�te
  ICMP_STATUS_BAD_ROUTE                       = 11012 ;      // Mauvaise route
  ICMP_STATUS_TTL_EXPIRED_TRANSIT             = 11013 ;      // TTL � expir� pendant le trajet
  ICMP_STATUS_TTL_EXPIRED_REASSEMBLY          = 11014 ;      // TTL � expir� pendant le r�assemblage
  ICMP_STATUS_PARAMETER                       = 11015 ;      // Probl�me de param�trages
  ICMP_STATUS_SOURCE_QUENCH                   = 11016 ;      // Extinction de la source
  ICMP_STATUS_OPTION_TOO_BIG                  = 11017 ;      // Options trop grandes
  ICMP_STATUS_BAD_DESTINATION                 = 11018 ;      // Mauvaise destination
  ICMP_STATUS_ADDR_DELETED                    = 11019 ;      // Adresse supprim�e
  ICMP_STATUS_SPEC_MTU_CHANGE                 = 11020 ;      // Les specifications MTU ont chang�
  ICMP_STATUS_MTU_CHANGE                      = 11021 ;      // la taille maximale du paquet IP a chang�
  ICMP_STATUS_UNLOAD                          = 11022 ;      // d�chargement
  ICMP_STATUS_ADDRESS_ADDED                   = 11023 ;      // Adresse ajout�
  ICMP_STATUS_MEDIA_CONNECT                   = 11024 ;      // M�dia connect�
  ICMP_STATUS_MEDIA_DISCONNECT                = 11025 ;      // M�dia d�connect�
  ICMP_STATUS_BIND_ADAPTER                    = 11026 ;      // Adaptateur reli�
  ICMP_STATUS_UNBIND_ADAPTER                  = 11027 ;      // Adaptateur non reli�
  ICMP_STATUS_DEVICE_DOES_NOT_EXIST           = 11028 ;      // Mat�riel inexistant
  ICMP_STATUS_DUPLICATE_ADDRESS               = 11029 ;      // Doublon d'adresse
  ICMP_STATUS_INTERFACE_METRIC_CHANGE         = 11030 ;      // Distance de la route chang�e
  ICMP_STATUS_RECONFIG_SECFLTR                = 11031 ;      // ?????
  ICMP_STATUS_NEGOTIATING_IPSEC               = 11032 ;      // N�gociation de l'IPSEC (Internet Protocol Security)
  ICMP_STATUS_INTERFACE_WOL_CAPABILITY_CHANGE = 11033 ;      // Changement des capacit�s de Wake on Lan
  ICMP_STATUS_DUPLICATE_IPADD                 = 11034 ;      // Doublon d'adresse IP
  ICMP_STATUS_GENERAL_FAILURE                 = 11050 ;      // Erreur g�n�rale
  ICMP_STATUS_PENDING                         = 11255 ;      // Ping en cours

type

  TicmpIPAddress   = Longword;                             // Adresse IP format� comme un chiffre de 4 octets
  TicmpIPMask      = Longword;                             // Masque de sous reseau format� comme un chiffre de 4 octets
  TicmpIPStatus    = Longword;                             // Code renvoy� par les API.

  PIPOptionInformation = ^TIP_OPTION_INFORMATION;
  TIP_OPTION_INFORMATION = packed record
     TTL:         Byte;                                    // Time To Live (used for traceroute)
     TOS:         Byte;                                    // Type Of Service (usually 0)
     Flags:       Byte;                                    // IP header flags (usually 0)
     OptionsSize: Byte;                                    // Size of options data (usually 0, max 40)
     OptionsData: PansiChar;                               // Options data buffer
  end;

  PIcmpEchoReply = ^TICMP_ECHO_REPLY;

  TICMP_ECHO_REPLY = packed record
     Address:       TicmpIPAddress;                        // Replying address
     Status:        longWord;                              // IP status value
     RTT:           longWord;                              // Round Trip Time in milliseconds
     DataSize:      Word;                                  // Reply data size
     Reserved:      Word;                                  // Reserved
     Data:          Pointer;                               // Pointer to reply data buffer
     Options:       TIP_OPTION_INFORMATION;                // Reply options
  end;

//  ___________________________________________________________________________
// | Type TIcmpCreateFile = function                                           |
// | _________________________________________________________________________ |
// || squelette de l'API IcmpCreateFile                                       ||
// || cr�e un handle sur lequel des requ�tes ICMP peuvent �tre adress�es      ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties | result : Thandler                                             ||
// ||         |   Handler ouvert ou INVALID_HANDLE_VALUE en cas d'erreur voir ||
// ||         |   Getlasterror pour avoir des informations d'�taill�es        ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|
  TIcmpCreateFile = function: THandle; stdcall;

//  ___________________________________________________________________________
// | Type TIcmpCloseHandle = function                                          |
// | _________________________________________________________________________ |
// || squelette de l'API IcmpCloseHandle                                      ||
// || Ferme le handle ouvert par TicmpCreateFile                              ||
// ||_________________________________________________________________________||
// || Entr�es | IcmpHandle : THandle                                          ||
// ||         |   Handler � fermer                                            ||
// ||_________|_______________________________________________________________||
// || Sorties | result : Boolean                                              ||
// ||         |   True si andler bien ferm� ou False en cas d'erreur voir     ||
// ||         |   Getlasterror pour avoir des informations d'�taill�es        ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|
  TIcmpCloseHandle = function(IcmpHandle: THandle): Boolean; stdcall;

//  ___________________________________________________________________________
// | Type TIcmpSendEcho = function                                             |
// | _________________________________________________________________________ |
// || squelette de l'API IcmpSendEcho                                         ||
// || Envoie une requ�te Echo et renvoie une ou plusieurs reponses            ||
// ||_________________________________________________________________________||
// || Entr�es | IcmpHandle : THandle                                          ||
// ||         |   Handler ouvert par TicmpCreateFile                          ||
// ||         | DestinationAddress : TicmpIPAddress                           ||
// ||         |   Adresse de destination des requ�tes echo                    ||
// ||         | RequestData : Pointer                                         ||
// ||         |   Pointeur sur un tampon contenant les donn�es envoy�es par   ||
// ||         |   la requ�te                                                  ||
// ||         | RequestSize : Word                                            ||
// ||         |   Taille du tampon point� par RequestData                     ||
// ||         | RequestOptions : PIPOptionInformation                         ||
// ||         |   Pointeur vers les options d'ent�te IP, doit �tre nul        ||
// ||         | ReplyBuffer : Pointer                                         ||
// ||         |   Pointeur sur le tampon de receptions des r�ponses, le tampon||
// ||         |   doit pouvoir contenir au minimun un ICMP_ECHO_REPLY et 8    ||
// ||         |   octet, taille d'un message d'erreur                         ||
// ||         | ReplySize : DWord                                             ||
// ||         |   Taille du tampon point� par ReplyBuffer                     ||
// ||         | Timeout : DWord                                               ||
// ||         |   Temps en milli secondes d'attente de r�ponses               ||
// ||_________|_______________________________________________________________||
// || Sorties | result : DWord                                                ||
// ||         |   Nombre de r�ponses obtenu, 0 en cas d'erreur voir           ||
// ||         |   Getlasterror pour avoir des informations d'�taill�es        ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|
  TIcmpSendEcho = function(IcmpHandle: THandle ;
                           DestinationAddress : TicmpIPAddress ;
                           RequestData : Pointer ;
                           RequestSize : Word ;
                           RequestOptions : PIPOptionInformation ;
                           ReplyBuffer : Pointer ;
                           ReplySize : longWord ;
                           Timeout : longWord ): longWord ; stdcall ;

//  ___________________________________________________________________________
// | Type TIcmpReply   = procedure                                             |
// | _________________________________________________________________________ |
// || squelette de la procedure � utiliser lors d'une r�ponse                 ||
// ||_________________________________________________________________________||
// || Entr�es | Sender: TObject                                               ||
// ||         |   objet appelent la proc�dure                                 ||
// ||         | Error : Integer                                               ||
// ||         |   Eventuel num�ro d'erreur suite au ping                      ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

  TIcmpReply = procedure(Sender: TObject; Error : Integer) of object;

// #############################################################################
// #############################################################################
// ##                                                                         ##
// ##  TFBPING                                                                ##
// ##                                                                         ##
// #############################################################################
// #############################################################################

  TfbPing = class(TObject)
  private

// ****************************************************************************
// * D�clarations priv�es                                                     *
// ****************************************************************************

    hDll : HModule;                                // Handle sur la DLL
    IcmpCreateFile : TIcmpCreateFile;              // Lien sur la fonction IcmpCreateFile
    IcmpCloseHandle : TIcmpCloseHandle;            // Lien sur la fonction IcmpCloseHandle
    IcmpSendEcho : TIcmpSendEcho;                  // Lien sur la fonction IcmpSendEcho
    hICMP : THandle;                               // Handle de ping
    FIcmpEchoReply : TICMP_ECHO_REPLY;             // Tampon pour recevoir les r�ponses Echo
    FIPOptionInformation : TIP_OPTION_INFORMATION; // Tampon contenant les option de ping
    FstrAddress : String;                          // Addresse IP fournie
    FstrHostName : String;                         // Nom d'h�te r�solut
    FstrHostIP : String;                           // Adresse IP de l'h�te r�solut sous forme WWW.XXX.YYY.ZZZ
    FicmpIPAddress : TicmpIPAddress;               // Address IP de l'h�te
    FdwSize : Longword ;                           // taille des paquets (initialis� � 56)
    FdwTimeOut : Longword ;                        // Timeout (initialis� � 4000mS)
    FdwTTL : Longword;                             // Time To Live
    FFlags : Integer;                              // Options flags
    FOnEchoRequest : TNotifyEvent;                 // Adresse de la fonction � appeller sur onEchoRequest
    FOnEchoReply : TICMPReply;                     // Adresse de la fonction � appeller sur onEchoReply
    FdwLastError : longword;                       // Derniere erreur
    FbooAddressResolved : Boolean;                 // L'adresse de l'h�te a bien �t� r�solut
    fdwLastRTT : Longword;                         // Temps de reponse du dernier ping
    fdwTotalRTT : longword;                        // Somme des temps de r�ponses
    fdwNbRepply : longword;                        // Nombres de r�ponses positives
    ffltRTT : Real ;                               // Temps de r�ponse moyen
    FDataBuf: Array of Byte;                       // Tampon d'envoie
    FReplyBuf: Array of Byte;                      // tempon de reception
    FReplyBufSize : Longword;                      // Taille du tampon de reception
    FintNBSaut : integer;                          // nombre de saut pour le trace route
    FstrAddressReply : string;                     // Adresse de reponce
    procedure ResolveAddress;
    procedure SetSize (intTaille : longword);
    function  envoyerEcho : integer;
  public

// ****************************************************************************
// * D�clarations publiques                                                   *
// ****************************************************************************

    constructor Create; virtual;
    destructor  Destroy; override;
    function    Ping : Integer;
    procedure   trace;
    procedure   SetAddress(strAddress : String);
    function    GetErrorString : String;

    property Address : String             read  FstrAddress    write SetAddress;
    property Size : longword              read  FdwSize        write SetSize;
    property Timeout : longword           read  FdwTimeout     write FdwTimeout;
    property Reply : TICMP_ECHO_REPLY     read  FIcmpEchoReply;
    property TTL : longword               read  FdwTTL         write FdwTTL;
    Property Flags : Integer              read  FFlags         write FFlags;
    Property intNBSaut : integer          read  FintNBSaut     write FintNBSaut;
    property strAddressReply : string     read  FstrAddressReply;
    property ErrorCode : longWord         read  FdwLastError;
    property ErrorString : String         read  GetErrorString;
    property HostName : String            read  FstrHostName;
    property HostIP : String              read  FstrHostIP;
    property RTT : longword               read  fdwLastRTT ;
    property averageRTT : real            read  ffltRTT ;
    property dwLastError : longword       read  FdwLastError;
    property OnEchoRequest : TNotifyEvent read  FOnEchoRequest write FOnEchoRequest;
    property OnEchoReply : TICMPReply     read  FOnEchoReply   write FOnEchoReply;
  end;

  TICMPException = class(Exception);

implementation

// #===========================================================================#
// #===========================================================================#
// #                                                                           #
// # Partie Priv�e                                                             #
// #                                                                           #
// #===========================================================================#
// #===========================================================================#

procedure TfbPing.ResolveAddress;

//  ___________________________________________________________________________
// | procedure TfbPing.ResolveAddress                                          |
// | _________________________________________________________________________ |
// || Permet de resoudre l'adresse fourni en adresse IP valide                ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  HostEnt : PHostEnt;
begin

  fdwTotalRTT := 0;
  fdwNbRepply := 0;

// ****************************************************************************
// * C'est une adresse ip                                                     *
// ****************************************************************************

  FicmpIPAddress := inet_addr(PAnsiChar (AnsiString (FstrAddress)));
  if FicmpIPAddress <> Longword(INADDR_NONE) then
    FstrHostName := FstrAddress
  else
  begin

// ****************************************************************************
// * Convertion du hostname en adresse IP                                     *
// ****************************************************************************

    HostEnt := GetHostByName(PAnsiChar (AnsiString (FstrAddress)));
    if HostEnt = nil then
    begin
      FdwLastError := GetLastError;
      Exit;
    end;
    FicmpIPAddress := longint(plongint(HostEnt^.h_addr_list^)^);
    FstrHostName := HostEnt^.h_name;
  end;
  FstrHostIP := StrPas(inet_ntoa(TInAddr(FicmpIPAddress)));
  FbooAddressResolved := TRUE;
end;

// #===========================================================================#
// #===========================================================================#
// #                                                                           #
// # Partie Publique                                                           #
// #                                                                           #
// #===========================================================================#
// #===========================================================================#

constructor TfbPing.Create;

//  ___________________________________________________________________________
// | constructor TfbPing.Create                                                |
// | _________________________________________________________________________ |
// || Constructeur de la class TICMP permet d'initialiser certaine variable et||
// || charger la DLL IPHLPAPI.DLL ou ICMP.DLL en fonction de la disponibilit� ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  WSAData: TWSAData;
begin
  hICMP      := INVALID_HANDLE_VALUE;
  FdwTTL     := 64;
  FdwTimeOut := 4000;
  FintNBSaut := 30;
  SetSize(56);

  if WSAStartup($101, WSAData) <> 0 then
      raise TICMPException.Create('Erreur lors de l''initialisation de Winsock');

// ****************************************************************************
// * Tentative de cr�ation de la liaison dynamique avec IPHLPAPI.DLL puis avec*
// * ICMP.DLL en cas d'�chec                                                  *
// ****************************************************************************

  hdll := LoadLibrary(IphlpapiDLL);
    if hdll = 0 then
    hdll := LoadLibrary(IcmpDLL );
    if hDll = 0 then
      raise TICMPException.Create('Impossible de trouver ' + icmpDLL + ' ou ' + IphlpapiDLL );

// ****************************************************************************
// * Chargement des fonctions                                                 *
// ****************************************************************************

  @ICMPCreateFile  := GetProcAddress(hdll, 'IcmpCreateFile');
  @IcmpCloseHandle := GetProcAddress(hdll, 'IcmpCloseHandle');
  @IcmpSendEcho    := GetProcAddress(hdll, 'IcmpSendEcho');
  if (@ICMPCreateFile = Nil) or (@IcmpCloseHandle = Nil) or (@IcmpSendEcho = Nil) then
    raise TICMPException.Create('Erreur lors du chargement des fonctions API');

// ****************************************************************************
// * Cr�ation du handler de ping                                              *
// ****************************************************************************

  hICMP := IcmpCreateFile;
  if hICMP = INVALID_HANDLE_VALUE then
    raise TICMPException.Create('Impossible d''avoir le handle de Ping');
end;

destructor TfbPing.Destroy;

//  ___________________________________________________________________________
// | destructor TfbPing.Destroy                                                |
// | _________________________________________________________________________ |
// || Destructeur de la class TICMP pemet de lib�rrer les different handler   ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

begin
  if hICMP <> INVALID_HANDLE_VALUE then IcmpCloseHandle(hICMP);
  if hdll <> 0 then FreeLibrary(hdll);
  WSACleanup;
  inherited Destroy;
end;

function TfbPing.envoyerEcho: integer;

//  ___________________________________________________________________________
// | function TfbPing.envoyerEcho                                              |
// | _________________________________________________________________________ |
// || Permet d'envoyer un ping                                                ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties | result : integer                                              ||
// ||         |   nombre de reply 0 si KO                                     ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

begin
  if Assigned(FOnEchoRequest) then FOnEchoRequest(Self);
  result := IcmpSendEcho(hICMP, FicmpIPAddress,@FDataBuf[0] ,FdwSize, @fIPOptionInformation, @FReplyBuf[0], FReplyBufSize, FdwTimeOut);

// ****************************************************************************
// * copie les informations depuis le tempon de reponce                       *
// ****************************************************************************

  Move(FReplyBuf[0], fIcmpEchoReply, SizeOf (fIcmpEchoReply));
  FdwLastError := fIcmpEchoReply.Status;

// ****************************************************************************
// *  Calcule des resultats de reponse                                        *
// ****************************************************************************

  if (result <> 0)or(fIcmpEchoReply.Status=ICMP_STATUS_REQUEST_TIMED_OUT) then
  begin
    if (fIcmpEchoReply.Status <> ICMP_STATUS_TTL_EXPIRED_TRANSIT)and(fIcmpEchoReply.Status<>ICMP_SUCCESS) then
    begin
      fdwLastRTT := cardinal(-1);
      FstrAddressReply := geterrorstring;
    end else
    begin
      fdwNbRepply := fdwNbRepply + 1;
      fdwLastRTT := fIcmpEchoReply.RTT;
      fdwTotalRTT := fdwTotalRTT + fdwLastRTT;
      ffltRTT := fdwTotalRTT / fdwNbRepply ;
      FstrAddressReply := StrPas(inet_ntoa(TInAddr(fIcmpEchoReply.Address)));
    end;
  end else
  begin
    fdwLastRTT := cardinal(-1);
    FstrAddressReply := geterrorstring;
  end;
  if Assigned(FOnEchoReply) then FOnEchoReply(Self, FdwLastError);
end;

procedure TfbPing.SetAddress(strAddress : String);

//  ___________________________________________________________________________
// | procedure TfbPing.SetAddress(strAddress : String)                         |
// | _________________________________________________________________________ |
// || Permet de d�finir l'adresse IP                                          ||
// ||_________________________________________________________________________||
// || Entr�es | strAddress : String                                           ||
// ||         |   adresse ip ou nom d'h�te � pinguer                          ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

begin
  if FstrAddress = strAddress then Exit;
  FstrAddress := strAddress;
  FbooAddressResolved := FALSE;
end;


procedure TfbPing.SetSize(intTaille: longword);

//  ___________________________________________________________________________
// | procedure TfbPing.SetSize                                                 |
// | _________________________________________________________________________ |
// || Permet de definir la taille du tampon d'envoie                          ||
// ||_________________________________________________________________________||
// || Entr�es | intTaille: longword                                           ||
// ||         |   nouvelle taille                                             ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  S: AnsiString;
  tailleMSG : longword;
begin
  if intTaille= FdwSize then exit;
  FdwSize := inttaille;
  if FdwSize< 32 then FdwSize := 32;
  s := 'Ping en cours ...';
  tailleMSG := length(s);
  FReplyBufSize := sizeof(fIcmpEchoReply) + FdwSize + 8;
  if Length (FDataBuf) < FdwSize then SetLength (FDataBuf, FdwSize);
  if Length (FReplyBuf) < FReplyBufSize then SetLength (FReplyBuf, FReplyBufSize);
  FillChar(FDataBuf[0], FdwSize, $20);
  FillChar(FReplyBuf[0], FReplyBufSize, 0);
  Move(S, FDataBuf[0],ifthen(FdwSize>=tailleMSG , tailleMSG ,FdwSize));
  FillChar(fIcmpEchoReply, SizeOf(fIcmpEchoReply), 0);
  FillChar(fIPOptionInformation, SizeOf(fIPOptionInformation), 0);
end;

procedure TfbPing.trace;

//  ___________________________________________________________________________
// | procedure TfbPing.trace                                                   |
// | _________________________________________________________________________ |
// || Permet de lancer un trace route                                         ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

var
  intRes : integer;
  intNbsaut : integer;
begin
  FdwLastError := 0;
  if not FbooAddressResolved then ResolveAddress;
  if FicmpIPAddress = Longword(INADDR_NONE) then
  begin
    FdwLastError := ICMP_STATUS_BAD_DESTINATION ;
    Exit;
  end;

// ****************************************************************************
// * R�servation m�moire pour les tampons                                     *
// ****************************************************************************

  setsize (32);
  for intNbsaut := 1 to FintNBSaut do
  begin
    fIPOptionInformation.TTL := intNbsaut;
    intRes := envoyerEcho ;
    if(fIcmpEchoReply.Status<>ICMP_STATUS_REQUEST_TIMED_OUT ) and
      (fIcmpEchoReply.Status<>ICMP_STATUS_TTL_EXPIRED_TRANSIT) or
      (FstrAddressReply = FstrHostIP) then break ;
    if intNbsaut < FintNBSaut then sleep(1000);
  end;
end;

function TfbPing.GetErrorString : String;

//  ___________________________________________________________________________
// | function TfbPing.GetErrorString : String                                  |
// | _________________________________________________________________________ |
// || Permet de r�ccuperer le d�tail de la derniere erreur lors de l'execution||
// || du ping                                                                 ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties | result : string                                               ||
// ||         |   d�tail de l'erreur                                          ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

begin
  case FdwLastError of
    ICMP_SUCCESS                             : Result := 'No error';
    ICMP_STATUS_BUFFER_TO_SMALL              : Result := 'Buffer trop petit';
    ICMP_STATUS_DESTINATION_NET_UNREACH      : Result := 'R�seau de destination non atteignable';
    ICMP_STATUS_DESTINATION_HOST_UNREACH     : Result := 'H�te destination non atteignable';
    ICMP_STATUS_DESTINATION_PROTOCOL_UNREACH : Result := 'protocole de destination non atteignable';
    ICMP_STATUS_DESTINATION_PORT_UNREACH     : Result := 'port de destination non atteignable';
    ICMP_STATUS_NO_RESOURCE                  : Result := 'Pas de resources';
    ICMP_STATUS_BAD_OPTION                   : Result := 'Mauvaises options';
    ICMP_STATUS_HARDWARE_ERROR               : Result := 'Erreur mat�riel';
    ICMP_STATUS_LARGE_PACKET                 : Result := 'Paquet trop grand';
    ICMP_STATUS_REQUEST_TIMED_OUT            : Result := 'Request timed out';
    ICMP_STATUS_BAD_REQUEST                  : Result := 'Mauvaise requ�te';
    ICMP_STATUS_BAD_ROUTE                    : Result := 'Mauvaise route';
    ICMP_STATUS_TTL_EXPIRED_TRANSIT          : Result := 'TTL � expir� pendant le trajet';
    ICMP_STATUS_TTL_EXPIRED_REASSEMBLY       : Result := 'TTL � expir� pendant le r�assemblage';
    ICMP_STATUS_PARAMETER                    : Result := 'Probl�me de param�trages';
    ICMP_STATUS_SOURCE_QUENCH                : Result := 'Extinction de la source';
    ICMP_STATUS_OPTION_TOO_BIG               : Result := 'Options trop grandes';
    ICMP_STATUS_BAD_DESTINATION              : Result := 'Mauvaise destination';
    ICMP_STATUS_ADDR_DELETED                 : Result := 'Adresse supprim�e';
    ICMP_STATUS_SPEC_MTU_CHANGE              : Result := 'Les specifications MTU ont chang�'; // (MTU Maximum Transmission Unit,taille maximale d'un paquet IP)
    ICMP_STATUS_MTU_CHANGE                   : Result := 'la taille maximale du paquet IP a chang�';
    ICMP_STATUS_GENERAL_FAILURE              : Result := 'Erreur g�n�rale';
    ICMP_STATUS_PENDING                      : Result := 'Ping en cours';
    else
      Result := 'ICMP error #' + IntToStr(FdwLastError);
  end;
end;

function TfbPing.Ping : Integer;

//  ___________________________________________________________________________
// | function TfbPing.Ping : Integer                                           |
// | _________________________________________________________________________ |
// || Permet d'executer un ping sur une adresse de destination                ||
// ||_________________________________________________________________________||
// || Entr�es |                                                               ||
// ||         |                                                               ||
// ||_________|_______________________________________________________________||
// || Sorties | result : integer                                              ||
// ||         |   nombre de r�ponses re�ue 1 ok, 0 Erreur                     ||
// ||_________|_______________________________________________________________||
// |___________________________________________________________________________|

begin
  FdwLastError := 0;
  if not FbooAddressResolved then ResolveAddress;
  if FicmpIPAddress = Longword(INADDR_NONE) then
  begin
    FdwLastError := ICMP_STATUS_BAD_DESTINATION ;
    Exit;
  end;
  fIPOptionInformation.TTL := FdwTTL;
  fIPOptionInformation.Flags := FFlags;
  result := envoyerEcho;
end;

end.

