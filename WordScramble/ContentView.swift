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
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
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
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            validationError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            validationError(title: "Word not possible", message: "You can't spell this word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            validationError(title: "Word not recognized", message: "Dude c'mon")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0) //for UX reasons: it's better for user to see that his word is saved in the list
        }
        
        newWord = ""
    }
    
    func isPossible(word: String) -> Bool {
        let rootWordSet = Set(rootWord)
        let newWordSet = Set(word)
        return newWordSet.isSubset(of: rootWordSet)
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) // make an array of string starting with 0 and being as long as utf16-length of word
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
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
    
    func validationError (title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
