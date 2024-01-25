var assert = require("assert"),
	all = require("../promise").all,
	when = require("../promise").when,
	whenPromise = require("../promise").whenPromise,
	defer = require("../promise").defer,
	Promise = require("../promise"),
	Step = require("../step").Step;

exports.testSpeedPlainValue = function(){
	for(var i = 0; i < 1000; i++){
		when(3, function(){
		});
	}
};

exports.testSpeedPromise = function(){
	var deferred = defer();
	for(var i = 0; i < 1000; i++){
		when(deferred.promise, function(){
		});
	}
	deferred.resolve(3);
};

exports.testWhenPromiseRejectHandled = function(){
	// The inner whenPromise doesn't have a rejectCallback, but the outer one does.
	// This means the error then *is* handled, but the inner whenPromise doesn't know about that.
	// This shouldn't result in an uncaught exception thrown by the promise library.
	whenPromise(true, function(){
		return whenPromise((function(){
			var deferred = defer();
			deferred.reject({});
			return deferred.promise;
		})());
	}).then(null, function(){});
};

exports.testMultipleReject = function(){
	all(delayedFail(25), delayedFail(50), delayedSuccess(75)).then(function () {
		throw new Error('There should be no success here.');
	}, function () {
		// This is where we want to end up, once only.
	});
};

function delayedSuccess(delay) {
	var deferred = defer();
	setTimeout(function () {
		deferred.resolve();
	}, delay);
	return deferred.promise;
}

function delayedFail(delay) {
	var deferred = defer();
	setTimeout(function () {
		deferred.reject();
	}, delay);
	return deferred.promise;
}

function veryDeferred(){
	var deferred = defer();
	setTimeout(function(){
		deferred.resolve(true);
	}, 100);
	return deferred.promise;
}

function veryDeferred(){
	var deferred = defer();
	setTimeout(function(){
		deferred.resolve(true);
	}, 100);
	return deferred.promise;
}

exports.testStep = function(){
	var deferred = defer();
	Step({foo: 'bar'}, [
		function(){
			console.log('S1');
			assert.ok(this.foo === 'bar');
			return false;
		},
		function(result){
			console.log('S2');
			assert.ok(result === false);
			this.foo = 'baz';
			return veryDeferred();
		},
		function(result){
			console.log('S3');
			assert.ok(this.foo === 'baz');
			assert.ok(result === true);
			throw Error('Catchme!');
		},
		function(result){
			console.log('S4');
			assert.ok(result instanceof Error);
			assert.ok(result.message === 'Catchme!');
			deferred.resolve(true);
			// return undefined;
		},
		function(result){
			console.log('S5', result);
			// Should never come here
			deferred.reject(false);
			assert.ok(true === false);
		},
	]);
	return deferred.promise;
};

exports.testAsValue = function (){
	var deferred = Promise.as("supercala");
	deferred.then(function (res) {
		assert.ok(res == "supercala");
	}, function () {
		throw new Error("Unexpected error");
	});
};

exports.testAsPromise = function (){
	var temp = defer();
	temp.resolve("supercala");
	var deferred = Promise.as(temp);
	assert.ok(temp === deferred);
	deferred.then(function (res) {
		assert.ok(res == "supercala");
	}, function () {
		throw new Error("Unexpected error");
	});
};

if (require.main === module)
	require("patr/runner").run(exports);

