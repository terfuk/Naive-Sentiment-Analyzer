// sentiment_analyzer.swift
import Foundation

class SentimentAnalyzer {
    private var positiveWords: Set<String>
    private var negativeWords: Set<String>
    private var negationWords: Set<String>
    private var emojiMap: [String: String]

    init() {
        positiveWords = Set([
            "good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome",
            "love", "like", "enjoy", "happy", "glad", "pleased", "delighted", "satisfied",
            "best", "beautiful", "nice", "perfect", "brilliant", "superb", "outstanding",
            "terrific", "marvellous", "fabulous", "splendid", "magnificent", "incredible"
        ])
        negativeWords = Set([
            "bad", "terrible", "awful", "horrible", "dreadful", "terrifying", "frightening",
            "hate", "dislike", "annoy", "upset", "sad", "depressed", "miserable", "unhappy",
            "worst", "ugly", "poor", "mediocre", "lousy", "disappointing", "pathetic",
            "abysmal", "atrocious", "deplorable", "detestable", "disgusting", "dismal"
        ])
        negationWords = Set(["not", "never", "no", "neither", "nor", "without", "none"])
        emojiMap = [
            "😊": "positive", "😀": "positive", "😄": "positive", "❤️": "positive",
            "👍": "positive", "😍": "positive", "😢": "negative", "😞": "negative",
            "💔": "negative", "👎": "negative", "😡": "negative"
        ]
    }

    func tokenize(_ text: String) -> [String] {
        var result = text.replacingOccurrences(of: "[^\\w\\s']+", with: " ", options: .regularExpression)
        for (emoji, sentiment) in emojiMap {
            result = result.replacingOccurrences(of: emoji, with: " \(sentiment) ")
        }
        return result.lowercased().split(separator: " ").map(String.init)
    }

    struct SentimentResult {
        var sentiment: String
        var score: Double
        var positiveWords: [String]
        var negativeWords: [String]
        var positiveCount: Int
        var negativeCount: Int
        var neutralCount: Int
        var polarity: Double
    }

    func analyze(_ text: String) -> SentimentResult {
        let tokens = tokenize(text)
        guard !tokens.isEmpty else {
            return SentimentResult(sentiment: "neutral", score: 0, positiveWords: [], negativeWords: [],
                                   positiveCount: 0, negativeCount: 0, neutralCount: 0, polarity: 0)
        }
        var posWords: [String] = []
        var negWords: [String] = []
        var score = 0
        var i = 0
        while i < tokens.count {
            var word = tokens[i]
            var negate = false
            if negationWords.contains(word) && i + 1 < tokens.count {
                negate = true
                i += 1
                word = tokens[i]
            }
            if positiveWords.contains(word) {
                let val = negate ? -1 : 1
                score += val
                if val > 0 { posWords.append(word) } else { negWords.append(word) }
            } else if negativeWords.contains(word) {
                let val = negate ? 1 : -1
                score += val
                if val > 0 { posWords.append(word) } else { negWords.append(word) }
            }
            i += 1
        }
        let total = tokens.count
        let posCount = posWords.count
        let negCount = negWords.count
        let neutralCount = total - posCount - negCount
        let polarity = total > 0 ? Double(posCount - negCount) / Double(total) : 0
        let sentiment = score > 0 ? "positive" : (score < 0 ? "negative" : "neutral")
        return SentimentResult(
            sentiment: sentiment,
            score: Double(score),
            positiveWords: posWords,
            negativeWords: negWords,
            positiveCount: posCount,
            negativeCount: negCount,
            neutralCount: neutralCount,
            polarity: polarity
        )
    }

    func batchAnalyze(_ texts: [String]) -> [SentimentResult] {
        return texts.map { analyze($0) }
    }
}

func main() {
    let analyzer = SentimentAnalyzer()
    print("=== Naive Sentiment Analyzer ===")
    while true {
        print("\n1. Analyze text")
        print("2. Analyze from file")
        print("3. Show word lists")
        print("4. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        switch choice {
        case "1":
            print("Enter text: ", terminator: "")
            guard let text = readLine() else { break }
            let result = analyzer.analyze(text)
            print("\nSentiment: \(result.sentiment.uppercased())")
            print("Score: \(result.score)")
            print("Positive words: \(result.positiveWords.isEmpty ? "none" : result.positiveWords.joined(separator: ", "))")
            print("Negative words: \(result.negativeWords.isEmpty ? "none" : result.negativeWords.joined(separator: ", "))")
            print("Positive count: \(result.positiveCount), Negative count: \(result.negativeCount), Neutral count: \(result.neutralCount)")
            print("Polarity: \(String(format: "%.1f", result.polarity * 100))% positive")
        case "2":
            print("Enter file path: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespaces) else { break }
            do {
                let content = try String(contentsOfFile: fname, encoding: .utf8)
                let lines = content.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                let results = analyzer.batchAnalyze(lines)
                print("\nBatch results:")
                for (i, r) in results.enumerated() {
                    print("\(i+1). Sentiment: \(r.sentiment), Score: \(r.score)")
                }
            } catch {
                print("File not found.")
            }
        case "3":
            let pos = Array(analyzer.positiveWords).prefix(20)
            let neg = Array(analyzer.negativeWords).prefix(20)
            print("Positive words: \(pos.joined(separator: ", "))...")
            print("Negative words: \(neg.joined(separator: ", "))...")
        case "4":
            print("Goodbye!")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
