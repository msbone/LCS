process.stdin.resume();
process.stdin.setEncoding('utf8');
var util = require('util');

var io = require('socket.io').listen(3000);
events = require('events'),
    serverEmitter = new events.EventEmitter();

io.sockets.on('connection', function (socket) {
    console.log('a user connected');
    serverEmitter.on('event', function (data) {
        socket.emit("event",data);
        //console.log('sent data: '+data);
    });
    socket.on('disconnect', function(){
        //console.log('user disconnected'+socket.id);
    });
});

process.stdin.on('data', function (text) {
    console.log('Reviced from console :', util.inspect(text));
    serverEmitter.emit('event', util.inspect(text));
});
