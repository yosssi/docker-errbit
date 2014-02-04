# Errbit
#
# VERSION 1.0

# Use the ubuntu base image provided by dotColud
FROM ubuntu

MAINTAINER Keiji Yoshida, yoshida.keiji.84@gmail.com

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2 libxml2-dev libxslt-dev libcurl4-openssl-dev
RUN apt-get clean

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
ENV PATH ~/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install ruby-build
RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 2.1.0
RUN bash -l -c 'rbenv install 2.1.0'
RUN bash -l -c 'rbenv global 2.1.0'

# Install MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update
RUN apt-get install -y --force-yes mongodb-10gen
RUN mkdir -p /mongodb/data
RUN mkdir /mongodb/log

# Install Bundler
RUN bash -l -c 'gem install bundler'

# Install Errbit
RUN git clone https://github.com/errbit/errbit.git ~/errbit
RUN bash -l -c 'cd ~/errbit; bundle install'
RUN bash -l -c 'mongod --dbpath /mongodb/data --logpath /mongodb/log/mongo.log &'; bash -l -c 'cd ~/errbit; rake errbit:bootstrap';

# Launch rails server
ENTRYPOINT bash -l -c 'cd ~/errbit; script/rails server'

# Expose rails server port
EXPOSE 3000
