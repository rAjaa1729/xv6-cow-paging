# xv6 Copy-on-Write & Demand Paging

Extends [xv6](https://pdos.csail.mit.edu/6.828/2020/xv6.html) with copy-on-write `fork()` and a disk-backed swap system, so memory pages are shared instead of copied and processes can run even when physical memory is full.

## How it works

- **Page sharing** (`copyuvm`, `vm.c`) — `fork()` maps the child to the parent's physical pages instead of copying them, marking both read-only.
- **Reference counting** (`rmap`, `proc.c`) — a per-physical-page table tracks which page table entries point at it; updated on every map/unmap (fork, `sbrk`, exit, swap).
- **COW fault handling** (`handle_fage_fault`, `proc.c`) — on a write fault: if `rmap` shows a page has one owner, just make it writable; otherwise copy it and update the PTE.
- **Swap** — when `kalloc()` runs out of pages: pick a victim process (largest resident set size), pick a victim page in it via a clock/second-chance scan of the hardware accessed bit, write it to disk through the existing buffer cache, and mark its PTE as swapped. Swapping out or back in a page correctly updates every process that shares it, not just one.
- **RSS tracking** (`proc.rss`) threaded through alloc/dealloc/swap, exposed via `getrss`/`getNumFreePages` syscalls.

## Build & run

Needs an i386 cross-toolchain and QEMU/Bochs (see `Makefile`).

```bash
make
make qemu
```

Provided test programs: `testcow1`–`testcow3` (page-sharing/COW correctness) and `memtest1`–`memtest4` (allocation under memory pressure).

## Notes

`project.md` is the original assignment spec. `vm.h` contains an early, unused sketch of the swap data structure — the real one is in `proc.c`.
