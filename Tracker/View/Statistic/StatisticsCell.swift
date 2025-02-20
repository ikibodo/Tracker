//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 19.2.25..
//
import UIKit
import UIKit

final class StatisticsCell: UITableViewCell {
    static let identifier = "StatisticsCell"
    
    private let gradientBorderLayer = CAGradientLayer()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(countLabel)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor.colorSelected1.cgColor,
            UIColor.colorSelected9.cgColor,
            UIColor.colorSelected3.cgColor
        ]
        gradientBorderLayer.locations = [0.1, 0.5, 0.9]
        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        contentView.layer.insertSublayer(gradientBorderLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: contentView.bounds.height - 12
        )

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(roundedRect: gradientBorderLayer.bounds.insetBy(dx: 0.5, dy: 0.5),
                                       cornerRadius: 16).cgPath
        
        gradientBorderLayer.mask = shapeLayer
    }
    
    func configure(count: Int, item: String) {
        countLabel.text = "\(count)"
        descriptionLabel.text = item
    }
}
