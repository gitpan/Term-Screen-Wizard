#!/usr/bin/perl

use lib "/prj/dsnew/perlmods/lib/site_perl/current";
use lib "/prj/dsnew/perlmods/lib/site_perl/current/aix";
use lib "/prj/dsnew/perlmods/lib/current";
use lib "./blib/lib";

BEGIN { $| = 1; $Ntst=5; print "1..$Ntst\n"; $tst=1; }
END { if ( $tst != $Ntst ) { print "not ok $tst\n"; } }

##############################################################################

print "Test $tst, loading the module and allocating screen\n";

use Term::Screen::Wizard;

$scr = new Term::Screen::Wizard;

print "ok $tst\n";
$tst++;

##############################################################################

$scr->clrscr();

$scr->add_screen(
      NAME => "PROCES",
      HEADER => "Test $tst(1), TESTING THE WIZARD, enter some things here, please also test F1",
      CANCEL => "Esc - Annuleren",
      NEXT   => "Ctrl-Enter - Volgende",
      PREVIOUS => "F3 - Vorige",
      FINISH => "Ctrl-Enter - Klaar",
      PROMPTS => [
         { KEY => "PROCESID", PROMPT => "Proces Id", LEN=>32, VALUE=>"123456789.00.04" , ONLYVALID => "[a-zA-Z0-9.]*" },
         { KEY => "TYPE", PROMPT => "Intern of Extern Proces (I/E)", CONVERT => "up", LEN=>1, ONLYVALID=>"[ieIE]*" },
         { KEY => "OMSCHRIJVING", PROMPT => "Beschrijving Proces", LEN=>75 },
         { KEY => "PASSWORD", PROMPT => "Enter a password", LEN=>14, PASSWORD=>1 }
                ],
      HELPTEXT => "\n\n\n".
              "  Don't worry, it's dutch.\n".
              "\n".
              "  In dit scherm kan een nieuw proces Id worden opgevoerd\n".
              "\n".
              "  ProcesId      - is het ingevoerde Proces Id\n".
              "  Intern/Extern - is het proces belastingdienst intern of niet?\n".
              "  Omschrijving  - Een korte omschrijving van het proces.\n"
     );

$scr->add_screen(
   NAME => "X.400",,
   HEADER => "Test $tst(2), TESTING THE WIZARD, enter some things here, please also test F1",
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
   HEADER => "Test $tst(3), TESTING THE WIZARD, enter some things here, please also test F1",
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

$result=$scr->wizard();
print "ok $tst\n";
$tst++;

##############################################################################

$scr->puts("Only PROCES and GETALLEN")->getch();
$result=$scr->wizard("PROCES","GETALLEN");
print "ok $tst\n";
$tst++;

##############################################################################

$scr->clrscr();
print "Test $tst, printing the entered values in the wizard.\n";
print "Wizard result was : '$result'\n";

%values=$scr->get_keys();
@array=( "PROCES", "X.400" );

for $i (@array) {
  print "\n$i\n\r";
  for $key (keys % { $values{$i} }) {
    my $val=$values{$i}{$key};
    print "  $key=$val\n\r";
  }
}

%values=$scr->get_keys("GETALLEN");
@array=( "GETALLEN" );

for $i (@array) {
  print "\n$i\n\r";
  for $key (keys % { $values{$i} }) {
    my $val=$values{$i}{$key};
    print "  $key=$val\n\r";
  }
}

print "ok $tst\n";
$tst++;

##############################################################################

exit;

