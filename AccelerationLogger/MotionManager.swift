import CoreMotion
import Foundation

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var rawAccelerometerData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var gravity: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var rotationmatrix:[String: Double] = ["x": 0.0,  "y":0.0, "z": 0.0]
    @Published var quaternion:[String: Double] = ["x": 0.0,  "y":0.0, "z": 0.0]
    @Published var attitude:[String: Double] = ["x": 0.0,  "y":0.0, "z": 0.0]
    @Published var globalData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var liner: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var diff: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var velocity: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var distance: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    @Published var average: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    
    private let threshold = 0.1
    
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
                    self.updateAttitudeData(from: motion)
//                    self.updateGlobalData(from: motion)
                    self.calculateGlobal(from: motion)
                    self.updateGravityData(from: motion)
                    self.updateUserAccelerationData(from: motion)
                    self.calculateDifferenceData()
                    self.calculateVelocity()
                    self.calculateDistance()
//                    self.updateQuaternionData(from: motion)
//                    self.updateRotationMatrixData(from: motion)
//                    self.calculateVelocity()
//                    self.calculateDistance()
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
    
    private func updateAttitudeData(from motion: CMDeviceMotion) {
        self.attitude = [
            "x": motion.attitude.roll,
            "y": motion.attitude.pitch,
            "z": motion.attitude.yaw
        ]
    }

//    private func updateGlobalData(from motion: CMDeviceMotion) {
//        let rotationMatrix = motion.attitude.rotationMatrix
//        let ax = rawAccelerometerData["x"] ?? 0.0
//        let ay = rawAccelerometerData["y"] ?? 0.0
//        let az = rawAccelerometerData["z"] ?? 0.0
//
//        self.globalData = [
//            "x": rotationMatrix.m11 * ax + rotationMatrix.m12 * ay + rotationMatrix.m13 * az,
//            "y": rotationMatrix.m21 * ax + rotationMatrix.m22 * ay + rotationMatrix.m23 * az,
//            "z": rotationMatrix.m31 * ax + rotationMatrix.m32 * ay + rotationMatrix.m33 * az
//        ]
//    }
//    private func updateGlobalData() {
//        // オイラー角の取得
//        let roll = attitude["x"] ?? 0.0   // x軸周りの回転 (ラジアン)
//        let pitch = attitude["y"] ?? 0.0// y軸周りの回転 (ラジアン)
//        let yaw = attitude["z"] ?? 0.0    // z軸周りの回転 (ラジアン)
//        
//        // 加速度データ
//        let ax = rawAccelerometerData["x"] ?? 0.0
//        let ay = rawAccelerometerData["y"] ?? 0.0
//        let az = rawAccelerometerData["z"] ?? 0.0
//        
//        // 回転行列をオイラー角から構築
//        let cosRoll = cos(roll)
//        let sinRoll = sin(roll)
//        let cosPitch = cos(pitch)
//        let sinPitch = sin(pitch)
//        let cosYaw = cos(yaw)
//        let sinYaw = sin(yaw)
//
//        let rotationMatrix = [
//            [cosPitch * cosYaw, cosPitch * sinYaw, -sinPitch],
//            [sinRoll * sinPitch * cosYaw - cosRoll * sinYaw, sinRoll * sinPitch * sinYaw + cosRoll * cosYaw, sinRoll * cosPitch],
//            [cosRoll * sinPitch * cosYaw + sinRoll * sinYaw, cosRoll * sinPitch * sinYaw - sinRoll * cosYaw, cosRoll * cosPitch]
//        ]
//        
//        // グローバル加速度を計算
//        self.globalData = [
//            "x": rotationMatrix[0][0] * ax + rotationMatrix[0][1] * ay + rotationMatrix[0][2] * az,
//            "y": rotationMatrix[1][0] * ax + rotationMatrix[1][1] * ay + rotationMatrix[1][2] * az,
//            "z": rotationMatrix[2][0] * ax + rotationMatrix[2][1] * ay + rotationMatrix[2][2] * az
//        ]
//    }

    private func updateGravityData(from motion: CMDeviceMotion) {
        self.gravity = [
            "x": motion.gravity.x * self.gToMetersPerSecondSquared,
            "y": motion.gravity.y * self.gToMetersPerSecondSquared,
            "z": motion.gravity.z * self.gToMetersPerSecondSquared
        ]
    }
    
    private func calculateGlobal(from motion: CMDeviceMotion){
        let rotationMatrix = motion.attitude.rotationMatrix
        // 加速度データ
        let ax = rawAccelerometerData["x"] ?? 0.0
        let ay = rawAccelerometerData["y"] ?? 0.0
        let az = rawAccelerometerData["z"] ?? 0.0
        
        // 重力成分データ
        let gx = gravity["x"] ?? 0.0
        let gy = gravity["y"] ?? 0.0
        let gz = gravity["z"] ?? 0.0
        
        let localAccX = ax - gx
        let localAccY = ay - gy
        let localAccZ = az - gz
        
        self.globalData = [
            "x": rotationMatrix.m11 * localAccX + rotationMatrix.m12 * localAccY + rotationMatrix.m13 * localAccZ,
            "y": rotationMatrix.m21 * localAccX + rotationMatrix.m22 * localAccY + rotationMatrix.m23 * localAccZ,
            "z": rotationMatrix.m31 * localAccX + rotationMatrix.m32 * localAccY + rotationMatrix.m33 * localAccZ
        ]
        // ローパスフィルタを適用
//        applyLowPassFilter(to: globalData)
        // カルマンフィルタを適用
//        applyKalmanFilter(to: globalData)
        
        // 移動平均を計算
        updateMovingAverage(with: globalData)
    }
    
    private var xBuffer: [Double] = []
    private var yBuffer: [Double] = []
    private var zBuffer: [Double] = []
    private let bufferSize = 100

//    private func updateMovingAverage(with globalData: [String: Double]) {
//        // X成分の更新
//        xBuffer.append(globalData["x"] ?? 0.0)
//        if xBuffer.count > bufferSize {
//            xBuffer.removeFirst()
//        }
//        let xAverage = xBuffer.reduce(0.0, +) / Double(xBuffer.count)
//
//        // Y成分の更新
//        yBuffer.append(globalData["y"] ?? 0.0)
//        if yBuffer.count > bufferSize {
//            yBuffer.removeFirst()
//        }
//        let yAverage = yBuffer.reduce(0.0, +) / Double(yBuffer.count)
//
//        // Z成分の更新
//        zBuffer.append(globalData["z"] ?? 0.0)
//        if zBuffer.count > bufferSize {
//            zBuffer.removeFirst()
//        }
//        let zAverage = zBuffer.reduce(0.0, +) / Double(zBuffer.count)
//
//        // 平均値をPublished変数に格納
//        DispatchQueue.main.async {
//            self.average = ["x": xAverage, "y": yAverage, "z": zAverage]
//        }
//    }
    private func updateMovingAverage(with globalData: [String: Double]) {
        // X成分の更新
        xBuffer.append(globalData["x"] ?? 0.0)
        if xBuffer.count > bufferSize {
            xBuffer.removeFirst()
        }
        let xAverage = xBuffer.reduce(0.0, +) / Double(xBuffer.count)
        let xProcessed = abs(xAverage) <= threshold ? 0.0 : xAverage

        // Y成分の更新
        yBuffer.append(globalData["y"] ?? 0.0)
        if yBuffer.count > bufferSize {
            yBuffer.removeFirst()
        }
        let yAverage = yBuffer.reduce(0.0, +) / Double(yBuffer.count)
        let yProcessed = abs(yAverage) <= threshold ? 0.0 : yAverage

        // Z成分の更新
        zBuffer.append(globalData["z"] ?? 0.0)
        if zBuffer.count > bufferSize {
            zBuffer.removeFirst()
        }
        let zAverage = zBuffer.reduce(0.0, +) / Double(zBuffer.count)
        let zProcessed = abs(zAverage) <= threshold ? 0.0 : zAverage

        // 平均値をPublished変数に格納
        DispatchQueue.main.async {
//            self.average = ["x": xProcessed, "y": yProcessed, "z": zProcessed]
            self.average = ["x": xAverage, "y": yAverage, "z": zAverage]
        }
    }
    
    private func updateUserAccelerationData(from motion: CMDeviceMotion) {
        self.liner = [
            "x": motion.userAcceleration.x,
            "y": motion.userAcceleration.y,
            "z": motion.userAcceleration.z
        ]
    }
    private func calculateDifferenceData() {
        self.diff = [
            "x": globalData["x"]! - liner["x"]!,
            "y": globalData["y"]! - liner["y"]!,
            "z": globalData["z"]! - liner["z"]!
        ]
    }
//    private func calculateVelocity() {
//        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
//        self.velocity = [
//            "x": velocity["x"]! + (abs(globalData["x"]!) < 0.1 ? 0.0 : globalData["x"]!) * dt * 3.6,
//            "y": velocity["y"]! + (abs(globalData["y"]!) < 0.1 ? 0.0 : globalData["y"]!) * dt * 3.6,
//            "z": velocity["z"]! + (abs(globalData["z"]!) < 0.1 ? 0.0 : globalData["z"]!) * dt * 3.6
//        ]
//    }
//
//    private func calculateDistance() {
//        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
//        self.distance = [
//            "x": distance["x"]! + abs(velocity["x"]!) * dt,
//            "y": distance["y"]! + abs(velocity["y"]!) * dt,
//            "z": distance["z"]! + abs(velocity["z"]!) * dt
//        ]
//    }
    private func calculateVelocity() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
//        let dt = 1.0
        self.velocity = [
            "x": velocity["x"]! + average["x"]! * dt * 3.6,
            "y": velocity["y"]! + average["y"]! * dt * 3.6,
            "z": velocity["z"]! + average["z"]! * dt * 3.6
        ]
    }

    private func calculateDistance() {
        let dt = motionManager.deviceMotionUpdateInterval // 更新間隔
        self.distance = [
            "x": distance["x"]! + abs(velocity["x"]!) * dt / 1000,
            "y": distance["y"]! + abs(velocity["y"]!) * dt / 1000,
            "z": distance["z"]! + abs(velocity["z"]!) * dt / 1000
        ]
    }
    
    
    func resetData() {
        DispatchQueue.main.async {
            self.rawAccelerometerData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.globalData = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.gravity = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.velocity = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.distance = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.attitude = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.average = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.liner = ["x": 0.0, "y": 0.0, "z": 0.0]
            self.diff = ["x": 0.0, "y": 0.0, "z": 0.0]
        }
    }

    deinit {
        stopSensors()
    }
    private var kalmanState: [String: (Double, Double)] = [
        "x": (0.0, 1.0), // 初期値 (推定値, 推定誤差)
        "y": (0.0, 1.0),
        "z": (0.0, 1.0)
    ]
    private let processNoise: Double = 0.01 // プロセスノイズ
    private let measurementNoise: Double = 0.1 // 測定ノイズ

    // カルマンフィルタの適用
    private func applyKalmanFilter(to newData: [String: Double]) {
        for axis in ["x", "y", "z"] {
            var (estimate, error) = kalmanState[axis]!
            
            // 予測ステップ
            error += processNoise
            
            // 更新ステップ
            let kalmanGain = error / (error + measurementNoise)
            estimate += kalmanGain * (newData[axis]! - estimate)
            error *= (1 - kalmanGain)
            
            // 状態更新
            kalmanState[axis] = (estimate, error)
        }
    }
    private var filteredGlobalData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
    private let alpha: Double = 0.1 // フィルタ係数 (0.0 ~ 1.0)

    // ローパスフィルタの適用
    private func applyLowPassFilter(to newData: [String: Double]) {
        filteredGlobalData["x"] = alpha * newData["x"]! + (1 - alpha) * filteredGlobalData["x"]!
        filteredGlobalData["y"] = alpha * newData["y"]! + (1 - alpha) * filteredGlobalData["y"]!
        filteredGlobalData["z"] = alpha * newData["z"]! + (1 - alpha) * filteredGlobalData["z"]!
    }
}
