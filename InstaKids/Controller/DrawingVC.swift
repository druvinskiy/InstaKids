//
//  DrawingVC.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/23/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import PencilKit
import JGProgressHUD

protocol DrawingVCDelegate {
    func didCreateDrawing()
}

class DrawingVC: UIViewController {
    
    var sketch: Sketch?
    var canvasView: PKCanvasView!
    //var creatingProfileDrawing = false
    var createProfileDrawing: ((UIImage) -> Void)?
    //var delegate: DrawingVCDelegate?
    var done: (() -> Void)?
    
    fileprivate let saveHUD = JGProgressHUD(style: .dark)
    
    let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
    
    init(sketch: Sketch?) {
        super.init(nibName: nil, bundle: nil)
        
        self.sketch = sketch
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
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
        saveButton.isEnabled = false
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        canvasView.backgroundColor = .offWhite
        
        setupToolPicker()
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setNavigationBar() {
        navigationItem.rightBarButtonItems = []
        
        let undoItem = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undo))
        
        let redoItem = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redo))
        
        if createProfileDrawing == nil {
            navigationItem.rightBarButtonItems?.append(saveButton)
        }
        
        navigationItem.rightBarButtonItems?.append(undoItem)
        navigationItem.rightBarButtonItems?.append(redoItem)
        
        //navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolPicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let createProfileDrawing = createProfileDrawing {
            createProfileDrawing(createImage())
            navigationController?.popViewController(animated: true)
            return
        }
        
        didCreateDrawing()
    }
    
    func createImage() -> UIImage {
        let drawing = canvasView.drawing
        let image = drawing.image(from: canvasView.frame, scale: 3.0)
        let imageWithBackgroundColor = image.withBackground(color: createProfileDrawing != nil ? UIColor.offWhite : .white)
        
        return imageWithBackgroundColor
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
    
    @objc func undo() {
        undoManager?.undo()
    }
    
    @objc func redo() {
        undoManager?.redo()
    }
    
    @objc func save() {
        saveHUD.textLabel.text = "Saving"
        saveHUD.show(in: self.view)
        
        view.isUserInteractionEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.tintColor = UIColor.clear
        
        navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.isEnabled = false
        })
        
        SketchService.saveSketch(drawing: canvasView.drawing, thumbnailImage: createImage(), sketchId: sketch?.sketchId) { (sketch) in
            self.sketch = sketch
            self.saveHUD.dismiss(animated: true)
            
            self.view.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.tintColor = .white
            
            self.navigationItem.rightBarButtonItems?.forEach({ (button) in
                button.isEnabled = true
            })
            
            self.saveButton.isEnabled = false
            self.didCreateDrawing()
            
        }
    }
    
    func didCreateDrawing() {
        //self.delegate?.didCreateDrawing()
        done?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawingVC: PKToolPickerObserver {
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
            //            navigationItem.leftBarButtonItems = [undoButton, redoButton]
        }
    }
}

extension DrawingVC: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        saveButton.isEnabled = true
    }
}
