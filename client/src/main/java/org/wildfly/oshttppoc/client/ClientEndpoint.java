package org.wildfly.oshttppoc.client;


import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Response;
import org.wildfly.oshttppoc.server.StatefulRemote;

import javax.naming.Context;
import javax.naming.InitialContext;
import java.util.Hashtable;


@Path("/")
public class ClientEndpoint {

    static StatefulRemote statefulBean = null;

    @GET
    @Produces("text/plain")
    public Response doGet() {
        try {
            if(statefulBean == null) {
                Hashtable<String, String> table = new Hashtable<>();
                table.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
                table.put(Context.PROVIDER_URL, "http://server-loadbalancer.ospoc.svc.cluster.local:8080/wildfly-services");

                InitialContext ic = new InitialContext(table);
                statefulBean = (StatefulRemote) ic.lookup("java:server/StatefulBean!org.wildfly.oshttppoc.server.StatefulRemote");
            }
            statefulBean.invoke();
            return Response.ok("OK").build();
        } catch (Throwable t) {
            return Response.ok("FAILURE " + t.getMessage()).build();
        }
    }
}
