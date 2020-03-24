//
//  DrawingViewController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import PencilKit
import FirebaseAuth

class DrawingViewController: UIViewController {
    
    static let reuseID = "DrawingViewControllerID"
    var sketch: Sketch?
    var canvasView: PKCanvasView!
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftItemsSupplementBackButton = true
        
        let canvasView = PKCanvasView(frame: view.bounds)
        self.canvasView = canvasView
        canvasView.allowsFingerDrawing = true
        view.addSubview(canvasView)
        
        if let sketch = sketch {
            SketchService.downloadData(from: sketch.drawingUrl!) { (data) in
                canvasView.drawing = try! PKDrawing(data: data)
            }
        }
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        canvasView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        canvasView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        canvasView.backgroundColor = .offWhite
        
        setupToolPicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //saveSketch()
    }
    
    func saveSketch() {
//        if sketch == nil {
//            let now = Date()
//            let newStekch = Sketch(thumbnailImage: imageWithBackgroundColor, drawing: drawing, dateCreated: now)
//            PersistanceManager.save(sketch: newStekch)
//
//            SketchService.saveSketch(drawing: drawing, thumbnailImage: imageWithBackgroundColor)
//
//        } else {
//            sketch?.drawing = drawing
//            sketch?.thumbnailImage = imageWithBackgroundColor
//            PersistanceManager.save(sketch: sketch!)
//
//            SketchService.saveSketch(drawing: drawing, thumbnailImage: imageWithBackgroundColor)
//        }
    }

    func setupToolPicker() {
        if let window = self.parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            toolPicker.addObserver(self)
            updateTools(toolPicker)
        }
    }
    
    @IBAction func undo(_ sender: UIBarButtonItem) {
        undoManager?.undo()
    }
    
    @IBAction func redo(_ sender: UIBarButtonItem) {
        undoManager?.redo()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let drawing = canvasView.drawing
        let image = drawing.image(from: canvasView.frame, scale: 3.0)
        let imageWithBackgroundColor = image.withBackground(color: .offWhite)
        
        SketchService.saveSketch(drawing: drawing, thumbnailImage: imageWithBackgroundColor, sketchId: sketch?.sketchId) { (sketch) in
            self.sketch = sketch
        }
    }
    
}

extension DrawingViewController: PKToolPickerObserver {
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        if let tool = toolPicker.selectedTool as? PKEraserTool {
            print("Eraser: \(tool.eraserType)")
        } else if let tool = toolPicker.selectedTool as? PKInkingTool {
            print("Ink: \(tool.inkType) Color: \(tool.color) Width: \(tool.width)")
        } else if let _ = toolPicker.selectedTool as? PKLassoTool {
            print("Lasso tool")
        }
    }
    
    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
        print("Ruler active: \(toolPicker.isRulerActive)")
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateTools(toolPicker)
    }
    
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateTools(toolPicker)
    }
    
    func updateTools(_ toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        if obscuredFrame.isNull {
            navigationItem.leftBarButtonItems = []
        } else {
            navigationItem.leftBarButtonItems = [undoButton, redoButton]
        }
    }
}

