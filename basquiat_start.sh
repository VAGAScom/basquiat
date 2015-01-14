#!/usr/bin/bash

exec 'bundle install'

echo '### Starting guard ####'
exec 'bundle exec guard start'

