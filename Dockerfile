FROM ruby:2.1-onbuild
EXPOSE 9292
CMD ["puma", "-p", "9292"]
