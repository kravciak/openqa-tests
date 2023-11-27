# SUSE's openQA tests
#
# Copyright 2009-2013 Bernhard M. Wiedemann
# Copyright 2012-2018 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Unlock encrypted partitions during bootup after the bootloader
#   passed, e.g. from plymouth
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use strict;
use warnings;
use base "installbasetest";
use utils;
use testapi qw(check_var get_var record_info);
use version_utils qw(is_leap is_sle is_leap_micro is_sle_micro is_alp);

sub run {
    # With newer grub2 (in TW and SLE 15SP6 currently), entering the passphrase in GRUB2
    # is enough. The key is passed on during boot, so it's not asked for
    # a second time.
    my $need_to_enter_passphrase = is_leap || is_sle('<15-sp6') || is_leap_micro || is_sle_micro || is_alp;
    return if is_boot_encrypted && !$need_to_enter_passphrase;

    unlock_if_encrypted(check_typed_password => 1);
}

1;
