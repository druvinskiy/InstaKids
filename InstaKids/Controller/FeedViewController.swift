//
//  FeedViewController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var sketches = [Sketch]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureTabBar()
        setNavigationBar()
        
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SketchService.getSketches { (sketches) in
            self.sketches = sketches
            self.tableView.reloadData()
        }
        
        self.tabBarController?.navigationItem.title = "InstaKids"
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func configureTabBar() {
        tabBarController?.delegate = self
    }
    
    @objc func addDrawing() {
        let drawingVC = DrawingVC(sketch: nil)
        drawingVC.hidesBottomBarWhenPushed = true
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
        cell.set(with: sketch)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drawingVC = DrawingVC(sketch: sketches[indexPath.row])
        drawingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(drawingVC, animated: true)
    }
}

extension FeedViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let title = tabBarController.tabBar.selectedItem?.title
        
        if title == "New Drawing" {
//            let navigationController = UINavigationController(rootViewController: DrawingVC(sketch: nil))
            //navigationController.modalPresentationStyle = .fullScreen
            //present(DrawingVC(sketch: nil), animated: true)
            
            let drawingVC = DrawingVC(sketch: nil)
            drawingVC.done = {
                tabBarController.selectedIndex = 0
            }
            //drawingVC.delegate = self
            navigationController?.pushViewController(drawingVC, animated: true)
            
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if tabBarController.selectedIndex == 1 {
//            return false
//        }

        return true
    }
}

//extension FeedViewController: DrawingVCDelegate {
//    func didCreateDrawing() {
//        tabBarController?.selectedIndex = 0
//    }
//}
