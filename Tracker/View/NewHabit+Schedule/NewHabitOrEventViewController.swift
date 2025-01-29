//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import UIKit

protocol NewHabitOrEventViewControllerDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory)
}

final class NewHabitOrEventViewController: UIViewController, ScheduleViewControllerDelegate {
    
    weak var trackerViewController: TrackerTypeViewController?
    weak var delegate: NewHabitOrEventViewControllerDelegate?
    
    private var trackerItemsTopConstraint: NSLayoutConstraint!
    private var schedule: [WeekDay?] = []
    private let itemsForHabits = ["Категория", "Расписание"]
    private let itemsForEvents = ["Категория"]
    private var currentItems: [String] = []
    private var categoryTitle: String?
    private var emoji: String?
    private var color: UIColor?
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪" ]
    private let colors: [UIColor] = [
        .colorSelected1, .colorSelected2, .colorSelected3, .colorSelected4, .colorSelected5, .colorSelected6, .colorSelected7, .colorSelected8, .colorSelected9, .colorSelected10, .colorSelected11, .colorSelected12, .colorSelected13, .colorSelected14, .colorSelected15, .colorSelected16, .colorSelected17, .colorSelected18 ]
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameInput: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.tintColor = .ypBlack
        textField.textColor =  .ypBlack
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.clipsToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerItems: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        
        let itemWidth = (UIScreen.main.bounds.width - 18 * 2 - 5 * 5) / 6
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 34)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(CollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(isForHabits: Bool) {
        self.currentItems = isForHabits ? itemsForHabits : itemsForEvents
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        trackerItems.reloadData()
        trackerItems.delegate = self
        trackerItems.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationBar()
        updateNavigationBarTitle(forItems: currentItems)
        addSubViews()
        addConstraints()
    }
    
    func didUpdateSchedule(_ schedule: [WeekDay?]) {
        self.schedule = schedule
        validateCreateButtonState()
        trackerItems.reloadData()
        print("Обновленное расписание \(schedule.map { $0?.rawValue ?? "None" })")
    }
    
    private func updateNavigationBarTitle(forItems items: [String]) {
        if items == itemsForHabits {
            titleLabel.text = "Новая привычка"
        } else if items == itemsForEvents {
            titleLabel.text = "Новое нерегулярное событие"
        }
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func navigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(trackerNameInput)
        view.addSubview(limitLabel)
        view.addSubview(trackerItems)
        view.addSubview(collectionView)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
    }
    
    private func addConstraints() {
        trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            trackerNameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            limitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            trackerItemsTopConstraint,
            trackerItems.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerItems.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerItems.heightAnchor.constraint(equalToConstant: CGFloat(75 * currentItems.count)),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createButton.leftAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: trackerItems.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
        ])
    }
    
    private func updateConstraints() {
        if limitLabel.isHidden {
            trackerItemsTopConstraint.isActive = false
            trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24)
        } else {
            trackerItemsTopConstraint.isActive = false
            trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 32)
        }
        trackerItemsTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func validateCreateButtonState() {
        let isForHabits = currentItems.contains("Расписание")
        let isNameFilled = !(trackerNameInput.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let isScheduleSelected = !schedule.isEmpty
        
        createButton.isEnabled = isForHabits ? (isNameFilled && isScheduleSelected) : isNameFilled
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc
    private func createButtonTapped() {
        let newTracker = Tracker(
            id: UUID(),
            name: trackerNameInput.text ?? "Привычка",
            color: self.color ?? .colorSelected17,
            emoji: self.emoji ?? "🌟",
            schedule: self.schedule
        )
        
        let categoryTracker = TrackerCategory(
            title: self.categoryTitle ?? "Новые трекеры",
            trackers: [newTracker])
        delegate?.addTracker(newTracker, to: categoryTracker)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
        print("Создать нажато и создается трекер")
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewHabitOrEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Пользователь начал редактировать поле")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateCreateButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let maxSymbolNumber = 38
        limitLabel.isHidden = !(updatedText.count >= maxSymbolNumber)
        updateConstraints()
        return true
    }
}

extension NewHabitOrEventViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Категория нажата")
            // TODO - добавить логику для выбора категории
        case 1:
            print("Расписание нажато")
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.loadSelectedSchedule(from: schedule)
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true)
        default:
            break
        }
    }
}

extension NewHabitOrEventViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        cell.textLabel?.text = currentItems[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        
        if indexPath.row == 1, currentItems.contains("Расписание") {
            let shortWeekDays = schedule.compactMap { $0?.shortWeekDay }
            print("Краткие дни недели: \(shortWeekDays)")
            cell.detailTextLabel?.text = shortWeekDays.isEmpty ? "" : shortWeekDays.joined(separator: ", ")
            cell.detailTextLabel?.text = shortWeekDays.joined(separator: ", ")
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        if indexPath.row == 0, !currentItems.contains("Расписание") {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let chevronImage = UIImage(named: "Chevron")
        if let chevronImage = chevronImage {
            let chevronImageView = UIImageView(image: chevronImage)
            cell.accessoryView = chevronImageView
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension NewHabitOrEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell else {
                fatalError("Unable to dequeue EmojiCell")
            }
            cell.configure(with: emojis[indexPath.item], isSelected: indexPath == selectedEmojiIndex)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell else {
                fatalError("Unable to dequeue ColorCell")
            }
            cell.configure(with: colors[indexPath.item], isSelected: indexPath == selectedColorIndex)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? CollectionHeaderView else {
            fatalError("Unable to dequeue CollectionHeaderView")
        }
        header.configure(with: indexPath.section == 0 ? "Emoji" : "Цвет")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let previousIndex = selectedEmojiIndex
            selectedEmojiIndex = indexPath
            self.emoji = emojis[indexPath.item]
            collectionView.reloadItems(at: [indexPath, previousIndex].compactMap { $0 })
            print("Выбран эмодзи: \(emojis[indexPath.item])")
        } else {
            let previousIndex = selectedColorIndex
            selectedColorIndex = indexPath
            self.color = colors[indexPath.item]
            collectionView.reloadItems(at: [indexPath, previousIndex].compactMap { $0 })
            print("Выбран цвет: \(colors[indexPath.item])")
        }
    }
}
