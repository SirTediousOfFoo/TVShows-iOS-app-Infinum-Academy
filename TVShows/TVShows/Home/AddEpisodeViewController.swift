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
import SVProgressHUD
import RxSwift
import RxCocoa

protocol AddEpisodeViewControllerDelegate: class {
    func showListDidChange(addedEpisode: Episode)
}

final class AddEpisodeViewController: UIViewController {

    //MARK: - Properties
    
    private var notificaionTokens: [NSObjectProtocol] = []
    var showId = ""
    weak var delegate: AddEpisodeViewControllerDelegate?
    private var media: Media?
    private var imageByteData: Data?
    private let disposeBag = DisposeBag()
    
    //MARK: - Outlets
    
    @IBOutlet private weak var addImageButton: UIButton!
    @IBOutlet private weak var seasonEpisodePicker: UIPickerView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var epiosdeTitleField: UITextField!
    @IBOutlet private weak var episodeDescriptionField: UITextField!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        handleKeyboardEvents()
        subscribeItems()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        notificaionTokens.forEach(NotificationCenter.default.removeObserver)
    }
    
    private func subscribeItems() {
        addImageButton.rx.tap.subscribe({ [weak self] _ in
            self?.uploadImage()
        }).disposed(by: disposeBag)
    }
    
    //MARK: - UI setup
    
    private func setupUI() {
        
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
                // keyboard is about to hide, handle UIScrollView contentInset
                self?.scrollView.contentInset.bottom = .zero
        }
        
        notificaionTokens.append(willShowToken)
        notificaionTokens.append(willHideToken)
    }

    @objc private func didSelectDone() {
        
        guard let title = epiosdeTitleField.text,
            let description = episodeDescriptionField.text
            else { return }
        
        guard let token = UserKeychain.keychain[Properties.userToken.rawValue] else {
            showAlert(title: "Session expired", message: "Please log back in")
            return
        }
        
        let headers = ["Authorization": token]

        let parameters: [String: String] = [
            "showId": showId,
            "mediaId": "",
            "title": title,
            "description": description,
            "episodeNumber": "\(seasonEpisodePicker.selectedRow(inComponent: 1)+1)",
            "season": "\(seasonEpisodePicker.selectedRow(inComponent: 0)+1)"
        ]
        
        guard let imageByteData = imageByteData else {
            addEpisodeWithoutImage(parameters: parameters, headers: headers)
            return
        }
 
        addNewEpisode(imageByteData: imageByteData, parameters: parameters, headers: headers)
    }
    
    @objc private func didSelectCancel() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - API Calls

extension AddEpisodeViewController {
    
    private func addNewEpisode(imageByteData: Data, parameters: [String: String], headers: [String: String]) {
        
        var parameters = parameters
        
        firstly{
            APIManager.uploadImageOnAPI(
                fileName: "image.png",
                imageByteData: imageByteData,
                headers: headers)
            }.then{ image -> Promise<Episode> in
                
                parameters["mediaId"] = image.id
                
                return APIManager.request(
                    Episode.self,
                    path: "https://api.infinum.academy/api/episodes",
                    method: .post,
                    parameters: parameters,
                    keyPath: "data",
                    encoding: JSONEncoding.default,
                    decoder: JSONDecoder(),
                    headers: headers)
            }.ensure{
                SVProgressHUD.dismiss()
            }.done { [weak self] result in
                self?.dismiss(animated: true, completion: nil)
                self?.delegate?.showListDidChange(addedEpisode: result)
            }.catch { [weak self] error in
                self?.showAlert(title: "Posting failed", message: "\(error.localizedDescription)")
        }
    }
    private func addEpisodeWithoutImage(parameters: [String: String], headers: [String: String]) {
      
        SVProgressHUD.show()
        
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
            }.ensure{
                SVProgressHUD.dismiss()
            }.catch { [weak self] error in
                self?.showAlert(title: "Posting failed", message: "\(error.localizedDescription)")
        }
    }
}

//MARK: - Image picker methods

extension AddEpisodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func uploadImage() {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self

        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            imageByteData = pickedImage.pngData()!
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Episode picker view setup

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
    
    private func setupDelegates() {
        seasonEpisodePicker.delegate = self
        seasonEpisodePicker.dataSource = self
    }
}

