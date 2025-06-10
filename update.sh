#!/bin/bash -ex
moon update && moon install && rm -rf target
# moon add tonyfettes/uv - "error: Multiple conflicting versions were found for module tonyfettes/encoding: [Version { major: 0, minor: 3, patch: 1 }, Version { major: 0, minor: 1, patch: 0 }]"
moon add peter-jerry-ye/async

moon fmt && moon info --target native
moon test --target native
# moon test --target all
