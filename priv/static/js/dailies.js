// A $( document ).ready() block.
$(document).ready(function() {
    // We are using the filename as the channel name
    let gChannel = sSocket.channel("dailies");

    // Try to join the channel
    gChannel.join().receive("ok", function(response) {
        return console.log("Dailies channel connection successfully.", response);
    }).receive("error", function(reason) {
        return console.log("Dailies channel connection failed.", reason);
    });

    // A special case topic for the settings page
    gChannel.on("update_timer", function(_ref) {
        $("#" + _ref.name + "_time").text(_ref.time);
    });

    // A special case topic for the settings page
    gChannel.on("update_lastresult", function(_ref) {
        $("#" + _ref.name + "_lastresult").text(_ref.lastresult);
    });
});