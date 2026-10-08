# julia-pcre-jit-mwe

Minimal reproducer for crashes in PCRE2's JIT allocator (`sljit_malloc_exec` / `sljit_free_exec` in `libpcre2-8.DLL`) when many `Regex` objects are created and finalized in Julia on Windows.

Run locally:

```
julia --startup-file=no mwe_regex.jl
```

Locally (Julia 1.13.1, Windows 11 build 26300) this fails in round 1 or 2 with `EXCEPTION_ACCESS_VIOLATION` or `ReadOnlyMemoryError()` in a `Regex` finalizer. Building the regex once outside the loop avoids the crash.

The GitHub Actions workflow runs the script on several OS / Julia version combinations.
