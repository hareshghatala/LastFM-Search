//
//  ArtistSearch.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Alamofire

class ArtistSearch {
    
    // MARK: - Properties
    var currentpage = 1
    var searchKeyword: String
    var dataRequest: DataRequest?
    
    // MARK: - Init methods
    init(with keyword: String = "A") {
        self.searchKeyword = keyword
    }
    
    // MARK: - Public Methods
    func searchArtist(with keyword: String? = nil,
                      nextPageSearch: Bool = false,
                      completionHandler: @escaping ([Artist]?) -> Void) {
        
        if self.dataRequest != nil {
            self.dataRequest?.cancel()
        }
        
        self.searchKeyword = keyword ?? self.searchKeyword
        self.currentpage = nextPageSearch ? self.currentpage + 1 : 1
        
        let params: Parameters = [ParameterKeys.methodKey: ParameterValues.artistSearchMethod,
                                  ParameterKeys.api_keyKey: ParameterValues.apiKey,
                                  ParameterKeys.formatKey: ParameterValues.responseFormat,
                                  ParameterKeys.limitKey: ParameterValues.itemsPerPage,
                                  ParameterKeys.pageKey: self.currentpage,
                                  ParameterKeys.artistKey: self.searchKeyword]
        
        self.dataRequest = NetworkServices.shared.fetchMediaDetails(with: params, completionHandler: { response, error in
            
            guard let response = response,
                let results = response["results"] as? [String: Any],
                let artistMatches = results["artistmatches"] as? [String: Any],
                let artistArray = artistMatches["artist"] as? [[String: Any]],
                let artistData = try? JSONSerialization.data(withJSONObject: artistArray, options: []) else {
                    return
            }
            
            guard let artistList = try? JSONDecoder().decode([Artist].self, from: artistData) else {
                var artists: [Artist] = []
                for item in artistArray {
                    artists.append(Artist(with: item))
                }
                completionHandler(artists.isEmpty ? nil : artists)
                return
            }
            
            completionHandler(artistList)
        })
    }
    
    // MARK: - Static methods
    static func fetchArtistInfo(for artist: Artist,
                                completionHandler: @escaping ([String: Any]?) -> Void) {
        
        var params: Parameters = [ParameterKeys.methodKey: ParameterValues.artistGetinfoMethod,
                                  ParameterKeys.api_keyKey: ParameterValues.apiKey,
                                  ParameterKeys.formatKey: ParameterValues.responseFormat]
        
        if let mbidValue = artist.mbid {
            params[ParameterKeys.mbidKey] = mbidValue
        } else {
            params[ParameterKeys.artistKey] = artist.name
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
