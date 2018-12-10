//
//  Artist.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Foundation

struct Artist: Decodable {
    
    // MARK: - Properties
    let name: String
    let listeners: String
    let artistUrl: URL
    let images: [ImageItem]
    let mbid: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case listeners = "listeners"
        case artistUrl = "url"
        case images = "image"
        case mbid = "mbid"
    }
    
    // MARK: - Init methods
    init(with dictionary: [String: Any]) {
        
        self.name = dictionary["nama"] as? String ?? ""
        self.listeners = dictionary["listeners"] as? String ?? ""
        
        if let url = URL(string: dictionary["url"] as? String ?? "") {
            self.artistUrl = url
        } else {
            self.artistUrl = URL(fileURLWithPath: "")
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
    func listenersString() -> String {
        return "\(self.listeners) Listeners"
    }
    
    func imageURL() -> URL {
        let imageItem = self.images.filter { $0.size == "extralarge" }
        return imageItem.first!.url
    }
}
