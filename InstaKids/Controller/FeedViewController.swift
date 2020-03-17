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
    
    private let sketchDataSource = SketchDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        sketchDataSource.observers.append(self)
        
//        navigationItem.rightBarButtonItem =
//        UIBarButtonItem(
//          barButtonSystemItem: .add,
//          target: self,
//          action: #selector(addDrawing(_:)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addDrawing(_ sender: UIBarButtonItem) {
      sketchDataSource.addDrawing()
      tableView.reloadData()
    }
}

extension FeedViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sketchDataSource.sketches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Get a photo cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! SketchCell
        
        cell.backgroundColor = UIColor.lightGray
        cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        if let thumbnailImage = sketchDataSource.sketches[indexPath.row].thumbnailImage {
          cell.sketchImage = thumbnailImage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let drawingViewController = storyboard?.instantiateViewController(identifier: "DrawingViewController") as? DrawingViewController,
          let navigationController = navigationController else {
            return
        }
        drawingViewController.sketch = sketchDataSource.sketches[indexPath.row]
        drawingViewController.sketchDataSource = sketchDataSource
        navigationController.pushViewController(drawingViewController, animated: true)
    }
}

extension FeedViewController: SketchDataSourceObserver {
  func thumbnailDidUpdate(_ thumbnail: UIImage) {
    tableView.reloadData()
  }
}
