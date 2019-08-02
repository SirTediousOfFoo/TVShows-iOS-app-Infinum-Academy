//
//  TVShowCell.swift
//  TVShows
//
//  Created by Infinum on 19/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

final class TVShowCell: UITableViewCell{
    
    //MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageHolder: UIImageView!
    
    // MARK: - Lifecycle functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageHolder.image = nil
        titleLabel.text = nil
    }
}

// MARK: - Configure

extension TVShowCell {
    func configure(with item: Show) {
        let url = URL(string: "https://api.infinum.academy" + item.imageUrl)
        imageHolder.kf.setImage(with: url)
        titleLabel.text = item.title
    }
}

// MARK: - Private extension

private extension TVShowCell {
    func setupUI() {
        imageHolder.layer.cornerRadius = 20
    }
}
