//
//  StatsViewController.swift
//  nback
//
//  Created by 山口浩明 on 2018/01/03.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    
    @IBOutlet weak var chartView: UIScrollView!
    var type:String = "single"
    var N:Int = 2
    let displayDataNum = 20
    var viewHeight:CGFloat = 0  //最初のviewの高さを保持
    var contentSize:CGSize = CGSize()
    var changeDraw = false
    var graphFrame = UIView()

    
    @IBOutlet weak var typeSegment: TTSegmentedControl!
    @IBOutlet weak var NSegment: TTSegmentedControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景
        setBackgroundColor(view: self.view)

        
        // Do any additional setup after loading the view.
        self.type = self.appDelegate.setting.type
        self.N = self.appDelegate.setting.N
        //セグメントの初期化
        self.typeSegment.itemTitles = ["Single", "Dual"]
        self.typeSegment.selectItemAt(index: self.type == "single" ? 0 : 1)
        self.typeSegment.didSelectItemWith = {(i, title) -> () in
            self.changeType(index: i)
        }
        self.NSegment.itemTitles = ["1", "2", "3", "4", "5"]
        self.NSegment.selectItemAt(index: self.N - 1)
        self.NSegment.didSelectItemWith = {(i, title) -> () in
            self.changeN(index: i)
        }
        viewHeight = chartView.frame.size.height
        contentSize = chartView.contentSize
//        copyChartView = chartView.copy() as! UIScrollView
        
        createLineGraph()
    }
    
    func drawLineGraph() {
        let stroke1 = LineStroke(graphPoints: [40.2,65.0,55.2,78.4,89.1, 100.0,87.2])
//        let stroke1 = LineStroke(graphPoints: [40.2])
        stroke1.color = UIColor(red:0, green:0.8, blue:0, alpha:1.0)
        let xLabels = ["10/18",
                       "10/18",
                       "11/18",
                       "12/18",
                       "01/18",
            "02/18",
            "03/18"]
//        let xLabels = ["10/18"]
        
//        let graphFrame = LineStrokeGraphFrame(strokes: [stroke1], xLabels: xLabels)
//        chartView.addSubview(graphFrame)
        
        ////
//        let xLabelView = UIView(frame: CGRect(x:0, y: chartView.frame.height-100, width: chartView.frame.width, height: 100))
        ////
        
        view.addSubview(chartView)
//        view.addSubview(xLabelView)
    }
    
    func createLineGraph() {
        // 初期化
        let type = self.type
        let N = self.N
        let scoreTable = self.appDelegate.scoreTable
        removeAllSubviews(parentView: chartView)
        chartView.frame.size.height = viewHeight    //初期表示から切り替えた場合、heightが変わるので初期のサイズに戻す（よくない処理）
        chartView.contentSize = contentSize
        
        // プロットデータ整形
        let key = type + "_" + String(N)
        if (scoreTable[key] != nil) {
            print("========================================")
            print(scoreTable[key])
            print("========================================")
            var x:Array<Date> = []
            var y_score:Array<CGFloat> = []
            for score in scoreTable[key]! {
                var arrayDictionary = score as Dictionary<String, Any>
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                x.append(arrayDictionary["date"] as! Date)
                y_score.append((CGFloat(arrayDictionary["score"] as! Double)*100.0))
            }
//            // 表示データ数を20個にする
//            x = Array(x.suffix(self.displayDataNum))
//            y_score = Array(y_score.suffix(self.displayDataNum))
            // 格納
            let stroke1 = LineStroke(graphPoints: y_score)
            stroke1.color = UIColor(red:0, green:0.8, blue:0, alpha:1.0)
            let xLabels = x
            graphFrame = LineStrokeGraphFrame(strokes: [stroke1], xLabels: xLabels)
            chartView.addSubview(graphFrame)
            // 横スクロールのために、contentSizeの横幅をgraphFrameに合わす
            self.chartView.contentSize = CGSize(width:graphFrame.frame.width, height:graphFrame.frame.height)
            if (changeDraw) {
                // 初期表示からパラメータ切り替えた場合、chartViewの高さが変わり、x軸のラベルが範囲外で表示されなくなるので、高さを増やす
                // （addSubView以降にこの処理をしないと、画面下部にx軸の線までしか表示されない）
                chartView.frame.size = CGSize(width:chartView.frame.width, height: chartView.frame.height + 44)
            } else {
                changeDraw = true
            }
            // スクロール初期表示位置
            chartView.setContentOffset(CGPoint(x:chartView.contentSize.width - chartView.frame.width, y:0), animated: true)
            
        } else {
            let label:UILabel = UILabel()
            let w = 100
            let h = 30
            label.textAlignment = NSTextAlignment.center
//            label.frame = CGRect(origin:CGPoint(x:view.frame.width/2-CGFloat(w/2), y:view.frame.height/2+CGFloat(h/2)), size:CGSize(width:w, height:h))
            label.frame = CGRect(origin:CGPoint(x:view.frame.width/2-CGFloat(w/2), y:100), size:CGSize(width:w, height:h))
            label.text = "No Data"
            label.textColor = UIColor.white
            chartView.addSubview(label)
        }
    }
    
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func changeType(index:Int) {
        switch (index) {
        case 0:
            self.type = "single"
            break
        case 1:
            self.type = "dual"
            break
        default:
            self.type = "single"
        }
        createLineGraph()
    }
    
    func changeN(index:Int) {
        self.N = index + 1
        createLineGraph()
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
