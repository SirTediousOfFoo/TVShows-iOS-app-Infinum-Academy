//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import PromiseKit
import CodableAlamofire
import SVProgressHUD
import Kingfisher
import KeychainAccess

final class NewHomeViewController: UIViewController{
    
    //MARK: - Properties
    
    private var userData: LoginData? = nil
    private var showsList: [Show] = []
    let listCellIdentifier = "ListCell"
    var isListView = false
    
    //MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupCollectionView()
        getShowsList(userData: userData)
        self.title = "Shows"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func initialSetup(){
        guard let token = UserKeychain.keychain[Properties.userToken.rawValue]
            else {
                navigateBackToLogin()
                return
        }
        
        userData = LoginData.init(token: token)
        
        let logoutItem = UIBarButtonItem.init(
            image: UIImage(named: "ic-logout"),
            style: .plain,
            target: self,
            action: #selector(_logoutActionHandler))
        
        navigationItem.leftBarButtonItem = logoutItem
        
        let toggleLayoutItem = UIBarButtonItem.init(
            image: UIImage(named: "ic-listview"),
            style: .plain,
            target: self,
            action: #selector(_toggleLayout))
        
        navigationItem.rightBarButtonItem = toggleLayoutItem
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self,
                            action: #selector(refreshWrapper),
                            for: .valueChanged)
        collectionView.refreshControl = refresher
        
       // collectionView.register(ListCell.self, forCellWithReuseIdentifier: listCellIdentifier)
    }
    
    //MARK: - objc functions
    
    @objc private func _toggleLayout() {
        if isListView {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(
                image: UIImage(named: "ic-gridview"),
                style: .plain,
                target: self,
                action: #selector(_toggleLayout))
            isListView = false
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(
                image: UIImage(named: "ic-listview"),
                style: .plain,
                target: self,
                action: #selector(_toggleLayout))
            isListView = true
        }
        
        self.collectionView?.reloadData()
    }
    
    @objc private func _logoutActionHandler() {
        navigateBackToLogin()
        
    }
    
    @objc private func refreshWrapper() {
        getShowsList(userData: userData)
    }
    
    //MARK: - Data fetching
    
    private func getShowsList(userData: LoginData?) {
        
        guard let token = userData?.token else {
            showAlert(title: "Authentication error", message: "Please try logging in to your account again")
            return }
        
        let headers = ["Authorization": token]
        
        if !(collectionView.refreshControl?.isRefreshing ?? false) {
            SVProgressHUD.show()
        }
        
        firstly {
            APIManager.request(
                [Show].self,
                path: "https://api.infinum.academy/api/shows",
                method: .get,
                parameters: nil,
                keyPath: "data",
                encoding: JSONEncoding.default,
                decoder: JSONDecoder(),
                headers: headers)
            }.ensure { [weak self] in
                if self?.collectionView.refreshControl?.isRefreshing ?? false {
                    self?.collectionView.refreshControl?.endRefreshing()
                } else {
                    SVProgressHUD.dismiss()
                }
            }.done { [weak self] showsList in
                self?.showsList = showsList
                self?.collectionView.reloadData()
            }.catch { [weak self] error in
                self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
        }
    }
    
    //MARK: - Navigation
    
    private func navigateToDetailsScene(selectedShow: Show) {
        
        let showDetailsViewContoller = storyboard?.instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController
        showDetailsViewContoller.showId = selectedShow.id
        
        navigationController?.pushViewController(showDetailsViewContoller, animated: true)
    }
    
    private func navigateBackToLogin() {
        
        do {
            try UserKeychain.keychain.removeAll()
        } catch let error {
            print("error: \(error)")
        }
        
        UserDefaults.standard.set(false, forKey: "userIsRemembered")
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }
}

//MARK: - TableView functions

extension NewHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showsList.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isListView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as! ListCell
            cell.configure(with: showsList[indexPath.row])
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
            cell.configure(with: showsList[indexPath.row])
            return cell
        }
    }
}

extension NewHomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if isListView {
            return CGSize(width: width, height: 120)
        }else {
            return CGSize(width: (width - 15)/2, height: (width - 15)/2)
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let item = showsList[indexPath.row]
//        navigateToDetailsScene(selectedShow: item)
//    }
//
//    func tableView(_ tableView: UITableView,
//                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(
//            style: .destructive,
//            title: "Delete",
//            handler: { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in //Deletion still just visual since we don't really want to delete the shows we have
//                tableView.performBatchUpdates({
//                    self.showsList.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .automatic)
//                }, completion: nil)
//                success(true)
//        })
//        deleteAction.backgroundColor = .red
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
//
//    //Using this so we don't mess up the loading process and put the wrong image in the wrong cell, correct according to __KF Cheat sheet__
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.imageView?.kf.cancelDownloadTask()
//    }
}

private extension NewHomeViewController {
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
