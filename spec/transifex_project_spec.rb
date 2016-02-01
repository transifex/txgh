require 'spec_helper'

include Txgh

describe TransifexProject do
  include StandardTxghSetup

  describe '#name' do
    it 'pulls the project name out of the config' do
      expect(transifex_project.name).to eq(project_name)
    end
  end
end
