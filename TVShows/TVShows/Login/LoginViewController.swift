//
//  LoginViewController.swift
//  TVShows
//
//  Created by Infinum on 05/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire
import PromiseKit

final class LoginViewController: UIViewController {
    
    //MARK :- Outlets
    
    @IBOutlet private weak var rememberMeCheckboxButton: UIButton!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        if mainStackView.frame.height < scrollView.frame.height //Content is smaller than scrollView so it needs to be centered on screen
        {
            topInsetValue = (scrollView.frame.height - mainStackView.frame.height)/2
            scrollView.contentInset.top = topInsetValue
        }
        else { //Content is bigger than scrollView so we remove the inset
            scrollView.contentInset.top = 0
        }
    }
    
    //MARK :- Actions
    
    @IBAction private func checkboxStateChanged() {
        if rememberMeIsSelected { //I hope this is a good way of doing these comparisons and working with the checkbox
            UIView.animate(withDuration: 0.5) {
                self.rememberMeCheckboxButton.setImage(
                    UIImage(named: "ic-checkbox-empty"),
                    for: UIControl.State.normal)
            }
            rememberMeIsSelected = false
        }
        else{
            UIView.animate(withDuration: 0.5) {
                self.rememberMeCheckboxButton.setImage(
                    UIImage(named: "ic-checkbox-filled"),
                    for: UIControl.State.normal)
            }
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

    @IBAction func onLogin() {
        
        SVProgressHUD.show()
        
        firstly{
            alamofireLoginUserWith(
                email: usernameTextField.text!,
                password: passwordTextField.text!)
            }.ensure {
                SVProgressHUD.dismiss()
            }.done{ user in
                self.navigateToHomeScene(_user: user)
            }.catch{ error in
                SVProgressHUD.showError(withStatus: "\(error)")
        }
        
    }
    
    @IBAction func onAccountCreation() {
        
        SVProgressHUD.show()
        
        firstly{
            alamofireRegisterUserWith(
                email: usernameTextField.text!,
                password: passwordTextField.text!)
            }.ensure {
                SVProgressHUD.dismiss()
            }.done{ user in
                self.navigateToHomeScene(_user: user)
            }.catch{ error in
                SVProgressHUD.showError(withStatus: "\(error)")
        }
    }

    //MARK: - Navigation
    
    private func navigateToHomeScene(_user: User?) {
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        viewController.user = _user
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - API calls

private extension LoginViewController{
    
    private func alamofireRegisterUserWith(email: String, password: String) -> Promise<User> {
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        return Promise { promise in
            Alamofire
                .request(
                    "https://api.infinum.academy/api/users",
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default)
                .validate()
                .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (response: DataResponse<User>) in
                    switch response.result {
                    case .success(let user):
                        promise.fulfill(user)
                    case .failure(let error):
                        promise.reject(error)
                    }
            }
        }
    }
    
    private func alamofireLoginUserWith(email: String, password: String) -> Promise<User>{
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        return Promise{ promise in
            Alamofire
                .request(
                    "https://api.infinum.academy/api/users/sessions",
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default)
                .validate()
                .responseJSON { dataResponse in
                    switch dataResponse.result {
                    case .success(let response):
                        SVProgressHUD.showSuccess(withStatus: "\(response)")
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: "\(error)")
                    }
            }
        }
    }
    
}
