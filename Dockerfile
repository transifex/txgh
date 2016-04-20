FROM ruby:2.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app
RUN bundle install --jobs=3 --retry=3

EXPOSE 9292

CMD ["puma", "-p", "9292"]
