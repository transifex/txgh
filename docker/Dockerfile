FROM ruby:2.3

EXPOSE 9292

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY ./Gemfile /usr/src/app/
COPY ./Gemfile.lock /usr/src/app/
RUN bundle install --jobs=3 --retry=3

COPY ./config.ru /usr/src/app

CMD ["puma", "-p", "9292"]
