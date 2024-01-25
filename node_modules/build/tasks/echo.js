var util = require("util"),
    Promise = require("promised-io").Promise;

module.exports.tasks = {
    echo: function(options, config, logger) {
        var p = new Promise();
        if (typeOf(options) == 'string') {
            logger.info(options);
        } else {
            logger.info(util.inspect(option, false, null));
        }
        p.resolve(true);
        return p;
    }
};