module IntegrationSetup
  extend RSpec::SharedContext

  let(:base_config) do
    {
      'github' => {
        'repos' => {
          'txgh-bot/txgh-test-resources' => {
            'api_username' => 'txgh-bot',
            # github will auto-revoke a token if they notice it in one of your commits ;)
            'api_token' => Base64.decode64('YjViYWY3Nzk5NTdkMzVlMmI0OGZmYjk4YThlY2M1ZDY0NzAwNWRhZA=='),
            'push_source_to' => 'test-project-88',
            'branch' => 'master'
          }
        }
      },
      'transifex' => {
        'projects' => {
          'test-project-88' => {
            'tx_config' => 'file://./config/tx.config',
            'api_username' => 'txgh.bot',
            'api_password' => '2aqFGW99fPRKWvXBPjbrxkdiR',
            'push_translations_to' => 'txgh-bot/txgh-test-resources'
          }
        }
      }
    }
  end

  before(:all) do
    VCR.configure do |config|
      config.filter_sensitive_data('<GITHUB_TOKEN>') do
        base_config['github']['repos']['txgh-bot/txgh-test-resources']['api_token']
      end

      config.filter_sensitive_data('<TRANSIFEX_PASSWORD>') do
        base_config['transifex']['projects']['test-project-88']['api_password']
      end
    end
  end

  before(:each) do
    allow(Txgh::KeyManager).to receive(:base_config).and_return(base_config)
  end
end
