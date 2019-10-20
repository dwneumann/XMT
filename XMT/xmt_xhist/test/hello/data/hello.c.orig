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
 
#include <stdlib.h> 
#include <stdio.h> 
#include <unistd.h> 
#include <sys/syscall.h>
#include <pthread.h>

#ifdef XHIST 
#include "xhist.h" 
#endif  

#define NUM_THREADS	10
void foo();
void *thread_main(void *arg);

/* xhist instrument FALSE */
int main(int argc, char *argv[]) 
{
    int i = 0;
    pthread_t thr[NUM_THREADS];

    for (i = 0; i < NUM_THREADS; i++)	// thread loop
    {
        pthread_create(&thr[i], NULL, thread_main, NULL);
    }

    for (i = 0; i < NUM_THREADS; i++)	// thread loop
    {
	pthread_join(thr[i], NULL); // wait for all threads to complete
    }
}
/* xhist instrument TRUE */

void *thread_main(void *arg) 
{
    int	i;
 
    /* <xhist init> */
 
    for (i = 0; i < 5; i++)
    { 
	sleep(1);	
	foo();	
    } 
    return( 0 );
}

void foo()
{
    printf("hello from thread %d\n", (int) syscall(SYS_gettid));
}
