//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 17.2.25..
//
import UIKit

final class FiltersCell: UITableViewCell {
    static let identifier = "FiltersCell"
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CategoryCheckmark")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    let separatorImageView: UIView = {
        let separator = UIView()
        separator.backgroundColor = .ypGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel?.textColor = .ypBlack
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel?.textColor = .ypGray
        selectionStyle = .none
        
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(separatorImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorImageView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(with text: String, isSelected: Bool) {
        textLabel?.text = text
        checkmarkImageView.isHidden = !isSelected
    }
    
    func setSeparatorVisibility(isHidden: Bool) {
         separatorImageView.isHidden = isHidden
     }
}
