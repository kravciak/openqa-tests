# SUSE's openQA tests
#
# Copyright 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Test the ability to boot installed linux from cd with linuxrc.
# Maintainer: QA SLE YaST team <qa-sle-yast@suse.de>

use base "bootbasetest";
use strict;
use warnings;
use testapi;
use bootloader_setup qw(select_bootmenu_more ensure_shim_import);

sub run {
    my ($self) = @_;
    ensure_shim_import;
    select_bootmenu_more('inst-boot_linuxrc', 1);
    for (1 .. 3) {
        assert_screen("OK_button_linuxrc", 120);
        send_key "ret";
    }
    assert_screen "edit_kernel_options";
    send_key "ret";
    assert_screen "edit_kexec_options";
    send_key "ret";
    $self->{in_boot_desktop} = 1;
}


1;
