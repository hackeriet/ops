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

