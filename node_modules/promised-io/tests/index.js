exports.testOAuth = require('./oauth');
exports.testPromise = require('./promise');
exports.testQuerystring = require('./querystring');

// test spawning coroutines if generators are supported on platform
try {
	eval("(function* (){})()");
	exports.testPromiseSpawn = require('./promise-spawn');
}
catch (err) {}

if (require.main === module)
	require("patr/runner").run(exports);
