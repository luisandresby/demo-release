#!/bin/bash

function abort {
    local message="$1"
    echo "$message"
    exit 0
}