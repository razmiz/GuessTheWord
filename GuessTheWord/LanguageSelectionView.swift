//
//  LanguageSelectionView.swift
//  GuessTheWord
//
//  Created by Raz Mizrahi on 08/02/2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String

    var body: some View {
        VStack {
            Text("בחר שפה")
                .font(.title)
                .bold()
                .padding()

            Button("עברית") {
                selectedLanguage = "עברית"
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("English") {
                selectedLanguage = "English"
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView(selectedLanguage: .constant(""))
    }
}
