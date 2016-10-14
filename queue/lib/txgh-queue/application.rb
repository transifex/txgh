require 'sinatra'
require 'sinatra/json'

module TxghQueue
  module RespondWith
    def respond_with(resp)
      env['txgh.response'] = resp
      status resp.status
      json resp.body
    end
  end

  class WebhookEndpoints < Sinatra::Base
    include TxghQueue::Webhooks
    helpers RespondWith

    configure do
      set :logging, nil
      logger = Txgh::TxLogger.logger
      set :logger, logger
    end

    post '/transifex/enqueue' do
      respond_with(
        Transifex::RequestHandler.handle_request(request, settings.logger)
      )
    end

    post '/github/enqueue' do
      respond_with(
        Github::RequestHandler.handle_request(request, settings.logger)
      )
    end
  end
end
