#!/bin/bash
source "$TESTSUITE_DIR"/test-scripts/utils/testsuite-utils.sh

before_test
install_client
install_service a 2
install_service b 2
execute_test

