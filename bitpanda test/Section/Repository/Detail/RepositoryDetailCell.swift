//
//  RepositoryListCell.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

import Strongify
import Kingfisher

internal final class RepositoryDetailCell: UITableViewCell {
    
    fileprivate typealias SelfType = RepositoryDetailCell
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commitsCountLabel: UILabel!
    
    internal func configure(with model: RepositoryDetailCellModelProtocol) {
        self.avatarImageView.kf.setImage(with: model.avatarUrl)
        self.avatarImageView.kf.setImage(
            with: model.avatarUrl
            , completionHandler: strongify(weak: self, closure: { (selfStrong: SelfType, result: Result<RetrieveImageResult, KingfisherError>) in
            selfStrong._validateCircleImage()
        }))
        self.usernameLabel.text = model.username
        self.commitsCountLabel.text = String(model.commits)
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        self._validateCircleImage()
    }
    
    @inline(__always)
    private func _validateCircleImage() {
        let cornerRadius: CGFloat = self.avatarImageView.bounds.height * 0.5
        guard cornerRadius != self.avatarImageView.layer.cornerRadius else {
            return
        }
        self.avatarImageView.layer.cornerRadius = cornerRadius
        self.avatarImageView.clipsToBounds = true
    }
    
}
