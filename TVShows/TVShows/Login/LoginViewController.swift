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
    private var notificaionTokens: [NSObjectProtocol] = []

    //MARK :- Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        handleKeyboardEvents()
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
    
    deinit {
        notificaionTokens.forEach(NotificationCenter.default.removeObserver)
    }
    
    //Doing this keeps the content of the scroll view centered on all devices
    private func setTopInsetValue() {
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
        rememberMeCheckboxButton.isSelected.toggle()
    }
    
    private func handleKeyboardEvents() {
        let willShowToken = NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self?.scrollView.contentInset.bottom = keyboardHeight
                self?.scrollView.contentInset.top = 0
            }
        let willHideToken = NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                // keyboard is about to hide, handle UIScrollView contentInset, e.g.
                self?.scrollView.contentInset.bottom = .zero
                guard let topInsetValue = self?.topInsetValue else { return }
                self?.scrollView.contentInset.top = topInsetValue
            }
        notificaionTokens.append(willShowToken)
        notificaionTokens.append(willHideToken)
    }

    @IBAction func onLogin() {
        if let userEmail = usernameTextField.text, let userPassword = passwordTextField.text {
                SVProgressHUD.show()
            //TODO: - Add "remember me" functionality
                firstly{
                    alamofireLoginUserWith(
                        email: userEmail,
                        password: userPassword)
                    }.ensure {
                        SVProgressHUD.dismiss()
                    }.done{ token in
                        self.navigateToHomeScene()
                    }.catch{ error in
                        print("\(error.localizedDescription)")
                }
        }
    }
    
    @IBAction func onAccountCreation() { //The API does check on the validity of inputs but if the call can be skipped I believe it should
        if let userEmail = usernameTextField.text, let userPassword = passwordTextField.text {
            if userEmail.isValidEmail(), userPassword.isEmpty == false {
                SVProgressHUD.show()

                firstly{
                    alamofireRegisterUserWith(
                        email: userEmail,
                        password: userPassword)
                    }.ensure {
                        SVProgressHUD.dismiss()
                    }.done{ _ in //This is clearly wrong but I've no idea how to do it and there were no consultations free for this week :(
                        self.onLogin()
                    }.catch{ error in
                        print("\(error.localizedDescription)")
                }
            } else if userEmail.isValidEmail() == false { //Probably bad but i like it
                SVProgressHUD.showError(withStatus: "Please enter a valid e-mail")
            } else if userPassword.isEmpty {
                SVProgressHUD.showError(withStatus: "Password can't be empty")
            }
        }
    }

    //MARK: - Navigation
    
    private func navigateToHomeScene() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - Helper functions

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(
            pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
            options: .caseInsensitive)
        return regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count)) != nil
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
    
    private func alamofireLoginUserWith(email: String, password: String) -> Promise<LoginData>{
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        return Promise { promise in
            Alamofire
                .request(
                    "https://api.infinum.academy/api/users/sessions",
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default)
                .validate()
                .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { (dataResponse: DataResponse<LoginData>) in
                    switch dataResponse.result {
                    case .success(let token):
                        promise.fulfill(token)
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: "\(error)")
                    }
            }
        }
    }
    
}
