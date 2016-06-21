var Observable = require("FuseJS/Observable");
var appstax = require("appstax");
appstax.init("NkxXMTRibGhEWHBLcg==");

var model = appstax.model();
model.watch("todos");

var newItem = Observable("");

function toggle(args) {
    var item = args.data;
    item.completed = !item.completed;
    model.save(item);
}

function addItem(args) {
    var text = newItem.value;
    if(text.length == 0) {
        return;
    }
    var item = appstax.object("todos");
    item.title = text;
    item.completed = false;
    item.save();
    newItem.value = "";
}

module.exports = {
    model: model.observable(Observable),
    toggle: toggle,
    newItem: newItem,
    addItem: addItem
};