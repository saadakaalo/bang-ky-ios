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
        "x" : "জ",
        "y" : "্য",
        "z" : "য",
        "A" : "অ",
        "B" : "ভ",
        "C" : "ছ",
        "D" : "ধ",
        "E" : "এ",
        "F" : "ফ",
        "G" : "ঘ",
        "H" : "ঃ",
        "I" : "ই",
        "J" : "ঝ",
        "K" : "খ",
        "L" : "ল",
        "M" : "ং",
        "N" : "ণ",
        "O" : "ও",
        "P" : "ফ",
        "Q" : "্",
        "R" : "র",
        "S" : "শ",
        "T" : "ট",
        "U" : "উ",
        "V" : "ভ",
        "W" : "ঊ",
        "X" : "জ",
        "Y" : "জ",
        "Z" : "য",
    ]

    private init() {
        // Private initialization to ensure just one instance is created.
    }

    func transform(_ s: String) -> String {
        guard let transliteratedLetter = transliterationDict[s] else {
            return "X"
        }
        return transliteratedLetter
    }
}
