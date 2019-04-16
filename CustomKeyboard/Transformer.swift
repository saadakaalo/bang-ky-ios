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
        "a" : "আ",
        "b" : "ব",
        "c" : "চ",
        "d" : "দ",
        "e" : "এ",
        "f" : "ফ",
        "g" : "গ",
        "h" : "হ",
        "i" : "ই",
        "j" : "জ",
        "k" : "ক",
        "l" : "ল",
        "m" : "ম",
        "n" : "ন",
        "o" : "অ",
        "p" : "প",
        "q" : "্",
        "r" : "র",
        "s" : "স",
        "t" : "ত",
        "u" : "উ",
        "v" : "ভ",
        "w" : "ঊ",
        "x" : "্স",
        "y" : "্য",
        "z" : "য",
        "A" : "আ",
        "B" : "ভ",
        "C" : "ছ",
        "D" : "ড",
        "E" : "ঐ",
        "F" : "ফ",
        "G" : "ঘ",
        "H" : "ঃ",
        "I" : "ঈ",
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
        "U" : "ঊ",
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
        "oo" : "উ",
        "rri" : "ৃ",
    ]

    let shorbornoToKars = [
        "অ" : "",
        "আ" : "া",
        "ই" : "ি",
        "ঈ" : "ী",
        "এ" : "ে",
        "ও" : "ো",
        "উ" : "ু",
        "ঊ" : "ূ",
    ]

    var typedLetters = ""
    var lastNumberOfBngAlphabets = 0
    var shouldConsiderNextShorbornoAsKar = false

    var textDocumentProxy: UITextDocumentProxy!

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func transform(_ s: String) -> String {
        if s == " " {
            typedLetters = ""
            lastNumberOfBngAlphabets = 0
            shouldConsiderNextShorbornoAsKar = false
            return s
        } else if s == "-" {
            if typedLetters.count < 1 {
                return "-"
            }
            typedLetters.removeLast()
            let (tsWord, nLetters) = tranliterateWord(typedLetters)
            let wordToReturn = "-" + tsWord
            lastNumberOfBngAlphabets = nLetters
            return wordToReturn
        } else {
            typedLetters += s
            let (tsWord, nLetters) = tranliterateWord(typedLetters)
            deleteLastWord()
            let wordToReturn = tsWord
            lastNumberOfBngAlphabets = nLetters
            return wordToReturn
        }
    }

    func deleteLastWord() {
        while true {
            guard let previousText = textDocumentProxy.documentContextBeforeInput else {
                break
            }
            if previousText.count == 0 || previousText.hasSuffix(" ") {
                break
            }

            textDocumentProxy.deleteBackward()
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
                /// The value should always be there, so forced unwrapped
                let borno = transliterationDict[key]!

                if mutableWord.starts(with: key) {
                    isAnyKeyMatched = true

                    /// Add kar instead of borno when the shorborno is in middle of a word
                    if shouldConsiderNextShorbornoAsKar, let kar = shorbornoToKars[borno] {
                        tranliteratedWord += kar
                        mutableWord.removeFirst(key.count)
                        nLettersAdded += kar.count
                    } else {
                        tranliteratedWord += borno
                        mutableWord.removeFirst(key.count)
                        nLettersAdded += borno.count
                    }

                    let isShorborno = shorbornoToKars[borno] != nil
                    if isShorborno {
                        shouldConsiderNextShorbornoAsKar = false
                    } else {
                        shouldConsiderNextShorbornoAsKar = true
                    }

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


