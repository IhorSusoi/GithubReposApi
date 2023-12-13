# frozen_string_literal: true

module Types
  # user repo type
  class UserRepoType < Types::BaseObject
    field :name, [String], null: true
  end
end
