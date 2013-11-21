txgh
====

A Sinatra server that integrates Transifex with GitHub

How it works
====

You configure a service hook in Github and point it to this server. The URL path is /hooks/github.
You do the same for Transifex, in your project settings page, and point it to the /hooks/transifex URL path.

For every change to a source translation file in Github, the server will update the content in Transifex. For every change to a translation in Transifex, the server will create a commit and push it to Github with the new translations.

How run it
===

In order to run the server, you need to have Ruby and bundler installed:

```BASH
# Install RVM
bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

# Install Ruby
rvm install 1.9.3

# Install Bundler
gem install bundler --no-rdoc --no-ri
```


The server also needs some configuration, in a config/txgh.yml file:

```YAML
txgh:
    github:
        repos:
            <your/full/repo/name>:
                api_username: <your Github API username>
                api_token: <your Github API token>
                push_source_to: ios-transifex-demo
    transifex:
        projects:
            <transifex project slug>:
                tx_config: "/path/to/.tx/config, see below if you do not have any"
                api_username: <Transifex API username>
                api_password: <Transifex API password>
                push_translations_to: <full/github/repo/name>
```

If your project uses Transifex already, and uses the Transifex client, you most likely have a .tx directory in your repo where the .tx config file mentioned above is located. If you do not have one, you can use this template to make your own:

```
[main]
host = https://www.transifex.com
lang_map =

# Create one such section per resource
[<transifex project slug>.<transifex resource slug>]
file_filter = ./Where/Translated/<lang>/Files.Are
source_file = ./Where/Source/Files.Are
source_lang = <source lang>
type = <FILETYPE>

```

