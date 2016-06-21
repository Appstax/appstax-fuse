var Observable = require("FuseJS/Observable");
var appstax = require("appstax");
appstax.init("NkxXMTRibGhEWHBLcg==");

var messages = Observable();

var channel = appstax.channel("public/chat");

channel.on("message", function(event) {
	messages.add(event.message);
});

function sendMessage() {
	var message = "Hello Fuse! " + Date().toString();
	channel.send(message);
	messages.add(message);
}

module.exports = {
    messages: messages,
    sendMessage: sendMessage
};