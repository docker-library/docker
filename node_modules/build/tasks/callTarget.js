var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs"),
    path = require("path"),
    Builder = require("../builder");

module.exports.tasks = {
    callTarget: function (options, config, logger) {
        var p = new Promise();
        
        //first, copy passed in params to the config object
        config.params = options.params;
        
        new Builder(config, config.logfilePath).build(options.target).then(function(){
            p.resolve(true);
        });
        
        return p;
    }
};