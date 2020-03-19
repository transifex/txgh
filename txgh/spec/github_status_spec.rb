require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe GithubStatus do
  include StandardTxghSetup

  let(:status) { GithubStatus.new(transifex_project, git_repo, branch) }
  let(:resource) { tx_config.resource(resource_slug) }
  let(:branch) { 'heads/master' }
  let(:sha) { 'abc123shashasha' }

  before(:each) do
    allow(transifex_api).to receive(:get_resources).and_return(
      [{ 'slug' => resource.resource_slug }]
    )

    allow(github_api).to receive(:get_ref).and_return(
      object: { sha: sha }
    )
  end

  describe '#update' do
    let(:stats) do
      supported_languages.each_with_object({}) do |language, ret|
        ret[language] = {
          'translated_entities' => 10, 'untranslated_entities' => 0,
          'completed' => '100%'
        }
      end
    end

    before(:each) do
      allow(transifex_api).to receive(:get_stats).and_return(stats)
    end

    context 'with all resources at 100%' do
      it 'reports status as success' do
        expect(github_api).to receive(:create_status) do |commit_sha, state, options|
          expect(commit_sha).to eq(sha)
          expect(state).to eq(GithubStatus::State.success)
          expect(options[:description]).to eq('Translations complete!')
          expect(options[:context]).to eq('continuous-localization/txgh')
          expect(options[:target_url]).to eq(
            "https://www.transifex.com/#{organization}/#{project_name}/content"
          )
        end

        status.update
      end
    end

    context 'with one language at less than 100%' do
      let(:stats) do
        {
          'pt' => {
            'translated_entities' => 10, 'untranslated_entities' => 0,
            'completed' => '100%'
          },
          'ja' => {
            'translated_entities' => 5, 'untranslated_entities' => 5,
            'completed' => '50%'
          }
        }
      end

      it 'reports status as pending' do
        expect(github_api).to receive(:create_status) do |commit_sha, state, options|
          expect(state).to eq(GithubStatus::State.pending)
          expect(options[:description]).to eq('15/20 translations complete.')
        end

        status.update
      end
    end
  end

  describe '#error' do
    it 'reports status as error' do
      target_url = 'http://abc.foo.com'
      description = 'The green albatross flitters in the moonlight'

      expect(github_api).to receive(:create_status) do |commit_sha, state, options|
        expect(commit_sha).to eq(sha)
        expect(state).to eq(GithubStatus::State.error)
        expect(options[:description]).to eq(description)
        expect(options[:context]).to eq('continuous-localization/txgh')
        expect(options[:target_url]).to eq(target_url)
      end

      status.error(target_url: target_url, description: description)
    end
  end
end
