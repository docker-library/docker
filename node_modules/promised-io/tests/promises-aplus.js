var lib = require("../promise");
var promisesAplusTests = require("promises-aplus-tests");

exports.baseAdapter = {
	resolved: Promise.resolve,
	rejected: Promise.reject,
	deferred: function () {
		var resolver, rejecter;
		var promise = new Promise(function (resolve, reject) {
			resolver = resolve;
			rejecter = reject;
		});
		return {
			promise: promise,
			resolve: resolver,
			reject: rejecter
		};
	}
};

exports.libAdapter = {
	resolved: function (value) {
		var deferred = lib.defer();
		deferred.resolve(value);
		return deferred.promise;
	},
	rejected: function (reason) {
		var deferred = lib.defer();
		deferred.reject(reason);
		return deferred.promise;
	},
	deferred: function () {
		return lib.defer();
	}
}

function run(adapter, callback) {
	promisesAplusTests(adapter, callback);
}

if (require.main === module) {
	// run(exports.baseAdapter, function () {});
	run(exports.libAdapter, function () {});
}
