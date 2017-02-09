Implementing on Heroku
======================

Heroku provides a command-line tool for interacting with applications. When you create a new application, Heroku creates a remote Git repository (with a branch named heroku), which you can then push your code to. Change your current directory to the Txgh project’s root directory and enter the following command:
```
$ heroku create
Creating nameless-eyrie-4025... done, stack is cedar-14
https://nameless-eyrie-4025.herokuapp.com/ | https://git.heroku.com/nameless-eyrie-4025.git
Git remote heroku added
```
By default, Heroku provides a randomly generated name, but you can supply one as a parameter. Once the new application has been created, you need to generate a Gemfile.lock and commit it to your repository. This is counter to how most projects work in git, but is a Heroku requirement:
```
$ bundle install
Fetching gem metadata from https://rubygems.org/............
Fetching version metadata from https://rubygems.org/...
Fetching dependency metadata from https://rubygems.org/..
Resolving dependencies...
Using rake 12.0.0
Using public_suffix 2.0.5
Using addressable 2.5.0
Using backports 3.6.8
Using coderay 1.1.1
Using safe_yaml 1.0.4
Using crack 0.4.3
Using diff-lcs 1.3
Using multipart-post 2.0.0
Using faraday 0.11.0
Using faraday_middleware 0.11.0.1
Using hashdiff 0.3.2
Using json 2.0.3
Using method_source 0.8.2
Using multi_json 1.12.1
Using sawyer 0.8.1
Using octokit 4.6.2
Using parseconfig 1.0.8
Using slop 3.6.0
Using pry 0.10.4
Using pry-nav 0.2.4
Using puma 3.7.0
Using rack 1.6.5
Using rack-protection 1.5.3
Using rack-test 0.6.3
Using rspec-support 3.5.0
Using rspec-core 3.5.4
Using rspec-expectations 3.5.0
Using rspec-mocks 3.5.0
Using rspec 3.5.0
Using shotgun 0.9.2
Using tilt 2.0.6
Using sinatra 1.4.8
Using sinatra-contrib 1.4.7
Using vcr 3.0.3
Using webmock 1.24.6
Using bundler 1.10.6
Bundle complete! 16 Gemfile dependencies, 37 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
$ git add -f Gemfile.lock
$ git commit -m"Adding Gemfile.lock for Heroku's benefit"
```
Then you can deploy your app by using git:

```
$ git push heroku master
Counting objects: 156, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (71/71), done.
Writing objects: 100% (156/156), 33.84 KiB | 0 bytes/s, done.
Total 156 (delta 65), reused 155 (delta 65)
remote: Compressing source files... done.
remote: Building source:
remote:
remote: -----> Ruby app detected
remote: -----> Compiling Ruby/Rack
remote: -----> Using Ruby version: ruby-2.0.0
remote: -----> Installing dependencies using bundler 1.9.7
...
remote: -----> Compressing... done, 18.3MB
remote: -----> Launching... done, v4
remote:        https://nameless-eyrie-4025.herokuapp.com/ deployed to Heroku
remote:
remote: Verifying deploy.... done.
To https://git.heroku.com/nameless-eyrie-4025.git
 * [new branch]      master -> master
```

You can verify the success of the deployment by opening the Heroku dashboard in your web browser and navigating to the newly created dyno.

##Updating the Configuration

Before you can start pushing updates between GitHub and Transifex, you’ll need to provide the Heroku app with information on how to access each service. Txgh uses a set of environment variables to manage connections between each service. The name and description of these variables is shown in the table below:

| Variable | Description | Example |
| -------- | ----------- | ------- |
| TX_CONFIG_PATH | Location of your Transifex project’s configuration file relative to Txgh’s root folder. | ./config/tx.config |
| TX_USERNAME | Your Transifex username. | txuser |
| TX_PASSWORD | Password to your Transifex account. | 1324578 |
| TX_PUSH_TRANSLATIONS_TO | Name of the GitHub repository that Txgh will push updates to. | ghuser/my_repository |
| TX_WEBHOOK_SECRET | Secret key given to Transifex to authenticate the webhook request (optional) | please-dont-use-this-example |
| GITHUB_BRANCH | GitHub branch to update. | heads/master |
| GITHUB_USERNAME | Your GitHub username. | ghuser |
| GITHUB_TOKEN | A personal API token created in GitHub. | 489394e58d99095d9c6aafb49f0e2b1e |
| GITHUB_PUSH_SOURCE_TO | Name of the Transifex project that Txgh will push updates to. | my_project |
| GITHUB_WEBHOOK_SECRET | Secret key given to Github to authenticate the webhook request (optional) | please-dont-use-this-example |

If you want to use webhook secrets, you'll need to add them to your txgh.yml as well.  Add `webhook_secret: "<%= ENV['GITHUB_WEBHOOK_SECRET'] %>"` to the Github repo block in there, and `webhook_secret: "<%= ENV['TX_WEBHOOK_SECRET'] %>"` in the Transifex block.

There are two ways to apply these to your Heroku app:

- Add the environment variables through Heroku’s web interface.

Create a local file containing your environment variables and apply it using rake.
Add Environment Variables Through the Heroku Dashboard
Open the Heroku dashboard in your web browser. Click on the Settings tab and scroll down to the Config Variables section. Click Reveal Config Vars, then click Edit. You’ll have access to the application’s existing variables, but more importantly you can add new variables. Add the variables listed above and click Save.

- Config vars

**Note** The RACK_ENV variable defaults to production, but in order for it to work with Txgh we need to set it to test.

Add Environment Variables Using txgh_config.rb
The txgh_config.rb file stores our environment variables inside of the Txgh folder. To create the file, copy and paste the following into a new text file. Replace the placeholder values with your actual values and save the file in the config directory as txgh_config.rb.

```
# 'test' only ENV['RACK_ENV']
config_env :test do
    set 'TX_CONFIG_PATH', './config/tx.config'
    set 'TX_USERNAME', 'txuser'
    set 'TX_PASSWORD', '1324578'
    set 'TX_PUSH_TRANSLATIONS_TO', 'ghuser/my_repository'
    set 'GITHUB_BRANCH', 'heads/master'
    set 'GITHUB_USERNAME', 'ghuser'
    set 'GITHUB_TOKEN', '489394e58d99095d9c6aafb49f0e2b1e'
    set 'GITHUB_PUSH_SOURCE_TO', 'my_project'
end
```
To apply the changes to your Heroku dyno, use the rake command:

```
$ rake config_env:heroku
Running echo $RACK_ENV on nameless-eyrie-4025... up, run.2376
Configure Heroku according to config_env[test]

=== nameless-eyrie-4025 Config Vars
LANG:                          en_US.UTF-8
RACK_ENV:                      test
GITHUB_TOKEN:                  489394e58d99095d9c6aafb49f0e2b1e
GITHUB_USERNAME:               ghuser
GITHUB_PUSH_SOURCE_TO:         my_project
TX_PASSWORD:                   1324578
TX_USERNAME:                   txuser
TX_PUSH_TRANSLATIONS_TO:       ghuser/my_repository
TX_CONFIG_PATH:                ./config/tx.config
```

This command updates the configuration of your Heroku app with the values specified in `txgh_config.rb` If you have any issues running the rake command, run bundle install in the Txgh project’s root directory. This compiles and installs the Ruby gems required by Txgh. Once the install completes, run the rake command again.


**Note** Since this file contains sensitive information, you should avoid committing it to your Heroku repository or to your GitHub repository.

Once the rake command has completed successfully, open the Heroku dashboard, navigate to the application’s settings and click Reveal Config Vars.

##Final Configuration Steps
The last step is to change the value of the RACK_ENV variable. By default, Heroku sets the value of RACK_ENV to production. However, we recommend testing Txgh by setting this value to test. If you haven’t already, open your application’s environment variables in a web browser and change the value of RACK_ENV from production to test. When you’re ready to deploy, you can change this value back to production.

Meanwhile, check the values of your other variables. If any values seem incorrect, you can edit them in your browser or edit and re-apply the txgh_config.rb file using rake. Once everything looks good, you can add your webhooks to Transifex and GitHub.

##Connecting Transifex and GitHub to Txgh

Txgh synchronizes your Transifex and GitHub projects using webhooks, allowing Txgh to respond immediately to changes in either service. The webhook URLs follow the format https://HEROKUNAME.herokuapp.com/hooks/SOURCE, where HEROKUNAME is the name of your deployed Heroku app and SOURCE is either “transifex” or “github”.

For instance, we’ll use the following URL with Transifex:

https://nameless-eyrie-4025.herokuapp.com/hooks/transifex

and the following URL with GitHub:

https://nameless-eyrie-4025.herokuapp.com/hooks/github

Open your project in Transifex. Under More Project Options, click Manage.

In the Features section at the bottom of the screen is a text box titled Web Hook URL. Enter in the URL you created from your Heroku app, then click Save Project.

Connecting Your GitHub Repository
Connecting a GitHub repository is similar. Open your repository in a web browser and click Settings.

Under Webhooks & services, click to add a webhook. You may be asked to confirm your password. Enter the Heroku app URL for the Payload URL and change the Content type to application/x-www-form-urlencoded.

Click Add webhook to create your new webhook. GitHub will ping the URL to test its validity. You can check whether the ping was successful by reloading the page.

Next, we’ll test out the integration by moving translations between GitHub and Transifex.

##Testing It Out

To test the integration, we’ll push a new commit to GitHub, then we’ll use the new commit to update translations in Transifex.

First, add a new string to the language source file in your Transifex project. Save your changes, then push the code to your GitHub repository. The push will automatically trigger the webhook. You can verify that webhook was successful by opening GitHub in a browser, navigating to the Webhooks & services, clicking on the webhook URL, and reviewing Recent Deliveries.

If successful, you should see the new source strings in your Transifex project.

Update the translations in Transifex. Back in your GitHub repository, review the latest commits. You should see a commit from Transifex with the latest updates to the target language.
