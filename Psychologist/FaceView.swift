//
//  FaceView.swift
//  Happiness
//
//  Created by Zhiheng Yi on 2015-05-28.
//  Copyright (c) 2015 Zhiheng Yi. All rights reserved.
//

import UIKit

//新建的protocal
protocol FaceViewDataSource: class {
    func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
    @IBInspectable
    //设置线的一些属性,线粗,颜色等
    var lineWidth: CGFloat = 3 {didSet {setNeedsDisplay()}}
    var color: UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}
    var scale: CGFloat = 0.90{didSet {setNeedsDisplay()}}   //You can use this method or the setNeedsDisplayInRect: to notify the system that your view’s contents need to be redrawn.
    
    var faceCenter: CGPoint {
        get {
            return convertPoint(center, fromView: superview)
        }
    }
    var faceRadius: CGFloat {
        get {
            //取bound的宽度或高度,取小的
            return min(bounds.size.width, bounds.size.height) / 2 * scale
        }
    }
    
    weak var dataSource: FaceViewDataSource?
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10  //脸的半径是眼睛半径的几倍
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye {
        case Left,Right
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
        // 嘴的宽度,高度等参数
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        //max(min(fractionOfMaxSmile, 1), -1)设置了范围在-1到1之间
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y )
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius / Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y = eyeCenter.y - eyeVerticalOffset
        
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path //函数返回一个UIBezierPath类型的变量
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale = scale * gesture.scale
            gesture.scale = 1
        }
    }
    
    override func drawRect(rect: CGRect) {
        //画圆,成为脸的基准
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth  //设置脸的线宽
        color.set()
        facePath.stroke()   //UIBezierPath.stroke()指画线
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0 //两个问号符,如果前面是nil,则用后面的值,smiliness的值也是在这里被从controller里传进来
        
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
        
    }
}
