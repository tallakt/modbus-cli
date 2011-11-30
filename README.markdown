modbus-cli
==========

modbus-cli is a command line utility that lets you read and write data using
the Modbus TCP protocol (ethernet only, no serial line). It supports different
data formats (bool, int, word, float, dword), allows you to save data to a file
and dump it back to your device, acting as a backup tool, or allowing you to
move blocks in memory.

[Home page]:http://www.github.com/tallakt/momdbus-cli

Installation
------------

Install ruby. Then install the gem:

    $ gem install modbus-cli

The pure ruby gem should run on most rubies.

Quick Start
-----------

Lets start by reading five words from our device startig from address %MW100. 

    $ modbus read 192.168.0.1 %MW100 5

which writes

    %MW100        0
    %MW101        0
    %MW102        0
    %MW103        0
    %MW104        0

We chose to write the address in Schneider format, %MW100, but you can also use Modicon naming convention.
The following achieves the same as the previous line

    $ modbus read 192.168.0.1 400101 5

To read coils run the command

    $ modbus read 192.168.0.1 %M100 5

or 

    $ modbus read 192.168.0.1 101 5

You get three subcommands, read, write and dump. The dump commands writes data previously read
using the read command back to its original location. You can get more info on the commands by 
using the help parameter

    $ modbus read --help
 
To write data, write the values after the offset

    $ modbus write 192.168.0.1 101 1 2 3 4 5

Please be aware that there is no protection here - you could easily mess up a running production
system by doing this.

Data Types
----------

For Schneider format you can choose between different data types by using different addresses, 
When using Modicon addresses, you may specify the data type with an additional parameter.
The supported data types are shown in the following table

<table>
  <tr>
    <th>Data type</th>
    <th>Data size</th>
    <th>Schneider address</th>
    <th>Modicon address</th>
    <th>Parameter</th>
  </tr>
  <tr>
    <td>word (default, unsigned)</td>
    <td>16 bits</td>
    <td>%MW100</td>
    <td>400101</td>
    <td>--word</td>
  </tr>
  <tr>
    <td>integer (signed)</td>
    <td>16 bits</td>
    <td>%MW100</td>
    <td>400101</td>
    <td>--int</td>
  </tr>
  <tr>
    <td>floating point</td>
    <td>32 bits</td>
    <td>%MF100</td>
    <td>400101</td>
    <td>--float</td>
  </tr>
  <tr>
    <td>double word</td>
    <td>32 bits</td>
    <td>%MD100</td>
    <td>400101</td>
    <td>--dword</td>
  </tr>
  <tr>
    <td>boolean (coils)</td>
    <td>1 bit</td>
    <td>%M100</td>
    <td>101</td>
    <td>N/A</td>
  </tr>
</table>

To read a floating point value, issue the following command

    $ modbus read %MF100 2

which should give you something like

    %MF100    0.0
    %MF102    0.0

or alternatively

    $ modbus read --float 400101 2

giving

    400101   0.0
    400103   0.0

The modbus command supports the addressing areas 1..99999 for coils and 400001..499999 for the rest using Modicon addresses. Using Schneider addresses the %M addresses are in a separate memory from %MW values, but %MW, %MD, %MF all reside in a shared memory, so %MW0 and %MW1 share the memory with %MF0.


Reading and dumping to files
----------------------------

The following functionality has a few potential uses:

* Storing a backup of PLC memory containing setpoints and such in event og hardware failure
* Moving a block from one location in the PLC to another location
* Copy data from one machine to another

First, start by reading data from your device to be stored in a file

    $ modbus read --output mybackup.yml 192.168.0.1 400001 1000

on Linux you may want to look at the text file by doing

    $ less mybackup.yml

on Windows try loading the file in Wordpad.

To restore the memory at a later time, run the command (again a word of warning, this can mess
up a running production system)

    $ modbus dump mybackup.yml

The modbus command supports multiple files, so feel free to write

    $ modbus dump *.yml

To write the data back to a different device, use the --host parameter

    $ modbus dump --host 192.168.0.2 mybackup.yml

or for a different memory location

    $ modbus dump --offset 401001 192.168.0.2 mybackup.yml

or for a different slave id

    $ modbus dump --slave 88 192.168.0.2 mybackup.yml

Slave ids are not commonly necessary when working with Modbus TCP.

Contributing to modbus-cli
--------------------------

Feel free to fork the project on GitHub and send fork requests. Please 
try to have each feature separated in commits.



License
-------

    (The MIT License)

    Copyright (C) 2011 Tallak Tveide

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





