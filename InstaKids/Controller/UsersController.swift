//
//  UsersController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/25/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import JGProgressHUD

class UsersController: UIViewController, CardViewDelegate {
    
    let cardsDeckView = UIView()
    
    var cardViewModels = [CardViewModel]() // empty array
    
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.isHidden = true
        
        setupLayout()
        fetchCurrentUser()
        //self.title = "Choose someone to follow"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Choose someone to follow"
        configureSearchController()
    }
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: SketchUser?
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        user = LocalStorageService.loadCurrentUser()
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
    }
    
    func updateData(on users: [SketchUser]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, SketchUser>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(users)
//        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    fileprivate func fetchUsers() {
        UserService.getUsers { (users) in
            self.hud.dismiss()
            var previousCardView: CardView?
            
            users.forEach { (user) in
                //let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let isNotCurrentUser = true
                
                if isNotCurrentUser  {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            }
        }
    }
    
    var topCardView: CardView?
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: SketchUser) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print("Home controller:", cardViewModel.attributedString)
//        let userDetailsController = UserDetailsController()
//        userDetailsController.cardViewModel = cardViewModel
//        present(userDetailsController, animated: true)
        UserService.follow(cardViewModel.uid)
    }
    
    func didSaveSettings() {
        print("Notified of dismissal from SettingsController in HomeController")
        fetchCurrentUser()
    }
    
    // MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [cardsDeckView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
}

extension UsersController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        isSearching = true
        //filteredUsers = users.filter { $0.username!.lowercased().contains(filter.lowercased() ) }
        //updateData(on: filteredUsers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        //updateData(on: users)
    }
}
