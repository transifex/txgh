# 7.2.0
* Upgrade to txgh-server v3.1.0.

# 7.1.0
* Upgrade to txgh v6.6.0.
* Other misc gem bumps.

# 7.0.0
* Upgrade to txgh-server v3.0.0.
* Upgrade to txgh-queue v2.0.0.

# 6.8.0
* Upgrade to txgh-server v2.4.0.

# 6.7.0
* Upgrade to txgh v6.5.0.

# 6.6.0
* Upgrade to txgh v6.4.0.

# 6.5.0
* Upgrade to txgh-queue v1.1.0.

# 6.4.1
* Upgrade to txgh v6.3.1.

# 6.4.0
* Upgrade to txgh v6.3.0.
* Upgrade to txgh-server v2.3.0.

# 6.3.2
* Upgrade to txgh v6.2.2.

# 6.3.1
* Upgrade to txgh v6.2.1.

# 6.3.0
* Upgrade to txgh v6.2.0.

# 6.2.3
* Upgrade to txgh v6.1.2.

# 6.2.2
* Upgrade txgh-queue to v1.0.2.

# 6.2.1
* Upgrade txgh-queue to v1.0.1.

# 6.2.0
* Upgrade txgh-server to v2.2.0.
* Add txgh-queue support.

# 6.1.2
* Upgrade txgh-server to v2.1.1.

# 6.1.1
* Upgrade to txgh v6.1.1.

# 6.1.0
* Upgrade to txgh v6.1.0 and txgh-server v2.1.0.

# 6.0.5
* Upgrade to txgh v6.0.6.

# 6.0.4
* Upgrade to txgh v6.0.5.

# 6.0.3
* Upgrade to txgh v6.0.4.

# 6.0.2
* Upgrade to txgh v6.0.3.

# 6.0.1
* Upgrade to txgh v6.0.2.

# 6.0.0
* Upgrade txgh to v6.0.
* Upgrade txgh-server to v2.0.

# 5.6.0
* Refactor webhook logic, bump version of txgh-server.
* Fix incorrectly scoped constant.

# 5.5.0
* Use github's contents API for downloading files.

# 5.4.4
* Don't convert nils to empty strings when serializing YAML.

# 5.4.3
* Fix for nested YAML arrays, which broke after the array preservation stuff.

# 5.4.2
* Array preservation should only affect string arrays (i.e. not nested objects).

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
