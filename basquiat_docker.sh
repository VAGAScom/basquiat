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

function stop_and_remove_containers {
    docker-compose stop rabbitmq
    docker rm basquiat_basquiat_run_1
    docker rm --volumes=true basquiat_rabbitmq_1 
}

generate_gemfile
docker-compose start rabbitmq
docker-compose run --service-ports basquiat

trap stop_and_remove_containers EXIT SIGINT SIGTERM SIGKILL
