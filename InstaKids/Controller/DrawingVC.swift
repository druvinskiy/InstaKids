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
    
    var createProfileDrawing: ((UIImage) -> Void)?
    var done: (() -> Void)?
    
    let drawingViewModel = DrawingViewModel()
    
    fileprivate let saveHUD = JGProgressHUD(style: .dark)
    
    let saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        button.isEnabled = false
        return button
    }()
    

    let undoItem = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undo))
    let redoItem = UIBarButtonItem(title: "Redo", style: .plain, target: self, action: #selector(redo))
    
    init(sketch: Sketch?) {
        super.init(nibName: nil, bundle: nil)
        
        drawingViewModel.sketch = sketch
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupBindables()
        
        let canvasView = PKCanvasView(frame: view.bounds)
        drawingViewModel.canvasView = canvasView
        view.addSubview(canvasView)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        canvasView.backgroundColor = .offWhite
        
        setupToolPicker()
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    fileprivate func setupBindables() {
        
        
        drawingViewModel.bindableCanSave.bind { (canSave) in
            guard let canSave = canSave else { return }
            self.saveButton.isEnabled = canSave
        }
        
        drawingViewModel.bindableCanEdit.bind { (canEdit) in
            guard let canEdit = canEdit else { return }

            self.saveButton.isEnabled = canEdit
            self.toggleRightBarButtonItems(color: .clear)

            if !canEdit { self.drawingViewModel.canvasView.resignFirstResponder() }
        }
    }
    
    func setNavigationBar() {
        navigationItem.rightBarButtonItems = []
        
        if createProfileDrawing == nil {
            navigationItem.rightBarButtonItems?.append(saveButton)
        }
        
        navigationItem.rightBarButtonItems?.append(undoItem)
        navigationItem.rightBarButtonItems?.append(redoItem)
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
        let drawing =  drawingViewModel.canvasView.drawing
        let image = drawing.image(from: drawingViewModel.canvasView.frame, scale: 3.0)
        let imageWithBackgroundColor = image.withBackground(color: .white)
        
        return imageWithBackgroundColor
    }
    
    func setupToolPicker() {
        if let window = self.parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: drawingViewModel.canvasView)
            toolPicker.addObserver(drawingViewModel.canvasView)
            drawingViewModel.canvasView.becomeFirstResponder()
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
        toggleRightBarButtonItems(color: .clear)
        
        drawingViewModel.saveSketch(and: createImage()) {
            self.saveHUD.dismiss(animated: true)
            self.view.isUserInteractionEnabled = true
            self.toggleRightBarButtonItems(color: .white)
            
            self.didCreateDrawing()
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    func didCreateDrawing() {
        done?()
    }
    
    func toggleRightBarButtonItems(color: UIColor) {
        navigationController?.navigationBar.isUserInteractionEnabled.toggle()
        navigationController?.navigationBar.tintColor = color
        
        undoItem.isEnabled.toggle()
        redoItem.isEnabled.toggle()
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

//extension DrawingVC: PKCanvasViewDelegate {
//
//    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        saveButton.isEnabled = true
//    }
//}
