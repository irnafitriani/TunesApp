//
//  ViewModel.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import Foundation
enum ErrorState: Error {
  case unableToConnect
}

enum UIState {
  case loading
  case loaded(UIElement)
  case error(ErrorState)
}

enum UIElement {
  case musicList
  case music
}

class ViewModel {
  var uiStateHandler: ((UIState) -> Void)?
  var musics: [Music]?
  var musicSelected: Music?
  var musicData: Data?

  func initialSetup() {
    self.uiStateHandler?(.loading)
  }

  func fetchData(searchString: String) {
    FetchRequest.fetchData(seacrh: searchString) { [ weak self] result in
      switch result {
      case .success(let data):
        let list = try? JSONDecoder().decode(List.self, from: data)
        self?.musics = list?.results.filter { $0.kind == "song"}
        DispatchQueue.main.async {
          self?.uiStateHandler?(.loaded(.musicList))
        }
      case .failure(_):
        self?.uiStateHandler?(.error(.unableToConnect))
      }
    }
  }

  func getMusic(url: URL) {
    FetchRequest.getMusic(url: url) { [ weak self] result in
      switch result {
      case .success(let data):
        self?.musicData = data
        self?.uiStateHandler?(.loaded(.music))
      case .failure(_):
        self?.uiStateHandler?(.error(.unableToConnect))
      }
    }
  }
}
