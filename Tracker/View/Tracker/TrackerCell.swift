//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    var currentDate: Date?
    var trackerId: UUID?
    var isPinned: Bool = false {
        didSet {
            updatePinVisibility(shouldShowPin: isPinned)
        }
    }
    
    private var indexPath: IndexPath?
    private var blurEffectView: UIVisualEffectView?
    private var isCompletedToday = false
    private let doneImage = UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate)
    private let plusImage = UIImage(named: "Plus")
    
    var  topContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var  bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var  titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.overrideUserInterfaceStyle = .light
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.overrideUserInterfaceStyle = .light
        view.clipsToBounds = true
        view.layer.cornerRadius = 24 / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pin: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pin")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    var emoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dayNumberView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var  actionButton: UIButton = {
        let button = UIButton()
        let buttonSize = 34
        button.layer.cornerRadius = 34 / 2
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
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with tracker: Tracker, indexPath: IndexPath, completedDay: Int, isCompletedToday: Bool) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        self.contentView.backgroundColor = .ypWhite
        self.topContainerView.backgroundColor = tracker.color
        
        self.emoji.text = tracker.emoji
        self.titleLabel.text = tracker.name
        
        let wordDay = dayWord(for: completedDay)
        dayNumberView.text = "\(completedDay) \(wordDay)"
        
        if isCompletedToday {
            actionButton.tintColor = .ypWhite
            actionButton.backgroundColor = tracker.color
            actionButton.alpha = 0.3
        } else {
            actionButton.tintColor = tracker.color
            actionButton.backgroundColor = .ypWhite
            actionButton.alpha = 1
        }
        
        let image = isCompletedToday ? doneImage : plusImage
        actionButton.setImage(image, for: .normal)
        if actionButton.image(for: .normal) == nil {
            print("Изображение не установлено для кнопки!")
        }
    }
    
    func configure(with title: String, date: Date, isPinned: Bool) {
        titleLabel.text = title
        self.currentDate = date
        self.isPinned = isPinned
    }
    
    func dayWord(for number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "manyDays".localized
        }
        
        switch lastDigit {
        case 1:
            return "oneDay".localized
        case 2, 3, 4:
            return "fewDays".localized
        default:
            return "manyDays".localized
        }
    }
    
    func updatePinVisibility(shouldShowPin: Bool) {
        pin.isHidden = !shouldShowPin
    }
    
    private func addSubview() {
        contentView.addSubview(topContainerView)
        contentView.addSubview(bottomContainerView)
        
        topContainerView.addSubview(emojiView)
        topContainerView.addSubview(emoji)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(pin)
        
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
            
            pin.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            pin.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            
            titleLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12),
            
            dayNumberView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            dayNumberView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 12),
            
            actionButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func buttonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            print("Нет ID трекера")
            return }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
