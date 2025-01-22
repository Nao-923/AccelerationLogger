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
                    accData(label: "x軸", value: motionManager.accelerationData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.accelerationData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.accelerationData["z"] ?? 0.0, color: .blue)
                    velocityData(label: "x軸_速度", value: motionManager.velocity["x"] ?? 0.0, color: .red)
                    velocityData(label: "y軸_速度", value: motionManager.velocity["y"] ?? 0.0, color: .green)
                    velocityData(label: "z軸_速度", value: motionManager.velocity["z"] ?? 0.0, color: .blue)
                    distanceData(label: "x軸_距離", value: motionManager.distance["x"] ?? 0.0, color: .red)
                    distanceData(label: "y軸_距離", value: motionManager.distance["y"] ?? 0.0, color: .green)
                    distanceData(label: "z軸_距離", value: motionManager.distance["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("実空間データ").font(.headline)
                    accData(label: "x軸", value: motionManager.globalData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.globalData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.globalData["z"] ?? 0.0, color: .blue)
                    velocityData(label: "x軸_速度", value: motionManager.corrected_velocity["x"] ?? 0.0, color: .red)
                    velocityData(label: "y軸_速度", value: motionManager.corrected_velocity["y"] ?? 0.0, color: .green)
                    velocityData(label: "z軸_速度", value: motionManager.corrected_velocity["z"] ?? 0.0, color: .blue)
                    distanceData(label: "x軸_距離", value: motionManager.corrected_distance["x"] ?? 0.0, color: .red)
                    distanceData(label: "y軸_距離", value: motionManager.corrected_distance["y"] ?? 0.0, color: .green)
                    distanceData(label: "z軸_距離", value: motionManager.corrected_distance["z"] ?? 0.0, color: .blue)
                }

                Group {
                    Text("線形加速度").font(.headline)
                    accData(label: "x軸", value: motionManager.userAccelerationData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.userAccelerationData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.userAccelerationData["z"] ?? 0.0, color: .blue)
                    velocityData(label: "x軸_速度", value: motionManager.userVelocity["x"] ?? 0.0, color: .red)
                    velocityData(label: "y軸_速度", value: motionManager.userVelocity["y"] ?? 0.0, color: .green)
                    velocityData(label: "z軸_速度", value: motionManager.userVelocity["z"] ?? 0.0, color: .blue)
                    distanceData(label: "x軸_距離", value: motionManager.userDistance["x"] ?? 0.0, color: .red)
                    distanceData(label: "y軸_距離", value: motionManager.userDistance["y"] ?? 0.0, color: .green)
                    distanceData(label: "z軸_距離", value: motionManager.userDistance["z"] ?? 0.0, color: .blue)
                }
                
                Group {
                    Text("重力加速度").font(.headline)
                    accData(label: "x軸", value: motionManager.gravityData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.gravityData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.gravityData["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("ジャイロ").font(.headline)
                    gyroData(label: "roll", value: motionManager.gyroData["x"] ?? 0.0, color: .red)
                    gyroData(label: "pitch", value: motionManager.gyroData["y"] ?? 0.0, color: .green)
                    gyroData(label: "yaw", value: motionManager.gyroData["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("磁場").font(.headline)
                    magneticFieldData(label: "x軸", value: motionManager.magneticFieldData["x"] ?? 0.0, color: .red)
                    magneticFieldData(label: "y軸", value: motionManager.magneticFieldData["y"] ?? 0.0, color: .green)
                    magneticFieldData(label: "z軸", value: motionManager.magneticFieldData["z"] ?? 0.0, color: .blue)
                }
                Group {
                    Text("線形加速度 - (実空間データ-重力加速度)").font(.headline)
                    accData(label: "x軸", value: motionManager.differenceData["x"] ?? 0.0, color: .red)
                    accData(label: "y軸", value: motionManager.differenceData["y"] ?? 0.0, color: .green)
                    accData(label: "z軸", value: motionManager.differenceData["z"] ?? 0.0, color: .blue)
                }

                Group {
                    Text("GPS").font(.headline)
                    gpsData(label: "緯度", value: gpsManager.latitude, color: .red)
                    gpsData(label: "経度", value: gpsManager.longitude, color: .green)
                    gpsData(label: "高度", value: gpsManager.altitude, color: .blue)
                }
                Group {
                    Text("地磁気").font(.headline)
                    magneticFieldData(label: "x軸", value: gpsManager.geomagneticData["x"] ?? 0.0, color: .red)
                    magneticFieldData(label: "y軸", value: gpsManager.geomagneticData["y"] ?? 0.0, color: .green)
                    magneticFieldData(label: "z軸", value: gpsManager.geomagneticData["z"] ?? 0.0, color: .blue)
                    headingData(label: "方位", value: gpsManager.heading, color: .black)
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
                            motionManager.velocity,
                            motionManager.distance,
                            motionManager.globalData,
                            motionManager.corrected_velocity,
                            motionManager.corrected_distance,
                            motionManager.userAccelerationData,
                            motionManager.userVelocity,
                            motionManager.userDistance,
                            motionManager.gravityData,
                            motionManager.gyroData,
                            motionManager.magneticFieldData,
                            motionManager.differenceData,
                            [gpsManager.latitude, gpsManager.longitude, gpsManager.altitude],
                            gpsManager.geomagneticData,
                            gpsManager.heading
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
            Text(String(format: "%.2f m/s²", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func velocityData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.2f km/h", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    private func distanceData(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(color)
            Text(String(format: "%.2f km", value))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

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
}
