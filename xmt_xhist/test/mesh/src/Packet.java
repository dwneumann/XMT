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
 * @version	$Version: meshtest-1.0-44 [develop] $
 */
public	class		Packet {
    public static final String id = "@(#) mesh.Packet $Version: meshtest-1.0-44 [develop] $";
    public int	src;		/* port # of original sender		*/
    public int	dest;		/* port # of ultimate destination 	*/
    public int	hops;		/* # times this pkt has been forwarded	*/
    public int	ttl;		/* # hops this pkt still has dest take 	*/

    public	Packet( int src ) {
	this.src	= src;Xhist.add( 10708, 35 );
	this.dest	= 0;Xhist.add( 10708, 36 );
	this.hops	= 0;Xhist.add( 10708, 37 );
	this.ttl	= 0;Xhist.add( 10708, 38 );
    }

    public int	src()	{
	return this.src;
    }

    public void	setSrc(int port)	{
	this.src	= port;Xhist.add( 10708, 46 );
    }

    public int	dest()	{
	return this.dest;
    }

    public void	setDest(int port)	{
	this.dest	= port;Xhist.add( 10708, 54 );
    }

    public int	hops()	{
	return this.hops;
    }

    public void	setHops(int n)	{
	this.hops	= n;Xhist.add( 10708, 62 );
    }

    public void	incrementHops()	{
	this.hops++;Xhist.add( 10708, 66 );
    }

    public int	ttl()	{
	return this.ttl;
    }

    public void	setTtl(int n)	{
	this.ttl	= n;Xhist.add( 10708, 74 );
    }

    public void	decrementTtl()	{
	this.ttl--;Xhist.add( 10708, 78 );
    }


    public void send(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array();Xhist.add( 10708, 85 );
	InetAddress hostAddr = null;

	bb.putInt(this.src); Xhist.add( 10708, 88 );
	bb.putInt(this.dest);Xhist.add( 10708, 89 );
	bb.putInt(this.ttl);Xhist.add( 10708, 90 );
	try
	{
	    hostAddr = InetAddress.getByName("localhost");Xhist.add( 10708, 93 );
	}
	catch (UnknownHostException e)
	{
	    System.out.println( "InetAddress.getByName: " + e.getMessage());Xhist.add( 10708, 97 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	dg = new DatagramPacket(payload, payload.length, hostAddr, this.dest);Xhist.add( 10708, 100 );
	try
	{
	    n.socket.send(dg);Xhist.add( 10708, 103 );
	}
	catch (IOException e)
	{
	    System.out.println( "socket.send: " + e.getMessage());Xhist.add( 10708, 107 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
    }

    public void receive(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array();Xhist.add( 10708, 115 );

	dg	= new DatagramPacket(payload, payload.length);Xhist.add( 10708, 117 );
	try
	{
	    n.socket.receive(dg);Xhist.add( 10708, 120 );
	}
	catch (IOException e)
	{
	    System.out.println( "socket receive: " + e.getMessage());Xhist.add( 10708, 124 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	this.src	= bb.getInt();Xhist.add( 10708, 127 );
	this.dest	= bb.getInt();Xhist.add( 10708, 128 );
	this.ttl	= bb.getInt();Xhist.add( 10708, 129 );
    }

}
