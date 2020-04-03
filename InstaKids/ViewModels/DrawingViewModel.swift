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
    
    var saveShouldBeEnabled = Bindable<Bool>()
            
    var bindableIsSaving = Bindable<Bool>()
    
    var didDownloadDrawing = Bindable<PKDrawing>()
    
    private var count: Int = 0 {
        willSet {
            if newValue != 0 {
                saveShouldBeEnabled.value = true
            } else {
                saveShouldBeEnabled.value = false
            }
        }
    }
    
    var sketch: Sketch! {
        willSet {
            
            SketchService.downloadData(from: newValue.drawingUrl!) { (result) in
                
                switch result {
                    
                case .success(let data):
                    
                    do {
                        
                        let drawing = try PKDrawing(data: data)
                        self.didDownloadDrawing.value = drawing
                        
                    } catch {
                        
                        self.didDownloadDrawing.value = nil
                    }
                    
                case .failure(_):
                    
                    self.didDownloadDrawing.value = nil
                }
                
            }
            
        }
    }
    
    func didPressUndo() {
        count -= 1
    }
    
    func didPressRedo() {
        count += 1
    }
    
    func didEndUsingTool() {
        count += 1
    }
    
    func saveSketch(_ drawing: PKDrawing, and image: UIImage) {
        bindableIsSaving.value = true
        
        SketchService.saveSketch(drawing: drawing, thumbnailImage: image, sketchId: sketch?.sketchId) { (sketch) in
            
            self.bindableIsSaving.value = false
        }
    }
}
