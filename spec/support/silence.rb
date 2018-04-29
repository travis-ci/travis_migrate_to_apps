module Support
  module Silence
    def self.included(c)
      c.before { allow($stdout).to receive(:puts) }
      c.before { allow($stdout).to receive(:write) }
    end
  end
end
