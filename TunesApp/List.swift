//
//  List.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import Foundation
public final class List: Codable {
    let resultCount: Int
    let results: [Music]

  enum CodingKeys: String, CodingKey {
    case resultCount
    case results
  }
}

public final class Music: Codable {
  let wrapperType: String?
  let artistName: String?
  let collectionName, collectionCensoredName: String?
  let artworkUrl60, artworkUrl100: String?
  let previewUrl: String?
  let kind: String?
  let trackId: Int?
  let trackName, trackCensoredName: String?
  let trackViewUrl: String?

  enum CodingKeys: String, CodingKey {
    case wrapperType
    case artistName, collectionName, collectionCensoredName
    case artworkUrl60, artworkUrl100
    case previewUrl
    case trackViewUrl
    case kind
    case trackId
    case trackName, trackCensoredName
  }
}
