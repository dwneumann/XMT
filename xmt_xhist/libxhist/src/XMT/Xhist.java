/**
 * The Xhist class defines methods for extracting execution history from a running process.
 * <p>
 * Package:	XMT
 * Class:	Xhist
 *
 * <p>
 * Xhist (for "execution history") is a package which assists in the diagnosis
 * of difficult bugs such as intermittent, non-reproducible bugs as the software
 * executes in its target environment.  Xhist is made up of an instrumentation
 * program "xhist_instrument", a postprocessing program "xhist_rport", and runtime
 * libraries for various languages, which generate the trace files at runtime.
 *
 * <p>
 * The instrumentation program "xhist_instrument" instruments the source
 * code of the software under test (currnetly C, C++ and Java are supported),
 * and produces modified source code that is then compiled and linked using
 * the same compiler, linker, and flags as the uninstrumented source.
 *
 * <p>
 * The instrumented software, when compiled and executed, records into a circular
 * buffer the filename and line number of each source statement as it is executed.
 * When the program misbehaves, the circular "trace log" can be examined directly
 * (if on an embedded target) or the trace log can be exported to a file,
 * socket, or serial device for interpretation by the developer of the software
 * under test.
 *
 * <p>
 * The Xhist class contains methods which perform the writing
 * of the trace log to a file or socket descriptor.  The Xhist.write()
 * method can be installed as a signal handler, as a termination handler, or
 * it can be invoked unconditionally, so that the trace log be exported using a
 * number of means.  The developer may also examine
 * the trace log directly in memory (if that is supported in the target
 * environment), or may choose to export it in another manner.
 *
 * <p>
 * The postprocessing program "xhist_report" reads a previously written trace
 * log from file, and presents a human-readable formatted listing of the last N
 * source statements executed by the software immediately prior to the log
 * being written.  The program correctly performs byteswapping if the
 * architecture in which the software under test executes is different than
 * the environment in which the xhist_report program executes.  Use of the
 * xhist_report program is optional.
 *
 * @version	$Version:$
 *
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

package XMT;
import java.io.*;
import java.lang.Runtime;
import java.io.DataOutputStream;
import java.io.FileOutputStream;

public final class Xhist
{
    private static final String id = "@(#) XMT.Xhist $Version:$";
    private static final int	XhistMaxHistory	= 1000;	// max history depth per thread 
    private static final int	XhistMaxThreads	= 20;	// max number of threads to keep history for
    private static String buildTag;	// buildTag of instrumented source
    private static String mapFn;	// mapping file used during instrumentation
    private static volatile int[][] historyTbl	= new  int[XhistMaxThreads][XhistMaxHistory];
    private static volatile int[] threadIds	= new  int[XhistMaxThreads]; // map of threadIds to columns
    private static volatile short[] tails	= new  short[XhistMaxThreads]; //initial values =0
    private static ThreadLocal<Integer> myTblIndex = ThreadLocal.withInitial(() -> -1);
    private static volatile DataOutputStream logStream	= null;


    /**
    * initializes xhist execution history logging.
    * @param	logFn		pathname of trace log to write to
    * @param	mapFn		pathname of mapFile to store in trace log
    * @param	version		source build tag to store in trace log
    */
    public static synchronized boolean init( String logFn, String mapFn, String version ) {
	DataOutputStream	fd	= null;
	int			myId, i;
    
	/*
	 * initialize a history table for this thread.
	 * this requires concurrency-safe access to threadIds[] 
	 * so we declare this method synchronized.
	 */
	
	myId = (int) Thread.currentThread().getId();	
	for (i=0; i< XhistMaxThreads; i++)
	{
	    if ( threadIds[i] == 0 )	// find the first unused index
	    {
	        break;
	    }
	}
	if ( i >= XhistMaxThreads )
	{
	    assert(false);		// we've called Xhist.init too many times.
	    myTblIndex.set( -1 );	// this value will turn Xhist.add into a no-op
	    return(false);		// fail silently
	}

	threadIds[i] = myId;		// claim the first unused column for this thread
	myTblIndex.set( i );

	if ( logStream == null )	// only initialize the Datastream once.
	{
	    try 
	    {
		fd = new DataOutputStream(new FileOutputStream(logFn)); 
		Xhist.logdev(fd);
		Xhist.mapfile(mapFn);
		Xhist.version(version);

		Runtime.getRuntime().addShutdownHook( new Thread() 
		{
		    @Override
		    public void run() 
		    {
			Xhist.write();
		    }
		} );
	    } 
	    catch (java.io.FileNotFoundException e) 
	    {
		; /* keep executing without the ability to write the trace log */
	    }
	}
	return(true); // successful initialization
    }

    /**
    * deinitializes Xhist for the current thread 
    * (called during cleanup of crashed thread, before restarting a new thread).
    */
    public static synchronized void deinit() {
	myTblIndex.set( 0 );	//  release this column index for reuse
    }

    /**
    * sets the build tag of the instrumented source to write into the trace file.
    * @param	s	build tag of the instrumented source
    */
    public	static void version( String s ) {
	buildTag = s;
    }

    /**
    * sets the the name of the mapfile needed to decode the file numbers
    * recorded in the table.
    * @param	s	filename of mapfile used during instruentation
    */
    public	static void mapfile( String s ) {
	mapFn = s;
    }

    /**
    * Sets the stream to export the execution history to. 
    * @param	fd	DatOutputStream to write output to
    */
    public	static void logdev( DataOutputStream fd ) { 
	logStream = fd;
    }


    /**
    * Appends (filenum, linenum) to execution history log.
    * This function call gets appended to every exeutable statement so it must be O(1).
    * @param	fnum		filename hash (mapping stored in mapfile())
    * @param	lnum		line number just executed
    */
    public	static void add( int fnum,  int lnum ) { 
	int	index, tail;

	index = myTblIndex.get();	// retrieve my ThreadLocal table index
	if (index >= 0)			// no-op if no history for this thread
	{
	    tail  = tails[index];
	    historyTbl[index][tail] = (((short) fnum << 16) | (short) lnum);
	    tails[index] = (short) ((tail+1) % XhistMaxHistory);
	}
    }


    /**
    * Writes in-memory table to the stream specified via logdev().
    * Squashes exceptions thrown while attempting to write.
    */
    public static void write() {
	int	i, index;
	    try {

	    /*
	    *  write 4 bytes containing the file format magic number 5.
	    *  This allows the xhist_report program to determine the byte order of the writer.
	    *  (xhist_report is agnostic to the language and architecture of the writer).
	    *  Then write the depth of the histry table.
	    */

	    logStream.writeInt(5);
	    logStream.writeInt(XhistMaxHistory);

	    /*
	    *  now write the length & name of the map file created during instrumentation
	    *  and the length & build tag of the instrumented source
	    */
	    logStream.writeUTF(mapFn);
	    logStream.writeUTF(buildTag);
	    
	    /*
	    *  now write the history table one thread at a time
	    */
	    
	    for (index = 0; index < XhistMaxThreads; index++)
	    {
		if (threadIds[index] > 0)	//  only write non-empty threads
		{
		    logStream.writeInt(threadIds[index]);
		    logStream.writeInt(tails[index]);
		    for (i = 0; i < historyTbl[index].length; i++)
		    {
			logStream.writeInt(historyTbl[index][i]);
		    }
		}
	    }
	    logStream.close();
	} catch (IOException ioe) {
		; /* Fail silently */
	}
    }
}
