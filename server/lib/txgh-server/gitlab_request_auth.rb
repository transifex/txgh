module TxghServer
  class GitlabRequestAuth < TxghServer::GithubRequestAuth
    RACK_HEADER = 'HTTP_X_GITLAB_TOKEN'
    GITLAB_HEADER = 'X-Gitlab-Token'
  end
end
