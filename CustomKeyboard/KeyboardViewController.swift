//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Saurav Ganguly-402 on 14/3/19.
//  Copyright © 2019 bjitgroup. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardLettersDelegate, KeyboardNumbersDelegate {

    var smallLetterKeyboardView: UIView!
    var capitalLetterKeyboardView: UIView!
    var lettersView: KeyboardLettersView!
    var numbersView: KeyboardNumbersView!
    var proxy : UITextDocumentProxy!
    var isCapital = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Fixed height for the keyboard
        view.heightAnchor.constraint(equalToConstant: 250).isActive = true;

//        addKeyboardUIToRootView(isCapital: false)


        lettersView = KeyboardLettersView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        lettersView.delegate = self
        view.addSubview(lettersView)
        lettersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lettersView.leftAnchor.constraint(equalTo: view.leftAnchor),
            lettersView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            lettersView.rightAnchor.constraint(equalTo: view.rightAnchor),
            lettersView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        numbersView = KeyboardNumbersView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        numbersView.isHidden = true
        numbersView.delegate = self
        view.addSubview(numbersView)
        numbersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numbersView.leftAnchor.constraint(equalTo: view.leftAnchor),
            numbersView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            numbersView.rightAnchor.constraint(equalTo: view.rightAnchor),
            numbersView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        proxy = textDocumentProxy as UITextDocumentProxy
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else {
            return
        }
        if title == "⇤" {
            proxy.deleteBackward()
        } else if title == "⇪" {
            swapCapitalAndSmallLetterKeyboard()
        } else if title == "🌐" {
            advanceToNextInputMode()
        } else {
            proxy.insertText(title)
        }
    }

    func swapCapitalAndSmallLetterKeyboard() {
        if isCapital {
            addKeyboardUIToRootView(isCapital: false)
        } else {
            addKeyboardUIToRootView(isCapital: true)
        }
        isCapital = !isCapital
    }


    func addKeyboardUIToRootView(isCapital: Bool) {

        loadKeyboardViewsIfNotLoaded()

        let keyboardViewToAdd: UIView
        if isCapital {
            smallLetterKeyboardView.removeFromSuperview()
            keyboardViewToAdd = capitalLetterKeyboardView
        } else {
            capitalLetterKeyboardView.removeFromSuperview()
            keyboardViewToAdd = smallLetterKeyboardView
        }

        view.addSubview(keyboardViewToAdd)

        keyboardViewToAdd.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardViewToAdd.leftAnchor.constraint(equalTo: view.leftAnchor),
            keyboardViewToAdd.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            keyboardViewToAdd.rightAnchor.constraint(equalTo: view.rightAnchor),
            keyboardViewToAdd.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    func loadKeyboardViewsIfNotLoaded() {
        if smallLetterKeyboardView == nil {
            let nib = UINib(nibName: "KeyboardView", bundle: nil)
            let objects = nib.instantiate(withOwner: self, options: nil)
            smallLetterKeyboardView = (objects.first as! UIView)
        }

        if capitalLetterKeyboardView == nil {
            let nibForCap = UINib(nibName: "CapitalLetterKeyboardView", bundle: nil)
            let objectsForCap = nibForCap.instantiate(withOwner: self, options: nil)
            capitalLetterKeyboardView = (objectsForCap.first as! UIView)
        }
    }

    // MARK: KeyboardLettersDelegate and KeyboardNumbersDelegate methods

    var returnLabel: String = ""
    var shouldResetInsertionPoint: Bool = false

    func transform(_ s: String) -> String {
        return s
    }

    func didLetters(_ button: UIButton) {
        lettersView.isHidden = false
        numbersView.isHidden = true
    }

    func didNumbers(_ button: UIButton) {
        lettersView.isHidden = true
        numbersView.isHidden = false
    }
}
