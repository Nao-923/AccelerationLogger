import Foundation

class SaveLogs {
    private var logBuffer: [[String]] = [] // メモリに保持するログデータ
    private var fileHandle: FileHandle?
    private var isLogging = false
    private let queue = DispatchQueue(label: "com.savelogs.queue")
    private var timer: Timer?

    // CSVのラベル
    private let csvHeader = "timestamp,raw_x,raw_y,raw_z,velocity_x,velocity_y,velocity_z,distance_x,distance_y,distance_z,global_x,global_y,global_z,corrected_velocity_x,corrected_velocity_y,corrected_velocity_z,corrected_distance_x,corrected_distance_y,corrected_distance_z,liner_x,liner_y,liner_z,userVelocity_x,userVelocity_y,userVelocity_z,userDistance_x,userDistance_y,userDistance_z,gravity_x,gravity_y,gravity_z,roll,pitch,yaw,magnetic_x,magnetic_y,magnetic_z,diff_x,diff_y,diff_z,latitude,longtitude,altitude,geomagnetic_x,geomagnetic_y,geomagnetic_z,heading\n"

    enum LogMode {
        case timerBased
        case eventBased
    }

    private var logMode: LogMode = .timerBased

    func startLogging(mode: LogMode = .timerBased, dataProvider: @escaping () -> ([String: Double],[String: Double],[String: Double],[String: Double],[String: Double],[String: Double],[String: Double], [String: Double], [String: Double], [String: Double], [String: Double], [String: Double], [String: Double], [Double], [String: Double], Double)) {
        guard !isLogging else { return }
        isLogging = true
        logMode = mode

        let timestamp = createTimestamp()
        let fileName = "log_\(timestamp).csv"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            fileHandle = try FileHandle(forWritingTo: filePath)
            fileHandle?.write(csvHeader.data(using: .utf8)!)
        } catch {
            print("Failed to create or open file: \(error)")
            return
        }

        if mode == .timerBased {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                self?.recordLog(using: dataProvider)
            }
        } else if mode == .eventBased {
            // イベントベースの場合、dataProviderの呼び出しを外部でトリガー
            // ここではタイマーを使いません
        }
    }

    func stopLogging() {
        guard isLogging else { return }
        isLogging = false

        timer?.invalidate()
        timer = nil

        flushBufferToFile()

        fileHandle?.closeFile()
        fileHandle = nil
    }

    func recordLog(using dataProvider: @escaping () -> ([String: Double], [String: Double],[String: Double],[String: Double],[String: Double],[String: Double],[String: Double],[String: Double], [String: Double], [String: Double], [String: Double], [String: Double], [String: Double], [Double], [String: Double], Double)) {
        let (raw,velocity,distance, global,cvelocity,cdistance, liner,uvelocity,udistance, gravity, gyro, magnetic, diff, gps, geomagnetic, heading) = dataProvider()

        let rawValues = [raw["x"] ?? 0.0, raw["y"] ?? 0.0, raw["z"] ?? 0.0]
        let velocityValues = [velocity["x"] ?? 0.0, velocity["y"] ?? 0.0, velocity["z"] ?? 0.0]
        let distanceValues = [distance["x"] ?? 0.0, distance["y"] ?? 0.0, distance["z"] ?? 0.0]
        let globalValues = [global["x"] ?? 0.0, global["y"] ?? 0.0, global["z"] ?? 0.0]
        let cvelocityValues = [cvelocity["x"] ?? 0.0, cvelocity["y"] ?? 0.0, cvelocity["z"] ?? 0.0]
        let cdistanceValues = [cdistance["x"] ?? 0.0, cdistance["y"] ?? 0.0, cdistance["z"] ?? 0.0]
        let linerValues = [liner["x"] ?? 0.0, liner["y"] ?? 0.0, liner["z"] ?? 0.0]
        let uvelocityValues = [uvelocity["x"] ?? 0.0, uvelocity["y"] ?? 0.0, uvelocity["z"] ?? 0.0]
        let udistanceValues = [udistance["x"] ?? 0.0, udistance["y"] ?? 0.0, udistance["z"] ?? 0.0]
        let gravityValues = [gravity["x"] ?? 0.0, gravity["y"] ?? 0.0, gravity["z"] ?? 0.0]
        let gyroValues = [gyro["x"] ?? 0.0, gyro["y"] ?? 0.0, gyro["z"] ?? 0.0]
        let magneticValues = [magnetic["x"] ?? 0.0, magnetic["y"] ?? 0.0, magnetic["z"] ?? 0.0]
        let diffValues = [diff["x"] ?? 0.0, diff["y"] ?? 0.0, diff["z"] ?? 0.0]
        let gpsValues = [gps[0], gps[1], gps[2]]
        let geomagneticValues = [geomagnetic["x"] ?? 0.0, geomagnetic["y"] ?? 0.0, geomagnetic["z"] ?? 0.0]

        addLogEntry(
            timestamp: createTimestamp(),
            raw: rawValues,
            velocity: velocityValues,
            distance: distanceValues,
            global: globalValues,
            cvelocity: cvelocityValues,
            cdistance: cdistanceValues,
            liner: linerValues,
            uvelocity: uvelocityValues,
            udistance: udistanceValues,
            gravity: gravityValues,
            gyro: gyroValues,
            magnetic: magneticValues,
            diff: diffValues,
            gps: gpsValues,
            geomagnetic: geomagneticValues,
            heading: heading
        )
    }

    func addLogEntry(
        timestamp: String,
        raw: [Double],
        velocity: [Double],
        distance: [Double],
        global: [Double],
        cvelocity: [Double],
        cdistance: [Double],
        liner: [Double],
        uvelocity: [Double],
        udistance: [Double],
        gravity: [Double],
        gyro: [Double],
        magnetic: [Double],
        diff: [Double],
        gps: [Double],
        geomagnetic: [Double],
        heading: Double
    ) {
        guard isLogging else { return }

        // 各部分をフォーマットしたリストとして保持
        var logEntry: [String] = []
        logEntry.append(timestamp)

        logEntry.append(contentsOf: raw.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: velocity.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: distance.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: global.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: cvelocity.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: cdistance.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: liner.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: uvelocity.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: udistance.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: gravity.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: gyro.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: magnetic.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: diff.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: gps.map { String(format: "%.6f", $0) })
        logEntry.append(contentsOf: geomagnetic.map { String(format: "%.6f", $0) })
        logEntry.append(String(format: "%.6f", heading))

        // ログバッファに非同期で追加
        queue.async { [weak self] in
            self?.logBuffer.append(logEntry)
        }
    }

    private func flushBufferToFile() {
        guard !logBuffer.isEmpty, let fileHandle = fileHandle else { return }

        queue.sync {
            let logData = logBuffer.map { $0.joined(separator: ",") + "\n" }.joined()
            if let data = logData.data(using: .utf8) {
                fileHandle.write(data)
            }
            logBuffer.removeAll()
        }
    }

    private func createTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
