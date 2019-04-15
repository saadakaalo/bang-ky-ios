//
//  Transformer.swift
//  CustomKeyboard
//
//  Created by Saurav Ganguly-402 on 11/4/19.
//  Copyright © 2019 bjitgroup. All rights reserved.
//

import Foundation

class Transformer {
    static let shared = Transformer()

    let transliterationDict = [
        "a" : "া",
        "b" : "ব",
        "c" : "চ",
        "d" : "দ",
        "e" : "ে",
        "f" : "ফ",
        "g" : "গ",
        "h" : "হ",
        "i" : "ি",
        "j" : "জ",
        "k" : "ক",
        "l" : "ল",
        "m" : "ম",
        "n" : "ন",
        "o" : "ো",
        "p" : "প",
        "q" : "্",
        "r" : "র",
        "s" : "স",
        "t" : "ত",
        "u" : "ু",
        "v" : "ভ",
        "w" : "ঊ",
        "x" : "্স",
        "y" : "্য",
        "z" : "য",
        "A" : "অ",
        "B" : "ভ",
        "C" : "ছ",
        "D" : "ড",
        "E" : "এ",
        "F" : "ফ",
        "G" : "ঘ",
        "H" : "ঃ",
        "I" : "ই",
        "J" : "ঝ",
        "K" : "খ",
        "L" : "",
        "M" : "ং",
        "N" : "ণ",
        "O" : "ও",
        "P" : "ফ",
        "Q" : "্",
        "R" : "ড়",
        "S" : "শ",
        "T" : "ট",
        "U" : "উ",
        "V" : "",
        "W" : "",
        "X" : "",
        "Y" : "",
        "Z" : "য়",
        "bh" : "ভ",
        "ch" : "ছ",
        "dh" : "ধ",
        "kh" : "খ",
        "gh" : "ঘ",
        "jh" : "ঝ",
        "ph" : "ফ",
        "sh" : "শ",
        "th" : "থ",
        "Dh" : "ঢ",
        "Sh" : "ষ",
        "Th" : "ঠ",
        "rri" : "ৃ",
    ]

    var typedLetters = ""
    var lastNumberOfBngAlphabets = 0

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func transform(_ s: String) -> String {
        if s == " " {
            typedLetters = ""
            lastNumberOfBngAlphabets = 0
            return s
        } else if s == "-" {
            if typedLetters.count < 1 {
                return "-"
            }
            typedLetters.removeLast()
            let (tsWord, nLetters) = tranliterateWord(typedLetters)
            let wordToReturn = String(repeating: "-", count: lastNumberOfBngAlphabets) + tsWord
            lastNumberOfBngAlphabets = nLetters
            return wordToReturn
        } else {
            typedLetters += s
            let (tsWord, nLetters) = tranliterateWord(typedLetters)
            let wordToReturn = String(repeating: "-", count: lastNumberOfBngAlphabets) + tsWord
            lastNumberOfBngAlphabets = nLetters
            return wordToReturn
        }
    }

    func tranliterateWord(_ word: String) -> (String, Int)  {
        var mutableWord = word
        var tranliteratedWord = ""
        
        let sortedKeys = transliterationDict.keys.sorted { (fistString, secondString) -> Bool in
            if fistString.count != secondString.count {
                return fistString.count > secondString.count
            }
            return fistString > secondString
        }
        
        var nLettersAdded = 0
        while mutableWord.count > 0 {
            var isAnyKeyMatched = false
            for key in sortedKeys {
                guard let value = transliterationDict[key] else {
                    fatalError("Something is not right.")
                }
                if mutableWord.starts(with: key) {
                    isAnyKeyMatched = true
                    tranliteratedWord += value
                    mutableWord.removeFirst(key.count)
                    nLettersAdded += value.count
                    break
                }
            }
            if isAnyKeyMatched == false {
                tranliteratedWord += String(mutableWord.prefix(1))
                mutableWord.removeFirst(1)
                nLettersAdded += 1
            }
        }
        return (tranliteratedWord, nLettersAdded)
    }

}


