# SUSE's openQA tests
#
# Copyright 2009-2013 Bernhard M. Wiedemann
# Copyright 2012-2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Package: Mesa-demo-x
# Summary: glxgears can start
# - Handle installing of Mesa-demo-x (if necessary)
# - Launch glxgears and check if it is running
# - Close glxgears
# Maintainer: QE Core <qe-core@suse.de>

use base "x11test";
use strict;
use warnings;
use testapi;

sub run {
    ensure_installed 'Mesa-demo-x';
    # 'no_wait' for screen check because glxgears will be always moving
    x11_start_program('glxgears', match_no_wait => 1);
    send_key 'alt-f4';
}

1;
