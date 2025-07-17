# Build and Test Attempt

A Swift test run was attempted in `repos/fountainai` using `swift test -v`. The build started but produced type errors related to the `socket` calls:

```
initializer 'init(_:)' requires that '__socket_type' conform to 'BinaryFloatingPoint'
```

This indicates the constants `AF_INET` and `SOCK_STREAM` need to be explicitly cast to `Int32` when calling `socket()` on Linux. After patching `main.swift` files to use `Int32(AF_INET)` and `Int32(SOCK_STREAM)`, the build could not fully complete due to environment resource limits.

