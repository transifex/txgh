Transifex Txgh
====

[![Build Status](https://travis-ci.org/transifex/txgh.svg?branch=devel)](https://travis-ci.org/transifex/txgh)

Description
---
A lightweight web server that integrates Transifex with Github.  Txgh acts as an agent for developers by automatically uploading source files to Transifex.  It also acts as an agent for translators by pushing translation files to GitHub that have been 100% translated in Transifex.

Installation
---
To setup locally, clone this repository and install the dependencies from the Gemfile. You can place a txgh.yml file in your home directory to bootstrap configuration of the server.  The quickest way to get started is to clone the repository, update your configuration, and then run the puma web server on a specific port.
```ruby
puma -p 9292
```

Other platforms:

- [Amazon AWS](https://github.com/transifex/txgh/blob/devel/docs/aws.md)
- [Salesforce Heroku](https://github.com/transifex/txgh/blob/devel/docs/heroku.md)
- [Docker Container](https://github.com/transifex/txgh/blob/devel/docs/docker.md)

Directory Layout
---
```
.
|-- config
|   |-- tx.config   # sample config file
|   `-- txgh.yml    # ERB template for flexible config
|-- lib
|   |-- txgh
|   |   |-- handlers # Logic specific to endpoint hooks
|   |   |   |-- ...
|   |   |
|   |   |-- app.rb  # the main Sinatra app, includes both web service endpoints
|   |   |-- category_support.rb
|   |   |-- config.rb
|   |   |-- errors.rb
|   |   |-- github_api.rb               # Wrapper for GitHub REST API
|   |   |-- github_repo.rb              # GitHub repository object
|   |   |-- github_request_auth.rb      # GitHub webhook Auth
|   |   |-- handlers.rb
|   |   |-- key_manager.rb              # Loads configuration
|   |   |-- parse_config.rb
|   |   |-- transifex_api.rb            # Wrapper for Tx REST API
|   |   |-- transifex_project.rb        # Tx Project Object
|   |   |-- transifex_request_auth.rb   # Tx webhook auth
|   |   |-- tx_branch_resource.rb       # Support for branches
|   |   |-- tx_config.rb                # Loads tx.config
|   |   |-- tx_logger.rb
|   |   |-- tx_resource.rb              #Tx resource Object
|   |   `-- utils.rb
|   `-- txgh.rb     # includes for app dependencies
|-- spec # spec unit and integration tests
|   |-- ...
|
|-- Dockerfile      # DIY Docker base
|-- Rakefile        # rake tasks to run tests
|-- bootstrap.rb    # includes for application paths
`-- config.ru       # bootstrap for web server
```


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


Notes
---

We recommend running it using Ruby 2.2.2 and installing dependencies via bundler.

There are 2 important configuration files.

txgh.yml - This is the base configuration for the service.  To avoid needing to checkin sensitive password information, this file should pull it's settings from the Ruby ENV in production.  Additionally, this file can be located in the users HOME directory to support running the server with local values.

```yaml
txgh:
  github:
    repos:
      # This name should be org/repo
      MyOrg/frontend:
        api_username: "github_username"
        api_token: "github_token"
        # Transifex project name, as below
        push_source_to: "my-frontend" 
        # The branch to watch. Set to 'all' to listen to all pushes.
        branch: "i18n"
        # Create a repo webhook. The secret is any string of your choosing,
        # and is input during webhook creation. TXGH uses this to validate
        # messages are really coming from GitHub.
        webhook_secret: "..." 
  transifex:
    projects:
      # This name should match the transifex project name, without org name
      my-frontend:
        tx_config: "./config/tx.config"
        api_username: "transifex_user"
        api_password: "transifex_password"
        # This is the GitHub project name, as above.
        push_translations_to: "MyOrg/frontend" 
        # This can be 'translated' or 'reviewed'. To catch both actions,
        # simply remove this key.
        push_trigger: "translated"
        # This works similarly to the GitHub webhook_secret above.
        webhook_secret: "..."
```

tx.config - This is a configuration which maps the source file, languages, and target translation files.  It is based on this specification: http://docs.transifex.com/client/config/#txconfig

Getting Help
---
You can always get additional help via [GitHub Issues](https://github.com/transifex/txgh/issues) or [Transifex support email](support@transifex.com)

License
---
Txgh is primarily distributed under the terms of the Apache License (Version 2.0).

See [LICENSE](https://github.com/transifex/txgh/blob/master/LICENSE) for details.



