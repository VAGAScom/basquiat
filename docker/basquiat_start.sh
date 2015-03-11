#!/usr/bin/bash
echo '#### Installing bundle ####'
bundle install --binstubs

echo '#### Starting guard ####'
(
  cd /basquiat
  bin/guard start
)
