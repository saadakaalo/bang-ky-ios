//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Saurav Ganguly-402 on 14/3/19.
//  Copyright © 2019 bjitgroup. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardLettersDelegate, KeyboardNumbersDelegate {

    let sharedTransformer = Transformer.shared
    var lettersView: KeyboardLettersView!
    var numbersView: KeyboardNumbersView!
    // TODO: Remove this label
    var debugLabel: UILabel!

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        ///Fixed height for the keyboard
        view.heightAnchor.constraint(equalToConstant: 250).isActive = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sharedTransformer.textDocumentProxy = self.textDocumentProxy

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

        /// TODO: Delete this below code, they are now for debug purpose
        debugLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 20))
        debugLabel.text = "@"
        view.addSubview(debugLabel)
        NSLayoutConstraint.activate([
            debugLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            debugLabel.topAnchor.constraint(equalTo: view.topAnchor),
            debugLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }

    // MARK: KeyboardLettersDelegate and KeyboardNumbersDelegate methods

    func didLetters(_ button: UIButton) {
        lettersView.isHidden = false
        numbersView.isHidden = true
    }

    func didNumbers(_ button: UIButton) {
        lettersView.isHidden = true
        numbersView.isHidden = false
    }

    func didTap(onKeyboardKey keyValue: String) {
        sharedTransformer.debugLabel = debugLabel

        /// Clear the buffer when context become empty
        /// When the context changes from externally, reset the buffer
        /// context is nil when there is no text in the left side
        if textDocumentProxy.documentContextBeforeInput == nil {
            sharedTransformer.resetBuffer()
        }

        sharedTransformer.insertText(keyValue)
    }
}
