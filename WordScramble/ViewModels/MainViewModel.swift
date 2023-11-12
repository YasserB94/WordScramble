//
//  MainViewModel.swift
//  WordScramble
//
//  Created by Yasser Bal on 12/11/2023.
//

import Foundation
import UIKit

final class MainViewModel:ObservableObject{
    
    @Published var newWordInput:String = ""
    @Published var words:[String] = []
    
    @Published var rootWord:String?
    
    private var loadedWords:[String]? = nil
    
    var score:Int{
        if words.isEmpty {
            return 0
        }
        var tmp = 0

        for (index, word) in words.enumerated() {
            tmp += word.count

            // Bonus scoring for every complete set of 5 words
            if (index + 1) % 5 == 0 {
                let bonusMultiplier = (index + 1) / 5
                let bonusPoints = 5 * bonusMultiplier
                tmp += bonusPoints
            }
        }
        if tmp > highScore {
            highScore = tmp
        }
        return tmp
    }
    
    var highScore:Int = 0
    
    init(){

    }
    
    public func newGame(){
        if score > highScore{
            highScore = score
        }
        
        rootWord = getRandomWord()
    }
    
    /// Attempt to add the current `newWordInput` to the list of words.
    public func addWord(){
        self.addWord(word:self.newWordInput)
    }
    
    /// Add a sanitized word to the list of words after performing various checks.
    /// - Parameter word: The word to add.
    public func addWord(word:String){
        let sanitised = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard sanitised.count > 0,
              !sanitised.isEmpty,
              self.containsOnlyLetters(input:sanitised),
              self.isOriginal(input: sanitised),
              self.isValid(input: sanitised),
              self.isReal(word: sanitised)
        else{
            newWordInput = ""
            return
        }
        
        self.words.insert(word, at: 0)
    }
    
    /// Check if a given word is a valid English word using UITextChecker.
    /// - Parameter word: The word to check.
    /// - Returns: `true` if the word is valid, otherwise `false`.
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    /// Check if a given input is a valid word formed from the root word's letters.
    /// - Parameter input: The input word to check.
    /// - Returns: `true` if the word is valid, otherwise `false`.
    private func isValid(input:String)->Bool{
        var tmp = rootWord
        
        for letter in input{
            if let pos = tmp?.firstIndex(of: letter){
                tmp?.remove(at: pos)
            }else{
                return false
            }
        }
        
        return true
    }
    
    /// Check if a given word is not already present in the list of words.
    /// - Parameter input: The input word to check.
    /// - Returns: `true` if the word is not present, otherwise `false`.
    private func isOriginal(input:String)->Bool{
        return !self.words.contains(input)
    }
    
    /// Check if a given input contains only letters.
    /// - Parameter input: The input string to check.
    /// - Returns: `true` if the input contains only letters, otherwise `false`.
    private func containsOnlyLetters(input:String)->Bool{
        return input.lowercased().range(of: #"^[a-z]+$"#, options: .regularExpression) != nil
    }
    
    /// Get a random word from the loaded wordlist.
    /// - Returns: A random word from the wordlist.
    private func getRandomWord()->String{
        if self.loadedWords == nil {
            self.loadedWords = self.loadWordlist()
        }
        guard let words = self.loadedWords,
              let word = words.randomElement()
        else
        {
            fatalError("Wordlist Data corrups")
        }
        return word;
    }
    
    
    /**
     Loads a wordlist from a text file named "wordlist.txt" bundled with the main application bundle.
     
     - Returns: An array of unique strings representing the words in the wordlist, sorted in ascending order.
     
     - Note: The wordlist file should be a plain text file containing one word per line.
     */
    private func loadWordlist() -> [String] {
        // Attempt to get the URL of the wordlist.txt file in the main application bundle
        if let fileURL = Bundle.main.url(forResource: "wordlist", withExtension: "txt"),
           
            // Attempt to read the contents of the file into a string
           let fileContents = try? String(contentsOf: fileURL) {
            
            // Split the file contents into an array of strings, removing empty lines
            let wordArray = fileContents.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            // Create a set to ensure uniqueness and convert it back to a sorted array
            let uniqueSortedWords = Array(Set(wordArray))
            
            self.loadedWords = uniqueSortedWords
            
            // Return the resulting array
            return uniqueSortedWords
        }
        
        // The file couldn't be loaded
        fatalError("Failed to load Wordlist")
    }
    
    
}
