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

  describe '#auto_delete_resources' do
    it 'returns false by default' do
      project_config['auto_delete_resources'] = nil
      expect(transifex_project.auto_delete_resources?).to eq(false)
    end

    it 'returns true if configured' do
      project_config['auto_delete_resources'] = 'true'
      expect(transifex_project.auto_delete_resources?).to eq(true)
    end

    it 'handles inconsistent casing' do
      project_config['auto_delete_resources'] = 'tRuE'
      expect(transifex_project.auto_delete_resources?).to eq(true)
    end
  end
end
