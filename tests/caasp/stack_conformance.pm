# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run CNCF K8s Conformance tests
#   Maintain certified status of CaaSP under k8s certification
#   Project: https://github.com/cncf/k8s-conformance
# Maintainer: Martin Kravec <mkravec@suse.com>

use parent 'caasp_controller';
use caasp_controller;

use strict;
use utils;
use testapi;
use caasp 'script_retry';
use version_utils 'is_caasp';

# Needed for QAM kubernetes tests
# https://github.com/cncf/k8s-conformance/pull/281
sub run_yaml {
    # CaaSP 2.0 has Kubernetes 1.8.9 which doesn't work with v1.10.0 testsuite
    my $branch = '6179d790e6bfc799afef5058ce50a2f314983fa2';

    # https://github.com/cncf/k8s-conformance/blob/6179d790e6bfc799afef5058ce50a2f314983fa2/instructions.md
    my $sb_yaml = "https://raw.githubusercontent.com/cncf/k8s-conformance/$branch/sonobuoy-conformance.yaml";
    my $sb_exit = '"no-exit was specified, sonobuoy is now blocking"';
    my $sb_pass = '"SUCCESS! -- [1-9][0-9]\+ Passed | 0 Failed | 0 Pending.*PASS"';
    my $sb_test = '"Test Suite Passed"';

    # Run conformance tests and wait 90 minutes for result
    assert_script_run "curl -L $sb_yaml | kubectl apply -f -";
    script_retry "kubectl -n sonobuoy logs sonobuoy | grep $sb_exit", retry => 90, delay => 60;

    # Results available at /tmp/sonobuoy/201801191307_sonobuoy_be1dbeae-f889-4735-9aa9-4cc04ad13cd5.tar.gz
    my $path = script_output "kubectl -n sonobuoy logs sonobuoy | grep -o 'Results.*tar.gz'  | cut -d' ' -f4";
    assert_script_run "kubectl cp sonobuoy/sonobuoy:$path sonobuoy.tgz";

    # Expect: SUCCESS! -- 123 Passed | 0 Failed | 0 Pending | 586 Skipped PASS
    script_run 'tar -xzf sonobuoy.tgz';
    upload_logs 'sonobuoy.tgz';
    upload_logs 'plugins/e2e/results/e2e.log';
    assert_script_run "tail -10 plugins/e2e/results/e2e.log | tee /dev/tty | grep $sb_pass";
    assert_script_run "tail -10 plugins/e2e/results/e2e.log | grep $sb_test";
}

# Requires kubernetes version 1.10.0 or newer
# https://github.com/cncf/k8s-conformance/blob/master/instructions.md
sub run_cli {
    assert_script_run 'wget https://github.com/heptio/sonobuoy/releases/download/v0.12.1/sonobuoy_0.12.1_linux_amd64.tar.gz';
    assert_script_run 'tar -xzf sonobuoy_0.12.1_linux_amd64.tar.gz';

    # Deploy a Sonobuoy pod to your cluster with:
    assert_script_run './sonobuoy run';

    # View actively running pods:
    assert_script_run './sonobuoy status';

    # To inspect the logs:
    assert_script_run './sonobuoy logs';

    # Once sonobuoy status shows the run as completed, copy the output directory from the main Sonobuoy pod to a local directory:
    # This copies a single .tar.gz snapshot from the Sonobuoy pod into your local . directory.
    assert_script_run './sonobuoy retrieve .';

    # Extract the contents into ./results with:
    assert_script_run 'mkdir ./results; tar xzf *.tar.gz -C ./results';

    # To clean up Kubernetes objects created by Sonobuoy, run:
    assert_script_run './sonobuoy delete';
}

sub run {
    switch_to 'xterm';

#    my kube_ver = script_output 'kubectl version --short=true | grep Server | cut -d: -f2 | tr -d "v "';
#    if (check_version('1.10.0+', qr/^(?:\d+\.?){3}$/, $kube_ver) {
    if (is_caasp '4.0+') {
        record_info 'Skipped';
        # run_cli;
    } else {
        run_yaml;
    }

    switch_to 'velum';
}

1;

