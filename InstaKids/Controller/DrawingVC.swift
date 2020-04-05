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
    
    var drawingViewModel = DrawingViewModel()
    
    fileprivate let saveHUD = JGProgressHUD(style: .dark)
    
    let saveButton = IKDrawingButton(title: "Save", style: .done, target: self, action: #selector(save))
    let undoItem = IKDrawingButton(title: "Undo", style: .plain, target: self, action: #selector(undo))
    let redoItem = IKDrawingButton(title: "Redo", style: .plain, target: self, action: #selector(redo))
    lazy var backButton = IKDrawingButton(title: createProfileDrawing == nil ? "Back" : "Save", style: .done, target: self, action: #selector(didPressBack), isHidden: false)
    
    lazy var canvasView: PKCanvasView = {
        let cv = PKCanvasView(frame: view.bounds)
        view.addSubview(cv)
        cv.isUserInteractionEnabled = false
        cv.allowsFingerDrawing = true
        cv.backgroundColor = .offWhite
        return cv
    }()
    
    init(sketch: Sketch?, createProfileDrawing: ((UIImage) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        
        self.createProfileDrawing = createProfileDrawing
        
        setNavigationBar()
        setupBindables()
        
        if let sketch = sketch {
            drawingViewModel.sketch = sketch
        } else {
            enableDrawing()
            self.canvasView.delegate = self
        }
        
        self.hidesBottomBarWhenPushed = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoRedoUI), name: .NSUndoManagerDidUndoChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoRedoUI), name: .NSUndoManagerDidRedoChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoRedoUI), name: .NSUndoManagerDidOpenUndoGroup, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupToolPicker()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    fileprivate func setupBindables() {
        
        drawingViewModel.saveShouldBeEnabled.bind { [weak self] (saveEnabled) in
            guard let self = self,
                let saveEnabled = saveEnabled else { return }
            
            self.saveButton.isEnabled = saveEnabled
        }
        
        drawingViewModel.didDownloadDrawing.bind { [weak self] (drawing) in
            
            if let self = self,
                let drawing = drawing,
                let currentUser = LocalStorageService.loadCurrentUser() {
                
                self.canvasView.drawing = drawing
                self.canvasView.delegate = self
                
                let userId = currentUser.userId!
                
                if self.drawingViewModel.sketch!.byId == userId {
                    self.enableDrawing()
                } else {
                    self.canvasView.delegate = self
                }
            }
        }
        
        drawingViewModel.bindableIsSaving.bind { [weak self] (isSaving) in
            guard let self = self,
                let isSaving = isSaving else { return }
            
            if isSaving {
                self.saveHUD.textLabel.text = "Saving"
                self.saveHUD.show(in: self.view)
                
                self.view.isUserInteractionEnabled = false
                self.rightBarButtonItems(shouldBeVisible: false, backButtonShouldBeVisible: false)
            } else {
                self.saveHUD.dismiss(animated: true)
                self.view.isUserInteractionEnabled = true
                self.rightBarButtonItems(shouldBeVisible: true)
                self.didCreateDrawing()
            }
        }
    }
    
    private func enableDrawing() {
        rightBarButtonItems(shouldBeVisible: true)
        canvasView.becomeFirstResponder()
        canvasView.isUserInteractionEnabled = true
    }
    
    func rightBarButtonItems(shouldBeVisible: Bool, backButtonShouldBeVisible: Bool = true) {
        guard let rightBarButtonItems = navigationItem.rightBarButtonItems as? [IKDrawingButton], let leftBarButtonItem = navigationItem.leftBarButtonItem as? IKDrawingButton else { return }
        rightBarButtonItems.forEach({ $0.isHidden = !shouldBeVisible })
        //rightBarButtonItems.forEach({ $0.isEnabled = !$0.isHidden })
        //self.navigationItem.setHidesBackButton(!backButtonShouldBeVisible, animated: false)
        leftBarButtonItem.isHidden = !backButtonShouldBeVisible
    }
    
    func setNavigationBar() {
        navigationItem.rightBarButtonItems = []
        
        if createProfileDrawing == nil {
            navigationItem.rightBarButtonItems?.append(saveButton)
        }
        
        navigationItem.rightBarButtonItems?.append(undoItem)
        navigationItem.rightBarButtonItems?.append(redoItem)
        
        navigationItem.leftBarButtonItem = backButton
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
        let imageWithBackgroundColor = image.withBackground(color: .white)
        
        return imageWithBackgroundColor
    }
    
    func setupToolPicker() {
        if let window = self.parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            //            drawingViewModel.canvasView.becomeFirstResponder()
            toolPicker.addObserver(self)
            updateTools(toolPicker)
        }
    }
    
    @objc func undo() {
        if let undoManager = undoManager, undoManager.canUndo {
            
            drawingViewModel.didPressUndo()
            undoManager.undo()
            //updateUndoRedoUI()
            
        }
    }
    
    @objc func redo() {
        if let undoManager = undoManager, undoManager.canRedo {
            
            drawingViewModel.didPressRedo()
            undoManager.redo()
            //updateUndoRedoUI()
        }
    }
    
    @objc func updateUndoRedoUI() {
        guard let undoManager = undoManager else { return }
        
        undoItem.isEnabled = undoManager.canUndo
        redoItem.isEnabled = undoManager.canRedo
    }
    
    @objc func save() {
        drawingViewModel.saveSketch(canvasView.drawing, and: createImage())
    }
    
    func didCreateDrawing() {
        self.hidesBottomBarWhenPushed = false
        done?()
    }
    
    @objc func didPressBack() {
        guard createProfileDrawing == nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if saveButton.isEnabled {
            presentIKAlertOnMainThread(title: "Save?", message: "Do you want to save changes to your beautiful drawing 😎 ?", positiveButtonTitle: "Yes", positiveButtonAction: { [weak self] in
                
                guard let self = self else { return }
                self.save()
                
            }, negativeButtonTitle: "No") {
                
                self.didCreateDrawing()
            }
            
            return
        }
        
        self.didCreateDrawing()
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
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        //updateUndoRedoUI()
        drawingViewModel.didEndUsingTool()
    }
}
