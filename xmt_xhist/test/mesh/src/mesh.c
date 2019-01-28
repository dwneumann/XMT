/************************************************************************
*   Package	: mesh
*   $Version:$
*    Copyright 2018 Visionary Research Inc.   All rights reserved.
*  			legal@visionary-research.com
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
*	void	init_payload(packet_t *payload, int from, int to, int ttl)
*	long	round_trip_ms(struct timeval from)
*	int	is_listening(int port)
*	void	test_complete()
*
************************************************************************/

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
#include <errno.h>

#ifdef XHIST
#include "xhist.h"
#endif 

#define TEST_PASS	0
#define TEST_FAIL	1

#define BACKOUT_IF(ex, msg)	\
	if (ex) { perror(msg); exit(TEST_FAIL); }

#define MAX_NODES	100	/* max # nodes in mesh			*/

typedef struct 			/* packet payload to be sent/ack'ed	*/
{
    int	pkt_src;		/* port # of original sender		*/
    int	pkt_to;			/* port # of ultimate destination 	*/
    int	pkt_num_fwds;		/* # times this pkt has been forwarded	*/
    int	pkt_ttl;		/* # hops this pkt still has to take 	*/
    struct timeval pkt_sent_at;	/* time of departure of packet		*/
} packet_t;

typedef struct 
{
    int	gl_pkts_to_send;	/* # packets to initiate		*/
    int	gl_pkts_returned;	/* # of ACKs returned to me		*/
    int	gl_total_time;		/* accumulated sum of round trip times	*/
    int	gl_num_hops;		/* # hops to fwd each packet		*/
    int	gl_nodes[MAX_NODES];	/* port #'s of all nodes in mesh	*/
    int	gl_num_nodes;		/* # nodes in mesh			*/
    int	gl_my_nodenum;		/* index of this node within gl_nodes[]	*/
} mesh_t;

mesh_t	globals	= {0};		/* fields we need to access from signal handler */

void	init_payload(packet_t *payload, int from, int to, int ttl);
long	round_trip_ms(struct timeval from);
int	is_listening(int port);
void	test_complete();

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
    packet_t		payload;
    struct sockaddr_in	node;
    int			next_node;
    int			i, nbytes;	/* counters */

#ifdef XHIST
/* xhist instrument FALSE */
    int fd;
    char logfn[32]	= {0};

    sprintf(logfn, "cmesh.%d.trace", (int) getpid());
    BACKOUT_IF((fd=open(logfn, O_RDWR|O_CREAT, 0644)) < 0, logfn); 
    xhist_logdev(fd);			/* file or socket to write to		*/
    xhist_mapfile("$XhistMap:$");	/* embed name of file map		*/
    xhist_version("$Version:$");	/* embed build tag of source		*/
    signal(SIGUSR1, xhist_write);	/* dump trace upon receipt of signal	*/
/* xhist instrument TRUE */
#endif

    /* @configure mesh topology */
    globals.gl_pkts_to_send	= 10;	
    globals.gl_num_hops		= 200;
    signal(SIGINT, test_complete);	/* print stats & exit upon receipt of SIGINT	*/
    BACKOUT_IF(argc < 2, "usage: mesh <my (0-based) node index> <port#> <port#> <port#> ...");
    globals.gl_my_nodenum 	= atoi(argv[1]);
    for (i = 2; i < argc; ++i)
    {
        globals.gl_nodes[i-2] = atoi(argv[i]);
    }
    globals.gl_num_nodes = argc-2;

    BACKOUT_IF((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0, "socket");
    memset(&node, 0, sizeof(struct sockaddr_in));
    node.sin_family	= AF_INET;
    node.sin_addr.s_addr = inet_addr("127.0.0.1");
    node.sin_port = htons(globals.gl_nodes[globals.gl_my_nodenum]);
    BACKOUT_IF(bind(sock, (struct sockaddr *)&node, sizeof(node)) < 0, "bind"); 

    /* wait until the node I'm going to send to has started */
    next_node = globals.gl_nodes[(globals.gl_my_nodenum+1)%globals.gl_num_nodes];
    while ( ! is_listening(next_node) )
    {
	sleep(1);
    }

    /* @send my initial messages to my first-listed neighbour	*/
    for (i = 0; i < globals.gl_pkts_to_send; ++i)
    {
	node.sin_port = htons(next_node);
	init_payload(&payload, globals.gl_nodes[globals.gl_my_nodenum], next_node, globals.gl_num_hops);
	sendto(sock, &payload, sizeof(payload), 0, (struct sockaddr *) &node, sizeof(node));
    }

    /* now just forward or ack messges received from others */
    next_node = globals.gl_my_nodenum;
    globals.gl_pkts_returned = 0;
    while (1)
    {
	nbytes = recvfrom(sock, &payload, sizeof(payload), 0, NULL, NULL);

	/* @simulate packet corruption here */
	if (nbytes != sizeof(payload))
	{
	    continue;	/* just drop corrupted packet and continue */
	}

	/* this message was sent by me */
	if ( payload.pkt_src == globals.gl_nodes[globals.gl_my_nodenum] ) 
	{
	    globals.gl_pkts_returned++;
	    globals.gl_total_time += round_trip_ms(payload.pkt_sent_at);
	    printf("%2d : RECV'd ACK after %2d hops in %ld ms\n", 
		globals.gl_nodes[globals.gl_my_nodenum], 
		payload.pkt_num_fwds, 
		round_trip_ms(payload.pkt_sent_at));
	}

	/* @ttl expired; send back to sender as ack */
	else if (payload.pkt_ttl <= 0)	
	{
	    node.sin_port = htons(payload.pkt_src);
	    payload.pkt_num_fwds++;
	    payload.pkt_ttl--;
	    sendto(sock, &payload, sizeof(payload), 0, 
		(struct sockaddr *) &node, sizeof(node));
	}

	/* forward message one more hop to someone else */
	else	
	{
	    next_node	  = ((next_node+1) % globals.gl_num_nodes); 
	    node.sin_port = htons(globals.gl_nodes[next_node]);
	    payload.pkt_num_fwds++;
	    payload.pkt_ttl--;
	    sendto(sock, &payload, sizeof(payload), 0, 
		(struct sockaddr *) &node, sizeof(node));
	    printf("\t%2d : FWD'd to %2d\n", 
		globals.gl_nodes[globals.gl_my_nodenum], 
		globals.gl_nodes[next_node]);
	}
    }
    /* NOT REACHED */
}

/************************************************************************
*   Synopsis:
*	void	init_payload(packet_t *payload, int from, int to, int ttl)
*
*   Purpose:
*	initialize payload contents to the arguments specified.
* 
*   Parameters: 
*	packet_t	*payload	: ptr to payload to initialize
*	int	from	: port number of sender
*	int	to	: port number of recipient
*	int	ttl	: number of hops to forward payload
* 
*   Values Returned: 
*	none	 
* 
***********************************************************************/
void init_payload(packet_t *payload, int from, int to, int ttl)
{
    memset(payload, 0, sizeof(packet_t));
    payload->pkt_src 	= from;
    payload->pkt_to	= to;
    payload->pkt_ttl	= ttl;
    gettimeofday(&(payload->pkt_sent_at), NULL);
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


/************************************************************************
*   Synopsis:
*	int	is_listening(int port)
*
*   Purpose:
*	return true if there is a listener on <port>, false otherwise.
* 
*   Parameters: 
*	int	port	: port number to check
* 
*   Values Returned: 
*	1	: there is a listener on the port
*	0	: there is no listener on the port
* 
***********************************************************************/
int is_listening(int port) 
{
    char str[128];
    FILE* fp;
    int status = 0;

    sprintf(str, "netstat -lnu | grep %d", port);
    BACKOUT_IF((fp = popen(str, "r")) == NULL, "popen");
    if ( fgets(str, sizeof(str)-1, fp) != NULL )
    {
	status = 1;
    }
    fclose(fp); 
    return(status);
}


/************************************************************************
*   Synopsis:
*	void	test_complete()
*
*   Purpose:
*	signal handler that prints summary stats & exits pgm.
* 
*   Parameters: 
*	none	
* 
*   Values Returned: 
*	none	
* 
***********************************************************************/
void test_complete()
{
    printf("%2d : %d pkts sent\t%d%% packet loss,\t%d ms avg round trip time\n", 
	globals.gl_nodes[globals.gl_my_nodenum], 
	globals.gl_pkts_to_send,
	(int) ((globals.gl_pkts_to_send - globals.gl_pkts_returned)/globals.gl_pkts_to_send)*100,
	(int) (globals.gl_total_time/(1 + globals.gl_pkts_returned)));
    exit( (globals.gl_pkts_returned == globals.gl_pkts_to_send) ? TEST_PASS : TEST_FAIL );
}
