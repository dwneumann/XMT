/************************************************************************
*   Package	: libxhist
*   $Version:$
*    Copyright 2018 Visionary Research Inc.   All rights reserved.
*    			legal@visionary-research.com
*    Licensed under the Apache License, Version 2.0 (the "License");
*    you may not use this file except in compliance with the License.
*    You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
*    
*    Unless required by applicable law or agreed to in writing, software
*    distributed under the License is distributed on an "AS IS" BASIS,
*    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*    See the License for the specific language governing permissions and
*    limitations under the License. 
*
*   Purpose	: demonstrate xhist usage
************************************************************************/

#define __hello_c

#ifdef EMBED_REVISION_STRINGS
static const char hello_c_id[] = "@(#) libxhist::hello.c	$Version:$";
#endif

#ifdef XHIST
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include "xhist.h"
#endif 

extern void foo();

int main(int argc, char *argv[])
{

#ifdef XHIST
/* xhist instrument FALSE */
    int i, fd;

    if ((fd=open(XHIST_LOGFILE, O_RDWR|O_CREAT, 0644)) < 0)
    {
        perror(XHIST_LOGFILE);
	exit(1);
    }
    xhist_logdev(fd);
    xhist_mapfile("$XhistMap:$");
    xhist_version("$Version:$");
    signal(SIGUSR1, xhist_write);
/* xhist instrument TRUE */
#endif

    for (i = 0; i < 10; i++)
    {
	sleep(1);
	foo();
    }
    xhist_write();
}

