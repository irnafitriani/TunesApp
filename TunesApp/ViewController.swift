//
//  ViewController.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var musicControlView: MusicControlView!

  let viewModel: ViewModel
  let minimumSearch = 3
  var audioPlayer: AVAudioPlayer?

  required init?(coder: NSCoder) {
    self.viewModel = ViewModel()
    super.init(coder: coder)
    bindToViewModel()
  }

  private func bindToViewModel() {
    self.viewModel.uiStateHandler = { [weak self] uiState in
      guard let self = self else {
        return
      }
      switch uiState {
      case .loading:
        self.viewModel.fetchData(searchString: "all")
      case .loaded(let element):
        switch  element {
        case .musicList:
          self.tableView.reloadData()
        case .music:
          self.playTrack()
        }
      case .error(let error):
        self.handle(error: error)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.estimatedRowHeight = 80
    self.tableView.rowHeight = UITableView.automaticDimension
    self.musicControlView.isHidden = true
    self.musicControlView.delegate = self
    self.audioPlayer?.delegate = self
    viewModel.initialSetup()
  }

  private func handle(error: ErrorState) {
    let errorMessage = error.localizedDescription
    switch error {
    case .unableToConnect:
      let alert = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
          switch action.style{
              case .default:
              print("default")

              case .cancel:
              print("cancel")

              case .destructive:
              print("destructive")

          @unknown default:
            fatalError()
          }
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.viewModel.musics?.count ?? 0
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell, let data = self.viewModel.musics?[indexPath.row] else {
      return UITableViewCell()
    }
    let isSelected = data.trackId == self.viewModel.musicSelected?.trackId ? true : false
    cell.style(data: data, isSelected: isSelected)

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selected = self.viewModel.musics?[indexPath.row] else {
      return
    }
    self.audioPlayer?.stop()
    self.musicControlView.playPauseButton.isSelected = false
    self.viewModel.musicSelected = selected
    if let _ = self.viewModel.musicSelected {
      self.musicControlView.isHidden = false
    } else {
      self.musicControlView.isHidden = true
    }
  }
}

extension ViewController: UISearchBarDelegate {

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.count > 3 {
      self.audioPlayer?.stop()
      self.musicControlView.isHidden = true
      self.musicControlView.playPauseButton.isSelected = false
      self.viewModel.musicSelected = nil
      self.viewModel.fetchData(searchString: searchText)
    }
  }
}

extension ViewController: AVAudioPlayerDelegate {
  func playTrack() {
    do {
      if let data = self.viewModel.musicData {
        self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.m4a.rawValue)
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
      }
    } catch {
      print(error)
    }
  }

  func pauseTrack() {
    self.audioPlayer?.pause()
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    self.viewModel.musicSelected = nil
    self.musicControlView.isHidden = true
    self.musicControlView.playPauseButton.isSelected = false
    tableView.reloadData()
  }
}

extension ViewController: MusicControlDelegate {
  func play() {
    self.tableView.reloadData()
    if let urlString = self.viewModel.musicSelected?.previewUrl, let url = URL(string: urlString) {
      self.viewModel.getMusic(url: url)
    }
  }

  func pause() {
    self.viewModel.musicSelected = nil
    self.musicControlView.isHidden = true
    self.audioPlayer?.pause()
    self.tableView.reloadData()
  }
}

