# Beta version, to be v2.0
##
# Anti Idle v1.1.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# If a user is caught idle'n too long, you can do any number of things
# settable by this script.  For instance:
#   - If an op is idle too long, you can deop him/ her.  No reason to have an
#     AFK op opped -- seems like a secure idea, gotta be pretty paranoid though
#     *grin*.
#   - Or maybe your running a warez channel and all your servers are specified
#     by +v, if idle (no FTP post) within x min's then -v that user.
#   - And yea, of course the traditional kick and/ or ban if someone is idle.
#   - Etc, etc ... configure to how you want your channel ran.
#
# Why not just use 'kick-idle' that's part of core eggdrop, you may ask.  Well
# in addition to the many settable options as explained above, you can also set # what will reset the idle timer.  Such as 'don't reset there idle if they
# change the topic', or 'don't reset a user's idle timer if he/ she says "bla"
# in his/ her action".  There are more than just topic and wild card public
# criteria's, see settings below.
##

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v1.1.1 (06.07.02)
#  MC_8      - - Removed 'scan''s for finding ident and host from uhost.  Using
#                split to find proper values -- more accurate.
#  MC_8      - - Removed an 'array unset' and replaced it with catch {unset
#                ...}, this would cause problems with pre TCL 8.3.
#  MC_8      - - Wasn't activating an idle timestamp if one not already found.
#  MC_8      - - Bugzilla bug #41.
#  MC_8      - - Added error catching system, gives a good debug for bug
#                reports.
#  MC_8      - - I evedently had an anti idle script out there, both
#                equally functional.  But after looking everything
#                over, I decided I like this format better.  Closing my
#                old mc.antiidle.tcl for good, using this version
#                instead.
#  MC_8      - - Changed the scripts name from 'Idle DeMode' to 'Anti
#                Idle', carring the version over.
#  MC_8      - - Added SVS v2.0.
#  MC_8      - - Veriables added: mc_aa(active), mc_aa(exempt:flag),
#                mc_aa(exempt:voice), mc_aa(message), mc_aa(exempt:op),
#                mc_aa(mode), mc_aa(limit:reset:mode),
#                mc_aa(limit:reset:topic), mc_aa(limit:reset:nick),
#                mc_aa(limit:reset:kick), mc_aa(limit:reset:pub),
#                mc_aa(strip), mc_aa(kick), mc_aa(ban), mc_aa(banmask).
#  MC_8      - - Veriables removed: mc_aa(exempt), mc_aa(devoice),
#                mc_aa(deop_msg), mc_aa(devoice_msg), mc_aa(deop),
#                mc_aa(chan), mc_aa(idle), mc_aa(freq).
#  MC_8      - - Updated the replace procedure.
#  MC_8      - - Added chanset channel int 'mc.antiidle'.
#  MaSsKilla - - Fixed issue with exempt.
#
# v1.1 (08.14.00)
#  MC_8 - Buffers - Added devoice and deop message.
#  MC_8 -         - Added ability to have all channels by setting
#                   mc_aa(chan) to "".
#  MC_8 - Buffers - The bot was deop'n it's self, fixed.
#
# v1.0 (01-28-00)
#  MC_8 - Matt - inital release.
##

##
# COMMANDS (dcc)
##
# chanset <#channel> mc.antiidle <number>
#   This is used to set the maximum idle time, in min.s for the
#   specified channel.  Setting the number to '0' (zero), the default,
#   will disable the script for that specific channel.
##

##
# SETTINGS
##

# [0=no/1=yes] Upon a user reaching his/her maximum idle time, what
# flag changes do you want to take place?  Set this to "" to disable
# this function.
# Replacment veriables:
#   %nick = IRC nickname of the user thats in violation of idle.
#  %ident = Ident of the user thats in violation of idle.
#   %host = Hostname of the user thats in violation of idle.
set mc_aa(mode) "-ov %user %user"

# What do you want the kick message to say, when kicking a user for
# being in violation of idle.  Set this to "" to disable kicking.
# Replacment veriables:
#   %channel = The channel in which the user is in.
#      %nick = IRC nickname of the user thats in violation of idle.
#     %ident = Ident of the user thats in violation of idle.
#      %host = Hostname of the user thats in violation of idle.
#      %idle = The max. idle time the user exceeded.
set mc_aa(kick) "You have been idle'n in an excess of %idle min's."

# How long, in min.s, do you want to ban the user in violation?
# Set this to "-1" to have the ban as a server ban, and not a ban
# in the bot's banlist.  Set this to "0" to disable this function.
# If you want the ban to be a sticky ban, and the value is 1 or
# greater, then append the value with an ! (exclimation point).
# Example:  set mc_aa(ban) "20!"    ;# This is a 20 min. sticky ban.
set mc_aa(ban) "1"

# If you have chosen to ban the user in violation of idle, the above
# setting, then how do you want to mask the ban?
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
#     You can also specify a type of 10 to 19 which correspond to masks
#     0 to 9.  But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of
#                  the host.domain, it replaces the numbers in the
#                  host.domain with a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_aa(banmask) 3

# What message do you want to give to the user upon finding him/her
# exceeding maximum idle time?
# The first word should be the message type, such as NOTICE
# or PRIVMSG.  Set this to "" to disable this function.
# Replacment veriables:
#   %channel = The channel in which the user is in.
#      %nick = IRC nickname of the user thats in violation of idle.
#     %ident = Ident of the user thats in violation of idle.
#      %host = Hostname of the user thats in violation of idle.
#      %idle = The max. idle time the user exceeded.
set mc_aa(message) "PRIVMSG You have been idle'n in an excess of %idle min's."

# Which users should the script evaluate?  Hint, if your using this
# script to devoice users that are in violation of idle... then
# you do not want to set this to 4 (everyone)... you should set it
# to 2 (voices).
#  1= Ops
#  2= Voices
#  3= Ops and voices
#  4= Everyone
set mc_aa(active) 3

# [0=no/1=yes] Do you want to reset the users idle time upon performing
# a nick change?
set mc_aa(limit:reset:nick) 1

# [0=no/1=yes] Do you want to reset the users idle time upon performing
# a kick?
set mc_aa(limit:reset:kick) 1

# [0=no/1=yes] Do you want to reset the users idle time upon performing
# mode changes?
# Ie.  User op's someone, or even set's the channel to +s.
set mc_aa(limit:reset:mode) 1

# [0=no/1=yes] Do you want to reset the users idle time upon performing
# topic change?
set mc_aa(limit:reset:topic) 1

# What public text (/msg's, /action's, /notice's and /ctcp's to the
# channel) should be exempt from the idle timer reset?  This is usefull
# for things like blocking anti idle scripts, witch is really just a
# timer on there client to say something once every so often.
#  Syntax: <type> <message>
#        valid type's are msg, action, notice, ctcp
# Wildcards accepted, seperate each string with a new line.
set mc_aa(limit:reset:pub) {
msg *ftp online*
action *ftp online*
* anti idle, don't ban me
ctcp mp3 *
}

# [0=no/1=yes] Do you want to strip color/bold/uline/reverse characters
# from public text before analysing it for the above setting,
# limit:reset:pub?
set mc_aa(strip) 1

# [0=no/1=yes] Do you want to exempt channel ops?
set mc_aa(exempt:op) 0

# [0=no/1=yes] Do you want to exempt channel voices?
set mc_aa(exempt:voice) 0

# What flagged users are exempt?
# Flag syntax: <global>|<channel>
set mc_aa(exempt:flag) "bmnt|mn"

## MC SVS (Script Version Service) v2.0 ##
# [0=no/1=yes] Do you want the bot to connection to MC_8's SVS to see
# if there are newer versions of this script avilable?  It will only
# tell you -- It's up to you to get the newest version (I decided not
# to auto update the code, there may be new features in the newest
# script that may require your attention).
set mc_aa(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_aa(svs:check) 0   ;#This is at Midnight
#  set mc_aa(svs:check) 5   ;#This is at 5am
#  set mc_aa(svs:check) 13  ;#This is at 1pm
#  set mc_aa(svs:check) 23  ;#This is at 11pm
set mc_aa(svs:check) 3

# Upon finding a newer version of this script, who do you want this
# script to send a note to telling them of this newer version?
# If more than 1 user is to be notified, seperate each user with a
# ' ' (space).
set mc_aa(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or
# just stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_aa(svs:stableonly) 0


##
# Edit no further, tcl coding below.
##

#Script:mc_aa

set mc_aa(script)      "Anti Idle"
set mc_aa(version)     "v1.1.1"
set mc_aa(svs:script)  "antiidle"
set mc_aa(svs:version) "001001001000"
set mc_aa(svs:server)  "mc.purehype.net"
set mc_aa(svs:port)    "81"
set mc_aa(svs:get)     "/"
set mc_aa(svs:query)   "svs=$mc_aa(svs:script)&version=$mc_aa(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_aa(script) $mc_aa(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_aa(script) $mc_aa(version)  will not work with eggdrop $version."
 putlog "$mc_aa(script) $mc_aa(version)  not loaded."
 return 1
}

setudef int mc.antiidle

proc mc:aa:error {bindproc error {arg ""}} {
 global mc_aa version lastbind
 putlog "Error in script $mc_aa(script) $mc_aa(version)."
 putlog "        Last bind: $lastbind"
 putlog "        Procedure: $bindproc"
 putlog "             Args: $arg"
 putlog "  Eggdrop version: $version"
 putlog "      TCL version: [info tclversion]               "
 putlog "*** Please tell MC_8 about this BUG!  Visit        "
 putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
 putlog "*** Please include the next line in the bug report."
 error $error
}

proc mc:aa:errchk {command arg} {
 if {[catch {eval $command $arg} return]} {
  mc:aa:error $command $return $arg; return 0
 }; return $return
}

bind time - * mc:aa:time
proc mc:aa:time {args} {
 return [mc:aa:errchk mc:aa:time_ [list $args]]
}
proc mc:aa:time_ {args} {
	global mc_aa botnick
	foreach channel [channels] {
		if {![set idle [mc:aa:chanint $channel mc.antiidle]]} {continue}
		foreach nick [chanlist $channel] {
			set hand [nick2hand $nick $channel]
			if {([matchattr $hand $mc_aa(exempt:flag) $channel]) ||
			    ([mc:aa:limit get $nick $channel] < $idle) ||
			    ([isbotnick $nick]) ||
			    (([isop $nick $channel]) && ($mc_aa(exempt:op))) ||
			    (([isvoice $nick $channel]) && ($mc_aa(exempt:voice))) ||
			    (($mc_aa(active) == "1") && (![isop $nick $channel])) ||
			    (($mc_aa(active) == "2") && (![isvoice $nick $channel])) ||
			    (($mc_aa(active) == "3") && ((![isop $nick $channel]) &&
			    (![isvoice $nick $channel])))} {continue}
			set action ""
			set uhost [getchanhost $nick $channel]
			set suhost [split $uhost @]
			set ident [join [lrange $suhost 0 [expr [llength $suhost]-2]] @]
			set host [lindex $suhost end]
			if {$mc_aa(mode) != ""} {
				set temp(mc) [mc:aa:replace $mc_aa(mode) [list %nick  $nick \
				                                               %ident $ident \
				                                               %host  $host]
				putserv "MODE $channel $temp(mc)]"
				lappend action "Mode change attempt ($temp(mc))"
			}
			if {$mc_aa(message) != ""} {
				set type [lindex [split $mc_aa(message) " "] 0]
				set message [join [lrange [split $mc_aa(message) " "] 1 end] " "]
				putserv "$type $nick :[mc:aa:replace $message [list %channel $channel \
				                                                    %nick    $nick \
				                                                    %ident   $ident \
				                                                    %host    $host \
				                                                    %idle    $idle]]"
				lappend action "${type}'d"
			}
			set ban [string trimright $mc_aa(ban) !]
			set banmask [mc:aa:masktype $nick!$ident@$host $mc_aa(banmask)]
			set temp(banned) 0
			if {$ban == "-1"} {
				putserv "MODE $channel +b $banmask"
				lappend action "Banned (server ban)"
				set temp(banned) 1
			} elseif {$ban > "0"} {
				set option none; set temp(action) ""
				if {[string match *! $mc_aa(ban)]} {
					set option sticky; set temp(action) ", sticky"
				}
				if {$mc_aa(kick) != ""} {set message $mc_aa(kick)} \
				elseif {$mc_aa(message) != ""} {set message $mc_aa(message)} \
				else {set message "Anti Idle"}
				set message [mc:aa:replace $message [list %channel $channel \
				                                          %nick    $nick \
				                                          %ident   $ident \
				                                          %host    $host \
				                                          %idle    $idle]]
				newchanban $channel $banmask "Anti Idle" $message $ban $option
				putserv "MODE $channel +b $banmask"
				set temp(dur) [duration [expr $ban*60]]
				lappend action "Banned (banlist, $temp(dur)$temp(action))"
				set temp(banned) 1
			}
			if {$mc_aa(kick) != ""} {
				putserv "KICK $channel $nick :[mc:aa:replace $mc_aa(kick) [list \
				         %channel $channel \
				         %nick    $nick \
				         %ident   $ident \
				         %host    $host \
				         %idle    $idle]]"
				if {!$temp(banned)} {lappend action "Kicked"}
			} elseif {$temp(banned)} {
				putserv "KICK $channel $nick :$mc_aa(script)"
			}
			set action [join $action ", "]
			putlog "$mc_aa(script): Found $nick over idle limit in $channel: $action"
		}
	}
}

bind join - * mc:aa:join
proc mc:aa:join {nick uhost hand chan} {mc:aa:limit set $nick join $chan}

bind part - * mc:aa:leave
bind sign - * mc:aa:leave
proc mc:aa:leave {nick uhost hand chan {msg ""}} {mc:aa:limit set $nick leave $chan}

bind kick - * mc:aa:kick
proc mc:aa:kick {nick uhost hand chan target reason} {
 mc:aa:limit set $nick kick $chan
 mc:aa:limit set $target leave $chan
}

bind nick - * mc:aa:nick
proc mc:aa:nick {nick uhost hand chan nnick} {mc:aa:limit set $nick nick $chan $nnick}

bind mode - * mc:aa:mode
proc mc:aa:mode {nick uhost hand chan mc vict} {mc:aa:limit set $nick mode $chan}

bind topc - * mc:aa:topc
proc mc:aa:topc {nick uhost hand chan topic} {mc:aa:limit set $nick topic $chan}

bind pubm - * mc:aa:pubm
proc mc:aa:pubm {nick uhost hand chan text} {mc:aa:limit set $nick msg $chan $text}

bind notc - * mc:aa:notc
proc mc:aa:notc {nick uhost hand text {dest ""}} {
 if {[validchan $dest]} {mc:aa:limit set $nick notice $dest $text}
}

bind raw - PRIVMSG mc:aa:raw:privmsg
proc mc:aa:raw:privmsg {from key arg} {
 return [mc:aa:errchk mc:aa:raw:privmsg_ [list $from key arg]]
}
proc mc:aa:raw:privmsg_ {from key arg} {
	set dest [lindex [split $arg] 0]
	set arg [string range [lindex [split $arg] 1] 1 end]
	if {(![validchan $dest]) ||
	    (![regexp -- "^\001(.*)\001\$" $arg dummy arg])} {return 0}
	set keyword [lindex [split $arg " "] 0]
	set arg [join [lrange [split $arg " "] 1 end] " "]
	set nick [lindex [split $from !] 0]
	set uhost [join [lrange [split $from !] 1 end] !]
	set suhost [split $uhost @]
	set ident [join [lrange $suhost 0 [expr [llength $suhost]-2]] @]
	set host [lindex $suhost end]
	if {[string tolower $keyword] == "action"} {
		mc:aa:limit set $nick action $chan $arg
	} else {mc:aa:limit set $nick ctcp $chan "$keyword $arg"}
	return 0
}

proc mc:aa:limit {do nick {method ""} {channel ""} {arg ""}} {
	return [mc:aa:errchk mc:aa:limit_ [list $do $nick $method $channel $arg]]
}
proc mc:aa:limit_ {do nick {method ""} {channel ""} {arg ""}} {
	global mc_aa botnick
	switch -- $do {
		"set" {
			if {[string tolower $nick] == [string tolower $botnick]} {
				if {$method == "join"} {
					foreach nick [chanlist $channel] {
						set array "!limit:[string tolower $nick]:[string tolower $channel]"
						set temp(expr) "[clock seconds]-([getchanidle $nick $channel]*60)"
						set mc_aa($array) [expr $temp(expr)]
					}
				} elseif {$method == "leave"} {
					catch {unset mc_aa(!limit:*:[string tolower $channel])}
				}
			} else {
				if {(($method == "mode") && ($mc_aa(limit:reset:mode))) ||
				    (($method == "topic") && ($mc_aa(limit:reset:topic))) ||
				    (($method == "kick") && ($mc_aa(limit:reset:kick))) ||
				     ($method == "join")} {
					set array "!limit:[string tolower $nick]:[string tolower $channel]"
					set mc_aa($array) [clock seconds]
				}
				if {$method == "nick"} {
					set temp [clock seconds]
					set array "!limit:[string tolower $nick]:[string tolower $channel]"
					if {!$mc_aa(limit:reset:nick)} {
						catch {set temp $mc_aa($array)}
					}
					catch {unset mc_aa($array)}
					set array "!limit:[string tolower $arg]:[string tolower $channel]"
					set mc_aa($array) $temp
				} elseif {$method == "leave"} {
					set array "!limit:[string tolower $nick]:[string tolower $channel]"
					catch {unset mc_aa($array)}
				} elseif {($method == "msg") || ($method == "action") ||
				          ($method == "notice") || ($method == "ctcp")} {
					set array "!limit:[string tolower $nick]:[string tolower $channel]"
					if {$mc_aa(strip)} {set arg [mc:aa:strip:all $arg]}
					foreach line [split [string tolower $mc_aa(limit:reset:pub)] \n] {
						if {$line == ""} {continue}
						set sline [split $line " "]
						set larg [string tolower $arg]
						if {([string match [lindex $sline 0] $method]) &&
						    ([string match [join [lrange $sline 1 end]] $larg])} {
							return
						}
						set mc_aa($array) [clock seconds]
					}
				}
			}
		}
		"get" {
			set channel $method
			set temp [clock seconds]
			set array "!limit:[string tolower $nick]:[string tolower $channel]"
			if {![info exists mc_aa($array)]} {
				set mc_aa($array) $temp
			} else {set temp $mc_aa($array)}
			set temp [expr ([clock seconds]-$temp)/60]
			return $temp
		}
	}
}

# v1.0
proc mc:aa:strip:all {text} {
 regsub -all -- {\002} $text "" text
 regsub -all -- {\003([0-9][0-9]?(,[0-9][0-9]?)?)?} $text "" text
 regsub -all -- {\026} $text "" text
 regsub -all -- {\037} $text "" text
 return $text
}

# v1.0
proc mc:aa:replace {text subs} {
 if {![catch {string map -nocase $subs $text} output]} {return $output}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $text [lindex $subs [expr $i+1]] text
 }; return $text
}

# v1.0
proc mc:aa:chanint {channel int} {
 if {![validchan $channel]} {return -code error "no such channel record"}
 set list [channel info $channel]
 for {set i 0} {![regexp -- {^[0-9]*:[0-9]*$} [lindex $list $i]]} {incr i} {}
 for {} {[regexp -- {^[0-9]*:[0-9]*$} [lindex $list $i]]} {incr i} {}
 set list [lrange $list $i end]
 foreach info [string tolower $list] {
  if {[lindex $info 0] == [string tolower $int]} {return [lindex $info 1]}
 };return -1
}

# v1.0
proc mc:aa:masktype {hostmask type} {
 set ident_max-length 9
 set host_max-length 63
 scan $hostmask {%[^!]!%[^@]@%s} nick ident host
 set maskhost 1
 if {[regexp -- {^1[0-9]$} $type]} {
  if {!([regexp -- {^([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)$} $host temp a b c d] && ($a > 0 && $a < 255 && $b < 255 && $c < 255 && $d < 255))} {
   regsub -all {[0-9]} $host "?" host
   set maskhost 0
  };set type [string index $type 1]
 }
 if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
 if {[regexp -- {^[2479]$} $type]} {set ident "*"}
 if {[regexp -- {^[1368]$} $type]} {set ident "*[string trimleft $ident ~]"}
 if {[regexp -- {^[3489]$} $type]} {if {$maskhost} {scan [maskhost $host] {%[^@]@%s} temp host}}
 if {[string length $ident] > ${ident_max-length}} {
  set ident "*[string range $ident [expr [string length $ident]-${ident_max-length}] end]"
 }
 if {[string length $host] > ${host_max-length}} {
  set host "*[string range $host [expr [string length $host]-${host_max-length}] end]"
 }; return [format "%s!%s@%s" $nick $ident $host]
}

## SVS v2.0
if {(![info exists mc_aa(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_aa(svs:enabled)])} {set mc_aa(svs:enabled) 0}
if {(![info exists mc_aa(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_aa(svs:check)])} {set mc_aa(svs:check) 0}
if {![info exists mc_aa(svs:notify)]} {set mc_aa(svs:notify) $owner}
if {(![info exists mc_aa(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_aa(svs:stableonly)])} {set mc_aa(svs:stableonly) 0}
foreach bind [binds mc:aa:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:aa:svs:time] {rename $command ""}
if {$mc_aa(svs:enabled)} {
 if {($mc_aa(svs:check) > "23") || ($mc_aa(svs:check) < "0")} {set mc_aa(svs:check) 00}
 if {[string length $mc_aa(svs:check)] == "1"} {set mc_aa(svs:check) 0$mc_aa(svs:check)}
 bind time - "00 $mc_aa(svs:check) *" mc:aa:svs:time
 proc mc:aa:svs:time {{args ""}} {
  global mc_aa
  if {[catch {socket -async $mc_aa(svs:server) $mc_aa(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_aa(svs:script)/$mc_aa(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:aa:svs:interface $sid timeout"]
  fileevent $sid readable "mc:aa:svs:interface $sid $tout"
  puts $sid "GET $mc_aa(svs:get)?$mc_aa(svs:query) HTTP/1.0\
           \nHost: $mc_aa(svs:server)\n"
  flush $sid
 }
}
proc mc:aa:svs:interface {sid tout} {
 global mc_aa
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_aa(svs:script)/$mc_aa(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_aa(svs:script)} {
     putlog "SVS Error\[$mc_aa(svs:script)/$mc_aa(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break
    }
    if {$mc_aa(svs:stableonly)} {
     set temp [string range $mc_aa(svs:version) 0 8]999
    } else {set temp [string range $mc_aa(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_aa(version) note
     foreach to [split $mc_aa(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_aa(svs:script)/$mc_aa(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_aa(svs:script)/$mc_aa(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_aa(script) $mc_aa(version) by MC_8 loaded."
