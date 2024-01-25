/**
 * The main builder script
 */

//require mootools
require('moo-server').apply(GLOBAL);



var winston = require('winston'),
    fs = require('fs'),
    path = require("path"),
    util = require("util"),
    sys = require("sys"),
    when = require("promised-io").when,
    Promise = require("promised-io").Promise;



var Builder = new Class({
    
    Implements: [Options],
    options: {},
    config: null,
    targets: {},
    logger: null,
    queue: [],
    stack: null,
    tasks: {},
    
    initialize: function(options, logfile) {
        this.setOptions(options);
        this.logger = new (winston.Logger)({
            transports: [
                new (winston.transports.Console)({level: "silly"}),
                new (winston.transports.File)({ filename: logfile, level: "silly" })
            ]
        });
        this.logger.emitErrs = false;
        
        if (nil(options)) {
            this.logger.debug("config is nil");
        } else {
            this.logger.debug("config is not nil");
            //this.logger.info("config: " + util.inspect(this.options, false, null));
        }
        
        this.loadInternalTasks();
        this.loadTasks(this.options.tasks);
        
    },
    
    loadTasks: function(filename) {
        Array.from(filename).each(function(file){
            var tasks = require(file).tasks;
            for (var name in tasks) {
                this.logger.info("loading task: " + name);
                this.tasks[name] = tasks[name];
            }
        },this);
    },
   
    build: function(target, config) {
        var p = new Promise();
        config = nil(config) ? this.options : config;
        
        this.logger.info("Processing target: " + target);
        
        //load the target file
        fn = require(this.options.targets + "/" + target + ".target");
        this.targets[target] = fn(config, this.logger);
        this.logger.info("Starting target" + util.inspect(this.targets[target], false, null));
        //start loading in the target's required dependencies 
        if (!nil(this.targets[target].depends)) {
            this.importTargets(this.targets[target].depends);
        }
        
        this.queue.push(target);
        
        this.logger.info("queue order: " + util.inspect(this.queue, false, null));
        //begin processing targets
        this.runTargets().then(function(){ p.resolve(true);});
        return p;
    },
    
    loadInternalTasks: function(){
        var taskPath = path.normalize(__dirname + "/tasks");
            files = fs.readdirSync(taskPath);
        Array.from(files).each(function(file){
            this.loadTasks(taskPath + "/" + file); 
        }, this);
    },

    importTargets: function(depends){
        this.logger.debug("in ImportTargets for " + util.inspect(depends,false,null));
        if (!nil(depends)) {
            Array.from(depends).each(function(d){
                if (!Object.keys(this.targets).contains(d)) {
                    this.targets[d] = (require(this.options.targets + "/" + d + ".target"))(this.options,this.logger);
                    this.logger.info("Target config for " + d + ":\n" + util.inspect(this.targets[d],false,null));
                    if (!nil(this.targets[d].depends)) {
                        this.importTargets(this.targets[d].depends);
                    }
                    this.queue.push(d);
                    
                }
            }, this);
        }
    },
    
    runTargets: function(){
        var target = this.queue.shift(),
            p = new Promise();
        
        this.stack = Array.clone(this.targets[target].tasks);
        
        this.logger.info("\n\n!!!!!!!!!!!!!\nExecuting target: " + target);
        this.logger.info("Target description: " + this.targets[target].description);
        this.logger.info("Number of tasks: " + this.stack.length);
        
        this.executeTarget(target).then(function(){
            if (this.queue.length > 0) { 
                this.runTargets();
            } else {
                p.resolve(true);
            }
        }.bind(this));
        
        return p;
    },
    
    executeTarget: function(){
        var p = new Promise();
        
        var task = this.stack.shift(),
            taskName = Object.keys(task)[0],
            options = task[taskName];
            
        this.logger.info("running task: " + taskName);
        this.tasks[taskName](options, this.options, this.logger).then(function(){
            this.logger.info("Promise resolved from task: " + taskName);
            if (this.stack.length === 0) {
                this.logger.info("No more tasks...");
                p.resolve(true);
            } else {
                this.logger.info("On to next task!!!");
                this.executeTarget().then(function(){p.resolve(true);});
            }
        }.bind(this), function(err){
            p.reject(err);
        }.bind(this));
           
        return p;
    }

    
});

module.exports = Builder;



            
