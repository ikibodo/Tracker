//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 7.1.25..
//
import UIKit

final class IrregularEventController : UIViewController {
    weak var trackerViewController: TrackerTypeViewController?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Новое нерегулярное событие"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameInput: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.tintColor = .ypGray
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 17
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .ypBlack
        
        let chevronImageView = UIImageView(image: UIImage(named: "Chevron"))
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(chevronImageView)
        
        return stackView
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        button.layer.cornerRadius = 16
        button.addSubview(stackView)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationBar()
        addSubViews()
        addConstraints()
    }
    
    private func navigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(trackerNameInput)
        view.addSubview(categoryButton)
        view.addSubview(stackView)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            trackerNameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            categoryButton.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            stackView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createButton.leftAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc
    private func categoryButtonTapped () {
        // TODO
        print("Категория нажата") // удалить
    }
    
    @objc
    private func createButtonTapped() {
        // TODO
        print("Создать нажато") // удалить
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
