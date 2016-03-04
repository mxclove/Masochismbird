//
//  ViewController.swift
//  紫诺小鸡
//
//  Created by 马超 on 15/8/9.
//  Copyright © 2015年 马超. All rights reserved.
//

import UIKit
var makeTheFirst = 1
class ViewController: UIViewController {
    var birdButton: UIButton!
    var birdY:Double = 200
    var godowntimer:NSTimer?
    var gouptimer:NSTimer?
    var automaticMoveTimer:NSTimer?
    var makeABarrierTimer:NSTimer?
    
    var maxscore = 0
    var downSpeed:Double = 0.00
    var directionflag = 0
    var failedflag = 1
    var viewSizeHeight:UInt32 = 100
    var viewSizewidth:UInt32 = 100
    var BarrierX : [CGFloat]!
    var barrierNum = 0
    var currentBarrier = 0
    var actualtimescoreText : UITextView!
    var failedimageview : UIImageView!
    var mainView : UIImageView!
    var picture = 1
    var changedefficultlevel = 1
    var barriermovespeed : CGFloat = 30.0
    
    var playertimer = 0.02
    var gap = 200
    var makeoneBarriertimer = 5.0
    
    override func viewDidLoad() {
        birdY = Double (view.center.y)
        super.viewDidLoad()
        let birdimage = UIImage(named: "bird")
        birdButton = UIButton(type: UIButtonType.Custom)
        birdButton.frame = CGRect(x: 200, y: birdY, width: 30, height: 25)
        
        
        birdButton.setBackgroundImage(birdimage, forState: UIControlState.Normal)
        view.addSubview(birdButton)
        
        makeTheFirst = 1
        failedflag = 1
        directionflag = 0  //下
        viewSizeHeight = UInt32 (view.frame.size.height)
        viewSizewidth = UInt32 (view.frame.size.width)
        BarrierX = [CGFloat]()
        
        readDataFromFile()
        main.image = UIImage(named: "\(picture)")
        view.addSubview(changpictures)
        let llX = view.frame.size.width / 2
        let llY = view.frame.size.height
        actualtimescoreText = UITextView(frame: CGRect(x: llX, y: llY-50, width: 120, height: 50))
        actualtimescoreText.backgroundColor = UIColor.greenColor()
        
        changedifficults()

    }
    
    @IBOutlet weak var changpictures: UIButton!
    
    @IBAction func changedefficultlevel(sender: AnyObject) {
        if changedefficultlevel == 5 {
            changedefficultlevel = 1
        }
        else {
            changedefficultlevel++
        }
        changedifficults()

    }
    
    @IBAction func changepictures
        (sender: AnyObject) {

        
        
        if picture == 5 {
            picture = 1
        }
        else {
            picture++
        }
        main.image = UIImage(named: "\(picture)")
        
        view.addSubview(changpictures)
    }
    @IBOutlet weak var main: UIImageView!
    @IBAction func touch(sender: UIButton) {
        directionflag = 0
        if failedflag == 0 {
            beginANewGame()

        }
        
    }
    @IBAction func touchUpButton(sender: UIButton) {
        directionflag = 1
        
        if makeTheFirst == 1 {
            godowntimer = NSTimer.scheduledTimerWithTimeInterval(playertimer, target: self, selector: "birdGoDown", userInfo: nil, repeats: true)
            
            gouptimer = NSTimer.scheduledTimerWithTimeInterval(playertimer, target: self, selector: "birdGoUp", userInfo: nil, repeats: true)
            automaticMoveTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "moveBarrier", userInfo: nil, repeats: true)
           
            makeABarrierTimer = NSTimer.scheduledTimerWithTimeInterval(makeoneBarriertimer, target: self, selector: "makeABarrier", userInfo: nil, repeats: true)
            
            makeTheFirst = 2
        }
        
    }
    
    func changedifficults() {
        switch changedefficultlevel {
        case 1:playertimer = 0.02
        gap = 200
        makeoneBarriertimer = 5
        barriermovespeed = 12
            
        case 2:playertimer = 0.02
        gap = 150
        makeoneBarriertimer = 4.5
        barriermovespeed = 15
            
        case 3:playertimer = 0.014
        gap = 150
        makeoneBarriertimer = 4
        barriermovespeed = 15
            
        case 4:playertimer = 0.011
        gap = 150
        makeoneBarriertimer = 3
        barriermovespeed = 18
            
        case 5:playertimer = 0.011
        gap = 150
        makeoneBarriertimer = 3
        barriermovespeed = 18
            
            
        default:playertimer = 0.02
        gap = 200
        makeoneBarriertimer = 5
            break
            
        }
        actualtimescoreText.text = "当前难度级别:\(changedefficultlevel)\r当前得分: \(currentBarrier)"
        view.addSubview(actualtimescoreText)
    }
    func birdGoDown() {
        downSpeed = downSpeed + 0.08
        checkFailedAndUpdateBirdPosition()
        
    }
    
    func birdGoUp() {
        if directionflag == 1 {
            downSpeed = downSpeed - 0.18
        }
        checkFailedAndUpdateBirdPosition()
    }
    
    func resetflag() {
        directionflag = 0
    }
    
    func checkFailedAndUpdateBirdPosition() {
        
        if birdY > 0 && birdY < Double (view.frame.size.height - birdButton.frame.size.height) {
            
            birdY += downSpeed
            birdButton.frame = CGRect(x: 200, y: birdY, width: 30, height: 25)
            view.addSubview(birdButton)
            
            for i in 0..<upbarrierArray.count {
                if upbarrierArray[i].frame.origin.x <= birdButton.frame.origin.x && upbarrierArray[i].frame.origin.x >= birdButton.frame.origin.x-60 {
                    if i >= currentBarrier {
                        currentBarrier = i+1
                        actualtimescoreText.text = "当前难度级别:\(changedefficultlevel) 当前得分: \(currentBarrier)"
                        view.addSubview(actualtimescoreText)
                    }
                    
                    if birdButton.frame.origin.y+birdButton.frame.size.height >= downbarrierArray[i].frame.origin.y || birdButton.frame.origin.y <= upbarrierArray[i].frame.size.height {
                        failedReport()
                        
                    }
                }
                
            }
            
            
            
        }
        else {
            failedReport()
            
        }
        
    }
    
    
    func failedReport() {
        godowntimer?.invalidate()
        gouptimer?.invalidate()
        makeABarrierTimer?.invalidate()
        automaticMoveTimer?.invalidate()
        failedflag = 0
        
        var forscoreReportText = ""
        
        if  currentBarrier > maxscore {
            maxscore = currentBarrier
            forscoreReportText = "产生新纪录了 \(maxscore)"
        }
        else {
            forscoreReportText = "本次得分： \(currentBarrier)"
        }
        let x = view.center.x - 200
        let y = view.center.y - 300
        failedimageview = UIImageView(frame: CGRect(x: x, y: y, width: 400, height: 600))
        failedimageview.image = UIImage(named: "failedreport")
        view.addSubview(failedimageview)
        
        let scoreTextX = failedimageview.frame.size.width / 2
        let scoreTextY = failedimageview.frame.size.height / 2
        let scoreReportText = UITextView(frame: CGRect(x: scoreTextX+30, y: scoreTextY - 6, width: 120, height: 36))
        scoreReportText.text = forscoreReportText
        scoreReportText.backgroundColor = UIColor.greenColor()
        failedimageview.addSubview(scoreReportText)
        print("\(scoreReportText.frame)")
        
        let maxscoreTextX = scoreTextX
        let maxscoreTextY = scoreTextY
        let maxscoreReportText = UITextView(frame: CGRect(x: maxscoreTextX+30, y: maxscoreTextY+60, width: 120, height: 36))
        maxscoreReportText.text = "最高纪录：\(maxscore)"
        maxscoreReportText.backgroundColor = UIColor.greenColor()
        failedimageview.addSubview(maxscoreReportText)
    }
    
    
    func beginANewGame() {
        
        for i in 0..<upbarrierArray.count {
            upbarrierArray[i].removeFromSuperview()
            downbarrierArray[i].removeFromSuperview()
        }
        
        failedimageview.removeFromSuperview()
        birdY = Double (view.center.y)
        downSpeed = 0
        birdButton.frame = CGRect(x: 200, y: birdY, width: 30, height: 25)
        view.addSubview(birdButton)
        makeTheFirst = 1
        upbarrierArray = [UIImageView]()
        downbarrierArray = [UIImageView]()
        BarrierX = [CGFloat]()
        number = 0
        failedflag = 1
        currentBarrier = 0
        actualtimescoreText.text = "当前得分：\(currentBarrier)"
    }

    var upbarrierArray = [UIImageView]()
    var downbarrierArray = [UIImageView]()
    var number = 0
    
    
    func makeABarrier() {
        
        let a: UInt32 = viewSizeHeight-UInt32(gap)
        let upBarrierImageHeight = Int(arc4random_uniform(a))
        let hhhh = UIImageView(frame: CGRect(x: Int(viewSizewidth), y: 0, width: 60, height: upBarrierImageHeight))
        upbarrierArray.append(hhhh)
        
        let atstart = CGFloat(viewSizewidth)
        BarrierX.append(atstart)
        
        let downBarrierImageHeight = Int(viewSizeHeight)-gap-upBarrierImageHeight
        let qqqq = UIImageView(frame: CGRect(x: Int(viewSizewidth), y: upBarrierImageHeight+gap, width: 60, height: downBarrierImageHeight))

        downbarrierArray.append(qqqq)
        
        let upinset = UIEdgeInsets(top: 0, left: 25, bottom:20, right: 25)
        let aaimage = UIImage(named: "shang")
        upbarrierArray[number].image = aaimage?.resizableImageWithCapInsets(upinset)
        
        let downinset = UIEdgeInsets(top: 20, left: 25, bottom:0, right: 25)
        let bbimage = UIImage(named: "xia")
        downbarrierArray[number].image = bbimage?.resizableImageWithCapInsets(downinset)
        
        view.addSubview(upbarrierArray[number])
        view.addSubview(downbarrierArray[number])
        
        number++

    }
    func moveBarrier() {
        for j in 0..<upbarrierArray.count {
            
            if BarrierX[j] <= -30 {
                upbarrierArray[j].removeFromSuperview()
                downbarrierArray[j].removeFromSuperview()
            }
            else {
                BarrierX[j] = BarrierX[j]-barriermovespeed
                for i in 0..<upbarrierArray.count {
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.upbarrierArray[i].frame.origin.x = self.BarrierX[i]
                        self.downbarrierArray[i].frame.origin.x = self.BarrierX[i]
                    })
            }
            
        }
        
        
        }

    }
    
    // MARK: 关于数据的保存
    //找到沙盒路径
    private func documentPath() ->String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return paths[0];
        
    }
    //获取data 文件应该存放的 plist文件路径
    private func myDataFilePath() -> String {
        return documentPath().stringByAppendingString("myApplicationData.plist")
    }
    //存数据
    func saveDataToFile() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(maxscore, forKey: "Maxscore")
        archiver.encodeObject(picture, forKey: "Picture")
        archiver.encodeObject(changedefficultlevel, forKey: "Changedefficultlevel")
        archiver.finishEncoding()
        data.writeToFile(myDataFilePath(), atomically: true)
    }
    //读数据
    func readDataFromFile() {
        if NSFileManager.defaultManager().fileExistsAtPath(myDataFilePath()) {
            if let data = NSData(contentsOfFile: myDataFilePath()) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                maxscore = unarchiver.decodeObjectForKey("Maxscore") as! Int
                picture = unarchiver.decodeObjectForKey("Picture") as! Int
                changedefficultlevel = unarchiver.decodeObjectForKey("Changedefficultlevel") as! Int
                unarchiver.finishDecoding()
                
            }
        }
        
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        
    }
    


}

