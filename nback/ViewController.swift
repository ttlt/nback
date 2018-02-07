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

    var bannerView: GADBannerView!
    
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var NSegment: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    
    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    
//    init?() {
//        self.setting = Setting()
//    }
    
    @IBAction func changeType(_ sender: Any) {
        var type = "single"
        switch (self.typeSegment.selectedSegmentIndex) {
        case 0:
            self.appDelegate.setting.type = "single"
            type = "single"
            break
        case 1:
            self.appDelegate.setting.type = "dual"
            type = "dual"
            break
        default:
            self.appDelegate.setting.type = "single"
            type = "single"
        }
        self.appDelegate.setting.type = type
        self.appDelegate.userDefaults.set(type, forKey: "type")
    }
    
    
    @IBAction func changeN(_ sender: Any) {
        self.appDelegate.setting.N = self.NSegment.selectedSegmentIndex + 1
    self.appDelegate.userDefaults.set(self.NSegment.selectedSegmentIndex + 1, forKey: "N")
    }
    
    @IBAction func clickStart(_ sender: Any) {
        self.appDelegate.startTask = true
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        // ボタン設定
//        let width = UIScreen.main.bounds.size.width
//        self.startButton.frame.origin.x = width / 2 - 120 / 2   // 真ん中配置
//        self.startButton.frame.size.width = 120
//        self.startButton.frame.size.height = 120
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // セグメントの初期値
        if (self.appDelegate.setting.type == "single") {
            self.typeSegment.selectedSegmentIndex = 0
        } else {
            self.typeSegment.selectedSegmentIndex = 1
        }
        self.NSegment.selectedSegmentIndex = self.appDelegate.setting.N - 1
        
        // AdMob広告設定
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-5587634884366709/3770549232"
        bannerView.rootViewController = self
          bannerView.load(GADRequest())
        bannerView.delegate = self as? GADBannerViewDelegate
        addBannerViewToView(bannerView)
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }

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

