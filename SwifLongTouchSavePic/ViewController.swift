//
//  ViewController.swift
//  SwifLongTouchSavePic
//
//  Created by YuanFang on 15/12/13.
//  Copyright © 2015年 vfarv. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate,UIActionSheetDelegate {

    //脚本触摸事件
    static var touchJSStr:String = "document.ontouchstart=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:start:\"+x+\":\"+y;};document.ontouchmove=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:move:\"+x+\":\"+y;};document.ontouchcancel=function(event){document.location=\"myweb:touch:cancel\";};document.ontouchend=function(event){document.location=\"myweb:touch:end\";};"
    
    static var imgUrl:String = ""//存储当前点击的图片路径
    var touchState:TouchState = TouchState.None//设置默认的点击状态为NONE
    var timer:NSTimer? = nil//定时器 长按时 定时器启动 执行一次 弹出保存确认
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://image.baidu.com")!))
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        let requestStr:String = request.URL!.absoluteString
        
        let components = requestStr.componentsSeparatedByString(":")
        if(components.count>1 && components[0] == "myweb"){
            if(components[1] == "touch"){
                if(components[2] == "start"){
                    
                    touchState = TouchState.Start
                    let ptX:Float32 = (components[3] as NSString).floatValue
                    let ptY:Float32 = (components[4] as NSString).floatValue
                    let js:String = "document.elementFromPoint(\(ptX), \(ptY)).tagName"
                    let tagName:String? = webView.stringByEvaluatingJavaScriptFromString(js)
                    if(tagName!.uppercaseString == "IMG")
                    {
                        let srcJS:String = "document.elementFromPoint(\(ptX), \(ptY)).src"
                        ViewController.imgUrl = srcJS
                        if(ViewController.imgUrl != ""){
                            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "handleLongTouch", userInfo: nil, repeats: false)
                        }
                    }
                }else if(components[2] == "move"){
                    touchState = TouchState.Move
                    if(timer != nil)
                    {
                        timer!.fire()
                    }
                }
                else if(components[2] == "cancel"){
                    touchState = TouchState.Cancel
                    if(timer != nil)
                    {
                        timer!.fire()
                    }
                }
                else if(components[2] == "end"){
                    touchState = TouchState.End
                    if(timer != nil)
                    {
                        timer!.fire()
                    }
                }
            }
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        webView.stringByEvaluatingJavaScriptFromString(ViewController.touchJSStr)//触摸js注册
    }
    //弹出保存对话框
    func handleLongTouch(){
        if(ViewController.imgUrl != "" && touchState == TouchState.Start){
            var sheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "保存图片")
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1
            sheet.showInView(UIApplication.sharedApplication().keyWindow!)
        }
    }
    //按钮点击保存 保存图片 需要实现 UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 1){
            let urlToSave:String? = self.webView.stringByEvaluatingJavaScriptFromString(ViewController.imgUrl)
            let data:NSData? = NSData(contentsOfURL: NSURL(string: urlToSave!)!)
            var image:UIImage? = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            return
        }
    }
    

}

