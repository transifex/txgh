require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe ResourceCommitter do
  include StandardTxghSetup

  let(:language) { 'es' }
  let(:resource) { tx_config.resource(resource_slug, branch) }
  let(:committer) do
    ResourceCommitter.new(transifex_project, github_repo, logger)
  end

  describe '#commit_resource' do
    it 'commits translations to the git repo' do
      expect(transifex_api).to receive(:download).and_return(:translations)
      expect(github_api).to(
        receive(:commit).with(
          repo_name, branch, resource.translation_path(language), :translations
        )
      )

      committer.commit_resource(resource, branch, language)
    end

    it "doesn't commit anything if the language is the source language" do
      expect(github_api).to_not receive(:commit)
      committer.commit_resource(resource, branch, resource.source_lang)
    end

    it "doesn't commit anything if the branch is protected" do
      transifex_project.protected_branches << 'foobranch'
      expect(github_api).to_not receive(:commit)
      committer.commit_resource(resource, 'foobranch', resource.source_lang)
    end
  end
end
