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

module dsqllint.parse.tokenize.tok;

import std.array;

@safe pure
struct SQLTokenDeclaration
{
	@safe pure
	public SQLTokenDeclaration dup()
	{
		SQLTokenDeclaration ret;
		ret.name = name.dup;
		ret.match = match.dup;
		ret.matchFlags = matchFlags.dup;

		return ret;
	}

	string name, match, matchFlags = "i";

	enum Type : uint {
		Statement = 1 << 0,
		Clause = 1 << 1,
		Operator = 1 << 2,
		Delimiter = 1 << 3,
		Literal = 1 << 4,
		Keyword = 1 << 5,
		Special = 1 << 6,
		Word = 1 << 7,
		Other = 1 << 8
	};

	uint types = Type.Other;

	@safe pure
	@property isSpecial() const
	{
		return types == Type.Special;
	}

	@safe pure
	@property hasType(uint types) const
	{
		return (this.types & types) == types;
	}

	@safe pure
	public bool assertSame()(auto ref const SQLTokenDeclaration t) const {
		if(t.name == name)
			assert(0, "Same token name! (" ~ name ~ ")");
		else if(!(t.isSpecial || isSpecial) && t.match == match)
			assert(0, "Same match expression! (" ~ match ~ ")");
		else
			return false;
	}
}

alias SQLTok = SQLTokenDeclaration;
alias SQLTokType = SQLTokenDeclaration.Type;

@safe pure @nogc nothrow
struct SQLTokenContent {
	@safe pure
	public SQLTokenContent dup()
	{
		SQLTokenContent ret;
		ret.token = token.dup;
		ret.content = content.dup;

		ret.index = index;
		ret.startIndex = startIndex;
		ret.endIndex = endIndex;

		ret.startCol = startCol;
		ret.endCol = endCol;

		ret.startLine = startLine;
		ret.endLine = endLine;

		return ret;
	}

	/// Token
	public SQLTok token;
	/// Token content
	public string content;

	// buffer reference

	/// index in the buffer
	public size_t index;

	/// start buffer index
	public size_t startIndex;
	/// end buffer index
	public size_t endIndex;

	// file reference

	/// start file column
	public size_t startCol = 1;
	/// end file column
	public size_t endCol = 1;

	/// start file line
	public size_t startLine = 1;
	/// end file line
	public size_t endLine = 1;
}

@safe pure
package template sqlTokDec(
	string name,
	string match = "(" ~ name ~ ")",
	string matchFlags = "i",
	uint types = SQLTokType.Other)
{
	import std.string : startsWith;
	enum sqlTokDec = SQLTokenDeclaration(
		name,
		(match is null && matchFlags is null)
			? match
			: "^" ~ match,
		matchFlags,
		types);
}

enum sqlSpaceSufix = `\s`;

@safe pure
package template sqlTokDecWord(
	string name,
	uint types = SQLTokType.Word | SQLTokType.Other,
	string ncSufix = sqlSpaceSufix)
{
	enum sqlTokDecWord = sqlTokDec!(name, "(" ~ name ~ ")" ~ ncSufix, "i", types);
}

@safe pure
package template sqlTokDecKeyword(string name, string ncSufix = sqlSpaceSufix)
{
	enum sqlTokDecKeyword = sqlTokDecWord!(name, SQLTokType.Keyword, ncSufix);
}

@safe pure
package template sqlTokDecStatement(string name)
{
	enum sqlTokDecStatement = sqlTokDecWord!(name, SQLTokType.Statement);
}

@safe pure
package template sqlTokDecClause(string name)
{
	enum sqlTokDecClause = sqlTokDecWord!(name, SQLTokType.Clause);
}

@safe pure
package template sqlTokDecSpecial(string name)
{
	enum sqlTokDecSpecial = sqlTokDec!(name, null, null, SQLTokType.Special);
}
