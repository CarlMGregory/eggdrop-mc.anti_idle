##
# Anti Idle v1.0.2 by (Carl M. Gregory) MC_8 <gregory@worldinter.net>
#
# If you have any comments/suggestions/ideas/bug reports, please email me.
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script will kick/ban/mode change a user upon idle'n x amount of seconds.
# The difference between this script, and eggdrop's internal anti idle is
# that you can specify what doesn't reset there idle count, wild cards accpeted.
#
# Note:  Channel ctcp's/notices/actions are treated as public messages.
#
# Extended notes, Ok... I ran across a stump.  Currently eggdrop supports setting
# user defined channel flags, but... no bind pertaning to chanset's.  Ok, here
# is the problem.  Let's say you have mc.antiidle set to 0, witch is off for that
# specific channel, then you change it to 60... you just turned it on.  The script
# cannot see when you turned it on, it needs to be on before the bot join's the
# channel.  If it's not, the users that were there before the bot will not be
# evaluated by this script.  My suggestion, turn what ever channels you want on
# and do a .restart, or if you have access to the `.dump' command... just type
# `.dump PART #channel' and the bot will part/join... this time he will join with
# the antiidle for that channel turned on and go ahead and compile a list of ALL
# users in the channel before the bot was.  I could find a way around this with
# timers, BUT... 1) it would slow the bot/shell down 2) it wouldn't be realtime
# activation.  I reported this delema to the egg devel crew, so they may or may
# not be working on a bind event for me.  If you are a tcl coder and have a nifty
# little trick that will make a proc initalize upon a chanset command, and it's
# realtime... e`mail me.
##

##
# History
##
# v1.0.2 (09.17.01)
#  MC_8 - Riccardo - Fixed 'invalid command name "findip"'.
#
# v1.0.1 (03.11.01)
#  MC_8 - If this script loaded, it disabled all public bind's (on all scripts),
#         this is a minor problem with TCL that was easily compensated.
#  MC_8 - Jens Bergmann - Fixed `Tcl error [mc:aidle:raw:privmsg]: list element
#                         in quotes followed by "" instead of space`
#
# v1.0 (02.03.01)
#  MC_8 - ]2501 - inital release
##

##
# Settings
##
# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   mc.antiidle <time>   Set's the number of seconds the user can idle before
#                        in violation of idle'n.  Set to 0 (default) to disable
#                        this for the specific channel.
#
#  Example from dcc chat with the bot:
#   .chanset #channel mc.antiidle 60

# If the user is found idle'n past the time you set, what do you want the script
# to do?   Set this to the channel mode change you want to perform on the user,
# such as "-v" to devoice them... Set it to "" if you do not want to perform this.
set mc_aidle(mc:method) ""

# If the user is found idle'n past the time you set, what do you want the script
# to do?  This is for kicking and/or banning.
#  0 = disable, don't kick nor ban
#  1 = Kick
#  2 = Ban
#  3 = Kick & Ban
set mc_aidle(kb:method) 3

# If you stated you want to ban the user found idle'n, how long do you want him/her
# baned?
# Set to 0 for a server ban insted of an internal bot ban.  Time in min's.
set mc_aidle(kb:time) 10

# Do you want the script to /msg the user as well upon violating idle'n rules?
#  Replacment veriables:  %nick & %chan
set mc_aidle(message) "%nick, you are in violation of idle'n %chan.  You earned a 10 min ban."

# What do you want as the kick and/or ban message, assuming you chose to kick
# and/or ban the user.
#  Replacment veriables:  %nick & %chan
set mc_aidle(kmessage) "Idle'n in %chan is not permited."

# If you stated you want to ban the user found idle'n, what kinda ban mask do you want?
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9, but
#     instead of using a * wildcard to replace portions of the host.domain, it uses ?
#     wildcards to replace the numbers in the address.
set mc_aidle(banmask) 13

# What does not reset the idle counter for the specific user?  This is based
# off the public chatter produced by the user.  Wildcards accepted.
# Seperate each string with a new line.
set mc_aidle(rbreak) {
 *ftp up*
 *ftp online*
 anti idle, don't ban me
 *serving*
}

# [0=no/1=yes] Do you want to strip color/bold/uline/reverse characters from 
#  the users text before analysing it?
set mc_aidle(strip) 1

# [0=no/1=yes] Do mode changes by the user reset idle his/her idle timer?
set mc_aidle(mcreset) 0

# [0=no/1=yes] Do topic changes by the user reset his/her idle timer?
set mc_aidle(tpreset) 0

# What flaged users are exempt from being examined by this script?
# Flag structure is <global>|<channel>, set to "-|-" to state no one
# is exempt.
set mc_aidle(exempt) "bovf|ovf"

## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_aidle(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_aidle(svs:check) 0  ;#This is at Midnight
#  set mc_aidle(svs:check) 5  ;#This is at 5am
#  set mc_aidle(svs:check) 13  ;#This is at 1pm
#  set mc_aidle(svs:check) 23  ;#This is at 11pm
set mc_aidle(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_aidle(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_aidle(svs:stableonly) 0




### Do not edit past this part ###
set mc_aidle(version) v1.0.2
set mc_aidle(svs:script) "antiidle 001000002000"
set mc_aidle(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Anti Idle $mc_aidle(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Anti Idle $mc_aidle(version) will not work with eggdrop $version."
 putlog "Anti Idle $mc_aidle(version) not loaded."
 return 1
};setudef int mc.antiidle

bind join - * mc:aidle:join
proc mc:aidle:join {nick uhost hand chan} {
 global mc_aidle botnick
 if {[string tolower $nick] == [string tolower $botnick]} {
  foreach user [chanlist $chan] {
   if {$user == $botnick} {continue}
   mc:aidle:join $user [getchanhost $user $chan] [nick2hand $user] $chan
  };return
 }
 if {[matchattr $hand $mc_aidle(exempt) $chan]} {return}
 if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" [utimers]]} {
  foreach timer [utimers] {
   if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" $timer]} {
    killutimer [lindex $timer 2];break
   }
  }
 }
 foreach info [channel info $chan] {
  if {[lindex $info 0] != "mc.antiidle"} {continue}
  if {![lindex $info 1]} {return}
  utimer [lindex $info 1] "mc:aidle:inter:idlelimit [split $nick] [split $chan]"
  break
 }
}

bind pubm - * mc:aidle:pubm
proc mc:aidle:pubm {nick uhost hand chan args} {
 mc:aidle:inter:text $nick $hand $chan [join $args]
}

bind notc - * mc:aidle:notc
proc mc:aidle:notc {nick uhost hand text dest} {
 global botnick
 if {[string tolower $dest] != [string tolower $botnick]} {
  mc:aidle:inter:text $nick $hand $dest "{$text}"
 }
}

catch {unbind raw - privmsg mc:aidle:raw:privmsg}
bind raw - PRIVMSG mc:aidle:raw:privmsg
proc mc:aidle:raw:privmsg {from key args} {
 global botnick
 set nick [lindex [split $from !] 0]
 set hand [nick2hand $nick]
 set args [join $args]
 set dest [lindex [mc:ai:filt $args] 0]
 if {[string tolower $dest] == [string tolower $botnick]} {return 0}
 set args [join [string range [lrange [mc:ai:filt $args] 1 e] 1 e]]
 if {([string index $args 0] == "") &&
     ([string index $args [expr [string length $args]-1]] == "")} {
  mc:aidle:inter:text $nick $hand $dest "[string range $args 1 [expr [string length $args]-2]]"
 };return 0
}

proc mc:aidle:inter:text {nick hand chan args} {
 global mc_aidle botnick
 if {[string tolower $nick] == [string tolower $botnick]} {return}
 if {[matchattr $hand $mc_aidle(exempt) $chan]} {return}
 set args [join $args]
 if {$mc_aidle(strip)} {set argz [mc:aidle:inter:strip-all $args]} {set argz $args}
 foreach rbreak [split $mc_aidle(rbreak) \n] {
  if {[join $rbreak] == ""} {continue}
  if {[string match [string tolower [string trim $rbreak]] [string tolower $argz]]} {return}
 }
 if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" [utimers]]} {
  foreach timer [utimers] {
   if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" $timer]} {
    killutimer [lindex $timer 2];break
   }
  }
 }
 foreach info [channel info $chan] {
  if {[lindex $info 0] != "mc.antiidle"} {continue}
  if {![lindex $info 1]} {return}
  utimer [lindex $info 1] "mc:aidle:inter:idlelimit [split $nick] [split $chan]"
  break
 }
}

bind nick - * mc:aidle:nick
proc mc:aidle:nick {nick uhost hand chan nnick} {
 global mc_aidle botnick
 if {[string tolower $nnick] == [string tolower $botnick]} {return}
 if {[matchattr $hand $mc_aidle(exempt) $chan]} {return}
 if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" [utimers]]} {
  foreach timer [utimers] {
   if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" $timer]} {
    set utimer [lindex $timer 0];killutimer [lindex $timer 2];break
   }
  }
 }
 foreach info [channel info $chan] {
  if {[lindex $info 0] != "mc.antiidle"} {continue}
  if {![lindex $info 1]} {return}
  if {![info exists utimer]} {set utimer [lindex $info 1]}
  utimer $utimer "mc:aidle:inter:idlelimit [split $nnick] [split $chan]"
  break
 }
}


bind topc - * mc:aidle:topc
proc mc:aidle:topc {nick uhost hand chan topic} {
 global mc_aidle botnick
 if {[string tolower $nick] == [string tolower $botnick]} {return}
 if {!$mc_aidle(tpreset)} {return}
 if {[matchattr $hand $mc_aidle(exempt) $chan]} {return}
 if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" [utimers]]} {
  foreach timer [utimers] {
   if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" $timer]} {
    killutimer [lindex $timer 2];break
   }
  }
 }
 foreach info [channel info $chan] {
  if {[lindex $info 0] != "mc.antiidle"} {continue}
  if {![lindex $info 1]} {return}
  utimer [lindex $info 1] "mc:aidle:inter:idlelimit [split $nick] [split $chan]"
  break
 }
}

bind mode - * mc:aidle:mode
proc mc:aidle:mode {nick uhost hand chan mc vict} {
 global mc_aidle botnick
 if {[string tolower $nick] == [string tolower $botnick]} {return}
 if {!$mc_aidle(mcreset)} {return}
 if {[matchattr $hand $mc_aidle(exempt) $chan]} {return}
 if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" [utimers]]} {
  foreach timer [utimers] {
   if {[string match "*mc:aidle:inter:idlelimit $nick $chan*" $timer]} {
    killutimer [lindex $timer 2];break
   }
  }
 }
 foreach info [channel info $chan] {
  if {[lindex $info 0] != "mc.antiidle"} {continue}
  if {![lindex $info 1]} {return}
  utimer [lindex $info 1] "mc:aidle:inter:idlelimit [split $nick] [split $chan]"
  break
 }
}

proc mc:aidle:inter:idlelimit {nick chan} {
 global mc_aidle
 if {![onchan $nick $chan]} {return} {set onchan 1}
 if {[matchattr [nick2hand $nick] $mc_aidle(exempt) $chan]} {return}
 if {$mc_aidle(mc:method) != ""} {
  set mc_aidle(mc:method) [mc:aidle:inter:replace $mc_aidle(mc:method) "b {}"]
  set x [string length [join [split $mc_aidle(mc:method) +-] ""]]
  set temp ""
  for {set i 0} {$i < $x} {incr i 1} {set temp "$temp $nick"}
  putserv "MODE $chan $mc_aidle(mc:method) $temp"
 }
 set uhost [getchanhost $nick $chan]
 set hand [nick2hand $nick]
 set ban [mc:aidle:inter:masktype $nick!$uhost $mc_aidle(banmask)]
 set kmsg [mc:aidle:inter:replace $mc_aidle(kmessage) "%nick $nick %chan $chan"]
 switch -- $mc_aidle(kb:method) {
  1 {putkick $chan $nick $kmsg;set onchan 0}
  2 {
   if {!$mc_aidle(kb:time)} {pushmode $chan +b $ban} {
    newchanban $chan $ban mc.antiidle $kmsg $mc_aidle(kb:time)
   };set onchan 0
  }
  3 {
   if {!$mc_aidle(kb:time)} {pushmode $chan +b $ban} {
    newchanban $chan $ban mc.antiidle $kmsg $mc_aidle(kb:time)
   };putkick $chan $nick $kmsg;set onchan 0
  }
 }
 if {$mc_aidle(message) != ""} {
  set msg [mc:aidle:inter:replace $mc_aidle(message) "%nick $nick %chan $chan"]
  puthelp "PRIVMSG $nick :$msg"
 };if {$onchan} {mc:aidle:join $nick $uhost $hand $chan}
}

proc mc:aidle:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

proc mc:aidle:inter:masktype {uhost type} {
 if {![string match "*!*@*.*" $uhost]} {
  set nick [lindex [split $uhost "!"] 0]
  if {$nick == ""} {
   set uhost [string range $uhost [expr [string first ! $uhost]+1] e]
   foreach chan [channels] {
    set nick [lindex [findchanuser *$uhost* $chan] 0]
    if {$nick != ""} {break}
   }
   if {$nick == ""} {set uhost $nick!} {set uhost "$nick![gethost $nick]"}
  }
  if {$uhost == "$nick!" || $nothing} {set type "return_nothing"}
 }
 switch -exact $type {
  0 {set ban "*[string range $uhost [string first ! $uhost] e]"}
  1 {set ban "*!*[string trimleft [string range $uhost [expr [string first ! $uhost]+1] e] "~"]"}
  2 {set ban "*!*[string range $uhost [string first @ $uhost] e]"}
  3 {
   set ident [string range $uhost [expr [string first ! $uhost]+1] [expr [string last @ $uhost]-1]]
   set ban "*!*[string trimleft $ident "~"][string range [maskhost $uhost] [string first @ [maskhost $uhost]] e]"
  }
  4 {set ban "*!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"}
  5 {set ban $uhost}
  6 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range $uhost [string last "@" $uhost] e]"
  }
  7 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range $uhost [string last "@" $uhost] e]"
  }
  8 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  9 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  10 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!$ident$host"
   } {set ban [masktype $uhost 0]}
  }
  11 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!*[string trimleft $ident "~"]$host"
   } {set ban [masktype $uhost 1]}
  }
  12 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ban "*!*$host"
   } {set ban [masktype $uhost 2]}
  }
  13 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 11]} {set ban [masktype $uhost 3]}
  }
  14 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 12]} {set ban [masktype $uhost 4]}
  }
  15 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest [string range $uhost 0 [expr [string last "@" $uhost]-1]]
    set ban $rest$host
   } {set ban [masktype $uhost 5]}
  }
  16 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*[string trimleft [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]] "~"]"
    set ban $rest$host
   } {set ban [masktype $uhost 6]}
  }
  17 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*"
    set ban $rest$host 
   } {set ban [masktype $uhost 7]}
  }
  18 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 16]} {set ban [masktype $uhost 8]}
  }
  19 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 17]} {set ban [masktype $uhost 9]}
  }
  return_nothing {set ban ""}
  default {set ban "*!*[string range $uhost [string first "@" $uhost] e]"}
 }
 set _nick [lindex [split $ban !] 0]
 set _ident [string range $ban [expr [string first ! $ban]+1] [expr [string last @ $ban]-1]]
 set _host [string range $ban [expr [string last @ $ban]+1] e]
 if {$_ident != [set temp [string range $_ident [expr [string length $_ident]-9] e]]} {
  set _ident *[string trimleft $temp *]
 }
 if {$_host != [set temp [string range $_host [expr [string length $_host]-63] e]]} {
  set _host *[string trimleft $temp *]
 } ; return $_nick!$_ident@$_host
}

proc findip {args} {
 catch {unset mc_found_ip}
 if {![string match *.*.*.* $args]} {return 0}
 foreach arg $args {
  if {[string match *.*.*.* $arg]} {
   set mc_testa [split $arg "."] ; set i 0
   while {[llength $mc_testa] != $i} {
    set mc_test [lrange $mc_testa $i end]
    if {[string length [lindex $mc_test 1]]<4 && [string length [lindex $mc_test 2]]<4} {
     if {[lindex $mc_test 1] < 256 && [lindex $mc_test 2] < 256 && [lindex $mc_test 1] >= 0 && [lindex $mc_test 2] >= 0} {
      set first "abcdefghi"
      if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] >= 0} {
       set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1] end]
       if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] >= 0} {
        set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2] end]
        if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] >= 0} {
         set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3] end]
        }
       }
      }
      set second [lindex $mc_test 1] ; set third [lindex $mc_test 2] ; set fourth "abcdefghi"
      if {[string index [lindex $mc_test 3] 0] <= 9 && [string index [lindex $mc_test 3] 0] >= 0} {
       set fourth [string index [lindex $mc_test 3] 0]
       if {[string index [lindex $mc_test 3] 1] <= 9 && [string index [lindex $mc_test 3] 1] >= 0} {
        set fourth $fourth[string index [lindex $mc_test 3] 1]
        if {[string index [lindex $mc_test 3] 2] <= 9 && [string index [lindex $mc_test 3] 2] >= 0} {
         set fourth $fourth[string index [lindex $mc_test 3] 2]
        }
       }
      }
      if {($first < 256) && ($second < 256) && ($third < 256) &&
          ($fourth < 256) && ($first > 0) && ($second > 0) &&
          ($third > 0) && ($fourth > 0) && ([string index $first 0] > 0) &&
          ([string index $second 0] > 0) && ([string index $third 0] > 0) &&
          ([string index $fourth 0] > 0)} {
       if {[info exists mc_found_ip]} {
        set mc_found_ip "$mc_found_ip $first.$second.$third.$fourth"
       } {set mc_found_ip $first.$second.$third.$fourth}
      }
     }
    } ; incr i +1
   }
  }
 } ; if {[info exists mc_found_ip]} {return $mc_found_ip} {return 0}
}

proc mc:aidle:inter:strip-color {ar} {
 set argument ""
 if {![string match ** $ar]} {return $ar} ; set i -1 ; set length [string length $ar]
 while {$i < $length} {
  if {[string index $ar $i] == ""} {
   set wind 1 ; set pos [expr $i+1]
   while {$wind < 3} {
    if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
     incr wind 1 ; incr pos 1} {set wind 3
    }
   }
   if {[string index $ar $pos] == "," && [string index $ar [expr $pos + 1]] <= 9 &&
       [string index $ar [expr $pos + 1]] >= 0} {
    set wind 1 ; incr pos 1
    while {$wind < 3} {
     if {[string index $ar $pos] <= 9 && [string index $ar $pos] >= 0} {
      incr wind 1 ; incr pos 1} {set wind 3
     }
    }
   }
   if {$i == 0} { 
    set ar [string range $ar $pos end] 
    set length [string length $ar] 
   } { 
    set ar "[string range $ar 0 [expr $i - 1]][string range $ar $pos end]" 
    set length [string length $ar] 
   }
   set argument "$argument[string index $ar $i]"
  } {incr i 1}
 }
 set argument $ar
 return $argument
}

proc mc:aidle:inter:strip-bold {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:aidle:inter:strip-uline {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:aidle:inter:strip-reverse {ar} {
 set argument ""
 if {[string match ** $ar]} {
  set i 0
  while {$i <= [string length $ar]} { 
   if {![string match  [string index $ar $i]]} { 
    set argument "$argument[string index $ar $i]"
   } ; incr i 1
  }
 } {set argument $ar}
 return $argument
}

proc mc:aidle:inter:strip-all {ar} {
 return [mc:aidle:inter:strip-reverse [mc:aidle:inter:strip-uline [mc:aidle:inter:strip-bold [mc:aidle:inter:strip-color $ar]]]]
}

proc mc:ai:filt {data} {
 regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
 regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

proc mc:ai:unfilt {data} {
 regsub -all -- \\\\\\\\ $data \\ data
 regsub -all -- \\\\\\\[ $data \[ data
 regsub -all -- \\\\\\\] $data \] data
 regsub -all -- \\\\\} $data \} data
 regsub -all -- \\\\\{ $data \{ data
 regsub -all -- \\\\\" $data \" data
 return $data
}

if {$mc_aidle(svs:enabled)} {
 if {($mc_aidle(svs:check) > "23") || ($mc_aidle(svs:check) < "0")} {set mc_aidle(svs:check) 00}
 if {[string length $mc_aidle(svs:check)] == "1"} {set mc_aidle(svs:check) 0$mc_aidle(svs:check)}
 if {$mc_aidle(svs:stableonly)} {
  set mc_aidle(svs:script) [string range $mc_aidle(svs:script) 0 [expr [string length $mc_aidle(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_aidle(svs:oldcheck) * * *" mc:aidle:svs:time}
 set mc_aidle(svs:oldcheck) $mc_aidle(svs:check)
 bind time - "00 $mc_aidle(svs:check) * * *" mc:aidle:svs:time
 proc mc:aidle:svs:time {min hour day month year} {
  global mc_aidle
  catch {control [connect [lindex $mc_aidle(svs:server) 0] [lindex $mc_aidle(svs:server) 1]] mc:aidle:svs:interface}
 }
}
proc mc:aidle:svs:interface {idx args} {
 global mc_aidle;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_aidle(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_aidle(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_aidle(svs:script) 1]} {
    set note [mc:aidle:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:aidle:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:aidle:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_aidle(version)}"]
    set note [mc:aidle:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:aidle:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:aidle:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:aidle:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_aidle(svs:notify) ",;"]] {
     set outnote [mc:aidle:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_aidle(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_aidle(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:aidle:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Anti Idle $mc_aidle(version) by MC_8 loaded." 
