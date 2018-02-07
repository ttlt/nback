//
//  StatsViewController.swift
//  nback
//
//  Created by 山口浩明 on 2018/01/03.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//

import UIKit
import Charts

class StatsViewController: UIViewController {

    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    @IBOutlet weak var chartView: LineChartView!
//    @IBOutlet weak var barChartView: BarChartView!
    var type:String = "single"
    var N:Int = 2
    let displayDataNum = 20
    
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var NSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.type = self.appDelegate.setting.type
        self.N = self.appDelegate.setting.N
        self.typeSegment.selectedSegmentIndex = self.type == "single" ? 0 : 1
        self.NSegment.selectedSegmentIndex = self.N - 1

        createChart()
    }
    
    func createChart() {
        // 初期化
        let type = self.type
        let N = self.N
        let scoreTable = self.appDelegate.scoreTable
        self.chartView.clear()
        self.chartView.noDataText = "No Data"
        self.chartView.noDataFont = UIFont.systemFont(ofSize: 24)
        // プロットデータ整形
        let key = type + "_" + String(N)
        if (scoreTable[key] != nil) {
            var x:Array<String> = []
            var y:[[Double]] = []
            var y_score:Array<Double> = []
            var y_position:Array<Double> = []
            var y_sound:Array<Double> = []
            for score in scoreTable[key]! {
                var arrayDictionary = score as Dictionary<String, Any>
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                print (score)
                x.append(formatter.string(from: arrayDictionary["date"] as! Date))
                y_score.append((arrayDictionary["score"] as! Double)*100.0)
//                y_position.append((arrayDictionary["scorePosition"] as! Double)*100.0)
//                if (type == "dual") {
//                    y_sound.append((arrayDictionary["scoreSound"] as! Double)*100.0)
//                }
            }
            // 表示データ数を20個にする
            x = Array(x.suffix(self.displayDataNum))
            y_score = Array(y_score.suffix(self.displayDataNum))
//            y_position = Array(y_position.suffix(self.displayDataNum))
//            y_sound = Array(y_sound.suffix(self.displayDataNum))
            // 格納
            y.append(y_score)
//            y.append(y_position)
//            if (type == "dual") {
//                y.append(y_sound)
//            }
            print (x)
            print (y)
            /////////////
             //dummy data
//            x = ["1/10/18, 9:00 AM",
//            "1/10/18,10:00 AM",
//            "1/11/18, 9:30 AM",
//            "1/13/18,10:20 AM",
//            "1/13/18, 3:00 PM"]
//            y = [[
//            40.2,65.0,55.2,78.4,89.1]]
            /////////////
            setChart(x: x ,y: y)
//            setBarChart(x: x, y: y_position)
        } else {
            //dummy data
//            var x = ["1/10/18, 9:00 AM",
//                 "1/10/18,10:00 AM",
//                 "1/11/18, 9:30 AM",
//                 "1/13/18,10:20 AM",
//                 "1/13/18, 3:00 PM"]
//            var y = [[
//                40.2,65.0,55.2,78.4,89.1]]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(x:Array<String> ,y: [[Double]]) {
        
        // チャート全体の設定
        chartView.highlightPerTapEnabled = true
        chartView.legend.enabled = false
        
        // X軸のラベルを設定
        let xaxis = XAxis()
        xaxis.valueFormatter = LineChartFormatter(x:x)
        chartView.xAxis.valueFormatter = xaxis.valueFormatter
        chartView.xAxis.setLabelCount(x.count, force: true)
        
        // x軸設定
        chartView.xAxis.labelPosition = .bottom// x軸のラベルをボトムに表示
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelRotationAngle = CGFloat(90.0)
//        chartView.xAxis.labelCount = 3
//        chartView.xAxis.labelWidth = 3
        
        // y軸設定
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMaximum = 105 //最大値
//        chartView.leftAxis.axisMinimum = 0   //最小値
        
        
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [[ChartDataEntry]]()
        var chartDataSets = [LineChartDataSet]()
        
        for num in 0..<y.count {
            dataEntries.append([ChartDataEntry]())
            for (i, val) in y[num].enumerated() {
                let dataEntry = ChartDataEntry(x: Double(i), y: val) // X軸データは、0,1,2,...
                dataEntries[num].append(dataEntry)
            }
            // グラフをUIViewにセット
            let chartDataSet = LineChartDataSet(values: dataEntries[num], label: "Score\(num)")
            // y軸設定
            chartDataSet.lineWidth = 3.0
            chartDataSet.circleRadius = 5.0
            chartDataSet.drawFilledEnabled = true
            //グラフのグラデーション有効化
//            chartDataSet.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)] //Drawing graph
            let gradientColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.2196078449, green: 1, blue: 0.8549019694, alpha: 1).withAlphaComponent(0.3).cgColor] as CFArray // Colors of the gradient
            let colorLocations:[CGFloat] = [0.7, 0.0] // Positioning of the gradient
            let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
            chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
            chartDataSets.append(chartDataSet)
//            chartDataSet.mode = .cubicBezier  //曲線
            
        }
        if (1 == y.count) {
            chartView.data = LineChartData(dataSets: chartDataSets)
        } else {
            chartView.data = LineChartData(dataSets: chartDataSets)
        }
        // グラフの色
//        chartDataSet.colors = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)]
//        // グラフの背景色
//        chartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
//        // グラフの棒をニョキッとアニメーションさせる
//        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//        // 横に赤いボーダーラインを描く
//        let ll = ChartLimitLine(limit: 10.0, label: "Target")
//        chartView.rightAxis.addLimitLine(ll)
//        // グラフのタイトル
        chartView.chartDescription?.text = ""
    }
    
    func setBarChart(x:Array<String> ,y: [Double]) {
        
        // チャート全体の設定
        chartView.highlightPerTapEnabled = true
//        chartView.drawValueAboveBarEnabled = true
        
        // X軸のラベルを設定
        let xaxis = XAxis()
        xaxis.valueFormatter = BarChartFormatter(x:x)
        chartView.xAxis.valueFormatter = xaxis.valueFormatter
//        chartView.xAxis.setLabelCount(x.count, force: true)
//        chartView.xAxis.labelCount = 3
        chartView.xAxis.labelWidth = 200.0
        
        // x軸設定
        chartView.xAxis.labelPosition = .bottom// x軸のラベルをボトムに表示
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelRotationAngle = CGFloat(75.0)
        
        // y軸設定
        chartView.rightAxis.enabled = false
        
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [BarChartDataEntry]()
        var chartDataSet = BarChartDataSet()
        
//        for num in 0..<y.count {
//            dataEntries.append([ChartDataEntry]())
            for (i, val) in y.enumerated() {
                let dataEntry = BarChartDataEntry(x: Double(i), y: val) // X軸データは、0,1,2,...
                dataEntries.append(dataEntry)
            }
            // グラフをUIViewにセット
            chartDataSet = BarChartDataSet(values: dataEntries, label: "Score")
            chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
            // y軸設定
//            chartDataSet.circleRadius = 0
//            chartDataSet.drawFilledEnabled = true
//            chartDataSets.append(chartDataSet)
//        }
        if (1 == y.count) {
            chartView.data = BarChartData(dataSet: chartDataSet)
        } else {
            chartView.data = BarChartData(dataSet: chartDataSet)
        }
        // グラフの色
        //        chartDataSet.colors = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)]
        //        // グラフの背景色
        //        chartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        //        // グラフの棒をニョキッとアニメーションさせる
        //        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        //        // 横に赤いボーダーラインを描く
        //        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        //        chartView.rightAxis.addLimitLine(ll)
        //        // グラフのタイトル
        //        chartView.chartDescription?.text = "Cool Graph!"
    }
    
    
    @IBAction func changeType(_ sender: Any) {
        switch (self.typeSegment.selectedSegmentIndex) {
        case 0:
            self.type = "single"
            break
        case 1:
            self.type = "dual"
            break
        default:
            self.type = "single"
        }
        createChart()
    }
    
    @IBAction func changeN(_ sender: Any) {
        self.N = self.NSegment.selectedSegmentIndex + 1
        createChart()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

public class LineChartFormatter: NSObject, IAxisValueFormatter{
    // x軸のラベル
//    var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var x:Array<String>
    
    init(x:Array<String>) {
        self.x = x
//        self.x[0] = "aa\nbb"
    }
    
    // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 0 -> Jan, 1 -> Feb...
//        return months[Int(value)]
        if (value < 0.0 || Int(value) >= self.x.count) {
            return ""
        }
        return self.x[Int(value)]
    }
}

public class BarChartFormatter: NSObject, IAxisValueFormatter{
    // x軸のラベル
    var x:Array<String>
    
    init(x:Array<String>) {
        self.x = x
    }
    
    // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (value < 0.0 || Int(value) >= self.x.count) {
            return ""
        }
        return self.x[Int(value)]
    }
}

