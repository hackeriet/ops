# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

include "redmine.vcl";
include "hackeriet.vcl";

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
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

