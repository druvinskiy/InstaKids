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
        
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SketchCell.self, forCellReuseIdentifier: SketchCell.reuseID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PersistanceManager.retrieveSketches { (result) in
            switch result{
            case .success(let sketches):
                self.sketches = sketches
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SketchCell.reuseID, for: indexPath) as! SketchCell
        let thumbnail = sketches[indexPath.row].thumbnailImage

        cell.set(with: thumbnail)

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
