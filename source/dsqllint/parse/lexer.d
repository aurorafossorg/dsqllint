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

/++
SQL Lexer

This file defines the SQL Lexer

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2019
+/
module dsqllint.parse.lexer;

import dsqllint.parse.tokenize.tok;
import dsqllint.parse.tokenize.tokens;

import std.stdio;
import std.string;
import std.ascii;
import std.traits;
import std.algorithm.iteration;
import std.algorithm.setops;
import std.regex;
import std.exception;
import std.array;

version(unittest) import aurorafw.unit.assertion;


/** Invalid Token Exception
 *
 * Exception that reports an invalid token parsed by the tokenizer.
 *
 * Examples:
 * --------------------
 * throw new InvalidTokenException("This token is invalid");
 * --------------------
 */
@safe pure
public final class InvalidTokenException: Exception
{
	///
	mixin basicExceptionCtors;
}


public struct SQLLexer
{
	// disable default constructor
	@disable this();

	@safe pure
	public this(string input)
	{
		this.input = input;
	}

	@safe pure
	public this(SQLLexer lexer)
	{
		this.cur = lexer.cur.dup;
		this.input = lexer.input.dup;
	}

	@safe pure
	public SQLLexer dup()
	{
		return SQLLexer(this);
	}

	@safe
	public static const(SQLTok)[] tokens(string input)
	{
		return tokens(SQLLexer(input));
	}

	@trusted
	public static const(SQLTok)[] tokens(SQLLexer lexer)
	{
		auto ret = appender!(const(SQLTok)[]);
		foreach(_; lexer)
			ret ~= _;

		return ret[];
	}

	@safe
	public static const(SQLTokenContent)[] tokensContent(string input)
	{
		return tokensContent(SQLLexer(input));
	}

	@trusted
	public static const(SQLTokenContent)[] tokensContent(SQLLexer lexer)
	{
		auto ret = appender!(const(SQLTokenContent)[]);

		foreach(_; lexer)
			ret ~= lexer.cur;

		return ret[];
	}

	@safe pure
	public @property bool empty()
	{
		return cur.index >= input.length;
	}

	public int opApply(scope int delegate(SQLTok) dg)
	{
		while(!empty)
		{
			immutable int result = dg(nextToken());
			if (result)
				return result;
		}

		return 0;
	}


	public int opApply(scope int delegate(string, SQLTok) dg)
	{
		while(!empty)
		{
			auto nt = nextToken();
			immutable int result = dg(content, nt);
			if (result)
				return result;
		}

		return 0;
	}


	@safe pure
	private static bool isNewLine(dchar c)
	{
		static import std.uni;
		switch (c)
		{
		case '\n':
		case '\r':
		case std.uni.lineSep:
		case std.uni.paraSep:
			return true;

		default:
			return false;
		}
	}

	@safe /*pure*/
	private SQLTok captureToken(SQLTok[] filteredSpec)(ref Captures!string c)
	{
		static foreach(tok; filteredSpec)
		{
			c = input[cur.index .. $].matchFirst(ctRegex!(tok.match, tok.matchFlags));
			if(!c.empty)
			{
				cur.startLine = cur.endLine;
				cur.startCol = cur.endCol;
				cur.startIndex = cur.index;
				cur.endIndex = (cur.index += c[1].length);

				static if(tok.name == "WHITESPACE" || tok.name == "MULTI_LINE_COMMENT")
				{
					foreach(ch; c.front)
					{
						if(isNewLine(ch))
						{
							cur.endLine++;
							cur.endCol = 1;
						} else {
							cur.endCol++;
						}
					}
				} else {
					cur.endCol += (cur.endIndex - cur.startIndex);
				}
				cur.content = input[cur.startIndex .. cur.endIndex];
				return (cur.token = tok);
			}
		}

		return SQLToken.get!"ERROR";
	}

	@safe /*pure*/
	SQLTok nextToken()
	{
		Captures!string c;

		if(empty)
			return SQLToken.get!"EOF";

		/* function to check for char from statements, words or identifiers */
		bool isSWOI(char c)
		{
			static import std.ascii;
			return std.ascii.isAlpha(c) || c == '_';
		}

		immutable _swoiTokens = SQLToken.spec
			.filter!(t =>
				t.hasType(SQLTok.Type.Statement)
					|| t.hasType(SQLTok.Type.Word)
					|| t.hasType(SQLTok.Type.Keyword)).array;

		immutable _otherTokens = setDifference!"a.name < b.name"(
			SQLToken.spec
				.filter!(t => !t.isSpecial).array,
			_swoiTokens
		).array;

		if(isSWOI(input[cur.index])
			&& captureToken!(_swoiTokens)(c).name != "ERROR")
			return cur.token;

		if(captureToken!(_otherTokens)(c).name != "ERROR")
			return cur.token;

		throw new InvalidTokenException("Can't match a valid token!");
	}

	@safe pure
	public void reset()
	{
		cur = SQLTokenContent.init;
	}

	@safe pure
	public @property SQLTokenContent current()
	{
		return cur;
	}

	@safe pure
	public @property string content()
	{
		return cur.content;
	}

	@safe pure
	public @property size_t startCol()
	{
		return cur.startCol;
	}

	@safe pure
	public @property size_t startLine()
	{
		return cur.startLine;
	}

	@safe pure
	public @property size_t endCol()
	{
		return cur.endCol;
	}

	@safe pure
	public @property size_t endLine()
	{
		return cur.endLine;
	}

	private string input;
	private SQLTokenContent cur;
}

@("Lexer: New Line")
unittest {
	assertTrue(SQLLexer.isNewLine('\n'));
	assertTrue(SQLLexer.isNewLine('\r'));

	static import std.uni;
	assertTrue(SQLLexer.isNewLine(std.uni.lineSep));
	assertTrue(SQLLexer.isNewLine(std.uni.paraSep));

	assertFalse(SQLLexer.isNewLine('a'));
}

@("Lexer: duplication")
unittest {
	SQLLexer lexer = SQLLexer("= .");
	assertEquals(lexer, SQLLexer(lexer));
	assertEquals(lexer, lexer.dup);
	assertNotSame(lexer, lexer.dup);
}

@("Lexer: token list")
unittest {
	auto content = "= *\n#";
	SQLLexer lexer = SQLLexer(content);

	auto tokens = [
		SQLToken.get!"EQ",
		SQLToken.get!"WHITESPACE",
		SQLToken.get!"STAR",
		SQLToken.get!"WHITESPACE",
		SQLToken.get!"POUND",
	];

	assertEquals(tokens,lexer.array);
	assertEquals(tokens,SQLLexer.tokens(lexer));
	assertEquals(tokens, SQLLexer.tokens(content));
}

@("Lexer: token content")
unittest {
	auto content = "Select ";
	SQLLexer lexer = SQLLexer(content);

	assertEquals(SQLTokenContent.init, lexer.current);
	assertEquals(SQLToken.get!"SELECT", lexer.nextToken);
	auto tokContents = [
		SQLTokenContent(
			SQLToken.get!"SELECT",
			"Select",
			6, 0, 6, 1, 7, 1, 1
		),
		SQLTokenContent(
			SQLToken.get!"WHITESPACE",
			" ",
			7, 6, 7, 7, 8, 1, 1
		)
	];

	assertEquals(tokContents.front, lexer.current);

	assertEquals("Select", lexer.content);
	assertEquals(1, lexer.startCol);
	assertEquals(7, lexer.endCol);
	assertEquals(1, lexer.startLine);
	assertEquals(1, lexer.endLine);

	lexer.reset();

	assertEquals(tokContents, SQLLexer.tokensContent(lexer));
	assertEquals(tokContents, SQLLexer.tokensContent(content));
}

@("Lexer: foreach and opApply")
unittest {
	SQLLexer lexer = SQLLexer("    ");

	assertFalse(lexer.empty);
	foreach(_; lexer)
		continue;

	assertTrue(lexer.empty);
	foreach(_; lexer)
		assertFalse(0, "Should be empty, so this loop shouldn't run");

	lexer.reset();
	assertFalse(lexer.empty);
	foreach(_, __; lexer)
		continue;

	assertTrue(lexer.empty);
	foreach(_, __; lexer)
		assertFalse(0, "Should be empty, so this loop shouldn't run");

	assertEquals(SQLToken.get!"EOF", lexer.nextToken);
}
