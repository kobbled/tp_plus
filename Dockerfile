FROM ruby:3.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN apt-get update
#install package to convert windows line endings
RUN apt-get install dos2unix

WORKDIR /tp_plus

COPY . .
#convert windows line ending to unix
RUN git config --global core.autocrlf input
RUN find ./ -type f -exec dos2unix {} \;

RUN bundle install
RUN bundle exec rake

CMD ./bin/tpp