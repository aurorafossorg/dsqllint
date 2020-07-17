module dsqllint.tests.comments;

version (unittest) import aurorafw.unit.assertion;

import dsqllint.parse.lexer;
import dsqllint.parse.tokenize.tokens;
import std.algorithm.iteration;
import std.array;


///
@("Tokenizer: Line comments")
@safe
unittest {
	assertEquals([
		"LINE_COMMENT"
	], SQLLexer.tokens("-- foo").map!(t => t.name).array);

	assertEquals([
		"LINE_COMMENT",
		"WHITESPACE"
	], SQLLexer.tokens("-- foobar\n").map!(t => t.name).array);

	assertEquals([
		"WHITESPACE",
		"LINE_COMMENT"
	], SQLLexer.tokens("\n\n-- foo").map!(t => t.name).array);
}


///
@("Tokenizer: Multiline comments")
@safe
unittest {
	assertEquals([
		"MULTI_LINE_COMMENT"
	], SQLLexer.tokens("/* foo */").map!(t => t.name).array);

	assertEquals([
		"WHITESPACE",
		"MULTI_LINE_COMMENT",
		"WHITESPACE"
	], SQLLexer.tokens("\n/* foo */\n").map!(t => t.name).array);
}


///
@("Tokenizer: Mix single and multiline comments")
@safe
unittest {
	assertEquals([
		"MULTI_LINE_COMMENT",
		"WHITESPACE",
		"LINE_COMMENT"
	], SQLLexer.tokens("/* foo */\n--foo").map!(t => t.name).array);

	assertEquals([
		"LINE_COMMENT",
		"WHITESPACE",
		"MULTI_LINE_COMMENT",
	], SQLLexer.tokens("--foo\n/* foo */").map!(t => t.name).array);
}
