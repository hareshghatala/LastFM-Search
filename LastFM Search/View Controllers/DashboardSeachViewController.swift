//
//  DashboardSeachViewController.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import Alamofire

enum MediaType {
    case all
    case albums
    case artists
    case songs
}

class DashboardSeachViewController: UIViewController {
    
    // MARK: - Constatnts
    private static let collectionViewCellSpace: CGFloat = 10.0
    private static let collectionViewCellPerRowiPhone: CGFloat = 2.0
    private static let collectionViewCellMarginColumniPhone: CGFloat = 3.0
    private static let collectionViewCellPerRowiPad: CGFloat = 3.0
    private static let collectionViewCellMarginColumniPad: CGFloat = 4.0
    private static let albumsKey = "Albums"
    private static let artistsKey = "Artists"
    private static let songsKey = "Songs"
    private static let headerReuseIdentifier = "HeaderCollectionReusableView"
    private static let cellReuseIdentifier = "MediaCollectionViewCell"
    
    // MARK: - Outlets
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
    @IBOutlet private weak var waitViewLabel: UILabel!
    
    // MARK: - Variables
    private var mediaItems: [String: [Any]] = [:]
    private var selectedMediaIndex: MediaType = .all
    private let album = AlbumSearch()
    private let artist = ArtistSearch()
    private let song = SongSearch()
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.setupView()
    }
    
    // MARK: - Private helper methods
    private func setupView() {
        self.waitViewLabel.isHidden = false
        self.mediaItems[type(of: self).albumsKey] = []
        self.mediaItems[type(of: self).artistsKey] = []
        self.mediaItems[type(of: self).songsKey] = []
        self.searchMedia()
    }
    
    private func searchMedia(with keyword: String? = nil, nextPageSearch: Bool = false) {
        self.searchAlbumsMedia(with: keyword, nextPageSearch: nextPageSearch)
        self.searchArtistsMedia(with: keyword, nextPageSearch: nextPageSearch)
        self.searchSongsMedia(with: keyword, nextPageSearch: nextPageSearch)
    }
    
    private func searchAlbumsMedia(with keyword: String?, nextPageSearch: Bool = false) {
        self.album.searchAlbums(with: keyword, nextPageSearch: nextPageSearch, completionHandler: { albumList in
            guard let albumList = albumList else { return }
            if nextPageSearch {
                self.mediaItems[type(of: self).albumsKey]?.append(contentsOf: albumList)
            } else {
                self.mediaItems[type(of: self).albumsKey] = albumList
            }
            self.collectionView.reloadData()
            self.waitViewLabel.isHidden = true
        })
    }
    
    private func searchArtistsMedia(with keyword: String?, nextPageSearch: Bool = false) {
        self.artist.searchArtist(with: keyword, nextPageSearch: nextPageSearch, completionHandler: { artistList in
            guard let artistList = artistList else { return }
            if nextPageSearch {
                self.mediaItems[type(of: self).artistsKey]?.append(contentsOf: artistList)
            } else {
                self.mediaItems[type(of: self).artistsKey] = artistList
            }
            self.collectionView.reloadData()
            self.waitViewLabel.isHidden = true
        })
    }
    
    private func searchSongsMedia(with keyword: String?, nextPageSearch: Bool = false) {
        self.song.searchSong(with: keyword, nextPageSearch: nextPageSearch, completionHandler: { songList in
            guard let songList = songList else { return }
            if nextPageSearch {
                self.mediaItems[type(of: self).songsKey]?.append(contentsOf: songList)
            } else {
                self.mediaItems[type(of: self).songsKey] = songList
            }
            self.collectionView.reloadData()
            self.waitViewLabel.isHidden = true
        })
    }
    
    fileprivate func sizeForCollectionViewItem() -> CGSize {
        let viewWidth = self.collectionView.bounds.size.width
        
        let selfType = type(of: self)
        var cellWidth: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .phone {
            let margin = selfType.collectionViewCellMarginColumniPhone * selfType.collectionViewCellSpace
            cellWidth = (viewWidth - margin) / selfType.collectionViewCellPerRowiPhone
        } else {
            let margin = selfType.collectionViewCellMarginColumniPad * selfType.collectionViewCellSpace
            cellWidth = (viewWidth - margin) / selfType.collectionViewCellPerRowiPad
        }
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

// MARK: - UISearchBar Delegate

extension DashboardSeachViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchMedia(with: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        switch selectedScope {
        case 0:
            self.selectedMediaIndex = .all
            
        case 1:
            self.selectedMediaIndex = .albums
            
        case 2:
            self.selectedMediaIndex = .artists
            
        case 3:
            self.selectedMediaIndex = .songs
            
        default:
            self.selectedMediaIndex = .all
        }
        self.collectionView.setContentOffset(CGPoint.zero, animated: true)
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.performEndSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.performEndSearch()
    }
    
    private func performEndSearch() {
        self.searchBar.showsCancelButton = false
        guard let searchText = self.searchBar.text else {
            return
        }
        self.searchBar.endEditing(true)
        self.searchMedia(with: searchText)
    }
}

// MARK: - UICollectionView DataSource

extension DashboardSeachViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.selectedMediaIndex {
        case .all:
            return self.mediaItems.count
        case .albums,
             .artists,
             .songs:
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let selfType = type(of: self)
        
        switch (self.selectedMediaIndex, section) {
        case (.all, 0),
             (.albums, 0):
            return self.mediaItems[selfType.albumsKey]?.count ?? 0
            
        case (.all, 1),
             (.artists, 0):
            return self.mediaItems[selfType.artistsKey]?.count ?? 0
            
        case (.all, 2),
             (.songs, 0):
            return self.mediaItems[selfType.songsKey]?.count ?? 0
            
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let selfType = type(of: self)
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: selfType.headerReuseIdentifier,
                                                                                   for: indexPath) as? HeaderCollectionReusableView else {
                                                                                    return UICollectionReusableView()
            }
            
            var titleText: String
            switch (self.selectedMediaIndex, indexPath.section) {
            case (.all, 0),
                 (.albums, 0):
                titleText = selfType.albumsKey
                
            case (.all, 1),
                 (.artists, 0):
                titleText = selfType.artistsKey
                
            case (.all, 2),
                 (.songs, 0):
                titleText = selfType.songsKey
                
            default:
                titleText = ""
            }
            
            headerView.setTitle(title: titleText)
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selfType = type(of: self)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selfType.cellReuseIdentifier, for: indexPath) as? MediaCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var title: String
        var subtitle: String
        var imageUrl: URL
        switch (self.selectedMediaIndex, indexPath.section) {
        case (.all, 0),
             (.albums, 0):
            guard let albumItem = self.mediaItems[selfType.albumsKey]?[indexPath.row] as? Album else {
                return cell
            }
            title = albumItem.name
            subtitle = albumItem.artist
            imageUrl = albumItem.imageURL()
            
        case (.all, 1),
             (.artists, 0):
            guard let artistsItem = self.mediaItems[selfType.artistsKey]?[indexPath.row] as? Artist else {
                return cell
            }
            title = artistsItem.name
            subtitle = artistsItem.listenersString()
            imageUrl = artistsItem.imageURL()
            
        case (.all, 2),
             (.songs, 0):
            guard let songItem = self.mediaItems[selfType.songsKey]?[indexPath.row] as? Song else {
                return cell
            }
            title = songItem.name
            subtitle = songItem.artist
            imageUrl = songItem.imageURL()
            
        default:
            title = ""
            subtitle = ""
            imageUrl = URL(fileURLWithPath: "")
        }
        
        cell.setupMediaDetails(with: title, subtitle: subtitle, imageURL: imageUrl)
        
        return cell
    }
    
}

// MARK: - UICollectionView Delegate

extension DashboardSeachViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let selfType = type(of: self)
        switch self.selectedMediaIndex {
        case .albums:
            guard let mediaCount = self.mediaItems[selfType.albumsKey]?.count,
                indexPath.row == mediaCount - 1,
                let searchText = self.searchBar.text else {
                    return
            }
            self.searchAlbumsMedia(with: searchText, nextPageSearch: true)
            
        case .artists:
            guard let mediaCount = self.mediaItems[selfType.artistsKey]?.count,
                indexPath.row == mediaCount - 1,
                let searchText = self.searchBar.text else {
                    return
            }
            self.searchArtistsMedia(with: searchText, nextPageSearch: true)
            
        case .songs:
            guard let mediaCount = self.mediaItems[selfType.songsKey]?.count,
                indexPath.row == mediaCount - 1,
                let searchText = self.searchBar.text else {
                    return
            }
            self.searchSongsMedia(with: searchText, nextPageSearch: true)
            
        default:
            return
        }
    }
}

// MARK: - UICollectionView Delegate FlowLayout

extension DashboardSeachViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCollectionViewItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let selfType = type(of: self)
        var height: CGFloat = 40.0
        switch (self.selectedMediaIndex, section) {
        case (.all, 0),
             (.albums, 0):
            height = self.mediaItems[selfType.albumsKey]?.count == 0 ? 0.0 : height
            
        case (.all, 1),
             (.artists, 0):
            height = self.mediaItems[selfType.artistsKey]?.count == 0 ? 0.0 : height
            
        case (.all, 2),
             (.songs, 0):
            height = self.mediaItems[selfType.songsKey]?.count == 0 ? 0.0 : height
            
        default:
            height = 0.0
        }
        
        return CGSize(width: self.collectionView.bounds.width, height: height)
    }
    
}
