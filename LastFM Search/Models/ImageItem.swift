//
//  ImageItem.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Foundation

struct ImageItem: Decodable {
    
    let url: URL
    let size: String
    
    enum CodingKeys : String, CodingKey {
        case url = "#text"
        case size = "size"
    }
    
    init(with dictionary: [String: Any]) {
        if let url = URL(string: dictionary["#text"] as? String ?? "") {
            self.url = url
        } else {
            self.url = URL(fileURLWithPath: "")
        }
        self.size = dictionary["size"] as? String ?? ""
    }
}
