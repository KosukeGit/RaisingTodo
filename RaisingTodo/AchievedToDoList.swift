//
//  AchievedToDoList.swift
//  RaisingTodo
//
//  Created by x13089xx on 2016/07/16.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

class AchievedToDoList: UIViewController {
    
    @IBOutlet var level: UILabel!
    @IBOutlet var todoTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--------------------
        // 読み込み処理を追加
        //--------------------
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let storedTodoList = userDefaults.objectForKey("achievementList") as? [String] {
            var content: String = ""
            // 達成したToDoを逆順にcontentに追加
            for index in (0..<storedTodoList.count).reverse() {
                content += storedTodoList[index] + "\n\n"
            }
            // 達成したToDoをUITextViewに表示
            todoTextView.text = content
            
            // 達成したToDo分の数を文字列変換してレベルを表示
            level.text! = String(storedTodoList.count)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * キーボードが出ている状態で、Viewをタップした時の処理
     */
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    
}
