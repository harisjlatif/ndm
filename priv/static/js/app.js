/**
 * This function is called at the beginning when the page is first loaded.
 */
let sSocket = new Phoenix.Socket("/socket");
sSocket.connect();
sSocket.onError(function() {
    return console.log("there was an error with the connection!");
});
sSocket.onClose(function() {
    return console.log("the connection dropped");
});

let gConnectionChannel = sSocket.channel("connection");

// Try to join the channel
gConnectionChannel.join().receive("ok", function(response) {
    return console.log("Connection channel connection successfully.", response);
}).receive("error", function(reason) {
    return console.log("Connection channel connection failed.", reason);
});

// A special case topic for appending to log
gConnectionChannel.on("log", function(_ref) {
    var html = _ref.html;
    appendToLog(html);
});