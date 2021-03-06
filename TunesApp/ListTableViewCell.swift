//
//  ListTableViewCell.swift
//  TunesApp
//
//  Created by Irna on 09/05/21.
//

import UIKit

class ListTableViewCell: UITableViewCell {
  @IBOutlet private weak var artworkImage: UIImageView!
  @IBOutlet private weak var songNameLabel: UILabel!
  @IBOutlet private weak var artistNameLabel: UILabel!
  @IBOutlet private weak var albumNameLabel: UILabel!
  @IBOutlet private weak var equilizerImage: UIImageView!

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

  func style(data: Music, isSelected: Bool) {
    self.artistNameLabel.text = data.artistName
    self.songNameLabel.text = data.trackName
    self.albumNameLabel.text = data.collectionName
    self.artworkImage.load(url: URL(string: data.artworkUrl100 ?? "") ?? URL(fileURLWithPath: ""))
    self.equilizerImage.image = UIImage.gifImageWithName("YdBO")
    if isSelected {
      self.equilizerImage.isHidden = false
    } else {
      self.equilizerImage.isHidden = true
    }
  }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension UIImage {
  public class func gifImageWithData(_ data: Data) -> UIImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
      print("image doesn't exist")
      return nil
    }

    return UIImage.animatedImageWithSource(source)
  }

  public class func gifImageWithName(_ name: String) -> UIImage? {
   guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
    print("SwiftGif: This image named \"\(name)\" does not exist")
    return nil
   }
   guard let imageData = try? Data(contentsOf: bundleURL) else {
     print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
     return nil
   }

   return gifImageWithData(imageData)
  }

  class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
    var a = a
    var b = b
    if b == nil || a == nil {
        if b != nil {
            return b!
        } else if a != nil {
            return a!
        } else {
            return 0
        }
    }

    if a ?? 0 < b ?? 0 {
        let c = a
        a = b
        b = c
    }

    var rest: Int
    while true {
        rest = a! % b!

        if rest == 0 {
            return b!
        } else {
            a = b
            b = rest
        }
    }
  }

  class func gcdForArray(_ array: Array<Int>) -> Int {
   if array.isEmpty {
       return 1
   }

   var gcd = array[0]

   for val in array {
       gcd = UIImage.gcdForPair(val, gcd)
   }

   return gcd
 }

  class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
    var delay = 0.1

    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    let gifProperties: CFDictionary = unsafeBitCast(
        CFDictionaryGetValue(cfProperties,
            Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
        to: CFDictionary.self)

    var delayObject: AnyObject = unsafeBitCast(
        CFDictionaryGetValue(gifProperties,
            Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
        to: AnyObject.self)
    if delayObject.doubleValue == 0 {
        delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
            Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
    }

    delay = delayObject as! Double

    if delay < 0.1 {
        delay = 0.1
    }

    return delay
  }

  class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
    let count = CGImageSourceGetCount(source)
    var images = [CGImage]()
    var delays = [Int]()

    for i in 0..<count {
        if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
            images.append(image)
        }

        let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
            source: source)
        delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
    }

    let duration: Int = {
        var sum = 0

        for val: Int in delays {
            sum += val
        }

        return sum
    }()

    let gcd = gcdForArray(delays)
    var frames = [UIImage]()

    var frame: UIImage
    var frameCount: Int
    for i in 0..<count {
        frame = UIImage(cgImage: images[Int(i)])
        frameCount = Int(delays[Int(i)] / gcd)

        for _ in 0..<frameCount {
            frames.append(frame)
        }
    }

    let animation = UIImage.animatedImage(with: frames,
        duration: Double(duration) / 1000.0)

    return animation
  }
}
