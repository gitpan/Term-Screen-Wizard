#
# TCtest.pl
#
# test program to exercise the screen contol module
#
# by Mark Kaehny 1995
# this file is available under the same terms as the perl language
# distribution. See the Artistic License.
#

use lib "/prj/dsnew/perlmods/lib/site_perl/current";
use lib "/prj/dsnew/perlmods/lib/site_perl/current/aix";
use lib "/prj/dsnew/perlmods/lib/current";

use lib "./blib/lib";

use Term::Screen::Wizard;

$scr = new Term::Screen::Wizard;

$scr->clrscr();

$scr->add_screen(
      NAME => "PROCES",
      HEADER => "Voer het nieuwe proces id in",
      CANCEL => "Esc - Annuleren",
      NEXT   => "Ctrl-Enter - Volgende",
      PREVIOUS => "F3 - Vorige",
      FINISH => "Ctrl-Enter - Klaar",
      PROMPTS => [
         { KEY => "PROCESID", PROMPT => "Proces Id", LEN=>32, VALUE=>"123456789.00.04" , ONLYVALID => "[a-zA-Z0-9.]*" },
         { KEY => "TYPE", PROMPT => "Intern of Extern Proces (I/E)", CONVERT => "up", LEN=>1, ONLYVALID=>"[ieIE]*" },
         { KEY => "OMSCHRIJVING", PROMPT => "Beschrijving Proces", LEN=>75 }
                ],
      HELPTEXT => "\n\n\n".
              "  In dit scherm kan een nieuw proces Id worden opgevoerd\n".
              "\n".
              "  ProcesId      - is het ingevoerde Proces Id\n".
              "  Intern/Extern - is het proces belastingdienst intern of niet?\n".
              "  Omschrijving  - Een korte omschrijving van het proces.\n"
     );

$scr->add_screen(
   NAME => "X.400",,
   HEADER => "Voer het X.400 adres in",
   CANCEL => "Esc - Annuleren",
   NEXT   => "Ctrl-Enter - Volgende",
   PREVIOUS => "F3 - Vorige",
   FINISH => "Ctrl-Enter - Klaar",
   PROMPTS => [
     { KEY => "COUNTRY", PROMPT => "COUNTRY", LEN => 2, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "AMDM",    PROMPT => "AMDM",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "PRDM",    PROMPT => "PRDM",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "ORG",     PROMPT => "ORGANISATION",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "OU1",     PROMPT => "UNIT1",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "OU2",     PROMPT => "UNIT2",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
     { KEY => "OU3",     PROMPT => "UNIT3",    LEN => 16, CONVERT => "up", ONLYVALID => "[^/]*" },
   ],
   HELPTEXT => "\n\n\n".
           "  In dit scherm kan een standaard X.400 adres worden ingevoerd voor een ProcesId",
);

$scr->add_screen(
   NAME => "GETALLEN",,
   HEADER => "Voer getallen in",
   CANCEL => "Esc - Annuleren",
   NEXT   => "Ctrl-Enter - Volgende",
   PREVIOUS => "F3 - Vorige",
   FINISH => "Ctrl-Enter - Klaar",
   #NOFINISH => 1,
   PROMPTS => [
     { KEY => "ANINT",     PROMPT => "INT",     LEN => 10, CONVERT => "up", ONLYVALID => "[0-9]*" },
     { KEY => "ADOUBLE",  PROMPT => "DOUBLE",  LEN => 16, CONVERT => "up", ONLYVALID => "[0-9]+([.,][0-9]*)?" },
   ],
);

$scr->wizard();

$scr->clrscr();

%values=$scr->get_keys();
@array=( "PROCES", "X.400", "GETALLEN" );

for $i (@array) {
  print "\n$i\n\r";
  for $key (keys % { $values{$i} }) {
    my $val=$values{$i}{$key};
    print "  $key=$val\n\r";
  }
}

exit;

