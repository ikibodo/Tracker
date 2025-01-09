//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import Foundation
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    private var onAdd: ((Date) -> Void)?
    private var currentDate: Date?
    private var id: UUID?
    private var indexPath: IndexPath?
    private var countDays: Int = 0
    private var isPlusState = false
    
    let  titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var  topContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .colorSelected18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var  bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.clipsToBounds = true
        view.layer.cornerRadius = 24 / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "❤️"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dayNumberView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "\(countDays) дней"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var  actionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 34 / 2
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.tintColor = .colorSelected18
        button.alpha = 1
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with tracker: Tracker, indexPath: IndexPath) { // TODO доделать
        emojiView.setNeedsDisplay()
        emoji.text = tracker.emoji
        titleLabel.text = tracker.title
        dayNumberView.text = tracker.title
        self.id = tracker.id
    }
    
    private func addSubview() {
        contentView.addSubview(topContainerView)
        contentView.addSubview(bottomContainerView)
        
        topContainerView.addSubview(emojiView)
        topContainerView.addSubview(emoji)
        topContainerView.addSubview(titleLabel)
        
        bottomContainerView.addSubview(actionButton)
        bottomContainerView.addSubview(dayNumberView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            bottomContainerView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            
            emoji.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dayNumberView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            dayNumberView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 12),
            
            actionButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    func configure(with title: String, date: Date, onAdd: @escaping (Date) -> Void) {
            titleLabel.text = title
            self.currentDate = date
            self.onAdd = onAdd
        }

    @objc private func buttonTapped() {
        if isPlusState {
            actionButton.setImage(UIImage(named: "Plus"), for: .normal)
            actionButton.tintColor = .colorSelected18
            actionButton.backgroundColor = .ypWhite
            actionButton.alpha = 1
        } else {
            actionButton.setImage(UIImage(named: "Done"), for: .normal)
            actionButton.tintColor = .ypWhite
            actionButton.backgroundColor = .colorSelected18
            actionButton.alpha = 0.3
        }
        isPlusState.toggle()
        if let date = currentDate { onAdd?(date) }

    }
}
