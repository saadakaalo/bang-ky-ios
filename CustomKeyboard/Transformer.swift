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
        "w" : "@",//extra
        "x" : "@",//extra
        "y" : "য়",
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
        "L" : "@",//extra
        "M" : "ং",
        "N" : "ণ",
        "O" : "ও",
        "P" : "@",//extra
        "Q" : "@",//extra
        "R" : "ড়",
        "S" : "শ",
        "T" : "ট",
        "U" : "ঊ",
        "V" : "@",//extra
        "W" : "@",//extra
        "X" : "@",//extra
        "Y" : "@",//extra
        "Z" : "@",//extra
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

        /// Special Considerations
        "Ng" : "ঙ",
        "ng" : "ং",
        "NG" : "ঞ",
        "TH" : "ৎ",
        "kkh" : "ক্ষ",
        "gg" : "জ্ঞ",
        "qq" : "ঁ",
    ]

    private let letterToJuktoborno = [
        "kk" : "ক্ক",
        "kT" : "ক্ট",
        "kTr" : "ক্ট্র",
        "kt" : "ক্ত",
        "ktr" : "ক্ত্র",
        "kb" : "ক্ব",
        "km" : "ক্ম",
        "ky" : "ক্য",
        "kr" : "ক্র",
        "kl" : "ক্ল",
        "kSh" : "ক্ষ",
        "kShN" : "ক্ষ্ণ",
        "kShb" : "ক্ষ্ব",
        "kShm" : "ক্ষ্ম",
        "kShmy" : "ক্ষ্ম্য",
        "kShy" : "ক্ষ্য",
        "ks" : "ক্স",
        "khy" : "খ্য",
        "khr" : "খ্র",
        "gN" : "গ্‌ণ",
        "gdh" : "গ্ধ",
        "gdhy" : "গ্ধ্য",
        "gdhr" : "গ্ধ্র",
        "gn" : "গ্ন",
        "gny" : "গ্ন্য",
        "gb" : "গ্ব",
        "gm" : "গ্ম",
        "gy" : "গ্য",
        "gr" : "গ্র",
        "gry" : "গ্র্য",
        "gl" : "গ্ল",
        "ghn" : "ঘ্ন",
        "ghy" : "ঘ্য",
        "ghr" : "ঘ্র",
        //        "" : "ঙ্ক",
        //        "" : "ঙ্‌ক্ত",
        //        "" : "ঙ্ক্য",
        //        "" : "ঙ্ক্ষ",
        //        "" : "ঙ্খ",
        //        "" : "ঙ্গ",
        //        "" : "ঙ্গ্য",
        //        "" : "ঙ্ঘ",
        //        "" : "ঙ্ঘ্য",
        //        "" : "ঙ্ঘ্র",
        //        "" : "ঙ্ম",
        "cc" : "চ্চ",
        "cch" : "চ্ছ",
        "cchb" : "চ্ছ্ব",
        "cchr" : "চ্ছ্র",
        //        "" : "চ্ঞ",
        "cb" : "চ্ব",
        "cy" : "চ্য",
        "jj" : "জ্জ",
        "jjb" : "জ্জ্ব",
        "jjh" : "জ্ঝ",
        //        "" : "জ্ঞ",
        "jb" : "জ্ব",
        "jy" : "জ্য",
        "jr" : "জ্র",
        //        "" : "ঞ্চ",
        //        "" : "ঞ্ছ",
        //        "" : "ঞ্জ",
        //        "" : "ঞ্ঝ",
        "TT" : "ট্ট",
        "Tb" : "ট্ব",
        "Tm" : "ট্ম",
        "Ty" : "ট্য",
        "Tr" : "ট্র",
        "DD" : "ড্ড",
        "Db" : "ড্ব",
        "Dy" : "ড্য",
        "Dr" : "ড্র",
        "Rg" : "ড়্গ",
        "Dhy" : "ঢ্য",
        "Dhr" : "ঢ্র",
        "NT" : "ণ্ট",
        "NTh" : "ণ্ঠ",
        "NThy" : "ণ্ঠ্য",
        "ND" : "ণ্ড",
        "NDy" : "ণ্ড্য",
        "NDr" : "ণ্ড্র",
        "NDh" : "ণ্ঢ",
        "NN" : "ণ্ণ",
        "Nb" : "ণ্ব",
        "Nm" : "ণ্ম",
        "Ny" : "ণ্য",
        //        "" : "ৎক",
        "tt" : "ত্ত",
        "ttb" : "ত্ত্ব",
        "tty" : "ত্ত্য",
        "tth" : "ত্থ",
        "tn" : "ত্ন",
        "tb" : "ত্ব",
        "tm" : "ত্ম",
        "tmy" : "ত্ম্য",
        "ty" : "ত্য",
        "tr" : "ত্র",
        "try" : "ত্র্য",
        //        "" : "ৎল",
        //        "" : "ৎস",
        "thb" : "থ্ব",
        "thy" : "থ্য",
        "thr" : "থ্র",
        "dg" : "দ্গ",
        "dgh" : "দ্ঘ",
        "dd" : "দ্দ",
        "ddb" : "দ্দ্ব",
        "ddh" : "দ্ধ",
        "db" : "দ্ব",
        "dbh" : "দ্ভ",
        "dbhr" : "দ্ভ্র",
        "dm" : "দ্ম",
        "dy" : "দ্য",
        "dr" : "দ্র",
        "dry" : "দ্র্য",
        "dhn" : "ধ্ন",
        "dhb" : "ধ্ব",
        "dhm" : "ধ্ম",
        "dhy" : "ধ্য",
        "dhr" : "ধ্র",
        "nT" : "ন্ট",
        "nTr" : "ন্ট্র",
        "nTh" : "ন্ঠ",
        "nD" : "ন্ড",
        "nDr" : "ন্ড্র",
        "nt" : "ন্ত",
        "ntb" : "ন্ত্ব",
        "nty" : "ন্ত্য",
        "ntr" : "ন্ত্র",
        "ntry" : "ন্ত্র্য",
        "nth" : "ন্থ",
        "nthy" : "ন্থ্র",
        "nd" : "ন্দ",
        "ndy" : "ন্দ্য",
        "ndb" : "ন্দ্ব",
        "ndr" : "ন্দ্র",
        "ndh" : "ন্ধ",
        "ndhy" : "ন্ধ্য",
        "ndhr" : "ন্ধ্র",
        "nn" : "ন্ন",
        "nb" : "ন্ব",
        "nm" : "ন্ম",
        "ny" : "ন্য",
        "pT" : "প্ট",
        "pt" : "প্ত",
        "pn" : "প্ন",
        "pp" : "প্প",
        "py" : "প্য",
        "pr" : "প্র",
        "pry" : "প্র্য",
        "pl" : "প্ল",
        "ps" : "প্স",
        "phs" : "ফ্র",
        "phl" : "ফ্ল",
        "fs" : "ফ্র",
        "fl" : "ফ্ল",
        "bj" : "ব্জ",
        "bd" : "ব্দ",
        "bdh" : "ব্ধ",
        "bb" : "ব্ব",
        "by" : "ব্য",
        "br" : "ব্র",
        "bl" : "ব্ল",
        "bhb" : "ভ্ব",
        "bhy" : "ভ্য",
        "bhr" : "ভ্র",
        "vb" : "ভ্ব",
        "vy" : "ভ্য",
        "vr" : "ভ্র",
        "mn" : "ম্ন",
        "mp" : "ম্প",
        "mpr" : "ম্প্র",
        "mph" : "ম্ফ",
        "mb" : "ম্ব",
        "mbr" : "ম্ব্র",
        "mbh" : "ম্ভ",
        "mbhr" : "ম্ভ্র",
        "mm" : "ম্ম",
        "my" : "ম্য",
        "mr" : "ম্র",
        "ml" : "ম্ল",
        "zy" : "য্য",
        "rk" : "র্ক",
        "rky" : "র্ক্য",
        "rgy" : "র্গ্য",
        "rghy" : "র্ঘ্য",
        "rcy" : "র্চ্য",
        "rjy" : "র্জ্য",
        "rNy" : "র্ণ্য",
        "rty" : "র্ত্য",
        "rthy" : "র্থ্য",
        "rby" : "র্ব্য",
        "rmy" : "র্ম্য",
        "rshy" : "র্শ্য",
        "rShy" : "র্ষ্য",
        "rhy" : "র্হ্য",
        "rkh" : "র্খ",
        "rg" : "র্গ",
        "rgr" : "র্গ্র",
        "rgh" : "র্ঘ",
        "rc" : "র্চ",
        "rch" : "র্ছ",
        "rj" : "র্জ",
        "rjh" : "র্ঝ",
        "rT" : "র্ট",
        "rD" : "র্ড",
        "rN" : "র্ণ",
        "rt" : "র্ত",
        "rtr" : "র্ত্র",
        "rth" : "র্থ",
        "rd" : "র্দ",
        "rdb" : "র্দ্ব",
        "rdr" : "র্দ্র",
        "rdh" : "র্ধ",
        "rdhb" : "র্ধ্ব",
        "rn" : "র্ন",
        "rp" : "র্প",
        "rph" : "র্ফ",
        "rbh" : "র্ভ",
        "rm" : "র্ম",
        "rz" : "র্য",
        "rl" : "র্ল",
        "rsh" : "র্শ",
        "rshb" : "র্শ্ব",
        "rSh" : "র্ষ",
        "rs" : "র্স",
        "rh" : "র্হ",
        "rDh" : "র্ঢ্য",
        "lk" : "ল্ক",
        "lky" : "ল্ক্য",
        "lg" : "ল্গ",
        "lT" : "ল্ট",
        "lD" : "ল্ড",
        "lp" : "ল্প",
        "lph" : "ল্‌ফ",
        "lb" : "ল্ব",
        "lbh" : "ল্‌ভ",
        "lm" : "ল্ম",
        "ly" : "ল্য",
        "ll" : "ল্ল",
        "shc" : "শ্চ",
        "shch" : "শ্ছ",
        "shn" : "শ্ন",
        "shb" : "শ্ব",
        "shm" : "শ্ম",
        "shy" : "শ্য",
        "shr" : "শ্র",
        "shl" : "শ্ল",
        "Sc" : "শ্চ",
        "Sch" : "শ্ছ",
        "Sn" : "শ্ন",
        "Sb" : "শ্ব",
        "Sm" : "শ্ম",
        "Sy" : "শ্য",
        "Sr" : "শ্র",
        "Sl" : "শ্ল",
        "Shk" : "ষ্ক",
        "Shkr" : "ষ্ক্র",
        "ShT" : "ষ্ট",
        "ShTy" : "ষ্ট্য",
        "Shtr" : "ষ্ট্র",
        "ShTh" : "ষ্ঠ",
        "ShThy" : "ষ্ঠ্য",
        //        "" : "ষ্ণ",
        "Shp" : "ষ্প",
        "Shpr" : "ষ্প্র",
        "Shph" : "ষ্ফ",
        "Shb" : "ষ্ব",
        "Shm" : "ষ্ম",
        "Shy" : "ষ্য",
        "sk" : "স্ক",
        "skr" : "স্ক্র",
        "skh" : "স্খ",
        "sT" : "স্ট",
        "sTr" : "স্ট্র",
        "st" : "স্ত",
        "stb" : "স্ত্ব",
        "sty" : "স্ত্য",
        "str" : "স্ত্র",
        "sth" : "স্থ",
        "sthy" : "স্থ্য",
        "sn" : "স্ন",
        "sp" : "স্প",
        "spr" : "স্প্র",
        "spl" : "স্প্‌ল",
        "sph" : "স্ফ",
        "sb" : "স্ব",
        "sm" : "স্ম",
        "sy" : "স্য",
        "sr" : "স্র",
        "sl" : "স্ল",
        "hN" : "হ্ণ",
        "hn" : "হ্ন",
        "hb" : "হ্ব",
        "hm" : "হ্ম",
        "hy" : "হ্য",
        "hr" : "হ্র",
        "hl" : "হ্ল",
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
