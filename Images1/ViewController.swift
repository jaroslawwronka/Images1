//
//  ViewController.swift
//  Images1
//
//  Created by Boss on 07/01/2024.
//

import UIKit

class ViewController: UIViewController {
    
    var gallery = [#imageLiteral(resourceName: "image4.png"),#imageLiteral(resourceName: "image3.png"),#imageLiteral(resourceName: "image5.png"),#imageLiteral(resourceName: "image2.png"),#imageLiteral(resourceName: "image1.png")]

    @IBOutlet weak var TrashImage: UIImageView!
    
    var NextIndex = 0
    var CurrentPicture : UIImageView?
    let OrginalSize : CGFloat = 300
    var IsActive = false
    var ActiveSize : CGFloat {
        return OrginalSize + 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ShowNextPicture()
    }
    
    func DeletePicture(ImageView : UIImageView) {
        self.gallery.remove(at: NextIndex - 1)
        IsActive = false
        UIView.animate(withDuration: 0.4) {
            ImageView.alpha = 0
        } completion: { (_) in
            ImageView.removeFromSuperview()
        }
        ShowNextPicture()
    }
    
    func ActivateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.CurrentPicture?.frame.size = CGSize(width: self.ActiveSize, height: self.ActiveSize)
            self.CurrentPicture?.layer.shadowOpacity = 0.5
            self.CurrentPicture?.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    func DeactivateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.CurrentPicture?.frame.size = CGSize(width: self.OrginalSize, height: self.OrginalSize)
            self.CurrentPicture?.layer.shadowOpacity = 0
            self.CurrentPicture?.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    func ShowNextPicture() {
        if let NewPicture = CreatePicture() {
            CurrentPicture = NewPicture
            ShowPicture(NewPicture)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.HandleTap))
            NewPicture.addGestureRecognizer(tap)
            let Swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.HandleSwipe(_:)))
            Swipe.direction = .up
            NewPicture.addGestureRecognizer(Swipe)
            
            let Pan = UIPanGestureRecognizer(target : self, action: #selector(self.HandlePan(_:)) )
            
            Pan.delegate = self
            NewPicture.addGestureRecognizer(Pan)
        } else {
            NextIndex = 0
            ShowNextPicture()
        }
    }
    
    @objc func HandlePan(_ sender: UIPanGestureRecognizer) {
        guard let View = CurrentPicture, IsActive else { return }
        switch sender.state {
        case .began, .changed:
            ProcessPictureMovement(sender: sender, View: View)
        case .ended:
            if View.frame.intersects(TrashImage.frame) {
                DeletePicture(ImageView: View)
            }
            
        default:
            break
        }
        
    }
    
    @objc func HandleSwipe(_ sender : UIGestureRecognizer){
        guard !IsActive else {return }
        HidePicture(CurrentPicture!)
        ShowNextPicture()
    }
    
    @objc func HandleTap() {
        IsActive = !IsActive
        if IsActive {
            ActivateCurrentPicture()
        } else {
            DeactivateCurrentPicture()
        }
    }
    
    func ProcessPictureMovement(sender: UIPanGestureRecognizer, View:UIView) {
        let Translation = sender.translation(in: View)
        View.center = CGPoint(x: View.center.x + Translation.x, y: View.center.y + Translation.y)
        sender.setTranslation(.zero, in: View)
        
        if View.frame.intersects(TrashImage.frame) {
            View.layer.borderColor = UIColor.red.cgColor
        } else {
            View.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    func CreatePicture() -> UIImageView? {
        guard NextIndex < gallery.count else { return nil }
        let ImageView = UIImageView(image:gallery[NextIndex])
        ImageView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (OrginalSize / 2), width: OrginalSize, height: OrginalSize)
        ImageView.isUserInteractionEnabled = true
        
        //Shadow
        ImageView.layer.shadowColor = UIColor.black.cgColor
        ImageView.layer.shadowOpacity = 0
        ImageView.layer.shadowOffset = .zero
        ImageView.layer.shadowRadius = 10
        //Frame
        ImageView.layer.borderWidth = 2
        ImageView.layer.borderColor = UIColor.darkGray.cgColor
        
        NextIndex += 1
        return ImageView
    }
    func ShowPicture(_ ImageView:UIImageView){
        self.view.addSubview(ImageView)
        UIView.animate(withDuration: 0.4) {
            ImageView.center = self.view.center
        }
    }
    func HidePicture (_ ImageView:UIImageView) {
        UIView.animate(withDuration: 0.4, animations: {
            self.CurrentPicture?.frame.origin.y = -self.OrginalSize
        }) { (_) in
            ImageView.removeFromSuperview()
        }
    }
}

extension ViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
