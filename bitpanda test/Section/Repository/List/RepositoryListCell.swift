//
//  RepositoryListCell.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

internal final class RepositoryListCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    internal func configure(with model: RepositoryListCellModelProtocol) {
        self.nameLabel.text = model.name
        self.fullNameLabel.text = model.fullName
        self.ownerNameLabel.text = model.ownerName
        self.starsLabel.text = String(model.starsCount)
    }
    
    
}
