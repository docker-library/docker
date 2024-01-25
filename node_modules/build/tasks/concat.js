var util = require("util"),
    Promise = require("promised-io").Promise,
    fs = require("fs"),
    files,
    _logger;


var addFile = function (stream, p) {
    var file = files.shift();
    
    readstream = fs.createReadStream(file, { encoding: 'utf-8' });
    
    readstream.on("end",function(){
        _logger.debug("in end method of readstream.");
        if (files.length > 0) {
            _logger.debug("going around again.");
            addFile(stream,p);
        } else {
            _logger.debug("closing stream and resolving promise...");
            stream.end();
            p.resolve(true);
        }
    });
    
    readstream.pipe(stream, {end: false});
};

module.exports.tasks = {
    concat: function (options, config, logger) {
        var p = new Promise(),
            newFile = fs.createWriteStream(options.target);
        logger.info("In concat... options passed: " + util.inspect(options,false,null));
        _logger = logger;
        files = Array.clone(options.files);
        addFile(newFile, p);
        return p;
    }
};


