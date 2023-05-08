//
//  ContentView.swift
//  WordScramble
//
//  Created by Anastasiia Solomka on 05.05.2023.
//
//https://www.hackingwithswift.com/100/swiftui/29
//improvements: https://www.hackingwithswift.com/books/ios-swiftui/word-scramble-wrap-up

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "" //spelling from
    @State private var newWord = "" //binded to textfield
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    @State private var score = 0
    
    enum FocusedField {
        case inputField
    }
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .inputField)
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
            .toolbar {
                Button("Restart", action: startGame)
            }
            .onSubmit(addNewWord)
            .onSubmit {
                focusedField = .inputField
            }
            .onAppear(perform: startGame)
            .onAppear {
                focusedField = .inputField
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .safeAreaInset(edge: .bottom) {
                Text("Your score: \(score)")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .background(.cyan)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            validationError(title: "Word is too short", message: "You cannot use words that are shorter than 3 characters")
            return
        }
        
        guard answer != rootWord else {
            validationError(title: "\(rootWord) is original word", message: "You cannot use original word")
            return
        }
        
        guard isOriginal(word: answer) else {
            validationError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            validationError(title: "Word not possible", message: "You can't spell this word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            validationError(title: "Word not recognized", message: "We don't know this word, sorry bro")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0) //for UX reasons: it's better for user to see that his word is saved in the list
        }
    
        newWord = ""
        
        if answer.count > 3 {
            score += answer.count
        } else {
            score += 1
        }
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
        usedWords.removeAll()
        newWord = ""
        score = 0
        
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
