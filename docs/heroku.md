Implementing on Heroku
======================

Heroku provides a command-line tool for interacting with applications. When you create a new application, Heroku creates a remote Git repository (with a branch named heroku), which you can then push your code to. Change your current directory to the Txgh project’s root directory and enter the following command:
```
$ heroku create
Creating nameless-eyrie-4025... done, stack is cedar-14
https://nameless-eyrie-4025.herokuapp.com/ | https://git.heroku.com/nameless-eyrie-4025.git
Git remote heroku added
```
By default, Heroku provides a randomly generated name, but you can supply one as a parameter. Once the new application has been created, you can deploy your app by using git:

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
```
[table]
Variable,Description,Example
transifex_project_config_tx_config,Location of your Transifex project’s configuration file relative to Txgh’s root folder.,./config/tx.config
transifex_project_config_api_username,Your Transifex username.,txuser
transifex_project_config_api_password,Password to your Transifex account.,1324578
transifex_project_config_push_translations_to,Name of the GitHub repository that Txgh will push updates to.,ghuser/my_repository
transifex_project_config_push_translations_to_branch,GitHub branch to update.,heads/master
github_repo_config_api_username,Your GitHub username.,ghuser
github_repo_config_api_token,A personal API token created in GitHub.,489394e58d99095d9c6aafb49f0e2b1e
github_repo_config_push_source_to,Name of the Transifex project that Txgh will push updates to.,my_project
[/table]
```
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
    set 'transifex_project_config_tx_config', './config/tx.config'
    set 'transifex_project_config_api_username', 
    set 'transifex_project_config_api_password', 
    set 'transifex_project_config_push_translations_to', 
    set 'transifex_project_config_push_translations_to_branch', 'heads/master'
    set 'github_repo_config_api_username', 
    set 'github_repo_config_api_token', 
    set 'github_repo_config_push_source_to', 
end
```
To apply the changes to your Heroku dyno, use the rake command:

```
$ rake config_env:heroku
Running echo $RACK_ENV on nameless-eyrie-4025... up, run.2376
Configure Heroku according to config_env[test]

=== nameless-eyrie-4025 Config Vars
LANG:                                          en_US.UTF-8
RACK_ENV:                                      test
github_repo_config_api_token:                  489394e58d99095d9c6aafb49f0e2b1e
github_repo_config_api_username:               ghuser
github_repo_config_push_source_to:             nodejs-test
transifex_project_config_api_password:         12345678
transifex_project_config_api_username:         txuser
transifex_project_config_push_translations_to: ghuser/nodejs-test
transifex_project_config_tx_config:            ./config/tx.config
```

This command updates the configuration of your Heroku app with the values specified in `txgh_config.rb` If you have any issues running the rake command, run bundle install in the Txgh project’s root directory. This compiles and installs the Ruby gems required by Txgh. Once the install completes, run the rake command again.


**Note** Since this file contains sensitive information, you should avoid committing it to your Heroku repository or to your GitHub repository.

Once the rake command has completed successfully, open the Heroku dashboard, navigate to the application’s settings and click Reveal Config Vars.

##Final Configuration Steps
The last step is to change the value of the RACK_ENV variable. By default, Heroku sets the value of RACK_ENV to production. However, we recommend testing Txgh by setting this value to test. If you haven’t already, open your application’s environment variables in a web browser and change the value of RACK_ENV from production to test. When you’re ready to deploy, you can change this value back to production.

Meanwhile, check the values of your other variables. If any values seem incorrect, you can edit them in your browser or edit and re-apply the txgh_config.rb file using rake. Once everything looks good, you can add your webhooks to Transifex and GitHub.

##Connecting Transifex and GitHub to Txgh

Txgh synchronizes your Transifex and GitHub projects using webhooks, allowing Txgh to respond immediately to changes in either service. The webhook URLs follow the format https://.herokuapp.com/hooks/, where is the name of your deployed Heroku app and is either “transifex” or “github.” 

For instance, we’ll use the following URL with Transifex:

https://nameless-eyrie-4025.herokuapp.com/hooks/transifex

and the following URL with GitHub:

https://nameless-eyrie-4025.herokuapp.com/hooks/github

Open your project in Transifex. Under More Project Options, click Manage.

In the Features section at the bottom of the screen is a text box titled Web Hook URL. Enter in the URL you created from your Heroku app, then click Save Project. Secret keys are currently unsupported, so leave the field blank for now.

Connecting Your GitHub Repository
Connecting a GitHub repository is similar. Open your repository in a web browser and click Settings.

Under Webhooks & services, click to add a webhook. You may be asked to confirm your password. Enter the Heroku app URL for the Payload URL and change the Content type to application/x-www-form-urlencoded. Just like with Transifex, keep the Secret token field blank.

Click Add webhook to create your new webhook. GitHub will ping the URL to test its validity. You can check whether the ping was successful by reloading the page.

Next, we’ll test out the integration by moving translations between GitHub and Transifex.

##Testing It Out

To test the integration, we’ll push a new commit to GitHub, then we’ll use the new commit to update translations in Transifex.

First, add a new string to the language source file in your Transifex project. Save your changes, then push the code to your GitHub repository. The push will automatically trigger the webhook. You can verify that webhook was successful by opening GitHub in a browser, navigating to the Webhooks & services, clicking on the webhook URL, and reviewing Recent Deliveries.

If successful, you should see the new source strings in your Transifex project.

Update the translations in Transifex. Back in your GitHub repository, review the latest commits. You should see a commit from Transifex with the latest updates to the target language.
