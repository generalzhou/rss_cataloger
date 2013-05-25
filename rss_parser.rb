class RssParser
  def initialize(url)
    @url = url
  end

  def article_urls
    RSS::Parser.parse(open(@url), false).items.map{|item| item.link }
  end
end
