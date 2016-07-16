//
//  ViewController.swift
//  RaisingTodo
//
//  Created by x13089xx on 2016/07/14.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

// UITableViewDataSource, UITableViewDelegate のプロトコルを実装する旨の宣言を行う
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let dateFormatter = NSDateFormatter()
    
    // Todoを格納した配列
    var todoList = [MyTodo]()
    // 達成したTodoを格納した配列
    var achievementTodoList = [String]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 時刻の表示設定を追加
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        //--------------------
        // 読み込み処理を追加
        //--------------------
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let todoListData = userDefaults.objectForKey("todoList") as? NSData {
            if let storeTodoList = NSKeyedUnarchiver.unarchiveObjectWithData(todoListData) as? [MyTodo] {
                todoList.appendContentsOf(storeTodoList)
            }
        }
        if let achievementTodoListData = userDefaults.objectForKey("achievementList") as? [String] {
            achievementTodoList.appendContentsOf(achievementTodoListData)
        }
        
        // 通知の許可を取得
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * ＋ボタンをタップした際に呼ばれる処理
     */
    @IBAction func tapAddButton(sender: AnyObject) {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "リストに追加",
            message: "ToDoを入力してください",
            preferredStyle: UIAlertControllerStyle.Alert)
        // テキストエリアを追加
        alertController.addTextFieldWithConfigurationHandler(nil)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // OKボタンが押されたときの処理
            if let textField = alertController.textFields?.first {
                // 前後の空白文字を削除する要素を追加
                textField.text = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                // 空白文字かどうかを確認する処理
                if textField.text != "" {
                    // ToDoの配列に入力した値を挿入。先頭に挿入する
                    let myTodo = MyTodo()
                    myTodo.todoTitle = textField.text
                    self.todoList.insert(myTodo, atIndex: 0)
                    
                    // テーブルに行が追加されたことをテーブルに通知
                    self.tableView.insertRowsAtIndexPaths(
                        [NSIndexPath(forRow: 0, inSection: 0)],
                        withRowAnimation: UITableViewRowAnimation.Right)
                    
                    //--------------------
                    // 保存処理を追加
                    //--------------------
                    // NSData型にシリアライズする
                    let data: NSData =  NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
                    
                    // NSUserDefaultsに保存
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(data, forKey: "todoList")
                    userDefaults.synchronize()
                    
                    // バッジの数字を更新
                    UIApplication.sharedApplication().applicationIconBadgeNumber = self.todoList.count
                }
            }
        }
        // OKボタンを追加
        alertController.addAction(okAction)
        
        // キャンセルボタンがタップされたときの処理
        let cancelAction = UIAlertAction(title: "キャンセル",
            style: UIAlertActionStyle.Cancel, handler: nil)
        // キャンセルボタンを追加
        alertController.addAction(cancelAction)
        
        // アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * テーブルの行数を返却する
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ToDoの配列の長さを返却する
        return todoList.count
    }
    
    /**
     * テーブルの行ごとのセルを返却する
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath)
        // 行番号に合ったToDoのタイトルを取得
        let todo = todoList[indexPath.row]
        // セルのラベルにToDoのタイトルをセット
        cell.textLabel!.text = todo.todoTitle
        if todo.todoDone {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    /**
     * セルをタップしたときの処理
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = todoList[indexPath.row]
        if todo.todoDone {
            // 完了済みの場合は未完に変更
            todo.todoDone = false
        } else {
            // 未完の場合は完了済みに変更
            todo.todoDone = true
        }
        // セルの状態を変更
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        // データ保存
        // NSData型にシリアライズする
        let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
        
        // NSUserDefaultsに保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
//    /**
//     * セルが編集可能かどうかの判定処理
//     */
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    /**
//     * セルが削除したときの処理
//     */
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
//         forRowAtIndexPath indexPath: NSIndexPath) {
//        // 削除処理かどうか
//        if editingStyle == .Delete {
//            let todo = todoList[indexPath.row]
//            if todo.todoDone {
//                // 完了済みの場合はToDoリストから削除。記録に保存する
//                //----------------------------------------
//                // 達成済みのToDoを消す前に保存する処理を追加
//                //----------------------------------------
//            }
//            todoList.removeAtIndex(indexPath.row)
//            // セルを削除
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            // データ保存
//            // NSData型にシリアライズする
//            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
//            
//            // NSUserDefaultsに保存
//            let userDefaults = NSUserDefaults.standardUserDefaults()
//            userDefaults.setObject(data, forKey: "todoList")
//            userDefaults.synchronize()
//            
//            // バッジの数字を更新
//            UIApplication.sharedApplication().applicationIconBadgeNumber = todoList.count
//        }
//    }
    
    /**
     * スワイプ時のボタンを拡張する処理
     */
    func tableView(tableView: UITableView,
         editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let todo = todoList[indexPath.row]
        if todo.todoDone {
            // 完了済みの場合はToDoリストから削除。記録に保存する
            // 達成ボタンを追加
            let myAchievementButton: UITableViewRowAction = UITableViewRowAction(style: .Normal,
                title: "Achievement") { (action, index) -> Void in
                // 達成ボタンが押されたときの処理
                tableView.editing = false
                // アラートダイアログ生成
                let alertController = UIAlertController(title: "確認",
                    message: "達成しましたか？",
                    preferredStyle: UIAlertControllerStyle.Alert)
                // Yesボタンを追加
                let yesAction = UIAlertAction(title: "はい",
                     style: UIAlertActionStyle.Default) {
                    (action: UIAlertAction) -> Void in
                        
                    //----------------------------------------
                    // 達成済みのToDoを消す前に保存する処理を追加
                    //----------------------------------------
                    let date = NSDate()
                    let currenTime = self.dateFormatter.stringFromDate(date)
                    // ToDoの配列に入力した値を挿入。先頭に挿入する
                    // 行番号に合ったToDoのタイトルを取得
                    let todo = self.todoList[indexPath.row]
                    let todoData: String = currenTime + "   " + todo.todoTitle!
                    // 達成したToDoを追加
                    self.achievementTodoList.append(todoData)
                    // NSUserDefaultsに保存
                    userDefaults.setObject(self.achievementTodoList, forKey: "achievementList")
                    userDefaults.synchronize()
                        
                    // Yesボタンが押されたときの処理
                    self.todoList.removeAtIndex(indexPath.row)
                    // セルを削除
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    // データ保存
                    // NSData型にシリアライズする
                    let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
                    
                    // NSUserDefaultsに保存
                    userDefaults.setObject(data, forKey: "todoList")
                    userDefaults.synchronize()
                        
                    // バッジの数字を更新
                    UIApplication.sharedApplication().applicationIconBadgeNumber = self.todoList.count
                }
                // Yesボタンを追加
                alertController.addAction(yesAction)
                
                // Noボタンがタップされたときの処理
                let noAction = UIAlertAction(title: "いいえ",
                                                 style: UIAlertActionStyle.Cancel, handler: nil)
                // Noボタンを追加
                alertController.addAction(noAction)
                
                // アラートダイアログを表示
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            // バックグラウンドの色を緑色に変更
            myAchievementButton.backgroundColor = UIColor.greenColor()
            
            return [myAchievementButton]
        }
        // 未完の場合はToDoリストから削除
        // 削除ボタンを追加
        let myDeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal,
            title: "Delete") { (action, index) -> Void in
            // 削除ボタンが押されたときの処理
            tableView.editing = false
                
            self.todoList.removeAtIndex(indexPath.row)
            // セルを削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // データ保存
            // NSData型にシリアライズする
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
            
            // NSUserDefaultsに保存
            userDefaults.setObject(data, forKey: "todoList")
            userDefaults.synchronize()
            
            // バッジの数字を更新
            UIApplication.sharedApplication().applicationIconBadgeNumber = self.todoList.count
        }
        // バックグラウンドの色を赤色に変更
        myDeleteButton.backgroundColor = UIColor.redColor()
        return [myDeleteButton]
    }
    
    
}


/**
 * ToDoのタイトルと完了状態を判定するフラグをプロパティとして持つ独自クラス
 */
// 独自クラスをシリアライズする際には、NSObjectを継承し、NSCodingプロトコルに準拠する必要がある
class MyTodo: NSObject, NSCoding {
    
    // ToDoのタイトル
    var todoTitle: String?
    
    // ToDoを完了したかどうかを表すフラグ
    var todoDone: Bool = false
    
    // コンストラクタ
    override init() {
        
    }
    
    // NSCodingプロトコルに宣言されているデシリアライズ処理。（デコード処理）
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObjectForKey("todoTitle") as? String
        todoDone = aDecoder.decodeBoolForKey("todoDone")
    }
    
    // NSCodingプロトコルに宣言されているシリアライズ処理。（エンコード処理）
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(todoTitle, forKey: "todoTitle")
        aCoder.encodeBool(todoDone, forKey: "todoDone")
    }
    
    
}





