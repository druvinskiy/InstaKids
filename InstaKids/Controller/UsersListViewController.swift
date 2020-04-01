//
//  UsersListViewController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/22/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class UsersListViewController: UIViewController {
    
    enum Section { case main }
    
    var users: [SketchUser] = []
    var filteredUsers: [SketchUser] = []
    var hasMoreFollowers = true
    var isSearching = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, SketchUser>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSearchController()
        configureCollectionView()
        configureDataSource()
        getUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        self.navigationItem.title = "Follow Someone"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: tabBarController!.view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseID)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        let searchBar = searchController.searchBar
        // ...
        // Configure `searchBar` if needed
        // ...

        let searchTextField: UITextField
        if #available(iOS 13, *) {
            searchTextField = searchBar.searchTextField
        } else {
            searchTextField = (searchBar.value(forKey: "searchField") as? UITextField) ?? UITextField()
        }

        // Since iOS 13 SDK, there is no accessor to get the placeholder label.
        // This is the only workaround that might cause issued during the review.
        if let systemPlaceholderLabel = searchTextField.value(forKey: "placeholderLabel") as? UILabel {
            // Empty or `nil` strings cause placeholder label to be hidden by the search bar
            searchBar.placeholder = " "

            // Create our own placeholder label
            let placeholderLabel = UILabel(frame: .zero)

            placeholderLabel.text = "Search for a username"
            placeholderLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            placeholderLabel.textColor = .white

            systemPlaceholderLabel.addSubview(placeholderLabel)

            // Layout label to be a "new" placeholder
            placeholderLabel.leadingAnchor.constraint(equalTo: systemPlaceholderLabel.leadingAnchor).isActive = true
            placeholderLabel.topAnchor.constraint(equalTo: systemPlaceholderLabel.topAnchor).isActive = true
            placeholderLabel.bottomAnchor.constraint(equalTo: systemPlaceholderLabel.bottomAnchor).isActive = true
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        } else {
            searchBar.placeholder = ""
        }
        
        navigationItem.searchController = searchController
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SketchUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.reuseID, for: indexPath) as! UserCell
            cell.set(user: follower)
            
            return cell
        })
    }
    
    func updateData(on users: [SketchUser]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SketchUser>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
}

extension UsersListViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else { return}
            getUsers()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredUsers : users
        let user = activeArray[indexPath.item]
        
        let title = "Follow \(user.username!)?"
        let message = "Your child will be able to see all drawings created by \(user.username!)."
        let action = {
            UserService.follow(user.userId!)
        }
        
        presentIKAlertOnMainThread(title: title, message: message, positiveButtonTitle: nil, positiveButtonAction: action, negativeButtonTitle: nil)
    }
    
    func getUsers() {
        UserService.getUsers { (users) in
            self.users = users
            self.updateData(on: users)
            
        }
    }
}

extension UsersListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        isSearching = true
        filteredUsers = users.filter { $0.username!.lowercased().contains(filter.lowercased() ) }
        updateData(on: filteredUsers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: users)
    }
}
