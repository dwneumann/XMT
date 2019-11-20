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


import java.lang.Runtime;

public	class		Hello
{
    public static final String id = "@(#) hello.Hello $Version:$";

    public static void main(String []args) 
    {
	int t = 0;

	for (t = 0; t < 10; t++)	// thread loop
	{
	    Thread thr = new Thread(new Runnable() 
	    {
		@Override
		public void run() 
		{
		    int i = 0;
		    /* <xhist init> */		// instrument each thread

		    for (i = 0; i < 10; i++)	// print loop
		    { 
			try { 
			    Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
			    /* do nothing */
			}
			foo((int) Thread.currentThread().getId());
		    } 
		}
	    } );

	    thr.start();
	}
    }

    public static void foo(int t) 
    {
        System.out.println("hello from thread " + t);
    }
}
