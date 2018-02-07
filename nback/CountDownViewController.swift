//
//  CountDownViewController.swift
//  nback
//
//  Created by 山口浩明 on 2018/01/06.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//



import UIKit

class CountDownViewController: UIViewController,CAAnimationDelegate {
    
    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    
    var _countNumberLabel:UILabel!
    let _countDownMax:Int = 3
    var _countDownNum:Int = 3
    var _circleView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // カウントダウン数値ラベル設定
        _countNumberLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height))
        _countNumberLabel.font = UIFont(name: "HelveticaNeue", size: 54)
        // 中心揃え
        _countNumberLabel.textAlignment = NSTextAlignment.center
        _countNumberLabel.baselineAdjustment = UIBaselineAdjustment.alignCenters
        self.view.addSubview(_countNumberLabel)
        
        _circleView = UIView(frame : CGRect(x:(self.view.frame.width/2)-100, y:(self.view.frame.height/2)-100, width:200, height:200))
        _circleView.layer.addSublayer(drawCircle(viewWidth:_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.2)))
        _circleView.layer.addSublayer(drawCircle(viewWidth:_circleView.frame.width, strokeColor: UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0)))
        self.view.addSubview(_circleView)
    }
    
    // 遷移毎に実行
    override func viewWillAppear(_: Bool) {
        // 数値をリセット
        _countDownNum = _countDownMax
        _countNumberLabel.text = String(_countDownNum)
        // アニメーション開始
        circleAnimation(layer:_circleView.layer.sublayers![1] as! CAShapeLayer)
    }
    
    func drawCircle(viewWidth:CGFloat, strokeColor:UIColor) -> CAShapeLayer {
        var circle:CAShapeLayer = CAShapeLayer()
        // ゲージ幅
        let lineWidth: CGFloat = 20
        // 描画領域のwidth
        let viewScale: CGFloat = viewWidth
        // 円のサイズ
        let radius: CGFloat = viewScale - lineWidth
        // 円の描画path設定
        circle.path = UIBezierPath(roundedRect: CGRect(x:0, y:0, width:radius, height:radius), cornerRadius: radius / 2).cgPath
        // 円のポジション設定
        circle.position = CGPoint(x:lineWidth / 2, y:lineWidth / 2)
        // 塗りの色を設定
        circle.fillColor = UIColor.clear.cgColor
        // 線の色を設定
        circle.strokeColor = strokeColor.cgColor
        // 線の幅を設定
        circle.lineWidth = lineWidth
        return circle
    }
    
    func circleAnimation(layer:CAShapeLayer) {
        // アニメーションkeyを設定
        var drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // callbackで使用
        drawAnimation.setValue(layer, forKey:"animationLayer")
        // callbackを使用する場合
        drawAnimation.delegate = self
        // アニメーション間隔の指定
        drawAnimation.duration = 1.0
        // 繰り返し回数の指定
        drawAnimation.repeatCount = 1.0
        // 起点と目標点の変化比率を設定 (0.0 〜 1.0)
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        // イージング設定
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.add(drawAnimation, forKey: "circleAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation!, finished flag: Bool) {
        let layer:CAShapeLayer = anim.value(forKey:"animationLayer") as! CAShapeLayer
        _countDownNum -= 1
        // 表示ラベルの更新
        _countNumberLabel.text = String(_countDownNum)
        
        if _countDownNum <= 0 {
//            self.appDelegate.startTask = true
            //次の画面へ遷移(navigationControllerの場合)
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "startBoard")
            self.present(nextView, animated: true, completion: nil)
        } else {
            circleAnimation(layer:layer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func back(_ sender: UIButton) {
//        //1つ前に戻る
//        print("push back button by countdown")
//        self.dismiss(animated: false, completion: nil)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
