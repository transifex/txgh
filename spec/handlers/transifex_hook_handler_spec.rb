require 'spec_helper'

include Txgh
include Txgh::Handlers

describe TransifexHookHandler do
  let(:github_api) { double(:github_api) }
  let(:transifex_api) { double(:github_api) }

  let(:project_config) do
    {
      tx_config: 'path/to/tx.config'
      api_username: 'api_username'
      api_password: 'api_password'
      push_translations_to: 'my_org/my_repo'
    }
  end

  let(:repo_config) do
    {}
  end

  let(:transifex_project) do
    TransifexProject.new(project_config, transifex_api)
  end
end
