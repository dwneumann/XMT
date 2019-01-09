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

//package XMT;
import java.io.*;
import java.io.DataOutputStream;

public	class		Xhist 
{ 
    public static final String id = "@(#) XMT.Xhist $Version:$";
    private static final int	XhistTableSize		= 1000;
    public static String buildTag;	// buildTag of instrumented source
    public static String mapFn;		// mapping file used during instrumentation
    public static int[] tbl		= new  int[XhistTableSize];
    public static int tail		= 0;
    public static DataOutputStream logStream		= null;


    /**
    * Appends (filenum, linenum) to execution history log.	
    * @param	fnum		filename hash (mapping stored in mapfile())
    * @param	lnum		line number just executed
    */
    public	static void add( short fnum,  short lnum ) { 
	tbl[tail] = (((short) fnum << 16) | (short) lnum);
	tail = (short) ((tail+1) % XhistTableSize);
    }

    /**
    * writes the build tag of the instrumented source into the trace file.
    * @param	s	build tag of the instrumented source
    */
    public	static void version( String s ) { 
	buildTag = s;
    }

    /**
    * writes the the name of the mapfile needed to decode the file numbers
    * recorded in the table.
    * @param	s	filename of mapfile used during instruentation
    */
    public	static void mapfile( String s ) { 
	mapFn = s;
    }

    /**
    * Sets the strea to export the execution history to. 
    * @param	fd	DatOutputStream to write output to
    */
    public	static void logdev( DataOutputStream fd ) { 
	logStream = fd;
    }

    /**
    * Writes in-memory table to the stream specified via logdev().
    * @throws	IOException a write error occurred
    */
    public	static void write() throws IOException { 
	 int	i;

	/*
	 *  write 4 bytes containing sizeof(int).  (i.e the number 4) 
	 *  This allows the xhist_report program to determine the byte order of the writer.
	 *  (xhist_report is agnostic to the language and architecture of the writer).
	 *  Then write the size of the table and the index of the tail pointer.
	 */
	logStream.writeInt(4);
	logStream.writeInt(tbl.length);
	logStream.writeInt(tail);

	/*
	 *  now write the length & name of the map file created during instrumentation
	 *  and the length & build tag of the instrumented source
	 */
	logStream.writeInt(mapFn.length());
	logStream.writeChars(mapFn);
	logStream.writeInt(buildTag.length());
	logStream.writeChars(buildTag);
	
	/*
	 *  now write the entire table to the log device
	 */
	
	for (i = 0; i < tbl.length; i++)
	{
	    logStream.writeInt(tbl[i]);
	}
    }
}

