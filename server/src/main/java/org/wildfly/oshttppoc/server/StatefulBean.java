package org.wildfly.oshttppoc.server;

import jakarta.ejb.Stateful;

@Stateful
public class StatefulBean implements StatefulRemote {

        int invocationCount = 0;
        public int invoke(){
            invocationCount++;
            System.out.println("Invocation number " + invocationCount);
            return invocationCount;
        }
}
