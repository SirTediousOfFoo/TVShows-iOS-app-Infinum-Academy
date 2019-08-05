//
//  ListCell.swift
//  TVShows
//
//  Created by Infinum on 03/08/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import UIKit

class ListCell: UICollectionViewCell {
    
//    let imgView : UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "ic-placeholder")
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    let titleLabel : UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        imageHolder.layer.cornerRadius = 20
//
//       // setUpViews()
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
//    func setUpViews() {
//        addSubview(imgView)
//        addSubview(titleLabel)
//        imgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
//        imgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
//        imgView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
//        imgView.widthAnchor.constraint(equalToConstant: frame.height).isActive = true
//
//        titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 8).isActive = true
//        titleLabel.topAnchor.constraint(equalTo: imgView.topAnchor, constant: 4).isActive = true
//        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        titleLabel.textAlignment = NSTextAlignment.center
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
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
