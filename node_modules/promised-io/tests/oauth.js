var assert = require("assert");
var oauth = require("../oauth");
var querystring = require("../util/querystring");

exports.testGeneratingSignatureBaseString = function(){
	// base string described in <http://oauth.net/core/1.0/#sig_base_example>
	var client = new oauth.Client;
	var result = client._createSignatureBase("GET", "http://photos.example.net/photos",
		"file=vacation.jpg&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1191242096&oauth_token=nnch734d00sl2jdk&oauth_version=1.0&size=original");
	assert.equal(result, "GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal");
};

exports.testNormalizingUrl = function(){
	var client = new oauth.Client;

	// default ports should be stripped
	assert.equal(client._normalizeUrl({ protocol: "https:", hostname: "somehost.com", port: "443", pathname: "/foo/bar" }), "https://somehost.com/foo/bar");
	assert.equal(client._normalizeUrl({ protocol: "http:", hostname: "somehost.com", port: "80", pathname: "/foo/bar" }), "http://somehost.com/foo/bar");

	// should leave non-default ports from URLs for use in signature generation
	assert.equal(client._normalizeUrl({ protocol: "https:", hostname: "somehost.com", port: "446", pathname: "/foo/bar" }), "https://somehost.com:446/foo/bar");
	assert.equal(client._normalizeUrl({ protocol: "http:", hostname: "somehost.com", port: "81", pathname: "/foo/bar" }), "http://somehost.com:81/foo/bar");
};

exports.testNormalizingRequestParams = function(){
	var client = new oauth.Client;

	// ordered by name
	assert.equal(client._normalizeParams(["z", "a", "a", "b", "1", "c"]), "1=c&a=b&z=a");

	// if two parameter names are the same then order by the value
	assert.equal(client._normalizeParams(["z", "b", "z", "a", "1", "c"]), "1=c&z=a&z=b");

	// resulting parameters should be encoded and ordered as per <http://tools.ietf.org/html/rfc5849#section-3.1> (3.4.1.3.2)
	var requestParams = [];
	querystring.parseToArray(requestParams, querystring.stringify({
		"b5" : "=%3D",
		"c@": "",
		"a2": "r b",
		"oauth_consumer_key": "9djdj82h48djs9d2",
		"oauth_token":"kkk9d7dh3k39sjv7",
		"oauth_signature_method": "HMAC-SHA1",
		"oauth_timestamp": "137131201",
		"oauth_nonce": "7d8f3e4a",
		"c2" :  ""
	}));
	querystring.addToArray(requestParams, "a3", "a");
	querystring.addToArray(requestParams, "a3", "2 q");
	assert.equal(client._normalizeParams(requestParams), "a2=r%20b&a3=2%20q&a3=a&b5=%3D%253D&c%40=&c2=&oauth_consumer_key=9djdj82h48djs9d2&oauth_nonce=7d8f3e4a&oauth_signature_method=HMAC-SHA1&oauth_timestamp=137131201&oauth_token=kkk9d7dh3k39sjv7");
};

function generateClient() {
	var client = new oauth.Client("consumerkey", "consumersecret", null, null, null, "1.0", null, function(){ return "ybHPeOEkAUJ3k2wJT9Xb43MjtSgTvKqp"; });
	oauth.Client.getTimestamp = function(){ return "1272399856"; };
	return client;
}

exports.testSigningUrl = {
	"test without token": function(){
		var client = generateClient();

		// provide a valid signature when no token is present
		var requestParams = ["bar", "foo"];
		var oauthParams = client._collectOAuthParams({}, requestParams);
		var params = client._normalizeParams(requestParams);
		var baseString = client._createSignatureBase("GET", "http://somehost.com:3323/foo/poop", params);
		var signature = client._createSignature(baseString);
		assert.equal(signature, "7ytO8vPSLut2GzHjU9pn1SV9xjc=");
	},

	"test with token": function(){
		var client = generateClient();

		// provide a valid signature when a token is present
		var bound = client.bind("token", "");
		var requestParams = ["bar", "foo"];
		var oauthParams = bound._collectOAuthParams({}, requestParams);
		var params = bound._normalizeParams(requestParams);
		var baseString = bound._createSignatureBase("GET", "http://somehost.com:3323/foo/poop", params);
		var signature = bound._createSignature(baseString);
		assert.equal(oauthParams.oauth_token, "token");
		assert.equal(signature, "9LwCuCWw5sURtpMroIolU3YwsdI=");
	},
	"test with token and secret": function(){
		var client = generateClient();

		// provide a valid signature when a token and a token secret are present
		var bound = client.bind("token", "tokensecret");
		var requestParams = ["bar", "foo"];
		var oauthParams = bound._collectOAuthParams({}, requestParams);
		var params = bound._normalizeParams(requestParams);
		var baseString = bound._createSignatureBase("GET", "http://somehost.com:3323/foo/poop", params);
		var signature = bound._createSignature(baseString);
		assert.equal(signature, "zeOR0Wsm6EG6XSg0Vw/sbpoSib8=");
	}
};

exports.testBuildingAuthHeader = function(){
	var client = generateClient();

	// all provided OAuth arguments should be concatenated correctly
	var request = client._signRequest({
		method: "GET",
		protocol: "http:",
		hostname: "somehost.com",
		port: "3323",
		pathname: "/foo/poop",
		headers: {}
	}, ["bar", "foo"]);
	assert.equal(request.headers.authorization, 'OAuth oauth_consumer_key="consumerkey",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1272399856",oauth_nonce="ybHPeOEkAUJ3k2wJT9Xb43MjtSgTvKqp",oauth_version="1.0",oauth_signature="7ytO8vPSLut2GzHjU9pn1SV9xjc%3D"'); 
};

if (require.main === module)
	require("patr/runner").run(exports);
