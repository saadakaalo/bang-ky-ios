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

    private var transletingBufferWordEng = ""
    private var nBngLettersInLastWord = 0

    // TODO: This two property should not be implicit optional
    weak var textDocumentProxy: UITextDocumentProxy!
    weak var debugLabel: UILabel!
    
    //Settings
    let autometicJuktoborno = true

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func insertText(_ text: String) {
        if text == " " {
            resetBuffer()
            textDocumentProxy.insertText(text)
        } else if text == "-" {
            /// When no text to delete backword
            if textDocumentProxy.documentContextBeforeInput == nil {
                resetBuffer()
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
    }

    func resetBuffer() {
        transletingBufferWordEng = ""
        nBngLettersInLastWord = 0
    }

    private func clearBufferWord() {
        for _ in 0..<nBngLettersInLastWord {
            textDocumentProxy.deleteBackward()
        }
    }

    private func tranliterateWord(_ word: String) -> (String, Int)  {

        let letterToBornoLocal = autometicJuktoborno ? letterToAnyborno : letterToBorno

        var shouldConsiderNextShorbornoAsKar = false
        var mutableWord = word
        var tranliteratedWord = ""
        
        let sortedKeys = letterToBornoLocal.keys.sorted { (fistString, secondString) -> Bool in
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
                let borno = letterToBornoLocal[key]!

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


    private let letterToBorno = [
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
        "rri" : "ঋ",
    ]

    private let letterToJuktoborno = [
        "kk" : "ক্ক",
        "kT" : "ক্ট",
        "kTr" : "ক্ট্র",
        "kt" : "ক্ত",
        "ktr" : "ক্ত্র",
        "kb" : "ক্ব",
        "km" : "ক্ম",
        "kr" : "ক্র",
        "kl" : "ক্ল",
        "kSh" : "ক্ষ",
        "kShN" : "ক্ষ্ণ",
        "kShb" : "ক্ষ্ব",
        "kShm" : "ক্ষ্ম",
        "ks" : "ক্স",
        "khr" : "খ্র",
        "gN" : "গ্‌ণ",
        "gdh" : "গ্ধ",
        "gdhr" : "গ্ধ্র",
        "gn" : "গ্ন",
        "gb" : "গ্ব",
        "gm" : "গ্ম",
        "gr" : "গ্র",
        "gl" : "গ্ল",
    ]

    private var letterToAnyborno: [String : String] {
        return letterToBorno.merging(letterToJuktoborno, uniquingKeysWith: { (first, _) in first })
    }

    private let shorbornoToKars = [
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
        "ঋ" : "ৃ",
    ]

}


/// যুক্তবর্নের লিস্ট + যেগুলা ডিকশোনারিতে এড করা হইসে
/*
 /ক্ক = ক + ক; যেমন- আক্কেল, টেক্কা
 /ক্ট = ক + ট; যেমন- ডক্টর (মন্তব্য: এই যুক্তাক্ষরটি মূলত ইংরেজি/বিদেশী কৃতঋণ শব্দে ব্যবহৃত)
 /ক্ট্র = ক + ট + র; যেমন- অক্ট্রয়
 /ক্ত = ক + ত; যেমন- রক্ত
 /ক্ত্র = ক + ত + র; যেমন- বক্ত্র
 /ক্ব = ক + ব; যেমন- পক্ব, ক্বণ
 /ক্ম = ক + ম; যেমন- রুক্মিণী
 ক্য = ক + য; যেমন- বাক্য
 /ক্র = ক + র; যেমন- চক্র
 /ক্ল = ক + ল; যেমন- ক্লান্তি
 /ক্ষ = ক + ষ; যেমন- পক্ষ
 /ক্ষ্ণ = ক + ষ + ণ; যেমন- তীক্ষ্ণ
 /ক্ষ্ব = ক + ষ + ব; যেমন- ইক্ষ্বাকু
 /ক্ষ্ম = ক + ষ + ম; যেমন- লক্ষ্মী
 ক্ষ্ম্য = ক + ষ + ম + য; যেমন- সৌক্ষ্ম্য
 ক্ষ্য = ক + ষ + য; যেমন- লক্ষ্য
 /ক্স = ক + স; যেমন- বাক্স
 খ্য = খ + য; যেমন- সখ্য
 /খ্র = খ+ র যেমন; যেমন- খ্রিস্টান
 /গ্‌ণ = গ + ণ; যেমন - রুগ্‌ণ
 /গ্ধ = গ + ধ; যেমন- মুগ্ধ
 গ্ধ্য = গ + ধ + য; যেমন- বৈদগ্ধ্য
 /গ্ধ্র = গ + ধ + র; যেমন- দোগ্ধ্রী
 /গ্ন = গ + ন; যেমন- ভগ্ন
 গ্ন্য = গ + ন + য; যেমন- অগ্ন্যাস্ত্র, অগ্ন্যুৎপাত, অগ্ন্যাশয়
 /গ্ব = গ + ব; যেমন- দিগ্বিজয়ী
 /গ্ম = গ + ম; যেমন- যুগ্ম
 গ্য = গ + য; যেমন- ভাগ্য
 /গ্র = গ + র; যেমন- গ্রাম
 গ্র্য = গ + র + য; যেমন- ঐকাগ্র্য, সামগ্র্য, গ্র্যাজুয়েট
 /গ্ল = গ + ল; যেমন- গ্লানি
 */
