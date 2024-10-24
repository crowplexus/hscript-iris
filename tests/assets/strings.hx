function main() {
	trace('Program Start!');

	var hello = "Hello!";
	trace('test 1, basic interpolation: $hello');
	var tally = {
		score: 10,
		hits: 5,
		misses: 0,
	};
	var stats = 'Score:${tally.score}';
	trace('test 2, bracket interpolation: ' + stats);
	stats = 'Score:${tally.score} - Hits:${tally.hits} - Misses:${tally.misses}';
	trace('test 3, bracket interpolation with multiple strings: ' + stats);

	trace('test 4, escaped interpolation: $${caw}, also blablablablabla');

	trace('test 5, nested interpolation: ${'${tally.score}'}');
}
