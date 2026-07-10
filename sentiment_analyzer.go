// sentiment_analyzer.go
package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

type SentimentAnalyzer struct {
	positiveWords map[string]bool
	negativeWords map[string]bool
	negationWords map[string]bool
	emojiMap      map[string]string
}

func NewSentimentAnalyzer() *SentimentAnalyzer {
	sa := &SentimentAnalyzer{
		positiveWords: make(map[string]bool),
		negativeWords: make(map[string]bool),
		negationWords: make(map[string]bool),
		emojiMap:      make(map[string]string),
	}
	// Initialize positive words
	posList := []string{"good", "great", "excellent", "amazing", "wonderful", "fantastic", "awesome",
		"love", "like", "enjoy", "happy", "glad", "pleased", "delighted", "satisfied",
		"best", "beautiful", "nice", "perfect", "brilliant", "superb", "outstanding",
		"terrific", "marvellous", "fabulous", "splendid", "magnificent", "incredible"}
	for _, w := range posList {
		sa.positiveWords[w] = true
	}
	// Initialize negative words
	negList := []string{"bad", "terrible", "awful", "horrible", "dreadful", "terrifying", "frightening",
		"hate", "dislike", "annoy", "upset", "sad", "depressed", "miserable", "unhappy",
		"worst", "ugly", "poor", "mediocre", "lousy", "disappointing", "pathetic",
		"abysmal", "atrocious", "deplorable", "detestable", "disgusting", "dismal"}
	for _, w := range negList {
		sa.negativeWords[w] = true
	}
	// Negation words
	negWords := []string{"not", "never", "no", "neither", "nor", "without", "none"}
	for _, w := range negWords {
		sa.negationWords[w] = true
	}
	// Emoji mapping
	sa.emojiMap["😊"] = "positive"
	sa.emojiMap["😀"] = "positive"
	sa.emojiMap["😄"] = "positive"
	sa.emojiMap["❤️"] = "positive"
	sa.emojiMap["👍"] = "positive"
	sa.emojiMap["😍"] = "positive"
	sa.emojiMap["😢"] = "negative"
	sa.emojiMap["😞"] = "negative"
	sa.emojiMap["💔"] = "negative"
	sa.emojiMap["👎"] = "negative"
	sa.emojiMap["😡"] = "negative"
	return sa
}

func (sa *SentimentAnalyzer) tokenize(text string) []string {
	// Remove punctuation
	re := regexp.MustCompile(`[^\w\s']+`)
	text = re.ReplaceAllString(text, " ")
	// Replace emojis
	for emoji, sentiment := range sa.emojiMap {
		text = strings.ReplaceAll(text, emoji, " "+sentiment+" ")
	}
	// Split and lower
	tokens := strings.Fields(strings.ToLower(text))
	return tokens
}

type SentimentResult struct {
	Sentiment      string
	Score          float64
	PositiveWords  []string
	NegativeWords  []string
	PositiveCount  int
	NegativeCount  int
	NeutralCount   int
	Polarity       float64
}

func (sa *SentimentAnalyzer) Analyze(text string) SentimentResult {
	tokens := sa.tokenize(text)
	if len(tokens) == 0 {
		return SentimentResult{Sentiment: "neutral", Score: 0}
	}
	var posWords, negWords []string
	score := 0
	i := 0
	for i < len(tokens) {
		word := tokens[i]
		negate := false
		if sa.negationWords[word] && i+1 < len(tokens) {
			negate = true
			i++
			word = tokens[i]
		}
		if sa.positiveWords[word] {
			val := 1
			if negate {
				val = -1
			}
			score += val
			if val > 0 {
				posWords = append(posWords, word)
			} else {
				negWords = append(negWords, word)
			}
		} else if sa.negativeWords[word] {
			val := -1
			if negate {
				val = 1
			}
			score += val
			if val > 0 {
				posWords = append(posWords, word)
			} else {
				negWords = append(negWords, word)
			}
		}
		i++
	}
	totalWords := len(tokens)
	posCount := len(posWords)
	negCount := len(negWords)
	neutralCount := totalWords - posCount - negCount
	polarity := 0.0
	if totalWords > 0 {
		polarity = float64(posCount-negCount) / float64(totalWords)
	}
	sentiment := "neutral"
	if score > 0 {
		sentiment = "positive"
	} else if score < 0 {
		sentiment = "negative"
	}
	return SentimentResult{
		Sentiment:     sentiment,
		Score:         float64(score),
		PositiveWords: posWords,
		NegativeWords: negWords,
		PositiveCount: posCount,
		NegativeCount: negCount,
		NeutralCount:  neutralCount,
		Polarity:      polarity,
	}
}

func (sa *SentimentAnalyzer) BatchAnalyze(texts []string) []SentimentResult {
	results := make([]SentimentResult, len(texts))
	for i, t := range texts {
		results[i] = sa.Analyze(t)
	}
	return results
}

func main() {
	analyzer := NewSentimentAnalyzer()
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Naive Sentiment Analyzer ===")
	for {
		fmt.Println("\n1. Analyze text")
		fmt.Println("2. Analyze from file")
		fmt.Println("3. Show word lists")
		fmt.Println("4. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			fmt.Print("Enter text: ")
			scanner.Scan()
			text := scanner.Text()
			result := analyzer.Analyze(text)
			fmt.Printf("\nSentiment: %s\n", strings.ToUpper(result.Sentiment))
			fmt.Printf("Score: %.1f\n", result.Score)
			fmt.Printf("Positive words: %v\n", result.PositiveWords)
			fmt.Printf("Negative words: %v\n", result.NegativeWords)
			fmt.Printf("Positive count: %d, Negative count: %d, Neutral count: %d\n",
				result.PositiveCount, result.NegativeCount, result.NeutralCount)
			fmt.Printf("Polarity: %.1f%% positive\n", result.Polarity*100)
		case "2":
			fmt.Print("Enter file path: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			file, err := os.Open(fname)
			if err != nil {
				fmt.Println("File not found.")
				break
			}
			defer file.Close()
			var lines []string
			fs := bufio.NewScanner(file)
			for fs.Scan() {
				line := strings.TrimSpace(fs.Text())
				if line != "" {
					lines = append(lines, line)
				}
			}
			results := analyzer.BatchAnalyze(lines)
			fmt.Println("\nBatch results:")
			for i, r := range results {
				fmt.Printf("%d. Sentiment: %s, Score: %.1f\n", i+1, r.Sentiment, r.Score)
			}
		case "3":
			fmt.Printf("Positive words (%d): ", len(analyzer.positiveWords))
			count := 0
			for w := range analyzer.positiveWords {
				if count < 20 {
					fmt.Print(w, " ")
					count++
				}
			}
			fmt.Println("...")
			fmt.Printf("Negative words (%d): ", len(analyzer.negativeWords))
			count = 0
			for w := range analyzer.negativeWords {
				if count < 20 {
					fmt.Print(w, " ")
					count++
				}
			}
			fmt.Println("...")
		case "4":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
