module Identity
  class Base < ApplicationRecord
    self.abstract_class = true
    establish_connection :primary
  end
end
