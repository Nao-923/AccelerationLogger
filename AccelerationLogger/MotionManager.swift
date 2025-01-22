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
    @Published var velocity: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var distance: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var corrected_velocity: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var corrected_distance: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var userVelocity: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var userDistance: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    
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
                    self.calculateVelocity()
                    self.calculateDistance()
                    self.calculateGlobalVelocity()
                    self.calculateGlobalDistance()
                    self.calculateUserVelocity()
                    self.calculateUserDistance()
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
    private func calculateVelocity() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔

        self.velocity = [
            "x": velocity["x"]! + (abs(rawAccelerometerData["x"]!) < 0.1 ? 0.0 : rawAccelerometerData["x"]!) * dt * 3.6,
            "y": velocity["y"]! + (abs(rawAccelerometerData["y"]!) < 0.1 ? 0.0 : rawAccelerometerData["y"]!) * dt * 3.6,
            "z": velocity["z"]! + (abs(rawAccelerometerData["z"]!) < 0.1 ? 0.0 : rawAccelerometerData["z"]!) * dt * 3.6
        ]
    }

    private func calculateDistance() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.distance = [
            "x": distance["x"]! + velocity["x"]! * dt / 1000,
            "y": distance["y"]! + velocity["y"]! * dt / 1000,
            "z": distance["z"]! + velocity["z"]! * dt / 1000
        ]
    }
    private func calculateGlobalVelocity() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.corrected_velocity = [
            "x": corrected_velocity["x"]! + (abs(globalData["x"]!) < 0.1 ? 0.0 : globalData["x"]!) * dt * 3.6,
            "y": corrected_velocity["y"]! + (abs(globalData["y"]!) < 0.1 ? 0.0 : globalData["y"]!) * dt * 3.6,
            "z": corrected_velocity["z"]! + (abs(globalData["z"]!) < 0.1 ? 0.0 : globalData["z"]!) * dt * 3.6
        ]
    }

    private func calculateGlobalDistance() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.corrected_distance = [
            "x": corrected_distance["x"]! + corrected_velocity["x"]! * dt / 1000,
            "y": corrected_distance["y"]! + corrected_velocity["y"]! * dt / 1000,
            "z": corrected_distance["z"]! + corrected_velocity["z"]! * dt / 1000
        ]
    }
    private func calculateUserVelocity() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.userVelocity = [
            "x": userVelocity["x"]! + (abs(userAccelerationData["x"]!) < 0.02 ? 0.0 : userAccelerationData["x"]!) * dt * 3.6,
            "y": userVelocity["y"]! + (abs(userAccelerationData["y"]!) < 0.02 ? 0.0 : userAccelerationData["y"]!) * dt * 3.6,
            "z": userVelocity["z"]! + (abs(userAccelerationData["z"]!) < 0.02 ? 0.0 : userAccelerationData["z"]!) * dt * 3.6
            
        ]
    }

    private func calculateUserDistance() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.userDistance = [
            "x": userDistance["x"]! + userVelocity["x"]! * dt / 1000,
            "y": userDistance["y"]! + userVelocity["y"]! * dt / 1000,
            "z": userDistance["z"]! + userVelocity["z"]! * dt / 1000
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
            self.velocity = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.distance = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.corrected_velocity = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.corrected_distance = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.userVelocity = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.userDistance = ["x": 0.0, "y": 0.0, "z": 0.0]
        }
    }

    deinit {
        stopSensors()
    }
}
