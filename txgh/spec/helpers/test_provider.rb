class TestProvider
  SCHEME = 'test'

  class << self
    def supports?(scheme)
      scheme == SCHEME
    end

    def load
    end
  end
end
