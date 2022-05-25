////
////  VirtualObject.swift
////  ARView
////
////  Created by user on 5/17/22.
////
//
//import UIKit
//import RealityKit
//import Combine
//
//class LoadUSDZ: NSObject {
//
//    static let shared = LoadUSDZ()
//
//    private override init() {}
//
//    // download model from local url
//    public func loadObjectFromFilePath(_ path: String, completion: @escaping (_ usdzAnchor: AnchorEntity, _ entity: Entity) -> Void) {
//        let usdzAnchor = AnchorEntity()
//        var cancellable: AnyCancellable? = nil
//
//        cancellable = Entity.loadAsync(contentsOf: URL(fileURLWithPath: path))
//            .sink(receiveCompletion: { error in
//                print("Unexpected error: \(error)")
//                cancellable?.cancel()
//            }, receiveValue: { usdzEntity in
//                usdzEntity.generateCollisionShapes(recursive: true)
//                let boundingBox = usdzEntity.visualBounds(relativeTo: usdzEntity)
//                print("boundingBox-y:  \(boundingBox.min.y)")
//                // usdz file 'cm' -> m
//                let y = abs(boundingBox.min.y/100.0)
//                let x = abs((boundingBox.min.x + (boundingBox.max.x - boundingBox.min.x)/2.0)/100)
//                let z = abs((boundingBox.min.z + (boundingBox.max.z - boundingBox.min.z)/2.0)/100)
//                usdzEntity.position.y = y
//
//                let height = boundingBox.max.y - boundingBox.min.y
//                let width = boundingBox.max.x - boundingBox.min.x
//                let depth = boundingBox.max.z - boundingBox.min.z
//                let edge = sqrt(width * width + depth * depth)
//
//                // add shadow plane to usdzEntity
//                let plane = MeshResource.generatePlane(width: edge, depth: edge, cornerRadius: edge/2.0)
//                let material = OcclusionMaterial(receivesDynamicLighting: true) //SimpleMaterial(color: .blue, roughness: 0, isMetallic: false)//OcclusionMaterial()
//                let planeEntity = ModelEntity(mesh: plane, materials: [material])
//                planeEntity.position = SIMD3(x: 0, y: -height/2-1, z: 0)
//                usdzEntity.addChild(planeEntity)
//
//                usdzAnchor.addChild(usdzEntity)
//                cancellable?.cancel()
//                completion(usdzAnchor, usdzEntity)
//                usdzEntity.startAnimation()
//            })
//    }
//}
//
//extension Entity: HasCollision {
//    func startAnimation() {
//        for animation in self.availableAnimations {
//            self.playAnimation(animation.repeat(), transitionDuration: 0.75, startsPaused: false)
//        }
//    }
//}
