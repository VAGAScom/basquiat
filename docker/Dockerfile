FROM mereghost/ruby:latest

RUN useradd -m -g users dev

VOLUME /basquiat
WORKDIR /basquiat

ENV REFRESHED_AT 2015-03-29
COPY Gemfile /tmp/Gemfile
RUN cd /tmp && bundle install
