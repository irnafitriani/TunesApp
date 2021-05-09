//
//  FetchRequest.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import Foundation

enum Result<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
}

enum ServiceError: Error {
    case networkFailure(Error)
    case invalidData
}

struct FetchRequest {
  static func fetchData(seacrh:String, completion: @escaping (Result<Data, Error>) -> Void) {
    let searchParam = seacrh.replacingOccurrences(of: " ", with: "+")
    guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchParam)") else {
      return
    }
    let task = URLSession.shared.dataTask(with: url) { result in
        switch result {
        case .success(let data):
          if let data = data {
            completion(.success(data))
          } else{
            completion(.failure(ServiceError.invalidData))
          }
        case .failure(let error):
          completion(.failure(error))
        }
    }

    task.resume()
  }

  static func getMusic(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { result in
        switch result {
        case .success(let data):
          if let data = data {
            completion(.success(data))
          } else{
            completion(.failure(ServiceError.invalidData))
          }
        case .failure(let error):
          completion(.failure(error))
        }
    }

    task.resume()
  }
}

extension URLSession {
  typealias DataTaskResult = Result<Data?, Error>

    func dataTask( with url: URL, handler: @escaping (DataTaskResult) -> Void) -> URLSessionDataTask {
        dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success((data)))
            }
        }
    }
}

