require 'spec_helper'
require 'helpers/standard_txgh_setup'
require 'yaml'

include Txgh::Handlers

describe DownloadHandler do
  include StandardTxghSetup

  let(:api_languages) { %w(es de ja) }
  let(:format) { DownloadHandler::DEFAULT_FORMAT }

  let(:params) do
    {
      'format' => format,
      'project_slug' => project_name,
      'branch' => ref
    }
  end

  let(:handler) do
    DownloadHandler.new(transifex_project, github_repo, params, logger)
  end

  let(:api_resources) do
    tx_config.resources.map(&:to_api_h)
  end

  before(:each) do
    allow(transifex_api).to(
      receive(:get_languages).with(project_name).and_return(
        api_languages.map do |language_code|
          { 'language_code' => language_code }
        end
      )
    )

    allow(transifex_api).to(
      receive(:get_resources)
        .with(project_name)
        .and_return(api_resources)
    )

    allow(transifex_api).to(
      receive(:download) do |resource, language|
        translations_for(resource, language)
      end
    )
  end

  def translations_for(resource, language)
    outdent(%Q{
      #{language}:
        string: ! "translation"
    })
  end

  context 'with a basic resource' do
    let(:resource) do
      tx_config.resource(resource_slug)
    end

    it 'downloads the resource in all languages' do
      response = handler.execute
      expect(response).to be_a(ZipStreamResponse)
      expect(response.enum.to_a).to eq(
        api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            translations_for(resource, language)
          ]
        end
      )
    end

    context 'with a tgz format' do
      let(:format) { '.tgz' }

      it 'responds with a tgz stream' do
        response = handler.execute
        expect(response).to be_a(TgzStreamResponse)
      end
    end
  end

  context 'with more than one resource' do
    before(:each) do
      tx_config.resources << Txgh::TxResource.new(
        project_name, "#{resource_slug}_second", 'YML',
        'en', 'en.yml', '', 'translations/<lang>/sample2.yml'
      )

      allow(Txgh::Config::TxManager).to(
        receive(:tx_config).and_return(tx_config)
      )
    end

    context 'when told to process all branches' do
      let(:branch) { 'all' }
      let(:api_resources) do
        [
          { 'slug' => "#{resource_slug}-#{Txgh::Utils.slugify(ref)}" },
          { 'slug' => "#{resource_slug}_second" }
        ]
      end

      it 'only includes resources that match the branch (ref)' do
        resource = tx_config.resource(resource_slug)
        response = handler.execute
        expect(response.enum.to_a).to eq(
          api_languages.map do |language|
            [
              "translations/#{language}/sample.yml",
              translations_for(resource, language)
            ]
          end
        )
      end
    end
  end

  context 'when told to upload diffs' do
    let(:diff_point) { 'heads/master' }
    let(:ref) { 'heads/mybranch' }

    before(:each) do
      allow(github_api).to receive(:download) do |repo_name, file, branch|
        source_for(branch)
      end
    end

    def source_for(branch)
      if branch == diff_point
        diff_point_source_for(branch)
      else
        head_source_for(branch)
      end
    end

    def head_source_for(branch)
      # picard unmodified, janeway modified, sisko added, sulu removed
      outdent(%Q{
        en:
          picard: ! "enterprise"
          janeway: ! "uss voyager"
          sisko: ! "deep space nine"
      })
    end

    def diff_point_source_for(branch)
      outdent(%Q{
        en:
          picard: ! "enterprise"
          janeway: ! "voyager"
          sulu: ! "excelsior"
      })
    end

    def translations_for(resource, language)
      branch = resource.respond_to?(:branch) ? resource.branch : nil

      if branch == diff_point
        diff_point_translations_for(language)
      else
        head_translations_for(language)
      end
    end

    # picard unmodified, janeway modified, sisko added, sulu removed
    def head_translations_for(language)
      outdent(%Q{
        #{language}:
          picard: ! "enterprise (head trans)"
          janeway: ! "uss voyager (head trans)"
          sisko: ! "deep space nine (head trans)"
      })
    end

    def diff_point_translations_for(language)
      # diff point strings (i.e. strings in master)
      outdent(%Q{
        #{language}:
          picard: ! "enterprise (dp trans)"
          janeway: ! "voyager (dp trans)"
          sulu: ! "excelsior (dp trans)"
      })
    end

    it 'merges the head and diff point strings together' do
      # picard unmodified, janeway modified, sisko added, sulu removed
      response = handler.execute
      expect(response.enum.to_a).to eq(
        api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            outdent(%Q{
              #{language}:
                picard: ! "enterprise (dp trans)"
                janeway: ! "uss voyager (head trans)"
                sisko: ! "deep space nine (head trans)"
            })
          ]
        end
      )
    end
  end
end