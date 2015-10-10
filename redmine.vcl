backend redmine {
   .host = "projects.hackeriet.no";
}

sub vcl_recv { 
   if(req.http.host ~ "^(www\.)?(procrastinate|redmine|projects?|humla|metafusion)\."){
      if(req.url ~ "^/$") {
         if(req.http.host ~ "hackeriet.no") {
            set req.url = "/projects/hackeriet";
         }
         if(req.http.host ~ "badface.eu") {
            set req.url = "/projects/hausmania";
         }
         if(req.http.host ~ "humla.info") {
            set req.url = "/projects/humla";
         }
         if(req.http.host ~ "metafusion.no") {
            set req.url = "/projects/metafusion";
         }
      }
      if(!req.http.host ~ "projects.hackeriet.no|metafusion.no|humla.info|delta9.pl"){
         set req.http.location = "https://projects.hackeriet.no";
         return (synth(751, "Moved Permanently"));
      }
      set req.http.x-host = req.http.host;
      set req.http.host = "projects.hackeriet.no";
      set req.backend_hint = redmine;
      // serve over wsgi instead
      //set req.backend_hint = nginx;
   }
}

sub vcl_deliver {
   # necessary?
   if(req.http.x-host && !req.http.x-host ~ "projects" && resp.http.location ~ "projects\.hackeriet\.no") {
      set resp.http.location = regsub(resp.http.location, "projects.hackeriet.no", req.http.X-Host);
   }
}

