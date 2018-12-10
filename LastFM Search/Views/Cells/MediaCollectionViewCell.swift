//
//  MediaCollectionViewCell.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import AlamofireImage

class MediaCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constatnts
    private static let colors = [UIColor(red: 66.0/255.0, green: 66.0/255.0, blue: 66.0/255.0, alpha: 1.0), // Dark Gray
                                 UIColor(red: 255.0/255.0, green: 126.0/255.0, blue: 121.0/255.0, alpha: 1.0), // Light Red
                                 UIColor(red: 0.0/255.0, green: 84.0/255.0, blue: 147.0/255.0, alpha: 1.0), // Blue
                                 UIColor(red: 148.0/255.0, green: 55.0/255.0, blue: 255.0/255.0, alpha: 1.0), // Purple
                                 UIColor(red: 0.0/255.0, green: 144.0/255.0, blue: 81.0/255.0, alpha: 1.0)] // Green
    
    // MARK: - Outlets
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var artworkImageView: UIImageView!
    @IBOutlet private weak var titelLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        self.mainContentView.layer.cornerRadius = 10.0
    }
    
    override func prepareForReuse() {
        self.artworkImageView.af_cancelImageRequest()
        self.artworkImageView.image = nil
        self.artworkImageView.backgroundColor = self.randomBackgroundColor()
        self.titelLabel.text = nil
        self.subtitleLabel.text = nil
    }
    
    // MARK: - Private helper methods
    private func randomBackgroundColor() -> UIColor {
        let selfType = type(of: self)
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<6)
        } while !selfType.colors.indices.contains(randomIndex)
        
        return selfType.colors[randomIndex]
    }
    
    // MARK: - Public methods
    
    /// setup cell details and load image from url
    func setupMediaDetails(with title: String, subtitle: String, imageURL: URL) {
        self.titelLabel.text = title
        self.subtitleLabel.text = subtitle
        
        self.artworkImageView.af_setImage(withURL: imageURL,
                                          imageTransition: .flipFromLeft(0.4))
    }
}
