class TrainingManager

  attr_accessor :stop_words
  attr_accessor :loaded_sets

  BAD_WORDS_FILE = 'bs_words.txt'

  def initialize
    @stop_words = []
    File.open(BAD_WORDS_FILE).each_line { |line| @stop_words << line.chomp }
    @loaded_sets = []
  end

  def create_training_set(category, url, selector)
    content = HtmlParser.new(url, selector).content
    trainer = Trainer.new(category)
    trainer.train(content, stop_words)
  end

  def save(training_set)
    training_set.save
  end

  def train_this_list(list, selector)
    list.each do |category, url|
      set = create_training_set(category, url, selector)
      set.save
      all_loaded_sets << set
    end
    all_loaded_sets
  end

  def load_all_sets(folder_path)
    Dir[APP_ROOT + '/training_sets/*csv'].map { |file| load_set(file) }
  end

  def load_set(file_path)
    category = file_path.match(/.*\/(.*)\.csv/)[1]
    set = Trainer.new(category)
    CSV.foreach(file_path) do |row|
      set.training_set[row[0]] = row[1].to_f
    end
    set
  end

end
