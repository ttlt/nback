//
//  Util.swift
//  nback
//
//  Created by 山口浩明 on 2018/02/27.
//  Copyright © 2018年 hiroaki.yamaguchi. All rights reserved.
//
import UIKit
import Foundation


func setBackgroundColor(view: UIView) {
    //グラデーションの開始色
    let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
    //グラデーションの開始色
//    let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
    let bottomColor = UIColor(red:0.44, green:0.64, blue:0.64, alpha:1)
    //グラデーションの色を配列で管理
    let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
    //グラデーションレイヤーを作成
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    //グラデーションの色をレイヤーに割り当てる
    gradientLayer.colors = gradientColors
    //グラデーションレイヤーをスクリーンサイズにする
    gradientLayer.frame = view.bounds
    //グラデーションレイヤーをビューの一番下に配置
    view.layer.insertSublayer(gradientLayer, at: 0)
}
