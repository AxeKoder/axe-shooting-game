//
//  GameViewController.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2023/10/18.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width))
        adBannerView.frame.origin = CGPoint(x: 0, y: view.frame.size.height - adBannerView.frame.height)
        adBannerView.frame.size = CGSize(width: view.frame.width, height: adBannerView.frame.height)
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        return adBannerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uuidString = UIDevice.current.identifierForVendor?.uuidString
        if let uuidString {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [uuidString]
        }
        let adMobRequest = GADRequest()
        adBannerView.load(adMobRequest)
        
        if let view = self.view as! SKView? {
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.addSubview(adBannerView)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Fail to receive ads")
        print(error)
    }
}
