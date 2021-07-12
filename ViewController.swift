//
//  ViewController.swift
//  MyChatRoom
//
//  Created by ESD 29 on 2016/11/22.
//
//

import UIKit

class ViewController: UIViewController {
    var i :Int = 0
    var id : String = "0"
    let hostString: String = "http://localhost:3000"
    var socket : SocketIOClient? = nil
    var name : String = ""
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var indexTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var memberTextView: UITextView!
    @IBOutlet weak var chatContentTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //創造連線 的URL物件
        let hostUrl = NSURL(string: self.hostString)
        //創造SocketIOClient函數,同時設定socket將連線到的URL 
        self.socket = SocketIOClient(socketURL: hostUrl!)
        //把anyEventCallBack這個function設定成socket中所有event的handler,告訴socket接到所有的 event時都要call anyEventCallBack這個函數
        self.socket!.onAny(anyEventCallBack)
        //把connectCallBack這個functio 設定成socket中 "connect" event的handler,告訴socket接到
        //"connect" event時要call connectCallBack這個函數
        self.socket!.on("connect",callback: connectCallBack)
        //把serverMsgCallBack這個function設定成 "chat message from server" event的handler,告 訴socket接到 "chat message from server" event時要call gCallBack這個函數
        self.socket!.on("chat message from server", callback: serverMsgCallBack)
        print("--- connecting to \(self.hostString) —")
        self.socket!.on("memberListClear",callback: addmemberCallBack)
        //叫socket連線到前 已指定的Server 
        //self.socket!.connect()
        self.socket!.on("memberListRenew",callback: renewListCallBack)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendButtonPressed(sender: AnyObject) {
        let message = self.messageTextField.text!
        let index = self.indexTextField.text!
        if (index == ""){
            self.socket!.emit( "chat message from client" , message )
        }
        else{
            self.socket!.emit( "chat message to private" , index+","+message )
            print(index+","+message)
        }
      //  self.i = self.i + 1
      //  let newChatContent = "me:\(message)\n\(self.chatContentTextView.text)"
      //  self.chatContentTextView.text = newChatContent
        self.messageTextField.text = ""
    }
    func anyEventCallBack( anyEvent: SocketAnyEvent)
    {
        // 印出所有收到的event跟event附帶的data,debug時可
        //print("--- Got event: \(anyEvent.event), with items: \(anyEvent.items) ---")
    }
    @IBAction func connectPressed(sender: UIButton) {
        self.socket!.connect()
    }

    @IBAction func disconnectPressed(sender: UIButton) {
        self.socket!.disconnect()
        let newChatContent = ""
        self.memberTextView.text = newChatContent
    }
    func connectCallBack( data:[AnyObject], ack:SocketAckEmitter)
    {
        print("--- socket connected ---")
        //  socket傳送 event + message 給server
        name = self.nameTextField.text!
        self.socket!.emit("addmember", name)
        self.socket!.emit("chat message from client", "Hello! I've connected!")
        
    }
    func serverMsgCallBack( data:[AnyObject], ack:SocketAckEmitter)
    {
        print("--- receive \"chat message from server\" event ---")
        //找出message string
        let message: String = (data[0] as! String)
        let newChatContent = "\(message)\n\(self.chatContentTextView.text)"
        self.chatContentTextView.text = newChatContent
        print("received:\n\n" + "\(message)" + "\n")
    }
    func addmemberCallBack(data:[AnyObject], ack:SocketAckEmitter)
    {
        let newChatContent = ""
        self.memberTextView.text = newChatContent
		
    }
    func renewListCallBack(data:[AnyObject], ack:SocketAckEmitter)
    {
        print("--- receive \"chat message from server\" event ---")
        //找出message string
        let message: String = (data[0] as! String)
        var newChatContent : String
        if (name == message){
            newChatContent = ">>\(message)\n\(self.memberTextView.text)"
        }
        else{
            newChatContent = "\(message)\n\(self.memberTextView.text)"
        }
        self.memberTextView.text = newChatContent
        print("received:\n\n" + "\(message)" + "\n")
    }
}

