//
//  ViewController.swift
//  MLApp
//
//  Created by Akrem El-ghazal on 2020-04-14.
//  Copyright © 2020 YourCompanyName. All rights reserved.
//
import UIKit
import CoreML
import Charts
import CoreMotion

class ViewController: UIViewController {
    @IBOutlet weak var orientationLbl: UILabel!
    @IBOutlet weak var barView: BarChartView!
    
    let model = PhoneOrientation()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion, error) in
            if let deviceMotion = deviceMotion {
                let d1_x = BarChartDataEntry(x: 1, y: deviceMotion.gravity.x)
                let d2_y = BarChartDataEntry(x: 2, y: deviceMotion.gravity.y)
                let d3_z = BarChartDataEntry(x: 3, y: deviceMotion.gravity.z)
                
                let dataSet = BarChartDataSet(entries: [d1_x,d2_y,d3_z], label: "")
                dataSet.colors = [.red, .blue, .green]
                
                let chartData = BarChartData(dataSet: dataSet)
                
                self.barView.data = chartData
                self.barView.scaleYEnabled = false
                self.barView.leftAxis.axisMaximum = 1
                self.barView.leftAxis.axisMinimum = -1
                self.barView.rightAxis.axisMaximum = 1
                self.barView.rightAxis.axisMinimum = -1
                let gravityVal = [deviceMotion.gravity.x,deviceMotion.gravity.y,deviceMotion.gravity.z]
                
                getPhoneOrientation(gravity: gravityVal, model: self.model, orientationLbl: self.orientationLbl)
            }
        }
    }
}

func getPhoneOrientation(gravity: [Double], model: PhoneOrientation, orientationLbl: UILabel) {
    var result : Int64 = 0
    do {
        let input = try  MLMultiArray(shape:[1,3] , dataType: MLMultiArrayDataType.double)
        for(index,element) in gravity.enumerated(){
            input[index] = NSNumber(floatLiteral: element)
        }
        let prediction = try model.prediction(input: input)
        result = prediction.classLabel
    }
    catch{
        print("Error,.....")
    }
    switch result {
        case 1:
            orientationLbl.text = "Face Up"
        case 2:
            orientationLbl.text = "Face Down"
        case 3:
            orientationLbl.text = "Portrait"
        case 4:
            orientationLbl.text = "Portrait Upside Down"
        case 5:
            orientationLbl.text = "Landscape Left"
        case 6:
            orientationLbl.text = "Landscape Right"
        default:
            orientationLbl.text = "Unknown"
    }
}

