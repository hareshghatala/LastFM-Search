//
//  Song.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Foundation

struct Song: Decodable {
    
    // MARK: - Properties
    let name: String
    let artist: String
    let songUrl: URL
    let images: [ImageItem]
    let mbid: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case artist = "artist"
        case songUrl = "url"
        case images = "image"
        case mbid = "mbid"
    }
    
    // MARK: - Init methods
    init(with dictionary: [String: Any]) {
        
        self.name = dictionary["nama"] as? String ?? ""
        self.artist = dictionary["artist"] as? String ?? ""
        
        if let url = URL(string: dictionary["url"] as? String ?? "") {
            self.songUrl = url
        } else {
            self.songUrl = URL(fileURLWithPath: "")
        }
        
        if let imgItems = dictionary["image"] as? [[String: Any]] {
            var imgs: [ImageItem] = []
            for imgItem in imgItems {
                imgs.append(ImageItem(with: imgItem))
            }
            self.images = imgs
        } else {
            self.images = []
        }
        
        self.mbid = dictionary["mbid"] as? String
    }
    
    // MARK: - Public methods
    func imageURL() -> URL {
        let imageItem = self.images.filter { $0.size == "extralarge" }
        return imageItem.first!.url
    }
}

