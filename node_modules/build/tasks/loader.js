//require dependencies
var jxLoader = require('jxLoader').jxLoader,
    Promise = require('promised-io').Promise,
    fs = require('fs'),
    util = require("util");

//the loader instance itself
var loader = null,
    _logger;

module.exports.tasks = {
    combine: function(options, config, logger){
        var p = new Promise();
        _logger = logger;
        if (loader === null) {
            config.loader.base.logger = _logger;
            loader = new jxLoader(config.loader.base);
            loader.addEvent('loadRepoDone', function(){
               runCombine(options, p); 
            });
            loader.addRepository(config.loader.repos);
        } else {
            runCombine(options, p); 
        }
        return p;
        
    },
    
    createDeps: function(options, config, logger){
        var p = new Promise();
        _logger = logger;
        if (loader === null) {
            _logger.info("no loader object found... creating.");
            config.loader.base.logger = _logger;
            loader = new jxLoader(config.loader.base);
            loader.addEvent('loadRepoDone', function(){
               fs.writeFileSync(options.target + '/deps.json',JSON.stringify(loader.getRepoArray()),'utf8');
               p.resolve(true);
            });
            loader.addRepository(config.loader.repos);
        } else {
            //console.warn("object from getRepoArray(): " + util.inspect(loader.getRepoArray(),false, null));
            fs.writeFileSync(options.target + '/deps.json',JSON.stringify(loader.getRepoArray()),'utf8');
            p.resolve(true);
        }
        return p;
    }
};


var runCombine = function(options, promise) {
    //_logger.info("options passed into runCombine: " + util.inspect(options,false,null));
    
    Array.from(options).each(function(opts){
        var classes = !nil(opts.classes) ? opts.classes : null;
        var repos = !nil(opts.repos) ? opts.repos : null;
        var type = !nil(opts.type) ? opts.type : 'js';
        var includeDeps = !nil(opts.includeDeps) ? opts.includeDeps : true;
        var theme = !nil(opts.theme) ? opts.theme : null;
        var exclude = !nil(opts.exclude) ? opts.exclude : null;
        var opt = !nil(opts.opts) ? opts.opts : true;
        loader.options.tags = opts.tags;
        _logger.debug('tags passed in:' + util.inspect(loader.options.tags,false,null));
        var compiled = loader.compile(classes, repos, type, includeDeps, theme, exclude, opt);
        //_logger.info("returned from compile: " + util.inspect(compiled, false, null));
        _logger.warn("writing to target: " + opts.target);
        fs.writeFileSync(opts.target, compiled.source, 'utf8');
    });
    promise.resolve(true);
};