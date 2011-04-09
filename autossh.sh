#!/usr/bin/expect --
#!/bin/sh
#
# autossh.sh
# SimpleSSHProxy
#
# Created by ivan on 10-9-10.
# http://twitter.com/ivan_wl
#
# This is another wheel of autossh built using expect.
# If you have to use ssh password authorizing,
# use this instead of autossh.
#
# WARNING: This script is NOT SAFE for your password,
# DON'T USE THIS IF YOU HAVE SECURITY CONCERNS!
#
# Usage: autossh.sh [foo] [foo] [bindingIP:port] [foo] [username] [remoteHost] [password]
# get arguments
set username [lrange $argv 0 0]
set remoteHost [lrange $argv 1 1]
set password [lrange $argv 2 2]

while (1) {
	set connectedFlag 0;
	spawn /usr/bin/ssh $username@$remoteHost;
	match_max 100000;
	set timeout 60;
	expect {
		"?sh: Error*" 
			{ puts "CONNECTION_ERROR"; exit; }
		"*yes/no*" 
			{ send "yes\r"; exp_continue; }
		"*?assword:*" {
			 send "$password\r"; set timeout 4;
			 expect "*?assword:*" { send "$password\r"; set timeout 4; }
			 set connectedFlag 1;
		}
		# if no password
		"*~*"
			{ send "echo hello\r"; set connectedFlag 1; }
	}
	if { $connectedFlag == 0 } { 
		close;
		puts "SSH server unavailable, retrying..."; 
		continue; 
	}

	while (1) {
		set conAliveFlag 0;
		interact {
			# time interval for checking connection
			timeout 600 {
				set timeout 30;
				send "echo hello\r";
				expect "*hello*" { set conAliveFlag 1; }
				if { $conAliveFlag == 1 } { 
					# connection is alive
					continue;
				} else { break; }
			}
		}
	}
	
	close;
	puts "SSH connection failed, restarting...";
}
