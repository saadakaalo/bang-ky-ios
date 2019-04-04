//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Saurav Ganguly-402 on 14/3/19.
//  Copyright © 2019 bjitgroup. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    var smallLetterKeyboardView: UIView!
    var capitalLetterKeyboardView: UIView!
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

        addKeyboardUIToRootView(isCapital: false)
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
            print("Shift button tapped")
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
}
