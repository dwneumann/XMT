/**
 *  Copyright 2018 Visionary Research Inc.   All rights reserved.
 *    			legal@visionary-research.com
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *    
 *    Unless required by applicable law or agreed dest in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License. 
 */

import java.io.*;
import java.net.*;
import java.nio.ByteBuffer;
import XMT.Xhist;

/**
 * The Packet class defines [short description].
 * <p>
 * [full description]
 * <p>
 * @version	$Version:$
 */
public	class		Packet {
    public static final String id = "@(#) mesh.Packet $Version:$";
    public int	src;		/* port # of original sender		*/
    public int	dest;		/* port # of ultimate destination 	*/
    public int	hops;		/* # times this pkt has been forwarded	*/
    public int	ttl;		/* # hops this pkt still has dest take 	*/

    public	Packet( int src ) {
	this.src	= src;
	this.dest	= 0;
	this.hops	= 0;
	this.ttl	= 0;
    }

    public int	src()	{
	return this.src;
    }

    public void	setSrc(int port)	{
	this.src	= port;
    }

    public int	dest()	{
	return this.dest;
    }

    public void	setDest(int port)	{
	this.dest	= port;
    }

    public int	hops()	{
	return this.hops;
    }

    public void	setHops(int n)	{
	this.hops	= n;
    }

    public void	incrementHops()	{
	this.hops++;
    }

    public int	ttl()	{
	return this.ttl;
    }

    public void	setTtl(int n)	{
	this.ttl	= n;
    }

    public void	decrementTtl()	{
	this.ttl--;
    }


    public void send(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array();
	InetAddress hostAddr = null;

	bb.putInt(this.src); 
	bb.putInt(this.dest);
	bb.putInt(this.ttl);
	try
	{
	    hostAddr = InetAddress.getByName("localhost");
	}
	catch (UnknownHostException e)
	{
	    System.out.println( "InetAddress.getByName: " + e.getMessage());
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	dg = new DatagramPacket(payload, payload.length, hostAddr, this.dest);
	try
	{
	    n.socket.send(dg);
	}
	catch (IOException e)
	{
	    System.out.println( "socket.send: " + e.getMessage());
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
    }

    public void receive(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array();

	dg	= new DatagramPacket(payload, payload.length);
	try
	{
	    n.socket.receive(dg);
	}
	catch (IOException e)
	{
	    System.out.println( "socket receive: " + e.getMessage());
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	this.src	= bb.getInt();
	this.dest	= bb.getInt();
	this.ttl	= bb.getInt();
    }

}
