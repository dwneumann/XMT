/************************************************************************
*   Package	: mesh
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

#define __mesh_c

#ifdef EMBED_REVISION_STRINGS
static const char mesh_c_id[] = "@(#) mesh::mesh.c	$Version:$";
#endif

#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <sys/socket.h>
#ifdef XHIST
#include "xhist.h"
#endif 

#define BACKOUT_IF(ex, msg)	\
	if (ex) { fprintf(stderr, "%s\n", msg); goto backout; }

#define MAX_MESH	20	/* max # neighbours to communicate with */
#define MSGLEN		32	/* max datagram payload */

int main(int argc, char *argv[])
{
    int			sock;
    int			my_port;
    int			peer_ports[MAX_MESH], num_peers;
    int 		count, i;
    int			spreading_factor	= 1;
    struct sockaddr_in	me;
    struct sockaddr	peer;
    char		msg[MSGLEN];

#ifdef XHIST
/* xhist instrument FALSE */
    int fd;

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

    /* configure topology */
    BACKOUT_IF(argc < 2, "usage: mesh <my_port#> <peer_port#> <peer_port#> <peer_port#> ...");
    my_port 		= atoi(argv[1]);
    for (num_peers = 0; argc > num_peers-2; ++num_peers)
    {
        peer_ports[num_peers] = atoi(argv[num_peers+2]);
    }
    me.sin_family	= AF_INET;
    me.sin_port		= htons(my_port);
    me.sin_addr		= inet_addr("127.0.0.1");
    BACKOUT_IF((sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0, "socket error");
    BACKOUT_IF(bind(sock, (struct sockaddr *) &me, sizeof(me))   < 0, "bind error");
    peer.sin_family	= AF_INET;
    peer.sin_addr	= inet_addr("127.0.0.1");

    /* if argv[0] == mesh_initiate, send 1 initial msg to 1 peer */
    peer.sin_port = htons(peer_ports[0]);
    sprintf(msg, "msg:%2d from:%d", 1, my_port);
    if (strcmp(argv[0], "mesh_initiate") == 0)
    {
	(void) sendto(s, msg, strlen(msg), 0, &peer, sizeof(peer));
    }

    /* now everyone forwards all received msgs to N others */
    while (1)
    {
	if (recvfrom(s, msg, sizeof(msg), 0, &peer, &slen) > 0)
	{
	    printf("%s\n", msg);

	    /* resend to N peers */
	    for (i = 0; i < spreading_factor; ++i)
	    {
		peer.sin_port = htons(peer_ports[i]);
		sprintf(msg, "msg:%2d from:%d", count, my_port);
		(void) sendto(s, msg, strlen(msg), 0, &peer, sizeof(peer));
	    }
	}
    }

    /* shutdown */
    backout:
#ifdef XHIST
    xhist_write();
#endif
    exit(0);
}

