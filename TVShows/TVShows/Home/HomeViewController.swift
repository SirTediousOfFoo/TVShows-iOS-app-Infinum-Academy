//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import CodableAlamofire
import SVProgressHUD

final class HomeViewController: UIViewController{
    
    //MARK: - Properties
    
    var userData: LoginData? = nil
    private var showsList: [Show] = []
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getShowsList(userData: userData)
        self.title = "Shows"
    }

    func getShowsList(userData: LoginData?) {
        
        guard let token = userData?.token else { return }
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
            }.catch { error in
                print("\(error)")
        }
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
        print("Selected Item: \(item)")
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            print("Deleting \(self.showsList[indexPath.row])")

            self.showsList.remove(at: indexPath.row) //TODO: add API call for deleting shows i guess?
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
}

private extension HomeViewController {
    func setupTableView() {
        
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()

        tableView.delegate = self
        tableView.dataSource = self
    }
}
