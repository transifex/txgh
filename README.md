Transifex Txgh
====

[![Build Status](https://travis-ci.org/transifex/txgh.svg?branch=devel)](https://travis-ci.org/transifex/txgh)

A Sinatra server that integrates Transifex with GitHub

How it works
---

You configure a service hook in Github and point it to this server. The URL path to the service hook endpoint: /hooks/github
You do the same for Transifex, in your project settings page, and point it to the service hook endpoint: /hooks/transifex

Currently there are 4 use cases that are supported:

1) When a resource (configured in this service) in Transifex reaches 100% translated, the Txgh service will pull the translations and commit them to the target repository.

2) When a source file (configured in this service) is pushed to a specific Github branch (also configured in this service), the Txgh service will update the source resource (configured in this service) with the new file.

3) When a source file (configured in this service) is pushed to a specific Github tag (also configured in this service), the Txgh service will update the source resource (configured in this service) with the new file.

4) EXPERIMENTAL - When a source file (configured in this service) is pushed to a specific Github tag called 'L10N', Txgh will create a new branch called 'L10N' and new resources where the slug is prefixed with 'L10N'.

![Txgh Use Cases](https://www.gliffy.com/go/publish/image/9483799/L.png)


How run it
---

In order to run the server, you need to have Ruby 2.1.5 and bundler installed.

There are 2 important configuration files.

txgh.yml - This is the base configuration for the service.  For 12 factor app support, this file should pull it's settings from the Ruby ENV.  Additionally, this file can be located in the users $HOME directory to support running the server with hard coded values.


tx.config - This is a configuration which maps the source file, languages, and target translation files.  It is based on this specification: http://docs.transifex.com/client/config/#txconfig


AWS
---

https://github.com/transifex/txgh/issues/14


Heroku
---

https://www.transifex.com/blog/2015/bridging-github-and-transifex-with-txgh/



