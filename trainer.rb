class Trainer
  attr_accessor :stop_words

  def initialize(stop_words_file)
    @stop_words = []
    File.open(stop_words_file).each_line { |line| @stop_words << line.chomp }
  end

  def train_data(data)
    trained_data = Hash.new(0)
    data.each do |category, text|
      weighted_words = Hash.new(0)
      all_words = text.downcase.scan(/[a-z]+/)

      all_words.each do |word| 
        weighted_words[word] += 1 unless stop_words.include?(word)
      end

      ratio = 1 / all_words.length.to_f
      weighted_words.keys.each { |key| weighted_words[key] *= ratio }
      trained_data[category] = weighted_words
    end
    trained_data
  end

end
