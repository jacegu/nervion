module Nervion
  class CallbackTable
    def initialize
      @callbacks = {}
    end

    def []=(name, code)
      @callbacks[name] = code
    end

    def [](name)
      @callbacks[name]
    end
  end
end
