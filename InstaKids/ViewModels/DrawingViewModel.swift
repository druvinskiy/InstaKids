//
//  DrawingViewModel.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/31/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import PencilKit

class DrawingViewModel: NSObject {
    
    var bindableCanSave = Bindable<Bool>()
    var bindableCanEdit = Bindable<Bool>()
    
    private var oldDrawing: PKDrawing?
    
    var sketch: Sketch? {
        didSet {
            if sketch != nil {
                
                SketchService.downloadData(from: sketch!.drawingUrl!) { (data) in
                    let drawing = try! PKDrawing(data: data)
                    
                    self.canvasView.drawing = drawing
                    self.oldDrawing = drawing
                }
            }
            
            checkCanEdit()
        }
    }
    
    var canvasView: PKCanvasView! { didSet {
        canvasView.allowsFingerDrawing = true
        canvasView.delegate = self
        }
    }
    
    func checkCanSave() {
        let canSave = !canvasView.drawing.bounds.isEmpty
        bindableCanSave.value = canSave
    }
    
    func checkCanEdit() {
        guard let currentUser = LocalStorageService.loadCurrentUser() else { return }
        let userId = currentUser.userId!
        
        let canEdit = sketch?.byId == userId
        
        bindableCanEdit.value = canEdit
    }
    
    func saveSketch(and image: UIImage, completion: @escaping (() -> Void)) {
        SketchService.saveSketch(drawing: canvasView.drawing, thumbnailImage: image, sketchId: sketch?.sketchId) { (sketch) in
            
            self.sketch = sketch
            self.bindableCanSave.value?.toggle()
            completion()
        }
    }
}

extension DrawingViewModel: PKCanvasViewDelegate {    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        checkCanSave()
    }
}
