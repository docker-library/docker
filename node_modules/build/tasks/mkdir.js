var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs");

module.exports.tasks = {
    mkdir: function(options,config,logger){
        var p = new Promise();
        Array.from(options).each(function(d){
            logger.info("Making directory: " + d);
            fs.mkdirSync(d, "0755");
        });
        p.resolve(true);
        return p;
    }
};