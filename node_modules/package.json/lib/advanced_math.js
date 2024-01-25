var call_counter = require("./call_counter");

function mulitply(x, y) {
	call_counter();
	return x * y;
}

function divide(x, y) {
	call_counter();
	return x / y;
}

function fibo(count) {
	call_counter();
	return private_fibo(count);
}

function private_fibo(count, counter, first, second) {
	if(count == 0)
		return 0;
		
	if(counter == undefined) {
		counter = 1;
		first = 1;
		second = 2;
	}
	
	result = first + second;
	if(counter == count)
		return result;
		
	private_fibo(count, ++counter, second, result);
	
	return result;
}

module.exports = {
	multiplication: multiply,
	division: divide,
	fibonacci: fibo
}