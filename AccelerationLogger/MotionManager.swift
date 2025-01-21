import CoreMotion
import Foundation

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    @Published var accelerationData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var rawAccelerometerData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var globalData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var userAccelerationData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var gravityData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var gyroData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var magneticFieldData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var differenceData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]

    private let gToMetersPerSecondSquared = 9.80665
    private var isRunning = false

    init() {}

    func startSensors() {
        if isRunning { return }
        isRunning = true

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01 // Update interval in seconds
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: queue) { [weak self] (deviceMotion, error) in
                guard let self = self, let motion = deviceMotion, error == nil else { return }

                DispatchQueue.main.async {
                    self.updateAccelerationData(from: motion)
                    self.updateGlobalData(from: motion)
                    self.updateUserAccelerationData(from: motion)
                    self.updateGravityData(from: motion)
                    self.updateGyroData(from: motion)
                    self.updateMagneticFieldData(from: motion)
                    self.calculateDifferenceData()
                }
            }
        }

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01 // Update interval in seconds
            motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data, error) in
                guard let self = self, let data = data, error == nil else { return }

                DispatchQueue.main.async {
                    self.rawAccelerometerData = [
                        "x": data.acceleration.x * self.gToMetersPerSecondSquared,
                        "y": data.acceleration.y * self.gToMetersPerSecondSquared,
                        "z": data.acceleration.z * self.gToMetersPerSecondSquared
                    ]
                }
            }
        }
    }

    func stopSensors() {
        if !isRunning { return }
        isRunning = false

        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }

    private func updateAccelerationData(from motion: CMDeviceMotion) {
        self.accelerationData = [
            "x": self.rawAccelerometerData["x"] ?? 0.0,
            "y": self.rawAccelerometerData["y"] ?? 0.0,
            "z": self.rawAccelerometerData["z"] ?? 0.0
        ]
    }

    private func updateGlobalData(from motion: CMDeviceMotion) {
        let rotationMatrix = motion.attitude.rotationMatrix
        let ax = accelerationData["x"] ?? 0.0
        let ay = accelerationData["y"] ?? 0.0
        let az = accelerationData["z"] ?? 0.0

        self.globalData = [
            "x": rotationMatrix.m11 * ax + rotationMatrix.m12 * ay + rotationMatrix.m13 * az,
            "y": rotationMatrix.m21 * ax + rotationMatrix.m22 * ay + rotationMatrix.m23 * az,
            "z": rotationMatrix.m31 * ax + rotationMatrix.m32 * ay + rotationMatrix.m33 * az
        ]
    }

    private func updateUserAccelerationData(from motion: CMDeviceMotion) {
        self.userAccelerationData = [
            "x": motion.userAcceleration.x,
            "y": motion.userAcceleration.y,
            "z": motion.userAcceleration.z
        ]
    }

    private func updateGravityData(from motion: CMDeviceMotion) {
        self.gravityData = [
            "x": motion.gravity.x  * self.gToMetersPerSecondSquared,
            "y": motion.gravity.y  * self.gToMetersPerSecondSquared,
            "z": motion.gravity.z  * self.gToMetersPerSecondSquared
        ]
    }

    private func updateGyroData(from motion: CMDeviceMotion) {
        self.gyroData = [
            "x": motion.rotationRate.x,
            "y": motion.rotationRate.y,
            "z": motion.rotationRate.z
        ]
    }
    private func updateMagneticFieldData(from motion: CMDeviceMotion) {
        let magneticField = motion.magneticField.field
        DispatchQueue.main.async {
            self.magneticFieldData = [
                "x": magneticField.x,
                "y": magneticField.y,
                "z": magneticField.z
            ]
        }
    }

    private func calculateDifferenceData() {
        let linearAcceleration = [
            "x": accelerationData["x"]! - gravityData["x"]!,
            "y": accelerationData["y"]! - gravityData["y"]!,
            "z": accelerationData["z"]! - gravityData["z"]!
        ]

        self.differenceData = [
            "x": userAccelerationData["x"]! - linearAcceleration["x"]!,
            "y": userAccelerationData["y"]! - linearAcceleration["y"]!,
            "z": userAccelerationData["z"]! - linearAcceleration["z"]!
        ]
    }

    func resetData() {
        DispatchQueue.main.async {
            self.accelerationData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.rawAccelerometerData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.globalData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.userAccelerationData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.gravityData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.gyroData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.magneticFieldData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.differenceData = ["x": 0.0, "y": 0.0, "z": 0.0]
        }
    }

    deinit {
        stopSensors()
    }
}
