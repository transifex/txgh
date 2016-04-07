Transifex Txgh (Lumos Labs fork)
====

[![Build Status](https://travis-ci.org/lumoslabs/txgh.svg?branch=master)](https://travis-ci.org/lumoslabs/txgh)

Txgh, a mashup of "Transifex" and "Github", is a lightweight server that connects Transifex to Github via webhooks. It enables automatic translation of new content in your Github repository, and supports single-resource as well as branch-based git workflows.


How Does it Work?
---

Configure Transifex and Github:

1. Add a service hook to your Github repo and point it to your running Txgh instance.
2. Configure a service hook for your project in Transifex (via the settings page).

This enables the following automated processes:

1. When a source file is pushed to Github, the Txgh service will update the corresponding Transifex resource with the contents of the new file. Configuration options exist to process only certain branches and tags.

2. When a resource in Transifex reaches 100% translated, the Txgh service will download the translations and commit them to the target repository. Configuration options exist to protect certain branches or tags from automatic commits.

<br>
For the more visually inclined:
![Txgh Use Cases](https://www.gliffy.com/go/publish/image/9483799/L.png)
<br>
<br>

Supported Workflows
---

Use the following table to determine if Txgh will work for your git and translation workflow:

|Workflow|Comments|
|:--------|:----------|
|**Basic**<br>* You maintain one master version of your translations<br>* Translations may not be under source control<br>* New content is translated before each release and does not change|This is the default. Txgh <br> can also be configured to only<br> listen for changes that happen<br> on a certain branch or tag.|
|**Multi-branch**<br>* Your team is small or everyone works from the same branch<br>* Translations should change when code changes|You might want to consider <br>multi-branch with diffs (below)<br> since your translators may see<br> a number of duplicate strings<br> in Transifex using this workflow.|
|**Multi-branch with Diffs**<br>* Your team uses git branches for feature development<br>* Translations should change when code changes|This is the recommended workflow<br> if you'd like to manage translations<br> in an agile way, i.e. "continuous<br> translation." Only new and changed<br> phrases are uploaded to Transifex.|

Configuring Txgh
---

Config is written in the YAML markup language and is comprised of two sections, one for Github config and one for Transifex config:

```yaml
---
github:
  repos:
    organization/repo:
      api_username: github username
      api_token: abcdefghijklmnopqrstuvwxyz github api token
      push_source_to: transifex project slug
      branch: branch to watch for changes, or "all" to watch all of them
      tag: tag to watch for changes, or "all" to watch all of them
      webhook_secret: 123abcdef456ghi github webhook secret
      diff_point: branch to diff against (usually master)
transifex:
  projects:
    project-slug:
      tx_config: map of transifex resources to file paths
      api_username: transifex username
      api_password: transifex password (transifex doesn't support token-based auth)
      push_translations_to: organization/repo
      protected_branches: branches that should not receive automatic commits
      webhook_secret: 123abcdef456ghi transifex webhook secret
      auto_delete_resources: 'true' to delete resource when branch is deleted
```

### Github Configuration

* **`api_username`**
* **`api_token`**
* **`push_source_to`**
* **`branch`**
* **`tag`**
* **`webhook_secret`**
* **`diff_point`**

### Transifex Configuration

* **`tx_config`**
* **`api_username`**
* **`api_password`**
* **`push_translations_to`**
* **`protected_branches`**
* **`webhook_secret`**
* **`auto_delete_resources`**

### Loading Config

Txgh supports two different ways of accessing configuration, raw text and a file path. In both cases, config is passed via the `TXGH_CONFIG` environment variable. You'll prefix the raw text or file path with the appropriate scheme, `raw://` or `file://`, to indicate which strategy Txgh should use.

#### Raw Config

Passing raw config to Txgh can be done like this:

```bash
export TXGH_CONFIG="raw://big_yaml_string_here"
```

When Txgh runs, it will parse the YAML payload that starts after `raw://`.

#### File Config

It might make more sense to store all your config in a file. Pass the path to Txgh like this:

```bash
export TXGH_CONFIG="file://path/to/config.yml"
```

When Txgh runs, it will read and parse the file at the path that comes after `file://`.

Of course, in both the file and the raw case, environment variables can be specified via `export` or inline when starting Txgh. See the "Running Txgh" section below for more information.

Running Txgh
---

Txgh is distributed as a [Docker image](https://quay.io/repository/lumoslabs/txgh) and as a [Rubygem](https://rubygems.org/gems/txgh). You can choose to run it via Docker, install and run it as a Rubygem, or run it straight from a local clone of this repository.

### With Docker

Using Docker to run Txgh is pretty straightforward (keep in mind you'll need to have the Docker server set up wherever you want to run Txgh).

First, pull the Txgh image:

```bash
docker pull quay.io/lumoslabs/txgh:latest
```

Run the image in a new container:

```bash
docker run
  -p 9292:9292
  -e "TXGH_CONFIG=raw://$(cat path/to/config.yml)"
  quay.io/lumoslabs/txgh:latest
```

At this point, Txgh should be up and running. To test it, try hitting the `health_check` endpoint. You should get a 200 response:

```bash
curl -v localhost:9292/health_check
....
< HTTP/1.1 200 OK
```

Note that Txgh might not be available on localhost depending on how your Docker client is configured. On a Mac with [docker-machine](https://docs.docker.com/machine/) for instance, you might try this instead:

```bash
curl -v 192.168.99.100:9292/health_check
```

(Where 192.168.99.100 is the IP of your docker machine instance).

### From Rubygems

Docker is by far the easiest way to run Txgh, but a close runner-up is via Rubygems. You'll need to have at least Ruby 2.1 installed as well as the [bundler gem](http://bundler.io/). Installing ruby and bundler are outside the scope of this README, but I'd suggest using a ruby installer like [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to get the job done. Once ruby is installed, executing `gem install bundler` should be enough to install the bundler gem.

1. Create a new directory for your Txgh instance.
2. Inside the new directory, create a file named `Gemfile`. This file is a manifest of all your ruby dependencies.
3. Inside `Gemfile`, add the following lines:

  ```ruby
  source 'http://rubygems.org'
  gem 'txgh', '~> 1.0'
  ```
  When bundler parses this file, it will know to fetch dependencies from rubygems.org, the most popular and ubiquitous gem host. It will also know to fetch and install the txgh gem.
4. Create another file next to `Gemfile` named `config.ru`. This file describes how to run the Txgh server, including where to mount the various endpoints.
5. Inside `config.ru` add the following lines:

  ```ruby
  require 'txgh'

  map '/' do
    use Txgh::Application
    use Txgh::Triggers
    run Sinatra::Base
  end

  map '/hooks' do
    use Txgh::Hooks
    run Sinatra::Base
  end
  ```

  Where each endpoint is mounted is entirely configurable inside this file, as is any additional middleware or your own custom endpoints you might want to add. Txgh is built on the [Rack](http://rack.github.io/) webserver stack, meaning the wide world of Rack is available to you inside this file. The `map`, `use`, and `run` methods are part of Rack's builder syntax.

6. Run `TXGH_CONFIG=file://path/to/config.yml bundle exec rackup`. The Txgh instance should start running.
7. Test your Txgh instance by hitting the `health_check` endpoint as described above in the "With Docker" section, i.e. `curl -v localhost:9292/health_check`. You should get an HTTP 200 response.

### Local Clone

Running Txgh from a local copy of the source code requires almost the same setup as running it from Rubygems. Notably the `config.ru` file has already been written for you.

Refer to the "From Rubygems" section above to get ruby and bundler installed before continuing.

1. Clone Txgh locally:

  ```bash
  git clone git@github.com:lumoslabs/txgh.git
  ```

2. Change directory into the newly cloned repo (`cd txgh`) and run `bundle` to install gem dependencies.
3. Run `TXGH_CONFIG=file://path/to/config.yml bundle exec rackup`. The Txgh instance should start running.

4. Test your Txgh instance by hitting the `health_check` endpoint as described above in the "With Docker" section, i.e. `curl -v localhost:9292/health_check`. You should get an HTTP 200 response.

Running Tests
---

Txgh uses the popular RSpec test framework and has a comprehensive set of unit and integration tests. To run the full test suite, run `bundle exec rake spec:full`, or alternatively `FULL_SPEC=true bundle exec rspec`. To run only the unit tests (which is faster), run `bundle exec rspec`.

Requirements
---

Txgh requires an Internet connection to run, since its primary function is to connect two web services via webhooks and API calls. Other than that, it does not have any other external requirements like a database or cache.

Compatibility
---

Txgh was developed with Ruby 2.1.6, but is probably compatible with all versions between 2.0 and 2.3, and maybe even 1.9. Your mileage may vary when running on older versions.

Authors
---

This repository is a fork of the [original](https://github.com/transifex/txgh) and is maintained by [Cameron Dutro](https://github.com/camertron) from Lumos Labs.

License
---

Licensed under the Apache License, Version 2.0. See the LICENSE file included in this repository for the full text.
