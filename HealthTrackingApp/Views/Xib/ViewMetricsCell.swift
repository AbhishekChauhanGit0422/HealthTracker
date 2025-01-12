//
//  ViewMetricsCell.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//

import UIKit

class ViewMetricsCell: UITableViewCell {
    
    static let reusableIdentifier = "ViewMetricsCell"

    @IBOutlet weak var metricImageView: UIImageView!
    @IBOutlet weak var metricName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
