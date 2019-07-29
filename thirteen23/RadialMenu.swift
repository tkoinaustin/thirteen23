//
//  RadialMenu.swift
//  thirteen23
//
//  Created by Tom Nelson on 8/6/15.
//  Copyright © 2015 TKO Solutions. All rights reserved.
//

import UIKit

protocol RadialMenuDelegate : class {
    func onSelected(_ menuItem: RadialButton)
}

class RadialMenuView: UIView, UIGestureRecognizerDelegate {
    
    //MARK: - Properties
    
    var radialIconTouch = UIView()
    var radialIconOne = UIView()
    var radialIconTwo = UIView()
    var radialIconThree = UIView()
    let iconSize:CGFloat = 60
    let transparency:CGFloat = 0.8
    var MenuItemHasBeenSelected:Bool = false
    var radialMenuButtons:[RadialButton]? = nil
    weak var delegate:RadialMenuDelegate? = nil
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        radialMenuSetup()
    }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
    // MARK: - Configure Menu View
    
    func radialMenuSetup() {
        MenuItemHasBeenSelected = false
        self.backgroundColor = UIColor.clear
        radialIconTouch = makeRadialIcon(RadialButton.touch)
        self.addSubview(radialIconTouch)
    }
    
    
    func setButtons(_ radialButtons:[RadialButton], quadrant:Quadrant) {
        for btn:RadialButton in radialButtons {
            print("Button name is \(btn)")
        }
        radialMenuButtons = radialButtons
        let haveAThirdButton:Bool = radialButtons.count > 2
        radialIconOne = makeRadialIcon(radialButtons[0])
        radialIconTwo = makeRadialIcon(radialButtons[1])
        if haveAThirdButton { radialIconThree = makeRadialIcon(radialButtons[2]) }

        self.addSubview(radialIconOne)
        self.addSubview(radialIconTwo)
        if haveAThirdButton { self.addSubview(radialIconThree) }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            self.radialIconTouch.alpha = 1
            }, completion: nil)
       
        UIView.animate(withDuration: 0.9, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: UIView.AnimationOptions(), animations: {
            self.radialIconOne.center = self.findIconCenterPoint(0,quadrant:quadrant)
            self.radialIconOne.alpha = self.transparency
            }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIView.AnimationOptions(), animations: {
            self.radialIconTwo.center = self.findIconCenterPoint(1,quadrant:quadrant)
            self.radialIconTwo.alpha = self.transparency
            }, completion: nil)
        
        if haveAThirdButton {
            UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: UIView.AnimationOptions(), animations: {
                self.radialIconThree.center = self.findIconCenterPoint(2,quadrant:quadrant)
                self.radialIconThree.alpha = self.transparency
                }, completion: nil)
        }
    }
    
    // Because there are a limited number of icons I just populated an array.
    // A more elegant solution would have been using geometry to set locations
    // based on the number of icons and screen location, but overkill in this case
    func findIconCenterPoint(_ iconNumber:Int, quadrant:Quadrant) -> CGPoint {
        var points:[CGPoint]?
        switch (quadrant) {
        case .topLeft:
            points = [CGPoint(x: 350,y: 200),CGPoint(x: 308,y: 308),CGPoint(x: 200,y: 350)]
        case .topRight:
            points = [CGPoint(x: 50,y: 200),CGPoint(x: 92,y: 308),CGPoint(x: 200,y: 350)]
        case .left:
            points = [CGPoint(x: 308,y: 92),CGPoint(x: 350,y: 200),CGPoint(x: 308,y: 308)]
        case .right:
            points = [CGPoint(x: 92,y: 92),CGPoint(x: 50,y: 200),CGPoint(x: 92,y: 308)]
        case .bottomLeft:
            points = [CGPoint(x: 200,y: 50),CGPoint(x: 308,y: 92),CGPoint(x: 350,y: 200)]
        case .bottomRight:
            points = [CGPoint(x: 200,y: 50),CGPoint(x: 92,y: 92),CGPoint(x: 50,y: 200)]
        }
        return points![iconNumber]
    }
    
    func setupDelegate( _ myDelegate:RadialMenuDelegate)
    {
        delegate = myDelegate
    }
    
    // MARK: - Animation
    
    // We are done, gracefully remove the radial menu from the superview and optionally call the delegate for action
    func animateOut(_ actionToTake:RadialButton?) {
        // prevent the view controller from early dismissal if performing the HitTest animation
        if MenuItemHasBeenSelected && actionToTake == nil { return }
        UIView.animate(withDuration: 0.5,  delay: 0.0, options: UIView.AnimationOptions(), animations: {
            self.radialIconOne.alpha = 0
           }, completion: nil)
        
        UIView.animate(withDuration: 0.4,  delay: 0.1, options: UIView.AnimationOptions(), animations: {
            self.radialIconTwo.alpha = 0
            self.radialIconTouch.backgroundColor = UIColor.gray
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3,  delay: 0.2, options: UIView.AnimationOptions(), animations: {
            self.radialIconThree.alpha = 0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3,  delay: 0.3, options: UIView.AnimationOptions(), animations: {
            self.radialIconTouch.alpha = 0
            }, completion: {
                _ in self.removeFromSuperview()
                if let actionToTake = actionToTake {
                    self.delegate!.onSelected(actionToTake)
                }
        })
    }

    func newCoordinates(_ point:CGPoint)
    {
        var point = point
        // translate the location from parent into radial menu coordinates
        point.x += self.frame.width / 2.0
        point.y += self.frame.height / 2.0

        buttonHitTest(radialIconOne, point:point, actionToTake:radialMenuButtons![0])
        buttonHitTest(radialIconTwo, point:point, actionToTake:radialMenuButtons![1])
        if radialMenuButtons!.count > 2 {
            buttonHitTest(radialIconThree, point:point, actionToTake:radialMenuButtons![2])
        }
    }
    
    func buttonHitTest(_ button:UIView, point:CGPoint, actionToTake:RadialButton) {
        if button.frame.contains(point) {
            MenuItemHasBeenSelected = true
            button.backgroundColor = UIColor.green
            UIView.animate(withDuration: 0.5, animations: {
                button.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                button.alpha = 1
                }, completion: {
                    _ in self.animateOut(actionToTake)
            })
        }
    }
    
    func makeRadialIcon(_ radialButton:RadialButton) -> UIView {
        let icon = UIView()
        icon.frame = CGRect(x: 0.0, y: 0.0, width: iconSize, height: iconSize)
        icon.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
        icon.layer.cornerRadius = 30
        icon.backgroundColor = UIColor.lightGray
        icon.layer.borderWidth = 1
        icon.alpha = 0
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
        label.textAlignment = NSTextAlignment.center
        switch (radialButton) {
        case .home:
            label.text = "h"
        case .one:
            label.text = "1"
        case .two:
            label.text = "2"
        case .three:
            label.text = "3"
        case .touch:
            label.text = ""
            icon.backgroundColor = UIColor.clear
            icon.layer.borderWidth = 0.5
        }
        icon.addSubview(label)
        return icon
    }
    
    func handleMenuSwipe(_ recognizer: UIPanGestureRecognizer) {
        if MenuItemHasBeenSelected { return }
        if recognizer.state == .changed {
            let point = recognizer.translation(in: self)
            newCoordinates(point)
        }
    }

}

//MARK:- Enums

public enum Direction : Int {
    case none, left, up, right, down
}

public enum RadialButton : Int {
    case home, one, two, three, touch
}

public enum Quadrant : Int {
    case topLeft, topRight, left, right, bottomLeft, bottomRight
}
