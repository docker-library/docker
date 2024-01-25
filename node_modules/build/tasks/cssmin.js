var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs"),
    cssmin = require("cssmin").cssmin;

module.exports.tasks = {
    cssmin: function(options,config,logger){
        var p = new Promise();
        Array.from(options).each(function(opt){
            logger.info("Compressing css file: " + opt.source);
            var orig_code = fs.readFileSync(fs.realpathSync(opt.source), 'utf-8'),
                final_code = cssmin(orig_code);
            logger.info("Writing compressed file: " + opt.target);
            fs.writeFileSync(opt.target, final_code, 'utf-8');
        });
        p.resolve(true);
        return p;
    }
};