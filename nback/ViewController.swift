//
//  ViewController.swift
//  nback
//
//  Created by 山口浩明 on 2017/12/29.
//  Copyright © 2017年 hiroaki.yamaguchi. All rights reserved.
//

import UIKit
import GoogleMobileAds


class ViewController: UIViewController {
    
    @IBOutlet weak var typeSegment: TTSegmentedControl!
    @IBOutlet weak var NSegment: TTSegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    

    @IBOutlet weak var bannerView: GADBannerView!
    
    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    
    func changeType(index:Int) {
        var type = "single"
        switch (index) {
        case 0:
            type = "single"
            break
        case 1:
            type = "dual"
            break
        default:
            type = "single"
        }
        self.appDelegate.setting.type = type
        self.appDelegate.userDefaults.set(type, forKey: "type")
    }
    
    func changeN(index:Int) {
        self.appDelegate.setting.N = index + 1
        self.appDelegate.userDefaults.set(index + 1, forKey: "N")
    }
    
    @IBAction func clickStart(_ sender: Any) {
        self.appDelegate.startTask = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // セグメントの初期値
        self.typeSegment.itemTitles = ["Single", "Dual"]
        if (self.appDelegate.setting.type == "single") {
            self.typeSegment.selectItemAt(index: 0)
        } else {
            self.typeSegment.selectItemAt(index: 1)
        }
        self.typeSegment.didSelectItemWith = {(i, title) -> () in
            self.changeType(index: i)
        }
        self.NSegment.itemTitles = ["1", "2", "3", "4", "5"]
        self.NSegment.selectItemAt(index: self.appDelegate.setting.N - 1)
        self.NSegment.didSelectItemWith = {(i, title) -> () in
            self.changeN(index: i)
        }
        
        // 背景
        setBackgroundColor(view: self.view)

        // AdMob広告設定
//        // In this case, we instantiate the banner with desired ad size.
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-5587634884366709/3770549232"
        bannerView.rootViewController = self
          bannerView.load(GADRequest())
        bannerView.delegate = self as? GADBannerViewDelegate
//        addBannerViewToView(bannerView)
        
    }
    
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bannerView)
//        view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: bottomLayoutGuide,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    @IBAction func reset(_ sender: Any) {
//        // 保存データを全削除
//        let userDefault = UserDefaults.standard
//        var appDomain:String = Bundle.main.bundleIdentifier!
//        UserDefaults.standard.removePersistentDomain(forName: appDomain)
//    }
    

}

