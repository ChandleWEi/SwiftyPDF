//
//  ViewController.swift
//  SwiftyPDF
//
//  Created by prcela on 12/01/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit


class PdfViewController: UIViewController {
    
    var url: NSURL?
    var pageController: UIPageViewController!
    var currentPageIdx: Int?
    private var barsHidden = true
    private var pendingPageIdx: Int?
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbsContainerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPageTilesSaved:", name: pageTilesSavedNotification, object: nil)
        
    }
    
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let statusBarHeight = Config.prefersStatusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height
        
        navBarTopConstraint.constant = barsHidden ? -navBar.frame.size.height-statusBarHeight:0
        thumbsBottomConstraint.constant = barsHidden ? -thumbsContainerView.frame.size.height:0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "embed"
        {
            
            pageController = segue.destinationViewController as! UIPageViewController
            
            pageController.dataSource = self
            pageController.delegate = self
            
            if PdfDocument.open(url: url!) != nil
            {
                if let pageDesc = PdfDocument.pagesDesc.first
                {
                    let singlePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! SinglePageViewController
                    singlePageVC.pageIdx = pageDesc.idx
                    
                    currentPageIdx = singlePageVC.pageIdx
                    
                    pageController.setViewControllers([singlePageVC], direction: .Forward, animated: false, completion: nil)
                }
            }
        }
    }
    
    func onPageTilesSaved(notification: NSNotification)
    {
        let pageIdx = notification.object as! Int
        print("Tiles saved for page: \(pageIdx)")
        
        for vc in pageController.viewControllers!
        {
            let singlePageVC = vc as! SinglePageViewController
            if singlePageVC.pageIdx == pageIdx
            {
                singlePageVC.imageScrollView?.tilingView?.setNeedsDisplay()
            }
        }        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return Config.prefersStatusBarHidden
    }
    
    @IBAction func tap(sender: AnyObject)
    {
        barsHidden = !barsHidden
        
        let statusBarHeight = Config.prefersStatusBarHidden ? 0 : UIApplication.sharedApplication().statusBarFrame.size.height
        
        navBarTopConstraint.constant = barsHidden ? -navBar.frame.size.height-statusBarHeight:0
        thumbsBottomConstraint.constant = barsHidden ? -thumbsContainerView.frame.height:0
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func done(sender: AnyObject)
    {
        dismissViewControllerAnimated(true) {
            PdfDocument.close()
        }
    }
}

extension PdfViewController: UIPageViewControllerDataSource
{
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let singlePageVC = viewController as! SinglePageViewController
        if let idx = singlePageVC.pageIdx where idx < PdfDocument.pagesDesc.count-1
        {
            let nextSinglePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! SinglePageViewController
            nextSinglePageVC.pageIdx = idx+1
            return nextSinglePageVC
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let singlePageVC = viewController as! SinglePageViewController
        if let idx = singlePageVC.pageIdx where idx > 1
        {
            let prevSinglePageVC = storyboard!.instantiateViewControllerWithIdentifier("pdfPage") as! SinglePageViewController
            prevSinglePageVC.pageIdx = idx-1
            return prevSinglePageVC
        }
        return nil
    }
}

extension PdfViewController: UIPageViewControllerDelegate
{
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
    {
        if let vc = pendingViewControllers.last
        {
            pendingPageIdx = (vc as! SinglePageViewController).pageIdx
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if completed
        {
            for previousVC in previousViewControllers
            {
                if let singlePageVC = previousVC as? SinglePageViewController
                {
                    singlePageVC.removeTilingView()
                    
                    if let imageScrollView = singlePageVC.imageScrollView
                    {
                        imageScrollView.zoomScale = imageScrollView.minimumZoomScale
                    }

                }
            }
            
            currentPageIdx = pendingPageIdx
        }
    }
}
