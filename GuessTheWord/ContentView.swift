//
//  ContentView.swift
//  GuessTheWord
//
//  Created by Raz Mizrahi on 28/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = GameModel()
    
    let columns = Array(repeating: GridItem(.fixed(50), spacing: 5), count: 5)
    let row1 = "QWERTYUIOP".map { String($0) }
    let row2 = "ASDFGHJKL".map { String($0) }
    let row3 = "ZXCVBNM".map { String($0) }
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor") // רקע המשחק מתעדכן אוטומטית לפי המצב
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("נחש את המילה!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary) // ישתנה אוטומטית בין שחור ללבן
                
                // 🔹 כאן נמצאת תצוגת לוח המשחק
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<30, id: \.self) { index in
                        let row = index / 5
                        let col = index % 5
                        let (letter, backgroundColor) = getLetterAndColor(row: row, col: col) // שימוש בפונקציה
                        
                        Text(letter)
                            .frame(width: 50, height: 50)
                            .background(backgroundColor)
                            .cornerRadius(5)
                            .font(.title)
                            .bold()
                    }
                }
                .padding()
                
                // 🔹 כאן נמצאת המקלדת הווירטואלית
                VStack(spacing: 5) {
                    // 🔹 שורה ראשונה (QWERTYUIOP)
                    HStack(spacing: 5) {
                        ForEach(row1, id: \.self) { letter in
                            Button(letter) {
                                if gameModel.currentGuess.count < 5 {
                                    gameModel.currentGuess.append(letter)
                                }
                            }
                            .frame(width: 35, height: 45)
                            .background(gameModel.letterColors[letter, default: Color("KeyboardColor")]) // 🔹 שינוי צבעים דינמי
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                    }
                    
                    // 🔹 שורה שנייה (ASDFGHJKL)
                    HStack(spacing: 5) {
                        ForEach(row2, id: \.self) { letter in
                            Button(letter) {
                                if gameModel.currentGuess.count < 5 {
                                    gameModel.currentGuess.append(letter)
                                }
                            }
                            .frame(width: 35, height: 45)
                            .background(gameModel.letterColors[letter, default: Color("KeyboardColor")]) // 🔹 שינוי צבעים דינמי
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                    }
                    
                    // 🔹 שורה שלישית (ZXCVBNM + ⌫)
                    HStack(spacing: 5) {
                        ForEach(row3, id: \.self) { letter in
                            Button(letter) {
                                if gameModel.currentGuess.count < 5 {
                                    gameModel.currentGuess.append(letter)
                                }
                            }
                            .frame(width: 35, height: 45)
                            .background(gameModel.letterColors[letter, default: Color("KeyboardColor")]) // 🔹 שינוי צבעים דינמי
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                        
                        // 🔹 כפתור מחיקה (⌫) בסוף השורה
                        Button("⌫") {
                            gameModel.deleteLastLetter()
                        }
                        .frame(width: 60, height: 45)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    }
                    
                    // 🔹 כפתור Enter בשורה נפרדת
                    Button("Enter") {
                        if gameModel.currentGuess.count == 5 {
                            gameModel.addGuess(gameModel.currentGuess)
                            gameModel.currentGuess = "" // איפוס הניחוש הנוכחי
                        }
                    }
                    .frame(width: 90, height: 45)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
                
                .padding()
                
                
                
            }
        }
        
        .alert(isPresented: $gameModel.gameOver) {
            switch gameModel.gameStatus {
            case .invalidWord:
                return Alert(
                    title: Text("שגיאה"),
                    message: Text(gameModel.gameResultMessage),
                    dismissButton: .default(Text("אוקיי")) {
                        gameModel.gameOver = false
                    }
                )
            case .won:
                return Alert(
                    title: Text("🎉 ניצחון!"),
                    message: Text(gameModel.gameResultMessage),
                    dismissButton: .default(Text("התחל משחק חדש")) {
                        gameModel.startNewGame()
                    }
                )
            case .lost:
                return Alert(
                    title: Text("😞 הפסדת"),
                    message: Text(gameModel.gameResultMessage),
                    dismissButton: .default(Text("נסה שוב")) {
                        gameModel.startNewGame()
                    }
                )
            default:
                return Alert(title: Text("שגיאה"), message: Text("מצב לא ידוע"), dismissButton: .default(Text("אוקיי")))
            }
        }
    }
    
    
    func getLetterAndColor(row: Int, col: Int) -> (String, Color) {
        if row < gameModel.guesses.count {
            let guess = gameModel.guesses[row]
            let colors = gameModel.guessColors[row]
            
            if col < guess.count {
                let letter = String(guess[guess.index(guess.startIndex, offsetBy: col)])
                let color = colors[col]
                return (letter, color)
            }
        } else if row == gameModel.guesses.count {
            if col < gameModel.currentGuess.count {
                let letter = String(gameModel.currentGuess[gameModel.currentGuess.index(gameModel.currentGuess.startIndex, offsetBy: col)])
                return (letter, Color.gray.opacity(0.3)) // הניחוש הנוכחי ברירת מחדל אפור
            }
        }
        
        return ("", Color.gray.opacity(0.3)) // תא ריק
    }
    
    
}



#Preview {
    ContentView()
}
