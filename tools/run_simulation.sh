#!/bin/bash
#
# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Modified by MP to accept test_dir inside directory
#
# Description:
# This script runs simulations outside Vivado, making them faster.
# For usage details run the script with no arguments.
# For more information see: AMD Xilinx UG 900:
# https://docs.xilinx.com/r/en-US/ug900-vivado-logic-simulation/Simulating-in-Batch-or-Scripted-Mode-in-Vivado-Simulator
# To work properly, a git repository in the project directory is required.
# Run from the project root directory.

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function usage {
    echo "usage: $(basename "$0") [options]"
    echo "  options:"
    echo "    -l          list available tests"
    echo "    -t <test>   run the specified <test>"
    echo "    -g          show gui (use with -t)"
    echo "    -a          run all available tests (does not work with gui)"
    echo "    -d <dir>    run all tests inside a specific directory section"
    exit 1
}

function list_available_tests {
    find . -type f -name "*.prj" | sed 's|^\./||' | sed 's|/[^/]*$||'
    exit 0
}

function execute_test {
    # Remove untracked files
    git clean -fXd .

    mkdir -p build
    cd build

    test_path=$1
    test_name=$(basename "$test_path")
    PRJ_FILE=${ROOT_DIR}/sim/${test_path}/${test_name}.prj

    if [[ $(grep 'glbl.v' -oc  ${PRJ_FILE}) -gt 0 ]]; then
        COMPILE_GLBL='work.glbl'
    else
        COMPILE_GLBL=''
    fi

    XELAB_OPTS="work.${test_name}_tb
                ${COMPILE_GLBL}
                -snapshot ${test_name}_tb
                -prj ${PRJ_FILE}
                -timescale 1ns/1ps
                -L unisims_ver"

    # Run simulation
    if [[ ${show_gui} ]]; then
        xelab ${XELAB_OPTS} -debug typical
        xsim ${test_name}_tb -gui -t ${ROOT_DIR}/tools/sim_cmd.tcl
    else
        xelab ${XELAB_OPTS} -standalone -runall \
        | grep -ie '^\|fatal:\|error:\|critical\|warning:' --color=always
    fi

    cd ..
}

function run_all {
    # If target_dir is provided, limit search scope to that directory
    local search_path="."
    if [[ -n "$1" ]]; then
        search_path="./$1"
        if [[ ! -d "$search_path" ]]; then
            echo -e "\033[1;31mError: Directory 'sim/$1' does not exist.\033[0;39m"
            exit 1
        fi
        echo -e "\033[1;34m=== Running Simulations in Section: $1 ===\033[0;39m"
    fi

    for test in $(find "$search_path" -type f -name "*.prj" | sed 's|^\./||' | sed 's|/[^/]*$||'); do
        err_ctr=0
        echo -en "${test}:\t"
        err_ctr=$(execute_test ${test} | grep -oic 'error')
        if [ $err_ctr == 0 ]; then
            echo -e "\033[1;32m PASSED\033[0;39m"
        else
            echo -e "\033[1;31m FAILED\033[0;39m"
        fi
    done
    exit 0
}

if [[ $# -eq 0 ]]; then
    usage
fi

ROOT_DIR=$(pwd)
cd sim

# Added 'd:' to getopts string to accept the directory argument
while getopts aglrs:t:d: option; do
    case ${option} in
        g) show_gui=1;;
        l) list_available_tests;;
        t) test_name=${OPTARG};;
        a) run_all;;
        d) target_dir=${OPTARG};;
        *) usage;;
    esac
done

# If a specific directory section was requested, run all tests inside it
if [[ ${target_dir} ]]; then
    run_all "${target_dir}"
fi

if [[ ${test_name} ]]; then
    execute_test ${test_name}
fi