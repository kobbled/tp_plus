FROM ruby:3.1.2-alpine3.15

RUN apk add --no-cache bash
RUN /bin/sh
RUN apk update && apk add --virtual build-dependencies build-base
RUN apk add --no-cache git
RUN gem install bundler -v 2.3.11

#add env
ENV TPP_REPO /tp_plus
ENV TPP_FILE /tp_plus/bin/tpp
RUN echo 'alias tppmake="bundle exec ruby $TPP_FILE"' >> ~/.bashrc
ENV PATH=$PATH:/tp_plus/bin

WORKDIR $TPP_REPO

COPY . .

RUN bundle install
RUN bundle exec rake

ENTRYPOINT ["/bin/sh"]