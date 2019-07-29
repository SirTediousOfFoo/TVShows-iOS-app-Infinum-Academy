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

final class HomeViewController: UIViewController{
    
    //MARK: - Properties
    
    var userData: LoginData? = nil
    private var showsList: [Show] = []
    
    //MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getShowsList(userData: userData)
        self.title = "Shows"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func getShowsList(userData: LoginData?) {
        
        guard let token = userData?.token else {
            showAlert(title: "Authentication error", message: "Please try logging in to your account again")
            return }
        
        let headers = ["Authorization": token]
        SVProgressHUD.show()
        
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
            }.ensure {
                SVProgressHUD.dismiss()
            }.done { [weak self] showsList in
                self?.showsList = showsList
                self?.tableView.reloadData()
            }.catch { [weak self] error in
                self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
        }
    }
    
    //MARK: - Navigation
    
    private func navigateToDetailsScene(selectedShow: Show) {
        guard let token = userData?.token else { return }

        let showDetailsViewContoller = storyboard?.instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController
        showDetailsViewContoller.showId = selectedShow.id
        showDetailsViewContoller.userToken = token

        navigationController?.pushViewController(showDetailsViewContoller, animated: true)
    }
}

//MARK: - TableView functions

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TVShowCell.self),
            for: indexPath) as! TVShowCell
        
        tableViewCell.configure(with: showsList[indexPath.row])
        
        return tableViewCell
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = showsList[indexPath.row]
        navigateToDetailsScene(selectedShow: item)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in //Deletion still just visual since we don't really want to delete the shows we have
                tableView.performBatchUpdates({
                    self.showsList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
                success(true)
            })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
}

private extension HomeViewController {
    
    private func setupTableView() {
        
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()

        tableView.delegate = self
        tableView.dataSource = self
    }
}
