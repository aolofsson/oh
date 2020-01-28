# Test burst writes

https://github.com/parallella/oh/issues/37

> Remembered that we have a long forgotten mode in the epiphany chip elink
> (not impemented in the fpga elink) that creates bursts when you write
> doubles to the same address. (F**K!)
> So the writes were likely coming in as bursts.
> Looks like the mailbox works fine when you write in "int"s (I tested it on
> the board with consecutive)
> (see "mailbox_test" in elink/sw0)

