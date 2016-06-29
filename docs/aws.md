Implementation on AWS EC2
=========================

What you need:
1. A [Amazon EC2 instance](http://aws.amazon.com/ec2/). The basic Amazon Linux AMI should be enough. It comes with Ruby, Git and pretty much all you need. If you don't want to use EC2, you can use any kind of server with a recent version of Ruby installed with the ability to receive and send HTTP API traffic from the internet.

2. Maintainer access to your Transifex project.

3. The ability to add Service Hooks to your Github repo.

Once you've got your EC2 instance, [connect to it using ssh](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html). You'll do all your work from there. Take a note of its public DNS name, as you'll need it later.

    # Make sure you have all the build tools installed
    sudo yum groupinstall "Development Tools"

    # Install dependencies
    sudo yum install -y gcc-c++ patch readline readline-devel zlib \
    zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 \
    autoconf automake libtool bison iconv-devel

    # Install RVM
    bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)

    # Install Ruby
    rvm install 1.9.3

    # Install Bundler
    gem install bundler --no-rdoc --no-ri

    # Clone txgh
    git clone https://github.com/jsilland/txgh.git

    # Edit txgh config file
    cd txgh
    vim config/txgh.yml

Here is a sample yml file which you can fit to your configuration:

    txgh:
        github:
           repos:
               <your/full/repo/name>:
                    api_username: <your Github API username>
                    api_token: <your Github API token>
                    push_source_to: <transifex project slug>
       transifex:
            projects:
                <transifex project slug>:
                    tx_config: "/path/to/.tx/config, see below if you do not have any"
                    api_username: <Transifex API username>
                    api_password: <Transifex API password>
                    push_translations_to: <full/github/repo/name>


If your Transifex project currently uses the Transifex Command Line Client, you probably have a Transifex config file checked into your repo. Its default location is under a `.tx/` folder in the root of your git repo. If it doesn't contain one, use [this support article](/client/setup#installation) to create one, or use this template:


    [main]
    host = https://www.transifex.com

    [<transifex project slug>.<transifex resource slug>]
    file_filter = ./Where/Translated/<lang>/Files.Are
    source_file = ./Where/Source/Files.Are
    source_lang = <source lang>
    type = <FILETYPE>

Finally, start the server:

    # install bundled gems
    bundle install

    # start the server
    bundle exec rackup
    Puma 2.5.1 starting...
    * Min threads: 0, max threads: 16
    * Environment: development
    * Listening on tcp://0.0.0.0:9292

Now, you can keep the server running and go configure the webhooks in Transifex and in Github:

How to [configure webhooks in Github](https://help.github.com/articles/post-receive-hooks). You will want to point the new service hook you've created to:

    http://<public DNS name>:9292/hooks/github

To configure your webhooks in Transifex, you will need to go to your project management page and point the webhook URL to:

    http://<public DNS name>:9292/hooks/transifex

That's it! While this starts the server in development mode in a free ec2 server, if you do any kind of larger scale development, you would probably want to run this on a more stable instance, in production mode, with appropriate monitoring. But once you've configured the webhooks, any change that makes a file be 100% translated in Transifex will trigger the server to push a new commit to Github with the updated translations files and any change in Github to the source files will trigger the server to update the source content in Transifex.

