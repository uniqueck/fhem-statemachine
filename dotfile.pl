#!/usr/bin/perl
use strict;
use warnings;
use Storable qw(dclone);

my $string = "{ \
 LongClickAn => [ { event => '\$1:long-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$2:long-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$3:long-click', newState => 'GartenScheuneHof'  },  \
 ], \
 LongClickOFF => [ { event => '\$1:long-click', newState => 'OFF'  },  \
                   { event => '\$2:long-click', newState => 'OFF'  },  \
                   { event => '\$3:long-click', newState => 'OFF'  },  \
 ], \
 DoubleClickTimer => [ { event => '\$1:double-click', newState => 'HofVerlassen'  },  \
                       { event => '\$2:double-click', newState => 'GartenVerlassen'  },  \
                       { event => '\$3:double-click', newState => 'GartenVerlassen'  },  \
 ], \
 DoubleClickOFF => [ { event => '\$1:double-click', newState => 'OFF'  },  \
                     { event => '\$2:double-click', newState => 'OFF'  },  \
                     { event => '\$3:double-click', newState => 'OFF'  },  \
 ], \
 Generic => [ \
 ], \
 OFF => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'Hof'  },  \
                  { event => '\$2:short-click', newState => 'Hof'  },  \
                  { event => '\$3:short-click', newState => 'Garten'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Hof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'Scheune'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'Terrasse'  },  \
                  { event => '\$4:toogle-Garten', newState => 'Garten'  },  \
 ], \
 An => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht ON;', groups => 'LongClickOFF,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$2:short-click', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$3:short-click', newState => 'GartenTerrasseHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenTerrasseHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenScheuneHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'TerrasseScheuneHof'  },  \
 ], \
 Garten => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'GartenHof'  },  \
                  { event => '\$2:short-click', newState => 'GartenHof'  },  \
                  { event => '\$3:short-click', newState => 'GartenScheune'  },  \
                  { event => '\$4:toogle-Hof', newState => 'GartenHof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenScheune'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenTerrasse'  },  \
                  { event => '\$4:toogle-Garten', newState => 'OFF'  },  \
 ], \
 GartenHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'Garten'  },  \
                  { event => '\$2:short-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$3:short-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Garten'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenScheuneHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenTerrasseHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'Hof'  },  \
 ], \
 Terrasse => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'TerrasseHof'  },  \
                  { event => '\$2:short-click', newState => 'TerrasseHof'  },  \
                  { event => '\$3:short-click', newState => 'OFF'  },  \
                  { event => '\$4:toogle-Hof', newState => 'TerrasseHof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'TerrasseScheune'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'OFF'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenTerrasse'  },  \
 ], \
 TerrasseHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'Terrasse'  },  \
                  { event => '\$2:short-click', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$3:short-click', newState => 'Hof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Terrasse'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'Hof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenTerrasseHof'  },  \
 ], \
 Scheune => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'ScheuneHof'  },  \
                  { event => '\$2:short-click', newState => 'OFF'  },  \
                  { event => '\$3:short-click', newState => 'TerrasseScheune'  },  \
                  { event => '\$4:toogle-Hof', newState => 'ScheuneHof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'OFF'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'TerrasseScheune'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenScheune'  },  \
 ], \
 Hof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;' , groups => 'LongClickAn,DoubleClickTimer,Generic'},  \
                  { event => '\$1:short-click', newState => 'OFF'  },  \
                  { event => '\$2:short-click', newState => 'ScheuneHof'  },  \
                  { event => '\$3:short-click', newState => 'GartenHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'OFF'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'ScheuneHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'TerrasseHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenHof'  },  \
 ], \
 ScheuneHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'Scheune'  },  \
                  { event => '\$2:short-click', newState => 'Scheune'  },  \
                  { event => '\$3:short-click', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Scheune'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'Hof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenScheuneHof'  },  \
 ], \
 GartenScheune => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$2:short-click', newState => 'Garten'  },  \
                  { event => '\$3:short-click', newState => 'Scheune'  },  \
                  { event => '\$4:toogle-Hof', newState => 'GartenScheuneHof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'Garten'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$4:toogle-Garten', newState => 'Scheune'  },  \
 ], \
 GartenHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                { event => '\$1:short-click', newState => 'Garten'  },  \
                { event => '\$2:short-click', newState => 'GartenScheuneHof'  },  \
                { event => '\$3:short-click', newState => 'GartenScheuneHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Garten'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'Scheune'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'Terrasse'  },  \
                  { event => '\$4:toogle-Garten', newState => 'Hof'  },  \
 ], \
 GartenTerrasse => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'GartenTerrasseHof'  },  \
                  { event => '\$2:short-click', newState => 'GartenTerrasseHof'  },  \
                  { event => '\$3:short-click', newState => 'Terrasse'  },  \
                  { event => '\$4:toogle-Hof', newState => 'Hof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'Garten'  },  \
                  { event => '\$4:toogle-Garten', newState => 'Terrasse'  },  \
 ], \
 GartenTerrasseHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                        { event => '\$1:short-click', newState => 'GartenTerrasse'  },  \
                        { event => '\$2:short-click', newState => 'An'  },  \
                        { event => '\$3:short-click', newState => 'TerrasseHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'GartenTerrasse'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'An'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'TerrasseHof'  },  \
 ], \
 GartenTerrasseScheune => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht ON;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'An'  },  \
                  { event => '\$2:short-click', newState => 'GartenTerrasse'  },  \
                  { event => '\$3:short-click', newState => 'GartenTerrasse'  },  \
                  { event => '\$4:toogle-Hof', newState => 'An'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenTerrasse'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'GartenScheune'  },  \
                  { event => '\$4:toogle-Garten', newState => 'TerrasseScheune'  },  \
 ], \
 GartenScheuneHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', groups => 'LongClickOFF,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'GartenScheune'  },  \
                  { event => '\$2:short-click', newState => 'GartenScheune'  },  \
                  { event => '\$3:short-click', newState => 'ScheuneHof'  },  \
                  { event => '\$4:toogle-Hof', newState => 'GartenScheune'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'GartenHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'An'  },  \
                  { event => '\$4:toogle-Garten', newState => 'ScheuneHof'  },  \
 ], \
 TerrasseScheuneHof => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'TerrasseScheune'  },  \
                  { event => '\$2:short-click', newState => 'TerrasseScheune'  },  \
                  { event => '\$3:short-click', newState => 'An'  },  \
                  { event => '\$4:toogle-Hof', newState => 'TerrasseScheune'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'TerrasseHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'ScheuneHof'  },  \
                  { event => '\$4:toogle-Garten', newState => 'An'  },  \
 ], \
 TerrasseScheune => [ { enter => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht ON;set G_Garten_Hauptlicht OFF;', groups => 'LongClickAn,DoubleClickTimer,Generic' },  \
                  { event => '\$1:short-click', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$2:short-click', newState => 'Terrasse'  },  \
                  { event => '\$3:short-click', newState => 'GartenTerrasseScheune'  },  \
                  { event => '\$4:toogle-Hof', newState => 'TerrasseScheuneHof'  },  \
                  { event => '\$4:toogle-Scheune', newState => 'TerrasseHof'  },  \
                  { event => '\$4:toogle-Terrasse', newState => 'Scheune'  },  \
                  { event => '\$4:toogle-Garten', newState => 'GartenTerrasseScheune'  },  \
 ], \
 GartenVerlassen => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;sleep 0.5;set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;sleep 0.5;set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht ON;', \
                        leave => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;sleep 0.5;', \
                        groups => 'LongClickAn,DoubleClickOFF,Generic' },  \
                  { timeout => 120, newState => 'OFF'  },  \
                  { event => '\$1:short-click', newState => 'previous'  },  \
                  { event => '\$2:short-click', newState => 'previous'  },  \
                  { event => '\$3:short-click', newState => 'previous'  },  \
 ], \
 HofVerlassen => [ { enter => 'set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;sleep 0.5;set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;sleep 0.5;set G_Hof_Hauptlicht ON;set G_Scheune_Hauptlicht ON;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;', \
                     leave => 'set G_Hof_Hauptlicht OFF;set G_Scheune_Hauptlicht OFF;set G_Terrasse_Hauptlicht OFF;set G_Garten_Hauptlicht OFF;sleep 0.5;', \
                     groups => 'LongClickAn,DoubleClickOFF,Generic' },  \
                  { timeout => 10, newState => 'OFF'  },  \
                  { event => '\$1:short-click', newState => 'previous'  },  \
                  { event => '\$2:short-click', newState => 'previous'  },  \
                  { event => '\$3:short-click', newState => 'previous'  },  \
 ], \
}";

sub
getSettingTransition($)
{
  my ($current_state) = @_;
  return undef if( ref($current_state) ne 'ARRAY' );

   foreach my $t (@{$current_state}) {
     return $t if( defined($t->{enter}) || defined($t->{leave}) || defined($t->{groups}));
   }

  return undef;
}

sub handle_groups {
  my ($states) = @_;
  my @keys = keys %{$states};
  foreach my $key (@keys) {
    if( my $setting = getSettingTransition($states->{$key}) ) {
      if( my $groups_setting = $setting->{groups} ) {
        my @groups = split(/,/, $groups_setting);
        foreach my $group (@groups) {
	  my @group_transitions = @{$states->{$group}};
	  foreach my $transition (@group_transitions) {
	    $transition->{group} = $group;
	  }
          push @{$states->{$key}}, @group_transitions};
        }
      }
    }
  }
#}

sub generate_dot_file {
  my ($states, $event, $filename) = @_;
  my @keys = keys %{$states};
  # eliminate pure groups
  my %pure_groups;
  # get all groups
  foreach my $key (@keys) {
    my $transitions = $states->{$key};
    if( my $setting = getSettingTransition($transitions) ) {
      if( my $groups_setting = $setting->{groups} ) {
        my @groups = split(/,/, $groups_setting);
        foreach my $group (@groups) {
          $pure_groups{$group} = 1;
        }
      }
    }
  }
  # eliminate reachable groups
  foreach my $key (@keys) {
    my $transitions = $states->{$key};
    foreach my $transition (@{$transitions}) {
      if (defined($transition->{newState})) {
        if (exists($pure_groups{$transition->{newState}})) {
          delete($pure_groups{$transition->{newState}});
        }
      }
    }
  }
  open(my $fh, '>', $filename);
  print $fh "digraph G {\n";
  foreach my $key (@keys) {
	my $transitions = $states->{$key};
    if (exists($pure_groups{$key})) {
    print $fh  $key . " [shape=Mdiamond];\n";
	    foreach my $transition (@{$transitions}) {
	      if (defined($transition->{newState})) {
		if (defined($transition->{event})) {
		  if ($transition->{event} =~ /$event/) {
		    print $fh $key . " -> " . $transition->{newState};
		    print $fh " [label=\"" . $transition->{event} . "\"]";
		    print $fh "\n";
		  }
		}
		if (defined($transition->{timeout})) {
		  print $fh $key . " -> " . $transition->{newState};
		  print $fh "[label=\"timeout=" . $transition->{timeout} . "\"]";
		  print $fh "\n";
		}
	      }
	    }
        next;
    }
    print $fh  $key . " [shape=none,margin=0,label=<<table BORDER= \"0\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\">\n";
    print $fh "<tr><td><b>" . $key . "</b></td></tr>\n";
    # generate enter, group and leave lables
    if( my $setting = getSettingTransition($transitions) ) {
      if( my $enters_setting = $setting->{enter} ) {
        print $fh "<tr><td><font COLOR=\"blue\">enter:</font><br/>\n";
        my @enters = split(/;/, $enters_setting);
        foreach my $enter (@enters) {
          print $fh $enter . "<br/>\n";
        }
        print $fh "</td></tr>\n";
      }
      if( my $leaves_setting = $setting->{leave} ) {
        print $fh "<tr><td><font COLOR=\"blue\">leave:</font><br/>\n";
        my @leaves = split(/;/, $leaves_setting);
        foreach my $leave (@leaves) {
          print $fh $leave . "<br/>\n";
        }
        print $fh "</td></tr>\n";
      }
      if( my $groups_setting = $setting->{groups} ) {
        print $fh "<tr><td><font COLOR=\"blue\">groups:</font><br/>\n";
        my @groups = split(/,/, $groups_setting);
        foreach my $group (@groups) {
          print $fh $group . "<br/>\n";
        }
        print $fh "</td></tr>\n";
      }
    }
    print $fh "</table>>];\n\n";
    # generate transitions
    foreach my $transition (@{$transitions}) {
      if (defined($transition->{newState}) && !defined($transition->{group})) {
        if (defined($transition->{event})) {
          if ($transition->{event} =~ /$event/) {
            print $fh $key . " -> " . $transition->{newState};
            print $fh " [label=\"" . $transition->{event} . "\"]";
            print $fh "\n";
          }
        }
        if (defined($transition->{timeout})) {
          print $fh $key . " -> " . $transition->{newState};
          print $fh "[label=\"timeout=" . $transition->{timeout} . "\"]";
          print $fh "\n";
        }
      }
    }
    print $fh "\n";
  }
  print $fh "}\n";
  close $fh;
  #generate png file
  system("dot", "-Tpng", $filename, "-o", $filename.".png")
}

my $states = eval $string;
handle_groups($states);
generate_dot_file($states, "1:short", "event1.dot");
generate_dot_file($states, "2:short", "event2.dot");
generate_dot_file($states, "3:short", "event3.dot");
generate_dot_file($states, "4:", "event4.dot");
generate_dot_file($states, "", "all.dot");
