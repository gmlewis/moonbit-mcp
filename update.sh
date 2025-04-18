#!/bin/bash -ex
moon update && moon install && rm -rf target
moon add tonyfettes/uv
moon add peter-jerry-ye/async

moon fmt && moon info --target native
moon test --target native
# moon test --target all
