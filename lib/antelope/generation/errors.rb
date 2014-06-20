# encoding: utf-8

module Antelope
  module Generation

    # Defines an error that can occur within the Generation module.
    # All errors that are raised within the Generation module are
    # subclasses of this.
    class Error < Antelope::Error
    end

    # Used mainly in the {Tableizer}, this is raised when a conflict
    # could not be resolved.
    class UnresolvableConflictError < Error
    end
  end
end
