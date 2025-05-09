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
        System.out.println("IDZIE GET CLIENTA");
        try {
            if(statefulBean == null) {
                Hashtable<String, String> table = new Hashtable<>();
                table.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
                table.put(Context.PROVIDER_URL, "http://a-haproxy.ospoc.svc.cluster.local:8080/wildfly-services");
                table.put(Context.SECURITY_PRINCIPAL, "tomek");
                table.put(Context.SECURITY_CREDENTIALS, "tomek");

                InitialContext ic = new InitialContext(table);
                statefulBean = (StatefulRemote) ic.lookup("java:A/StatefulBean!org.wildfly.oshttppoc.server.StatefulRemote");
                //java:jboss/exported/server/StatefulBean!org.wildfly.oshttppoc.server.StatefulRemote
            }
            for(int i = 0; i < 30; i++){
                statefulBean.invoke();
            }
            statefulBean = null;
            return Response.ok("OK").build();

        } catch (Throwable t) {
            return Response.serverError().entity(t.getMessage()).type("text/plain").build();
        }
    }
}
