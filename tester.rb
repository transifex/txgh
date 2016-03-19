require 'txgh'
require 'pry-byebug'

config = Txgh::Config::KeyManager.config_from_project('lumositycom')
updater = Txgh::ResourceUpdater.new(config.transifex_project, config.github_repo)
tx_config = Txgh::Config::TxManager.tx_config(config.transifex_project, config.github_repo, 'heads/remove_rosette')
resource = tx_config.resource('enyml', 'heads/remove_rosette')

updater.update_resource(resource, '08f88af71eec47782d089466d77e175d2f90c490')
