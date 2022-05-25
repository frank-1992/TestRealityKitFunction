//
//  ViewController.swift
//  BoxTest
//
//  Created by user on 5/23/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    public lazy var arView: ARView = {
        let arView = ARView(frame: view.bounds)
        arView.automaticallyConfigureSession = true
        arView.debugOptions = [.showAnchorOrigins, .showWorldOrigin]
        return arView
    }()
    
    var hasPlaced: Bool = false
    
    var boxEntity: ModelEntity?
    var boxAnchorEntity: AnchorEntity?
    
    var previousPlaneAnchor: ARPlaneAnchor?
    
    var originScale: SIMD3<Float>?
    var boundingBoxMin: SIMD3<Float>?
    var boundingBoxMax: SIMD3<Float>?
    
    var horizontalInitLocation: SIMD3<Float>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(arView)
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
    }
    

    @objc
    func didTap(_ sender: UITapGestureRecognizer) {
        if hasPlaced {
            return
        }
        
        let location = sender.location(in: arView)
        guard let rayCast = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first else { return }
        let boxEntity = createBox()
        boxEntity.generateCollisionShapes(recursive: true)
        let boxAnchor = AnchorEntity(plane: .horizontal, classification: .any, minimumBounds: SIMD2(x: 0.1, y: 0.1))
        boxAnchor.addChild(boxEntity)
        arView.scene.addAnchor(boxAnchor)
        
        
        let worldAnchorEntity = AnchorEntity(world: .zero)
        let convertPosition = worldAnchorEntity.convert(position: rayCast.worldTransform.translation, to: boxAnchor)
        boxEntity.position.x = convertPosition.x
        boxEntity.position.z = convertPosition.z
        
        horizontalInitLocation = convertPosition
        
        let convertBoxAnchorPosition = worldAnchorEntity.convert(position: boxAnchor.position, to: worldAnchorEntity)
        
        
        self.boxEntity = boxEntity
        self.boxAnchorEntity = boxAnchor
        
        arView.installGestures([.translation, .scale], for: boxEntity).forEach { recognizer in
            recognizer.addTarget(self, action: #selector(handleGesture(_:)))
        }
        
        if let planeAnchor = rayCast.anchor as? ARPlaneAnchor {
            previousPlaneAnchor = planeAnchor
        }
        
        hasPlaced = true
    }
    
    @objc
    func handleGesture(_ gesture: UIGestureRecognizer){
        guard let boxEntity = boxEntity,
              let boxAnchorEntity = boxAnchorEntity else {
            return
        }

        if let panGesture = gesture as? EntityTranslationGestureRecognizer {
            switch panGesture.state {
            case .changed:
                let currentLocation = panGesture.location(in: arView)
                guard let rayCast = arView.raycast(from: currentLocation, allowing: .estimatedPlane, alignment: .horizontal).first,
                      let currentPlaneAnchor = rayCast.anchor as? ARPlaneAnchor,
                      let previousPlaneAnchor = previousPlaneAnchor else {
                    return
                }
                if currentPlaneAnchor.identifier != previousPlaneAnchor.identifier {

//                    boxEntity.position.x = 0
//                    boxEntity.position.z = 0
                    
//                    boxAnchorEntity.removeChild(boxEntity)
//                    boxAnchorEntity.removeFromParent()
                    
//                    let newBoxAnchor = AnchorEntity(plane: .horizontal)
//                    newBoxAnchor.addChild(boxEntity)
//                    arView.scene.addAnchor(newBoxAnchor)
                    

                    
                    self.previousPlaneAnchor = currentPlaneAnchor
                }
            default:
                break
            }
        }
        
        if let scaleGesture = gesture as? EntityScaleGestureRecognizer {
            switch scaleGesture.state {
            case .began:
                if originScale == nil {
                    let scale = boxEntity.scale
                    originScale = scale
                }
            case .changed:
                guard let originScale = originScale else {
                    return
                }
                let scaleFactor = boxEntity.scale.y / originScale.y
                if boundingBoxMin == nil && boundingBoxMax == nil {
                    let boundingBox = boxEntity.visualBounds(relativeTo: boxEntity)
                    boundingBoxMin = boundingBox.min
                    boundingBoxMax = boundingBox.max
                }
                // set usdz local position == sceneKit node's pivot
                guard let min = boundingBoxMin else { return }
                let newMin = SIMD3(x: (min.x * scaleFactor), y: (min.y * scaleFactor), z: (min.z * scaleFactor))
                let y = abs(newMin.y)
                boxEntity.position.y = y
            default:
                break
            }
        }
    }
    
    
    
    func createBox() -> ModelEntity {
        let box = MeshResource.generateBox(width: 0.5, height: 0.5, depth: 0.5)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let entity = ModelEntity(mesh: box, materials: [material])
        entity.position.y = 0.25
        return entity
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    private func resetTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            switch config.frameSemantics {
            case [.personSegmentationWithDepth]:
                config.frameSemantics.remove(.personSegmentationWithDepth)
            default:
                config.frameSemantics.insert(.personSegmentationWithDepth)
            }
        }
        arView.session.run(config)
    }
    
}

