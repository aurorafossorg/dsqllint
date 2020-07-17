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

module dsqllint.tests.select;

version (unittest) import aurorafw.unit.assertion;

import dsqllint.parse.lexer;
import dsqllint.parse.tokenize.tokens;
import std.algorithm.iteration;
import std.array;


///
@("Tokenizer: Simple SELECT statement")
@safe
unittest {
	auto source = "SELECT tuna1, tuna2 FROM tuna_t;";

	auto tokens = [
		"SELECT",
		"WHITESPACE",
		"IDENTIFIER",
		"COMMA",
		"WHITESPACE",
		"IDENTIFIER",
		"WHITESPACE",
		"FROM",
		"WHITESPACE",
		"IDENTIFIER",
		"SEMICOLON"
	];

	assertEquals(tokens, SQLLexer.tokens(source).map!(t => t.name).array);
}


///
@("Tokenizer: Detect IDENTIFIER instead of SELECT")
@safe
unittest {
	assertEquals([SQLToken.get!"IDENTIFIER"], SQLLexer.tokens("SELECTfalse"));
}


///
@("Tokenizer: Case insensitive SELECT, detect SELECT instead of IDENTIFIER")
unittest {
	assertEquals(SQLToken.get!"SELECT", SQLLexer.tokens("Select ").front);
	assertEquals(SQLToken.get!"SELECT", SQLLexer.tokens("select ").front);
	assertEquals(SQLToken.get!"SELECT", SQLLexer.tokens("sELeCt ").front);
}
