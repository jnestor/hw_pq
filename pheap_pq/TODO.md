# TODO list for pheap_pq

- synthesize & test in hardware
- test with higher capacities (first in simulation)
- test whether extra test in LEQ is really necessary (???)
- modify levelRam to exclude extra capacity bits at higher levels
- rename modules with more sensible names: leq->lvl_mgr, level_shifter->pos_reg, level->lvl_mem???


# DONE
- Correct busy signal and test at max throughput rate
- make configurable as either a min-pq or a max-pq
- add warning when PQ_CAPACITY not a power of 2 minus one
- modify to eliminate need for levelRam initialization files
- change order of generate loop to top level, middle levels, bottom level
