#!/bin/sh
function bundle_list() {
    bundle list
}

function generate_gemfile() {
    bundle_list | awk '
    BEGIN {
        FS=" "
        print "source \"https://rubygems.org\"";
        format = "gem \"%s\", \"%s\"\r\n";
    }
    {
        if ($2 == "bundler") {
            next;
        }
        if ($1 == "*") {
            match($3, "[^()]+");
            version = substr($3,RSTART,RLENGTH);
            printf format, $2, version;
        }
    }' > docker/Gemfile
}

generate_gemfile
#docker-compose start rabbitmq
#docker-compose run basquiat
