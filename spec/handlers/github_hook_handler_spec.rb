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

  let(:logger) do
    NilLogger.new
  end

  let(:ref) { 'heads/master' }

  let(:payload) do
    GithubPayloadBuilder.webhook_payload(repo_name, ref)
  end

  let(:modified_files) do
    file_sha = 'def456'
    transifex_project.resources.map do |resource|
      { 'path' => resource.source_file, 'sha' => file_sha.next! }
    end
  end

  it 'correctly uploads modified files to transifex' do
    tree_sha = 'abc123'

    # indicate that all the files we care about have changed
    payload.add_commit(
      modified: modified_files.map { |f| f['path'] }
    )

    expect(github_api).to(
      receive(:get_commit).with(repo_name, payload.commits.first[:id]) do
        { 'commit' => { 'tree' => { 'sha' => tree_sha } } }
      end
    )

    expect(github_api).to(
      receive(:tree).with(repo_name, tree_sha) do
        { 'tree' => modified_files }
      end
    )

    modified_files.each do |file|
      translations = "translations for #{file['path']}"

      expect(github_api).to(
        receive(:blob).with(repo_name, file['sha']) do
          { 'content' => translations, 'encoding' => 'utf-8' }
        end
      )

      expect(transifex_api).to(
        receive(:update) do |resource, content|
          expect(resource.source_file).to eq(file['path'])
          expect(content).to eq(translations)
        end
      )
    end

    handler.execute
  end

  context 'with an L10N branch' do
    let(:ref) { 'tags/L10N_my_branch' }

    it 'creates an L10N tag' do
      payload.add_commit

      expect(github_api).to(
        receive(:create_ref).with(repo_name, 'heads/L10N', payload.head_commit[:id])
      )

      handler.execute
    end
  end
end
