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
                    
                    debugLabel.text = key

                    /// Add kar instead of borno when the shorborno is in middle of a word
                    if shouldConsiderNextShorbornoAsKar, let kar = shorbornoToKars[borno] {
                        tranliteratedWord += kar
                        mutableWord.removeFirst(key.count)
                        nBngLettersAdded += kar.count
                    } else {
                        tranliteratedWord += borno
                        mutableWord.removeFirst(key.count)
                        nBngLettersAdded += borno.count
                        
                        /// Extra backspace for hoshonto's
                        if borno.count > 1 {
                            nBngLettersAdded += (borno.count - 1)
                        }
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
        "" : "ক্য",
        "kr" : "ক্র",
        "kl" : "ক্ল",
        "kSh" : "ক্ষ",
        "kShN" : "ক্ষ্ণ",
        "kShb" : "ক্ষ্ব",
        "kShm" : "ক্ষ্ম",
        "" : "ক্ষ্ম্য",
        "" : "ক্ষ্য",
        "ks" : "ক্স",
        "" : "খ্য",
        "khr" : "খ্র",
        "gN" : "গ্‌ণ",
        "gdh" : "গ্ধ",
        "" : "গ্ধ্য",
        "gdhr" : "গ্ধ্র",
        "gn" : "গ্ন",
        "" : "গ্ন্য",
        "gb" : "গ্ব",
        "gm" : "গ্ম",
        "" : "গ্য",
        "gr" : "গ্র",
        "" : "গ্র্য",
        "gl" : "গ্ল",
        "" : "ঘ্ন",
        "" : "ঘ্য",
        "" : "ঘ্র",
        "" : "ঙ্ক",
        "" : "ঙ্‌ক্ত",
        "" : "ঙ্ক্য",
        "" : "ঙ্ক্ষ",
        "" : "ঙ্খ",
        "" : "ঙ্গ",
        "" : "ঙ্গ্য",
        "" : "ঙ্ঘ",
        "" : "ঙ্ঘ্য",
        "" : "ঙ্ঘ্র",
        "" : "ঙ্ম",
        "" : "চ্চ",
        "" : "চ্ছ",
        "" : "চ্ছ্ব",
        "" : "চ্ছ্র",
        "" : "চ্ঞ",
        "" : "চ্ব",
        "" : "চ্য",
        "" : "জ্জ",
        "" : "জ্জ্ব",
        "" : "জ্ঝ",
        "" : "জ্ঞ",
        "" : "জ্ব",
        "" : "জ্য",
        "" : "জ্র",
        "" : "ঞ্চ",
        "" : "ঞ্ছ",
        "" : "ঞ্জ",
        "" : "ঞ্ঝ",
        "" : "ট্ট",
        "" : "ট্ব",
        "" : "ট্ম",
        "" : "ট্য",
        "" : "ট্র",
        "" : "ড্ড",
        "" : "ড্ব",
        "" : "ড্য",
        "" : "ড্র",
        "" : "ড়্গ",
        "" : "ঢ্য",
        "" : "ঢ্র",
        "" : "ণ্ট",
        "" : "ণ্ঠ",
        "" : "ণ্ঠ্য",
        "" : "ণ্ড",
        "" : "ণ্ড্য",
        "" : "ণ্ড্র",
        "" : "ণ্ঢ",
        "" : "ণ্ণ",
        "" : "ণ্ব",
        "" : "ণ্ম",
        "" : "ণ্য",
        "" : "ৎক",
        "" : "ত্ত",
        "" : "ত্ত্ব",
        "" : "ত্ত্য",
        "" : "ত্থ",
        "" : "ত্ন",
        "" : "ত্ব",
        "" : "ত্ম",
        "" : "ত্ম্য",
        "" : "ত্য",
        "" : "ত্র",
        "" : "ত্র্য",
        "" : "ৎল",
        "" : "ৎস",
        "" : "থ্ব",
        "" : "থ্য",
        "" : "থ্র",
        "" : "দ্গ",
        "" : "দ্ঘ",
        "" : "দ্দ",
        "" : "দ্দ্ব",
        "" : "দ্ধ",
        "" : "দ্ব",
        "" : "দ্ভ",
        "" : "দ্ভ্র",
        "" : "দ্ম",
        "" : "দ্য",
        "" : "দ্র",
        "" : "দ্র্য",
        "" : "ধ্ন",
        "" : "ধ্ব",
        "" : "ধ্ম",
        "" : "ধ্য",
        "" : "ধ্র",
        "" : "ন্ট",
        "" : "ন্ট্র",
        "" : "ন্ঠ",
        "" : "ন্ড",
        "" : "ন্ড্র",
        "" : "ন্ত",
        "" : "ন্ত্ব",
        "" : "ন্ত্য",
        "" : "ন্ত্র",
        "" : "ন্ত্র্য",
        "" : "ন্থ",
        "" : "ন্থ্র",
        "" : "ন্দ",
        "" : "ন্দ্য",
        "" : "ন্দ্ব",
        "" : "ন্দ্র",
        "" : "ন্ধ",
        "" : "ন্ধ্য",
        "" : "ন্ধ্র",
        "" : "ন্ন",
        "" : "ন্ব",
        "" : "ন্ম",
        "" : "ন্য",
        "" : "প্ট",
        "" : "প্ত",
        "" : "প্ন",
        "" : "প্প",
        "" : "প্য",
        "" : "প্র",
        "" : "প্র্য",
        "" : "প্ল",
        "" : "প্স",
        "" : "ফ্র",
        "" : "ফ্ল",
        "" : "ব্জ",
        "" : "ব্দ",
        "" : "ব্ধ",
        "" : "ব্ব",
        "" : "ব্য",
        "" : "ব্র",
        "" : "ব্ল",
        "" : "ভ্ব",
        "" : "ভ্য",
        "" : "ভ্র",
        "" : "ম্ন",
        "" : "ম্প",
        "" : "ম্প্র",
        "" : "ম্ফ",
        "" : "ম্ব",
        "" : "ম্ব্র",
        "" : "ম্ভ",
        "" : "ম্ভ্র",
        "" : "ম্ম",
        "" : "ম্য",
        "" : "ম্র",
        "" : "ম্ল",
        "" : "য্য",
        "" : "র্ক",
        "" : "র্ক্য",
        "" : "র্গ্য",
        "" : "র্ঘ্য",
        "" : "র্চ্য",
        "" : "র্জ্য",
        "" : "র্ণ্য",
        "" : "র্ত্য",
        "" : "র্থ্য",
        "" : "র্ব্য",
        "" : "র্ম্য",
        "" : "র্শ্য",
        "" : "র্ষ্য",
        "" : "র্হ্য",
        "" : "র্খ",
        "" : "র্গ",
        "" : "র্গ্র",
        "" : "র্ঘ",
        "" : "র্চ",
        "" : "র্ছ",
        "" : "র্জ",
        "" : "র্ঝ",
        "" : "র্ট",
        "" : "র্ড",
        "" : "র্ণ",
        "" : "র্ত",
        "" : "র্ত্র",
        "" : "র্থ",
        "" : "র্দ",
        "" : "র্দ্ব",
        "" : "র্দ্র",
        "" : "র্ধ",
        "" : "র্ধ্ব",
        "" : "র্ন",
        "" : "র্প",
        "" : "র্ফ",
        "" : "র্ভ",
        "" : "র্ম",
        "" : "র্য",
        "" : "র্ল",
        "" : "র্শ",
        "" : "র্শ্ব",
        "" : "র্ষ",
        "" : "র্স",
        "" : "র্হ",
        "" : "র্ঢ্য",
        "" : "ল্ক",
        "" : "ল্ক্য",
        "" : "ল্গ",
        "" : "ল্ট",
        "" : "ল্ড",
        "" : "ল্প",
        "" : "ল্‌ফ",
        "" : "ল্ব",
        "" : "ল্‌ভ",
        "" : "ল্ম",
        "" : "ল্য",
        "" : "ল্ল",
        "" : "শ্চ",
        "" : "শ্ছ",
        "" : "শ্ন",
        "" : "শ্ব",
        "" : "শ্ম",
        "" : "শ্য",
        "" : "শ্র",
        "" : "শ্ল",
        "" : "ষ্ক",
        "" : "ষ্ক্র",
        "" : "ষ্ট",
        "" : "ষ্ট্য",
        "" : "ষ্ট্র",
        "" : "ষ্ঠ",
        "" : "ষ্ঠ্য",
        "" : "ষ্ণ",
        "" : "ষ্প",
        "" : "ষ্প্র",
        "" : "ষ্ফ",
        "" : "ষ্ব",
        "" : "ষ্ম",
        "" : "ষ্য",
        "" : "স্ক",
        "" : "স্ক্র",
        "" : "স্খ",
        "" : "স্ট",
        "" : "স্ট্র",
        "" : "স্ত",
        "" : "স্ত্ব",
        "" : "স্ত্য",
        "" : "স্ত্র",
        "" : "স্থ",
        "" : "স্থ্য",
        "" : "স্ন",
        "" : "স্প",
        "" : "স্প্র",
        "" : "স্প্‌ল",
        "" : "স্ফ",
        "" : "স্ব",
        "" : "স্ম",
        "" : "স্য",
        "" : "স্র",
        "" : "স্ল",
        "" : "হ্ণ",
        "" : "হ্ন",
        "" : "হ্ব",
        "" : "হ্ম",
        "" : "হ্য",
        "" : "হ্র",
        "" : "হ্ল",

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
