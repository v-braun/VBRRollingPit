//
//  RollingPitTabBar.swift
//  VBRRollingPit
//
//  Created by Viktor Braun on 27.07.2018.
//  Copyright © 2018 Viktor Braun - Software Development. All rights reserved.
//

import UIKit

let pi = CGFloat.pi
let pi2 = CGFloat.pi / 2

extension CGFloat {
    public func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}

@IBDesignable class RollingPitTabBar: UITabBar {
    
    @IBInspectable public var barBackColor : UIColor = UIColor.white
    @IBInspectable public var barHeight : CGFloat = 65
    @IBInspectable public var barTopRadius : CGFloat = 10
    @IBInspectable public var barBottomRadius : CGFloat = 20
    
    @IBInspectable public var circleBackColor : UIColor = UIColor.white
    @IBInspectable public var circleRadius : CGFloat = 40
    
    @IBInspectable var marginBottom : CGFloat = 5
    @IBInspectable var marginTop : CGFloat = 0
    
    
    let marginLeft : CGFloat = 15
    let marginRight : CGFloat = 15
    
    
    let pitCornerRad : CGFloat = 10
    
    let pitCircleDistanceOffset : CGFloat = 7
    
    


    private var barRect : CGRect{
        get{
            let h = self.barHeight
            let w = bounds.width - (marginLeft + marginRight)
            let x = bounds.minX + marginLeft
            let y = marginTop + circleRadius
            
            let rect = CGRect(x: x, y: y, width: w, height: h)
            return rect
        }
    }
    
    private func createCircleRect() -> CGRect{
        
        let backRect = barRect
        let radius = circleRadius
        let circleXCenter = getCircleCenter()
        
        let x : CGFloat = circleXCenter - radius
        let y = backRect.origin.y - radius + pitCircleDistanceOffset
        
        
        let pos = CGPoint(x: x, y: y)
        
        
        let result = CGRect(origin: pos, size: CGSize(width: radius * 2, height: radius * 2))
        return result
    }
    
    private func createCirclePath() -> CGPath{
        let circleRect = createCircleRect()
        let result = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRect.height / 2);
        
        return result.cgPath
    }
    
    
    private func getCircleCenter() -> CGFloat{
        let totalWidth = self.bounds.width
        var x = totalWidth / 2
        if let v = getViewForItem(item: self.selectedItem){
            x = v.frame.minX + (v.frame.width / 2)
        }
        
        return x
    }
    
    
    func createPitMaskPath(rect: CGRect) -> CGMutablePath {
        let circleXcenter = getCircleCenter()
        let backRect = barRect
        let x : CGFloat = circleXcenter + pitCornerRad
        let y = backRect.origin.y
        
        let center = CGPoint(x: x, y: y)
        
        
        
        let maskPath = CGMutablePath()
        maskPath.addRect(rect)
        
        let pit = createPitPath(center: center)
        maskPath.addPath(pit)
        
        return maskPath
    }
    
    
    
    func createPitPath(center : CGPoint) -> CGPath{
        let rad = self.circleRadius + 5
        let x = center.x - rad - pitCornerRad
        let y = center.y
        
        let result = UIBezierPath()
        result.lineWidth = 0
        result.move(to: CGPoint(x: x - 0, y: y + 0))
        
        result.addArc(withCenter: CGPoint(x: (x - pitCornerRad), y: (y + pitCornerRad)), radius: pitCornerRad, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        
        result.addArc(withCenter: CGPoint(x: (x + rad), y: (y + pitCornerRad ) ), radius: rad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)
        
        result.addArc(withCenter: CGPoint(x: (x + (rad * 2) + pitCornerRad), y: (y + pitCornerRad) ), radius: pitCornerRad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        
        result.addLine(to: CGPoint(x: x + (pitCornerRad * 2) + (rad * 2), y: y)) // rounding errors correction lines
        result.addLine(to: CGPoint(x: 0, y: 0))
        
        result.close()
        
        return result.cgPath
    }
    
    private func createBackgroundPath() -> CGPath{
        let rect = barRect
        let topLeftRadius = self.barTopRadius
        let topRightRadius = self.barTopRadius
        let bottomRigtRadius = self.barBottomRadius
        let bottomLeftRadius = self.barBottomRadius
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topLeftRadius, y:rect.minY))
        
        path.addArc(withCenter: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle:3 * pi2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRigtRadius))
        path.addArc(withCenter: CGPoint(x: rect.maxX - bottomRigtRadius, y: rect.maxY - bottomRigtRadius), radius: bottomRigtRadius, startAngle: 0, endAngle: pi2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX + bottomRigtRadius, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: pi2, endAngle: pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(withCenter: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: pi, endAngle: 3 * pi2, clockwise: true)
        path.close()
        
        return path.cgPath
    }
    
    private lazy var background: CAShapeLayer = {
        let result = CAShapeLayer();
        result.fillColor = self.barBackColor.cgColor
        result.mask = self.backgroundMask
        
        return result
    }()
    
    private lazy var circle : CAShapeLayer = {
        let result = CAShapeLayer()
        
        result.fillColor = circleBackColor.cgColor
        
        return result
    }()
    
    private lazy var backgroundMask : CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillRule = kCAFillRuleEvenOdd
        return result
    }()




    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = self.barHeight + marginTop + marginBottom + self.circleRadius
        return sizeThatFits
    }
    
    private func getTabBarItemViews() -> [(item : UITabBarItem, view : UIView)]{
        guard let items = self.items else{
            return[]
        }
        
        var result : [(item : UITabBarItem, view : UIView)] = []
        for item in items {
            if let v = getViewForItem(item: item) {
                result.append((item: item, view: v))
            }
            
        }
        
        return result
    }
    
    private func getViewForItem(item : UITabBarItem?) -> UIView?{
        if let item = item {
            let v = item.value(forKey: "view") as? UIView
            return v
        }
        
        return nil
        
    }
    
    private func positionItem(barRect : CGRect, totalCount : Int, idx : Int, item : UITabBarItem, view : UIView){
        let margin : CGFloat = 5
        let x = view.frame.origin.x
        var y = barRect.origin.y + margin
        let h = barHeight - (margin * 2)
        let w = view.frame.width
        if self.selectedItem == item {
            y = barRect.origin.y - (self.circleRadius / 2)
        }
        
        
        view.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func animateHideAndShowItem(itemView : UIView){
        itemView.alpha = 0
        itemView.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400) , execute: {
            UIView.animate(withDuration: 0.4) {
                itemView.alpha = 1
            }
        })
        

    }
    private func createPathMoveAnimation(toVal : CGPath) -> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
//        animation.beginTime = CACurrentMediaTime() + 2
        animation.toValue = toVal
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    private func replaceAnimation(layer :CAShapeLayer, withNew : CABasicAnimation, forKey: String){
        
        let existing = layer.animation(forKey: forKey) as? CABasicAnimation
        if existing != nil{
            withNew.fromValue = existing!.toValue
        }
        
        layer.removeAnimation(forKey: forKey)
        layer.add(withNew, forKey: forKey)
    }
    
    private func moveCircleAnimated(){
        let bgMaskNewPath = self.createPitMaskPath(rect: self.bounds)
        let circleNewPath = self.createCirclePath()
    
        let bgAni = createPathMoveAnimation(toVal: bgMaskNewPath)
        let circleAni = createPathMoveAnimation(toVal: circleNewPath)
        
        
        self.replaceAnimation(layer: backgroundMask, withNew: bgAni, forKey: "move_animation")
        self.replaceAnimation(layer: circle, withNew: circleAni, forKey: "move_animation")
        
    }
    
    private func layoutElements(selectedChanged : Bool){
        self.background.path = self.createBackgroundPath()
        if self.backgroundMask.path == nil {
            self.backgroundMask.path = self.createPitMaskPath(rect: self.bounds)
            self.circle.path = self.createCirclePath()
        }
        else{
            moveCircleAnimated()
        }
        
        let items = getTabBarItemViews()
        if items.count <= 0 {
            return
        }
        
        let barR = barRect
        let total = items.count
        for (idx, item) in items.enumerated() {
            if selectedChanged {
                self.animateHideAndShowItem(itemView: item.view)
            }
            
            self.positionItem(barRect: barR, totalCount: total, idx: idx, item: item.item, view: item.view)
        }
    }
    
    override var selectedItem: UITabBarItem? {
        get{
            return super.selectedItem
        }
        set{
            let changed = (super.selectedItem != newValue)
            super.selectedItem = newValue
            if changed {
                layoutElements(selectedChanged: changed)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.fillColor = self.barBackColor.cgColor
        circle.fillColor = self.circleBackColor.cgColor
        
        self.layoutElements(selectedChanged: false)
        
        
    }
    
    override func prepareForInterfaceBuilder() {
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        
        background.fillColor = self.barBackColor.cgColor
        circle.fillColor = self.circleBackColor.cgColor
        
    }
    
    private func setup(){
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        
        
        self.layer.insertSublayer(background, at: 0)
        self.layer.insertSublayer(circle, at: 0)        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
}



