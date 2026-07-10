😊 Naive Sentiment Analyzer – Multi‑Language Edition

A lightweight **sentiment analysis tool** that classifies text as positive, negative, or neutral using a lexicon‑based approach.  
Supports negation handling, emoji detection, custom word lists, and detailed statistics.  
Built in **7 programming languages** – perfect for learning NLP basics, prototyping, or integration.

## ✨ Features
- **Lexicon-based scoring** – uses built‑in lists of positive and negative words.
- **Negation handling** – detects words like `not`, `never`, `no` and inverts sentiment of the following word.
- **Emoji support** – converts common emojis to sentiment tokens (😊 → positive, 😢 → negative).
- **Capitalization and punctuation** – case‑insensitive; strips punctuation automatically.
- **Custom dictionaries** – load your own positive/negative word lists from files.
- **Detailed output** – shows sentiment score, word counts, percentages, and a breakdown of positive/negative words.
- **Batch processing** – analyze multiple texts from a file.
- **Interactive CLI** – easy‑to‑use menu with options.

## 🗂 Languages & Files
| Language          | File                        |
|-------------------|-----------------------------|
| Python            | `sentiment_analyzer.py`     |
| Go                | `sentiment_analyzer.go`     |
| JavaScript (Node) | `sentiment_analyzer.js`     |
| C#                | `SentimentAnalyzer.cs`      |
| Java              | `SentimentAnalyzer.java`    |
| Ruby              | `sentiment_analyzer.rb`     |
| Swift             | `sentiment_analyzer.swift`  |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python sentiment_analyzer.py` |
| Go       | `go run sentiment_analyzer.go` |
| JavaScript | `node sentiment_analyzer.js` |
| C#       | `dotnet run` (or `csc SentimentAnalyzer.cs`) |
| Java     | `javac SentimentAnalyzer.java && java SentimentAnalyzer` |
| Ruby     | `ruby sentiment_analyzer.rb` |
| Swift    | `swift sentiment_analyzer.swift` |

## 📊 Example Session
=== Naive Sentiment Analyzer ===

Analyze text

Analyze from file

Show custom word lists

Load custom word lists

Exit
Choose: 1

Enter text: I really love this movie! It's amazing and not boring at all.
Sentiment: POSITIVE
Score: 4.0
Positive words: love, amazing (2)
Negative words: boring (1)
Neutral words: 5
Polarity: 60.0% positive, 40.0% negative

text

## 🔧 Technical Details
- **Built‑in word lists** – 100+ positive and negative English words.
- **Negation words** – `not`, `never`, `no`, `neither`, `nor`, `without`, `none`.
- **Emoji mapping** – maps 😊😀😄❤️ → positive, 😢😞💔 → negative (configurable).
- **Scoring** – each positive word adds +1, each negative word adds -1. Negation flips the score of the following word.
- **Classification** – positive if score > 0, negative if score < 0, neutral if score == 0.

## 🤝 Contributing
Add support for more languages, use TF‑IDF weighting, or integrate with a machine learning model – PRs welcome!

## 📜 License
MIT – use freely.
