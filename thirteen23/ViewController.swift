//
//  ViewController.swift
//  thirteen23
//
//  Created by Tom Nelson on 8/5/15.
//  Copyright © 2015 TKO Solutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, RadialMenuDelegate {
    
    //MARK: - Properties
    
    var radialMenu:RadialMenuView? = nil
    let pressRecognizer = UILongPressGestureRecognizer()
    let panRecognizer = UIPanGestureRecognizer()
    let formHome:UIView = UIView()
    let formOne:UIView = UIView()
    let formTwo:UIView = UIView()
    let formThree:UIView = UIView()
    var lastButtonPressed:RadialButton = .home
    let radialMenuSize:CGFloat = 400
    
    
    // MARK: - view load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        pressRecognizer.addTarget(self, action: "handleLongPress:")
        self.view.addGestureRecognizer(pressRecognizer)
        panRecognizer.addTarget(self, action: "handleSwipe:")
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
        
        initAndAddForm(formOne, labelText: "one")
        initAndAddForm(formTwo, labelText: "two")
        initAndAddForm(formThree, labelText: "three")
        initAndAddForm(formHome, labelText: "home")
        formHome.alpha = 1.0
    }
    
    // If the device is rotated, place the label back in the center
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        UIView.animateWithDuration(0.3, animations: {
            self.formHome.center = self.view!.center
            self.formOne.center = self.view!.center
            self.formTwo.center = self.view!.center
            self.formThree.center = self.view!.center
        })
    }
    
    //MARK: - Helper Functions
    
    // This animates the view transitions in and out
    func animateForm(incomingView:UIView, outgoingView:UIView, direction:Direction) {
        var outgoingViewCenter = outgoingView.center
        switch (direction) {
        case .Down:
            incomingView.center.y -= self.view.frame.size.height
            outgoingViewCenter.y += self.view.frame.size.height
        case .Left:
            incomingView.center.x -= self.view.frame.size.width
            outgoingViewCenter.x += self.view.frame.size.width
        case .Right:
            incomingView.center.x += self.view.frame.size.width
            outgoingViewCenter.x -= self.view.frame.size.width
        case .Up:
            incomingView.center.y += self.view.frame.size.height
            outgoingViewCenter.y -= self.view.frame.size.height
        default: break
        }
        incomingView.alpha = 1.0
        self.view.bringSubviewToFront(incomingView)
        UIView.animateWithDuration(0.5, delay:0.0, options:[], animations: {
            incomingView.center = self.view!.center
            outgoingView.center = outgoingViewCenter
            }, completion:{ _ in
                outgoingView.alpha = 0.0
                outgoingView.center = self.view!.center
        })

    }
    
    func initAndAddForm(form:UIView, labelText:String) {
        form.frame = view.frame
        form.backgroundColor = UIColor.whiteColor()
        form.alpha = 0.0
        let label = UILabel(frame: CGRectMake(0, 0, 200, 50))
        label.center = form.center
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name:label.font.fontName, size:48)
        label.text = labelText
        form.addSubview(label)
        self.view.addSubview(form)

    }
    
    // This defines which buttons get displayed on the Radial Menu View for the different screens
    func getRadialButtons() -> [RadialButton] {
        switch (lastButtonPressed) {
        case .home:
            return [RadialButton.one,RadialButton.two,RadialButton.three]
        case .one:
            return [RadialButton.home,RadialButton.two]
        case .two:
            return [RadialButton.home,RadialButton.one,RadialButton.three]
        case .three:
            return [RadialButton.home,RadialButton.two]
        case .touch:
            return [RadialButton.home]
        }
    }
    
    func determineQuadrant(location:CGPoint, size:CGSize) -> Quadrant {
        return location.y > size.height * 0.75 ? (location.x > size.width / 2.0  ? .BottomRight : .BottomLeft) :
            location.y < size.height * 0.25 ? (location.x > size.width / 2.0 ? .TopRight : .TopLeft) :
            location.x > size.width / 2.0 ? .Right : .Left
    }
    
    //MARK: - Gesture Recognizer

    func handleLongPress(recognizer:UILongPressGestureRecognizer) {
        if recognizer.state == .Began {
            // load up the radialMenu centered at this spot
            let pressLocation = recognizer.locationInView(self.view)
            let windowSize = view.frame.size
            let quadrant = determineQuadrant(pressLocation, size: windowSize)
            radialMenu = RadialMenuView(frame: CGRectMake(0, 0, radialMenuSize, radialMenuSize))
            if let radialMenu = radialMenu {
                radialMenu.setupDelegate(self)
                radialMenu.center = pressLocation
                self.view.insertSubview(radialMenu, aboveSubview: self.view)
                radialMenu.setButtons(getRadialButtons(), quadrant:quadrant)
            }
        }
        if recognizer.state == .Ended {
            radialMenu!.animateOut(nil)
        }
    }

    func handleSwipe(recognizer: UIPanGestureRecognizer) {
        if let radialMenu = radialMenu {
            radialMenu.handleMenuSwipe(recognizer)
        }
    }

    func gestureRecognizer(gestureRecognizer:UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    //MARK: - RadialMenuDelegate
    
    func onSelected(menuItem: RadialButton) {
        var outgoingView:UIView?
        switch lastButtonPressed {
        case .home:
            outgoingView = formHome
        case .one:
            outgoingView = formOne
        case .two:
            outgoingView = formTwo
        case .three:
            outgoingView = formThree
        default:
            outgoingView = formHome
        }
        switch (menuItem) {
        case .home:
            animateForm(formHome, outgoingView:outgoingView!, direction:Direction.Down)
        case .one:
            animateForm(formOne, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.Up : Direction.Left)
        case .two:
            animateForm(formTwo, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.Up : lastButtonPressed == .three ? Direction.Left : Direction.Right)
        case .three:
            animateForm(formThree, outgoingView:outgoingView!, direction:lastButtonPressed == .home ? Direction.Up : Direction.Right)
        case .touch:
            break
        }
        lastButtonPressed = menuItem
   }
}

