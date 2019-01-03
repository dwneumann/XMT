/************************************************************************
*   Package	: mesh
*   $Version:$
*    Copyright 2018 RightMesh AG.	legal@rightmesh.io
*   
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
*
*   Functions	:
*	int	main(int argc, char *argv[])
*	void	init_msg(packet_t *msg, int from, int to, int ttl)
*	long	round_trip_ms(struct timeval from)
*
************************************************************************/

#define __mesh_c

#ifdef EMBED_REVISION_STRINGS
static const char mesh_c_id[] = "@(#) mesh::mesh.c	$Version:$";
#endif

#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

#ifdef XHIST
#include "xhist.h"
#endif 

#define BACKOUT_IF(ex, msg)	\
	if (ex) { perror(msg); exit(1); }

#define MAX_NODES	100	/* max # nodes in mesh			*/

typedef struct 			/* packet payload to be sent/ack'ed	*/
{
    int	src;			/* port# of original sender		*/
    int	to;			/* port# of ultimate destination 	*/
    int	via[MAX_NODES];		/* port#s of intermediate nodes 	*/
    int	num_fwds;		/* #times this pkt has been forwarded	*/
    int	ttl;			/* #hops this pkt still has to take 	*/
    struct timeval sent_at;	/* time of departure of packet		*/
} packet_t;

void	init_msg(packet_t *msg, int from, int to, int ttl);
long	round_trip_ms(struct timeval from);

/************************************************************************
*   Synopsis:
*	int	main(int argc, char *argv[])
*
*   Purpose:
*	Mesh network packet flooding test.  
*	Used to demonstrate both xhist & Expect-based whitebox testing.
* 
*   Parameters: 
*	int	argc	: commandline arg count
*	char	*argv[]	: commandline args
* 
*   Values Returned: 
*	exit status
* 
***********************************************************************/
int main(int argc, char *argv[])
{
    int			sock;
    struct sockaddr_in	peer;
    packet_t		msg;
    int			my_port;
    int			peer_ports[MAX_NODES], num_peers, next_peer;
    int			i, num_hops = 0;

#ifdef XHIST
/* xhist instrument FALSE */
    int fd;
    char logfn[32];

    sprintf(logfn, "xhist.%d.trace", (int) getpid());
    BACKOUT_IF((fd=open(logfn, O_RDWR|O_CREAT, 0644)) < 0, logfn); 
    xhist_logdev(fd);			/* file or socket to write to	*/
    xhist_mapfile("$XhistMap:$");	/* embed name of file map	*/
    xhist_version("$Version:$");	/* embed build tag of source	*/
    signal(SIGUSR1, xhist_write);	/* dump trace upon receipt of SIGUSR1	*/
/* xhist instrument TRUE */
#endif

    /* @configure mesh topology */
    BACKOUT_IF(argc < 2, "usage: mesh <my_port#> <peer_port#> <peer_port#> <peer_port#> ...");
    my_port 		= atoi(argv[1]);
    for (i = 2; i < argc; ++i)
    {
        peer_ports[i-2] = atoi(argv[i]);
    }
    num_peers = argc-2;

    BACKOUT_IF((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0, "socket error");
    memset(&peer, 0, sizeof(struct sockaddr_in));
    peer.sin_family	= AF_INET;
    inet_pton(AF_INET, "127.0.0.1", &(peer.sin_addr));

    /* @send my one message	*/
    init_msg(&msg, my_port, peer_ports[0], num_hops);
    peer.sin_port = htons(peer_ports[0]);
    sendto(sock, &msg, sizeof(msg), 0, (struct sockaddr *) &peer, sizeof(peer));

    /* @now just receive & forward messges from others */
    while (1)
    {
	recvfrom(sock, &msg, sizeof(msg), 0, NULL, NULL);

	if ( msg.to == my_port ) /* my message came back to me */
	{
	    printf("%2d : RECV'd ACK after %d hops in %ld ms\n", 
		my_port, msg.num_fwds, round_trip_ms(msg.sent_at));
	}
	else if (msg.ttl <= 0)	/* @ttl expired; retrun to sender */
	{
	    peer.sin_port = htons(my_port);
	    msg.num_fwds++;
	    msg.ttl--;
	    sendto(sock, &msg, sizeof(msg), 0, (struct sockaddr *) &peer, sizeof(peer));
	}
	else	/* forward message one more hop */
	{
	    next_peer	  = ((next_peer+1) % num_peers);
	    peer.sin_port = htons(peer_ports[next_peer]);
	    msg.num_fwds++;
	    msg.ttl--;
	    sendto(sock, &msg, sizeof(msg), 0, (struct sockaddr *) &peer, sizeof(peer));
	}
    }

    /* shutdown */
    exit(0);
}

/************************************************************************
*   Synopsis:
*	void	init_msg(packet_t *msg, int from, int to, int ttl)
*
*   Purpose:
*	initialize msg contents to the arguments specified.
* 
*   Parameters: 
*	packet_t	*msg	: ptr to msg to initialize
*	int	from	: port number of sender
*	int	to	: port number of recipient
*	int	ttl	: number of hops to forward msg
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void init_msg(packet_t *msg, int from, int to, int ttl)
{
    memset(msg, 0, sizeof(packet_t));
    msg->src 	= from;
    msg->to	= to;
    msg->ttl	= ttl;
    gettimeofday(&(msg->sent_at), NULL);
}


/************************************************************************
*   Synopsis:
*	long	round_trip_ms(struct timeval from)
*
*   Purpose:
*	return milliseconds elapsed from <from> to now.
* 
*   Parameters: 
*	struct timeval	from	: start of round trip
* 
*   Values Returned: 
*	milliseconds elapsed
* 
***********************************************************************/
long round_trip_ms(struct timeval from) 
{
    struct timeval to;

    gettimeofday(&to, NULL);
    return( (to.tv_sec - from.tv_sec)*1000 + (to.tv_usec - from.tv_usec + 1)/1000 );
}
