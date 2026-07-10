// SentimentAnalyzer.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

class SentimentAnalyzer
{
    private HashSet<string> positiveWords;
    private HashSet<string> negativeWords;
    private HashSet<string> negationWords;
    private Dictionary<string, string> emojiMap;

    public SentimentAnalyzer()
    {
        positiveWords = new HashSet<string> {
            "good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome",
            "love", "like", "enjoy", "happy", "glad", "pleased", "delighted", "satisfied",
            "best", "beautiful", "nice", "perfect", "brilliant", "superb", "outstanding",
            "terrific", "marvellous", "fabulous", "splendid", "magnificent", "incredible"
        };
        negativeWords = new HashSet<string> {
            "bad", "terrible", "awful", "horrible", "dreadful", "terrifying", "frightening",
            "hate", "dislike", "annoy", "upset", "sad", "depressed", "miserable", "unhappy",
            "worst", "ugly", "poor", "mediocre", "lousy", "disappointing", "pathetic",
            "abysmal", "atrocious", "deplorable", "detestable", "disgusting", "dismal"
        };
        negationWords = new HashSet<string> { "not", "never", "no", "neither", "nor", "without", "none" };
        emojiMap = new Dictionary<string, string> {
            {"😊", "positive"}, {"😀", "positive"}, {"😄", "positive"}, {"❤️", "positive"},
            {"👍", "positive"}, {"😍", "positive"}, {"😢", "negative"}, {"😞", "negative"},
            {"💔", "negative"}, {"👎", "negative"}, {"😡", "negative"}
        };
    }

    private List<string> Tokenize(string text)
    {
        text = Regex.Replace(text, @"[^\w\s']+", " ");
        foreach (var kv in emojiMap)
            text = text.Replace(kv.Key, " " + kv.Value + " ");
        return text.ToLower().Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();
    }

    public class SentimentResult
    {
        public string Sentiment { get; set; }
        public double Score { get; set; }
        public List<string> PositiveWords { get; set; }
        public List<string> NegativeWords { get; set; }
        public int PositiveCount { get; set; }
        public int NegativeCount { get; set; }
        public int NeutralCount { get; set; }
        public double Polarity { get; set; }
    }

    public SentimentResult Analyze(string text)
    {
        var tokens = Tokenize(text);
        if (tokens.Count == 0)
            return new SentimentResult { Sentiment = "neutral", Score = 0, PositiveWords = new List<string>(), NegativeWords = new List<string>() };
        var posWords = new List<string>();
        var negWords = new List<string>();
        int score = 0;
        int i = 0;
        while (i < tokens.Count)
        {
            string word = tokens[i];
            bool negate = false;
            if (negationWords.Contains(word) && i + 1 < tokens.Count)
            {
                negate = true;
                i++;
                word = tokens[i];
            }
            if (positiveWords.Contains(word))
            {
                int val = negate ? -1 : 1;
                score += val;
                if (val > 0) posWords.Add(word); else negWords.Add(word);
            }
            else if (negativeWords.Contains(word))
            {
                int val = negate ? 1 : -1;
                score += val;
                if (val > 0) posWords.Add(word); else negWords.Add(word);
            }
            i++;
        }
        int total = tokens.Count;
        int posCount = posWords.Count;
        int negCount = negWords.Count;
        int neutralCount = total - posCount - negCount;
        double polarity = total > 0 ? (double)(posCount - negCount) / total : 0;
        string sentiment = score > 0 ? "positive" : (score < 0 ? "negative" : "neutral");
        return new SentimentResult
        {
            Sentiment = sentiment,
            Score = score,
            PositiveWords = posWords,
            NegativeWords = negWords,
            PositiveCount = posCount,
            NegativeCount = negCount,
            NeutralCount = neutralCount,
            Polarity = polarity
        };
    }

    public List<SentimentResult> BatchAnalyze(string[] texts)
    {
        return texts.Select(t => Analyze(t)).ToList();
    }

    static void Main()
    {
        var analyzer = new SentimentAnalyzer();
        Console.WriteLine("=== Naive Sentiment Analyzer ===");
        while (true)
        {
            Console.WriteLine("\n1. Analyze text");
            Console.WriteLine("2. Analyze from file");
            Console.WriteLine("3. Show word lists");
            Console.WriteLine("4. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim() ?? "";
            switch (choice)
            {
                case "1":
                    Console.Write("Enter text: ");
                    string text = Console.ReadLine() ?? "";
                    var result = analyzer.Analyze(text);
                    Console.WriteLine($"\nSentiment: {result.Sentiment.ToUpper()}");
                    Console.WriteLine($"Score: {result.Score}");
                    Console.WriteLine($"Positive words: {(result.PositiveWords.Any() ? string.Join(", ", result.PositiveWords) : "none")}");
                    Console.WriteLine($"Negative words: {(result.NegativeWords.Any() ? string.Join(", ", result.NegativeWords) : "none")}");
                    Console.WriteLine($"Positive count: {result.PositiveCount}, Negative count: {result.NegativeCount}, Neutral count: {result.NeutralCount}");
                    Console.WriteLine($"Polarity: {result.Polarity * 100:F1}% positive");
                    break;
                case "2":
                    Console.Write("Enter file path: ");
                    string fname = Console.ReadLine()?.Trim() ?? "";
                    if (!File.Exists(fname))
                    {
                        Console.WriteLine("File not found.");
                        break;
                    }
                    var lines = File.ReadAllLines(fname).Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();
                    var results = analyzer.BatchAnalyze(lines);
                    Console.WriteLine("\nBatch results:");
                    for (int i = 0; i < results.Count; i++)
                        Console.WriteLine($"{i+1}. Sentiment: {results[i].Sentiment}, Score: {results[i].Score}");
                    break;
                case "3":
                    Console.WriteLine($"Positive words ({analyzer.positiveWords.Count}): {string.Join(", ", analyzer.positiveWords.Take(20))}...");
                    Console.WriteLine($"Negative words ({analyzer.negativeWords.Count}): {string.Join(", ", analyzer.negativeWords.Take(20))}...");
                    break;
                case "4":
                    Console.WriteLine("Goodbye!");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
