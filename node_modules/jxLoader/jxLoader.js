/**
 * The jxLoader main class which does all of the work of ordering files from various
 * repositories according to their dependencies.
 */

//requires
var yaml = require('js-yaml'),
    sys = require('sys'),
    fsp = require('promised-io/fs'),
    fs = require('fs'),
    path = require('path'),
    util = require('util'),
    Walker = require('walker');

//check to see if mootools is already in the environment
if (typeof MooTools == 'undefined') {
    require('mootools').apply(GLOBAL);
    sys.puts('loaded mootools');
} else {
    sys.puts('mootools already loaded');
}

var jxLoader = new Class({

    Implements: [Events, Options],

    options: {},

    config: null,
    repos: null,
    flat: null,
    numRepos: 0,
    loadedRepos: 0,
    logger: null,
    debug: false,

    initialize: function (options) {
        this.setOptions(options);
        this.config = {};
        this.repos = {};
        
        this.logger = !nil(options.logger) ? options.logger : console;
        this.logger.info("Received logger in jxLoader");
        this.debug =  nil(options.debug)? false : options.debug;
    },

    /**
     * Add a repository to the loader
     * 
     * Paramaters:
     * config - The config should be an object that lists the appropriate keys for
     *      the listed repository
     */
    addRepository: function (config) {


        this.config = Object.merge(this.config, {repos: config});
        
        this.numRepos = Object.getLength(this.config.repos);
        
        Object.each(this.config.repos, function(conf, key){
            if (nil(this.repos[key])) {
                this.loadRepository(key, conf);
            }
        },this);




    },

    loadRepository: function (key, config) {
        var p = config.paths.js,
            me = this;

        //walk the path and process all files we find...
        Walker(p).filterDir(function(dir){
            return !(dir.test('^\.[\S\s]*$','i'));
        }).on('file', function(file){
            try {
                var data = fs.readFileSync(file, 'utf-8');
                
               if (this.debug) sys.puts('File contents: ' + sys.inspect(data));
                //process the file
                var descriptor = {},
                    regexp = /^-{3}\s*\n*([\S\s]*)\n+\.{3}/m,  //regexp to get yaml contents
                    matches = data.match(regexp);

                if (me.debug) me.logger.debug('All matches from getting yaml headers: ' + util.inspect(matches,false,null));

                if (!nil(matches)) {
                    matches.shift();
                    delete matches.index;
                    delete matches.input;
                    if (me.debug) me.logger.debug('matches is a ' + typeOf(matches));
                    if (me.debug) me.logger.debug('Matches from getting yaml headers: ' + matches[0]);
                    //remove \n from the string
                    var str = matches[0].replace(new RegExp('\r','g'),'');
                    if (me.debug) me.logger.debug('Matches from getting yaml headers after replacement: ' + str);
                    try {
                        descriptor = yaml.load(str);
                    } catch (err) {
                        me.logger.error('!!! error converting yaml');
                        me.logger.error('YAML object: ' + util.inspect(yaml,false,null));
                        me.logger.error('error: ' + util.inspect(err,false,null));
                        throw err;
                    }

                    me.logger.debug('object returned from yaml eval = ' + util.inspect(descriptor,false,null));
                    
                    
                    var requires = Array.from(!nil(descriptor.requires) ? descriptor.requires : []);
                    var provides = Array.from(!nil(descriptor.provides) ? descriptor.provides : []);
                    var optional = Array.from(!nil(descriptor.optional) ? descriptor.optional : []);
                    var filename = path.basename(file);

                    //normalize requires and optional. Fills up the default package name
                    //if one is not present and strips version info
                    requires.each(function(r, i){
                        requires[i] = me.parse_name(key, r).join('/').replace(' ','');
                    },this);

                    optional.each(function(r, i){
                        optional[i] = me.parse_name(key, r).join('/').replace(' ','');
                    },this);

                    if (nil(me.repos[key])) {
                        me.repos[key] = {};
                    }
                    var index = String.uniqueID();
                    me.repos[key][index] = Object.merge(descriptor,{
                        repo: key,
                        requires: requires,
                        provides: provides,
                        optional: optional,
                        path: file
                    });
                    
                    //make sure this is truly an object, not an array
                    var obj = {};
                    Object.each(me.repos[key][index], function(value, key){
                        obj[key] = value;
                    });
                    
                    me.repos[key][index] = obj;

                    if (me.debug) me.logger.debug('Done processing ' + filename);
                } else {
                    //there is no yaml header... drop this file
                    me.logger.debug('no header for ' + file);
                }
            } catch (err) {
                me.logger.error('!!!err : ' + util.inspect(err,false,null));
                //do nothing, just finish up
                //sys.puts('no file ' + file);
                throw err;
            }

            return;
        })
        .on('end',function(){
            this.loadedRepos++;
            if (this.loadedRepos == this.numRepos) {
                this.fireEvent('loadRepoDone', [key]);
            }
        }.bind(this));
    },

    parse_name: function (def, name){
        
        var exploded = name.split('/');
        if (this.debug) this.logger.debug('exploded = ' + util.inspect(exploded,false,null));
        if (exploded.length == 1 ) {
            if (this.debug) this.logger.debug("returning from parse_name: " + util.inspect([def, exploded[0]],false,null));
            return [def, exploded[0]];
        }
        if (nil(exploded[0]) || exploded[0].length === 0) {
            if (this.debug) this.logger.debug("returning from parse_name: " + util.inspect([def, exploded[1]],false,null));
            return [def, exploded[1]];
        }
        var exploded2 = exploded[0].split(':');
        if (exploded2.length == 1) {
            if (this.debug) this.logger.debug("returning from parse_name: " + util.inspect(exploded,false,null));
            return exploded;
        }
        if (this.debug) this.logger.debug("returning from parse_name: " + util.inspect([exploded2[0],exploded[1]],false,null));
        return [exploded2[0],exploded[1]];
    },

    flatten: function (obj) {
        var flat = {};
        Object.each(obj, function(items, repo){
            Object.each(items, function(value, key){
                value.provides.each(function(val){
                    val = val.replace(' ','');
                    flat[repo.toLowerCase() + '/' + val.toLowerCase()] = value;
                },this);
            },this);
        },this);

        return flat;
    },

    getRepoArray: function () {
        return this.repos;
    },

    getFlatArray: function () {
        return this.flat;
    },

    compileDeps: function (classes, repos, type, opts, exclude) {
        opts = !nil(opts) ? opts : true;
        exclude = !nil(exclude) ? exclude : [];

        var list = [];
        
        if (nil(this.flat)) {
            this.flat = this.flatten(this.repos);
        }

        if (!nil(repos)) {
            sys.puts("in compileDeps... ready to get repo info");
            sys.puts("repos to get: " + util.inspect(repos, false, null));
            sys.puts("type: " + type);
            Array.from(repos).each(function(val){
                var o = {};
                o[val] = this.repos[val];
                var flat = this.flatten(o);
                Object.each(flat, function(obj, key){
                    obj.visited = false;
                },this);
                Object.each(flat, function(obj, key){
                    list = this.includeDependencies(val, key, opts, exclude, flat, list, type, [key]);
                },this);
            },this);
        }

        if (!nil(classes)) {
            classes.each(function(val){
                var r = this.findRepo(val);
                //clear visited reference
                Object.each(this.flat, function(obj, key){
                    obj.visited = false;
                },this);
                list = this.includeDependencies(r, val, opts, exclude, this.flat, list, type);
            },this);
        }
        this.logger.info('list of dependencies: ' + util.inspect(list,false,null));
        return list;
    },

    compile: function (classes, repos, type, includeDeps, theme, exclude, opts) {
        type = !nil(type) ? type : 'js';
        includeDeps = !nil(includeDeps) ? includeDeps : true;
        theme = !nil(theme) ? theme : '';
        exclude = !nil(exclude) ? exclude : [];
        opts = !nil(opts) ? opts : true;

        if (nil(this.flat)) {
            this.flat = this.flatten(this.repos);
        }
        
        var deps, 
            ret;
            
        this.logger.info("repos passed in: " + util.inspect(repos,false,null));
        
        if (includeDeps || !nil(repos)) {
            deps = this.compileDeps(classes, repos, type, opts, exclude);
        } else {
            deps = this.convertClassesToDeps(classes, type, exclude);
        }

        if (deps.length > 0) {
            var included = [],
                sources = [],
                ret2;

            if (type == 'js') {
               ret2 = this.getJsFiles(sources, included, deps);
            } else {
                ret2 = this.getCssFiles(sources, included, theme, deps);
            }

            ret = {
                included: ret2.includes,
                source: ret2.sources.join('\n\n')
            };
        } else {
            ret = false;
        }
        if (this.debug) this.logger.warn("returning: " + util.inspect(ret,false,null));
        return ret;
    },

    includeDependencies: function (repo, klass, opts, exclude, flat, list, type, ml) {
        klass = klass.contains('/') ? klass : repo.toLowerCase() + '/' + klass.toLowerCase();

        if (!Object.keys(flat).contains(klass)) {
            return list;
        }

        var inf = flat[klass];

        if ((inf.visited && ml.contains(klass)) ||
            (type=='js' && (exclude.contains(inf.path) || list.contains(inf.path))) ||
            (type=='css' && (exclude.contains(klass) || list.contains(klass))) ||
            (type=='jsdeps' && (exclude.contains(inf.path) || list.contains(klass)))) {
            return list;
        }

        var requires = Array.from(inf.requires);
        flat[klass].visited = true;
        if (opts && Object.keys(inf).contains('optional') && inf.optional.length > 0) {
            requires.combine(inf.optional);
        }
        if (requires.length > 0) {
            requires.each(function(req){
                var parts = req.split('/');
                if (nil(ml)) {
                    ml = [];
                }
                ml.push(klass);
                list = this.includeDependencies(parts[0],parts[1],opts, exclude, flat, list, type, ml);
                ml.pop();
            },this);
        }

        if (type=='js') {
            list.push(inf.path);
        } else {
            list.push(klass);
        }

        return list;
    },

    convertClassesToDeps: function (classes, type, exclude) {
        var list;

        if (typeOf(classes) != 'array') {
            classes = Array.from(classes);
        }

        classes.each(function(klass){
            if (klass.contains('/')) {
                if (type=='js' && !exclude.contains(this.flat[klass.toLowerCase()].path)) {
                    list.push(this.flat[klass.toLowerCase()].path);
                } else if (type=='css' && !exclude.contains(klass)) {
                    list.push(klass);
                } else {
                    Object.each(this.flat, function(arr, key) {
                        var parts = key.split('/');
                        if (parts[0].toLowerCase() == klass.toLowerCase()) {
                            if (type=='js' && !exclude.contains(arr.path)) {
                                list.push(arr.path);
                            } else if (type=='css' && !exclude.contains(klass)) {
                                list.push(key);
                            }
                        }
                    },this);
                }
            }
        },this);

        return list;
    },

    findRepo: function(klass) {
        if (klass.contains('/')) {
            var parts = klass.split('/');
            return parts[0];
        } else {
            if (nil(this.flat)) {
                this.flat = this.flatten(this.repos);
            }
            var ret;
            Object.each(this.flat, function(arr, key){
                var parts = key.split('/');
                if (parts[1].toLowerCase() == klass.toLowerCase()) {
                    ret = parts[0];
                }
            },this);
            return ret;
        }
    },

    getJsFiles: function (sources, included, deps) {
        this.logger.debug('list of dependencies: ' + util.inspect(deps,false,null));
        deps.each(function(filename){
            this.logger.debug('reading file: ' + filename);
            var s = fs.readFileSync(filename, 'utf-8');
            //Remove any tags
            if (this.options.tags !== null && this.options.tags !== undefined) {
                Array.from(this.options.tags).each(function(tag){
                    var t = tag.escapeRegExp();
                        re = new RegExp('//<' + t + '>[\\s\\S]*?//</' + t + '>','gi');
                    s = s.replace(re,'');
                    re = new RegExp('/\\*<' + t + '>\\*/[\\s\\S]*?/\\*</' + t + '>\\*/','gi');
                    this.logger.debug('2nd regex = ' + util.inspect(re,false,null));
                    s = s.replace(re,'');
                },this);
            }
            sources.push(s);
            included.push(filename);
            this.logger.debug('done reading file: ' + filename);
        },this);
        return {
            includes: included,
            sources: sources
        };
    },

    getCssFiles: function (sources, included, theme, deps) {
        deps.each(function(dep){
            var parts = dep.split('/');
            included.push(dep);
            if (!nil(this.config.repos[parts[0]].paths.css)) {
                var csspath = this.config.repos[parts[0]].paths.css;
                csspath = csspath.replace('{theme}',theme);
                csspath = fs.realpathSync(csspath);
                var cssfiles = !nil(this.flat[dep].css) ? this.flat[dep].css : '';

                if (cssfiles.length > 0) {
                    cssfiles.each(function(css){
                        var fp = csspath + '/' + css + '.css';
                        if (path.existsSync(fp)) {
                            var s = fs.readFileSync(fp, 'utf-8');
                            if (this.options.rewriteImageUrl && !nil(this.config.repos[parts[0]].imageUrl)) {
                                s = s.replace(new RegExp(this.config.repos[parts[0]].imageUrl, 'g'),this.options.imagePath);
                            } else {
                                this.logger.info('not updating urls in css file ' + css);
                            }
                            sources.push(s);
                        } else {
                            if (!nil(this.config.repos[parts[0]].paths.cssalt)) {
                                var csspathalt = this.config.repos[parts[0]].paths.cssalt;
                                csspathalt = csspathalt.replace('{theme}',theme);
                                csspathalt = fs.realpathSync(csspathalt);
                                fp = csspathalt + '/' + css + '.css';
                                if (path.existsSync(fp)) {
                                    var s = fs.readFileSync(fp, 'utf-8');
                                    if (this.options.rewriteImageUrl && !nil(this.config.repos[parts[0]].imageUrl)) {
                                        s = s.replace(new RegExp(this.config.repos[parts[0]].imageUrl, 'g'),this.options.imagePath);
                                    } else {
                                        this.logger.info('not updating urls in css file ' + css);
                                    }
                                    sources.push(s);
                                }
                            }
                        }
                    },this);

                    if (this.options.moveImages && !nil(this.flat[dep].images)) {
                        var imageFiles = this.flat[dep].images;
                        if (imageFiles.length > 0) {
                            var ipath = this.config.repos[parts[0]].paths.images,
                                imageLocation = this.config.repos[parts[0]].imageLocation;

                            if (ipath.contains('{theme}')) {
                                ipath = ipath.replace('{theme}', theme);
                            }
                            ipath = fs.realpathSync(ipath);

                            //create destination if it's not already there
                            if (!path.existsSync(imageLocation)) {
                                fs.mkdirSync(imageLocation);
                            }

                            imageFiles.each(function(file){
                                if (!path.existsSync(imageLocation + '/' + file)) {
                                    var inStr = fs.createReadStream(ipath + '/' + file),
                                        outStr = fs.createWriteStream(imageLocation + '/' + file);

                                    inStr.pipe(outStr);
                                } else {
                                    this.logger.info('\t\tFile already exists');
                                }
                            },this);
                        } else {
                            this.logger.info('No image files to move');
                        }
                    } else {
                        this.logger.info('Not moving image files');
                    }
                }
            }
        },this);
        
        return {
            includes: included,
            sources: sources
        };
    }


});

exports.jxLoader = jxLoader;