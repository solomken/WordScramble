//
//  ContentView.swift
//  WordScramble
//
//  Created by Anastasiia Solomka on 05.05.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "" //spelling from
    @State private var newWord = "" //binded to textfield
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        withAnimation {
            let rootWordSet = Set(rootWord)
            let newWordSet = Set(newWord)
            let isContain = newWordSet.isSubset(of: rootWordSet)
            
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: answer.utf16.count) // make an array of string starting with 0 and being as long as utf16-length of word
            let misspelledRange = checker.rangeOfMisspelledWord(in: answer, range: range, startingAt: 0, wrap: false, language: "en")
            let allGood = misspelledRange.location == NSNotFound
            
            if usedWords.contains(answer) || !isContain || !allGood {
                return //ignoring duplicates and words which do not contains root word letters
            } else {
                usedWords.insert(answer, at: 0) //for UX reasons: it's better for user to see that his word is saved in the list
            }
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: startWordsURL) { //if we found URL do
                let allWords = fileContents.description.components(separatedBy: "\n") //creates array of string without any separates characters
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Opps! Could not load start.txt from bundle.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
