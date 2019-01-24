	    /* the message just received was originated by me, so this is an ACK */
	    if ( pkt.src() == myNode.port() ) 
	    {
		myNode.incrementPktsReturned();
	    }

	    /* ttl expired; send back to sender as ack */
	    else if (pkt.ttl() <= 0)	
	    {
		pkt.setDest(pkt.src());
		pkt.decrementTtl();
		pkt.send(myNode);
	    }

	    /* ttl not yet expired; forward message one more hop to someone else */
	    else	
	    {
		pkt.decrementTtl();
		pkt.setDest(nextPort);
		pkt.send(myNode);
	    }
	    try { 
		Thread.sleep(1000); 
	    } 
	    catch (InterruptedException e) 
	    {
		continue;	/* keep waiting if sleep interrupted */
	    }
