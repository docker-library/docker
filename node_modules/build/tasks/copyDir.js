var util = require("util"),
    Promise = require("promised-io").Promise,
    wrench = require("wrench"),
    fs = require("fs");

module.exports.tasks = {
    copyDir: function (options, config, logger) {
        var p = new Promise();
        options.copy.each(function(dir){
            var from = fs.realpathSync(options.basedirs.from + "/" + dir),
                to = options.basedirs.to + "/" + dir;   //may not exist already
            logger.info("Copying " + from + " to " + to);
            wrench.copyDirSyncRecursive(from, to);
        });
        p.resolve(true);
        return p;
    }
};