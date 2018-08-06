//
//  ViewController.swift
//  ColorPicker
//
//  Created by Sebastian Cancinos on 7/15/15.
//  Copyright (c) 2015 Inaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ColorPickerDelegate {
    
    fileprivate var customInputView: UIView?;
    @IBOutlet var textInput: UITextView?;
    var colorPickerButton: UIButton?;
    
    fileprivate var colorPicker: IKColorPicker?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.colorPicker = IKColorPicker(frame: CGRect.zero, color: self.textInput!.textColor!);
        self.colorPicker!.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorSelectedChanged(_ color: UIColor) {
        self.textInput?.textColor = color;
        
        let colorImage = self.colorPicker!.createFullColorImage(self.textInput!.textColor!, size: CGSize(width: 40, height: 40),radius: CGFloat(6));
        self.colorPickerButton!.setImage(colorImage, for:UIControlState());
        
    }
    
    override var inputAccessoryView: UIView?
        {
        get{
            
            if (self.customInputView == nil)
            {
                let screenSize: CGRect = UIScreen.main.bounds
                
                // lazy creation
                let accessFrame = CGRect(x: 0, y: 0, width: screenSize.width, height: 50);
                self.customInputView = UIView(frame: accessFrame);
                
                // create a semi-transparent banner
                let iavBackgroundView = UIView(frame: accessFrame);
                iavBackgroundView.backgroundColor = UIColor.darkGray;
                iavBackgroundView.alpha = 0.5;
                self.customInputView!.addSubview(iavBackgroundView);
                
                // create a button for system keyboard
                let image = UIImage(named: "btn-keyboard");
                let kbButton: UIButton = UIButton(type: .custom);
                kbButton.frame = CGRect(x: 10, y: 5, width: 40, height: 40);
                kbButton.setImage(image, for: UIControlState());
                kbButton.addTarget(self, action:#selector(ViewController.kbButtonPressed(_:)), for: UIControlEvents.touchUpInside);
                self.customInputView!.addSubview(kbButton);
                
                // create a button for our font & size keyboard
                let colorImage = self.colorPicker!.createFullColorImage(self.textInput!.textColor!, size: CGSize(width: 40, height: 40),radius: CGFloat(6));
                let colorButton: UIButton = UIButton(type: .custom);
                colorButton.frame = CGRect(x: 60, y: 5, width: 40, height: 40);
                colorButton.setImage(colorImage, for:UIControlState.normal);
                colorButton.addTarget(self, action:#selector(ViewController.colorButtonPressed(_:)),
                                      for:UIControlEvents.touchUpInside);
                self.customInputView!.addSubview(colorButton);
                
                self.colorPickerButton = colorButton;
            }
            return customInputView;
        }
    }
    
    @objc func kbButtonPressed(_ sender: AnyObject)
    {
        self.textInput!.inputView = nil;
        self.textInput!.reloadInputViews();
    }
    
    @objc func colorButtonPressed(_ sender: AnyObject)
    {
        self.textInput!.inputView = self.colorPicker;
        self.colorPicker!.selectedColor = self.textInput!.textColor!;
        
        let colorImage = self.colorPicker!.createFullColorImage(self.textInput!.textColor!, size: CGSize(width: 40, height: 40),radius: CGFloat(6));
        self.colorPickerButton!.setImage(colorImage, for:UIControlState.normal);
        
        self.textInput!.reloadInputViews();
    }
}

