//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 5.1.25..
//
import UIKit

final class StatisticsViewController: UIViewController {
    
    private let store = AppSettingsStore.shared
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    private var points: [Int] = [0, 0, 0, 0]
    private var goals: [String] = StatisticsType.allCases.map { $0.rawValue }
    
    private var bestStreak = 0
    private var perfectDays = 0
    private var totalCompleted = 0
    private var averageCompleted = 0
    
    private lazy var titleLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Статистика"
        descriptionLabel.font = .systemFont(ofSize: 34, weight: .bold)
        descriptionLabel.textColor = .ypBlack
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ErrorStat")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypWhite
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubViews()
        addConstraints()
        calculateStatistics()
        showStatisticOrError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateStatistics()
        showStatisticOrError()
    }
    
    private func addSubViews() {
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func showStatisticOrError() {
        let shouldShowError = totalCompleted == 0
        tableView.isHidden = shouldShowError
        errorImage.isHidden = !shouldShowError
        errorLabel.isHidden = !shouldShowError
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell else { return UITableViewCell() }
        let point = points[indexPath.row]
        let goal = goals[indexPath.row]
        cell.configure(count: point, item: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

extension StatisticsViewController {
    private func calculateStatistics() {
        do {
            let records = try trackerRecordStore.fetchAllRecords()
            let trackers = try trackerStore.fetchAllTrackers()
            
            guard !records.isEmpty else {
                bestStreak = 0
                perfectDays = 0
                totalCompleted = 0
                averageCompleted = 0
                store.saveStatistics(bestStreak: bestStreak, perfectDays: perfectDays, totalCompleted: totalCompleted, averageCompleted: averageCompleted)
                return
            }
            
            var completedByDate: [Date: Int] = [:]
            var trackersByWeekday: [WeekDay: Set<UUID>] = [:]
            var currentStreak = 0
            var maxStreak = 0
            var previousDate: Date?
            
            for record in records {
                let date = Calendar.current.startOfDay(for: record.date)
                completedByDate[date, default: 0] += 1
            }
            totalCompleted = records.count
            
            for tracker in trackers {
                for weekday in tracker.schedule.compactMap({ $0 }) {
                    trackersByWeekday[weekday, default: []].insert(tracker.id)
                }
            }
            
            let sortedDates = Array(Set(completedByDate.keys)).sorted()
            
            for date in sortedDates {
                let completedCount = completedByDate[date] ?? 0
                let weekdayIndex = Calendar.current.component(.weekday, from: date)
                if let weekday = WeekDay.from(weekdayIndex: weekdayIndex) {
                    let plannedCount = trackersByWeekday[weekday]?.count ?? 0
                    if completedCount == plannedCount {
                        if let prev = previousDate, Calendar.current.isDate(date, inSameDayAs: prev.addingTimeInterval(86400)) {
                            currentStreak += 1
                        } else {
                            currentStreak = 1
                        }
                        maxStreak = max(maxStreak, currentStreak)
                    } else {
                        currentStreak = 0
                    }
                }
                
                previousDate = date
            }
            bestStreak = maxStreak
            
            perfectDays = 0
            for date in sortedDates {
                let completedCount = completedByDate[date] ?? 0
                let weekdayIndex = Calendar.current.component(.weekday, from: date)
                if let weekday = WeekDay.from(weekdayIndex: weekdayIndex) {
                    let plannedCount = trackersByWeekday[weekday]?.count ?? 0
                    if completedCount == plannedCount {
                        perfectDays += 1
                    }
                }
            }
            
            let uniqueDays = completedByDate.keys.count
            averageCompleted = uniqueDays > 0 ? totalCompleted / uniqueDays : 0
            
            points = [bestStreak, perfectDays, totalCompleted, averageCompleted]
            
            store.saveStatistics(bestStreak: bestStreak, perfectDays: perfectDays, totalCompleted: totalCompleted, averageCompleted: averageCompleted)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.showStatisticOrError()
            }
        } catch {
            print("StatisticsViewController - Ошибка при получении данных: \(error)")
        }
    }
}
