# sr_pq
Shift Register Hardware Priority Queue

This code implements a hardware priority queue using a sequence of shift register stages.
Each stage contains a comparator that compares an input key to the key the stage
currently contains (empty stages are assigned a KEYINF value that is larger then any other key).

On a push the first stage which has a key greater than the input key will store the new key-value
pair while this stage and successive stages shift to the right.

On a pop when no push is taking place at the same time, all stages shift to the left.

On a simultaneous pop and push, this first stage which has a key greater than the input key
is stored while preceding stages shift tot he left.
