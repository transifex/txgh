FROM ruby:2.3

EXPOSE 9292

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY ./Gemfile /usr/src/app/
COPY ./Gemfile.lock /usr/src/app/
COPY ./txgh.gemspec /usr/src/app/
COPY ./lib/txgh/version.rb /usr/src/app/lib/txgh/
RUN bundle install --jobs=3 --retry=3

COPY . /usr/src/app

CMD ["puma", "-p", "9292"]
