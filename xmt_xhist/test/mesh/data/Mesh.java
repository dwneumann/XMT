/**
 *  Copyright 2018 Visionary Research Inc.   All rights reserved.
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
 */

import java.lang.*;
import java.io.*;
import java.net.*;
import XMT.Xhist;

/**
 * The Mesh class implements a toy mesh network to demonstrate execution history tracing
 * and whitebox testing.
 * <p>
 *  main() implements one myNode (myNode i) of an N myNode mesh.  
 *  Multiple instances should be run to create the N nodes.
 *  Each myNode then initiates, forwards, & receives packets
 *  to/from the other nodes.  
 *  Prints statistics on packet loss & latency.
 * <p>
 * @version	$Version:$
 */
public	class	Mesh {
    public static final String id = "@(#) mesh.Mesh $Version:$";
    public static final int MAX_NODES	= 100;		/* max # nodes in mesh		*/
    public static MeshNode	myNode	= null;		/* this Node			*/


    public static void main(String []args) throws NumberFormatException {
	Packet 		pkt		= null;		/* packet to be sent		*/
	int		nodes[] = new int[MAX_NODES];	/* port #'s of all nodes	*/
	int		numNodes	= 0;		/* # nodes in mesh		*/
	int		myNodeIndex	= 0;		/* index of my port#		*/
	int		nextPort	= 0;		/* value of nodes[myNodeIndex+1]*/
	int		dfltPktsToSend	= 10;		/* # pkts to initiate		*/
	int		dfltHops	= 100;		/* # hops before ack		*/
	int		i		= 0;

	/* xhist instrument FALSE */
	DataOutputStream	fd	= null;
    
	try 
	{
	    fd = new DataOutputStream(new FileOutputStream("./Hello.trace")); 
	    Xhist.logdev(fd);
	    Xhist.mapfile("$XhistMap:$");
	    Xhist.version("$Version:$");

	    Runtime.getRuntime().addShutdownHook( new Thread() 
	    {
		@Override
		public void run() 
		{
		    try 
		    {
			Xhist.write();
			myNode.reportResults();
		    }
		    catch (IOException e) 
		    {
			; /* we're in the process of shutting down anyway. do nothing */
		    }
		}
	    });
	} 
	catch (java.io.FileNotFoundException e) 
	{
	    System.out.println("cannot open DataOutputStream");
	    /* keep executing without the ability to write the trace log */
	}
	/* xhist instrument TRUE */

	/* usage: mesh <my (0-based) myNode index> <port#> <port#> <port#> ... */
	numNodes = -1;
	for (String s: args)
	{
	    if (numNodes < 0)
	    {
		myNodeIndex = Integer.parseInt(s);
		numNodes++;
	    }
	    else
	    {
		nodes[numNodes++] = Integer.parseInt(s);
	    }
	}

	/* create the MeshNode and associated socket */
	try 
	{
	    myNode = new MeshNode( nodes[myNodeIndex] ); /* bind to my port # */
	}
	catch (SocketException e) 
	{
	    /* we can't go on.  log the error & exit gracefully. */
	    System.out.println("fatal error: cannot create MeshNode\n");
	    System.exit(1);
	}

	/* configure the test  */
	myNode.setPktsToSend( dfltPktsToSend );	
	myNode.setNumHops( dfltHops );


	/* wait until the node I'm going to send to has started */
	nextPort = nodes[ (myNodeIndex +1) % numNodes ];
	try 
	{
	    waitForNode(nextPort);			
	}
	catch (IOException e)
	{
	    /* wait failed.  try a different approach.  */
	    try 
	    { 
		Thread.sleep(1000); 
	    } 
	    catch (InterruptedException e2) 
	    {
		;	/* keep waiting if sleep interrupted */
	    }

	}

	/* send N messages to my first-listed neighbour	*/
	for (i = 0; i < myNode.pktsToSend(); ++i)
	{
	    pkt = new Packet( myNode.port(), nextPort, myNode.numHops() );
	    myNode.send(pkt);
	}

	/* now just forward or ack messges received from others */
	myNode.setPktsReturned(0);
	while (true)
	{
	    myNode.receive(pkt);

	    /* the message just received was originated by me, so this is an ACK */
	    if ( pkt.src() == myNode.port() ) 
	    {
		myNode.incrementPktsReturned();
		myNode.addTotalTime( pkt.roundTripTime() );
		System.out.format( "%2d : RECV'd ACK after %2d hops in %ld ms\n", 
		    myNode.port(), pkt.hops(), pkt.roundTripTime() );
	    }

	    /* ttl expired; send back to sender as ack */
	    else if (pkt.ttl() <= 0)	
	    {
		pkt.setDest(pkt.src());
		pkt.incrementHops();
		myNode.send(pkt);
	    }

	    /* ttl not yet expired; forward message one more hop to someone else */
	    else	
	    {
		pkt.incrementHops();
		pkt.decrementTtl();
		pkt.setDest(nextPort);
		myNode.send(pkt);
		System.out.format("\t%2d : FWD'd to %2d\n", myNode.port(), nextPort);
	    }
	}
	/* NOT REACHED */
    }

    public static void waitForNode(int port) throws IOException {
	ProcessBuilder processBuilder = new ProcessBuilder();
	String cmdLine = String.format("netstat -lnu | grep %d", port);
	String line;

	processBuilder.command("bash", "-c", cmdLine);
	while (true) 
	{
	    try 
	    {
		Process process = processBuilder.start();
		BufferedReader reader = new BufferedReader(
		    new InputStreamReader(process.getInputStream()));

		if ((line = reader.readLine()) != null) 
		{
		    return;
		}
		{
		    Boolean isTrue = false; 
		    if (isTrue) { 
			throw new IOException("isTrue"); 
		    } 
		}
	    }
	    catch (IOException e) 
	    {
		throw e;	/* example of forcing an exception to be thrown */
	    }

	    try { 
		Thread.sleep(1000); 
	    } 
	    catch (InterruptedException e) 
	    {
		continue;	/* keep waiting if sleep interrupted */
	    }
	}
    }
}

