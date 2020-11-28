//
//  MovieCell.swift
//  RxSwiftCombine
//
//  Created by Azmi Muhammad on 28/11/20.
//

import UIKit

class MovieCell: UITableViewCell {

  @IBOutlet weak var movieBannerImageView: UIImageView!
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var movieDescriptionLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
