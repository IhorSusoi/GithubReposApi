# frozen_string_literal: true

# Main controller
class GraphqlController < ApplicationController
  def index
    @graphql_result = session.delete(:graphql_result)
    @parsed_result = JSON.parse(@graphql_result) if @graphql_result.present?
  end

  def execute
    nickname = params[:nickname]
    result = GithubReposApiSchema.execute(query, variables: { nickname: nickname })
    session[:graphql_result] = result.to_json
    redirect_to action: :index
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def query
    <<-GRAPHQL
      query GetUser($nickname: String!) {
        getUserData(nickname: $nickname) {
          name
        }
        getUserRepoData(nickname: $nickname) {
          name
        }
      }
    GRAPHQL
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
