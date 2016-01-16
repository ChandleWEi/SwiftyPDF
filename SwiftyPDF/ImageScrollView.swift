//
//  ImageScrollView.swift
//  SwiftyPDF
//
//  Created by prcela on 16/01/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView
{
    var zoomImageView: UIImageView?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func displayTiledImage(image: UIImage, imageContentSize: CGSize)
    {
        // reset our zoomScale to 1.0 before doing any further calculations
        self.zoomScale = 1.0;
        
        // make views to display the new image
        zoomImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: imageContentSize))
        zoomImageView!.image = image
        addSubview(zoomImageView!)
        
//        _tilingView = [[TilingView alloc] initWithImageName:imageName size:imageSize];
//        _tilingView.frame = _zoomView.bounds;
//        [_zoomView addSubview:_tilingView];
//        

        
        configureForImageSize(imageContentSize)
    }
    
    func configureForImageSize(imageContentSize: CGSize)
    {
        print("full image size: ")
        contentSize = imageContentSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
    }
    
    func setMaxMinZoomScalesForCurrentBounds()
    {
        let boundsSize = bounds.size
        
        // calculate min/max zoomscale
        let xScale = boundsSize.width  / contentSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / contentSize.height   // the scale needed to perfectly fit the image height-wise
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        let imagePortrait = contentSize.height > contentSize.width
        let phonePortrait = boundsSize.height > boundsSize.width
        var minScale = imagePortrait == phonePortrait ? xScale : min(xScale, yScale)
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        let maxScale = 1.0 / UIScreen.mainScreen().scale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if (minScale > maxScale) {
            minScale = maxScale;
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale

    }

}
