#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"


// #define NSLOTS SWAPBLOCKS/8

// struct swapslot {
//   uint start;
//   uint page_perm;
//   uint is_free;
//   pte_t* pte_id[NPROC];
//   uint* proc_id[NPROC];
// };

// struct swapslot swaparray[NSLOTS];