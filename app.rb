require 'sinatra/base'

require_relative 'lib/github_repos'

class AdjustedGithubApp < Sinatra::Application
  set :results_per_page, 30

  set :github_client_id, ENV.fetch('GITHUB_CLIENT_ID')
  set :github_client_secret, ENV.fetch('GITHUB_CLIENT_SECRET')

  def self.github_repos
    @github_repos ||= GithubRepos.new(
      client_id: github_client_id,
      client_secret: github_client_secret
    )
  end

  get '/' do
    page = params['page']&.to_i

    result = self.class.github_repos.search(
      params['search'],
      page: page,
      per_page: settings.results_per_page
    )

    erb :index, locals: { result: result }
  end

  helpers do
    def encoded_param(name)
      URI.encode_www_form_component(params[name])
    end
  end
end
