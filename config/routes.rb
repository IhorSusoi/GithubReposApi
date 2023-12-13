# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: 'graphql#execute' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  get '/index', to: 'graphql#index'
  root 'graphql#index'
end
