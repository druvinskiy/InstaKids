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
import JGProgressHUD

class DrawingViewController: UIViewController {
    
    static let reuseID = "DrawingNavigationControllerID"
    var sketch: Sketch?
    var canvasView: PKCanvasView!
    var creatingProfileDrawing = false
    var handleCreateProfileDrawing: ((UIImage) -> Void)?
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    fileprivate let saveHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.leftItemsSupplementBackButton = true
        
        let canvasView = PKCanvasView(frame: view.bounds)
        self.canvasView = canvasView
        canvasView.allowsFingerDrawing = true
        view.addSubview(canvasView)
        
        if let sketch = sketch {
            SketchService.downloadData(from: sketch.drawingUrl!) { (data) in
                self.canvasView.drawing = try! PKDrawing(data: data)
                canvasView.delegate = self
                self.saveButton.isEnabled = false
            }
        }
        
        canvasView.delegate = self
        self.saveButton.isEnabled = false
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        canvasView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        canvasView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        canvasView.backgroundColor = .offWhite
        
        //setupToolPicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolPicker()
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
        let imageWithBackgroundColor = image.withBackground(color: .white)
        
        saveHUD.textLabel.text = "Saving"
        //saveHUD.show(in: self.view)
        
        view.isUserInteractionEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.tintColor = UIColor.lightGray
        
        navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.isEnabled = false
        })
        
        if creatingProfileDrawing {
            if let handleProfileDrawing = handleCreateProfileDrawing {
                handleProfileDrawing(imageWithBackgroundColor)
                dismiss(animated: true)
                return
            }
        }

        SketchService.saveSketch(drawing: drawing, thumbnailImage: imageWithBackgroundColor, sketchId: sketch?.sketchId) { (sketch) in
            self.sketch = sketch
            self.saveHUD.dismiss(animated: true)
            
            self.view.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.tintColor = .white
            
            self.navigationItem.rightBarButtonItems?.forEach({ (button) in
                button.isEnabled = true
            })
            
            self.saveButton.isEnabled = false
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

extension DrawingViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        saveButton.isEnabled = true
    }
}

