//
//  ARUtils.swift
//  ARView
//
//  Created by user on 5/17/22.
//

import ARKit

extension float4x4 {
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }

    var orientation: simd_quatf {
        return simd_quaternion(self)
    }

    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}
