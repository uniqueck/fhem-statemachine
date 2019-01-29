# $Id: 33_stateMachine.pm 9767 2015-11-03 23:22:37Z justme1968 $

#TODO: trigger by missing event, timeout for event sequence, watchdog

#keywords:
#event, action, newState
#if !event ->  transition after timeout
#onEnter, onExit
#retrigger


package main;

use strict;
use warnings;

use Time::HiRes qw(gettimeofday);

#define <fsm> stateMachine CUL_HM_HM_PB_2_WM55_2B63C7_Btn_01,CUL_HM_HM_PB_2_WM55_2B63C7_Btn_02 Sonos_Esszimmer
#attr <fsm> transitions \
#{ OFF => [ { event => '$1:Short', action => 'set $TARGET Volume 15;; set $TARGET Play', newState => 'ON'  }, ], \
#  ON  => [ { event => '$2:Short', action => 'set $TARGET Stop',                         newState => 'OFF' },    \
#           { event => '$1:Long',  action => 'set $TARGET VolumeU', retrigger => 0.5,    newState => 'ON'  },    \
#           { event => '$2:Long',  action => 'set $TARGET VolumeD', retrigger => 0.5,    newState => 'ON'  },    \
#           { event => ':Release', action => ''                                                            }, ], \
#}
#attr <fsm> start OFF

#define <fsm> stateMachine CUL_HM_HM_PB_2_WM55_2B63C7_Btn_01,CUL_HM_HM_PB_2_WM55_2B63C7_Btn_02 Sonos_Esszimmer
#attr <fsm> stateFn {return 'OFF' if(ReadingsVal($TARGET,'transportState','STOPPED') eq 'STOPPED');; return 'ON'}
#attr <fsm> transitions \
#{ OFF => [ { event =>   ':Short', action => 'set $TARGET Volume 15;; set $TARGET on', newState => 'ON'  }, ], \
#  ON  => [ { event => '$1:Short', action => 'set $TARGET VolumeU', timeout => 0.5,    newState => 'ON'  },    \
#           { event => '$1:Short', action => 'set $TARGET Volume 15',                  newState => 'ON'  },    \
#           { event => '$2:Short', action => 'set $TARGET Stop',                       newState => 'OFF' },    \
#           { event => '$1:Long',  action => 'set $TARGET VolumeU',                    newState => 'ON'  },    \
#           { event => '$2:Long',  action => 'set $TARGET VolumeD',                    newState => 'ON'  }, ], \
#}
#attr <fsm> start OFF

#define <fsm> stateMachine CUL_HM_HM_PB_2_WM55_2_25EBC7_Btn_01,CUL_HM_HM_PB_2_WM55_2_25EBC7_Btn_02 LED2_3
#attr <fsm> transitions \
#{ OFF     => [ { event => '$1:Short|Long', action => 'set $TARGET on',      newState => 'ON'      },                  \
#               { event => '$2:Short',      action => 'set $TARGET 50%',     newState => 'ON'      }, ],               \
#  ON      => [ { event => '$1:Short',      action => 'set $TARGET 100%',    newState => 'ON', timeout => 0.5,      }, \
#               { event => '$2:Short',      action => 'set $TARGET off',     newState => 'OFF'     },                  \
#               { event => '$1:Long',       action => 'set $TARGET dimUp',   newState => 'DIMUP'   },                  \
#               { event => '$2:Long',       action => 'set $TARGET dimDown', newState => 'DIMDOWN' }, ],               \
#  DIMUP   => [ { event =>   ':Long',       action => 'set $TARGET dimUp',   newState => 'DIMUP'   },                  \
#               { event =>   ':Release',    action => '{Log 1, $EVENT}',     newState => 'ON'      }, ],               \
#  DIMDOWN => [ { event =>   ':Long',       action => 'set $TARGET dimDown', newState => 'DIMDOWN' },                  \
#               { event =>   ':Release',    action => '{Log 1, $EVENT}',     newState => 'ON'      }, ],               \
#}
#attr <fsm> start OFF


sub stateMachine_Initialize($)
{
  my ($hash) = @_;

  $hash->{DefFn}    = "stateMachine_Define";
  $hash->{NotifyFn} = "stateMachine_Notify";
  $hash->{UndefFn}  = "stateMachine_Undefine";
  $hash->{SetFn}    = "stateMachine_Set";
  #$hash->{GetFn}    = "stateMachine_Get";
  $hash->{AttrFn}   = "stateMachine_Attr";
  $hash->{AttrList} = "disable:1,0 disabledForIntervals "
                      ."start transitions:textField-long "
                      ."stateFn "
                      .$readingFnAttributes;
}

sub
stateMachine_Define($$)
{
  my ($hash, $def) = @_;

  my @args = split("[ \t]+", $def);

  return "Usage: define <name> stateMachine <device> [<target>]"  if(@args < 3);

  RemoveInternalTimer( $hash );

  my $name = shift(@args);
  my $type = shift(@args);
  my $devices = shift(@args);
  my $target = shift(@args);

  my @devices = devspec2array($devices);
  $hash->{DEVICES} = \@devices;
  $hash->{TARGET} = $target;

  my %list;
  foreach my $d (@devices) {
    $list{$d} = 1;
  }
  $hash->{CONTENT} = \%list;

  $hash->{STATE} = AttrVal( $name, 'start', 'OFF' );
  delete $hash->{helper}{currentTransion};

  return undef;
}

sub stateMachine_Undefine($$)
{
  my ($hash,$arg) = @_;

  return undef;
}

sub
stateMachine_retrigger($)
{
  my ($hash) = @_;
  my $name  = $hash->{NAME};

  Log3 $name, 5, "$name: retrigger";
  RemoveInternalTimer( $hash, "stateMachine_retrigger" );

  #FIXME: abort retrigger if condition evaluates to false ?

  stateMachine_doTransition($hash, $hash->{helper}{retrigger}{t}, $hash->{helper}{retrigger}{specials});
}
sub
stateMachine_timedTransition($)
{
  my ($hash) = @_;
  my $name  = $hash->{NAME};

  Log3 $name, 5, "$name: timedTransition";
  RemoveInternalTimer( $hash, "stateMachine_timedTransition" );

  stateMachine_doTransition($hash, $hash->{helper}{timed}{t}, $hash->{helper}{timed}{specials});

  $hash->{LAST_EVENT} = "#timed";
  $hash->{LAST_EVENT_TIME} = gettimeofday();
}

sub
getEmptyTransition($)
{
  my ($current_state) = @_;
  return undef if( ref($current_state) ne 'ARRAY' );

   foreach my $t (@{$current_state}) {
     return $t if( !$t->{event} );
   }

  return undef;
}
sub
stateMachine_doTransition($$%)
{
  my ($hash,$t,$specials) = @_;
  my $name  = $hash->{NAME};

  RemoveInternalTimer( $hash, "stateMachine_retrigger" );
  RemoveInternalTimer( $hash, "stateMachine_timedTransition" );

  my $new_state = $t->{newState};
  $new_state  = $hash->{STATE} if( !defined($new_state) );

  if( $hash->{helper}{currentTransition} && $hash->{helper}{currentTransition}->{onExit} && $new_state ne $hash->{STATE} ) {
    my $exec = EvalSpecials($hash->{helper}{currentTransition}{onExit}, %{$specials});
    Log3 $name, 4, "$name: exec $exec";

    AnalyzeCommandChain(undef, $exec);
  }

  if( $t->{onEnter} && $new_state ne $hash->{STATE} ) {
    my $exec = EvalSpecials($t->{onEnter}, %{$specials});
    Log3 $name, 4, "$name: exec $exec";

    AnalyzeCommandChain(undef, $exec);
  }

  my $exec = EvalSpecials($t->{action}, %{$specials});
  Log3 $name, 4, "$name: exec $exec";

  my $r = AnalyzeCommandChain(undef, $exec);
  Log3 $name, 3, "$name: return value: $r" if($r);
  $new_state = $r if( $r && $t->{action} =~ /^{.*}$/ );

  if( my $retrigger = $t->{retrigger} ) {
    if( $new_state eq $hash->{STATE} ) {
      $hash->{helper}{retrigger} = { t => $t, specials => $specials };
      InternalTimer( gettimeofday()+$retrigger, "stateMachine_retrigger", $hash, 0 );

    } else {
      Log3 $name, 2, "$name: can't retrigger with state transition";

    }
  }

  my $transitions = $hash->{helper}{transitions};
  return undef if( !$transitions );

  if( defined($new_state) && defined($transitions->{$new_state}) ) {
    $hash->{STATE} = $new_state;
    $hash->{helper}{currentTransition} = $t;
    Log3 $name, 5, "$name: new state: $new_state";

    if( my $t = getEmptyTransition($transitions->{$new_state}) ) {
      my $timeout = $t->{timeout};
      $hash->{helper}{timed} = { t => $t, specials => $specials };
      InternalTimer( gettimeofday()+$timeout, "stateMachine_timedTransition", $hash, 0 );
    }

  } elsif( defined($new_state) ) {
    delete $hash->{helper}{currentTransition};
    Log3 $name, 2, "$name: no such state: $new_state";

  }

  return $new_state;
}

sub
stateMachine_Notify($$)
{
  my ($hash,$dev) = @_;
  my $name  = $hash->{NAME};

  my $events = deviceEvents($dev,1);
  return if( !$events );

  return if( IsDisabled($name) > 0 );

  return if($dev->{NAME} eq $name);
  return if( !defined($hash->{CONTENT}{$dev->{NAME}}) );

  my $current_state = $hash->{STATE};
  if( my $stateFn = AttrVal( $name, 'stateFn', undef ) ) {
    my %specials = (   "%NAME" => $name,
                       "%SELF" => $name,
                     "%DEVICE" => $dev->{NAME},
                     "%TARGET" => $hash->{TARGET},
                   );
    my $exec = EvalSpecials($stateFn, %specials);
    my $state = AnalyzeCommandChain(undef, $exec);

    $current_state = $state if( defined($state) );
  }

  my $transitions = $hash->{helper}{transitions};
  return undef if( !$transitions );

  if( !defined($current_state) || !defined($transitions->{$current_state}) ) {
    Log3 $name, 2, "$name: unhandled state: $current_state";
    return undef;
  }

  $hash->{STATE} = $current_state;

  $current_state = $transitions->{$current_state};
  my $max = int(@{$events});
  for (my $i = 0; $i < $max; $i++) {
    my $s = $events->[$i];
    $s = "" if(!defined($s));

    my ($reading,$value) = split(": ", $s, 2);
    next if( !$value );

    my $NUM = $value;
    $NUM =~ s/[^-\.\d]//g;

    if( ref($current_state) ne 'ARRAY' ) {
      $current_state = [ $current_state ];
    }
    foreach my $t (@{$current_state}) {
      next if( ref($t) ne 'HASH' );
      my ($device,$event) = split(':', $t->{event}, 2 );

      if( $device ) {
        $device = $hash->{DEVICES}[$1-1] if( $device =~ m/^\$(\d+)$/ );
        next if( $dev->{NAME} !~ m/^$device$/ );
      }
      next if( $event && $value !~ m/$event/ );
      my %specials= (
                          "%1" => $1,
                          "%2" => $2,
                          "%3" => $3,
                          "%4" => $4,
                        "%NUM" => $NUM,
                       "%NAME" => $name,
                       "%SELF" => $name,
                      "%EVENT" => $s,
                     "%DEVICE" => $dev->{NAME},
                     "%TARGET" => $hash->{TARGET},
                    );

      if( my $timeout = $t->{timeout} ) {
        if( !$hash->{LAST_EVENT} || $hash->{LAST_EVENT} ne $value ) {
          Log3 $name, 5, "$name: not the same event";
          delete $hash->{CURRENT_EVENT_COUNT};
          $hash->{LAST_EVENT} = $value;
          next;
        }

        if( !$hash->{LAST_EVENT_TIME} || gettimeofday() - $hash->{LAST_EVENT_TIME} > $timeout ) {
          Log3 $name, 5, "$name: timeout expired";
          $hash->{LAST_EVENT_TIME} = gettimeofday();
          delete $hash->{CURRENT_EVENT_COUNT};
          next;
        }

        ++$hash->{CURRENT_EVENT_COUNT};

      } else {
        if( !$hash->{LAST_EVENT} || $hash->{LAST_EVENT} ne $value ) {
          $hash->{CURRENT_EVENT_COUNT} = 1;

        } else {
          ++$hash->{CURRENT_EVENT_COUNT};

        }

      }

      $specials{'%CURRENT_EVENT_COUNT'} = $hash->{CURRENT_EVENT_COUNT};

      #ignore event if condition evaluates to false
      if( my $condition = $t->{condition} ) {
        my $exec = EvalSpecials($condition, %specials);
        Log3 $name, 4, "$name: exec $exec";

        my $c = AnalyzeCommandChain(undef, $exec);
        Log3 $name, 4, "$name: condition: $c" if($c);

        next if( !$c );
      }

      stateMachine_doTransition($hash, $t, \%specials);

      $hash->{LAST_EVENT} = $value;
      $hash->{LAST_EVENT_TIME} = gettimeofday();

      last;
    }

  }

  return undef;
}

sub
stateMachine_Set($@)
{
  my ($hash, $name, $cmd, @params) = @_;

  my $list = 'state';
  if( $cmd eq 'state' ) {
    return "usage: $cmd <state>" if( !$params[0] );
    return "no such state: $params[0]" if( !defined($hash->{helper}{transitions}{$params[0]}) );

    $hash->{STATE} = $params[0];
    return undef;
  }

  return "Unknown argument $cmd, choose one of $list";
}

sub
stateMachine_Get($@)
{
  my ($hash, $name, @a) = @_;

}

sub
stateMachine_Attr($$$)
{
  my ($cmd, $name, $attrName, $attrVal) = @_;

  my $hash = $defs{$name};
  if( $attrName eq 'start' ) {
    $hash->{STATE} = $attrVal if( !$hash->{STATE} && $cmd eq 'set' );

  } elsif( $attrName eq 'transitions' ) {

    delete $hash->{helper}{$attrName};

    my %specials= (
                "%NAME" => $name,
                "%SELF" => $name,
              "%DEVICE" => $name,
              "%TARGET" => $hash->{TARGET},
      );
    my $err = perlSyntaxCheck($attrVal, %specials);
    return $err if($err);

    if( $cmd eq 'set' ) {
      my $transitions = eval $attrVal;
      if( $@ ) {
        Log3 $hash->{NAME}, 3, "$name: $attrVal: $@";

      } elsif( ref($transitions) eq 'HASH' ) {
        $hash->{helper}{$attrName} = $transitions;

      } else {
        Log3 $hash->{NAME}, 2, "$name: not a hash: $transitions";

      }

    }

  }

  return undef;
}


1;
