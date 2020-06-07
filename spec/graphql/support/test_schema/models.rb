# frozen_string_literal: true

require 'active_record'

class Author < ActiveRecord::Base
  has_many :books
end

class Book < ActiveRecord::Base
  belongs_to :author
end
