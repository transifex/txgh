require 'spec_helper'
require 'helpers/standard_txgh_setup'
require 'yaml'

include Txgh

describe ResourceDownloader do
  include StandardTxghSetup

  let(:api_languages) { %w(es de ja) }
  let(:format) { '.zip' }

  let(:downloader) do
    ResourceDownloader.new(transifex_project, github_repo, ref)
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
      receive(:download) do |resource, language|
        translations_for(resource, language)
      end
    )
  end

  def translations_for(resource, language)
    outdent(%Q{
      #{language}:
        string: "translation"
    })
  end

  context 'with a basic resource' do
    let(:resource) do
      tx_config.resource(resource_slug)
    end

    it 'downloads the resource in all languages' do
      expect(downloader.each.to_a).to eq(
        api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            translations_for(resource, language)
          ]
        end
      )
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

      it 'includes all resources' do
        resource = tx_config.resource(resource_slug)
        actual_results = downloader.each.to_a

        expected_results = api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            translations_for(resource, language)
          ]
        end

        expected_results += api_languages.map do |language|
          [
            "translations/#{language}/sample2.yml",
            translations_for(resource, language)
          ]
        end

        expect(actual_results).to eq(expected_results)
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
          picard: "enterprise"
          janeway: "uss voyager"
          sisko: "deep space nine"
      })
    end

    def diff_point_source_for(branch)
      outdent(%Q{
        en:
          picard: "enterprise"
          janeway: "voyager"
          sulu: "excelsior"
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
          picard: "enterprise (head trans)"
          janeway: "uss voyager (head trans)"
          sisko: "deep space nine (head trans)"
      })
    end

    def diff_point_translations_for(language)
      # diff point strings (i.e. strings in master)
      outdent(%Q{
        #{language}:
          picard: "enterprise (dp trans)"
          janeway: "voyager (dp trans)"
          sulu: "excelsior (dp trans)"
      })
    end

    it 'merges the head and diff point strings together' do
      # picard unmodified, janeway modified, sisko added, sulu removed
      expect(downloader.each.to_a).to eq(
        api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            outdent(%Q{
              #{language}:
                picard: "enterprise (dp trans)"
                janeway: "uss voyager (head trans)"
                sisko: "deep space nine (head trans)"
            })
          ]
        end
      )
    end

    it "works even if the resource doesn't exist in transifex" do
      allow(transifex_api).to(
        receive(:download) do |resource, language|
          if resource.branch
            translations_for(resource, language)
          else
            raise TransifexNotFoundError
          end
        end
      )

      results = downloader.each.to_a
      expect(results).to eq(
        api_languages.map do |language|
          [
            "translations/#{language}/sample.yml",
            outdent(%Q{
              #{language}:
                picard: "enterprise (dp trans)"
                janeway: "voyager (dp trans)"
            })
          ]
        end
      )
    end
  end
end
