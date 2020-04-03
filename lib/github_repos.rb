require 'octokit'

class GithubRepos
  DEFAULT_PER_PAGE = 30

  Result = Struct.new(
    :page,
    :items,
    :per_page,
    :total_count,
    keyword_init: true
  ) do
    def next_page
      page + 1 if page < total_pages
    end

    def previous_page
      page - 1 if page > 1
    end

    def total_pages
      total_count.fdiv(per_page).ceil
    end
  end

  EmptyResult = Result.new(
    page: 1,
    items: [],
    per_page: DEFAULT_PER_PAGE,
    total_count: 0
  )

  ResultItem = Struct.new(
    :name,
    :description,
    :url,
    keyword_init: true
  )


  def initialize(client_id:, client_secret:)
    @client = Octokit::Client.new(
      client_id: client_id,
      client_secret: client_secret
    )
  end

  def search(query, page: nil, per_page: DEFAULT_PER_PAGE)
    return EmptyResult if !query || query.empty?

    raw_result = client.search_repositories("#{query} is:public", page: page, per_page: per_page)

    result_items = raw_result.items.map do |item|
      ResultItem.new(
        name: item.full_name,
        description: item.description,
        url: item.html_url
      )
    end

    Result.new(
      page: page || 1,
      per_page: per_page,
      items: result_items,
      total_count: raw_result.total_count
    )
  end

  private

  attr_reader :client
end
