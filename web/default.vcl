# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

vcl 4.0;

backend default {
    .host = "127.0.0.1";
    .port = "8001";
}

include "redmine.vcl";
include "hackeriet.vcl";

sub vcl_recv {
    if (req.url ~ "^/munin|^/smokeping") {
        set req.backend_hint = default;
    }
}

sub vcl_backend_error {
 synthetic("Oh noes!");
   return (deliver);
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    if(!beresp.http.X-Message){
       set beresp.http.X-Message = "Soemthing fukced up!";
    }
    synthetic({"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
     <title>"} + beresp.status + " " + beresp.reason + {"</title>
  </head>
  <body>
     <h1>"} + beresp.status + " " + beresp.reason + {"</h1>
    "} + beresp.http.X-Message + {"
  </body>
</html>
"});
    unset beresp.http.X-Message;
    return (deliver);
}

