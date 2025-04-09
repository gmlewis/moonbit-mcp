#!/bin/bash -ex
moon update && moon install && rm -rf target
moon fmt && moon info --target native
moon test --target native
# moon test --target all
