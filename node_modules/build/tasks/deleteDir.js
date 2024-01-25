var util = require("util"),
    Promise = require("promised-io").Promise,
    wrench = require("wrench"),
    path = require("path");

module.exports.tasks = {
    deleteDir: function(options,config,logger){
        var p = new Promise();
        Array.from(options).each(function(dir){
            
            if (path.existsSync(dir)) {
                logger.info("removing directory: " + dir);
                wrench.rmdirSyncRecursive(dir);
            } else {
                logger.info("Path " + dir + " does not exist.");
            }
        });
        p.resolve(true);
        return p;
    }
};