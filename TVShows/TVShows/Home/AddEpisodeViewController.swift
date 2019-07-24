//
//  AddEpisodeViewController.swift
//  TVShows
//
//  Created by Infinum on 22/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import CodableAlamofire
import PromiseKit

protocol AddEpisodeViewControllerDelegate: class {
    func showListDidChange(addedEpisode: Episode)
}

class AddEpisodeViewController: UIViewController {

    //MARK: - Properties
    
    private var notificaionTokens: [NSObjectProtocol] = []
    var showId = ""
    var userToken = ""
    weak var delegate: AddEpisodeViewControllerDelegate?
    private let alertController = UIAlertController.init(
        title: "Posting failed",
        message: "Something went wrong",
        preferredStyle: .alert)
    
    //MARK: - Outlets
    
    @IBOutlet weak var seasonEpisodePicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var epiosdeTitleField: UITextField!
    @IBOutlet weak var episodeDescriptionField: UITextField!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        handleKeyboardEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    //MARK: - UI setup
    
    func setupUI() {
        
        let leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didSelectCancel)
        )
        leftBarButtonItem.tintColor = UIColor.init(red: 1.0, green: 117/255, blue: 140/255, alpha: 1.0)
        
        let rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(didSelectDone)
        )
        rightBarButtonItem.tintColor = UIColor.init(red: 1.0, green: 117/255, blue: 140/255, alpha: 1.0)
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem

        //Set up a tap listener that dismisses the keyboard upon tapping outside text fields
        let tap = UITapGestureRecognizer(
            target: self.view,
            action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        alertController.addAction(
            UIAlertAction.init(
                title: "OK",
                style: .default,
                handler: nil))
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
                guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                guard let contentHeight = self?.scrollView.contentSize.height else { return }
                guard let viewHeight = self?.view.frame.height else { return }
                if contentHeight - viewHeight <= keyboardHeight {
                    self?.scrollView.contentInset.bottom = keyboardHeight
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
                self?.scrollView.contentInset.bottom = .zero
        }
        notificaionTokens.append(willShowToken)
        notificaionTokens.append(willHideToken)
    }

    @objc func didSelectDone() {
        guard let title = epiosdeTitleField.text,
            let description = episodeDescriptionField.text
            else { return }
        
        let parameters: [String: String] = [
            "showId": showId,
            //"mediaId": "",
            "title": title,
            "description": description,
            "episodeNumber": "\(seasonEpisodePicker.selectedRow(inComponent: 1)+1)",
            "season": "\(seasonEpisodePicker.selectedRow(inComponent: 0)+1)"
        ]
        
        let headers = ["Authorization": userToken]

        firstly { APIManager.request(
            Episode.self,
            path: "https://api.infinum.academy/api/episodes",
            method: .post,
            parameters: parameters,
            keyPath: "data",
            encoding: JSONEncoding.default,
            decoder: JSONDecoder(),
            headers: headers)
        }.done { [weak self] result in
            self?.dismiss(animated: true, completion: nil)
            self?.delegate?.showListDidChange(addedEpisode: result)
        }.catch { [weak self] error in
            guard let alertController = self?.alertController else { return }
            alertController.message = error.localizedDescription
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func didSelectCancel() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Picker view setup

extension AddEpisodeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(row+1)"
    }
    
    func setupDelegates() {
        seasonEpisodePicker.delegate = self
        seasonEpisodePicker.dataSource = self
    }
}
