//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//
import UIKit
// точка для начала изменений, дальше не откатывай там просто порядок наводила в коде - изменения после помощи Дрюшки \\ перенесла var countDays в контролер и убрала замыкание onAdd? \\ почистила код от лишних коммитов!!!!! \\ name for trackers вместо title  \\моки добавлены// отрисовка кнопок сделана через замыкания в TVC  \\ начало работы с фильтром
final class TrackersViewController: UIViewController, NewHabitOrEventViewControllerDelegate {
    
    private var newHabitOrEventViewController: NewHabitOrEventViewController!
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Default", trackers: [])
    ]
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private var selectedDate: Date = Date()
    private let cellIdentifier = "cell"
    private var countDays: Int = 0
    
    private struct cellParams {
        let cellCount: Int
        let leftInset: CGFloat
        let rightInset: CGFloat
        let cellSpacing: CGFloat
        let height: CGFloat
        let paddingWidth: CGFloat
        
        init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat, height: CGFloat, paddingWidth: CGFloat) {
            self.cellCount = cellCount
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
            self.height = height
            self.paddingWidth =  leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
        }
    }
    
    private let params = cellParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9,
        height: 148,
        paddingWidth: 0
    )
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        return plusButton
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Трекеры"
        descriptionLabel.font = .systemFont(ofSize: 34, weight: .bold)
        descriptionLabel.textColor = .label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let search = UISearchTextField()
        search.textColor = .ypBlack
        search.placeholder = "Поиск..."
        search.font = .systemFont(ofSize: 17, weight: .regular)
        search.backgroundColor = .clear
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var errorImage: UIImageView = {
        let errorImage = UIImageView()
        errorImage.image = UIImage(named: "Error")
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        return errorImage
    }()
    
    private lazy var errorLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Что будем отслеживать?"
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = .ypBlack
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.backgroundColor = .colorSelected0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        label.text = dateFormatter.string(from: datePicker.date)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.switchHeaderIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.addSubview(errorImage)
        collectionView.addSubview(errorLabel)
        
        setupNavigationBar()
        addSubViews()
        addConstraints()
        showContentOrPlaceholder()
        
        newHabitOrEventViewController = NewHabitOrEventViewController()
        newHabitOrEventViewController.delegate = self
        categories = MockData.mockData // mockData убрать в следующих спринтах
    }
    
    private func addSubViews() {
        view.addSubview(plusButton)
        view.addSubview(descriptionLabel)
        view.addSubview(searchTextField)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(datePicker)
        view.addSubview(dateLabel)
        view.addSubview(collectionView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            datePicker.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.heightAnchor.constraint(equalToConstant: 34),
            dateLabel.widthAnchor.constraint(equalToConstant: 77),
            dateLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard (navigationController?.navigationBar) != nil else { return }
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(plusButton)
        containerView.addSubview(descriptionLabel)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func showContentOrPlaceholder() {
                if categories.isEmpty {
//        if trackers.isEmpty {
            collectionView.isHidden = true
            errorImage.isHidden = false
            errorLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            errorImage.isHidden = true
            errorLabel.isHidden = true
        }
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        if let categoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
            updateCategory(at: categoryIndex, with: tracker)
        } else {
            addToDefaultCategory(tracker)
        }
        
        trackers.append(tracker)
        print("Трекер добавлен: \(tracker.name)")
        showContentOrPlaceholder()
        collectionView.reloadData()
    }
    
    private func updateCategory(at index: Int, with tracker: Tracker) {
        var updatedTrackers = categories[index].trackers
        updatedTrackers.append(tracker)
        categories[index] = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
    }
    
    private func addToDefaultCategory(_ tracker: Tracker) {
        if let defaultIndex = categories.firstIndex(where: { $0.title == "Default" }) {
            updateCategory(at: defaultIndex, with: tracker)
        } else {
            categories.append(TrackerCategory(title: "New", trackers: [tracker]))
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapPlusButton() {
        let viewController = TrackerTypeViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func didChangeDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        dateLabel.text = formattedDate
        print("Выбранная дата: \(formattedDate)")
        let calendar = Calendar.current
        let selectedDayIndex = calendar.component(.weekday, from: datePicker.date)
        guard let selectedWeekDay = WeekDay.from(weekdayIndex: selectedDayIndex) else { return }
//        let filteredTrackers = trackers.filter { tracker in
//            tracker.schedule.contains { weekDay in
//                weekDay == selectedWeekDay
//            }
//        }
        let filteredTrackers = categories.flatMap { category in
            category.trackers.filter { tracker in
                tracker.schedule.contains { weekDay in
                    weekDay == selectedWeekDay
                }
            }
        }
        print("Отфильтрованные трекеры: \(filteredTrackers)")
        if filteredTrackers.isEmpty {
            showErrorImage(true)
            self.categories = []
        } else {
            showErrorImage(false)
            self.categories = [
                TrackerCategory(title: "Filtered", trackers: filteredTrackers)
            ]
        }
        collectionView.reloadData()
    }
    
    private func showErrorImage(_ show: Bool) {
        collectionView.isHidden = show
        errorImage.isHidden = !show
        errorLabel.isHidden = !show
    }
}

extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return trackers.count
        guard section < categories.count else {
            return 0
        }
        let category = categories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        print("Секция: \(indexPath.section), Элемент: \(indexPath.row)")
        cell.contentView.backgroundColor = .ypWhite
        cell.topContainerView.backgroundColor = tracker.color
        cell.actionButton.tintColor = tracker.color
        cell.emoji.text = tracker.emoji
        cell.titleLabel.text = tracker.name
        cell.onButtonTapped = { [weak self] isPlusState in
            if isPlusState {
                cell.actionButton.setImage(UIImage(named: "Plus"), for: .normal)
                cell.actionButton.tintColor = tracker.color
                cell.actionButton.backgroundColor = .ypWhite
                cell.actionButton.alpha = 1
                self?.handlePlusAction(for: indexPath)
            } else {
                cell.actionButton.setImage(UIImage(named: "Done"), for: .normal)
                cell.actionButton.tintColor = .ypWhite
                cell.actionButton.backgroundColor = tracker.color
                cell.actionButton.alpha = 0.3
                self?.handleDoneAction(for: indexPath)
            }
        }
        
        let currentDate = datePicker.date
        cell.dayNumberView.text = "\(countDays) дней"
        cell.configure(with: tracker.name, date: currentDate, countDays: countDays)
        return cell
    }
    
    private func handlePlusAction(for indexPath: IndexPath) {
        print("Отметка о выполнении снята у трекера \(indexPath)")
            // TODO
        }

        private func handleDoneAction(for indexPath: IndexPath) {
            print("Выполненным отмечен трекер \(indexPath)")
            // TODO
        }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: TrackerHeaderView.switchHeaderIdentifier,
                                                                               for: indexPath) as? TrackerHeaderView
        else { return UICollectionReusableView() }
        let titleCategory = categories[indexPath.section].title
        headerView.titleLabel.text = titleCategory
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - params.cellSpacing - params.leftInset - params.rightInset) / CGFloat(params.cellCount),
                      height: params.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
