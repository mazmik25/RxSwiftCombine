//
//  UIImageView+Extension.swift
//  RxSwiftCombine
//
//  Created by Azmi Muhammad on 28/11/20.
//

import UIKit
extension UIImageView {
  func imageFromUrl(url: URL?) {
    if let url: URL = url {
      URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
        guard let data = data, error == nil else {
          print(error ?? NetworkError.urlNotFound)
          return
        }
        DispatchQueue.main.async() { [weak self] in
          self?.image = UIImage(data: data)
        }
      }).resume()
    }
  }
    
  func loadPoster(path: String?) {
    let posterPath: String = "https://image.tmdb.org/t/p/w500\(path ?? "")"
    imageFromUrl(url: URL(string: posterPath))
  }
}
