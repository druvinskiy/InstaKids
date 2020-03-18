//
//  PersistanceManager.swift
//  InstaKids
//
//  Created by Richard Witherspoon on 3/17/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation

enum PersistanceManager{
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let sketches = "sketches"
    }
    
    static func save(sketch: Sketch){
        retrieveSketches { (result) in
            switch result{
            case .success(var retrivedSketches):
                if let row = retrivedSketches.firstIndex(where: {$0 == sketch}) {
                       retrivedSketches[row] = sketch
                } else {
                    retrivedSketches.append(sketch)
                }
                
                do {
                    let encoder = JSONEncoder()
                    let encoded = try encoder.encode(retrivedSketches)
                    defaults.set(encoded, forKey: Keys.sketches)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func retrieveSketches(completed: @escaping (Result<[Sketch], Error>) -> Void){
        guard let sketchData = defaults.object(forKey: Keys.sketches) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decode = JSONDecoder()
            let sketches = try decode.decode([Sketch].self, from: sketchData)
            completed(.success(sketches))
        } catch{
            completed(.failure(error))
        }        
    }
}
