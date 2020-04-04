//
//  FeedViewController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var sketches = [Sketch]()
    var isFeed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setNavigationBar()
        
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hidesBottomBarWhenPushed = false
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        if let currentUser = LocalStorageService.loadCurrentUser(),
            let title = tabBarController?.tabBar.selectedItem?.title {
            
            isFeed = title == ItemTitle.feed.rawValue
            
            let filter: ((Sketch) -> Bool) = isFeed
                ? {currentUser.following.contains($0.byId!)}
                : {currentUser.userId! == ($0.byId!)}
            
            self.navigationItem.title = isFeed
                ? "InstaKids"
                : currentUser.username
            
            SketchService.getFilteredSketches(filter: filter) { (sketches) in
                DispatchQueue.main.async {
                    self.sketches = Array(sketches)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func configureTabBar() {
        tabBarController?.delegate = self
    }
    
    @objc func addDrawing() {
        let drawingVC = DrawingVC(sketch: nil)
        navigationController?.pushViewController(drawingVC, animated: true)
    }
    
    func setNavigationBar() {
//        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDrawing))
//
//        navigationItem.rightBarButtonItem = addItem
    }
}

extension FeedViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sketches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Storyboard.feedSketchTableCellId, for: indexPath) as! SketchCell
        
        let sketch = sketches[indexPath.row]
        cell.set(with: sketch, isFeed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drawingVC = DrawingVC(sketch: sketches[indexPath.row])
        
        drawingVC.done = {
            self.navigationController?.popViewController(animated: true)
        }
        
        //drawingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(drawingVC, animated: true)
    }
}

extension FeedViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let title = tabBarController.tabBar.selectedItem?.title
        
        if title == ItemTitle.newDrawing.rawValue, let navigationController = viewController as? UINavigationController {
            
            let drawingVC = DrawingVC(sketch: nil)
            
            drawingVC.done = {
                //tabBarController.selectedIndex = 0
                //navigationController.popViewController(animated: true)
                navigationController.popViewController(animated: true) {
                    self.tabBarController?.selectedIndex = 0
                }
            }
            
            //drawingVC.hidesBottomBarWhenPushed = true
            
            navigationController.pushViewController(viewController: drawingVC, animated: true, completion: {
            })
            
        } else if title == ItemTitle.follow.rawValue {
            let authenticationController = AuthenticationController()
            authenticationController.modalPresentationStyle = .fullScreen
            
            authenticationController.didFinishAuthenticating = { isAuthenticated in
                
                if !isAuthenticated {
                    self.tabBarController?.selectedIndex = 0
                }
            }
            
        }
    }
}
