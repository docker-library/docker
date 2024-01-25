var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs");

module.exports.tasks = {
    rename: function(options,config,logger){
        var p = new Promise();
    
        Array.from(options).each(function(opt){
            var from = fs.realpathSync(opt.from);
            fs.renameSync(from, opt.to);
        });
        
        p.resolve(true);
        return p;
    
    }
};