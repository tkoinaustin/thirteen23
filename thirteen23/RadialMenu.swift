//
//  RadialMenu.swift
//  thirteen23
//
//  Created by Tom Nelson on 8/6/15.
//  Copyright © 2015 TKO Solutions. All rights reserved.
//

import UIKit

protocol RadialMenuDelegate : class {
    func onSelected(menuItem: RadialButton)
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
        super.init(coder: aDecoder)
        radialMenuSetup()
    }
    
    // MARK: - Configure Menu View
    
    func radialMenuSetup() {
        MenuItemHasBeenSelected = false
        self.backgroundColor = UIColor.clearColor()
        radialIconTouch = makeRadialIcon(RadialButton.touch)
        self.addSubview(radialIconTouch)
    }
    
    
    func setButtons(radialButtons:[RadialButton], quadrant:Quadrant) {
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

        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconTouch.alpha = 1
            }, completion: nil)
       
        UIView.animateWithDuration(0.9, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconOne.center = self.findIconCenterPoint(0,quadrant:quadrant)
            self.radialIconOne.alpha = self.transparency
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconTwo.center = self.findIconCenterPoint(1,quadrant:quadrant)
            self.radialIconTwo.alpha = self.transparency
            }, completion: nil)
        
        if haveAThirdButton {
            UIView.animateWithDuration(0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.radialIconThree.center = self.findIconCenterPoint(2,quadrant:quadrant)
                self.radialIconThree.alpha = self.transparency
                }, completion: nil)
        }
    }
    
    // Because there are a limited number of icons I just populated an array.
    // A more elegant solution would have been using geometry to set locations
    // based on the number of icons and screen location, but overkill in this case
    func findIconCenterPoint(iconNumber:Int, quadrant:Quadrant) -> CGPoint {
        var points:[CGPoint]?
        switch (quadrant) {
        case .TopLeft:
            points = [CGPointMake(350,200),CGPointMake(308,308),CGPointMake(200,350)]
        case .TopRight:
            points = [CGPointMake(50,200),CGPointMake(92,308),CGPointMake(200,350)]
        case .Left:
            points = [CGPointMake(308,92),CGPointMake(350,200),CGPointMake(308,308)]
        case .Right:
            points = [CGPointMake(92,92),CGPointMake(50,200),CGPointMake(92,308)]
        case .BottomLeft:
            points = [CGPointMake(200,50),CGPointMake(308,92),CGPointMake(350,200)]
        case .BottomRight:
            points = [CGPointMake(200,50),CGPointMake(92,92),CGPointMake(50,200)]
        }
        return points![iconNumber]
    }
    
    func setupDelegate( myDelegate:RadialMenuDelegate)
    {
        delegate = myDelegate
    }
    
    // MARK: - Animation
    
    // We are done, gracefully remove the radial menu from the superview and optionally call the delegate for action
    func animateOut(actionToTake:RadialButton?) {
        // prevent the view controller from early dismissal if performing the HitTest animation
        if MenuItemHasBeenSelected && actionToTake == nil { return }
        UIView.animateWithDuration(0.5,  delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconOne.alpha = 0
           }, completion: nil)
        
        UIView.animateWithDuration(0.4,  delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconTwo.alpha = 0
            self.radialIconTouch.backgroundColor = UIColor.grayColor()
            }, completion: nil)
        
        UIView.animateWithDuration(0.3,  delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconThree.alpha = 0
            }, completion: nil)
        
        UIView.animateWithDuration(0.3,  delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.radialIconTouch.alpha = 0
            }, completion: {
                _ in self.removeFromSuperview()
                if let actionToTake = actionToTake {
                    self.delegate!.onSelected(actionToTake)
                }
        })
    }

    func newCoordinates(var point:CGPoint)
    {
        // translate the location from parent into radial menu coordinates
        point.x += self.frame.width / 2.0
        point.y += self.frame.height / 2.0

        buttonHitTest(radialIconOne, point:point, actionToTake:radialMenuButtons![0])
        buttonHitTest(radialIconTwo, point:point, actionToTake:radialMenuButtons![1])
        if radialMenuButtons!.count > 2 {
            buttonHitTest(radialIconThree, point:point, actionToTake:radialMenuButtons![2])
        }
    }
    
    func buttonHitTest(button:UIView, point:CGPoint, actionToTake:RadialButton) {
        if CGRectContainsPoint(button.frame, point) {
            MenuItemHasBeenSelected = true
            button.backgroundColor = UIColor.greenColor()
            UIView.animateWithDuration(0.5, animations: {
                button.transform = CGAffineTransformMakeScale(1.4, 1.4)
                button.alpha = 1
                }, completion: {
                    _ in self.animateOut(actionToTake)
            })
        }
    
    }
    
    func makeRadialIcon(radialButton:RadialButton) -> UIView {
        let icon = UIView()
        icon.frame = CGRectMake(0.0, 0.0, iconSize, iconSize)
        icon.center = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0)
        icon.layer.cornerRadius = 30
        icon.backgroundColor = UIColor.lightGrayColor()
        icon.layer.borderWidth = 1
        icon.alpha = 0
        let label = UILabel(frame: CGRectMake(0, 0, iconSize, iconSize))
        label.textAlignment = NSTextAlignment.Center
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
            icon.backgroundColor = UIColor.clearColor()
            icon.layer.borderWidth = 0.5
        }
        icon.addSubview(label)
        return icon
    }
    
    func handleMenuSwipe(recognizer: UIPanGestureRecognizer) {
        if MenuItemHasBeenSelected { return }
        if recognizer.state == .Changed {
            let point = recognizer.translationInView(self)
            newCoordinates(point)
        }
    }

}

//MARK:- Enums

public enum Direction : Int {
    case None, Left, Up, Right, Down
}

public enum RadialButton : Int {
    case home, one, two, three, touch
}

public enum Quadrant : Int {
    case TopLeft, TopRight, Left, Right, BottomLeft, BottomRight
}