require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe ResourceUpdater do
  include StandardTxghSetup

  let(:updater) do
    ResourceUpdater.new(transifex_project, github_repo, logger)
  end

  let(:branch) { nil }
  let(:ref) { nil }
  let(:resource) { tx_config.resource(resource_slug, ref) }
  let(:commit_sha) { '8765309' }

  let(:modified_files) do
    [{ 'path' => resource.source_file, 'sha' => 'def456' }]
  end

  def translations_for(path)
    "translations for #{path}"
  end

  before(:each) do
    tree_sha = 'abc123'

    allow(github_api).to(
      receive(:get_commit).with(repo_name, commit_sha) do
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

    updater.update_resource(resource, commit_sha)
  end

  context 'when asked to process all branches' do
    let(:branch) { 'all' }
    let(:ref) { 'heads/master' }

    it 'uploads by branch name if asked' do
      allow(transifex_api).to receive(:resource_exists?).and_return(false)

      modified_files.each do |file|
        translations = translations_for(file['path'])

        expect(transifex_api).to(
          receive(:create) do |resource, content, categories|
            expect(resource.source_file).to eq(file['path'])
            expect(content).to eq(translations)
            expect(categories).to include("branch:#{ref}")
          end
        )
      end

      updater.update_resource(resource, commit_sha)
    end

    it 'adds categories when passed in' do
      expect(transifex_api).to receive(:resource_exists?).and_return(false)

      modified_files.each do |file|
        translations = translations_for(file['path'])

        expect(transifex_api).to(
          receive(:create) do |resource, content, categories|
            expect(categories).to include('foo:bar')
          end
        )
      end

      updater.update_resource(resource, commit_sha, { 'foo' => 'bar' })
    end
  end
end
