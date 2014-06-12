module Antelope
  module Generation
    class Conflictor
      Conflict = Struct.new(:state, :type, :rules, :token)
    end
  end
end
