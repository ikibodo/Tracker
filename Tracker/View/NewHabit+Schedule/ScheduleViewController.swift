//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import UIKit

final class ScheduleViewController: UIViewController {
    
    weak var newHabitViewController: NewHabitViewController?
    
    private var selectedDays: Set<WeekDay> = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Расписание"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .ypWhite
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
        navigationBar()
        addSubview()
        addConstraints()
    }
    private func navigationBar() {
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
    
    @objc
    private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        let weekDay = WeekDay.allCases[index]
        
        if sender.isOn {
            selectedDays.insert(weekDay)
        } else {
            selectedDays.remove(weekDay)
        }
        print("Selected days: \(selectedDays.map { $0.rawValue })")
    }
    
    @objc
    private func saveDays () {
        // TODO - сохранение дней реализовать
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
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let switchControl = UISwitch()
        switchControl.isOn = selectedDays.contains(weekDay)
        switchControl.tag = indexPath.row
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchControl
        
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