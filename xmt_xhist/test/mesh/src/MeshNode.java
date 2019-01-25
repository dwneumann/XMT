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
 * @version	$Version: meshtest-1.0-58 [develop] $
 */
public	class		MeshNode {
    public static final String id = "@(#) mesh.MeshNode $Version: meshtest-1.0-58 [develop] $";
    public int	pktsToSend;	/* # packets to initiate		*/
    public int	pktsReturned;	/* # of ACKs returned to me		*/
    public int	numHops;	/* # hops to fwd each packet		*/
    public int	port;		
    public DatagramSocket socket;

    public	MeshNode() { 
	this.pktsToSend		= 0;
	this.pktsReturned	= 0;
	this.numHops		= 0;
	this.port		= 0;
	this.socket		= null;
	InetSocketAddress address = null;
    }

    public	void bind(int port) throws SocketException { 
	this.port		= port;
	this.socket		= new DatagramSocket(null);
	InetSocketAddress address = new InetSocketAddress("127.0.0.1", this.port);
        this.socket.bind(address);
    }

    public int	pktsToSend() {
	return this.pktsToSend;
    }

    public void	setPktsToSend(int n) {
	this.pktsToSend	= n;
    }

    public int pktsReturned() {
	return this.pktsReturned;
    }

    public void	setPktsReturned(int n) {
	this.pktsReturned = n;
    }

    public int	numHops() {
	return this.numHops;
    }

    public void	setNumHops(int n) {
	this.numHops	= n;
    }

    public int	port() {
	return this.port;
    }

    public void incrementPktsReturned() {
	this.pktsReturned++;
    }

    public DatagramSocket	socket() {
	return this.socket;
    }

    public void reportResults() {
	System.out.format( "%2d : %d pkts sent" + "\t%d pkts returned \n",
	    this.port, this.pktsToSend, this.pktsReturned );
    }
}

