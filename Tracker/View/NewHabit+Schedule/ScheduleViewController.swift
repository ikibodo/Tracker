//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ schedule: [WeekDay?])
}

final class ScheduleViewController: UIViewController {
    
    weak var newHabitOrEventViewController: NewHabitOrEventViewController?
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var schedule: [WeekDay?] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Расписание"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.backgroundColor = .ypBackground
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners =  [.layerMaxXMaxYCorner,.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var saveDaysButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveDays), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        scheduleView.delegate = self
        scheduleView.dataSource = self
        setupNavigationBar()
        addSubview()
        addConstraints()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubview() {
        view.addSubview(titleLabel)
        view.addSubview(scheduleView)
        view.addSubview(saveDaysButton)
    }
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            scheduleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            scheduleView.heightAnchor.constraint(equalToConstant: 525),
            
            saveDaysButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveDaysButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveDaysButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveDaysButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    func loadSelectedSchedule(from schedule: [WeekDay?]) {
        self.schedule = schedule
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        let weekDay = WeekDay.allCases[index]
        
        if sender.isOn {
            if !schedule.contains(where: { $0 == weekDay }) {
                schedule.append(weekDay)
            }
        } else {
            if let indexToRemove = schedule.firstIndex(of: weekDay) {
                schedule[indexToRemove] = nil
            }
        }
        
        print("Selected schedule: \(schedule.map { $0?.rawValue ?? "None" })")
    }
    
    @objc
    private func saveDays () {
        delegate?.didUpdateSchedule(schedule)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        
        let weekDay = WeekDay.allCases[indexPath.row]
        
        cell.textLabel?.text = weekDay.rawValue
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        
        let switchControl = UISwitch()
        switchControl.isOn = schedule.contains(weekDay)
        switchControl.tag = indexPath.row
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switchControl.tintColor = .ypBlue
        switchControl.onTintColor = .ypBlue
        cell.accessoryView = switchControl

        let separatorImageView = UIView()
        separatorImageView.backgroundColor = .ypGray
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(separatorImageView)
        NSLayoutConstraint.activate([
            separatorImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separatorImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separatorImageView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
        ])
        separatorImageView.isHidden = indexPath.row == WeekDay.allCases.count - 1
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
}
