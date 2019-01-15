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
import XMT.Xhist;

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
    public long sentAt;		/* time of departure of packet		*/
    public long receivedAt;	/* time of return of packet		*/
    public DatagramPacket datagram;

    public	Packet( int src, int dest, int ttl ) {
	this.src	= src;Xhist.add( 10708, 37 );
	this.dest	= dest;Xhist.add( 10708, 38 );
	this.hops	= 0;Xhist.add( 10708, 39 );
	this.ttl	= ttl;Xhist.add( 10708, 40 );
	this.sentAt	= 0;Xhist.add( 10708, 41 );
	this.receivedAt	= 0;Xhist.add( 10708, 42 );
	this.datagram	= new DatagramPacket(new byte[512], 512);Xhist.add( 10708, 43 );
    }

    public int	src()	{
	return this.src;
    }

    public void	setSrc(int port)	{
	this.src	= port;Xhist.add( 10708, 51 );
    }

    public int	dest()	{
	return this.dest;
    }

    public void	setDest(int port)	{
	this.dest	= port;Xhist.add( 10708, 59 );
    }

    public int	hops()	{
	return this.hops;
    }

    public void	setHops(int n)	{
	this.hops	= n;Xhist.add( 10708, 67 );
    }

    public void	incrementHops()	{
	this.hops++;Xhist.add( 10708, 71 );
    }

    public int	ttl()	{
	return this.ttl;
    }

    public void	setTtl(int n)	{
	this.ttl	= n;Xhist.add( 10708, 79 );
    }

    public void	decrementTtl()	{
	this.ttl--;Xhist.add( 10708, 83 );
    }

    public long	sentAt()	{
	return this.sentAt;
    }

    public void	setSentAt(int n)	{
	this.sentAt	= n;Xhist.add( 10708, 91 );
    }

    public void	setSentAtNow()	{
	this.sentAt	= System.currentTimeMillis();Xhist.add( 10708, 95 );
    }

    public long	receivedAt()	{
	return this.receivedAt;
    }

    public void	setReceivedAt(int n)	{
	this.receivedAt	= n;Xhist.add( 10708, 103 );
    }

    public void	setReceivedAtNow()	{
	this.receivedAt	= System.currentTimeMillis();Xhist.add( 10708, 107 );
    }

    public DatagramPacket	datagram()	{
	return this.datagram;
    }

    public int roundTripTime() {
	return( (int) (this.receivedAt - this.sentAt) );
    }

}
