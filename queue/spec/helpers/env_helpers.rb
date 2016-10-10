module EnvHelpers
  def with_env(env)
    # ENV can't be duped, so use select instead to make a copy
    old_env = ENV.select { true }
    env.each_pair { |k, v| ENV[k] = v }
    yield
  ensure
    # reset back to old vars
    env.each_pair { |k, _| ENV[k] = old_env[k] }
  end
end

EnvHelpers.extend(EnvHelpers)
