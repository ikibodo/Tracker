//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 17.2.25..
//
import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(selectFilter: TrackerFilterType)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    
    private var appSettingsStore = AppSettingsStore.shared
    
    private var filterList: [TrackerFilterType] = TrackerFilterType.allCases
    private var selectedFilter: TrackerFilterType?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Фильтры"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.register(FiltersCell.self, forCellReuseIdentifier: FiltersCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        tableView.delegate = self
        tableView.dataSource = self
        setupNavigationBar()
        addSubViews()
        addConstraints()
        if let savedFilter = appSettingsStore.selectedFilter {
            selectedFilter = savedFilter
        } else {
            selectedFilter = filterList.first 
        }
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
        titleLabel.sizeToFit()
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * filterList.count)),
        ])}
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FiltersCell.identifier, for: indexPath) as? FiltersCell else {
            return UITableViewCell()
        }
        
        let filter = filterList[indexPath.row]
        let isSelected = filter == selectedFilter
        cell.configure(with: filter.rawValue, isSelected: isSelected)
        
        let isLastCell = indexPath.row == filterList.count - 1
        cell.setSeparatorVisibility(isHidden: isLastCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newSelectedFilter = filterList[indexPath.row]
        if selectedFilter == newSelectedFilter { return }
        
        let previousIndex = selectedFilter.flatMap { filterList.firstIndex(of: $0) }
        selectedFilter = newSelectedFilter
        appSettingsStore.selectedFilter = newSelectedFilter
        
        var indexPathsToReload = [indexPath]
        if let previousIndex = previousIndex {
            indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
        }
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)

        delegate?.didSelectFilter(selectFilter: newSelectedFilter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
