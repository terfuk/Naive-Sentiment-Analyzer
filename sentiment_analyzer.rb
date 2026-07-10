# sentiment_analyzer.rb
class SentimentAnalyzer
  def initialize
    @positive_words = Set.new(%w[
      good great excellent amazing wonderful fantastic awesome
      love like enjoy happy glad pleased delighted satisfied
      best beautiful nice perfect brilliant superb outstanding
      terrific marvellous fabulous splendid magnificent incredible
    ])
    @negative_words = Set.new(%w[
      bad terrible awful horrible dreadful terrifying frightening
      hate dislike annoy upset sad depressed miserable unhappy
      worst ugly poor mediocre lousy disappointing pathetic
      abysmal atrocious deplorable detestable disgusting dismal
    ])
    @negation_words = Set.new(%w[not never no neither nor without none])
    @emoji_map = {
      '😊' => 'positive', '😀' => 'positive', '😄' => 'positive', '❤️' => 'positive',
      '👍' => 'positive', '😍' => 'positive', '😢' => 'negative', '😞' => 'negative',
      '💔' => 'negative', '👎' => 'negative', '😡' => 'negative'
    }
  end

  def tokenize(text)
    text = text.gsub(/[^\w\s']+/, ' ')
    @emoji_map.each { |emoji, sentiment| text = text.gsub(emoji, " #{sentiment} ") }
    text.downcase.split
  end

  def analyze(text)
    tokens = tokenize(text)
    return { sentiment: 'neutral', score: 0, positive_words: [], negative_words: [],
             positive_count: 0, negative_count: 0, neutral_count: 0, polarity: 0 } if tokens.empty?

    pos_words, neg_words = [], []
    score = 0
    i = 0
    while i < tokens.length
      word = tokens[i]
      negate = false
      if @negation_words.include?(word) && i + 1 < tokens.length
        negate = true
        i += 1
        word = tokens[i]
      end
      if @positive_words.include?(word)
        val = negate ? -1 : 1
        score += val
        (val > 0 ? pos_words : neg_words) << word
      elsif @negative_words.include?(word)
        val = negate ? 1 : -1
        score += val
        (val > 0 ? pos_words : neg_words) << word
      end
      i += 1
    end
    total = tokens.length
    pos_count = pos_words.length
    neg_count = neg_words.length
    neutral_count = total - pos_count - neg_count
    polarity = total > 0 ? (pos_count - neg_count).to_f / total : 0
    sentiment = score > 0 ? 'positive' : (score < 0 ? 'negative' : 'neutral')
    { sentiment: sentiment, score: score, positive_words: pos_words, negative_words: neg_words,
      positive_count: pos_count, negative_count: neg_count, neutral_count: neutral_count, polarity: polarity }
  end

  def batch_analyze(texts)
    texts.map { |t| analyze(t) }
  end
end

def main
  analyzer = SentimentAnalyzer.new
  puts "=== Naive Sentiment Analyzer ==="
  loop do
    puts "\n1. Analyze text"
    puts "2. Analyze from file"
    puts "3. Show word lists"
    puts "4. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      print "Enter text: "
      text = gets.chomp
      result = analyzer.analyze(text)
      puts "\nSentiment: #{result[:sentiment].upcase}"
      puts "Score: #{result[:score]}"
      puts "Positive words: #{result[:positive_words].empty? ? 'none' : result[:positive_words].join(', ')}"
      puts "Negative words: #{result[:negative_words].empty? ? 'none' : result[:negative_words].join(', ')}"
      puts "Positive count: #{result[:positive_count]}, Negative count: #{result[:negative_count]}, Neutral count: #{result[:neutral_count]}"
      puts "Polarity: #{'%.1f' % (result[:polarity] * 100)}% positive"
    when '2'
      print "Enter file path: "
      fname = gets.chomp.strip
      begin
        lines = File.readlines(fname).map(&:chomp).reject(&:empty?)
        results = analyzer.batch_analyze(lines)
        puts "\nBatch results:"
        results.each_with_index { |r, i| puts "#{i+1}. Sentiment: #{r[:sentiment]}, Score: #{r[:score]}" }
      rescue Errno::ENOENT
        puts "File not found."
      end
    when '3'
      puts "Positive words (#{analyzer.instance_variable_get(:@positive_words).size}): #{analyzer.instance_variable_get(:@positive_words).to_a.first(20).join(', ')}..."
      puts "Negative words (#{analyzer.instance_variable_get(:@negative_words).size}): #{analyzer.instance_variable_get(:@negative_words).to_a.first(20).join(', ')}..."
    when '4'
      puts "Goodbye!"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
