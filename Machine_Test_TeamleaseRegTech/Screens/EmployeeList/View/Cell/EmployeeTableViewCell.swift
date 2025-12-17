//
//  EmployeeTableViewCell.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var viewEmployeeData: UIView!
    @IBOutlet weak var labelSerialNumber: UILabel!
    @IBOutlet weak var labelEmployeeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewEmployeeData.layer.cornerRadius = 10
        addShadow(to: viewEmployeeData)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
    }
}
