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
        "Ou" : "ঔ",
        "Oi" : "ঐ",
        "OU" : "ঔ",
        "OI" : "ঐ",
        "rri" : "ৃ",
    ]

    let shorbornoToKars = [
        "অ" : "",
        "আ" : "া",
        "ই" : "ি",
        "ঈ" : "ী",
        "এ" : "ে",
        "ঐ" : "ৈ",
        "ও" : "ো",
        "ঔ" : "ৌ",
        "উ" : "ু",
        "ঊ" : "ূ",
    ]

    var transletingBufferWordEng = ""
    var nBngLettersInLastWord = 0

    // TODO: This two property should not be implicit optional
    weak var textDocumentProxy: UITextDocumentProxy!
    weak var debugLabel: UILabel!

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func insertText(_ text: String) {
        if text == " " {
            transletingBufferWordEng = ""
            nBngLettersInLastWord = 0
            textDocumentProxy.insertText(text)
        } else if text == "-" {
            /// When no text to delete backword
            if let textLength = textDocumentProxy.documentContextBeforeInput?.count, textLength <= 0 {
                nBngLettersInLastWord = 0
            }
            /// When transletting Eng word is not empty
            else if transletingBufferWordEng.count > 0 {
                transletingBufferWordEng.removeLast()
                let (tsWord, nBngLetters) = tranliterateWord(transletingBufferWordEng)
                clearBufferWord()
                textDocumentProxy.insertText(tsWord)
                nBngLettersInLastWord = nBngLetters
            }
            /// When transletting Eng word is empty
            else {
                textDocumentProxy.deleteBackward()
                nBngLettersInLastWord = 0
            }
        } else {
            transletingBufferWordEng += text
            let (tsWord, nBngLetters) = tranliterateWord(transletingBufferWordEng)

            clearBufferWord()
            textDocumentProxy.insertText(tsWord)
            nBngLettersInLastWord = nBngLetters
        }
        debugLabel.text = String(nBngLettersInLastWord)
    }


    //TODO: Delete this method, no more necessary
    /// Delete the letters backword as long as there is no blank space
    func clearBufferWordArchieved() {
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

    func clearBufferWord() {
        for _ in 0..<nBngLettersInLastWord {
            textDocumentProxy.deleteBackward()
        }
    }

    func tranliterateWord(_ word: String) -> (String, Int)  {
        var shouldConsiderNextShorbornoAsKar = false
        var mutableWord = word
        var tranliteratedWord = ""
        
        let sortedKeys = transliterationDict.keys.sorted { (fistString, secondString) -> Bool in
            if fistString.count != secondString.count {
                return fistString.count > secondString.count
            }
            return fistString > secondString
        }
        
        var nBngLettersAdded = 0
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
                        nBngLettersAdded += kar.count
                    } else {
                        tranliteratedWord += borno
                        mutableWord.removeFirst(key.count)
                        nBngLettersAdded += borno.count
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
                nBngLettersAdded += 1
                shouldConsiderNextShorbornoAsKar = false
            }
        }
        return (tranliteratedWord, nBngLettersAdded)
    }

}


