package org.wildfly.oshttppoc.server;

import jakarta.ejb.Remote;

@Remote
public interface StatefulRemote {
    int invoke();
}
