var assert = require("assert");
var promise = require("../promise");

exports.testResolved = function (){
	return promise.spawn(function* (){
		yield promise.delay(100);
		// can yield non-promise values
		var foo = yield 'foo';
		assert.ok(foo === 'foo');
		var result = yield promise.delay(50).then(function () {
			return foo;
		});
		var error = new Error('Boom!');
		var start = new Date();
		try {
			yield promise.delay(100).then(function () {
				throw error;
			});
			// Should never come here
			assert.ok(true === false);
		}
		catch (e) {
			assert.ok(e === error);
			assert.ok(new Date() - start >= 100);
		}
		return result;
	}).then(function (value) {
		assert.ok(value === 'foo');
		return true;
	}, function (e) {
		// Should never come here
		assert.ok(true === false);
	});
};

exports.testRejected = function (){
	var error = new Error('Boom!');
	return promise.spawn(function* (){
		var start = new Date();
		yield promise.delay(100).then(function () {
			assert.ok(new Date() - start >= 100);
			throw error;
		});
		// Should never come here
		assert.ok(true === false);
	}).then(function () {
		// Should never come here
		assert.ok(true === false);
	}, function (e) {
		assert.ok(e === error);
		return true;
	});
};

if (require.main === module)
	require("patr/runner").run(exports);
