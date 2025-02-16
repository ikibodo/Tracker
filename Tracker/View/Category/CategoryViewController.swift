//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private var categoryViewModel: CategoryViewModel
    
    init(categoryViewModel: CategoryViewModel) {
        self.categoryViewModel = categoryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Категория"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let errorImage = UIImageView()
        errorImage.image = UIImage(named: "Error")
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        return errorImage
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        tableView.delegate = self
        tableView.dataSource = self
        setupBindings()
        setupNavigationBar()
        addSubViews()
        addConstraints()
    }
    
    private func setupBindings() {
        categoryViewModel.onCategoriesUpdated = { [weak self] categories in
            self?.tableView.reloadData()
            self?.updateTableViewHeight()
            self?.showContentOrPlaceholder()
        }
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(tableView)
        view.addSubview(categoryButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * categoryViewModel.getCategories().count)),
            
            
            categoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])}
    
    private func showContentOrPlaceholder() {
        if categoryViewModel.getCategories().isEmpty {
            tableView.isHidden = true
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            tableView.isHidden = false
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
    
    private func updateTableViewHeight() {
        let categoriesCount = categoryViewModel.getCategories().count
        let newHeight = CGFloat(75 * categoriesCount)
        
        if let existingConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
            existingConstraint.isActive = false
        }
        
        tableView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
    }
    
    @objc private func categoryButtonTapped() {
        print("🔘 Tapped Добавить категорию")
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = categoryViewModel.getCategories().count
        showContentOrPlaceholder()
        return count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if indexPath.row == categoryViewModel.getCategories().count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let categoryName = categoryViewModel.getCategories()[indexPath.row]
        let isSelected = categoryViewModel.isCategorySelected(categoryName)
        cell.configure(with: categoryName, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryName = categoryViewModel.getCategories()[indexPath.row]
        categoryViewModel.selectCategory(categoryName)
        delegate?.didSelectCategory(categoryName)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = categoryViewModel.getCategories()[indexPath.row]
        
        let editAction = UIAction(title: "Редактировать", handler: { _ in
            // TODO редактирование категории
        })
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive, handler: { _ in
            self.showDeleteCategoryAlert {
                self.categoryViewModel.deleteCategory(category)
                self.updateTableViewHeight()
                tableView.reloadData()
                self.showContentOrPlaceholder()
            }
        })
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func showDeleteCategoryAlert(confirmHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Эта категория точно не нужна?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            confirmHandler()
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension  CategoryViewController: NewCategoryDelegate {
    func addNewCategory(newCategory: String) {
        print("Новая категория \(newCategory) добавлена в таблицу категорий")
        categoryViewModel.addCategory(newCategory)
        updateTableViewHeight()
        tableView.reloadData()
        showContentOrPlaceholder()
    }
}

