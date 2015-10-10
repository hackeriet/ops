backend nginx {
    .host = "127.0.0.1";
    .port = "8001";
}

backend oldweb {
    .host = "31.185.27.119";
    .port = "80";
}

backend meetupapi {
    .host = "190.93.245.216";
}



backend door {
    .host = "door.hackeriet.no";
}

sub vcl_recv {
    if(req.http.host ~ "hackeriet\.no$") {
        if(req.url ~ "topic.jsonp|door.json"){
            set req.backend_hint = door;
            set req.http.host = "door.hackeriet.no";
            return(pass);
        }
        if (req.http.host ~ "^hackeriet\.no") {
            if(req.url ~ "meetup.json") {
                set req.url = "/2/events?offset=0&format=json&limited_events=False&group_urlname=hackeriet&photo-host=public&time=0d%2C1m&page=500&fields=&order=time&status=upcoming&desc=false&sig_id=89312252&sig=08383e6376d49121d671a67b602b62f80a0fb6ac";
                set req.http.host = "api.meetup.com";
                set req.backend_hint = meetupapi;
                return (hash);
            }

            # redirect human friendly links
            if(req.url ~ "\.(login|edit)$"){
                return(synth(750, "http://oldwww.hackeriet.no" + req.url));
            }
            if(req.url ~ "^/member"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Membership"));
            }
            if(req.url ~ "^/money"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Money"));
            }
            if(req.url ~ "^/goals"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Goals"));
            }
            if(req.url ~ "^/conduct"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Conduct"));
            }
            if(req.url ~ "^/newcomers(_guide)?"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Newcomers_Guide"));
            }
            if(req.url ~ "^/workshops"){
                return(synth(751, "http://oldwww.hackeriet.no/workshops"));
            }
            if(req.url ~ "^/events"){
                return(synth(751, "http://oldwww.hackeriet.no/events"));
            }
            if(req.url ~ "^/people"){
                return(synth(751, "http://oldwww.hackeriet.no/people"));
            }
            if(req.url ~ "^/captains"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Routines#Captains"));
            }
            if(req.url ~ "^/history"){
                return(synth(751, "http://oldwww.hackeriet.no/history"));
            }
            if(req.url ~ "^/bylaws"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Bylaws"));
            }
            if(req.url ~ "^/wantedstuff"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/Wantedstuff"));
            }
            if(req.url ~ "^/coolstuffwehave"){
                return(synth(750, "https://hackeriet.no/projects/hackeriet/wiki/CoolStuffWeHave"));
            }

            # redmine owns the following subfolders
            if(req.url ~ "^/(projects|admin|javascripts|themes|plugin_assets|stylesheets|images)"){
                set req.backend_hint = redmine;

            } elsif (req.url ~ "^/$"){

                # rewrite front page to redmine
                set req.backend_hint = redmine;

            } else {
                # load everything else from web server
                set req.backend_hint = nginx;
            }
        }
        if (req.http.host ~ "^www\.hackeriet\.no") {
            return(synth(751, "https://hackeriet.no" + req.url));
        }
        if (req.http.host ~ "^oldwww\.hackeriet\.no") {
            set req.http.host = "hackeriet.no";
            set req.backend_hint = oldweb;
        }
    }
}
sub vcl_backend_response {
    if (bereq.url ~ "jsapi") {
          set beresp.http.Content-Type = "application/javascript";
    }
    if (bereq.url ~ "saved_resource") {
          set beresp.http.Content-Type = "application/javascript";
    }
}
sub vcl_synth {
    if(resp.status == 750){
        set resp.http.Location = resp.reason;
        set resp.status = 301;
        set resp.reason = "Permanent Redirect";
    }
    if(resp.status == 751){
        set resp.http.Location = resp.reason;
        set resp.status = 301;
        set resp.reason = "Temporary Redirect";
    }
}

sub vcl_backend_response {
   # remove the comotion in the redirect
   if (beresp.http.location ~ "http://comotion\.hackeriet\.no"){
      set beresp.http.location = regsub(beresp.http.location, "comotion\.", "");
   }
}

sub vcl_deliver {
    if(req.url ~ "jsonp") {
       set resp.http.Content-Type = "application/javascript";
    }
}
