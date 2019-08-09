//
//  EpisodeDetailsViperWireframe.swift
//  TVShows
//
//  Created by Infinum on 06/08/2019.
//  Copyright (c) 2019 Infinum Academy. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import SVProgressHUD

final class EpisodeDetailsViperWireframe: BaseWireframe {

    // MARK: - Private properties -

    private let storyboard = UIStoryboard(name: "EpisodeDetailsViper", bundle: nil)
    var episode: Episode?
    var showImageUrl: String = ""
    
    // MARK: - Module setup -

    init() {
        let moduleViewController = storyboard.instantiateViewController(ofType: EpisodeDetailsViperViewController.self)
        super.init(viewController: moduleViewController)
        
        episode = moduleViewController.episode
        showImageUrl = moduleViewController.showImageUrl
        
        let interactor = EpisodeDetailsViperInteractor()
        let presenter = EpisodeDetailsViperPresenter(
            view: moduleViewController,
            interactor: interactor,
            wireframe: self)
        moduleViewController.presenter = presenter
    }

}
// MARK: - Extensions -

extension EpisodeDetailsViperWireframe: EpisodeDetailsViperWireframeInterface {
    
    func toComments() {
        
        guard let episodeId = episode?.id else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let commentsViewController = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsViewController.episodeId = episodeId
        
        navigationController?.present(commentsViewController, animated: true, completion: nil)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func showLoading() {
        SVProgressHUD.show()
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
    func show(error: Error) {
        let alertController = UIAlertController.init(
            title: "Error",
            message: "\(error)",
            preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction.init(
                title: "OK",
                style: .default,
                handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    
}