//
//  CommentsViewController.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import CodableAlamofire

class CommentsViewController: UIViewController {

    //MARK: - Properties
    
    private var comments: [Comment] = []
    private var isRefreshing = false
    var episodeId: String = ""
    private var notificaionTokens: [NSObjectProtocol] = []

    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var noCommentsView: UIView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getComments()
        setupTableView()
        setupUI()
        handleKeyboardEvents()
    }

    deinit {
        notificaionTokens.forEach(NotificationCenter.default.removeObserver)
    }
    
    //MARK: - Initial setup
    
    private func setupUI() {
        let refresher = UIRefreshControl()
        refresher.addTarget(self,
                            action: #selector(refreshWrapper),
                            for: .valueChanged)
        tableView.refreshControl = refresher
        
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func refreshWrapper() {
        isRefreshing = true
        getComments()
    }
    
    //MARK: - API calls
    
    private func getComments() {
        
        guard let token = UserKeychain.keychain[Properties.userToken.rawValue] else {
            showAlert(title: "Authentication error", message: "Please try logging in to your account again")
            return }
        
        let headers = ["Authorization": token]
        
        if !isRefreshing {
            SVProgressHUD.show()
        }
        
        firstly {
            APIManager.request(
                [Comment].self,
                path: "https://api.infinum.academy/api/episodes/\(episodeId)/comments",
                method: .get,
                parameters: nil,
                keyPath: "data",
                encoding: JSONEncoding.default,
                decoder: JSONDecoder(),
                headers: headers)
            }.ensure { [weak self] in
                if self?.isRefreshing ?? false {
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.isRefreshing = false
                } else {
                    SVProgressHUD.dismiss()
                }
            }.done { [weak self] comments in
                self?.comments = comments
                self?.tableView.reloadData()
            }.catch { [weak self] error in
                print(error)
                self?.showAlert(title: "API error", message: "\(error.localizedDescription)")
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func navigateBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func postComment() {
        
        guard
          //  let episodeId = episodeId,
            let comment = commentField.text
        else {
            showAlert(title: "Error", message: "There was an error posting the comment")
            return
        }
        
        guard let token = UserKeychain.keychain[Properties.userToken.rawValue] else {
            showAlert(title: "Authentication error", message: "Please try logging in to your account again")
            return }
        
        let parameters: [String: String] = [
            "text": comment,
            "episodeId": episodeId
        ]
        
        let headers = ["Authorization": token]
        
        firstly {
            APIManager.request(
                PostedComment.self,
                path: "https://api.infinum.academy/api/comments",
                method: .post,
                parameters: parameters,
                keyPath: "data",
                encoding: JSONEncoding.default,
                decoder: JSONDecoder(),
                headers: headers)
            }.done{ [weak self] result in
                self?.comments.append(result.toComment())
                self?.tableView.reloadData()
                self?.commentField.text?.removeAll()
            }.catch { [weak self] error in
                print(error)
                self?.showAlert(title: "Error", message: "There was an error posting a token")
            }
    }
    
    //MARK: - Event handling
    
    private func handleKeyboardEvents() {

        let willShowToken = NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        self?.inputViewBottomConstraint.constant = keyboardSize.height
                    }
        }
        
        let willHideToken = NotificationCenter
            .default
            .addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                // keyboard is about to hide, handle UIScrollView contentInset, e.g.
                self?.inputViewBottomConstraint.constant = 0
        }
        
        notificaionTokens.append(willShowToken)
        notificaionTokens.append(willHideToken)
    }
}

//MARK: - TableView setup and functions

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.count == 0 {
            noCommentsView.isHidden = false
            tableView.isHidden = true
        }
        else {
            noCommentsView.isHidden = true
            tableView.isHidden = false
        }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: CommentCell.self),
            for: indexPath) as! CommentCell
        
        tableViewCell.configure(with: comments[indexPath.row], at: indexPath.row)
        
        return tableViewCell
    }
    
    
}

private extension CommentsViewController {
    
    private func setupTableView() {
        
        tableView.estimatedRowHeight = 120
    //    tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
}
