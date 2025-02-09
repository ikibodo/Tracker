//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import UIKit

protocol NewCategoryDelegate: AnyObject {
    func addNewCategory(newCategory: String)
}

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryDelegate?
    
    private var previousText: String?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Новая категория"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryNameInput: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.tintColor = .ypBlack
        textField.textColor =  .ypBlack
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.placeholder = "Введите название категории"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        addSubViews()
        addConstraints()
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(categoryNameInput)
        view.addSubview(categoryButton)
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            categoryNameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            categoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])}
    
    private func validateCategoryButton() {
        let isCategoryNameFilled = !(categoryNameInput.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        
        categoryButton.isEnabled = isCategoryNameFilled
        categoryButton.backgroundColor = categoryButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc private func categoryButtonTapped() {
        guard let categoryName = categoryNameInput.text?.trimmingCharacters(in: .whitespaces), !categoryName.isEmpty else { return }
        delegate?.addNewCategory(newCategory: categoryName)
        dismiss(animated: true, completion: nil)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("✍️ Пользователь начал редактировать поле названия категории")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, text != previousText else { return }
        previousText = text
        validateCategoryButton()
    }
}
