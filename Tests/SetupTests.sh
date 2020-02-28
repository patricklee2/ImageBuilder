#!/bin/bash

function print_build_number()
{
    local BuildNumber=$1
    local File="BuildNumber.txt"
    rm -rf $File
    touch $File
    echo $BuildNumber > $File
}

print_build_number $1
