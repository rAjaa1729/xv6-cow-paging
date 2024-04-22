#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct
{
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

struct rmap_struct
{
  struct spinlock lock;
  uint refcount;
  pte_t *pte_id[NPROC];
  int present_id[NPROC];
};

struct rmap_struct rmap[PHYSTOP / PGSIZE];

#define NSLOTS SWAPBLOCKS / 8

struct swapslot
{
  uint start;
  uint page_perm;
  uint is_free;
  pte_t *pte_id[NPROC];
  struct proc *proc_id[NPROC];
  uint cnt;
};

struct swapslot swaparray[NSLOTS];

void initrmap()
{
  for (uint i = 0; i < (PHYSTOP / PGSIZE); i++)
  {
    rmap[i].refcount = 0;
    for (uint j = 0; j < NPROC; j++)
    {
      rmap[i].present_id[j] = 0;
    }
    initlock(&rmap[i].lock, "rmap");
  }
}

int check_rmap(uint pgnum)
{
  return (rmap[pgnum].refcount == 1);
}

void inc_sharing(pte_t *pte, uint page_num)
{
  
  if(page_num==73)cprintf("Increasing %d %d %d\n",pte,*pte,page_num);
  // acquire(&rmap[page_num].lock);
  rmap[page_num].refcount++;
  for (uint i = 0; i < NPROC; i++)
  {
    if (!rmap[page_num].present_id[i])
    {
      rmap[page_num].present_id[i] = 1;
      rmap[page_num].pte_id[i] = pte;
      // cprintf("Index %d\n",i);
      break;
    }
  }
  // release(&rmap[page_num].lock);
  // cprintf("Increased\n");
}

int dec_sharing(pte_t *pte, uint page_num)
{
  
  if(page_num==73)cprintf("Decreasing %d %d %d\n",pte,*pte,page_num);
  // acquire(&rmap[page_num].lock);
  rmap[page_num].refcount--;
  int found = 0;
  for (uint i = 0; i < NPROC; i++)
  {
    if (rmap[page_num].present_id[i] && rmap[page_num].pte_id[i] == pte)
    {
      found = 1;
      rmap[page_num].present_id[i] = 0;
      // cprintf("Index %d\n",i);
      break;
    }
  }
  if (!found)
  {
    panic("Trying to reduce refrence of page which is not refrenced");
  }
  // release(&rmap[page_num].lock);
  // cprintf("Decreased %d %d\n",pte,page_num);
  if (rmap[page_num].refcount == 0)
    return 1;
  else
    return 0;
}

void pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int cpuid()
{
  return mycpu() - cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu *
mycpu(void)
{
  int apicid, i;

  if (readeflags() & FL_IF)
    panic("mycpu called with interrupts enabled\n");

  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i)
  {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc *
myproc(void)
{
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

// PAGEBREAK: 32
//  Look in the process table for an UNUSED proc.
//  If found, change state to EMBRYO and initialize
//  state required to run in the kernel.
//  Otherwise return 0.
static struct proc *
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if (p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  release(&ptable.lock);

  // Allocate kernel stack.
  if ((p->kstack = kalloc()) == 0)
  {
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe *)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint *)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context *)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

// PAGEBREAK: 32
//  Set up first user process.
void userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();

  initproc = p;
  if ((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0; // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if (n > 0)
  {
    if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  else if (n < 0)
  {
    if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if ((np = allocproc()) == 0)
  {
    return -1;
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np)) == 0)
  {
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for (i = 0; i < NOFILE; i++)
    if (curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if (curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for (fd = 0; fd < NOFILE; fd++)
  {
    if (curproc->ofile[fd])
    {
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->parent == curproc)
    {
      p->parent = initproc;
      if (p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  // clean_proc_data(curproc->pgdir);
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->parent != curproc)
        continue;
      // cprintf("In wait child and parent %d %d\n", p->pid, curproc->pid);

      havekids = 1;
      if (p->state == ZOMBIE)
      {
        // cprintf("Child process is Zombie\n");
        // Found one.
        // release(&ptable.lock);
        // cprintf("Child process is Zombie2 %d\n",curproc->pid);
        // return 0;
        pid = p->pid;
        clean_proc_data(p->pgdir);
        kfree(p->kstack);
        p->kstack = 0;
        // cprintf("In wait proc id %d\n", p->pid);
        freevm2(p->pgdir,p);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        // cprintf("In the end of release wait %d\n", pid);
        release(&ptable.lock);
        // return pid;
        // cprintf("In the end of wait %d\n", pid);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
    {
      release(&ptable.lock);
      return -1;
    }
    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); // DOC: wait-sleep
  }
}

// Print the resident size of all the current procs
void print_rss()
{
  struct proc *p = 0;
  cprintf("PrintingRSS\n");
  acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if ((p->state == UNUSED))
      continue;
    cprintf("((P)) id: %d, state: %d, rss: %d\n", p->pid, p->state, p->rss);
  }
  release(&ptable.lock);
}

// PAGEBREAK: 42
//  Per-CPU process scheduler.
//  Each CPU calls scheduler() after setting itself up.
//  Scheduler never returns.  It loops, doing:
//   - choose a process to run
//   - swtch to start running that process
//   - eventually that process transfers control
//       via swtch back to the scheduler.
void scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for (;;)
  {
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;
      // if(p->pid == 3)
      // cprintf("IN scheduler %d\n",p->pid);
      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{

  int intena;
  struct proc *p = myproc();

  if (!holding(&ptable.lock))
    panic("sched ptable.lock");
  if (mycpu()->ncli != 1)
    panic("sched locks");
  if (p->state == RUNNING)
    panic("sched running");
  if (readeflags() & FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  // cprintf("In sched\n");
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void yield(void)
{
  acquire(&ptable.lock); // DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first)
  {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  if (p == 0)
    panic("sleep");

  if (lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if (lk != &ptable.lock)
  {                        // DOC: sleeplock0
    acquire(&ptable.lock); // DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if (lk != &ptable.lock)
  { // DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if (p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->pid == pid)
    {
      p->killed = 1;
      // Wake process from sleep if necessary.
      if (p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
  static char *states[] = {
      [UNUSED] "unused",
      [EMBRYO] "embryo",
      [SLEEPING] "sleep ",
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if (p->state == SLEEPING)
    {
      getcallerpcs((uint *)p->context->ebp + 2, pc);
      for (i = 0; i < 10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

struct proc *
select_victim_process(void)
{
  // print_rss();
  int maximum = -1;
  struct proc *p;
  struct proc *victim_proc;
  victim_proc = myproc();
  maximum = victim_proc->rss;
  int id = victim_proc->pid;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if (maximum < p->rss)
    {
      maximum = p->rss;
      victim_proc = p;
      id = p->pid;
    }
    else if (maximum == p->rss)
    {
      if (p->pid < id)
      {
        victim_proc = p;
        id = p->pid;
      }
    }
  }
  // release(&ptable.lock);
  return victim_proc;
}

static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if (*pde & PTE_P)
  {
    pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
  }
  else
  {
    if (!alloc || (pgtab = (pte_t *)kalloc()) == 0)
      return 0;
    memset(pgtab, 0, PGSIZE);
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

void find_pte_swap_out(struct proc *p, pte_t *pte_orig, int idx)
{
  uint sz = p->sz;
  pde_t *pgdir = p->pgdir;
  pte_t *pte;
  uint i;
  // uint pa = PTE_ADDR(*pte_orig);
  for (i = 0; i < sz; i += PGSIZE)
  {
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("find_pte_swap_out: pte should exist");
    if (*pte == *pte_orig)
    {
      // *pte = ((idx << 12) | PTE_S);
      swaparray[idx].proc_id[swaparray[idx].cnt] = p;
      swaparray[idx].pte_id[swaparray[idx].cnt] = pte;
      swaparray[idx].cnt += 1;
      p->rss -= PGSIZE;
      if(PTE_ADDR(*pte) / PGSIZE == 73) cprintf("In swap out %d %d\n",pte,*pte);
      dec_sharing(pte, PTE_ADDR(*pte) / PGSIZE);
      return;
    }
  }
}

void find_pte_swap_in(struct proc *p, pte_t *pte_orig, char *mem)
{
  uint sz = p->sz;
  pde_t *pgdir = p->pgdir;
  pte_t *pte;
  // uint pa = V2P(mem);
  uint i;
  for (i = 0; i < sz; i += PGSIZE)
  {
    if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("find_pte_swap_in: pte should exist");
    if (*pte == *pte_orig)
    {
      p->rss += PGSIZE;
      inc_sharing(pte, V2P(mem) / PGSIZE);
      return;
    }
  }
}

void make_other_pte_swapped_out(pte_t *pte, int idx)
{
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    if ((p->state == UNUSED)) continue;
    find_pte_swap_out(p, pte, idx);
    
  }
  // release(&ptable.lock);
}

void make_other_pte_swapped_in(pte_t *pte, char *mem)
{
  // struct proc *p;
  // uint pa = PTE_ADDR(*pte);
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    // if (!(p->state & UNUSED))
    {
      find_pte_swap_in(p, pte, mem);
    }
  }
  // release(&ptable.lock);
}

uint xint(uint x)
{
  uint y;
  uchar *a = (uchar *)&y;
  a[0] = x;
  a[1] = x >> 8;
  a[2] = x >> 16;
  a[3] = x >> 24;
  return y;
}

void initswap()
{
  int j = 0;
  for (int i = 0; i < SWAPBLOCKS; i += 8)
  {
    swaparray[j].is_free = 1;
    swaparray[j].start = xint(2) + i;
    swaparray[j].cnt = 0;
    j += 1;
  }
}

void make_acces_bit_0(pte_t* pte_orig){
  struct proc *p;
  // acquire(&ptable.lock);
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    // if (p->state == UNUSED) continue
     uint sz = p->sz;
    pde_t *pgdir = p->pgdir;
    pte_t *pte;
    uint i;
    for (i = 0; i < sz; i += PGSIZE)
    {
      if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
        panic("find_pte_swap_in: pte should exist");
      if (*pte == *pte_orig){
        *pte &= ~PTE_A;
      }
    
    }
  }
}


pte_t *select_a_victim()
{
  // check for p->rss should be positive
  struct proc *p = select_victim_process();
  int total = 0;
  // cprintf("Proc id %d\n",p->pid);
  for (int i = 0; i < p->sz; i += PGSIZE)
  {
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
    if (*pte & PTE_P)
    {
      if (!(*pte & PTE_A))
      {

        if (p->rss < PGSIZE)
          continue;

        // p->rss -= PGSIZE;
        // cprintf("total before %d\n",total);
        return pte;
      }
      else
        total += 1;
    }
  }
  // cprintf("total %d\n",total);
  total = (total + 9) / 10;
  int cnt = 0;
  for (int i = 0; i < p->sz; i += PGSIZE)
  {
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
    if (*pte & PTE_P)
    {
      if (*pte & PTE_A)
      {
        // *pte &= ~PTE_A;
        make_acces_bit_0(pte);
        cnt += 1;
      }
    }
    if (cnt >= total)
      break;
  }

  for (int i = 0; i < p->sz; i += PGSIZE)
  {
    pte_t *pte = walkpgdir(p->pgdir, (void *)i, 0);
    if (*pte & PTE_P)
    {
      if (!(*pte & PTE_A))
      {

        if (p->rss < PGSIZE)
          continue;

        // p->rss -= PGSIZE;
        return pte;
      }
    }
  }

  return 0;
}

void find_new_page_after_swapping()
{
  // cprintf("In find_new_page_after_swapping\n");
  pte_t *pte = select_a_victim();
  uint idx = -1;
  for (int i = 0; i < NSLOTS; i++)
  {
    if (swaparray[i].is_free)
    {
      idx = i;
      break;
    }
  }
  if (idx == -1)
    panic("No available slot\n");
  if (pte == 0)
    panic("Pte is 0\n");
  uint block_no = 2 + 8 * idx;
  // int a = (PTE_ADDR(*pte)/PGSIZE);
  write_pag_to_disk(ROOTDEV, (char *)P2V(PTE_ADDR(*pte)), block_no);
  // cprintf("In find_new_page_after_swapping2\n");
  make_other_pte_swapped_out(pte, idx);
  // cprintf("In find_new_page_after_swapping3\n");
  swaparray[idx].page_perm = PTE_FLAGS(*pte);
  swaparray[idx].is_free = 0;
  kfree((char *)P2V(PTE_ADDR(*pte)));
  *pte = ((idx << 12) | PTE_S);
  *pte &= ~PTE_A;
  for (int i = 0; i < swaparray[idx].cnt; i++)
    {
      // if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
      // inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
      // cprintf("checking both are changing or not %d %d\n",*pte,*swaparray[idx].pte_id[i]);
      // @changes made by me
      swaparray[idx].pte_id[i] = pte;
    }
  // cprintf("In find new page fault %d %d %d %d refcount %d\n", pte,*pte, block_no, idx,swaparray[idx].cnt);
  //   // *pte= (idx<< 12) | PTE_S;
  // cprintf("In find_new_page_after_swapping4\n");
  // lcr3(V2P(myproc()->pgdir));
  return;
}

void handle_fage_fault()
{
  struct proc *p;
  p = myproc();
  uint va = (rcr2());
  va = PGROUNDDOWN(va);
  pde_t *pg_dir;
  pg_dir = p->pgdir;
  pte_t *pte = walkpgdir(pg_dir, (void *)va, 0);
  uint pa = PTE_ADDR(*pte);
  uint pgnum = pa / PGSIZE;
  if (*pte & PTE_P)
  {
    if (check_rmap(pgnum))
    {
      *pte |= PTE_W;
    }
    else
    {
      char *mem = kalloc();
      memmove(mem, (char *)P2V(pa), PGSIZE);
      *pte = V2P(mem) | PTE_FLAGS(*pte) | PTE_W;
      dec_sharing(pte, pgnum);
      inc_sharing(pte, V2P(mem) / PGSIZE);
    }
  }
  else
  {
    uint block_no;
    block_no = (*pte) >> 12;
    char *mem = kalloc();
    read_page_from_disk(8 * block_no + 2, mem);
    uint permissions = swaparray[block_no].page_perm;
    swaparray[block_no].is_free = 1;
    // cprintf("In handle page fault %d %d %d refcount %d\n", pte, *pte, block_no,swaparray[block_no].cnt);
    *pte = PTE_ADDR(V2P(mem)) | PTE_FLAGS(permissions);
    *pte = *pte | PTE_A;
    *pte = *pte & ~PTE_W;
    *pte = *pte & ~PTE_S;
    for (int i = 0; i < swaparray[block_no].cnt; i++)
    {
      if(V2P(mem) / PGSIZE == 73) cprintf("In incr %d\n",swaparray[block_no].pte_id[i]);
      if(swaparray[block_no].proc_id[i]->state == UNUSED) continue;
      inc_sharing(swaparray[block_no].pte_id[i], V2P(mem) / PGSIZE);
      swaparray[block_no].proc_id[i]->rss += PGSIZE;
      *swaparray[block_no].pte_id[i] = *pte;
    }
    swaparray[block_no].cnt = 0;
  }
  // cprintf("In handle page fault2 %d %d refcount \n", pte, *pte);
  lcr3(V2P(pg_dir));
}

void clean_proc_data(pde_t *pde)
{
  for (int i = 0; i < NPDENTRIES; i++)
  {
    if (pde[i] & PTE_P)
    {
      pte_t *pte = (pte_t *)P2V(PTE_ADDR(pde[i]));
      for (int j = 0; j < NPTENTRIES; j++)
      {
        if (pte[j] & PTE_S)
        {
          uint slot = PTE_ADDR(pte[j]) >> 12;
          if(swaparray[slot].cnt == 1){
            // cprintf("More  one cnt\n");
            swaparray[slot].is_free = 1;
            swaparray[slot].cnt = 0;
          }
          else{
            // cprintf("More than one cnt\n");
            swaparray[slot].cnt --;
          }
        }
      }
    }
  }
}


void clear_swapped_page(pte_t* pte){
  uint slot = (*pte << 12);
  cprintf("More than one cnt\n");
  if(swaparray[slot].cnt == 1){

    swaparray[slot].is_free = 1;
    swaparray[slot].cnt = 0;
  }
  else{

    swaparray[slot].cnt --;
  }
}


void illop(){
  struct proc *p;
  p = myproc();

  uint va = (rcr2());
  va = PGROUNDDOWN(va);
  pde_t *pg_dir;
  pg_dir = p->pgdir;
  pte_t *pte = walkpgdir(pg_dir, (void *)va, 0);
  uint pa = PTE_ADDR(*pte);
  uint pgnum = pa / PGSIZE;
  cprintf("In illop p->pid %d va %d *pte %d pte %d pa %d pgnum %d \n",p->pid,va,*pte,pte,pa,pgnum);
  // panic("ILLP");
}
// PAGEBREAK!
//  Blank page.
// PAGEBREAK!
//  Blank page.
// PAGEBREAK!
//  Blank page.
