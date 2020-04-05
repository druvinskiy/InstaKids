//
//  IKAlertVC.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/30/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class IKAlertVC: UIViewController {
    
    let containerView = UIView()
    let titleLabel = IKTitleLabel(textAlignment: .center, fontSize: 20)
    let messageLabel = IKBodyLabel(textAlignment: .center)
    
    let positiveButton = IKButton(backgroundColor: #colorLiteral(red: 0.9334495664, green: 0.3899522722, blue: 0.2985906601, alpha: 1), title: "Ok")
    var positiveButtonTitle: String?
    var positiveButtonAction: (() -> Void)?
    
    let negativeButton = IKButton(backgroundColor: Theme.mainColor, title: "Ok")
    var negativeButtonTitle: String?
    var negativeButtonAction: (() -> Void)?
    
    var alertTitle: String?
    var message: String?
    
    let padding: CGFloat = 20
    
    init(title: String, message: String, positiveButtonTitle: String?, positiveButtonAction: @escaping (() -> Void), negativeButtonTitle: String?, negativeButtonAction: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        alertTitle = title
        self.message = message
        
        self.positiveButtonTitle = positiveButtonTitle
        self.positiveButtonAction = positiveButtonAction
        
        self.negativeButtonTitle = negativeButtonTitle
        self.negativeButtonAction = negativeButtonAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        configureContainerView()
        configureTitleLabel()
        configureActionButtons()
        configureMessageLabel()
    }
    
    func configureContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "Something went wrong"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [
            negativeButton,
            positiveButton
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        
        containerView.addSubview(stackView)
        
        positiveButton.setTitle(positiveButtonTitle ?? "Ok", for: .normal)
        positiveButton.addTarget(self, action: #selector(act), for: .touchUpInside)
        
        negativeButton.setTitle(negativeButtonTitle ?? "Cancel", for: .normal)
        negativeButton.addTarget(self, action: #selector(negAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configureMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: positiveButton.topAnchor, constant: -12)
        ])
    }
    
    @objc func negAction() {
        if let negAction = negativeButtonAction {
            negAction()
        }
        
        dismiss(animated: true)
    }
    
    @objc func act() {
        positiveButtonAction?()
        dismiss(animated: true)
    }
}
