# sentiment_analyzer.py
import re
import json
from typing import Dict, List, Tuple, Optional

class SentimentAnalyzer:
    def __init__(self):
        self.positive_words = {
            'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic', 'awesome',
            'love', 'like', 'enjoy', 'happy', 'glad', 'pleased', 'delighted', 'satisfied',
            'best', 'beautiful', 'nice', 'perfect', 'brilliant', 'superb', 'outstanding',
            'terrific', 'marvellous', 'fabulous', 'splendid', 'magnificent', 'incredible',
            'lovely', 'charming', 'delightful', 'enjoyable', 'pleasant', 'wonderful',
            'favorable', 'positive', 'optimistic', 'hopeful', 'confident', 'proud',
            'relieved', 'grateful', 'thankful', 'blessed', 'joyful', 'ecstatic',
            'radiant', 'glowing', 'cheerful', 'jovial', 'merry', 'jolly', 'elated'
        }
        self.negative_words = {
            'bad', 'terrible', 'awful', 'horrible', 'dreadful', 'terrifying', 'frightening',
            'hate', 'dislike', 'annoy', 'upset', 'sad', 'depressed', 'miserable', 'unhappy',
            'worst', 'ugly', 'poor', 'mediocre', 'lousy', 'disappointing', 'pathetic',
            'abysmal', 'atrocious', 'deplorable', 'detestable', 'disgusting', 'dismal',
            'dreadful', 'foul', 'ghastly', 'gruesome', 'hideous', 'horrendous', 'horrific',
            'lamentable', 'nasty', 'odious', 'offensive', 'reprehensible', 'repugnant',
            'repulsive', 'revolting', 'rotten', 'shameful', 'sickening', 'sordid',
            'squalid', 'sulky', 'sullen', 'surly', 'unpleasant', 'vile', 'wicked',
            'angry', 'furious', 'enraged', 'irritated', 'annoyed', 'frustrated'
        }
        self.negation_words = {'not', 'never', 'no', 'neither', 'nor', 'without', 'none'}
        self.emoji_map = {
            '😊': 'positive', '😀': 'positive', '😄': 'positive', '❤️': 'positive',
            '👍': 'positive', '😍': 'positive', '🥰': 'positive', '😁': 'positive',
            '😢': 'negative', '😞': 'negative', '💔': 'negative', '👎': 'negative',
            '😡': 'negative', '😠': 'negative', '😭': 'negative', '😩': 'negative'
        }
        self.positive_words.update({v: 'positive' for v in self.emoji_map if self.emoji_map[v] == 'positive'})
        self.negative_words.update({v: 'negative' for v in self.emoji_map if self.emoji_map[v] == 'negative'})

    def tokenize(self, text: str) -> List[str]:
        # Remove punctuation except apostrophes (keep contractions)
        text = re.sub(r"[^\w\s']+", ' ', text)
        # Replace emojis with their sentiment labels
        for emoji, sentiment in self.emoji_map.items():
            text = text.replace(emoji, f' {sentiment} ')
        return text.lower().split()

    def analyze(self, text: str) -> Dict:
        tokens = self.tokenize(text)
        if not tokens:
            return {'sentiment': 'neutral', 'score': 0, 'positive_words': [], 'negative_words': [],
                    'positive_count': 0, 'negative_count': 0, 'neutral_count': 0, 'polarity': 0}

        pos_words, neg_words = [], []
        score = 0
        i = 0
        while i < len(tokens):
            word = tokens[i]
            negate = False
            # Check for negation
            if word in self.negation_words and i + 1 < len(tokens):
                negate = True
                i += 1
                word = tokens[i]
            # Check sentiment
            if word in self.positive_words:
                val = -1 if negate else 1
                score += val
                (pos_words if val > 0 else neg_words).append(word)
            elif word in self.negative_words:
                val = 1 if negate else -1
                score += val
                (pos_words if val > 0 else neg_words).append(word)
            i += 1

        total_words = len(tokens)
        pos_count = len(pos_words)
        neg_count = len(neg_words)
        neutral_count = total_words - pos_count - neg_count
        polarity = (pos_count - neg_count) / total_words if total_words else 0

        if score > 0:
            sentiment = 'positive'
        elif score < 0:
            sentiment = 'negative'
        else:
            sentiment = 'neutral'

        return {
            'sentiment': sentiment,
            'score': score,
            'positive_words': pos_words,
            'negative_words': neg_words,
            'positive_count': pos_count,
            'negative_count': neg_count,
            'neutral_count': neutral_count,
            'polarity': polarity
        }

    def batch_analyze(self, texts: List[str]) -> List[Dict]:
        return [self.analyze(t) for t in texts]

def main():
    analyzer = SentimentAnalyzer()
    print("=== Naive Sentiment Analyzer ===")
    while True:
        print("\n1. Analyze text")
        print("2. Analyze from file")
        print("3. Show custom word lists")
        print("4. Load custom word lists")
        print("5. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            text = input("Enter text: ")
            result = analyzer.analyze(text)
            print(f"\nSentiment: {result['sentiment'].upper()}")
            print(f"Score: {result['score']:.1f}")
            print(f"Positive words: {', '.join(result['positive_words']) if result['positive_words'] else 'none'}")
            print(f"Negative words: {', '.join(result['negative_words']) if result['negative_words'] else 'none'}")
            print(f"Positive count: {result['positive_count']}, Negative count: {result['negative_count']}, Neutral count: {result['neutral_count']}")
            print(f"Polarity: {result['polarity']*100:.1f}% positive")
        elif choice == '2':
            fname = input("Enter file path: ")
            try:
                with open(fname, 'r', encoding='utf-8') as f:
                    lines = [line.strip() for line in f if line.strip()]
                results = analyzer.batch_analyze(lines)
                print("\nBatch results:")
                for i, res in enumerate(results, 1):
                    print(f"{i}. Sentiment: {res['sentiment']}, Score: {res['score']:.1f}")
            except FileNotFoundError:
                print("File not found.")
        elif choice == '3':
            print(f"Positive words ({len(analyzer.positive_words)}): {', '.join(sorted(analyzer.positive_words)[:20])}...")
            print(f"Negative words ({len(analyzer.negative_words)}): {', '.join(sorted(analyzer.negative_words)[:20])}...")
        elif choice == '4':
            print("Load custom word lists (positive.txt, negative.txt)")
            try:
                with open('positive.txt', 'r', encoding='utf-8') as f:
                    analyzer.positive_words.update(line.strip().lower() for line in f if line.strip())
                with open('negative.txt', 'r', encoding='utf-8') as f:
                    analyzer.negative_words.update(line.strip().lower() for line in f if line.strip())
                print("Custom word lists loaded.")
            except FileNotFoundError:
                print("Files not found. Create positive.txt and negative.txt.")
        elif choice == '5':
            print("Goodbye!")
            break
        else:
            print("Invalid choice.")

if __name__ == '__main__':
    main()
