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
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController{
    
    //MARK: - Properties
    
    private var userData: LoginData? = nil
    private var showsList: Observable<[Show]>?
    private let disposeBag = DisposeBag()
    
    //MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        initialSetup()
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
        
//        let refresher = UIRefreshControl()
//
//        refresher.addTarget(self,
//                            action: #selector(refreshWrapper),
//                            for: .valueChanged)
//        tableView.refreshControl = refresher
//
//        let refreshAction = refresher.rx.controlEvent(.valueChanged)
//
//        refreshAction.subscribe(onNext: { _ in
//            self.refreshWrapper()
//        }).disposed(by: disposeBag)
//          Can't get this to work, keeps crashing no idea what's wrong here, going to have to look into  it
        
        tableView.rx.modelSelected(Show.self)
            .subscribe(onNext: { [weak self] show in
                self?.navigateToDetailsScene(selectedShow: show)
                
                if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe(onNext: { (indexPath) in
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: "Delete",
                handler: { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in //Deletion still just visual since we don't really want to delete the shows we have
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: nil)
                    success(true)
                })
            deleteAction.backgroundColor = .red
        }).disposed(by: disposeBag)
    }
    
    //MARK: - objc functions
    
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
        
        showsList = APIManager.requestObservable(
            [Show].self,
            path: "https://api.infinum.academy/api/shows",
            method: .get,
            parameters: nil,
            keyPath: Properties.dataPath.rawValue,
            headers: headers)
        
        showsList?.bind(
            to: tableView.rx.items(
                cellIdentifier: String(describing: TVShowCell.self),
                cellType: TVShowCell.self)) { row, model, cell in
                    cell.configure(with: model)
            }.disposed(by: disposeBag)
        
//        firstly {
//            APIManager.request(
//                [Show].self,
//                path: "https://api.infinum.academy/api/shows",
//                method: .get,
//                parameters: nil,
//                keyPath: "data",
//                encoding: JSONEncoding.default,
//                decoder: JSONDecoder(),
//                headers: headers)
//            }.ensure { [weak self] in
//                if self?.tableView.refreshControl?.isRefreshing ?? false {
//                    self?.tableView.refreshControl?.endRefreshing()
//                } else {
//                    SVProgressHUD.dismiss()
//                }
//            }.done { [weak self] showsList in
//                self?.showsList = showsList
//                self?.tableView.reloadData()
//            }.catch { [weak self] error in
//                self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
//        }
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

//extension HomeViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return showsList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let tableViewCell = tableView.dequeueReusableCell(
//            withIdentifier: String(describing: TVShowCell.self),
//            for: indexPath) as! TVShowCell
//
//        tableViewCell.configure(with: showsList[indexPath.row])
//
//        return tableViewCell
//    }
//}

extension HomeViewController: UITableViewDelegate {
    
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
//            })
//        deleteAction.backgroundColor = .red
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
    //Using this so we don't mess up the loading process and put the wrong image in the wrong cell, correct according to __KF Cheat sheet__
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.imageView?.kf.cancelDownloadTask()
//    }
}

private extension HomeViewController {
    
    private func setupTableView() {
        
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()

        tableView.delegate = nil
     //   tableView.dataSource = self
    }
}
