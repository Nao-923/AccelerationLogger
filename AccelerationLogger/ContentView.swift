#Preview {
    ContentView()
}
import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = AccelerationLoggerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Acceleration Logger")
                .font(.largeTitle)
                .padding()

            Group {
                Text("生データ")
                    .font(.headline)
                HStack {
                    Text("x軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.rawAccelerationStringX)
                }
                HStack {
                    Text("y軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.rawAccelerationStringY)
                }
                HStack {
                    Text("z軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.rawAccelerationStringZ)
                }
            }

            Group {
                Text("グローバル")
                    .font(.headline)
                HStack {
                    Text("x軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.globalAccelerationStringX)
                }
                HStack {
                    Text("y軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.globalAccelerationStringY)
                }
                HStack {
                    Text("z軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.globalAccelerationStringZ)
                }
            }

            Group {
                Text("フィルタ後")
                    .font(.headline)
                HStack {
                    Text("x軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.filteredAccelerationStringX)
                }
                HStack {
                    Text("y軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.filteredAccelerationStringY)
                }
                HStack {
                    Text("z軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.filteredAccelerationStringZ)
                }
            }

            Group {
                Text("速度 (km/h)")
                    .font(.headline)
                HStack {
                    Text("x軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.velocityStringX)
                }
                HStack {
                    Text("y軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.velocityStringY)
                }
                HStack {
                    Text("z軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.velocityStringZ)
                }
            }

            Group {
                Text("距離 (km)")
                    .font(.headline)
                HStack {
                    Text("x軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.distanceStringX)
                }
                HStack {
                    Text("y軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.distanceStringY)
                }
                HStack {
                    Text("z軸:").frame(width: 50, alignment: .leading)
                    Text(viewModel.distanceStringZ)
                }
            }

            HStack {
                Button(viewModel.isLogging ? "Stop" : "Start") {
                    viewModel.toggleLogging()
                }
                .padding()
                .background(viewModel.isLogging ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Reset") {
                    viewModel.resetData()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .monospacedDigit()
    }
}

extension AccelerationLoggerViewModel {
    var rawAccelerationStringX: String { String(format: "%.4f", rawAcceleration?.x ?? 0.0) }
    var rawAccelerationStringY: String { String(format: "%.4f", rawAcceleration?.y ?? 0.0) }
    var rawAccelerationStringZ: String { String(format: "%.4f", rawAcceleration?.z ?? 0.0) }

    var globalAccelerationStringX: String { String(format: "%.4f", globalAcceleration?.x ?? 0.0) }
    var globalAccelerationStringY: String { String(format: "%.4f", globalAcceleration?.y ?? 0.0) }
    var globalAccelerationStringZ: String { String(format: "%.4f", globalAcceleration?.z ?? 0.0) }

    var filteredAccelerationStringX: String { String(format: "%.4f", filteredAcceleration?.x ?? 0.0) }
    var filteredAccelerationStringY: String { String(format: "%.4f", filteredAcceleration?.y ?? 0.0) }
    var filteredAccelerationStringZ: String { String(format: "%.4f", filteredAcceleration?.z ?? 0.0) }

    var velocityStringX: String { String(format: "%.4f", velocity.x) }
    var velocityStringY: String { String(format: "%.4f", velocity.y) }
    var velocityStringZ: String { String(format: "%.4f", velocity.z) }

    var distanceStringX: String { String(format: "%.4f", totalDistance.x) }
    var distanceStringY: String { String(format: "%.4f", totalDistance.y) }
    var distanceStringZ: String { String(format: "%.4f", totalDistance.z) }
}

final class AccelerationLoggerViewModel: ObservableObject {
    @Published var rawAcceleration: CMAcceleration?
    @Published var globalAcceleration: CMAcceleration?
    @Published var filteredAcceleration: CMAcceleration?
    @Published var velocityString = "0.0"
    @Published var distanceString = "0.0"
    @Published var isLogging = false

    private let motionManager = CMMotionManager()
    private var kalmanFilter = KalmanFilter()
    private var velocity = (x: 0.0, y: 0.0, z: 0.0)
    private var totalDistance = (x: 0.0, y: 0.0, z: 0.0)
    private var fileURL: URL?

    func toggleLogging() {
        if isLogging {
            stopLogging()
        } else {
            startLogging()
        }
    }

    func resetData() {
        rawAcceleration = nil
        globalAcceleration = nil
        filteredAcceleration = nil
        velocity = (x: 0.0, y: 0.0, z: 0.0)
        totalDistance = (x: 0.0, y: 0.0, z: 0.0)
    }

    private func startLogging() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.processMotionData(motion)
        }
        isLogging = true
    }

    private func stopLogging() {
        motionManager.stopDeviceMotionUpdates()
        isLogging = false
    }

    private func processMotionData(_ motion: CMDeviceMotion) {
        rawAcceleration = motion.userAcceleration
        globalAcceleration = motion.convertToGlobalAcceleration()
        filteredAcceleration = kalmanFilter.apply(to: globalAcceleration ?? CMAcceleration(x: 0, y: 0, z: 0))

        velocity.x += applyThreshold(filteredAcceleration?.x ?? 0) * 0.01 * 3.6
        velocity.y += applyThreshold(filteredAcceleration?.y ?? 0) * 0.01 * 3.6
        velocity.z += applyThreshold(filteredAcceleration?.z ?? 0) * 0.01 * 3.6

        let deltaDistanceX = abs(velocity.x * 0.01 / 3.6)
        let deltaDistanceY = abs(velocity.y * 0.01 / 3.6)
        let deltaDistanceZ = abs(velocity.z * 0.01 / 3.6)

        totalDistance.x += deltaDistanceX
        totalDistance.y += deltaDistanceY
        totalDistance.z += deltaDistanceZ
    }

    private func applyThreshold(_ value: Double) -> Double {
        return abs(value) < 0.02 ? 0.0 : value
    }
}

extension CMDeviceMotion {
    func convertToGlobalAcceleration() -> CMAcceleration {
        let rotationMatrix = attitude.rotationMatrix
        return CMAcceleration(
            x: rotationMatrix.m11 * userAcceleration.x + rotationMatrix.m12 * userAcceleration.y + rotationMatrix.m13 * userAcceleration.z,
            y: rotationMatrix.m21 * userAcceleration.x + rotationMatrix.m22 * userAcceleration.y + rotationMatrix.m23 * userAcceleration.z,
            z: rotationMatrix.m31 * userAcceleration.x + rotationMatrix.m32 * userAcceleration.y + rotationMatrix.m33 * userAcceleration.z
        )
    }
}

class KalmanFilter {
    private var previousEstimate = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    private var errorCovariance = CMAcceleration(x: 1.0, y: 1.0, z: 1.0)
    private let processNoise = CMAcceleration(x: 0.01, y: 0.01, z: 0.01)
    private let measurementNoise = CMAcceleration(x: 0.1, y: 0.1, z: 0.1)

    func apply(to acceleration: CMAcceleration) -> CMAcceleration {
        func updateAxis(previous: Double, error: Double, processNoise: Double, measurementNoise: Double, observed: Double) -> (estimate: Double, newError: Double) {
            let predictedEstimate = previous
            let predictedError = error + processNoise

            let kalmanGain = predictedError / (predictedError + measurementNoise)
            let newEstimate = predictedEstimate + kalmanGain * (observed - predictedEstimate)
            let newError = (1 - kalmanGain) * predictedError

            return (newEstimate, newError)
        }

        let xUpdate = updateAxis(previous: previousEstimate.x, error: errorCovariance.x, processNoise: processNoise.x, measurementNoise: measurementNoise.x, observed: acceleration.x)
        let yUpdate = updateAxis(previous: previousEstimate.y, error: errorCovariance.y, processNoise: processNoise.y, measurementNoise: measurementNoise.y, observed: acceleration.y)
        let zUpdate = updateAxis(previous: previousEstimate.z, error: errorCovariance.z, processNoise: processNoise.z, measurementNoise: measurementNoise.z, observed: acceleration.z)

        previousEstimate = CMAcceleration(x: xUpdate.estimate, y: yUpdate.estimate, z: zUpdate.estimate)
        errorCovariance = CMAcceleration(x: xUpdate.newError, y: yUpdate.newError, z: zUpdate.newError)

        return previousEstimate
    }
}
