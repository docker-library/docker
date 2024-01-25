var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs"),
    path = require("path");

module.exports.tasks = {
    deleteFile: function (options, config, logger) {
        var p = new Promise();
        Array.from(options).each(function(file){
            logger.info("Checking for file: " + file);
            if (path.existsSync(file)) {
                logger.info("Removing file: " + file);
                fs.unlinkSync(file);
            }
        });
        p.resolve(true);
        return p;
    }
};