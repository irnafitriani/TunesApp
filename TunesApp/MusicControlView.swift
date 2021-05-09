//
//  MusicControlView.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import UIKit

protocol MusicControlDelegate: class {
  func play()
  func pause()
}


class MusicControlView: UIView {
  @IBOutlet weak var playPauseButton: UIButton!
  weak var delegate: MusicControlDelegate?

  @IBAction private func play() {
    if playPauseButton.isSelected {
      self.playPauseButton.isSelected = false
      self.delegate?.pause()
    } else {
      self.playPauseButton.isSelected = true
      self.delegate?.play()
    }
  }

}
