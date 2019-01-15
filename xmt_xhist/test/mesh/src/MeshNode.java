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

import java.io.*;
import java.net.*;
import XMT.Xhist;

/**
 * The MeshNode class defines [short description].
 * <p>
 * [full description]
 * <p>
 * @version	$Version: notag-0 [develop] $
 */
public	class		MeshNode {
    public static final String id = "@(#) mesh.MeshNode $Version: notag-0 [develop] $";
    public static final String TEST_PASS	= "TEST PASS";
    public static final String TEST_FAIL	= "TEST FAIL";
    public int	pktsToSend;	/* # packets to initiate		*/
    public int	pktsReturned;	/* # of ACKs returned to me		*/
    public int	totalTime;	/* accumulated sum of round trip times	*/
    public int	numHops;	/* # hops to fwd each packet		*/
    public int	port;		
    public DatagramSocket socket;

    public	MeshNode(int port) throws SocketException { 
	this.pktsToSend		= 0;Xhist.add( 40978, 38 );
	this.pktsReturned	= 0;Xhist.add( 40978, 39 );
	this.totalTime		= 0;Xhist.add( 40978, 40 );
	this.numHops		= 0;Xhist.add( 40978, 41 );
	this.port		= port;Xhist.add( 40978, 42 );
	this.socket		= new DatagramSocket(null);Xhist.add( 40978, 43 );
	InetSocketAddress address = new InetSocketAddress("127.0.0.1", this.port);
        this.socket.bind(address);Xhist.add( 40978, 45 );
    }

    public int	pktsToSend() {
	return this.pktsToSend;
    }

    public void	setPktsToSend(int n) {
	this.pktsToSend	= n;Xhist.add( 40978, 53 );
    }

    public int pktsReturned() {
	return this.pktsReturned;
    }

    public void	setPktsReturned(int n) {
	this.pktsReturned = n;Xhist.add( 40978, 61 );
    }

    public int	totalTime() {
	return this.totalTime;
    }

    public void	setTotalTime(int n) {
	this.totalTime	= n;Xhist.add( 40978, 69 );
    }

    public void	addTotalTime(int n) {
	this.totalTime	+= n;Xhist.add( 40978, 73 );
    }

    public int	numHops() {
	return this.numHops;
    }

    public void	setNumHops(int n) {
	this.numHops	= n;Xhist.add( 40978, 81 );
    }

    public int	port() {
	return this.port;
    }

    public void incrementPktsReturned() {
	this.pktsReturned++;Xhist.add( 40978, 89 );
    }

    public DatagramSocket	socket() {
	return this.socket;
    }

    public void send(Packet p) {
	p.setSentAtNow();Xhist.add( 40978, 97 );
	try
	{
	    this.socket.send(p.datagram());Xhist.add( 40978, 100 );
	}
	catch (IOException e)
	{
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}

    }

    public void receive(Packet p) {
	try
	{
	    this.socket.receive(p.datagram());Xhist.add( 40978, 112 );
	}
	catch (IOException e)
	{
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	p.setReceivedAtNow();Xhist.add( 40978, 118 );
    }

    public void reportResults() {
	System.out.format(	"%2d : %d pkts sent" 		+
				"\t%d%% packet loss,"		+
				"\t%d ms avg round trip time\n", 
	    this.port, 
	    this.pktsToSend,
	    (int) ((this.pktsToSend - this.pktsReturned)/this.pktsToSend)*100,
	    (int) (this.totalTime()/(1 + this.pktsReturned)));Xhist.add( 40978, 128 );
	    System.out.println( (this.pktsReturned == this.pktsToSend) ? 
		TEST_PASS : TEST_FAIL );
    }
}
