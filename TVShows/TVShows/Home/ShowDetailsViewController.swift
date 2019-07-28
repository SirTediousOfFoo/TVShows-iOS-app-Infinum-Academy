//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 20/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import CodableAlamofire
import PromiseKit
import SVProgressHUD

final class ShowDetailsViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet private weak var showImage: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var addEpisodeButton: UIButton!
    
    //MARK: - Properties
    
    var showId = ""
    var userToken = ""
    private var episodeList: [Episode] = []
    private var showDetails: ShowDetails? = nil
    
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
        tableView.contentInset.top = 300
        showImage.image = UIImage(named: "show-image-placeholder")
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
            
            self?.showDetails = showDetails
            
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
        }.catch { [weak self] error in
            self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
        }
    }
}

//MARK: - Animations

//private extension ShowDetailsViewController {
//    //Hopefully this one will add a cool transition into adding episodes
//    func inflateAddEpisodeButton() {
//        let animation = CABasicAnimation(keyPath: "<#T##String?#>")
//    }
//    
//}

//MARK: - Additional data handling

private extension ShowDetailsViewController {
    private func showSortedData(episodeList: [Episode]) {
        self.episodeList = episodeList.sorted()
        tableView.reloadData()
    }
}

//MARK: - TableView functions

extension ShowDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {

            let tableViewCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: EpisodeDetailsCell.self),
                for: indexPath) as! EpisodeDetailsCell
            
            if let showDetails = showDetails {
                tableViewCell.configure(with: showDetails, numOfEpisodes: episodeList.count)
            }
            
            return tableViewCell
        } else {
            let tableViewCell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: EpisodeCell.self),
                for: indexPath) as! EpisodeCell
            
            tableViewCell.configure(with: episodeList[indexPath.row - 1])
            
            return tableViewCell
        }
    }
}

extension ShowDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //let item = episodeList[indexPath.row-1]
        //Pass to the next view later on with navigation
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        } else {
            return 50
        }
    }
}

private extension ShowDetailsViewController {
    
    private func setupTableView() {
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - Navigation

private extension ShowDetailsViewController {
    @IBAction private func onBackButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onAddShowButtonPress() {
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
