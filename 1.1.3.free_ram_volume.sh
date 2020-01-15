#! /bin/bash

read junk total used free shared buffers cached junk < <(free -m  | grep ^Mem);
echo `expr $total - $used` Mb