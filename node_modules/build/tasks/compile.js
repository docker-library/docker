var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs"),
    jsmin = require("jsmin").jsmin;

module.exports.tasks = {
    compile: function(options,config,logger){
        var p = new Promise();
        Array.from(options).each(function(opt){
            logger.info("Compressing file: " + opt.file);
            var orig_code = fs.readFileSync(fs.realpathSync(opt.file), 'utf-8'),
                final_code = jsmin(orig_code);
            logger.info("Writing compressed file: " + opt.target);
            fs.writeFileSync(opt.target, final_code, 'utf-8');
        });
        p.resolve(true);
        return p;
    }
};