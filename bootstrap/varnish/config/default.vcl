vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "192.100.100.7";
    .port = "80";
}

# Handling incoming requests
sub vcl_recv {
    # Set the client IP address
    set req.http.X-Forwarded-For = client.ip;

    # Pass certain URLs directly to the backend
    if (req.url ~ "^/(admin|customer|checkout|my-account)") {
        return (pass);
    }

    # Cache static assets for a longer duration
    if (req.url ~ "\.(css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|svg|eot)$") {
        unset req.http.Cookie;
        return (hash);
    }

    # Pass the rest of the requests to the backend
   return (pass);

    if (req.url ~ "^/$") {
        set req.url = "/index.php"; // Specify the Magento entry point file
        set req.backend_hint = default; // Point the request to the Magento server
    }
}

# Handling the response from the backend
sub vcl_backend_response {
    # Allow Magento-generated cookies to be cached
    if (beresp.http.Set-Cookie) {
        unset beresp.http.Set-Cookie;
    }

    # Cache static assets for a longer duration
    if (bereq.url ~ "\.(css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|svg|eot)$") {
        set beresp.ttl = 30d;  # Cache static assets for 30 days
    }

    # Cache dynamic HTML content for a shorter duration
    if (bereq.url ~ "\.html$" || beresp.http.Content-Type ~ "text/html") {
        set beresp.ttl = 1m;  # Cache dynamic HTML for 1 minute
    }
# Set the correct redirect location for the root URL
    if (bereq.url ~ "^/$") {
        set beresp.http.location = "/"; // Set the correct redirect location for the root URL
    }
}

sub vcl_deliver {
    # Add a custom header to indicate Varnish cache hit or miss
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}
