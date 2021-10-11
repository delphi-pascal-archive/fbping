program fbping;

// |===========================================================================|
// | PROGRAM fbping                                                            |
// | F.BASSO 2016                                                              |
// |___________________________________________________________________________|
// | Logiciel permettant d'executer un ping sur une liste de host et d'afficher|
// |  les statistiques                                                         |
// |___________________________________________________________________________|
// | Ce programme est libre, vous pouvez le redistribuer et ou le modifier     |
// | selon les termes de la Licence Publique Générale GNU publiée par la       |
// | Free Software Foundation .                                                |
// | Ce programme est distribué car potentiellement utile,                     |
// | mais SANS AUCUNE GARANTIE, ni explicite ni implicite,                     |
// | y compris les garanties de commercialisation ou d'adaptation              |
// | dans un but spécifique.                                                   |
// | Reportez-vous à la Licence Publique Générale GNU pour plus de détails.    |
// |                                                                           |
// | anbasso@wanadoo.fr                                                        |
// |___________________________________________________________________________|
// | Versions                                                                  |
// |  _________                                                                |
// | /  1.0.0  \______________________________________________________________ |
// || 2016/11/11 F.BASSO                                                      ||
// || Création du programme                                                   ||
// ||_________________________________________________________________________||
// |===========================================================================|

uses
  Forms,
  ufrmmaitre in 'ufrmmaitre.pas' {frmMaitre};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMaitre, frmMaitre);
  Application.Run;
end.
