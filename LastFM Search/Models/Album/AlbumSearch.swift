//
//  AlbumSearch.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Alamofire

class AlbumSearch {
    
    // MARK: - Properties
    var currentpage = 1
    var searchKeyword: String
    var dataRequest: DataRequest?
    
    // MARK: - Init methods
    init(with keyword: String = "A") {
        self.searchKeyword = keyword
    }
    
    // MARK: - Public Methods
    func searchAlbums(with keyword: String? = nil,
                      nextPageSearch: Bool = false,
                      completionHandler: @escaping ([Album]?) -> Void) {
        
        if self.dataRequest != nil {
            self.dataRequest?.cancel()
        }
        
        self.searchKeyword = keyword ?? self.searchKeyword
        self.currentpage = nextPageSearch ? self.currentpage + 1 : self.currentpage
        
        let params: Parameters = [ParameterKeys.methodKey: ParameterValues.albumSearchMethod,
                                  ParameterKeys.api_keyKey: ParameterValues.apiKey,
                                  ParameterKeys.formatKey: ParameterValues.responseFormat,
                                  ParameterKeys.limitKey: ParameterValues.itemsPerPage,
                                  ParameterKeys.pageKey: self.currentpage,
                                  ParameterKeys.albumKey: self.searchKeyword]
        
        self.dataRequest = NetworkServices.shared.fetchMediaDetails(with: params, completionHandler: { response, error in
            
            guard let response = response,
                let results = response["results"] as? [String: Any],
                let albumMatches = results["albummatches"] as? [String: Any],
                let albumArray = albumMatches["album"] as? [[String: Any]],
                let albumData = try? JSONSerialization.data(withJSONObject: albumArray, options: []) else {
                    return
            }
            
            guard let albumList = try? JSONDecoder().decode([Album].self, from: albumData) else {
                var albums: [Album] = []
                for item in albumArray {
                    albums.append(Album(with: item))
                }
                completionHandler(albums.isEmpty ? nil : albums)
                return
            }
            
            completionHandler(albumList)
        })
    }
    
    // MARK: - Static methods
    static func fetchAlbumInfo(for album: Album,
                               completionHandler: @escaping ([String: Any]?) -> Void) {
        
        var params: Parameters = [ParameterKeys.methodKey: ParameterValues.albumGetinfoMethod,
                                  ParameterKeys.api_keyKey: ParameterValues.apiKey,
                                  ParameterKeys.formatKey: ParameterValues.responseFormat]
        
        if let mbidValue = album.mbid {
            params[ParameterKeys.mbidKey] = mbidValue
        } else {
            params[ParameterKeys.albumKey] = album.name
            params[ParameterKeys.artistKey] = album.artist
            params[ParameterKeys.autocorrectKey] = ParameterValues.autocorrect
        }
        
        _ = NetworkServices.shared.fetchMediaDetails(with: params, completionHandler: { response, error in
            
            guard let response = response else {
                completionHandler(nil)
                return
            }
            
            completionHandler(response)
        })
    }
}
