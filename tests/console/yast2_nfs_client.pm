# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use base "console_yasttest";
use testapi;

# Test "yast2 nfs-client" functionality
# Ensures that it works with the current version of nfs-client (it got broken
# with the conversion from init.d to systemd services)

sub run() {
    my $self = shift;

    #
    # Preparation
    #
    select_console 'root-console';
    # Make sure packages are installed
    assert_script_run 'zypper -n in yast2-nfs-client nfs-client nfs-kernel-server';
    # Prepare the test file structure
    assert_script_run 'mkdir -p /tmp/nfs/server';
    assert_script_run 'echo "It worked" > /tmp/nfs/server/file.txt';
    # Serve the share
    assert_script_run 'echo "/tmp/nfs/server *(ro)" >> /etc/exports';
    assert_script_run 'systemctl start nfs-server';

    #
    # YaST nfs-client execution
    #
    script_run '/sbin/yast2 nfs-client', 0;
    assert_screen 'yast2-nfs-client-shares';
    # Open the dialog to add a connection to the share
    send_key 'alt-a';
    assert_screen 'yast2-nfs-client-add';
    type_string 'localhost';
    # Explore the available shares and select the only available one
    send_key 'alt-e';
    assert_screen 'yast2-nfs-client-exported';
    send_key 'alt-o';
    # Set the local mount point
    send_key 'alt-m';
    type_string '/tmp/nfs/client';
    # Save the new connection and close YaST
    send_key 'alt-o';
    send_key 'alt-o';
    wait_idle;

    #
    # Check the result
    #
    script_run "cat /tmp/nfs/client/file.txt > /dev/$serialdev", 0;

    # Wait for more than 90 seconds due to NFSD's 90 second grace period.
    wait_serial('It worked', 100) || die "Reading from nfs failed.";
}

1;

# vim: set sw=4 et:
