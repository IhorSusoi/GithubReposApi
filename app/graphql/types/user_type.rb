# frozen_string_literal: true

module Types
  # user type class
  class UserType < Types::BaseObject
    field :name, String, null: true
  end
end
