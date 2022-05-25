//
//  DateHelperTVC.swift
//  datepicker
//
//  Created by Андрей Королев on 24.05.2022.
//

import UIKit

//Cell of a date helper table

class DateHelperTVC: UITableViewCell {
    
    //MARK: - Elements
    
    var cellLogo: UIImageView = {
        let cl = UIImageView()
        cl.translatesAutoresizingMaskIntoConstraints = false
        cl.image = UIImage(named: "calendarIconDoubleCropped")?.withRenderingMode(.alwaysTemplate)
        cl.tintColor = .systemOrange
        return cl
    }()
    
    var cellText: UILabel = {
        let ct = UILabel()
        ct.translatesAutoresizingMaskIntoConstraints = false
        ct.text = "Сегодня"
        return ct
    }()
    
    var dateText: UILabel = {
        let dt = UILabel()
        dt.translatesAutoresizingMaskIntoConstraints = false
        dt.text = "Ср"
        dt.textColor = UIColor(rgb: 0x7C89A3)
        return dt
    }()
    
    //MARK: - Setup elements

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupElements()
        
        constrainElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupElements() {
        addSubview(cellLogo)
        addSubview(cellText)
        addSubview(dateText)
        
        resizeLogo()
    }
    
    //MARK: - Scale & Constrain
    
    private func constrainElements() {
        //center by Y
        NSLayoutConstraint.activate([
            cellLogo.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellText.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateText.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        //space by X
        NSLayoutConstraint.activate([
            cellLogo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellText.leadingAnchor.constraint(equalTo: cellLogo.trailingAnchor, constant: 10),
            dateText.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func resizeLogo() {
        NSLayoutConstraint.activate([
            cellLogo.heightAnchor.constraint(equalToConstant: 25),
            cellLogo.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        cellLogo.contentMode = .scaleToFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
