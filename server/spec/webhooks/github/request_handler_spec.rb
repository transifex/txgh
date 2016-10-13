require 'spec_helper'
require 'helpers/github_payload_builder'
require 'helpers/nil_logger'
require 'helpers/standard_txgh_setup'
require 'helpers/test_request'
require 'helpers/test_backend'

include TxghServer::Webhooks

describe Github::RequestHandler do
  include StandardTxghSetup

  let(:logger) { NilLogger.new }
  let(:ref) { 'heads/my_ref' }
  let(:headers) { { 'HTTP_X_GITHUB_EVENT' => event } }
  let(:body) { payload.to_json }
  let(:request) { TestRequest.new(body: body, headers: headers) }
  let(:handler) { described_class.new(request, logger) }

  describe '#handle_request' do
    context 'push event' do
      let(:event) { 'push' }
      let(:payload) { GithubPayloadBuilder.push_payload(repo_name, ref).tap { |p| p.add_commit } }

      it 'does not execute if unauthorized' do
        expect_any_instance_of(Github::PushHandler).to_not receive(:execute)
        response = handler.handle_request
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'handles the request with the push handler' do
          expect_any_instance_of(Github::PushHandler).to receive(:execute).and_return(:response)
          expect(handler.handle_request).to eq(:response)
        end
      end
    end

    context 'delete event' do
      let(:event) { 'delete' }
      let(:payload) { GithubPayloadBuilder.delete_payload(repo_name, ref) }

      it 'does not execute if unauthorized' do
        expect_any_instance_of(Github::DeleteHandler).to_not receive(:execute)
        response = handler.handle_request
        expect(response.status).to eq(401)
      end

      context 'with an authentic request' do
        before(:each) do
          allow(handler).to receive(:authentic_request?).and_return(true)
        end

        it 'handles the request with the delete handler' do
          expect_any_instance_of(Github::DeleteHandler).to receive(:execute).and_return(:response)
          expect(handler.handle_request).to eq(:response)
        end
      end
    end

    context 'unrecognized event' do
      let(:event) { 'foo' }
      let(:payload) { { repository: { full_name: repo_name } } }

      it 'responds with a 400' do
        allow(handler).to receive(:authentic_request?).and_return(true)
        response = handler.handle_request
        expect(response.status).to eq(400)
      end
    end
  end

  describe '#enqueue' do
    let(:payload) { { repository: { full_name: repo_name } } }
    let(:event) { 'push' }

    it "responds with an error when a queue backend isn't configured" do
      allow(handler).to receive(:authentic_request?).and_return(true)
      response = handler.enqueue

      expect(response.body.first[:error]).to(
        eq('Internal server error: No queue backend has been configured')
      )

      expect(response.status).to eq(500)
    end

    context 'with a queue configured' do
      let(:queue_config) do
        {
          backend: 'test',
          options: {
            queues: %w(test-queue)
          }
        }
      end

      let(:backend) { TxghQueue::Config.backend }
      let(:producer) { backend.producer_for("github.#{event}") }

      before(:each) do
        allow(TxghQueue::Config).to(
          receive(:raw_config).and_return(queue_config)
        )
      end

      after(:each) { backend.reset! }

      context 'push event' do
        let(:event) { 'push' }
        let(:payload) { GithubPayloadBuilder.push_payload(repo_name, ref).tap { |p| p.add_commit } }

        it 'does not enqueue if unauthorized' do
          expect { handler.enqueue }.to_not change { producer.enqueued_jobs.size }
        end

        it 'responds with an unauthorized status' do
          response = handler.enqueue
          expect(response.status).to eq(401)
        end

        context 'with an authentic request' do
          before(:each) do
            allow(handler).to receive(:authentic_request?).and_return(true)
          end

          it 'enqueues the job' do
            expect { handler.enqueue }.to(
              change { producer.enqueued_jobs.size }.from(0).to(1)
            )
          end

          it 'enqueues with the correct parameters' do
            handler.enqueue
            params = producer.enqueued_jobs.first
            expect(params[:payload]).to include(
              event: 'push',
              txgh_event: 'github.push',
              ref: "refs/#{ref}",
              repo_name: repo_name
            )
          end

          it 'responds with an ok status code' do
            response = handler.enqueue
            expect(response.status).to eq(202)
          end
        end
      end

      context 'delete event' do
        let(:event) { 'delete' }
        let(:payload) { GithubPayloadBuilder.delete_payload(repo_name, ref) }

        it 'does not enqueue if unauthorized' do
          expect { handler.enqueue }.to_not change { producer.enqueued_jobs.size }
        end

        it 'responds with an unauthorized status' do
          response = handler.enqueue
          expect(response.status).to eq(401)
        end

        context 'with an authentic request' do
          before(:each) do
            allow(handler).to receive(:authentic_request?).and_return(true)
          end

          it 'enqueues the job' do
            expect { handler.enqueue }.to(
              change { producer.enqueued_jobs.size }.from(0).to(1)
            )
          end

          it 'enqueues with the correct parameters' do
            handler.enqueue
            params = producer.enqueued_jobs.first
            expect(params[:payload]).to include(
              event: 'delete',
              txgh_event: 'github.delete',
              ref: "refs/#{ref}",
              repo_name: repo_name
            )
          end

          it 'responds with an ok status code' do
            response = handler.enqueue
            expect(response.status).to eq(202)
          end
        end
      end

      context 'unrecognized event' do
        let(:event) { 'foo' }

        it 'responds with a 400' do
          allow(handler).to receive(:authentic_request?).and_return(true)
          response = handler.enqueue
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
