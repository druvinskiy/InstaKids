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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SketchService.getSketches { (sketches) in
            self.sketches = sketches
            self.tableView.reloadData()
        }
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func configureTabBar() {
        tabBarController?.delegate = self
    }

    @IBAction func addDrawing(_ sender: UIBarButtonItem) {
      guard let drawingViewController = storyboard?.instantiateViewController(identifier: DrawingViewController.reuseID) as? DrawingViewController else {
          return
      }
      navigationController?.pushViewController(drawingViewController, animated: true)
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
        guard let drawingViewController = storyboard?.instantiateViewController(identifier: DrawingViewController.reuseID) as? DrawingViewController else {
            return
        }
        
        drawingViewController.sketch = sketches[indexPath.row]
        navigationController?.pushViewController(drawingViewController, animated: true)
    }
}

extension FeedViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(tabBarController.tabBar.selectedItem?.title)
    }
}
