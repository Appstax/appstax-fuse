var Observable = require("FuseJS/Observable");
var appstax = require("appstax");
appstax.init("NkxXMTRibGhEWHBLcg==");

var messages = Observable();

loadMessages();

function loadMessages() {
    appstax.findAll("messages").then(function(objects) {
        messages.replaceAll(objects);
    });
}

function addMessage() {
    var message = appstax.object("messages");
    message.text = "Hello Fuse! " + Date().toString();
    message.save().then(loadMessages);
}

module.exports = {
    messages: messages,
    addMessage: addMessage
};