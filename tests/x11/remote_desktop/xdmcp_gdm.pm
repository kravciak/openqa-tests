# Copyright 2017 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.
#
# Package: dhcp-client xorg-x11-server-extra
# Summary: Remote Login: XDMCP with gdm and GNOME session configured
# Maintainer: Grace Wang <grace.wang@suse.com>
# Tags: tc#1586203

use strict;
use warnings;
use base 'basetest';
use base 'x11test';
use testapi;
use lockapi;
use utils;
use version_utils 'is_sle';

sub run {
    my ($self) = @_;

    # Wait for supportserver if not yet ready
    mutex_lock 'dhcp';
    mutex_unlock 'dhcp';
    mutex_lock 'xdmcp';

    # Make sure the client gets the IP address and configure the firewall
    x11_start_program('xterm');
    become_root;
    assert_script_run 'dhclient';
    $self->configure_xdmcp_firewall;
    enter_cmd "exit";

    # Remote access SLES via Xephyr
    enter_cmd "Xephyr -query 10.0.2.1 -screen 1024x768+0+0 -terminate :1";
    assert_screen 'xdmcp-gdm', 90;
    send_key 'ret';
    assert_screen 'xdmcp-login-gdm';
    type_password;
    send_key 'ret';
    assert_screen 'xdmcp-gdm-generic-desktop';
    send_key 'alt-f4';    # Close Xephyr
    wait_still_screen 3;
    send_key 'alt-f4';    # Close xterm

    mutex_unlock 'xdmcp';
}

1;
