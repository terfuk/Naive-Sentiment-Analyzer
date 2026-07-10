// sentiment_analyzer.js
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

class SentimentAnalyzer {
    constructor() {
        this.positiveWords = new Set([
            'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic', 'awesome',
            'love', 'like', 'enjoy', 'happy', 'glad', 'pleased', 'delighted', 'satisfied',
            'best', 'beautiful', 'nice', 'perfect', 'brilliant', 'superb', 'outstanding',
            'terrific', 'marvellous', 'fabulous', 'splendid', 'magnificent', 'incredible'
        ]);
        this.negativeWords = new Set([
            'bad', 'terrible', 'awful', 'horrible', 'dreadful', 'terrifying', 'frightening',
            'hate', 'dislike', 'annoy', 'upset', 'sad', 'depressed', 'miserable', 'unhappy',
            'worst', 'ugly', 'poor', 'mediocre', 'lousy', 'disappointing', 'pathetic',
            'abysmal', 'atrocious', 'deplorable', 'detestable', 'disgusting', 'dismal'
        ]);
        this.negationWords = new Set(['not', 'never', 'no', 'neither', 'nor', 'without', 'none']);
        this.emojiMap = {
            '😊': 'positive', '😀': 'positive', '😄': 'positive', '❤️': 'positive',
            '👍': 'positive', '😍': 'positive', '😢': 'negative', '😞': 'negative',
            '💔': 'negative', '👎': 'negative', '😡': 'negative'
        };
    }

    tokenize(text) {
        // Remove punctuation
        text = text.replace(/[^\w\s']+/g, ' ');
        // Replace emojis
        for (const [emoji, sentiment] of Object.entries(this.emojiMap)) {
            text = text.replaceAll(emoji, ` ${sentiment} `);
        }
        return text.toLowerCase().split(/\s+/).filter(w => w);
    }

    analyze(text) {
        const tokens = this.tokenize(text);
        if (tokens.length === 0) {
            return { sentiment: 'neutral', score: 0, positiveWords: [], negativeWords: [],
                positiveCount: 0, negativeCount: 0, neutralCount: 0, polarity: 0 };
        }
        const posWords = [], negWords = [];
        let score = 0;
        let i = 0;
        while (i < tokens.length) {
            let word = tokens[i];
            let negate = false;
            if (this.negationWords.has(word) && i + 1 < tokens.length) {
                negate = true;
                i++;
                word = tokens[i];
            }
            if (this.positiveWords.has(word)) {
                const val = negate ? -1 : 1;
                score += val;
                (val > 0 ? posWords : negWords).push(word);
            } else if (this.negativeWords.has(word)) {
                const val = negate ? 1 : -1;
                score += val;
                (val > 0 ? posWords : negWords).push(word);
            }
            i++;
        }
        const totalWords = tokens.length;
        const posCount = posWords.length;
        const negCount = negWords.length;
        const neutralCount = totalWords - posCount - negCount;
        const polarity = (posCount - negCount) / totalWords;
        let sentiment = 'neutral';
        if (score > 0) sentiment = 'positive';
        else if (score < 0) sentiment = 'negative';
        return { sentiment, score, positiveWords: posWords, negativeWords: negWords,
            positiveCount: posCount, negativeCount: negCount, neutralCount, polarity };
    }

    batchAnalyze(texts) {
        return texts.map(t => this.analyze(t));
    }
}

async function main() {
    const analyzer = new SentimentAnalyzer();
    console.log("=== Naive Sentiment Analyzer ===");
    while (true) {
        console.log("\n1. Analyze text");
        console.log("2. Analyze from file");
        console.log("3. Show word lists");
        console.log("4. Exit");
        const choice = await ask("Choose: ");
        switch (choice.trim()) {
            case '1': {
                const text = await ask("Enter text: ");
                const result = analyzer.analyze(text);
                console.log(`\nSentiment: ${result.sentiment.toUpperCase()}`);
                console.log(`Score: ${result.score}`);
                console.log(`Positive words: ${result.positiveWords.join(', ') || 'none'}`);
                console.log(`Negative words: ${result.negativeWords.join(', ') || 'none'}`);
                console.log(`Positive count: ${result.positiveCount}, Negative count: ${result.negativeCount}, Neutral count: ${result.neutralCount}`);
                console.log(`Polarity: ${(result.polarity * 100).toFixed(1)}% positive`);
                break;
            }
            case '2': {
                const fname = await ask("Enter file path: ");
                try {
                    const data = fs.readFileSync(fname, 'utf8');
                    const lines = data.split('\n').map(l => l.trim()).filter(l => l);
                    const results = analyzer.batchAnalyze(lines);
                    console.log("\nBatch results:");
                    results.forEach((r, i) => {
                        console.log(`${i+1}. Sentiment: ${r.sentiment}, Score: ${r.score}`);
                    });
                } catch (e) {
                    console.log("File not found.");
                }
                break;
            }
            case '3': {
                const pos = Array.from(analyzer.positiveWords).slice(0, 20);
                const neg = Array.from(analyzer.negativeWords).slice(0, 20);
                console.log(`Positive words: ${pos.join(', ')}...`);
                console.log(`Negative words: ${neg.join(', ')}...`);
                break;
            }
            case '4':
                console.log("Goodbye!");
                rl.close();
                return;
            default:
                console.log("Invalid choice.");
        }
    }
}

main().catch(console.error);
