//
//  ResultViewController.swift
//  nback
//
//  Created by 山口浩明 on 2018/01/07.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//

import UIKit
import GoogleMobileAds


class ResultViewController: UIViewController {
    
    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var positionScoreLabel: UILabel!
    @IBOutlet weak var soundScoreLabel: UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景
        setBackgroundColor(view: self.view)

        // Do any additional setup after loading the view.
        var settingLabel = self.settingLabel.text
        settingLabel = settingLabel?.replacingOccurrences(of: "_type_", with: self.appDelegate.setting.type)
        settingLabel = settingLabel?.replacingOccurrences(of: "_n_", with: String(self.appDelegate.setting.N))
        self.settingLabel.text = settingLabel
        // 最新スコア取得
        let type = self.appDelegate.setting.type
        let N = self.appDelegate.setting.N
        let scoreTable = self.appDelegate.scoreTable
        let key = type + "_" + String(N)
        if (scoreTable[key] != nil) {
            let scoreArray = scoreTable[key] as! Array<Dictionary<String, Any>>
            let currentScore = scoreArray.last!
            print (currentScore)
            let scoreLabel = self.scoreLabel.text
            let positionScoreLabel = self.positionScoreLabel.text
            let soundScoreLabel = self.soundScoreLabel.text
            self.scoreLabel.text = scoreLabel?.replacingOccurrences(of: "_score_", with: String(format:"%.1f", (currentScore["score"]! as! Double)*100.0))
            self.positionScoreLabel.text = positionScoreLabel?.replacingOccurrences(of: "_pScore_", with: String(format:"%.1f", (currentScore["scorePosition"]! as! Double)*100.0))
            if (type == "dual") {
                self.soundScoreLabel.text = soundScoreLabel?.replacingOccurrences(of: "_sScore_", with: String(format:"%.1f", (currentScore["scoreSound"]! as! Double)*100.0))
            } else {
                self.positionScoreLabel.isHidden = true
                self.soundScoreLabel.isHidden = true
            }
        } else {
            print ("unexpected error!")
        }
        // AdMob広告設定
        bannerView.adUnitID = "ca-app-pub-5587634884366709/3770549232"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self as? GADBannerViewDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func pushRetry(_ sender: Any) {
        // CountDownViewまで戻る
        self.appDelegate.startTask = true
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
//        guard let preVc = self.presentingViewController as? StartViewController else {return}
//        preVc.dismiss(animated: false, completion: nil)
        // StartViewControllerの戻るボタンを押す
//        preVc.back(UIButton())
    }
    
    @IBAction func pushHome(_ sender: Any) {
        // ViewControllerまで戻る
        self.appDelegate.startTask = false
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
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
