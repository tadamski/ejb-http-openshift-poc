package org.wildfly.oshttppoc.server;


import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Produces;

import javax.naming.Context;
import javax.naming.InitialContext;
import java.util.Hashtable;


@Path("/")
public class HelloWorldEndpoint {

//    @EJB
//    StatefulRemote bean;
//
    @GET
    @Produces("text/plain")
    public Response doGet() {
        Hashtable<String, String> table = new Hashtable<>();
        try {
            table.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
            //table.put(Context.URL_PKG_PREFIXES, "org.jboss.as.naming.interfaces");
            table.put(Context.PROVIDER_URL, "http://localhost:8380/wildfly-services");


            InitialContext ic = new InitialContext(table);
//            StatefulRemote statefulBean = (StatefulRemote) ic.lookup("java:ROOT/"
//                    + "StatefulBean" + "!" + StatefulRemote.class.getName());
            StatefulRemote statefulBean = (StatefulRemote) ic.lookup("java:ROOT/StatefulBean!org.wildfly.oshttppoc.server.StatefulRemote");
            //return Response.ok(bean.getId()).build();
        } catch(Exception e){
            e.printStackTrace();
        }
        return Response.ok("kukuryku").build();
    }
}
