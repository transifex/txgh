require 'spec_helper'

include Txgh

describe TransifexProject do
  include StandardTxghSetup

  describe '#name' do
    it 'pulls the project name out of the config' do
      expect(transifex_project.name).to eq(project_name)
    end
  end

  # describe '#resource' do
  #   it 'finds the resource by slug' do
  #     resource = transifex_project.resource(resource_slug)
  #     expect(resource).to be_a(TxResource)
  #     expect(resource.resource_slug).to eq(resource_slug)
  #   end

  #   it 'returns nil if there is no resource with the given slug' do
  #     resource = transifex_project.resource('foobarbaz')
  #     expect(resource).to be_nil
  #   end
  # end

  # describe '#resources' do
  #   it 'hands back the array of resources from the tx config' do
  #     expect(transifex_project.resources).to be_a(Array)

  #     transifex_project.resources.each_with_index do |resource, idx|
  #       expect(resource.resource_slug).to(
  #         eq(tx_config.resources[idx].resource_slug)
  #       )
  #     end
  #   end
  # end

  # describe '#lang_map' do
  #   it 'converts the given language if a mapping exists for it' do
  #     expect(transifex_project.lang_map('ko-KR')).to eq('ko')
  #     expect(transifex_project.lang_map('pt-BR')).to eq('pt')
  #   end

  #   it 'does not perform any conversion if no mapping exists for the given language' do
  #     expect(transifex_project.lang_map('foo')).to eq('foo')
  #   end
  # end
end
