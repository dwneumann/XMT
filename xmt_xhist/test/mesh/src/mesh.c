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
/* xhist debug TRUE */	/*<DEBUG ON>*/

#ifdef EMBED_REVISION_STRINGS
static const char mesh_c_id[] = "@(#) mesh::mesh.c	$Version:$";	/*<DECL>*/
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
	if (ex) { perror(msg); exit(TEST_FAIL); }	/*<STMT OUTSIDE FUNC>*/

#define MAX_NODES	100	/* max # nodes in mesh			*/

typedef struct 			/* packet payload to be sent/ack'ed	*/
{	/*<FUNC START>*/
    int	pkt_src;		/* port # of original sender		*/
    int	pkt_to;			/* port # of ultimate destination 	*/
    int	pkt_num_fwds;		/* # times this pkt has been forwarded	*/
    int	pkt_ttl;		/* # hops this pkt still has to take 	*/
    struct timeval pkt_sent_at;	/* time of departure of packet		*/
} packet_t;	/*<FUNC END>*/

typedef struct 
{	/*<FUNC START>*/
    int	gl_pkts_to_send;	/* # packets to initiate		*/
    int	gl_pkts_returned;	/* # of ACKs returned to me		*/
    int	gl_total_time;		/* accumulated sum of round trip times	*/
    int	gl_num_hops;		/* # hops to fwd each packet		*/
    int	gl_nodes[MAX_NODES];	/* port #'s of all nodes in mesh	*/
    int	gl_num_nodes;		/* # nodes in mesh			*/
    int	gl_my_nodenum;		/* index of this node within gl_nodes[]	*/
} mesh_t;	/*<FUNC END>*/

mesh_t	globals	= {0};		/* fields we need to access from signal handler */	/*<STMT OUTSIDE FUNC>*/

void	init_payload(packet_t *payload, int from, int to, int ttl);	/*<DECL>*/
long	round_trip_ms(struct timeval from);	/*<DECL>*/
int	is_listening(int port);	/*<DECL>*/
void	test_complete();	/*<DECL>*/

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
{	/*<FUNC START>*/
    int			sock;	/*<DECL>*/
    packet_t		payload;	/*<DECL>*/
    struct sockaddr_in	node;	/*<DECL>*/
    int			next_node;	/*<DECL>*/
    int			i, nbytes;	/* counters */

#ifdef XHIST
/* xhist instrument FALSE */	/*<INSTRUMENT OFF>*/
    int fd;	/*<DECL>*/
    char logfn[32];	/*<DECL>*/

    sprintf(logfn, "xhist.%d.trace", (int) getpid());	/*<STMT>*/
    BACKOUT_IF((fd=open(logfn, O_RDWR|O_CREAT, 0644)) < 0, logfn); 	/*<STMT>*/
    xhist_logdev(fd);			/* file or socket to write to		*/	/*<STMT>*/
    xhist_mapfile("$XhistMap: xhist.meshtest-1.0-0-develop.map $");	/* embed name of file map		*/	/*<STMT>*/
    xhist_version("$Version:$");	/* embed build tag of source		*/	/*<STMT>*/
    signal(SIGUSR1, xhist_write);	/* dump trace upon receipt of SIGUSR1	*/	/*<STMT>*/
/* xhist instrument TRUE */	/*<INSTRUMENT ON>*/
#endif

    /* @configure mesh topology */
    globals.gl_pkts_to_send	= 10;		/*<STMT>*/	_XH_ADD( 24999, 124 );
    globals.gl_num_hops		= 200;	/*<STMT>*/	_XH_ADD( 24999, 125 );
    signal(SIGINT, test_complete);	/* print stats & exit upon receipt of SIGINT	*/	/*<STMT>*/	_XH_ADD( 24999, 126 );
    BACKOUT_IF(argc < 2, "usage: mesh <my (0-based) node index> <port#> <port#> <port#> ...");	/*<STMT>*/	_XH_ADD( 24999, 127 );
    globals.gl_my_nodenum 	= atoi(argv[1]);	/*<STMT>*/	_XH_ADD( 24999, 128 );
    for (i = 2; i < argc; ++i)	/*<FOR>*/
    {
        globals.gl_nodes[i-2] = atoi(argv[i]);	/*<STMT>*/	_XH_ADD( 24999, 131 );
    }
    globals.gl_num_nodes = argc-2;	/*<STMT>*/	_XH_ADD( 24999, 133 );

    BACKOUT_IF((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0, "socket");	/*<STMT>*/	_XH_ADD( 24999, 135 );
    memset(&node, 0, sizeof(struct sockaddr_in));	/*<STMT>*/	_XH_ADD( 24999, 136 );
    node.sin_family	= AF_INET;	/*<STMT>*/	_XH_ADD( 24999, 137 );
    node.sin_addr.s_addr = inet_addr("127.0.0.1");	/*<STMT>*/	_XH_ADD( 24999, 138 );
    node.sin_port = htons(globals.gl_nodes[globals.gl_my_nodenum]);	/*<STMT>*/	_XH_ADD( 24999, 139 );
    BACKOUT_IF(bind(sock, (struct sockaddr *)&node, sizeof(node)) < 0, "bind"); 	/*<STMT>*/	_XH_ADD( 24999, 140 );

    /* wait until the node I'm going to send to has started */
    next_node = globals.gl_nodes[(globals.gl_my_nodenum+1)%globals.gl_num_nodes];	/*<STMT>*/	_XH_ADD( 24999, 143 );
    while ( ! is_listening(next_node) )
    {
	sleep(1);	/*<STMT>*/	_XH_ADD( 24999, 146 );
    }

    /* @send my initial messages to my first-listed neighbour	*/
    for (i = 0; i < globals.gl_pkts_to_send; ++i)	/*<FOR>*/
    {
	node.sin_port = htons(next_node);	/*<STMT>*/	_XH_ADD( 24999, 152 );
	init_payload(&payload, globals.gl_nodes[globals.gl_my_nodenum], next_node, globals.gl_num_hops);	/*<STMT>*/	_XH_ADD( 24999, 153 );
	sendto(sock, &payload, sizeof(payload), 0, (struct sockaddr *) &node, sizeof(node));	/*<STMT>*/	_XH_ADD( 24999, 154 );
    }

    /* now just forward or ack messges received from others */
    next_node = globals.gl_my_nodenum;	/*<STMT>*/	_XH_ADD( 24999, 158 );
    globals.gl_pkts_returned = 0;	/*<STMT>*/	_XH_ADD( 24999, 159 );
    while (1)
    {
	nbytes = recvfrom(sock, &payload, sizeof(payload), 0, NULL, NULL);	/*<STMT>*/	_XH_ADD( 24999, 162 );

	/* @simulate packet corruption here */
	if (nbytes != sizeof(payload))
	{
	    continue;	/* just drop corrupted packet and continue */
	}

	/* this message was sent by me */
	if ( payload.pkt_src == globals.gl_nodes[globals.gl_my_nodenum] ) 
	{
	    globals.gl_pkts_returned++;	/*<STMT>*/	_XH_ADD( 24999, 173 );
	    globals.gl_total_time += round_trip_ms(payload.pkt_sent_at);	/*<STMT>*/	_XH_ADD( 24999, 174 );
	    printf("%2d : RECV'd ACK after %2d hops in %ld ms\n", 
		globals.gl_nodes[globals.gl_my_nodenum], 
		payload.pkt_num_fwds, 
		round_trip_ms(payload.pkt_sent_at));	/*<STMT>*/	_XH_ADD( 24999, 178 );
	}

	/* @ttl expired; send back to sender as ack */
	else if (payload.pkt_ttl <= 0)	
	{
	    node.sin_port = htons(payload.pkt_src);	/*<STMT>*/	_XH_ADD( 24999, 184 );
	    payload.pkt_num_fwds++;	/*<STMT>*/	_XH_ADD( 24999, 185 );
	    payload.pkt_ttl--;	/*<STMT>*/	_XH_ADD( 24999, 186 );
	    sendto(sock, &payload, sizeof(payload), 0, 
		(struct sockaddr *) &node, sizeof(node));	/*<STMT>*/	_XH_ADD( 24999, 188 );
	}

	/* forward message one more hop to someone else */
	else	
	{
	    next_node	  = ((next_node+1) % globals.gl_num_nodes); 	/*<STMT>*/	_XH_ADD( 24999, 194 );
	    node.sin_port = htons(globals.gl_nodes[next_node]);	/*<STMT>*/	_XH_ADD( 24999, 195 );
	    payload.pkt_num_fwds++;	/*<STMT>*/	_XH_ADD( 24999, 196 );
	    payload.pkt_ttl--;	/*<STMT>*/	_XH_ADD( 24999, 197 );
	    sendto(sock, &payload, sizeof(payload), 0, 
		(struct sockaddr *) &node, sizeof(node));	/*<STMT>*/	_XH_ADD( 24999, 199 );
	    printf("\t%2d : FWD'd to %2d\n", 
		globals.gl_nodes[globals.gl_my_nodenum], 
		globals.gl_nodes[next_node]);
	}
    }
    /* NOT REACHED */
}	/*<FUNC END>*/

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
{	/*<FUNC START>*/
    memset(payload, 0, sizeof(packet_t));	/*<STMT>*/	_XH_ADD( 24999, 227 );
    payload->pkt_src 	= from;	/*<STMT>*/	_XH_ADD( 24999, 228 );
    payload->pkt_to	= to;	/*<STMT>*/	_XH_ADD( 24999, 229 );
    payload->pkt_ttl	= ttl;	/*<STMT>*/	_XH_ADD( 24999, 230 );
    gettimeofday(&(payload->pkt_sent_at), NULL);	/*<STMT>*/	_XH_ADD( 24999, 231 );
}	/*<FUNC END>*/


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
{	/*<FUNC START>*/
    struct timeval to;	/*<DECL>*/

    gettimeofday(&to, NULL);	/*<STMT>*/	_XH_ADD( 24999, 253 );
    return( (to.tv_sec - from.tv_sec)*1000 + (to.tv_usec - from.tv_usec + 1)/1000 );	/*<RETURN>*/
}	/*<FUNC END>*/


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
{	/*<FUNC START>*/
    char str[128];	/*<DECL>*/
    FILE* fp;	/*<DECL>*/
    int status = 0;	/*<DECL>*/

    sprintf(str, "netstat -lnu | grep %d", port);	/*<STMT>*/	_XH_ADD( 24999, 279 );
    BACKOUT_IF((fp = popen(str, "r")) == NULL, "popen");	/*<STMT>*/	_XH_ADD( 24999, 280 );
    if ( fgets(str, sizeof(str)-1, fp) != NULL )
    {
	status = 1;	/*<STMT>*/	_XH_ADD( 24999, 283 );
    }
    fclose(fp); 	/*<STMT>*/	_XH_ADD( 24999, 285 );
    return(status);	/*<RETURN>*/
}	/*<FUNC END>*/


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
{	/*<FUNC START>*/
    printf("%2d : %d pkts sent\t%d pkts ack'd\t%d%% packet loss,\t%d ms total time\t%d ms avg round trip time\n", 
	globals.gl_nodes[globals.gl_my_nodenum], 
	globals.gl_pkts_to_send,
	globals.gl_pkts_returned,
	(int) ((globals.gl_pkts_to_send - globals.gl_pkts_returned)/globals.gl_pkts_to_send)*100,
	globals.gl_total_time,
	(int) (globals.gl_total_time/globals.gl_pkts_returned));	/*<STMT>*/	_XH_ADD( 24999, 312 );
    exit( (globals.gl_pkts_returned == globals.gl_pkts_to_send) ? TEST_PASS : TEST_FAIL );	/*<STMT>*/	_XH_ADD( 24999, 313 );
}	/*<FUNC END>*/
