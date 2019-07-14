//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    //MARK :- Outlets
    
    @IBOutlet private weak var rememberMeCheckboxButton: UIButton!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var mainStackView: UIStackView!
    
    //MARK :- Properties
    
    private var rememberMeIsSelected: Bool = false
    private var topInsetValue: CGFloat = 0
    
    //MARK :- Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        keyboardEventHappened()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTopInsetValue()
    }
    
    private func configureUI() {
        logInButton.layer.cornerRadius = 10
        //Set up a tap listener that dismisses the keyboard upon tapping outside text fields
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Doing this keeps the content of the scroll view centered on all devices
    private func setTopInsetValue()
    {
        topInsetValue = (scrollView.frame.height - mainStackView.frame.height)/2
        scrollView.contentInset.top = topInsetValue
    }
    
    //MARK :- Actions
    
    @IBAction private func checkboxStateChanged() {
        if rememberMeIsSelected { //I hope this is a good way of doing these
            rememberMeCheckboxButton.setImage(
                UIImage(named: "ic-checkbox-empty"),
                for: UIControl.State.normal)
            rememberMeIsSelected = false
        }
        else{
            rememberMeCheckboxButton.setImage(
                UIImage(named: "ic-checkbox-filled"),
                for: UIControl.State.normal)
            rememberMeIsSelected = true
        }
    }
    
    private func keyboardEventHappened() {
        NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height
                    self?.scrollView.contentInset.bottom = keyboardHeight
                    self?.scrollView.contentInset.top = 0
                }
            }
        NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                // keyboard is about to hide, handle UIScrollView contentInset, e.g.
                self?.scrollView.contentInset.bottom = .zero
                self?.scrollView.contentInset.top = self!.topInsetValue //This should be a good use of force unwrap since there should never be a nil
            }
        
    }

}
