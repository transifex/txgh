require 'spec_helper'
require 'helpers/standard_txgh_setup'

include Txgh

describe TransifexProject do
  include StandardTxghSetup

  describe '#name' do
    it 'pulls the project name out of the config' do
      expect(transifex_project.name).to eq(project_name)
    end
  end

  describe '#protected_branches' do
    it 'splits the list of branches and expands each one' do
      project_config['protected_branches'] = 'foo,bar, baz'
      expect(transifex_project.protected_branches).to eq(
        %w(heads/foo heads/bar heads/baz)
      )
    end
  end
end
