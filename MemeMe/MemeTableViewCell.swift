//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Amal Alqadhibi on 12/04/2019.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var memeLabel: UILabel!
    @IBOutlet weak var memeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
