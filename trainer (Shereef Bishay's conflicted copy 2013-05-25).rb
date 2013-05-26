class Trainer
  attr_accessor :stop_words
  attr_accessor :training_set

  def initialize(category, text, stop_words)
    @category = category
    @text = text
    @stop_words = stop_words
    @training_set = {}
  end

  def train
    words = text_to_array(@text)
    scored_words = score_words(words)
    @training_set = ratiolize(scored_words)
    return self
  end

  def ratiolize(scored_words)
    total_words = scored_words.values.inject(0, :+)
    ratio = 1 / total_words.to_f
    scored_words.keys.each { |key| scored_words[key] *= ratio }
    scored_words
  end

  def score_words(word_array)
    scored_words = Hash.new(0)
    word_array.each do |word| 
      scored_words[word] += 1 unless stop_words.include?(word)
    end
    scored_words
  end

  def text_to_array(text)
    text.downcase.scan(/[a-z]+/)
  end

  def save
    CSV.open("#{APP_ROOT}/training_sets/#{@category}.csv", 'wb') do |csv|
      @training_set.each do |word, weight|
        csv << [word, weight]
      end
    end
  end
end
