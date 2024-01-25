var assert = require("assert");
var querystring = require("../util/querystring");

exports.testMungingArrayParams = function(){
	var arr = ["bar", "baz"];
	var requestParams = [];
	querystring.addToArray(requestParams, "foo", arr);
	assert.deepEqual(requestParams, ["foo[]", "bar", "foo[]", "baz"]);
};

exports.testMungingObjectParams = function(){
	var obj = { "key": "value" };
	var requestParams = [];
	querystring.addToArray(requestParams, "obj", obj);
	assert.deepEqual(requestParams, ["obj[key]", "value"]);
};

exports.testParsingMungedQuerystring = function(){
	var qs = "foo=bar&foo=baz&obj[key]=value";
	var requestParams = [];
	querystring.parseToArray(requestParams, qs);
	assert.deepEqual(requestParams, ["foo[]", "bar", "foo[]", "baz", "obj[key]", "value"]);
};

if (require.main === module)
	require("patr/runner").run(exports);
