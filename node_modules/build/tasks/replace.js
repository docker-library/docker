var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs");

module.exports.tasks = {
    replace: function(options,config,logger){
        var p = new Promise();
        
        Array.from(options).each(function(opt){
            logger.info("Replacing " + opt.token + " with " + opt.value + " in " + opt.file);
            logger.info("\treading file");
            var original = fs.readFileSync(fs.realpathSync(opt.file), 'utf-8');
            var pattern = new RegExp("\\" + opt.token,"g");
            logger.info("\treplacing token");
            var final = original.replace(pattern, opt.value);
            logger.info("\tsaving file");
            fs.writeFileSync(opt.file, final, 'utf-8');
        });
        
        p.resolve(true);
        
        return p;
    }
};