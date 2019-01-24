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
 /*<XHIST>*/ import XMT.Xhist; /*</XHIST>*/

/**
 * The Packet class defines [short description].
 * <p>
 * [full description]
 * <p>
 * @version	$Version: notag-0 [develop] $
 */
public	class		Packet {
    public static final String id = "@(#) mesh.Packet $Version: notag-0 [develop] $";
    public int	src;		/* port # of original sender		*/
    public int	dest;		/* port # of ultimate destination 	*/
    public int	hops;		/* # times this pkt has been forwarded	*/
    public int	ttl;		/* # hops this pkt still has dest take 	*/

    public	Packet( int src ) {
	this.src	= src; Xhist.add( 10708, 36 );
	this.dest	= 0; Xhist.add( 10708, 37 );
	this.hops	= 0; Xhist.add( 10708, 38 );
	this.ttl	= 0; Xhist.add( 10708, 39 );
    }

    public int	src()	{
	return this.src;
    }

    public void	setSrc(int port)	{
	this.src	= port; Xhist.add( 10708, 47 );
    }

    public int	dest()	{
	return this.dest;
    }

    public void	setDest(int port)	{
	this.dest	= port; Xhist.add( 10708, 55 );
    }

    public int	hops()	{
	return this.hops;
    }

    public void	setHops(int n)	{
	this.hops	= n; Xhist.add( 10708, 63 );
    }

    public void	incrementHops()	{
	this.hops++; Xhist.add( 10708, 67 );
    }

    public int	ttl()	{
	return this.ttl;
    }

    public void	setTtl(int n)	{
	this.ttl	= n; Xhist.add( 10708, 75 );
    }

    public void	decrementTtl()	{
	this.ttl--; Xhist.add( 10708, 79 );
    }


    public void send(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array(); Xhist.add( 10708, 86 );
	InetAddress hostAddr = null;

	bb.putInt(this.src);  Xhist.add( 10708, 89 );
	bb.putInt(this.dest); Xhist.add( 10708, 90 );
	bb.putInt(this.ttl); Xhist.add( 10708, 91 );
	try
	{
	    hostAddr = InetAddress.getByName("localhost"); Xhist.add( 10708, 94 );
	}
	catch (UnknownHostException e)
	{
	    System.out.println( "InetAddress.getByName: " + e.getMessage()); Xhist.add( 10708, 98 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	dg = new DatagramPacket(payload, payload.length, hostAddr, this.dest); Xhist.add( 10708, 101 );
	try
	{
	    n.socket.send(dg); Xhist.add( 10708, 104 );
	}
	catch (IOException e)
	{
	    System.out.println( "socket.send: " + e.getMessage()); Xhist.add( 10708, 108 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
    }

    public void receive(MeshNode n) {
	DatagramPacket dg;
	ByteBuffer bb	=  ByteBuffer.allocate(64);
	byte[] payload	= bb.array(); Xhist.add( 10708, 116 );

	dg	= new DatagramPacket(payload, payload.length); Xhist.add( 10708, 118 );
	try
	{
	    n.socket.receive(dg); Xhist.add( 10708, 121 );
	}
	catch (IOException e)
	{
	    System.out.println( "socket receive: " + e.getMessage()); Xhist.add( 10708, 125 );
	    ; /* ignore the failure.  will be treated as a lost packet. */
	}
	this.src	= bb.getInt(); Xhist.add( 10708, 128 );
	this.dest	= bb.getInt(); Xhist.add( 10708, 129 );
	this.ttl	= bb.getInt(); Xhist.add( 10708, 130 );
    }

}
