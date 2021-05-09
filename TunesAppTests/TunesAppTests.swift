//
//  TunesAppTests.swift
//  TunesAppTests
//
//  Created by Irna on 09/05/21.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import TunesApp

class TunesAppTests: XCTestCase {

  let viewModel = ViewModel()
  let timeout : DispatchTimeInterval = .seconds(10)

  override func setUpWithError() throws {
    OHHTTPStubs.isEnabled()
  }

  override func tearDownWithError() throws {
    OHHTTPStubs.removeAllStubs()
  }

  func testFetchData() {
    OHHTTPStubs.shared.prepareStub(path: "https://itunes.apple.com/search?term=all", filePath: "ListMusic")
    waitUntil(timeout: timeout) { done in
      self.viewModel.uiStateHandler = { uiState in
        switch uiState {
        case .loading:
          done()
        case .loaded(.musicList):
          expect(self.viewModel.musics?.count).to(equal(37))
          done()
        case .error(_):
          break
        default:
          break
        }
      }
      self.viewModel.fetchData(searchString: "all")
    }
  }

  func testGetMusic() {
    OHHTTPStubs.shared.prepareStub(path: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview123/v4/2a/e9/d2/2ae9d20a-0266-1e07-e38c-cd492e0caff9/mzaf_1533909818002270392.plus.aac.p.m4a", filePath: "ListMusic")
    waitUntil(timeout: timeout) { done in
      self.viewModel.uiStateHandler = { uiState in
        switch uiState {
        case .loading:
          done()
        case .loaded(.music):
          expect(self.viewModel.musicData).toNot(beNil())
          done()
        case .error(_):
          break
        default:
          break
        }
      }
      if let url = URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview123/v4/2a/e9/d2/2ae9d20a-0266-1e07-e38c-cd492e0caff9/mzaf_1533909818002270392.plus.aac.p.m4a") {
        self.viewModel.getMusic(url: url)
      }
    }
  }
}

extension OHHTTPStubs {

    static let shared = OHHTTPStubs()

    @discardableResult
    func prepareStub(path: String, filePath: String, statusCode: Int32 = 200) -> OHHTTPStubsDescriptor {
        return stub(condition: isPath(path)) { request in
          let data = OHHTTPStubs.getData(fromFileWithName: "ListMusic", bundle: Bundle.main)
            return OHHTTPStubsResponse(data: data, statusCode: statusCode, headers: .none)
        }
    }

  public static func getData(fromFileWithName name: String, bundle: Bundle) -> Data {
    guard let path = bundle.path(forResource: name, ofType: "json") else {
      return Data()
    }
    let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    return data ?? Data()
  }

}
