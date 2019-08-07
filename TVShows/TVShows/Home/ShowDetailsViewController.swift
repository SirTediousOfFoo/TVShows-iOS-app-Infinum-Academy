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
import RxSwift
import RxCocoa

final class ShowDetailsViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet private weak var showImage: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var addEpisodeButton: UIButton!
    @IBOutlet private weak var viewForAnimation: UIView!

    //MARK: - Properties
    
    var showId = ""
    private var episodeList: [Episode] = []
    private var showDetails: ShowDetails? = nil
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getShowDetailsFor(showId: showId)
        setupTableView()
        subscribeItems()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        
        tableView.contentInset.top = 300
        viewForAnimation.layer.cornerRadius = viewForAnimation.bounds.size.width/2
    }
    
    private func subscribeItems() {
        addEpisodeButton.rx.tap.subscribe({ [weak self] _ in
            self?.onAddShowButtonPress()
        }).disposed(by: disposeBag)
        backButton.rx.tap.subscribe({ [weak self] _ in
            self?.onBackButtonPressed()
        }).disposed(by: disposeBag)
    }
    
    //MARK: - API calls
    
    private func getShowDetailsFor(showId: String) {
        
    guard let token = UserKeychain.keychain[Properties.userToken.rawValue] else {
        showAlert(title: "Session expired", message: "Please log back in")
        return
    }
    
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
        
        let url = URL(string: "https://api.infinum.academy" + showDetails.imageUrl)
        self?.showImage.kf.setImage(with: url)
        
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

private extension ShowDetailsViewController {
    //Hopefully this one will add a cool transition into adding episodes
    func inflateAddEpisodeButton() {
        UIView.animate(
        withDuration: 0.5,
        delay: 0.0,
        options: [.curveEaseOut],
        animations: { [weak self] in
            self?.viewForAnimation.transform = CGAffineTransform(scaleX: 150, y: 150)
        },
        completion: nil)
    }
    
}

//MARK: - Additional data handling

private extension ShowDetailsViewController {
    func showSortedData(episodeList: [Episode]) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row != 0) {
            
            let item = episodeList[indexPath.row-1]
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let episodeViewController = storyboard.instantiateViewController(withIdentifier: "EpisodeDetails") as! EpisodeDetailsViewController
            episodeViewController.episode = item
            if let imageUrl = showDetails?.imageUrl {
                episodeViewController.showImageUrl = "https://api.infinum.academy" + imageUrl
            }
            navigationController?.pushViewController(episodeViewController, animated: true)
        }
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
    private func onBackButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    private func onAddShowButtonPress() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "AddEpisodeViewController") as! AddEpisodeViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        nextViewController.showId = self.showId
        nextViewController.delegate = self
        
        //I like the way this one feels, it's probably very poor in regards of code quality/readability. It looks a little ugly
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: { //is weak self needed here?
                guard
                    let viewForAnimation = self.viewForAnimation,
                    let view = self.view
                    else { return }
                viewForAnimation.isHidden = false
                viewForAnimation.transform = CGAffineTransform(scaleX: 150, y: 150)
                viewForAnimation.center = CGPoint(
                    x: view.center.x,
                    y: view.center.y)
            },
            completion: { [weak self] _ in //is this better than the closure above? the upper one looks much nicer
                self?.present(navigationController, animated: false, completion: {
                    self?.viewForAnimation.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self?.viewForAnimation.center = CGPoint(
                        x: self?.addEpisodeButton.center.x ?? 0,
                        y: self?.addEpisodeButton.center.y ?? 0)
                    self?.viewForAnimation.isHidden = true
                })
        })
    }
}

//MARK: - Custom delegates

extension ShowDetailsViewController: AddEpisodeViewControllerDelegate {
    func showListDidChange(addedEpisode: Episode) {
        episodeList.append(addedEpisode)
        showSortedData(episodeList: episodeList)
    }
}
