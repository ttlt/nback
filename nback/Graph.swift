//
//  Graph.swift
//  nback
//
//  Created by 山口浩明 on 2018/02/12.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//
import UIKit

let leftMargin:CGFloat = 40 //グラフ左側のマージン
let rightMargin:CGFloat = 5    //グラフ右側のマージン
let pointSize:CGFloat = 10  //点の大きさ
let yMax:CGFloat = 100  //y軸最大値
let scoreWidth:CGFloat = 30, scoreHeight:CGFloat = 20   //表示スコアの幅
let topOffset:CGFloat = 50  //上のViewと重なってしまうため調整
let xMargin:CGFloat = 30    //列幅
let graphColor:UIColor = UIColor(red: 0, green: 0.8, blue:0, alpha: 1.0)  //グラフの色

protocol GraphObject {
    var view: UIView { get }
}

extension GraphObject {

    var view: UIView {
        return self as! UIView
    }
    
    func drawLine(_ from: CGPoint, to: CGPoint, c: UIColor) {
        let linePath = UIBezierPath()
        
        linePath.move(to: from)
        linePath.addLine(to: to)
        
        linePath.lineWidth = 0.5
        
        let color = c

        color.setStroke()
        linePath.stroke()
        linePath.close()
    }
    
    func drawLine(_ from: CGPoint, to: CGPoint) {
        self.drawLine(from, to: to, c: UIColor.white)
    }
}

protocol GraphFrame: GraphObject {
    var strokes: [GraphStroke] { get }
}

extension GraphFrame {
    // 保持しているstrokesの中で最大値
    var yAxisMax: CGFloat {
        //        return strokes.map{ $0.graphPoints }.flatMap{ $0 }.flatMap{ $0 }.max()!
        return yMax
    }
    
    // 保持しているstrokesの中でいちばん長い配列の長さ
    var xAxisPointsCount: Int {
        return strokes.map{ $0.graphPoints.count }.max()!
    }
    
    // X軸の点と点の幅
    var xAxisMargin: CGFloat {
        
        let width = UIScreen.main.bounds.size.width - leftMargin - rightMargin
        // データ数が画面幅に収まる場合は、画面幅に合わせたマージン設定
        if (CGFloat(xAxisPointsCount) * xMargin < width) {
            return width / CGFloat(xAxisPointsCount)
        }
        return xMargin
        
//        if (xAxisPointsCount == 1) {
//            return (view.frame.width - leftMargin - rightMargin)/(CGFloat(xAxisPointsCount))
//        } else {
//            return (view.frame.width - leftMargin - rightMargin)/(CGFloat(xAxisPointsCount)-1)
//        }
//        //        return (ViewController.mainView.frame.width - leftMargin)/CGFloat(xAxisPointsCount)
//        //        //データ数が少ない場合は、幅に合わせたマージン設定
//        //        var margin:CGFloat = 50
//        //        if (CGFloat(xAxisPointsCount) * margin < view.frame.width) {
//        //            margin = view.frame.width/CGFloat(xAxisPointsCount)
//        //        }
//        //        return margin
    }
    
    var frameWidth: CGFloat {
        return xAxisMargin*CGFloat(xAxisPointsCount)
    }
    
}

class LineStrokeGraphFrame: UIView, GraphFrame {
    
    var strokes = [GraphStroke]()
    var xLabels = [Date]()
    
    convenience init(strokes: [GraphStroke], xLabels: [Date]) {
        self.init()
        self.strokes = strokes
        self.xLabels = xLabels
    }
    
    override func didMoveToSuperview() {
        if self.superview == nil { return }
        self.frame.size = self.superview!.frame.size
        self.view.backgroundColor = UIColor.clear
//        self.frame.size = CGSize(width:xMargin * CGFloat(self.xLabels.count) + leftMargin, height:frame.height)
        if (CGFloat(xAxisPointsCount) * xMargin > UIScreen.main.bounds.size.width - leftMargin - rightMargin) {
            self.frame.size = CGSize(width:xMargin * CGFloat(self.xLabels.count) + leftMargin, height:frame.height)
        }
        strokeLines()
    }
    
    func strokeLines() {
        for stroke in strokes {
            self.addSubview(stroke as! UIView)
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawTopLine()
        drawBottomLine()
        drawVerticalLines()
        drawXLabel()
        drawYLabel()
    }
    
    func drawTopLine() {
        self.drawLine(
            CGPoint(x: 0, y: frame.height),
            to: CGPoint(x: frame.width, y: frame.height),
//            to: CGPoint(x: frameWidth, y: frame.height),
            c: UIColor.white
        )
    }
    
    func drawBottomLine() {
        self.drawLine(
            CGPoint(x: leftMargin, y: topOffset),
            to: CGPoint(x: frame.width, y: topOffset)
//            to: CGPoint(x: frameWidth, y: topOffset)
        )
    }
    
    func drawVerticalLines() {
        for i in 0..<xAxisPointsCount {
            let x = xAxisMargin*CGFloat(i) + leftMargin
            if (i != 0) {
                self.drawLine(
                    CGPoint(x: x, y: topOffset),
                    to: CGPoint(x: x, y: frame.height)
                )
            } else {
                // y軸
                self.drawLine(
                    CGPoint(x: x, y: topOffset - 30),
                    to: CGPoint(x: x, y: frame.height),
                    c: UIColor.white
                )
            }
        }
    }
    
    func drawYLabel() {
        let width:CGFloat = 40
        let height:CGFloat = 20
        let yLabel:UILabel = UILabel()
        yLabel.font = yLabel.font.withSize(12)
        yLabel.textAlignment = NSTextAlignment.center
        yLabel.frame = CGRect(origin:CGPoint(x:leftMargin - width, y:topOffset - height/2), size:CGSize(width:width, height:height))
        yLabel.text = "100"
        yLabel.textColor = UIColor.white
        view.addSubview(yLabel)
    }
    
    func drawXLabel() {
        // ラベルサイズ   
        let width:CGFloat = 40
        let height:CGFloat = 20
        let hMargin:CGFloat = 5
        // Dateformat
        let f_MMdd = DateFormatter()
        let f_yyyy = DateFormatter()
        let f_MMM = DateFormatter()
        let f_dd = DateFormatter()
        f_MMdd.dateFormat = "MM/dd"
        f_yyyy.dateFormat = "yyyy"
        f_MMM.dateFormat = "MMM"
        f_dd.dateFormat = "dd"
        // 年エリアの背景
        let xBackground:UIView = UIView()
        xBackground.frame = CGRect(x:0, y:frame.height + height, width:frame.width, height: height)
//        xBackground.frame = CGRect(x:0, y:frame.height + height, width:UIScreen.main.bounds.size.width, height: height)
//        xBackground.frame = CGRect(x:0, y:frame.height + height, width:frameWidth, height: height)
        xBackground.isOpaque = false
//        xBackground.backgroundColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.5)
        xBackground.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        view.addSubview(xBackground)
        view.bringSubview(toFront: xBackground)
        // 一つ前のラベル
        var preDayLabel = ""
        var preMonthLabel = ""
        // ラベル表示
        for i in 0..<xAxisPointsCount {
            let x = xAxisMargin * CGFloat(i) + leftMargin
            // 月日
            if (preDayLabel != f_dd.string(from: self.xLabels[i])) {
                let label:UILabel = UILabel()
                label.font = label.font.withSize(12)
                label.textAlignment = NSTextAlignment.center
                label.frame = CGRect(origin:CGPoint(x:(x - width / 2), y:frame.height), size:CGSize(width:width, height:height))
    //            label.text = f_MMdd.string(from: self.xLabels[i])
                label.text = f_dd.string(from: self.xLabels[i])
                label.textColor = UIColor.white
                view.addSubview(label)
                preDayLabel = label.text!
            }
            // 年
            if (preMonthLabel != f_MMM.string(from: self.xLabels[i])) {
                let y_label:UILabel = UILabel()
                y_label.font = y_label.font.withSize(12)
                y_label.textAlignment = NSTextAlignment.center
                y_label.frame = CGRect(origin:CGPoint(x:(x - width / 2), y:frame.height + height), size:CGSize(width:width, height:height))
    //            y_label.text = f_yyyy.string(from: self.xLabels[i])
                y_label.text = f_MMM.string(from: self.xLabels[i])
                y_label.textColor = UIColor.black
                view.addSubview(y_label)
                preMonthLabel = y_label.text!
            }
            
        }
    }
}


protocol GraphStroke: GraphObject {
    var graphPoints: [CGFloat?] { get }
}

extension GraphStroke {

    var graphFrame: GraphFrame? {
        return ((self as! UIView).superview as? GraphFrame)
    }
    
    var graphHeight: CGFloat {
        return view.frame.height - topOffset
    }
    
    var xAxisMargin: CGFloat {
        return graphFrame!.xAxisMargin
//        return xMargin
    }
    
    var yAxisMax: CGFloat {
        return graphFrame!.yAxisMax
    }
    
    // indexからX座標を取る
    func getXPoint(_ index: Int) -> CGFloat {
        return CGFloat(index) * xAxisMargin + leftMargin
    }
    
    // 値からY座標を取る
    func getYPoint(_ yOrigin: CGFloat) -> CGFloat {
        let y: CGFloat = yOrigin/yAxisMax * graphHeight
        return graphHeight - y
    }
}


class LineStroke: UIView, GraphStroke {
    
    var graphPoints = [CGFloat?]()
    //    var color = UIColor.white
    var color = graphColor
    
    convenience init(graphPoints: [CGFloat?]) {
        self.init()
        self.graphPoints = graphPoints
    }
    
    override func didMoveToSuperview() {
        if self.graphFrame == nil { return }
        self.frame.size = self.graphFrame!.view.frame.size
        self.view.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        
        let startPath = CGMutablePath()
        startPath.move(to: CGPoint(x: getXPoint(0), y: getYPoint(graphPoints[0] ?? 0) + topOffset))
        var startPoint:CGPoint = CGPoint()
        var endPoint:CGPoint = CGPoint()
        var isStartPoint = true
        for graphPoint in graphPoints.enumerated() {
            if graphPoint.element == nil { continue }
            let x = getXPoint(graphPoint.offset)
            let y = getYPoint(graphPoint.element!) + topOffset
            let nextPoint = CGPoint(x: x,
                                    y: y)
            startPath.addLine(to: nextPoint)
            if (isStartPoint) {
                startPoint = nextPoint
                isStartPoint = false
            }
            endPoint = nextPoint
            // 点
            drawFillCircle(rect: CGRect(x: x-pointSize/2,y: y-pointSize/2, width: pointSize, height: pointSize))
            // スコア
            let score = UILabel()
            score.font = score.font.withSize(12)
            score.textAlignment = NSTextAlignment.center
            score.frame = CGRect(x: x-scoreWidth/2, y:y-40, width: scoreWidth, height: scoreHeight)
            if (Int(graphPoint.element!) == 100) {
                //100点の場合は小数点以下削除
                score.text = String(Int(graphPoint.element!))
            } else {
                score.text = String(format: "%.1f", Double(graphPoint.element!))
            }
            score.textColor = UIColor.white
            view.addSubview(score)
        }
        //始点まで閉じる
        startPath.addLine(to: CGPoint(x:endPoint.x, y:frame.height))
        startPath.addLine(to: CGPoint(x:leftMargin, y:frame.height))
        startPath.addLine(to: startPoint)
        startPath.closeSubpath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x:0, y:0, width:frame.width, height: frame.height)
//        shapeLayer.frame = CGRect(x:0, y:0, width:GraphFrame.frameWidth, height: frame.height)
        shapeLayer.path = startPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0.0
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.borderColor = UIColor.white.cgColor
        
        /////////////////
        let graphPath = UIBezierPath()
        
        graphPath.move(
            to: CGPoint(x: getXPoint(0), y: getYPoint(graphPoints[0] ?? 0) + topOffset)
        )
        
        isStartPoint = true
        for graphPoint in graphPoints.enumerated() {
            if graphPoint.element == nil { continue }
            let x = getXPoint(graphPoint.offset)
            let y = getYPoint(graphPoint.element!) + topOffset
            let nextPoint = CGPoint(x: x,
                                    y: y)
            graphPath.addLine(to: nextPoint)
            if (isStartPoint) {
                startPoint = nextPoint
                isStartPoint = false
            }
            endPoint = nextPoint
            // 点
            drawFillCircle(rect: CGRect(x: x-pointSize/2,y: y-pointSize/2, width: pointSize, height: pointSize))
        }
        
        //始点まで閉じる
        graphPath.addLine(to: CGPoint(x:endPoint.x, y:frame.height))
        graphPath.addLine(to: CGPoint(x:leftMargin, y:frame.height))
        graphPath.addLine(to: startPoint)
        
        graphPath.lineWidth = 3.0
        color.setStroke()
        graphPath.stroke()
        graphPath.close()
        
        //////////////
        
        let gradLayer = CAGradientLayer()
        gradLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//        gradLayer.frame = CGRect(x: 0, y: 0, width: frame.frameWidth, height: frame.height)
        gradLayer.colors = [
            graphColor.withAlphaComponent(0.5).cgColor,
            graphColor.withAlphaComponent(0.2).cgColor
//            UIColor(red:1.0, green:128/255, blue:0, alpha:0.5).cgColor,
//            UIColor(red:1.0, green:128/255, blue:0, alpha:0.2).cgColor
        ]
        gradLayer.mask = shapeLayer
        view.layer.addSublayer(gradLayer)
    }
    
    //点の丸
    private func drawFillCircle(rect: CGRect) {
        // コンテキストの取得(1)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 色の設定(2)
        context.setFillColor(graphColor.cgColor)
        
        // 円を塗りつぶしで描く(3)
        // 円は引数のCGRectに内接する
        context.fillEllipse(in: rect)
    }
}

//class BarStroke: UIView, GraphStroke {
//    var graphPoints = [CGFloat?]()
//    var color = UIColor.white
//
//    convenience init(graphPoints: [CGFloat?]) {
//        self.init()
//        self.graphPoints = graphPoints
//    }
//
//    override func didMoveToSuperview() {
//        if self.graphFrame == nil { return }
//        self.frame.size = self.graphFrame!.view.frame.size
//        self.view.backgroundColor = UIColor.clear
//    }
//
//    override func draw(_ rect: CGRect) {
//        for graphPoint in graphPoints.enumerated() {
//            let graphPath = UIBezierPath()
//
//            let xPoint = getXPoint(graphPoint.offset)
//            graphPath.move(
//                to: CGPoint(x: xPoint, y: getYPoint(0))
//            )
//
//            if graphPoint.element == nil { continue }
//            let nextPoint = CGPoint(x: xPoint, y: getYPoint(graphPoint.element!))
//            graphPath.addLine(to: nextPoint)
//
//            graphPath.lineWidth = 30
//            color.setStroke()
//            graphPath.stroke()
//            graphPath.close()
//        }
//    }
//}

