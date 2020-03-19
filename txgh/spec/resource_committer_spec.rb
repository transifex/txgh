require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe ResourceCommitter do
  include StandardTxghSetup

  let(:language) { 'es' }
  let(:resource) { tx_config.resource(resource_slug, branch) }
  let(:downloader) { instance_double(ResourceDownloader) }
  let(:file_name) { "translations/#{language}/sample.yml" }
  let(:committer) do
    ResourceCommitter.new(transifex_project, git_repo, logger)
  end

  let(:commit_message) do
    "Updating #{language} translations in #{file_name}"
  end

  before(:each) do
    allow(github_api).to receive(:get_ref).and_return(
      object: { sha: 'abc123shashasha' }
    )
  end

  describe '#commit_resource' do
    context 'with apis available' do
      before(:each) do
        expect(ResourceDownloader).to receive(:new).and_return(downloader)
        expect(downloader).to receive(:first).and_return([file_name, :translations])

        expect(github_api).to(
          receive(:update_contents).with(
            branch, [{ path: file_name, contents: :translations }], commit_message
          )
        )
      end

      it 'commits translations to the git repo' do
        committer.commit_resource(resource, branch, language)
      end

      it 'fires the github.resource.committed event' do
        expect { committer.commit_resource(resource, branch, language) }.to(
          change { Txgh.events.published.size }.by(1)
        )

        event = Txgh.events.published.first
        expect(event[:channel]).to eq('github.resource.committed')

        options = event[:options]
        expect(options[:project].name).to eq(project_name)
        expect(options[:repo].name).to eq(repo_name)
        expect(options[:branch]).to eq(branch)
        expect(options[:resource].original_resource_slug).to eq(resource_slug)
        expect(options[:language]).to eq(language)
      end

      context 'with a custom commit message' do
        let(:commit_message_template) { "foo %{language}" }
        let(:commit_message) { "foo #{language}" }

        it 'uses the custom commit message' do
          committer.commit_resource(resource, branch, language)
        end
      end
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
