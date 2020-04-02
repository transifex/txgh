module IntegrationSetup
  extend RSpec::SharedContext

  let(:git_source) { 'github' }
  let(:project_name) { 'test-project-88' }
  let(:repo_name) { 'txgh-bot/txgh-test-resources' }

  let(:base_config) do
    if git_source == 'github'
      {
        git_source => {
          'repos' => {
            repo_name => {
              'api_username' => 'txgh-bot',
              # github will auto-revoke a token if they notice it in one of your commits ;)
              'api_token' => Base64.decode64('YjViYWY3Nzk5NTdkMzVlMmI0OGZmYjk4YThlY2M1ZDY0NzAwNWRhZA=='),
              'push_source_to' => project_name,
              'branch' => 'master',
              'webhook_secret' => '18d3998f576dfe933357104b87abfd61'
            }
          }
        },
        'transifex' => {
          'projects' => {
            project_name => {
              'tx_config' => 'file://./config/tx.config',
              'api_username' => 'txgh.bot',
              'api_password' => '2aqFGW99fPRKWvXBPjbrxkdiR',
              'push_translations_to' => 'txgh-bot/txgh-test-resources',
              'webhook_secret' => 'fce95b1748fd638c22174d34200f10cf',
              'languages' => ['el_GR']
            }
          }
        }
      }
    else
      {
        git_source => {
          'repos' => {
            repo_name => {
              'api_token' => Base64.decode64('a3M1LV85TmFTaUwtOU5TUVJhcjE='),
              'push_source_to' => project_name,
              'branch' => 'all',
              'webhook_secret' => '123456789'
            }
          }
        },
        'transifex' => {
          'projects' => {
            project_name => {
              'organization' => 'lumos-labs',
              'tx_config' => 'file://./config/tx_gitlab.config',
              'api_username' => 'txgh.bot',
              'api_password' => '2aqFGW99fPRKWvXBPjbrxkdiR',
              'push_translations_to' => 'idanci/txgl-test',
              'webhook_secret' => '123456789',
              'languages' => ['de']
            }
          }
        }
      }
    end
  end

  before(:all) do
    VCR.configure do |config|
      config.filter_sensitive_data('<GITHUB_TOKEN>') do
        base_config[git_source]['repos'][repo_name]['api_token']
      end

      config.filter_sensitive_data('<TRANSIFEX_PASSWORD>') do
        base_config['transifex']['projects'][project_name]['api_password']
      end
    end
  end

  before(:each) do
    allow(Txgh::Config::KeyManager).to(
      receive(:base_config).and_return(base_config)
    )
  end
end
