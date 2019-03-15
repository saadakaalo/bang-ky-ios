//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Saurav Ganguly-402 on 14/3/19.
//  Copyright © 2019 bjitgroup. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
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

        loadAndSetupInterface()
        proxy = textDocumentProxy as UITextDocumentProxy
        nextKeyboardButton.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
        //        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        print("textWillChange")
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        print("textDidChange")
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.magenta
//        } else {
//            textColor = UIColor.green
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, for: [])
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
        } else {
            proxy.insertText(title)
        }
    }

    func swapCapitalAndSmallLetterKeyboard() {
        if isCapital {
            loadAndSetupInterface()
        } else {
            loadAndSetupCapitalLetterInterface()
        }
        isCapital = !isCapital
    }

    func loadAndSetupInterface() {
        if let keyboard = capitalLetterKeyboardView {
            keyboard.removeFromSuperview()
        }

        let nib = UINib(nibName: "KeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        smallLetterKeyboardView = (objects.first as! UIView)
        view.addSubview(smallLetterKeyboardView)

        smallLetterKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            smallLetterKeyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            smallLetterKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            smallLetterKeyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            smallLetterKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    func loadAndSetupCapitalLetterInterface() {
        if let keyboard = smallLetterKeyboardView {
            keyboard.removeFromSuperview()
        }

        let nib = UINib(nibName: "CapitalLetterKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        capitalLetterKeyboardView = (objects.first as! UIView)
        view.addSubview(capitalLetterKeyboardView)

        capitalLetterKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capitalLetterKeyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            capitalLetterKeyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            capitalLetterKeyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            capitalLetterKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
