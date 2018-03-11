//
//  StartViewController.swift
//  nback
//
//  Created by 山口浩明 on 2017/12/29.
//  Copyright © 2017年 hiroaki.yamaguchi. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController {

    var appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
    var audioPlayers:Array<AVAudioPlayer> = []
    
    // ラベル
    @IBOutlet weak var settingDisplay: UILabel!
    @IBOutlet weak var currentNumLabel: UILabel!
    @IBOutlet weak var problemNumLabel: UILabel!
    // 各セル
    @IBOutlet weak var cell1: UIView!
    @IBOutlet weak var cell2: UIView!
    @IBOutlet weak var cell3: UIView!
    @IBOutlet weak var cell4: UIView!
    @IBOutlet weak var cell5: UIView!
    @IBOutlet weak var cell6: UIView!
    @IBOutlet weak var cell7: UIView!
    @IBOutlet weak var cell8: UIView!
    @IBOutlet weak var cell9: UIView!
    var cells: Array<UIView>!
    // サウンド
    var soundList: Array<String> = ["c","h","k","l","q","r","s","t"]
    
    var positions: Array<Int>! = [] //表示セル
    var sounds: Array<Int>! = []    //再生サウンド
    var currentNum: Int = 0 //現在の問題数
    var problemNum: Int = 0 //トータル問題数
    var answerPositions: Array<Bool>! = []  //false: クリックしてない 、true: クリックした
    var answerSounds: Array<Bool>! = [] //false: クリックしてない 、true: クリックした
    var timer = Timer()
    var isDisplay = true
    // 設定
    var type: String = "single"
    var N = 2
    
    @IBOutlet weak var positionBtn: UIButton!
    @IBOutlet weak var soundBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 背景
        setBackgroundColor(view: self.view)

        start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ボタン設定
        if (self.appDelegate.setting.type != "dual") {
            // 中央寄せ
            let width = UIScreen.main.bounds.size.width
            self.positionBtn.frame.origin.x = width / 2 - 100 / 2   // 真ん中配置
        }
    }
    
    func start() {
        // 初期化
        if (!self.appDelegate.startTask) {
            // 結果画面から戻ってきた場合なので、何もしない
            self.dismiss(animated: false, completion: nil)
            return
        }
        self.appDelegate.startTask = false
        // ラベル
        var label = self.settingDisplay.text
        label = label?.replacingOccurrences(of: "_type_", with: self.appDelegate.setting.type)
        label = label?.replacingOccurrences(of: "_n_", with: String(self.appDelegate.setting.N))
        self.settingDisplay.text = label
        // ボタン
        self.positionBtn.isHidden = true
        self.soundBtn.isHidden = true
        self.positionBtn.isEnabled = false
        self.soundBtn.isEnabled = false
        // 問題数
        self.N = self.appDelegate.setting.N
        self.problemNum = 20 + self.N * self.N
        self.currentNumLabel.text = String(1)
        self.problemNumLabel.text = "/ " + String(self.problemNum)
        // セル（位置）
        self.cells = [cell1,cell2,cell3,cell4,cell5,cell6,cell7,cell8,cell9]
        for cell in self.cells {
            cell.isHidden = true
        }
        // サウンド
        if (self.appDelegate.setting.type == "dual") {
            for s in self.soundList {
                let sound = NSDataAsset(name: s)
                let player = try? AVAudioPlayer(data: (sound?.data)!)
                self.audioPlayers.append(player!)
            }
        }
        // 問題設定
        // 初期化
        for _ in 0..<problemNum {
            self.answerPositions.append(false)
            self.answerSounds.append(false)
        }
        // 位置（最低3つ以上マッチする問題にする）
        while(true) {
            self.positions = []
            var matchNum = 0
            for _ in 0..<problemNum {
                // 位置
                let r = arc4random_uniform(UInt32(self.cells.count))
                self.positions.append(Int(r))
            }
            // マッチする問題か
            for i in self.N..<self.positions.count {
                if (self.positions[i - self.N] == self.positions[i]) {
                    //マッチ
                    matchNum += 1
                }
            }
            if (matchNum > 2) {
                break
            }
        }
        // サウンド（最低3つ以上マッチする問題にする）
        while(true) {
            self.sounds = []
            var matchNum = 0
            for _ in 0..<problemNum {
                // サウンド（面倒だからどのタイプでも設定だけしておいて再生はさせない）
                let r = arc4random_uniform(UInt32(self.soundList.count))
                self.sounds.append(Int(r))
            }
            // マッチする問題か
            for i in self.N..<self.sounds.count {
                if (self.sounds[i - self.N] == self.sounds[i]) {
                    //マッチ
                    matchNum += 1
                }
            }
            if (matchNum > 2) {
                break
            }
        }
        // タスク開始
//        task()
        // 2回目移行はタイマーで呼び出す
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(self.task),
            userInfo: nil,
            repeats: true)
        // スコア計算
        print("---score----")
    }
    
    @objc func task() {
        // 終了判定
        if (self.currentNum == self.positions.count) {
            calcScore()
            print ("----finish----:")
            self.timer.invalidate()
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "ResultBoard")
            self.present(nextView, animated: true, completion: nil)

            return
        }
        if (self.isDisplay) {
            // 開始
            let nextPosition = self.positions[self.currentNum]
            let nextSound = self.sounds[self.currentNum]
//            if (currentNum != 0) {
//                let prePosition = self.positions[self.currentNum - 1]
//                self.cells[prePosition].isHidden = true
//                //TODO: sleep
//                print(self.currentNum)
//            }
            // 表示
            self.cells[nextPosition].isHidden = false
            if (self.appDelegate.setting.type == "dual") {
                self.audioPlayers[nextSound].play()
            }
            // 更新
            self.currentNum += 1
            self.currentNumLabel.text = String(self.currentNum)
            // ボタン表示
            if (self.currentNum == self.N + 1) {
                self.positionBtn.isHidden = false
                if (self.appDelegate.setting.type == "dual") {
                    self.soundBtn.isHidden = false
                }
            }
            // ボタン活性化
            if (self.currentNum > self.N) {
                self.positionBtn.isEnabled = true
                self.positionBtn.alpha = 1.0
                self.soundBtn.isEnabled = true
                self.soundBtn.alpha = 1.0
            }
            self.isDisplay = false
            print(self.currentNum)
        } else {
            let prePosition = self.positions[self.currentNum - 1]
            self.cells[prePosition].isHidden = true
            self.isDisplay = true
        }

    }
    
    /*
     * スコア計算
     */
    func calcScore() {
        // スコアの格納先
//        var result:Array<Any> = Array()
        let now = Date()
//        result.append(now)
        var result:Dictionary<String, Any> = Dictionary()
        result["date"] = now
        // ポジションのスコア
        var correctPosition = 0
        var correctSound = 0
        var errorPosition = 0
        var errorSound = 0
        var scorePosition = 0.0
        var scoreSound = 0.0
        for i in self.N..<self.positions.count {
            if (self.positions[i - self.N] == self.positions[i]) {
                //マッチ
                if (self.answerPositions[i]) {
                    correctPosition += 1
                } else {
                    errorPosition += 1
                }
            } else {
                //マッチしていない
                if (self.answerPositions[i]) {
                    errorPosition += 1
                }
            }
        }
        scorePosition = Double(correctPosition) / Double(correctPosition + errorPosition)
//        result.append(scorePosition)
        result["scorePosition"] = scorePosition
        // サウンドの計算
        if (self.appDelegate.setting.type == "dual") {
            for i in self.N..<self.sounds.count {
                if (self.sounds[i - self.N] == self.sounds[i]) {
                    if (self.answerSounds[i]) {
                        correctSound += 1
                    } else {
                        errorSound += 1
                    }
                } else {
                    if (self.answerSounds[i]) {
                        errorSound += 1
                    }
                }
            }
            scoreSound = Double(correctSound) / Double(correctSound + errorSound)
//            result.append(scoreSound)
            result["scoreSound"] = scoreSound
        }
        result["score"] = Double(correctPosition + correctSound) / Double(correctPosition + correctSound + errorPosition + errorSound)
        
        // 保存
//        self.appDelegate.userDefaults.set(<#T##url: URL?##URL?#>, forKey: <#T##String#>)
        let key = self.appDelegate.setting.type + "_" + String(self.appDelegate.setting.N)
        var scoreTable = self.appDelegate.scoreTable
        if (scoreTable[key] != nil) {
            scoreTable[key]?.append(result)
        } else {
            scoreTable[key] = [result]
        }
        
        self.appDelegate.scoreTable = scoreTable
        self.appDelegate.userDefaults.set(scoreTable, forKey: "score")
        
        print ("score:")
        print (scoreTable)
        print (scorePosition)
        print (scoreSound)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickPosition(_ sender: Any) {
        self.positionBtn.isEnabled = false
        self.positionBtn.alpha = 0.5
        self.answerPositions[self.currentNum - 1] = true
    }
    
    @IBAction func clickSound(_ sender: Any) {
        self.soundBtn.isEnabled = false
        self.soundBtn.alpha = 0.5
        self.answerSounds[self.currentNum - 1] = true
    }
    
//    @IBAction func back(_ sender: UIButton) {
//        //1つ前に戻る
//        print("push back button")
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func backToHome(_ sender: UIButton) {
//        //Homeまで戻る
//        print("push backToHome button")
//        guard let preVc = self.presentingViewController as? CountDownViewController else {return}
//        preVc.dismiss(animated: false, completion: nil)
//      preVc.back(UIButton())
//        
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
