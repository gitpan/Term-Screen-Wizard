package Term::Screen::Wizard;

use strict;
use base qw(Term::Screen::ReadLine);
use Term::Screen::ReadLine;

use vars qw($VERSION);

BEGIN {
  $VERSION=0.20;
}

sub add_screen {
  my $self = shift;
  my $args = {
    NAME      => "noname",
    HEADER    => "",
    FOOTER    => "",
    CANCEL    => "Esc - Cancel",
    NEXT      => "Ctrl-Enter - Next",
    PREVIOUS  => "F3 - Previous",
    FINISH    => "Ctrl-Enter - Finish",
    NOFINISH  => 0,
    HELPTEXT  => undef,
    HELP      => "F1 - Help",
    ROW       => 2,
    COL       => 2,
    PROMPTS   => undef,
    @_,
  };

  my $arr=$self->{SCREENS};
  my @array;
  if ($arr) { @array=@$arr; }
  push @array, $args;
  $self->{SCREENS}=\@array;
return 1;
}

sub del_screen {
  my $self = shift;
  my $name = shift;
  my $i;
  my %screen;
  my $scr;
  my $arr=$self->{SCREENS};
  my @array=@$arr;

  $i=0;
  foreach $scr (@array) {
    if ($scr->{NAME} eq $name) {
      delete $self->{SCREENS}->{$i};
      return 1;
    }
    $i++;
  }
return 0;
}

sub get_screen {
  my $self = shift;
  my $name = shift;
  my %screen;
  my $scr;
  my $arr=$self->{SCREENS};
  my @array=@$arr;

  foreach $scr (@array) {
    if ($scr->{NAME} eq $name) {
      return %$scr;
    }
  }

return undef;
}

sub get_keys {
  my $self = shift;
  my $scr;
  my %values;

  for $scr (@{ $self->{SCREENS} }) {
    my $prompt;
    my $name=$scr->{NAME};
    for $prompt (@{ $scr->{PROMPTS} }) {
      $values{$name}{$prompt->{KEY}}=$prompt->{VALUE};
    }
  }
return %values;
}

sub wizard {
  my $self=shift;
  my $i=0;
  my $arr=$self->{SCREENS};
  my @array=@$arr;
  my $scr;
  my $i;
  my $N=scalar @array;
  my $what;
  my $footer;
  my $space=chr(32).chr(32).chr(32);

  $i=0;
  while ($i < $N) {
    $scr=$array[$i];

    $footer="";
    if ($scr->{HELPTEXT}) { $footer.=$space.$scr->{HELP}; }
    $footer.=$space.$scr->{CANCEL};
    if ($i  >  0   ) { $footer.=$space.$scr->{PREVIOUS}; }
    if ($i  < $N-1 or $scr->{NOFINISH} ) { $footer.=$space.$scr->{NEXT}; }
    if ($i == $N-1 and not $scr->{NOFINISH} ) { $footer.=$space.$scr->{FINISH}; }
    $scr->{FOOTER}=$footer;

    $what=$self->_display_screen($scr);

    if ($what eq "previous") {
      $i-- unless $i==0;
    }
    elsif ($what eq "next") {
      $i++;
      if ($i == $N) { last; }
    }
    else {
      last;
    }
  }

  if ($what ne "cancel") {
    foreach $scr (@array) {
      my $prompt;
      foreach $prompt (@{ $scr->{PROMPTS} }) {
	$prompt->{VALUE}=$prompt->{NEWVALUE};
	$prompt->{NEWVALUE}=undef;
      }
    }
    $what="finish";
  }

return $what;
}

sub _display_screen {
  my $self   = shift;
  my $scr    = shift;
  my $prompt;
  my $promptlen;
  my $displen;
  my $i;
  my $key;
  my @prompts=@{ $scr->{PROMPTS} };
  my $line;
  my $N;
  my $val;
  my $only;
  my $convert;
  my $dashes;
  my %keys;


  %keys = ( "esc"       => 1,
            "ctrl-enter" => 1,
            "pgdn"       => 1,
            "pgup"       => 1,
            "k3"         => 1,
            "k4"         => 1,
            "k1"         => 2,
           );


  {my $i;
     for(1..$self->{COLS}) {
       $dashes.="-";
     }
  }

  $N=scalar @prompts;
  $key="none";

  while (not defined $keys{$key} or $keys{$key} == 2) {

    $self->clrscr();

    if ($scr->{HEADER}) {
      $self->at(0,0)->puts($scr->{HEADER});
      $self->at(1,0)->puts($dashes);
    }
    if ($scr->{FOOTER}) {
      $self->at($self->{ROWS}-1,0)->puts($scr->{FOOTER});
      $self->at($self->{ROWS}-2,0)->puts($dashes);
    }

    if ($key eq "k1") {
      $self->at(3,0)->puts($scr->{HELP});
      $self->getch();
      $key="";
      next;
    }

    $key="";
    $promptlen=0;
    $i=3;
    foreach $prompt ( @prompts ) {
      my $s=$prompt->{PROMPT};
      if (length $s > $promptlen) { $promptlen=length $s; }
      $self->at($i,0)->puts($prompt->{PROMPT});
      $i++;
    }

    $promptlen++;
    $i=3;
    foreach $prompt ( @prompts	) {
      if (not defined $prompt->{NEWVALUE}) {
	$val=$prompt->{VALUE};
	$prompt->{NEWVALUE}=$val;
      }
      else {
	$val=$prompt->{NEWVALUE};
      }
      $self->at($i,$promptlen)->puts(": $val");
      $i++;
    }

    $promptlen+=2;
    $displen=$self->{COLS}-$promptlen;

    $i=0;
    while (not defined $keys{$key}) {

      if ($prompts[$i]->{ONLYVALID}) {
	$only=$prompts[$i]->{ONLYVALID};
      }
      else {
	$only=undef;
      }

      if ($prompts[$i]->{CONVERT}) {
	$convert=$prompts[$i]->{CONVERT};
      }
      else {
	$convert=undef;
      }

      $line=$self->readline(ROW => $i+3, COL => $promptlen,
			    LEN => $prompts[$i]->{LEN},
			    DISPLAYLEN => $displen,
			    LINE => $prompts[$i]->{NEWVALUE},
			    EXITS => { "pgup" => "pgup", "pgdn" => "pgdn", "k1" => "k1", "k3" => "k3", "k4" => "k4" },
			    ONLYVALID => $only,
			    CONVERT => $convert,
			   );

      $prompts[$i]->{NEWVALUE}=$line;
      $key=$self->lastkey();

      if ($key eq "tab" or $key eq "enter" or $key eq "kd") {
	$i+=1;
	if ($i >= $N) {
	  $i=0;
	  if ($key eq "enter") {
	    $key="ctrl-enter";
	  }
	}
      }
      elsif ( $key eq "ku" ) {
	$i--;
	if ($i < 0 ) { $i=$N-1; }
      }

    }
  }

  if ($key eq "esc") {
    return "cancel";
  }
  elsif ($key eq "ctrl-enter" or $key eq "pgdn" or $key eq "k4" ) {
    return "next";
  }
  elsif ($key eq "pgup" or $key eq "k3" ) {
    return "previous";
  }
}


=pod

=head1 NAME

Term::Screen::Wizard - A wizard on your terminal...

=head1 SYNOPSIS

	use Term::Screen::Wizard;

        $scr = new Term::Screen::Wizard;

        $scr->clrscr();

        $scr->add_screen(
              NAME => "PROCES",
              HEADER => "Give me the new process id",
              CANCEL => "Esc - Annuleren",
              NEXT   => "Ctrl-Enter - Volgende",
              PREVIOUS => "F3 - Vorige",
              FINISH => "Ctrl-Enter - Klaar",
              PROMPTS => [
                 { KEY => "PROCESID", PROMPT => "Proces Id", LEN=>32, VALUE=>"123456789.00.04" , ONLYVALID => "[a-zA-Z0-9.]*" },
                 { KEY => "TYPE", PROMPT => "Intern or Extern Process (I/E)", CONVERT => "up", LEN=>1, ONLYVALID=>"[ieIE]*" },
                 { KEY => "OMSCHRIJVING", PROMPT => "Description of Proces", LEN=>75 }
                        ],

#
# OK This helptext is in Dutch, but it's clear how it works isn't it?
#
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
#
# So the point is you can change the Wizard 'buttons'.
#
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

=head1 DESCRIPTION

This is a module to have a Wizard on a Terminal. It inherits from 
Term::Screen::ReadLine. The module provides some functions to add
screens. The result is a Hash with keys that have the (validated)
values that the used inputted on the different screens. 

=head1 USAGE

Description of the interface.

add_screen(
    NAME      => <name of screen>,
    HEADER    => <header to put on top of screen>,
    CANCEL    => <text of cancel 'button', defaults to 'Esc - Cancel'>,
    NEXT      => <text of next 'button', defaults to 'Ctrl-Enter - Next'>,
    PREVIOUS  => <text of previous 'button', defaults tro 'PgUp - Previous'>,
    FINISH    => <text of finish 'button', defaults to 'Ctrl-Enter - Finish>,
    HELP      => <text of help 'button', defaults to 'F1 - Help'>,
    HELPTEXT  => <text to put on your helpscreen>
    NOFINISH  => <1/0 - Inidicates that this wizard is/is not (1/0) part
                        of an ongoing 'wizard sequence'>
    PROMPTS   => <array of fields to input>
)

  This function add's a screen to the list of screens that the wizards goes
  through sequentially. If NOFINISH==1, the finish 'button' is not used. Use
  this, if the last screen of this wizard is not actually the last screen
  of a sequence of wizards. 

  For instance, if you need to go one way or the other after the first screen,
  you provide a wizard with one screen and no FINISH button. After that you
  call the next sequence of screens.

           PROMPTS => [
             { KEY => "ANINT",     PROMPT => "INT",     LEN => 10, CONVERT => "up", ONLYVALID => "[0-9]*" },
             { KEY => "ADOUBLE",  PROMPT => "DOUBLE",  LEN => 16, CONVERT => "up", ONLYVALID => "[0-9]+([.,][0-9]*)?" },
           ]

  Note the entries in PROMPTS : 

     KEY         is the hash key with what you can access the field.
     PROMPT      is the prompt to use for the field.
     LEN         is the maximum length of the field.
     CONVERT     'up' or 'lo' for uppercase or lowercase. If not used
                 it won't convert.
     ONLYVALID   is a regex to use for validation. Note: validation is
                 done *before* conversion! If not used, no validation is
                 done.
     VALUE       a default value to use. This value will change if the
                 wizard is used.


del_screen(<name>)

  This function deletes a screen with given name from the list of screens.


get_screen(<name>)

  This function get's you a handle to a defined screen with given name.


get_keys()

  This function gives you all the keys in a hash of a hash. Actually
  a hash of screens and each screen a hash of keys. See synopsis for
  usage.

wizard()
  
  This function starts the wizard.

=head1 AUTHOR

  Hans Dijkema <hans@oesterholt-dijkema.emailt.nl>

=cut

1;

