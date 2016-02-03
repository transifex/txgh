require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/nil_logger'

include Txgh
include Txgh::Handlers

describe GithubHookHandler do
  include StandardTxghSetup

  let(:handler) do
    GithubHookHandler.new(
      project: transifex_project,
      repo: github_repo,
      payload: payload.to_h,
      logger: logger
    )
  end

  let(:payload) do
    GithubPayloadBuilder.webhook_payload(repo_name, ref)
  end

  let(:modified_files) do
    file_sha = 'def456'
    transifex_project.resources.map do |resource|
      { 'path' => resource.source_file, 'sha' => file_sha.next! }
    end
  end

  def translations_for(path)
    "translations for #{path}"
  end

  before(:each) do
    tree_sha = 'abc123'

    # indicate that all the files we care about have changed
    payload.add_commit(
      modified: modified_files.map { |f| f['path'] }
    )

    allow(github_api).to(
      receive(:get_commit).with(repo_name, payload.commits.first[:id]) do
        { 'commit' => { 'tree' => { 'sha' => tree_sha } } }
      end
    )

    allow(github_api).to(
      receive(:tree).with(repo_name, tree_sha) do
        { 'tree' => modified_files }
      end
    )

    modified_files.each do |file|
      translations = translations_for(file['path'])

      allow(github_api).to(
        receive(:blob).with(repo_name, file['sha']) do
          { 'content' => translations, 'encoding' => 'utf-8' }
        end
      )
    end
  end

  it 'correctly uploads modified files to transifex' do
    modified_files.each do |file|
      translations = translations_for(file['path'])

      expect(transifex_api).to(
        receive(:create_or_update) do |resource, content|
          expect(resource.source_file).to eq(file['path'])
          expect(content).to eq(translations)
        end
      )
    end

    handler.execute
  end

  context 'when asked to process all branches' do
    let(:branch) { 'all' }

    it 'uploads by branch name if asked' do
      allow(transifex_api).to receive(:resource_exists?).and_return(false)

      modified_files.each do |file|
        translations = translations_for(file['path'])

        expect(transifex_api).to(
          receive(:create) do |resource, content, categories|
            expect(resource.source_file).to eq(file['path'])
            expect(content).to eq(translations)
            expect(categories).to include("branch:#{ref}")
            expect(categories).to include("author:Test_User")
          end
        )
      end

      handler.execute
    end
  end

  context 'with an L10N branch' do
    let(:ref) { 'tags/L10N_my_branch' }

    it 'creates an L10N tag' do
      modified_files.each do |file|
        allow(github_api).to(
          receive(:blob).and_return('content' => '')
        )

        allow(transifex_api).to receive(:create_or_update)
      end

      # this is what we actually care about in this test
      expect(github_api).to(
        receive(:create_ref).with(
          repo_name, 'heads/L10N', payload.head_commit[:id]
        )
      )

      handler.execute
    end
  end
end
