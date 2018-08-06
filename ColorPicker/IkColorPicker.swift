//
//  IkColorPicker.swift
//  ColorPicker
//
//  Created by Sebastian Cancinos on 8/10/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import Foundation
import UIKit

protocol ColorPickerDelegate {
    func colorSelectedChanged(_ color: UIColor);
}

class IKColorPicker: UIView
{
    fileprivate var viewPickerHeight = 0;
    fileprivate let brightnessPickerHeight = 30;
    
    fileprivate var hueColorsImageView: UIImageView!, brightnessColorsImageView: UIImageView!, fullColorImageView: UIImageView!;
    
    var delegate: ColorPickerDelegate?;
    
    func colorFor( _ x: CGFloat, y: CGFloat) -> UIColor
    {
        let screenSize: CGRect = UIScreen.main.bounds
        
        return UIColor(hue: (x/screenSize.width), saturation: y/CGFloat(viewPickerHeight), brightness:1, alpha: 1);
    }
    
    func colorWithColor(_ baseColor: UIColor, brightness: CGFloat) -> UIColor
    {
        var hue: CGFloat = 0.0;
        var saturation: CGFloat = 0.0;
        
        baseColor.getHue(&hue, saturation: &saturation, brightness: nil, alpha:nil);
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1);
    }
    
    func createHueColorImage() -> UIImage
    {
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageHeight = CGFloat(viewPickerHeight - brightnessPickerHeight);
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContext(size);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
                             height:ceil(imageWidth/256));
        
        for y in stride(from: 0.0, through: imageHeight, by: imageHeight/256)
        {
            for x in stride(from: 0.0, through: imageWidth, by: imageWidth/256)
            {
                let rec = CGRect(x: x, y: y, width: recSize.width , height: recSize.height);
                let color = self.colorFor(x, y: y);
                
                context.setFillColor(color.cgColor);
                context.fill(rec);
            }
        }
        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage!;
    }
    
    func createBrightnessImage(_ baseColor:UIColor) -> UIImage
    {
        let imageHeight = CGFloat(brightnessPickerHeight);
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
                             height:imageHeight);
        
        var hue:CGFloat = 0.0;
        var saturation:CGFloat = 0.0;
        baseColor.getHue(&hue, saturation:&saturation, brightness:nil, alpha:nil);
        
        for x in stride(from: 0.0, through: imageWidth, by: imageWidth/256)
        {
            let rec = CGRect(x: x, y: 0, width: recSize.width , height: recSize.height);
            let color = UIColor(hue: hue, saturation: saturation, brightness: (imageWidth-x)/imageWidth, alpha: 1);
            
            context.setFillColor(color.cgColor);
            context.fill(rec);
        }
        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage!;
    }
    
    func createFullColorImage(_ color :UIColor, size: CGSize, radius: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let rec = CGRect(x: 0, y: 0, width: size.width , height: size.height);
        
        context.setFillColor(color.cgColor);
        let roundedRect = UIBezierPath(roundedRect: rec, cornerRadius: radius);
        roundedRect.fill(with: .normal, alpha: 1);
        
        let fullColorImage =  UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return fullColorImage!;
    }
    
    func loadView()
    {
        let screenSize: CGRect = UIScreen.main.bounds
        viewPickerHeight = Int(ceil( screenSize.width / 1.10344));
        
        self.frame = CGRect(x:0,y:0,width:Int(screenSize.width),height:viewPickerHeight);
        
        
        let hueColorImage = self.createHueColorImage();
        self.hueColorsImageView = UIImageView(image: hueColorImage);
        self.addSubview(self.hueColorsImageView);
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(IKColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(panRecognizer);
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(IKColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(tapRecognizer);
        self.hueColorsImageView.isUserInteractionEnabled = true;
        
        
        //------
        let brightnessColorImage = self.createBrightnessImage(self.selectedBaseColor);
        self.brightnessColorsImageView = UIImageView(image: brightnessColorImage);
        self.addSubview(self.brightnessColorsImageView);
        
        var brImgRect = self.brightnessColorsImageView.frame;
        brImgRect.origin.y = self.hueColorsImageView.frame.origin.y + self.hueColorsImageView.frame.size.height;
        self.brightnessColorsImageView.frame = brImgRect;
        self.brightnessColorsImageView.isUserInteractionEnabled = true;
        
        let brightSlideGesture = UIPanGestureRecognizer(target: self, action:#selector(IKColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightSlideGesture);
        
        let brightTapGesture = UITapGestureRecognizer(target: self, action: #selector(IKColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightTapGesture);
        self.brightnessColorsImageView.isUserInteractionEnabled = true;
    }
    
    internal var selectedColor: UIColor
    {
        didSet{
            if((self.fullColorImageView) != nil)
            {
                let fullColorImage = self.createFullColorImage(selectedColor, size: CGSize(width: 40, height: 40),radius: CGFloat(6));
                fullColorImageView.image = fullColorImage;
            }
            
            self.delegate?.colorSelectedChanged(self.selectedColor);
        }
    }
    
    var selectedBrightness: CGFloat
    {
        get
        {
            var brightness: CGFloat=0;
            self.selectedColor.getHue(nil, saturation: nil, brightness:&brightness, alpha:nil);
            
            return brightness;
        }
        
    }
    
    func setSelectedBrightness(_ brightness: CGFloat)
    {
        self.selectedColor = self.colorWithColor(self.selectedBaseColor, brightness:brightness);
        
    }
    
    var selectedBaseColor: UIColor
    {
        didSet{
            let brightnessColorImage = self.createBrightnessImage(self.selectedBaseColor);
            self.brightnessColorsImageView.image = brightnessColorImage;
        }
    }
    
    func setColor(_ color: UIColor)
    {
        selectedBaseColor = color;
        selectedColor = color;
    }
    
    @objc func baseColorPicking(_ sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches==1)
        {
            let picked = sender.location(ofTouch: 0, in: sender.view);
            
            self.selectedBaseColor = self.colorFor(picked.x, y:picked.y);
            self.selectedColor = self.colorWithColor(self.selectedBaseColor, brightness:self.selectedBrightness);
        }
    }
    
    @objc func colorPicking(_ sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches==1)
        {
            let picked = sender.location(ofTouch: 0, in:sender.view);
            self.setSelectedBrightness((sender.view!.frame.width-picked.x)/sender.view!.frame.width);
        }
    }
    
    init(frame:CGRect, color: UIColor)
    {
        selectedColor = color;
        selectedBaseColor = color;
        
        super.init(frame: frame);
        self.loadView();
    }
    
    required init(coder aDecoder: NSCoder) {
        selectedColor = UIColor.white;
        selectedBaseColor = UIColor.white;
        
        super.init(coder: aDecoder)!;
        self.loadView();
    }
    
}
