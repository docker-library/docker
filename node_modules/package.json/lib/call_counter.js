var internal_call_counter = 0;

function count_call() {
	++internal_call_counter;
	console.log("You have made " + internal_call_counter + " calls!");
}

module.exports = count_call;