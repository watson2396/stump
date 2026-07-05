# stump
It's not a log, it's a stump

I'm stumped.

# current goal
single-node LSM-tree
- store ints for keys and values
    - maybe other primitives but that can be later

## steps

1. focus on LSM-tree

_Capacity_ will be based on multiples of buffer. Since I'm only doing integers a simple mulitple of fixed size works well.
If I was including strings or other variable data then a byte based approach would make more sense.

_Merge threshold_ will be _1_ run. For now at least, may change to multiple depending on how impl goes.

2. hard-code or file based input for a while, maybe very limited cli input 
3. parsing of query lang will come later

# research later
- bloom filters
- fence pointers
- sorted string tables


# how do LSMs work?

## data layout

Hierarchy of storage levels, increasing as the levels increase. First level, L0, is main memory, the rest are on disk. 
As the buffer (main memory) fills, it must be flushed to disk to be persisted. In the file the contents are sorted by key order.

With levels are starting at L0, levels are then typically described as starting at the smallest then to largest level. This keeps
consistent with the idea of levels getting bigger in size as they increase.

The concept of a level is logical. There are buffers, files, catalogs, and manifests. These all are real data structures, that in different ways
represent and track the levels of data. The defining attributes of a level are: capacity and merge threshold. Capacity is defined either by bytes or
multiples of buffer size. Merge threshold is the max number of runs in a level. The two options are: leveling, one run allowed,
and tiering, more than one run allowed. A run is a collection of one or more *sorted* files with *non-overlapping* key ranges.

Files are persisted on disk, contain entries sorted by key order. Files are immutable, compaction/merges create new files and 
changes/events are replayed and consolidated in the new files. Files typically persist smaller auxillary data structures to help 
optimize key searches. They typically include fence pointers and bloom filters.

## writes
Writes are fast because they are buffered to main memory first. There are no in place updates so updates are treated the same way. They are bound
to a key and added to the log. The changes are merged when flushed to disk or later merge runs as values are compacted. Deletes are mostly the same
except they contain a special flag to tombstone the key. One the main memory buffer is full the events are flushed to disk in a batch opertation.
Batching is one of the key ways performance is achieved and maintained. 

## merging (compaction)
Merging takes a set of sorted files and outputs a set of sorted files with non-overlapping key ranges. The key differences between inputs and outputs
is the input files may have overlapping ranges and have mergable events/keys. Once these are merged a new set of files are created based on the defined
sizing rules for the implementation so they represent a dense set of unique keys.

The 2 main triggers for merging are: the current level has reached merge threshold size must be merged and compacted to larger levels 
to maintain constraints. The other is a smaller level has triggered a merge and is pushing data down the tree to the current level which is at threshold
so a cascade of merges ensues to keep files at appropriate sizes.

## lookups
Lookups start in L0 and move to larger levels if the key is not found. Two different kinds of queries: single key and range queries.
Both are performed against all levels of the tree as needed. To avoid binary searches for each lookup, aux data structures are maintained for 
optimizations, fence pointers and bloom filters. Fence pointers are min/max of each page, or pages. Bloom filters are a probabilistic data structure,
look it up. Bloom filters are good for single key lookups. 

*Warning extrapolating* I imagine given a key a the fence pointers are first consulted to check if the range is relevant, 
once relevant range is found, a bloom filter is checked to see if the key _might_ be there. If it is not then move on or return. 
If it _might_ be then the range is more closely checked.

## consistency and level management
Files correspond to the file system but levels are purely logical and are managed by the LSM-tree impl. Typically a global catalog and manifest
of the immutable files is maintained, in-memory and persisted to disk. These describe the files and level relationship, and which files consist
of the current snapshot.

# references
- https://www.darchuletajr.com/blog/lsm-trees-memtables-sorted-string-tables-introduction
- https://dev.to/justlorain/building-an-lsm-tree-storage-engine-from-scratch-3eom
- http://daslab.seas.harvard.edu/classes/cs265/project.html
- https://en.wikipedia.org/wiki/External_sorting

