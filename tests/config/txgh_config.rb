# any ENV['RACK_ENV']
config_env :test do 
  set 'transifex_project_config_tx_config', '../config/tx.config'
  set 'transifex_project_config_api_username', '<USERNAME>'
  set 'transifex_project_config_api_password', '<PASSWORD>'
  set 'transifex_project_config_push_translations_to', 'matthewjackowski/txgh-test-resources'
  set 'github_repo_config_api_username', '<USERNAME>'
  set 'github_repo_config_api_token', '<API KEY>'
  set 'github_repo_config_push_source_to', 'txgh-test-1'
  set 'github_repo_config_branch', 'heads/test'
end

