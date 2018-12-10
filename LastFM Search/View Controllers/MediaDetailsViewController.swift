//
//  MediaDetailsViewController.swift
//  LastFM Search
//
//  Created by Haresh on 11/12/18.
//  Copyright © 2018 Haresh. All rights reserved.
//

import AlamofireImage

class MediaDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var banerImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var exploreMediaButton: UIButton!
    @IBOutlet private weak var listenersLabel: UILabel!
    @IBOutlet private weak var scrobblesLabel: UILabel!
    @IBOutlet private weak var albumWikiLabel: UILabel!
    @IBOutlet private weak var waitViewLabel: UILabel!
    
    // MARK: - Variables
    var album: Album?
    var artist: Artist?
    var song: Song?
    var viewType: MediaType = .all
    
    private var mediaDetails: [String: Any]?
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.waitViewLabel.isHidden = false
        self.setupDetailsView()
    }
    
    // MARK: - Action methods
    @IBAction func exploreMediaTapAction(_ sender: Any) {
        
        guard let urlString = self.getExploreUrl(),
            let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) else {
                return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Private helper methods
    private func setupDetailsView() {
        switch self.viewType {
        case .albums:
            self.title = "Album Info"
            self.exploreMediaButton.setTitle("Explore Album", for: .normal)
            self.fetchAlbumInfo()
            
        case .artists:
            self.title = "Artist Info"
            self.exploreMediaButton.setTitle("Explore Artist", for: .normal)
            self.fetchArtistInfo()
            
        case .songs:
            self.title = "Song Info"
            self.exploreMediaButton.setTitle("Explore Song/Track", for: .normal)
            self.fetchSongInfo()
            
        default:
            self.title = "Media Info Not Found"
        }
    }
    
    private func getExploreUrl() -> String? {
        guard let mediaDetails = self.mediaDetails else { return nil }
        
        var mediaKey = ""
        switch self.viewType {
        case .albums:
            mediaKey = "album"
            
        case .artists:
            mediaKey = "artist"
            
        case .songs:
            mediaKey = "track"
            
        default:
            mediaKey = ""
        }
        
        guard let mediaData = mediaDetails[mediaKey] as? [String: Any],
            let urlString = mediaData["url"] as? String else {
                return nil
        }
        
        return urlString
    }
    
    private func setMediaImage(images: [[String: String]]) {
        let imgItems = images.filter { $0["size"] == "extralarge" }
        guard let imgItem = imgItems.first,
            let urlString = imgItem["#text"],
            let url = URL(string: urlString) else {
                return
        }
        
        self.imageView.af_setImage(withURL: url, imageTransition: .curlDown(0.4))
        self.banerImageView.af_setImage(withURL: url, filter: BlurFilter(blurRadius: 20), imageTransition: .crossDissolve(0.4))
    }
    
    // MARK: - Album setup methods
    private func fetchAlbumInfo() {
        guard let album = self.album else { return }
        
        AlbumSearch.fetchAlbumInfo(for: album, completionHandler: { response in
            guard let response = response else { return }
            
            if response["error"] != nil {
                self.waitViewLabel.text = response["message"] as? String
                return
            } else {
                self.mediaDetails = response
                self.setupAlbumDetails()
                self.waitViewLabel.isHidden = true
            }
        })
    }
    
    private func setupAlbumDetails() {
        guard let albumDetails = self.mediaDetails?["album"] as? [String: Any] else { return }
        
        self.titleLabel.text = albumDetails["name"] as? String
        self.subtitleLabel.text = albumDetails["artist"] as? String
        self.listenersLabel.text = albumDetails["listeners"] as? String
        self.scrobblesLabel.text = albumDetails["playcount"] as? String
        
        if let wiki = albumDetails["wiki"] as? [String: Any] {
            self.albumWikiLabel.text = wiki["content"] as? String
        }
        
        if let images = albumDetails["image"] as? [[String: String]] {
            self.setMediaImage(images: images)
        }
    }
    
    // MARK: - Artist setup methods
    private func fetchArtistInfo() {
        guard let artist = self.artist else { return }
        
        ArtistSearch.fetchArtistInfo(for: artist, completionHandler: { response in
            guard let response = response else { return }
            
            if response["error"] != nil {
                self.waitViewLabel.text = response["message"] as? String
                return
            } else {
                self.mediaDetails = response
                self.setupArtistDetails()
                self.waitViewLabel.isHidden = true
            }
        })
    }
    
    private func setupArtistDetails() {
        guard let artistDetails = self.mediaDetails?["artist"] as? [String: Any] else { return }
        
        self.titleLabel.text = artistDetails["name"] as? String
        
        if let stats = artistDetails["stats"] as? [String: String] {
            self.listenersLabel.text = stats["listeners"]
            self.scrobblesLabel.text = stats["playcount"]
            self.subtitleLabel.text = "\(self.listenersLabel.text ?? "0") Listeners"
        }
        
        if let bio = artistDetails["bio"] as? [String: Any] {
            self.albumWikiLabel.text = bio["content"] as? String
        }
        
        if let images = artistDetails["image"] as? [[String: String]] {
            self.setMediaImage(images: images)
        }
    }
    
    // MARK: - Song setup methods
    private func fetchSongInfo() {
        guard let song = self.song else { return }
        
        SongSearch.fetchSongInfo(for: song, completionHandler: { response in
            guard let response = response else { return }
            
            if response["error"] != nil {
                self.waitViewLabel.text = response["message"] as? String
                return
            } else {
                self.mediaDetails = response
                self.setupSongDetails()
                self.waitViewLabel.isHidden = true
            }
        })
    }
    
    private func setupSongDetails() {
        guard let songDetails = self.mediaDetails?["track"] as? [String: Any] else { return }
        
        self.titleLabel.text = songDetails["name"] as? String
        
        if let album = songDetails["album"] as? [String: Any] {
            self.subtitleLabel.text = album["artist"] as? String
            if let images = album["image"] as? [[String: String]] {
                self.setMediaImage(images: images)
            }
        }
        
        self.listenersLabel.text = songDetails["listeners"] as? String
        self.scrobblesLabel.text = songDetails["playcount"] as? String
        
        if let wiki = songDetails["wiki"] as? [String: Any] {
            self.albumWikiLabel.text = wiki["content"] as? String
        }
        
    }
    
}
