FROM mereghost/ruby:2.2.2

RUN useradd -mg users -G network dev
VOLUME /basquiat
WORKDIR /basquiat

ENV REFRESHED_AT 2015-03-29
USER dev
COPY Gemfile /tmp/Gemfile

#This is needed by bundler =/
ENV GEM_HOME=/home/dev/.gem
RUN cd /tmp && bundle install

EXPOSE 8808
