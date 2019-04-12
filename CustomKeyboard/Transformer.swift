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
        "Z" : "",
    ]

    var typedLetters = ""
    var lastLetter = ""

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func transform(_ s: String) -> String {
        if s == " " {
            typedLetters = ""
        } else {
            typedLetters += s
        }

        guard var transliteratedLetter = transliterationDict[s] else {
            lastLetter = s
            return s
        }

        if s == "h" {

            switch lastLetter {
            case "b":
                transliteratedLetter = "-ভ"
            case "d":
                transliteratedLetter = "-ধ"
            case "k":
                transliteratedLetter = "-খ"
            case "g":
                transliteratedLetter = "-ঘ"
            case "j":
                transliteratedLetter = "-ঝ"
            case "p":
                transliteratedLetter = "-ফ"
            case "s":
                transliteratedLetter = "-"
            case "t":
                transliteratedLetter = "-থ"
            case "D":
                transliteratedLetter = "-ঢ"
            case "T":
                transliteratedLetter = "-ঠ"
            default:
                print("Do nothing")
            }
        }
        lastLetter = s
        return transliteratedLetter
    }
}
