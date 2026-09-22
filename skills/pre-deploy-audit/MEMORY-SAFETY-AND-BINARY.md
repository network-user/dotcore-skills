# Memory safety and binary hunting

## When to use

Используй для C/C++/Rust/Go native code, FFI, binary parser, image/archive parser,
kernel-facing code и unsafe memory operations.

## Классы

- bounds, integer overflow, lifetime/use-after-free, double free и data race;
- parser state confusion, length mismatch, decompression/recursion amplification;
- FFI ownership, pointer validation, type/ABI mismatch и unsafe transmute;
- privileged device/kernel boundary и untrusted local binary input.

## Validation rules

Свяжи controlled input, exact parser/operation и bounded memory/result. Crash
сам по себе не RCE. Для sanitizer/fuzzer используй только локальный fixture в
ограниченном sandbox и не продолжай после минимального доказательства.
