//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//

import UIKit

final class TrackerViewController: UIViewController {
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        return plusButton
    }()
    
//    private lazy var plusButton: UIBarButtonItem = {
//        let plusButton = UIBarButtonItem(image: UIImage(named: "Add tracker"), style: .plain, target: self, action: #selector(didTapPlusButton))
////        plusButton.translatesAutoresizingMaskIntoConstraints = false
//        return plusButton
//    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Трекеры"
        descriptionLabel.font = .systemFont(ofSize: 34, weight: .bold)
        descriptionLabel.textColor = .label
//        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
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
        descriptionLabel.textColor = .label
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupNavigationBar()
        addSubViews()
        addConstraints()
    }

//    private func setupNavigationBar() {
//        let image = UIImage(named: "Add tracker")?.withRenderingMode(.alwaysOriginal)
//        let plusButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapPlusButton))
//        navigationItem.leftBarButtonItem = plusButton
//        navigationItem.title = "Треки"
//    }
    private func addSubViews() {
        view.addSubview(plusButton)
        view.addSubview(descriptionLabel)
        view.addSubview(searchBar)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 57),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ])
    }
    
    @objc
    private func didTapPlusButton() {
        // TODO - обработать нажатие на кнопку
    }
}

