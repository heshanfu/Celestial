import UIKit

extension VC{
    /**
     * Normal tap
     */
    @objc func handleTap(sender : UITapGestureRecognizer) {
        Swift.print("handleTap")
        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed  {
            onTapRelease()
        }//tap release
    }
//    @objc func onTap(_ sender:UITapGestureRecognizer){
//        Swift.print("someAction")
//        Swift.print("rect.constraints.count:  \(self.curView.constraints.count)")
//        let anim = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: {
//            // Set the new constraints
//            _ = self.to?()
//            // Apply the new constraints on the view
//            self.view.layoutIfNeeded()
//        })
//        anim.startAnimation()
//    }
    /**
     * When user drags a tap across the screen
     */
    @objc func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        Swift.print("translation:  \(translation)")
        //        let locInView = recognizer.location(in: self.view)
        //        Swift.print("locInView:  \(locInView)")
        //        let posConstraints = NSLayoutConstraint.ofKind(, kinds: [.left])
        //        Swift.print("posConstraints.count:  \(posConstraints.count)")
        guard let posConstraint = curView.anchor else {fatalError("err posConstraint not available")}
        let x = posConstraint.x.constant + translation.x
        NSLayoutConstraint.deactivate([posConstraint.x])
        let xConstraint = Constraint.anchor(curView, to: self.view, align: .left, alignTo: .left, offset: x)
        NSLayoutConstraint.activate([xConstraint/*,pos.y*/])
        curView.anchor?.x = xConstraint
        self.view.layoutIfNeeded()
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)//reset recognizer
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed  {
            onTapRelease()
        }//tap release
    }
    /**
     * When user release tap (regular tap, or drag tap)
     */
    private func onTapRelease(){
        Swift.print("onTapRelease()")
        let screenRect = UIScreen.main.bounds
        var leftBoundry:CGFloat {return screenRect.origin.x - screenRect.size.width/4 }
        var rightBoundry:CGFloat {return screenRect.size.width + screenRect.size.width / 4 }
        self.view.isUserInteractionEnabled = false//disable userinteractions
        //        Swift.print("curView.frame:  \(curView.frame)")
        //        Swift.print("curView.bounds:  \(curView.bounds)")
        if curView.frame.origin.x < leftBoundry {//more 25% to the left
            Swift.print("outside left boundry")
            let to:CGFloat = screenRect.origin.x - screenRect.width
            animate(to: to) {
                Swift.print("swap the views around 🎉")
                self.curIdx += 1
                self.leftView.removeFromSuperview()
                //
                self.leftView = self.curView
                if let pos = self.leftView.anchor, let size = self.leftView.size {
                    NSLayoutConstraint.deactivate([pos.x,pos.y,size.w,size.h])
                }
                self.curView = self.rightView
                if let pos = self.curView.anchor, let size = self.curView.size {
                    NSLayoutConstraint.deactivate([pos.x,pos.y,size.w,size.h])
                }
                self.setCenterConstraints(self.curView)
                self.setLeftConstraints(self.leftView)
                //
                let newRightIdx = IntParser.normalize(self.curIdx + 1, VC.citiesAndColors.count) //loopy index
                self.rightView = self.createRightView(idx: newRightIdx)
                let normalizedCurIdx = IntParser.normalize(self.curIdx, VC.citiesAndColors.count) //loopy index
                self.footer.updateWeather(idx: normalizedCurIdx)
                self.view.isUserInteractionEnabled = true//enable userinteractions
            }
        }else if ((curView.frame.origin.x + curView.frame.width) > rightBoundry ){//more than 25% to the right
            Swift.print("outside right boundry")
            let to:CGFloat = screenRect.origin.x + screenRect.width
            animate(to:to){
                Swift.print("swap the views around 👌")
                self.curIdx -= 1
                self.rightView.removeFromSuperview()
                //
                self.rightView = self.curView
                if let pos = self.rightView.anchor, let size = self.rightView.size {
                    NSLayoutConstraint.deactivate([pos.x,pos.y,size.w,size.h])
                }
                self.curView = self.leftView
                if let pos = self.curView.anchor, let size = self.curView.size {
                    NSLayoutConstraint.deactivate([pos.x,pos.y,size.w,size.h])
                }
                self.setCenterConstraints(self.curView)
                self.setRightConstraints(self.rightView)
                //
                let newLeftIdx = IntParser.normalize(self.curIdx - 1, VC.citiesAndColors.count) //loopy index
                self.leftView = self.createLeftView(idx: newLeftIdx)
                let normalizedCurIdx = IntParser.normalize(self.curIdx, VC.citiesAndColors.count) //loopy index
                self.footer.updateWeather(idx: normalizedCurIdx)
                self.view.isUserInteractionEnabled = true//enable userinteractions
            }
        }else {//released within boundries
            Swift.print("within boundries")
            let to:CGFloat = screenRect.origin.x
            animate(to:to){
                Swift.print("swap the views around ✅")
                self.view.isUserInteractionEnabled = true//enable userinteractions
            }
        }
        self.view.layoutIfNeeded()
    }
}