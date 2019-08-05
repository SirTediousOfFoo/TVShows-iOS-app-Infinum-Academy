//
//  ListCell.swift
//  TVShows
//
//  Created by Infinum on 03/08/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class ListCell: UICollectionViewCell {
    
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        imageHolder.kf.cancelDownloadTask()
        imageHolder.image = nil
    }
}

extension ListCell {
    func configure(with item: Show) {
        let url = URL(string: "https://api.infinum.academy" + item.imageUrl)
        imageHolder.kf.setImage(with: url)
        titleLabel.text = item.title
    }
}
