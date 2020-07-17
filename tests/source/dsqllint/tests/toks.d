/*
  ____      ____  ____  _     _     _  _    _  _____
 |  _"\    / ___\/  _ \/ \   / \   / \/ \  / |/__ __\
/| | | |   |    \| / \|| |   | |   | || |\ | |  / \
U| |_| |\  \___ || \_\|| |_/\| |_/\| || | \| |  | |
 |____/ u  \____/\____\\____/\____/\_/\_/  \_|  \_/
  |||_
 (__)_)

Copyright (C) 2019-2020 Aurora Free Open Source Software.
Copyright (C) 2019-2020 Luís Ferreira <luis@aurorafoss.org>

This file is part of the Aurora Free Open Source Software. This
organization promote free and open source software that you can
redistribute and/or modify under the terms of the GNU Lesser General
Public License Version 3 as published by the Free Software Foundation or
(at your option) any later version approved by the Aurora Free Open Source
Software Organization. The license is available in the package root path
as 'LICENSE' file. Please review the following information to ensure the
GNU Lesser General Public License version 3 requirements will be met:
https://www.gnu.org/licenses/lgpl.html .

Alternatively, this file may be used under the terms of the GNU General
Public License version 3 or later as published by the Free Software
Foundation. Please review the following information to ensure the GNU
General Public License requirements will be met:
http://www.gnu.org/licenses/gpl-3.0.html.

NOTE: All products, services or anything associated to trademarks and
service marks used or referenced on this file are the property of their
respective companies/owners or its subsidiaries. Other names and brands
may be claimed as the property of others.

For more info about intellectual property visit: aurorafoss.org or
directly send an email to: contact (at) aurorafoss.org .
 */

module dsqllint.tests.toks;

import dsqllint.parse.tokenize.tokens;
import dsqllint.parse.tokenize.tok;
import dsqllint.parse.lexer;
import std.range;
import std.algorithm;
import std.meta;

version(unittest) import aurorafw.unit.assertion;

private void validateToken(alias tokName)(string content)
{
	assertEquals(SQLToken.get!tokName, SQLLexer.tokens(content).front);
}

private void nonValidToken(alias tokName)(string content)
{
	assertFalse(SQLToken.get!tokName == SQLLexer.tokens(content).front);
}


///
@("Tokenizer: Validate all swoi tokens")
unittest {
	enum toks = SQLToken.spec
			.filter!(t =>
				t.hasType(SQLTok.Type.Statement)
					|| t.hasType(SQLTok.Type.Word)
					|| t.hasType(SQLTok.Type.Keyword));

	foreach(_; toks)
		assertEquals(_, SQLLexer.tokens(_.name ~ " ").front);
}


///
@("Tokenizer: Validate identifier token")
unittest
{
	validateToken!"IDENTIFIER"("test_");
	validateToken!"IDENTIFIER"("Test_");
	validateToken!"IDENTIFIER"("t3st_");
	validateToken!"IDENTIFIER"("T3st_");
	validateToken!"IDENTIFIER"("_4");

	nonValidToken!"IDENTIFIER"("4_");
	nonValidToken!"IDENTIFIER"("4Test");
	nonValidToken!"IDENTIFIER"(" ");
}


///
@("Tokenizer: Validate all other tokens")
unittest {
	validateToken!"EQEQ"("==");
	validateToken!"LTEQGT"("<=>");
	validateToken!"LTEQ"("<=");
	validateToken!"LTGT"("<>");
	validateToken!"GTEQ"(">=");
	validateToken!"EQGT"("=>");

	validateToken!"EQ"("=");

	validateToken!"LTLT"("<<");
	validateToken!"LT_MONKEYS_AT"("<@");
	validateToken!"GTGT"(">>");

	validateToken!"LT"("<");
	validateToken!"GT"(">");

	validateToken!"LITERAL_HEX"("0x1F");
	validateToken!"LITERAL_INT"("132");
	validateToken!"LITERAL_FLOAT"("13.2");

	validateToken!"LITERAL_STRING"("\"TUNA\"");

	validateToken!"LCURLY"("{");
	validateToken!"RCURLY"("}");
	validateToken!"LPAREN"("(");
	validateToken!"RPAREN"(")");
	validateToken!"LBRACKET"("[");
	validateToken!"RBRACKET"("]");

	validateToken!"STAR"("*");
	validateToken!"DOT"(".");
	validateToken!"COMMA"(",");
	validateToken!"SEMICOLON"(";");

	validateToken!"BANGBANG"("!!");
	validateToken!"BANG"("!");
	validateToken!"BANGEQ"("!=");
	validateToken!"BANGGT"("!>");
	validateToken!"BANGLT"("!<");
	validateToken!"BANG_TILDE_STAR"("!~*");
	validateToken!"BANG_TILDE"("!~");

	validateToken!"TILDE_STAR"("~*");
	validateToken!"TILDE_EQ"("~=");
	validateToken!"TILDE"("~");

	validateToken!"QUESBAR"("?|");
	validateToken!"QUESAMP"("?&");
	validateToken!"QUESQUES"("??");
	validateToken!"QUES"("?");

	validateToken!"COLONEQ"(":=");
	validateToken!"COLONCOLON"("::");
	validateToken!"COLON"(":");

	validateToken!"AMPAMP"("&&");
	validateToken!"AMP"("&");

	validateToken!"BARBARSLASH"("||/");
	validateToken!"BARBAR"("||");
	validateToken!"BARSLASH"("|/");
	validateToken!"BAR"("|");

	validateToken!"PLUS"("+");
	validateToken!"SUBGT"("->");
	validateToken!"SUB"("-");

	validateToken!"SLASH"("/");
	validateToken!"CARETEQ"("^=");
	validateToken!"CARET"("^");
	validateToken!"PERCENT"("%");

	validateToken!"MONKEYS_AT_AT"("@@");
	validateToken!"MONKEYS_AT_GT"("@>");
	validateToken!"MONKEYS_AT"("@");

	validateToken!"POUNDGTGT"("#>>");
	validateToken!"POUNDGT"("#>");
	validateToken!"POUND"("#");
}
