require 'pry'
require 'nokogiri'
require 'open-uri'
require 'rss/2.0'


require_relative 'html_parser'
require_relative 'trainer'
require_relative 'rss_parser'


economy = HtmlParser.new('http://en.wikipedia.org/wiki/Economy', '.mw-content-ltr')
sport   = HtmlParser.new('http://en.wikipedia.org/wiki/Sport', '.mw-content-ltr')
health  = HtmlParser.new('http://en.wikipedia.org/wiki/Health', '.mw-content-ltr')

training_data = {'economy' => economy.content,
                'sport' => sport.content,
                'health' => health.content
                }

trainer = Trainer.new('bs_words.txt')

training_set = trainer.train_data(training_data)

rss_list = RssParser.new('http://avusa.feedsportal.com/c/33051/f/534658/index.rss')

rss_list.article_urls.each do |url|

  article = HtmlParser.new(url, '#article .area > h3, #article .area > p, #article > h3')
  article_words = article.content.downcase.scan(/[a-z]+/)

  article_categories = {'economy' => 0,
                'sport' => 0,
                'health' => 0}

  training_set.each do |category, weighted_words|
    weighted_words.each do |word, weight|
      article_categories[category] += article_words.count(word) * weight
    end
  end

  puts url
  p article_categories
end
