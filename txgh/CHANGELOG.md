# 6.8.0
* Support ERB tags in config files.

# 6.7.1
* Apply default serialization options correctly.

# 6.7.0
* Upgrade to abroad 4.6.0 in order to support nested JSON.

# 6.6.0
* Accept slugs as well as TxResources in TransifexApi#download method.

# 6.5.0
* Upgrade to abroad 4.4.0.

# 6.4.0
* Upgrade to abroad 4.3.0.

# 6.3.1
* Fix issue causing an error when receiving a delete webhook. Error caused by a resource with a blank set of categories.

# 6.3.0
* Events#publish now yields callback results if given a block.
* Add ability to report errors via github statuses.

# 6.2.2
* Fix lang map.

# 6.2.1
* Use lang map when constructing translation paths.

# 6.2.0
* Add support for text files.

# 6.1.2
* Handle Octokit::NotFound when downloading from Github.

# 6.1.1
* Remove stray argument in Txgh::Puller causing error.

# 6.1.0
* Consider all resources when computing github status updates.

# 6.0.6
* Publish version identical to 6.0.5 to force rubygems to re-index (WTF guys).

# 6.0.5
* Fix bug causing exceptions in ResourceCommitter (should be calling GithubApi#update_content with an array of files).

# 6.0.4
* Fix bug causing interruption in github status updates.

# 6.0.3
* Don't pass SHA when calling ResourceUpdater#update_resource.

# 6.0.2
* Fix bug in resource updater where a file hash is sent to the abroad extractor instead of the file's contents.

# 6.0.1
* Fix ArgumentError bug in resource updater.

# 6.0.0
* Refactor GithubApi. Repo name is now passed into constructor.
* Remove unused L10n branch behavior.
* Use tip of branch instead of commit SHA to update a resource.
* Use Github's content API to create and update files instead of the commit API.

# 5.5.0
* Use github's contents API for downloading files.

# 5.4.1
* Treat arrays as single units to conform to Transifex's string handling behavior.

# 5.4.0
* Separate txgh core library and server components.

# 5.3.4
* Guard against transifex errors in status event

# 5.3.3
* Guard against too many github statuses.

# 5.3.2
* Fix GithubApi#update_contents to create files if they doesn't exist.

# 5.3.1
* Coerce numeric values in YAML dumps.

# 5.3.0
* Reduce github API calls when committing. Reduced from 5 to 2.

# 5.2.2
* Correct issue with numeric YAML keys by upgrading to Abroad 4.0.

# 5.2.1
* Correct slugify algorithm.

# 5.2.0
* Moving pull/push logic into separate classes.

# 5.1.0
* Catch errors that occur during response streaming.
* Provide methods to get list of projects and repos in KeyManager.

# 5.0.0
* Use tip of branch instead of commit sha when updating Transifex resources.
* Library now raises more specific config errors.

# 4.0.0
* Refactor TransifexApi to reduce duplication.
* Rename TransifexApi#delete to #delete_resource (means major version bump).
* Include more information when raising TransifexApiError and subclasses.

# 3.0.0
* Upgrade abroad to v3.0.0 to take advantage of more consistent YAML scalar serialization

# 2.4.0
* Bump abroad to v2.0 to take advantage of pretty JSON serialization

# 2.3.0
* Make the raw:// tx config scheme the default

# 2.2.0
* Skip deleted branches when processing github push events
* Add configuration option for custom commit message
* Add environment

# 2.1.0
* Annotate commits on github with translation statuses
* Include the branch in the resource's name

# 2.0.1
* Handle both strings and bools in auto_delete_resources config option

# 2.0.0
* Only commit/download translations for languages in the list of supported languages.

# 1.1.0
* Added github ping handler.
* Added get_stats in TransifexApi.
* When diffing is enabled, ResourceUpdater now uploads the full resource for diff points (i.e. master).

# 1.0.1
* Heroku button compatibility.

# 1.0.0
* Birthday!
