var portNumber = 3000;
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var socketArray = [];
var memberArray = [];

//設定從網頁連進Server時，回傳index.html給瀏覽器 (瀏覽器端為Client，index.html裡面有client的code)
app.get('/',
        function(req, res)
        {
            res.sendFile(__dirname + '/index.html');
        });

//設定 Server 監聽 3000 這個 port
http.listen(portNumber,
            function()
            {
                console.log('listening on *:' + portNumber);
            });


//可將 io 視為 Server 上管理所有 Socket 的 Manager
io.on('connection',
      function(socket) /*[1]*/
      {
      //將新創造的 Socket加到 socketArray 裡
        socketArray[socketArray.length] = socket;
      //在 server 的 console 中輸出現有的 socket 數
        console.log('socket count: '+socketArray.length);
        socket.on('addmember', /*[2]*/
               function(msg)
               {
                  memberArray[memberArray.length] = msg;
                  console.log(msg + " has join");
                  var socketIndex;
                  for(var i=0 ; i<socketArray.length ; i++)
                  {
                  if(socketArray[i] == socket)
                    socketIndex = i;
                  }
                  io.emit('memberListClear', '');
                  for(var i=memberArray.length-1 ; i>=0 ; i--)
                  {
                        io.emit('memberListRenew', memberArray[i]);
                  }
               });
        socket.on('chat message from client', /*[2]*/
                  function(msg)
                  {
                  
                    //only send message back to the client of this socket ( with event string 'chat message from server' )
                    socket.emit('chat message from server', 'me:'+ msg);
                  
                    //broadcast to everyone include the client of this socket ( with event string 'chat message from server' )
                  
                    //broadcast to everyone except for the client of this socket ( with event string 'chat message form other client' )
                    var socketIndex;
                    for(var i=0 ; i<socketArray.length ; i++)
                    {
                        if(socketArray[i] == socket)
                        socketIndex = i;
                    }
                    socket.broadcast.emit('chat message from server',  memberArray[socketIndex]+":"+ msg);

                  });
      socket.on('chat message to private', /*[2]*/
                function(msg)
                {
                var splitArray = msg.split(",");
                var socketIndex;
                for(var i=0 ; i<socketArray.length ; i++)
                {
                    if(socketArray[i] == socket)
                    socketIndex = i;
                }
                var index = parseInt( splitArray[0] ,10);
                socket.emit('chat message from server', '(private to)'+ memberArray[index-1] +':'+ splitArray[1] );
                socketArray[index-1].emit('chat message from server', '(private)'+ memberArray[socketIndex]+":"+splitArray[1] );
                });

        socket.on('disconnect',
                  function()
                  {
                  //尋找要斷線的 socket 在 socketArray 中的 index var socketIndex;
                    var socketIndex;
                    for(var i=0 ; i<socketArray.length ; i++)
                    {
                        if(socketArray[i] == socket)
                        socketIndex = i;
                    }
               //從 socketArray 中把斷線的 socket 移除
                  io.emit('memberListClear', '');
                    socketArray.splice(socketIndex, 1);
					
                    memberArray.splice(socketIndex, 1);
                  for(var i=memberArray.length-1 ; i>=0 ; i--)
                  {
                    io.emit('memberListRenew', memberArray[i]);
                  }
               //在 server 的 console 中輸出現有的 socket 數
                  console.log('socket count: '+socketArray.length);
                  });
        });

/*
[1] when a new clinet connect to server, server will deploy a new socket to handle the connection to this client and call this function with the new created socket as parameter.

[2] tells socket to handle 'chat message from clinet' event. when socket get 'chat message frome clinet' event, server will call following function and the event message as the parameter
 
*/
