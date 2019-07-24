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
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Properties
    
    var showId = ""
    var userToken = ""
    private var episodeList: [Episode] = []
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getShowDetailsFor(showId: showId, token: userToken)
        setupTableView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        scrollView.contentInset.top = 280
    }
    
    //MARK: - API calls
    
    private func getShowDetailsFor(showId: String, token: String)
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
            self?.showSortedData(episodeList: episodeList)
        }.catch { error in
                print("\(error)")
        }
    }
}

//MARK: - Additional data handling

private extension ShowDetailsViewController {
    private func showSortedData(episodeList: [Episode]) {
        self.episodeList = episodeList.sorted(by: { (firstEpisode: Episode, secondEpisode: Episode) -> Bool in
            return (Int(firstEpisode.season) ?? 0, Int(firstEpisode.episodeNumber) ?? 0) < (Int(secondEpisode.season) ?? 0, Int(secondEpisode.episodeNumber) ?? 0)
        }) //Is it better to use $0, $1 or fully verbose names like above?
        episodeCountLabel.text = "\(episodeList.count)"
        tableView.reloadData()
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
        //let item = episodeList[indexPath.row]
        //Pass to the next view later on with navigation
    }
}

private extension ShowDetailsViewController {
    
    func setupTableView() {
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - Navigation

private extension ShowDetailsViewController {
    @IBAction func onBackButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddShowButtonPress() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "AddEpisodeViewController") as! AddEpisodeViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        nextViewController.showId = self.showId
        nextViewController.userToken = self.userToken
        nextViewController.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - Custom delegates

extension ShowDetailsViewController: AddEpisodeViewControllerDelegate {
    func showListDidChange(addedEpisode: Episode) {
        episodeList.append(addedEpisode)
        showSortedData(episodeList: episodeList)
    }
}
