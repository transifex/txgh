require 'spec_helper'

describe TxghQueue::ErrorHandlers::Gitlab do
  let(:gitlab_error_response) do
    OpenStruct.new({
      code: 404,
      request: double(base_uri: 'https://gitlab.com/api/v3', path: '/foo'),
      parsed_response: ::Gitlab::ObjectifiedHash.new(
        error_description: 'Displayed error_description',
        error: 'also will not be displayed'
      )
    })
  end

  describe '.can_handle?' do
    it 'can reply to all configured error classes' do
      described_class::ERROR_CLASSES.keys.each do |klass|
        expect(described_class.can_handle?(klass.new(gitlab_error_response))).to eq(true)
      end
    end

    it "can't reply to unsupported error classes" do
      expect(described_class.can_handle?(StandardError.new)).to eq(false)
    end
  end

  describe '.status_for' do
    it 'replies to all configured errors correctly' do
      described_class::ERROR_CLASSES.each_pair do |klass, expected_response|
        expect(described_class.status_for(klass.new(gitlab_error_response))).to eq(expected_response)
      end
    end

    it 'replies to all unconfigured errors with fail' do
      # i.e. if gitlab raises an error we didn't account for
      expect(described_class.status_for(StandardError.new)).to eq(TxghQueue::Status.fail)
    end
  end
end
