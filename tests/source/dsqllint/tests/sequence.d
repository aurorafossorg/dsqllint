module dsqllint.tests.sequence;

version (unittest) import aurorafw.unit.assertion;

import dsqllint.parse.lexer;
import dsqllint.parse.parser;
import dsqllint.parse.tokenize.iterator;
import dsqllint.parse.tokenize.tokens;
import std.algorithm.iteration;
import std.array;


///
@("Statement sequence: Before comments")
unittest {
	auto sources = [
		"-- foo\n/* bar */\n -- foobar\n",
		"\n-- foo\n/* bar */\n -- foobar",
		"-- foo\n/* bar */\n -- foobar"
	];

	foreach(source; sources)
	{
		auto tree = SQLParser(new TokenIterator(
			SQLLexer.tokensContent(source)
		)).parse();

		assertEquals([
			"-- foo",
			"/* bar */",
			"-- foobar"
		], tree.sequence.beforeComments.map!(c => c.content).array);

		assertEquals(3, tree.sequence.beforeComments.length);
	}
}
