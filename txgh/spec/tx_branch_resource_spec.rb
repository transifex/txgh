require 'spec_helper'

describe Txgh::TxBranchResource do
  let(:resource_slug) { 'resource_slug' }
  let(:resource_slug_with_branch) { "#{resource_slug}-heads_my_branch" }
  let(:project_slug) { 'project_slug' }
  let(:branch) { 'heads/my_branch' }

  let(:api) { :api }
  let(:config) { { name: project_slug } }
  let(:resources) { [base_resource] }

  let(:tx_config) do
    TxConfig.new(resources, {})
  end

  let(:base_resource) do
    TxResource.new(
      project_slug, resource_slug, 'type', 'source_lang', 'source_file',
      { 'ko-KR' => 'ko' }, 'translation_file'
    )
  end

  describe '.find' do
    it 'finds the correct resource when the suffix is included in the slug' do
      resource = described_class.find(tx_config, resource_slug_with_branch, branch)
      expect(resource).to be_a(described_class)
      expect(resource.resource).to eq(base_resource)
      expect(resource.branch).to eq(branch)
    end

    it 'finds the correct resource if no suffix is included in the slug' do
      resource = described_class.find(tx_config, resource_slug, branch)
      expect(resource).to be_a(described_class)
      expect(resource.resource).to eq(base_resource)
      expect(resource.branch).to eq(branch)
    end

    it 'returns nil if no resource matches' do
      resource = described_class.find(tx_config, 'foobar', branch)
      expect(resource).to be_nil

      resource = described_class.find(tx_config, resource_slug_with_branch, 'foobar')
      expect(resource).to be_nil
    end
  end

  describe '.deslugify' do
    it 'removes the branch suffix from the resource slug' do
      result = described_class.deslugify(resource_slug_with_branch, branch)
      expect(result).to eq(resource_slug)
    end

    it 'hands back the original slug if no suffix' do
      result = described_class.deslugify(resource_slug, branch)
      expect(result).to eq(resource_slug)
    end
  end

  context 'with a resource' do
    let(:resource) do
      described_class.new(base_resource, branch)
    end

    describe '#resource_slug' do
      it 'adds the branch name to the resource slug' do
        expect(resource.resource.resource_slug).to eq(resource_slug)
        expect(resource.resource_slug).to eq(resource_slug_with_branch)
      end
    end

    describe '#slugs' do
      it 'ensures the project slug contains the branch name' do
        expect(resource.slugs).to eq([project_slug, resource_slug_with_branch])
      end
    end

    describe '#to_h' do
      it 'converts the resource into a hash' do
        expect(resource.to_h).to eq(
          project_slug: project_slug,
          resource_slug: resource_slug_with_branch,
          type: 'type',
          source_lang: 'source_lang',
          source_file: 'source_file',
          translation_file: 'translation_file'
        )
      end
    end

    describe '#original_resource_slug' do
      it 'returns the base slug, i.e. without the branch' do
        expect(resource.original_resource_slug).to eq(resource_slug)
      end
    end
  end
end
