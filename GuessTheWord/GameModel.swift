//
//  GameModel.swift
//  GuessTheWord
//
//  Created by Raz Mizrahi on 08/02/2025.
//

import Foundation
import SwiftUICore


class GameModel: ObservableObject {
    
    enum GameStatus {
        case playing
        case won
        case lost
        case invalidWord
    }

    @Published var gameStatus: GameStatus = .playing
//    let wordList = ["apple", "board", "chair", "table", "mouse"] // רשימת מילים
    @Published var targetWord: String = "" // המילה שהמשתמש צריך לנחש
    @Published var guesses: [String] = [] // רשימת הניחושים
    @Published var currentGuess: String = "" // ישמור את האותיות שהמשתמש מקליד עד שהוא לוחץ “Enter”
    @Published var guessColors: [[Color]] = []
    @Published var gameOver: Bool = false
    @Published var gameResultMessage: String = ""
    @Published var validWords: Set<String> = []
    @Published var letterColors: [String: Color] = [:]
    
    init() {
        loadWords() // טוען את המילים מהקובץ
        startNewGame()
    }
    
    func startNewGame() {
        if let randomWord = validWords.randomElement() {
            targetWord = randomWord.uppercased() // בחירת מילה אקראית חדשה
        } else {
            targetWord = "APPLE" // ברירת מחדל למקרה שאין מילה זמינה
        }

        guesses = [] // איפוס רשימת הניחושים
        guessColors = [] // איפוס הצבעים לכל משחק חדש
        letterColors = [:] // 🔹 איפוס צבעי המקלדת!
        gameOver = false
        gameResultMessage = ""

        print("🔹 משחק חדש! המילה שנבחרה: \(targetWord)")
    }
    
    func addGuess(_ guess: String) {
        let upperGuess = guess.uppercased()

        // בדיקה האם המילה קיימת ברשימת המילים החוקיות
        if !validWords.contains(upperGuess) {
            gameResultMessage = "❌ המילה \"\(upperGuess)\" לא קיימת!"
            gameStatus = .invalidWord
            gameOver = true
            return
        }

        if guess.count == 5 {
            guesses.append(upperGuess)
            let colors = checkGuessColors(guess: upperGuess)
            guessColors.append(colors)

            // בדיקה אם השחקן ניחש נכון
            if upperGuess == targetWord.uppercased() {
                gameStatus = .won
                gameOver = true
                gameResultMessage = "🎉 כל הכבוד! ניחשת נכון!"
            } else if guesses.count == 6 { // אם נגמרו הניחושים
                gameStatus = .lost
                gameOver = true
                gameResultMessage = "😞 הפסדת! המילה הייתה \(targetWord)"
            }
        }
    }
    
    func deleteLastLetter() {
        if !currentGuess.isEmpty {
            currentGuess.removeLast()
        }
    }
    
    func checkGuessColors(guess: String) -> [Color] {
        var colors: [Color] = Array(repeating: .gray, count: 5)
        var targetChars = Array(targetWord.uppercased()) // המילה הנכונה
        var guessChars = Array(guess.uppercased())

        // 🔹 שלב 1: ספירת תדירות של אותיות במילה הנכונה
        var letterCount: [Character: Int] = [:]
        for char in targetChars {
            letterCount[char, default: 0] += 1
        }

        // 🔹 שלב 2: סימון אותיות במקום הנכון (ירוק) תחילה
        for i in 0..<5 {
            if guessChars[i] == targetChars[i] {
                colors[i] = .green
                letterCount[guessChars[i], default: 0] -= 1 // הפחתה מהספירה של האות
            }
        }

        // 🔹 שלב 3: סימון אותיות במקום הלא נכון (צהוב)
        for i in 0..<5 {
            if colors[i] != .green, let count = letterCount[guessChars[i]], count > 0 {
                colors[i] = .yellow
                letterCount[guessChars[i], default: 0] -= 1 // הפחתת הכמות
            }
        }

        // 🔹 שלב 4: עדכון צבעי המקלדת
        for i in 0..<5 {
            let letter = String(guessChars[i])
            if colors[i] == .green {
                letterColors[letter] = .green
            } else if colors[i] == .yellow {
                if letterColors[letter] != .green { // רק אם האות עוד לא ירוקה
                    letterColors[letter] = .yellow
                }
            } else {
                if letterColors[letter] == nil { // רק אם היא עדיין כחולה
                    letterColors[letter] = .gray.opacity(0.6)
                }
            }
        }

        return colors
    }
    
    func loadWords() {
        if let url = Bundle.main.url(forResource: "filtered_words", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let wordsArray = try JSONDecoder().decode([String].self, from: data)
                validWords = Set(wordsArray) // שמירת המילים כ-Set לשיפור ביצועים
                print("✅ נטענו \(validWords.count) מילים חוקיות")

                // בחירת מילה אקראית רק אחרי שהמילים נטענו
                startNewGame()
            } catch {
                print("❌ שגיאה בטעינת קובץ המילים: \(error)")
            }
        } else {
            print("❌ קובץ filtered_words.json לא נמצא")
        }
    }
    
}
