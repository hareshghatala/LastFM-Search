//
//  HeaderCollectionReusableView.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
    }
    
    /// Set header title text
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
}
