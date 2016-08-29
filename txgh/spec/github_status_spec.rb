require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe GithubStatus do
  include StandardTxghSetup

  describe '#update' do
    let(:status) { GithubStatus.new(transifex_project, github_repo, resource) }
    let(:resource) { tx_config.resource(resource_slug) }
    let(:sha) { 'abc123shashasha' }

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
            "https://www.transifex.com/#{organization}/#{project_name}/#{resource_slug}/"
          )
        end

        status.update(sha)
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

        status.update(sha)
      end
    end
  end
end
