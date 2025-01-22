#Preview {
    ContentView()
}

import SwiftUI

struct ContentView: View {
    @State private var isRunning = false
    @ObservedObject var motionManager = MotionManager()
    @ObservedObject var gpsManager = GPSManager()
    private let saveLogs = SaveLogs()

    var body: some View {
        Spacer()

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("生データ(単位変換済)").font(.headline)
                    accData(label: "x軸", value: motionManager.rawAccelerometerData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.rawAccelerometerData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.rawAccelerometerData["z"] ?? 0.0, color: .blue)
//                    velocityData(label: "x軸_速度", value: motionManager.velocity["x"] ?? 0.0, color: .red)
//                    velocityData(label: "y軸_速度", value: motionManager.velocity["y"] ?? 0.0, color: .green)
//                    velocityData(label: "z軸_速度", value: motionManager.velocity["z"] ?? 0.0, color: .blue)
//                    distanceData(label: "x軸_距離", value: motionManager.distance["x"] ?? 0.0, color: .red)
//                    distanceData(label: "y軸_距離", value: motionManager.distance["y"] ?? 0.0, color: .green)
//                    distanceData(label: "z軸_距離", value: motionManager.distance["z"] ?? 0.0, color: .blue)
                }
                
                Group {
                    Text("Attitude").font(.headline)
                    attitudeData(label: "roll", value: motionManager.attitude["x"] ?? 0.0, color: .red)
                    attitudeData(label: "pitch", value: motionManager.attitude["y"] ?? 0.0, color: .green)
                    attitudeData(label: "yaw", value: motionManager.attitude["z"] ?? 0.0, color: .blue)
                }
                
                Group {
                    Text("重力加速度").font(.headline)
                    accData(label: "x軸", value: motionManager.gravity["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.gravity["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.gravity["z"] ?? 0.0, color: .blue)
                }
                
                Group {
                    Text("グローバルデータ").font(.headline)
                    accData(label: "x軸", value: motionManager.globalData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.globalData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.globalData["z"] ?? 0.0, color: .blue)
//                    velocityData(label: "x軸_速度", value: motionManager.corrected_velocity["x"] ?? 0.0, color: .red)
//                    velocityData(label: "y軸_速度", value: motionManager.corrected_velocity["y"] ?? 0.0, color: .green)
//                    velocityData(label: "z軸_速度", value: motionManager.corrected_velocity["z"] ?? 0.0, color: .blue)
//                    distanceData(label: "x軸_距離", value: motionManager.corrected_distance["x"] ?? 0.0, color: .red)
//                    distanceData(label: "y軸_距離", value: motionManager.corrected_distance["y"] ?? 0.0, color: .green)
//                    distanceData(label: "z軸_距離", value: motionManager.corrected_distance["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("線形加速度").font(.headline)
                    accData(label: "x軸", value: motionManager.liner["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.liner["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.liner["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("線形加速度 - グローバルデータ").font(.headline)
                    accData(label: "x軸", value: motionManager.diff["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.diff["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.diff["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("グローバルデータ").font(.headline)
                    accData(label: "x軸", value: motionManager.average["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.average["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.average["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("速度").font(.headline)
                    velocityData(label: "x軸", value: motionManager.velocity["x"] ?? 0.0, color: .red)
                    velocityData(label: "y軸", value: motionManager.velocity["y"] ?? 0.0, color: .green)
                    velocityData(label: "z軸", value: motionManager.velocity["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("距離").font(.headline)
                    distanceData(label: "x軸", value: motionManager.distance["x"] ?? 0.0, color: .red)
                    distanceData(label: "y軸", value: motionManager.distance["y"] ?? 0.0, color: .green)
                    distanceData(label: "z軸", value: motionManager.distance["z"] ?? 0.0, color: .blue)
                }
                

            }

            Spacer()

        }
        .padding()

        Spacer()

        VStack(spacing: 16) {
            Button(action: {
                isRunning.toggle()
                if isRunning {
                    motionManager.startSensors()
                    gpsManager.startUpdates()
                    saveLogs.startLogging(mode: .timerBased) {
                        (
                            motionManager.rawAccelerometerData,
                            motionManager.attitude,
                            motionManager.gravity,
//                            motionManager.velocity,
//                            motionManager.distance,
//                            motionManager.globalData,
                            motionManager.average,
                            motionManager.liner,
                            motionManager.diff,
                            motionManager.velocity,
                            motionManager.distance
//                            motionManager.corrected_velocity,
//                            motionManager.corrected_distance,
//                            motionManager.userAccelerationData,
//                            motionManager.userVelocity,
//                            motionManager.userDistance,
//                            motionManager.gravityData,
//                            motionManager.gyroData,
//                            motionManager.magneticFieldData,
//                            motionManager.differenceData,
//                            [gpsManager.latitude, gpsManager.longitude, gpsManager.altitude],
//                            gpsManager.geomagneticData,
//                            gpsManager.heading
                        )
                    }
                } else {
                    motionManager.stopSensors()
                    gpsManager.stopUpdates()
                    saveLogs.stopLogging()
                }
            }) {
                Text(isRunning ? "ストップ" : "スタート")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                motionManager.resetData()
                gpsManager.resetData()
            }) {
                Text("リセット")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(isRunning ? 0.5 : 1.0))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isRunning)
        }
        .padding()
    }

    private func accData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.5f m/s²", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
//    private func velocityData(label: String, value: Double, color: Color) -> some View {
//        HStack {
//            Text(label)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(color)
//            Text(String(format: "%.2f km/h", value))
//                .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//    }
//    private func distanceData(label: String, value: Double, color: Color) -> some View {
//        HStack {
//            Text(label)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(color)
//            Text(String(format: "%.2f km", value))
//                .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//    }

    private func gpsData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.6f", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func gyroData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.2f rad/s", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func attitudeData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.2f rad", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func magneticFieldData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.2f μT", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func headingData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
                .font(.headline)
            Text(String(format: "%.2f °", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func velocityData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
                .font(.headline)
            Text(String(format: "%.5f km/h", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func distanceData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
                .font(.headline)
            Text(String(format: "%.5f km", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
