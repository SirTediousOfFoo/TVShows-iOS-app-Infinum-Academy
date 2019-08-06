//
//  EpisodeDetailsViewController.swift
//  TVShows
//
//  Created by Infinum on 31/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit
import CodableAlamofire
import PromiseKit
import Kingfisher
import KeychainAccess
import SVProgressHUD
import RxSwift
import RxCocoa

final class EpisodeDetailsViewController: UIViewController {

    //MARK: - Properties
    
    var episode: Episode?
    var showImageUrl: String = ""
    private let disposeBag = DisposeBag()
    
    //MARK: - Outlets
    
    @IBOutlet private weak var episodeTitleLabel: UILabel!
    @IBOutlet private weak var seasonEpisodeIndicatorLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var episodeImage: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!

    //MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showEpisodeDetails()
        subscribeItems()
    }
    
    private func subscribeItems() {
        backButton.rx.tap.subscribe({ [weak self] _ in
            self?.navigateBack()
        }).disposed(by: disposeBag)
        commentsButton.rx.tap.subscribe({ [weak self] _ in
            self?.navigateToComments()
        }).disposed(by: disposeBag)
    }
    
    private func showEpisodeDetails() //No need to even do API call here since all data shown is already loaded
    {
        guard let episode = episode else {
            showAlert(title: "Error", message: "Episode details are missing")
            return
        }
        
        descriptionLabel.text = episode.description
        episodeTitleLabel.text = episode.title
        seasonEpisodeIndicatorLabel.text = "S\(episode.season) E\(episode.episodeNumber)"
        
        if !episode.imageUrl.isEmpty {
            let url = URL(string: "https://api.infinum.academy" + episode.imageUrl)
            episodeImage.kf.setImage(with: url)
        }
        else if !showImageUrl.isEmpty {
            let url = URL(string: showImageUrl)
            episodeImage.kf.setImage(with: url)
        }
        else {
            episodeImage.image = UIImage(named: "ic-placeholder")
        }
    }
    
    // MARK: - Navigation

    private func navigateToComments() {
        guard let episodeId = episode?.id else {
            showAlert(title: "Error", message: "Couldn't get episode ID")
            return
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let commentsViewController = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsViewController.episodeId = episodeId
        present(commentsViewController, animated: true, completion: nil)
    }
    
    private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
}
