//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 20/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD

class ShowDetailsViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var episodeCountLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addEpisodeButton: UIButton!
    
    //MARK: - Properties
    
    var showId = ""
    var userToken = ""
    private var episodeList: [Episode] = []
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getShowDetailsFor(showId: showId, token: userToken)
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getShowDetailsFor(showId: String, token: String)
    {
        let headers = ["Authorization": token]
        
        firstly {
            APIManager.request(
                ShowDetails.self,
                path: "https://api.infinum.academy/api/shows/\(showId)",
                method: .get,
                parameters: nil,
                keyPath: "data",
                encoding: JSONEncoding.default,
                decoder: JSONDecoder(),
                headers: headers)
        }.then { [weak self] showDetails -> Promise<[Episode]> in
            
            self?.showTitleLabel.text = showDetails.title
            self?.showDescriptionLabel.text = showDetails.description
            
            return APIManager.request(
                [Episode].self,
                path: "https://api.infinum.academy/api/shows/\(showId)/episodes",
                method: .get,
                parameters: nil,
                keyPath: "data",
                encoding: JSONEncoding.default,
                decoder: JSONDecoder(),
                headers: headers)
        }.ensure {
            SVProgressHUD.dismiss()
        }.done { [weak self] episodeList in
            self?.episodeList = episodeList.sorted(by: { (firstEpisode: Episode, secondEpisode: Episode) -> Bool in
                return (Int(firstEpisode.season) ?? 0, Int(firstEpisode.episodeNumber) ?? 0) < (Int(secondEpisode.season) ?? 0, Int(secondEpisode.episodeNumber) ?? 0)
            })
            self?.episodeCountLabel.text = "\(episodeList.count)" 
            self?.tableView.reloadData()
        }.catch { error in
                print("\(error)")
        }
    }
}

//MARK: - TableView functions

extension ShowDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: EpisodeCell.self),
            for: indexPath) as! EpisodeCell
        
        tableViewCell.configure(with: episodeList[indexPath.row])
        
        return tableViewCell
    }
}

extension ShowDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = episodeList[indexPath.row]
        //Pass to the next view later on with navigation
    }
}

private extension ShowDetailsViewController {
    func setupTableView() {
        tableView.estimatedRowHeight = 50
        //tableView.rowHeight = UITableView.automaticDimension
        
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - Navigation


