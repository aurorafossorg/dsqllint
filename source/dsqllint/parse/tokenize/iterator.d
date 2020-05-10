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

module dsqllint.parse.tokenize.iterator;

import dsqllint.parse.tokenize.tok;

import std.array;
import std.typecons;

version(unittest) import aurorafw.unit.assertion;

@safe pure
class TokenIterator {
	@safe pure
	this(const(SQLTokenContent)[] tokens)
	{
		this._tokens = tokens;
	}

	@safe pure
	bool hasNext()
	{
		return _tokens.length > (idx + 1);
	}

	@safe pure
	const(SQLTokenContent) next(Flag!"skipBlankTokens" skipBlankTokens = Yes.skipBlankTokens)
	{
		if(skipBlankTokens)
		{
			SQLTokenContent cur;
			while(((cur = _tokens[++idx]).token.name == "WHITESPACE" || cur.token.name == "MULTI_LINE_COMMENT") && hasNext)
				continue;
			return cur;
		}
		else
		{
			return _tokens[++idx];
		}
	}

	@safe pure
	Nullable!(const(SQLTokenContent)) peekNext(Flag!"skipBlankTokens" skipBlankTokens = No.skipBlankTokens)
	{
		if(!hasNext)
			return Nullable!(const(SQLTokenContent)).init;

		if(skipBlankTokens)
		{
			size_t pidx = 1;
			SQLTokenContent cur;
			while(((cur = _tokens[idx + pidx]).token.name == "WHITESPACE" || cur.token.name == "MULTI_LINE_COMMENT") && hasNext)
				pidx++;

			return nullable!(const(SQLTokenContent))(cur);
		} else {
			return nullable(_tokens[idx + 1]);
		}
	}

	@safe pure
	@property const(SQLTokenContent) current()
	{
		return _tokens[idx];
	}

	@safe pure
	void reset()
	{
		idx = 0;
	}

	@safe pure
	@property size_t index()
	{
		return idx;
	}

	@safe pure
	@property const(SQLTokenContent)[] left()
	{
		return _tokens[0 .. index];
	}

	@safe pure
	@property const(SQLTokenContent)[] right()
	{
		return _tokens[index .. $];
	}

	@safe pure
	@property const(SQLTokenContent)[] tokens()
	{
		return _tokens;
	}

	private const(SQLTokenContent)[] _tokens;
	private size_t idx;
}

@safe pure
@("Tokenizer: Token Iterator")
unittest {
	import dsqllint.parse.tokenize.tokens;

	auto toks = [
		SQLTokenContent(SQLToken.get!"SELECT", "seLecT"),
		SQLTokenContent(SQLToken.get!"WHITESPACE", "   "),
		SQLTokenContent(SQLToken.get!"STAR", "*"),
		SQLTokenContent(SQLToken.get!"WHITESPACE", "  \n")
	];

	TokenIterator it = new TokenIterator(toks);
	assertEquals(toks, it.tokens);

	assertTrue(it.hasNext);

	assertEquals(toks.front, it.current);
	assertEquals([], it.left);
	assertEquals(toks, it.right);


	assertFalse(it.peekNext().isNull);
	assertEquals(toks[1], it.peekNext());
	// due to be a nullable
	assertEquals(toks[1], it.peekNext().get());
	assertEquals(toks.front, it.current);

	assertEquals(toks[2], it.peekNext(Yes.skipBlankTokens));
	assertEquals(toks.front, it.current);

	it.next(No.skipBlankTokens);
	assertEquals([toks.front], it.left);
	assertEquals(toks[1 .. $], it.right);
	assertEquals(toks[1], it.current);

	it.reset();
	assertEquals(0, it.index);
	it.next();
	assertEquals(toks[2], it.current);

	auto emptyTI = new TokenIterator([]);
	assertFalse(emptyTI.hasNext());
	assertTrue(emptyTI.peekNext().isNull);
	// same thing
	assertEquals(Nullable!(const(SQLTokenContent)).init, emptyTI.peekNext());
}
