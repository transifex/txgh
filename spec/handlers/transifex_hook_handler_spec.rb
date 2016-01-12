require 'spec_helper'
require 'helpers/nil_logger'

include Txgh
include Txgh::Handlers

describe TransifexHookHandler do
  include StandardTxghSetup

  let(:handler) do
    TransifexHookHandler.new(
      project: transifex_project,
      repo: github_repo,
      resource: resource_slug,
      language: language,
      logger: logger
    )
  end

  let(:logger) do
    NilLogger.new
  end

  before(:each) do
    expect(transifex_api).to(receive(:download)) do |resource, language|
      expect(resource.project_slug).to eq(project_name)
      expect(resource.resource_slug).to eq(resource_slug)
      translations
    end
  end

  it 'downloads translations and pushes them to the correct branch (head)' do
    expect(github_api).to(
      receive(:commit).with(
        repo_name, "heads/#{branch}", "translations/#{language}/sample.po", translations
      )
    )

    handler.execute
  end

  context 'with a tag instead of a branch' do
    let(:branch) { 'tags/my_tag' }

    it 'downloads translations and pushes them to the tag' do
      expect(github_api).to(
        receive(:commit).with(
          repo_name, "tags/my_tag", "translations/#{language}/sample.po", translations
        )
      )

      handler.execute
    end
  end
end
