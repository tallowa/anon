module Feedback
  class Base < ApplicationRecord
    self.abstract_class = true
    establish_connection :feedback
  end
end
