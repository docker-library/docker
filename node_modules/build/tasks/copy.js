var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs");

module.exports.tasks = {
    copy: function(options,config,logger){
        var p = new Promise();
            newFile = fs.createWriteStream(options.to),
            oldFile = fs.createReadStream(options.from);
        
        newFile.on('open',function(fd){
           util.pump(oldFile,newFile, function(err){
               logger.info("File " + options.from + " copied to " + options.to);
               p.resolve(true);
           });
        });
        
        return p;

    }
};