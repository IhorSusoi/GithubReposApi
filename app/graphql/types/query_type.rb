# frozen_string_literal: true

module Types
  # Query type
  class QueryType < Types::BaseObject
    field :get_user_data, Types::UserType, null: true do
      argument :nickname, String, required: true
    end
    field :get_user_repo_data, Types::UserRepoType, null: true do
      argument :nickname, String, required: true
    end

    def get_user_data(nickname)
      user_data = send_to_external_api(nickname)
      result = JSON.parse(user_data)
      {
        name: result['name']
      }
    end

    def send_to_external_api(nickname)
      uri = URI.parse("https://api.github.com/users/#{nickname[:nickname]}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      request = Net::HTTP::Get.new(uri.path)
      request.set_form_data('nickname' => nickname[:nickname])
      response = http.request(request)
      response.body
    end

    def get_user_repo_data(nickname)
      user_data = send_to_external_repo_api(nickname)
      result = JSON.parse(user_data)
      result = result.map { |rep_info| rep_info['name'] }
      {
        name: result
      }
    end

    def send_to_external_repo_api(nickname)
      uri = URI.parse("https://api.github.com/users/#{nickname[:nickname]}/repos")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = Net::HTTP::Get.new(uri.path)
      request.set_form_data('nickname' => nickname[:nickname])

      response = http.request(request)
      response.body
    end
  end
end
