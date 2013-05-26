require 'pry'
require 'nokogiri'
require 'open-uri'
require 'rss/2.0'
require 'csv'

APP_ROOT = File.expand_path( '../',__FILE__ )


require_relative 'html_parser'
require_relative 'trainer'
require_relative 'rss_parser'
require_relative 'training_manager'

@trainer = TrainingManager.new

RSS_URL = 'http://avusa.feedsportal.com/c/33051/f/534658/index.rss'
WIKIPEDIA_SELECTOR = '.mw-content-ltr'
LIST_OF_LINKS = {'japan' => 'http://en.wikipedia.org/wiki/Japan',
                  'great_britain' => 'https://en.wikipedia.org/wiki/Great_Britain',
                  'syria' => 'http://en.wikipedia.org/wiki/Syria',
                  'middle_east' => 'http://en.wikipedia.org/wiki/Middle_East',
                  'nigeria' => 'http://en.wikipedia.org/wiki/Middle_East',
                  'africa' => 'http://en.wikipedia.org/wiki/Africa',
                  'south_africa' => 'https://en.wikipedia.org/wiki/South_Africa',
                  'france' => 'http://en.wikipedia.org/wiki/France',
                  'europe' => 'http://en.wikipedia.org/wiki/Europe',
                  'disaster' => 'http://en.wikipedia.org/wiki/Disaster',
                  'terrorism' => 'http://en.wikipedia.org/wiki/Terrorism',
                  'accident' => 'http://en.wikipedia.org/wiki/Accident',
                  'rebellion' => 'http://en.wikipedia.org/wiki/Rebellion',
                  'economy'=> 'http://en.wikipedia.org/wiki/Economy',
                  'sport'=> 'http://en.wikipedia.org/wiki/Sport',
                  'health'=> 'http://en.wikipedia.org/wiki/health'
                }

@all_loaded_sets = @trainer.load_all_sets('/training_sets')
@all_categories = @all_loaded_sets.map { |set| set.category }

initial_values = Array.new(@all_categories.length){0}
@article_categories = Hash[@all_categories.zip(initial_values)]


def rss_scanner(rss_url)
  RssParser.new(rss_url).article_urls.each do |article_url|
    article_content = extract_article_content(article_url)
    p article_content
    scored_article = score_article(article_content)
    scores_percentages = convert_to_percentages(scored_article) 
    sorted_percentages = sort_by_relevance(scores_percentages)
    print_data(article_url, sorted_percentages)
  end
end

def print_data(article_url, sorted_scores)
  puts "url: #{article_url} END"
  sorted_scores.each { |cat, score| puts "#{cat}: #{score}" }
end

def sort_by_relevance(scored_article)
  scored_article.sort_by { |cat,score| -score }
end

def convert_to_percentages(scored_article)
  total = scored_article.values.inject(:+)
  scored_article.keys.each { |cat| scored_article[cat] = (scored_article[cat] / total * 100).to_i } 
  scored_article
end


def score_article(text_array)
  article_categories = @article_categories.clone
  @all_loaded_sets.each do |set|
    set.training_set.each do |word, weight|
      article_categories[set.category] += text_array.count(word) * weight
    end
  end
  article_categories
end

def extract_article_content(url)
  article = HtmlParser.new(url, '#article .area > h3, #article .area > p, #article > h3')
  article.content.downcase.scan(/[a-z]+/)
end


binding.pry
