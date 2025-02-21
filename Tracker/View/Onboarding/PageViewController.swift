//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import UIKit

enum PageType: Int {
    case first
    case second
}

final class PageViewController: UIViewController {
    var didFinishOnboarding: (() -> Void)?
    
    private let pageType: PageType
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var onboardingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onboardingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.currentPageIndicatorTintColor = .ypBlack
        control.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    init(pageType: PageType) {
        self.pageType = pageType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        addConstraints()
        configurePage()
    }
    
    private func addSubViews() {
        view.addSubview(onboardingImageView)
        view.addSubview(onboardingLabel)
        view.addSubview(pageControl)
        view.addSubview(onboardingButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            onboardingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            onboardingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            onboardingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 16),
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24),
            
            onboardingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60)
        ])}
    
    private func configurePage() {
        switch pageType {
        case .first:
            onboardingLabel.text = "Отслеживайте только то, что хотите"
            onboardingImageView.image = UIImage(named: "OnboardingBlue")
            pageControl.currentPage = 0
        case .second:
            onboardingLabel.text = "Даже если это не литры воды и йога"
            onboardingImageView.image = UIImage(named: "OnboardingPink")
            pageControl.currentPage = 1
        }
    }
    
    @objc private func onboardingButtonTapped() {
        print("🔘 Tapped onboardingButtonTapped - онбординг закрывается и больше не должен быть показан")
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        didFinishOnboarding?()
    }
}
