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
        
        return cell
    }
    
}

// MARK: - UICollectionView Delegate

extension DashboardSeachViewController: UICollectionViewDelegate {
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
