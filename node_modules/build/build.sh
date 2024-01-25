#!/usr/bin/env node

/**
 * Base script for invoking a build. Call with
 * 
 *     > build <target>
 */
var Builder = require("./builder.js"),
    sys = require("sys"),
    path = require("path"),
    util = require("util"),
    fs = require("fs");
    


/**
 * Parse arguments array
 * @param {Array} args optional arguments arrray.
 * @return {Object} opts key value hash.
 * @export
 */
 parse = function(args) {
    // args is optional, default is process.argv
    args = args || process.argv;

    var opts = {}, curSwitch;

    args.forEach(function(arg) {
        // its a switch
        if (/^(-|--)/.test(arg) || !curSwitch) {
            opts[arg] = true;
            curSwitch = arg;
        // this arg is a data
        } else {
            if (arg === 'false') {
                arg = false;
            } else if (arg === 'true') {
                arg = true;
            } else if (!isNaN(arg)) {
                arg = Number(arg);
            }

            // it was a boolean switch per default, 
            // now it has got a val
            if (typeof opts[curSwitch] === 'boolean') {
                opts[curSwitch] = arg;
            } else if (Array.isArray(opts[curSwitch])) {
                opts[curSwitch].push(arg);
            } else {
                opts[curSwitch] = [opts[curSwitch], arg];
            }
        }
    });

    return opts;
};

var args = parse();

//sys.puts("args: " + sys.inspect(args));
var configPath = fs.realpathSync((args['--config'] != undefined) ? args['--config'] : "./builder/config.js"),
    logfile = (args['--logfile'] != undefined) ? args['--logfile'] : "./build.log",
    config = require(configPath),
    target = (args['--target'] != undefined) ? args['--target'] : config.project["default"];

var logfileBase = path.basename(logfile),
    logfilePath = path.dirname(logfile)

logfile = fs.realpathSync(logfilePath) + "/" + logfileBase;
logfile = path.normalize(logfile);

config.logfilePath = logfile;
config.filepath = configPath;
config.targets = fs.realpathSync(path.dirname(configPath) + "/targets");

sys.puts("config: " + util.inspect(config, true, null));

new Builder(config, logfile).build(target);