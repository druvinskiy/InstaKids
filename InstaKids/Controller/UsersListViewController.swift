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
        navigationController?.navigationBar.prefersLargeTitles = true
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
        searchController.searchBar.placeholder = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
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
        let follower = activeArray[indexPath.item]
        
//        let destVC = UserInfoVC()
//        destVC.username = follower.login
//        let navController = UINavigationController(rootViewController: destVC)
//        present(navController, animated: true)
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
