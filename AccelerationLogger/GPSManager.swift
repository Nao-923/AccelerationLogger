//import CoreLocation
//import Foundation
//
//class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//
//    @Published var latitude: Double = 0.0
//    @Published var longitude: Double = 0.0
//    @Published var altitude: Double = 0.0
//    @Published var heading: Double = 0.0
//    @Published var geomagneticData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        
////        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = kCLDistanceFilterNone
//        
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
//    }
//
//    func startUpdates() {
//        locationManager.startUpdatingHeading() // 方位の取得を開始
//        locationManager.startUpdatingLocation() // 緯度・経度の取得を開始
//    }
//
//    func stopUpdates() {
//        locationManager.stopUpdatingHeading() // 方位の取得を停止
//        locationManager.stopUpdatingLocation() // 緯度・経度の取得を停止
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {
//            print("No location data available")
//            return
//        }
//        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude), Altitude: \(location.altitude)")
//        DispatchQueue.main.async {
//            self.latitude = location.coordinate.latitude
//            self.longitude = location.coordinate.longitude
//            self.altitude = location.altitude
//        }
//    }
//
//    // CLLocationManagerDelegate - 方位の更新
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        DispatchQueue.main.async {
//            self.heading = newHeading.trueHeading // 真北に基づく方位
//            self.geomagneticData = [
//                "x": newHeading.x,
//                "y": newHeading.y,
//                "z": newHeading.z
//            ]
//        }
//    }
//
//    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
//        // 方位センサーのキャリブレーションを表示するか
//        return false
//    }
//
//    func resetData() {
//        DispatchQueue.main.async {
//            self.latitude = 0.0
//            self.longitude = 0.0
//            self.altitude = 0.0
//            self.heading = 0.0
//            self.geomagneticData = ["x": 0.0, "y": 0.0, "z": 0.0]
//        }
//    }
//}

import CoreLocation
import Foundation

class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var heading: Double = 0.0
    @Published var geomagneticData: [String: Double] = ["x": 0.0, "y": 0.0, "z": 0.0]

    override init() {
        super.init()
        locationManager.delegate = self

        // 設定: 高精度 & 全ての位置更新を受け取る
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone

        // 権限リクエスト
        locationManager.requestWhenInUseAuthorization()
    }

    // 位置情報と方位の更新を開始
    func startUpdates() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        } else {
            print("Location authorization not granted")
        }
    }

    // 位置情報と方位の更新を停止
    func stopUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    // 位置情報の更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No location data available")
            return
        }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude
        }
    }

    // 方位の更新
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.trueHeading // 真北に基づく方位
            self.geomagneticData = [
                "x": newHeading.x,
                "y": newHeading.y,
                "z": newHeading.z
            ]
        }
    }

    // エラー処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    // キャリブレーションの確認
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true // 必要であればキャリブレーションを表示
    }

    // データリセット
    func resetData() {
        DispatchQueue.main.async {
            self.latitude = 0.0
            self.longitude = 0.0
            self.altitude = 0.0
            self.heading = 0.0
            self.geomagneticData = ["x": 0.0, "y": 0.0, "z": 0.0]
        }
    }
}
