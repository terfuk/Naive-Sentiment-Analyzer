// SentimentAnalyzer.java
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

public class SentimentAnalyzer {
    private Set<String> positiveWords;
    private Set<String> negativeWords;
    private Set<String> negationWords;
    private Map<String, String> emojiMap;

    public SentimentAnalyzer() {
        positiveWords = new HashSet<>(Arrays.asList(
            "good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome",
            "love", "like", "enjoy", "happy", "glad", "pleased", "delighted", "satisfied",
            "best", "beautiful", "nice", "perfect", "brilliant", "superb", "outstanding",
            "terrific", "marvellous", "fabulous", "splendid", "magnificent", "incredible"
        ));
        negativeWords = new HashSet<>(Arrays.asList(
            "bad", "terrible", "awful", "horrible", "dreadful", "terrifying", "frightening",
            "hate", "dislike", "annoy", "upset", "sad", "depressed", "miserable", "unhappy",
            "worst", "ugly", "poor", "mediocre", "lousy", "disappointing", "pathetic",
            "abysmal", "atrocious", "deplorable", "detestable", "disgusting", "dismal"
        ));
        negationWords = new HashSet<>(Arrays.asList("not", "never", "no", "neither", "nor", "without", "none"));
        emojiMap = new HashMap<>();
        emojiMap.put("😊", "positive"); emojiMap.put("😀", "positive"); emojiMap.put("😄", "positive");
        emojiMap.put("❤️", "positive"); emojiMap.put("👍", "positive"); emojiMap.put("😍", "positive");
        emojiMap.put("😢", "negative"); emojiMap.put("😞", "negative"); emojiMap.put("💔", "negative");
        emojiMap.put("👎", "negative"); emojiMap.put("😡", "negative");
    }

    private List<String> tokenize(String text) {
        text = text.replaceAll("[^\\w\\s']+", " ");
        for (Map.Entry<String, String> e : emojiMap.entrySet())
            text = text.replace(e.getKey(), " " + e.getValue() + " ");
        return Arrays.asList(text.toLowerCase().split("\\s+"));
    }

    public static class SentimentResult {
        public String sentiment;
        public double score;
        public List<String> positiveWords;
        public List<String> negativeWords;
        public int positiveCount, negativeCount, neutralCount;
        public double polarity;
    }

    public SentimentResult analyze(String text) {
        List<String> tokens = tokenize(text);
        if (tokens.isEmpty()) {
            SentimentResult r = new SentimentResult();
            r.sentiment = "neutral"; r.score = 0;
            r.positiveWords = new ArrayList<>(); r.negativeWords = new ArrayList<>();
            return r;
        }
        List<String> posWords = new ArrayList<>(), negWords = new ArrayList<>();
        int score = 0;
        int i = 0;
        while (i < tokens.size()) {
            String word = tokens.get(i);
            boolean negate = false;
            if (negationWords.contains(word) && i + 1 < tokens.size()) {
                negate = true;
                i++;
                word = tokens.get(i);
            }
            if (positiveWords.contains(word)) {
                int val = negate ? -1 : 1;
                score += val;
                if (val > 0) posWords.add(word); else negWords.add(word);
            } else if (negativeWords.contains(word)) {
                int val = negate ? 1 : -1;
                score += val;
                if (val > 0) posWords.add(word); else negWords.add(word);
            }
            i++;
        }
        int total = tokens.size();
        int posCount = posWords.size();
        int negCount = negWords.size();
        int neutralCount = total - posCount - negCount;
        double polarity = total > 0 ? (double)(posCount - negCount) / total : 0;
        String sentiment = score > 0 ? "positive" : (score < 0 ? "negative" : "neutral");
        SentimentResult r = new SentimentResult();
        r.sentiment = sentiment;
        r.score = score;
        r.positiveWords = posWords;
        r.negativeWords = negWords;
        r.positiveCount = posCount;
        r.negativeCount = negCount;
        r.neutralCount = neutralCount;
        r.polarity = polarity;
        return r;
    }

    public List<SentimentResult> batchAnalyze(String[] texts) {
        List<SentimentResult> results = new ArrayList<>();
        for (String t : texts) results.add(analyze(t));
        return results;
    }

    public static void main(String[] args) throws IOException {
        SentimentAnalyzer analyzer = new SentimentAnalyzer();
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("=== Naive Sentiment Analyzer ===");
        while (true) {
            System.out.println("\n1. Analyze text");
            System.out.println("2. Analyze from file");
            System.out.println("3. Show word lists");
            System.out.println("4. Exit");
            System.out.print("Choose: ");
            String choice = reader.readLine().trim();
            switch (choice) {
                case "1":
                    System.out.print("Enter text: ");
                    String text = reader.readLine();
                    SentimentResult result = analyzer.analyze(text);
                    System.out.printf("\nSentiment: %s\n", result.sentiment.toUpperCase());
                    System.out.printf("Score: %.1f\n", result.score);
                    System.out.printf("Positive words: %s\n", result.positiveWords.isEmpty() ? "none" : String.join(", ", result.positiveWords));
                    System.out.printf("Negative words: %s\n", result.negativeWords.isEmpty() ? "none" : String.join(", ", result.negativeWords));
                    System.out.printf("Positive count: %d, Negative count: %d, Neutral count: %d\n",
                            result.positiveCount, result.negativeCount, result.neutralCount);
                    System.out.printf("Polarity: %.1f%% positive\n", result.polarity * 100);
                    break;
                case "2":
                    System.out.print("Enter file path: ");
                    String fname = reader.readLine().trim();
                    try {
                        List<String> lines = Files.readAllLines(Paths.get(fname));
                        lines.removeIf(String::isEmpty);
                        List<SentimentResult> results = analyzer.batchAnalyze(lines.toArray(new String[0]));
                        System.out.println("\nBatch results:");
                        for (int i = 0; i < results.size(); i++)
                            System.out.printf("%d. Sentiment: %s, Score: %.1f\n", i+1, results.get(i).sentiment, results.get(i).score);
                    } catch (IOException e) {
                        System.out.println("File not found.");
                    }
                    break;
                case "3":
                    System.out.printf("Positive words (%d): %s...\n", analyzer.positiveWords.size(),
                            String.join(", ", analyzer.positiveWords.stream().limit(20).toArray(String[]::new)));
                    System.out.printf("Negative words (%d): %s...\n", analyzer.negativeWords.size(),
                            String.join(", ", analyzer.negativeWords.stream().limit(20).toArray(String[]::new)));
                    break;
                case "4":
                    System.out.println("Goodbye!");
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }
}
