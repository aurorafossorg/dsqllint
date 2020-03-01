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
SQL File

This file defines a SQL file. It will tokenize the file and parse it to an AST.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2019
+/
module dsqllint.parse.file;

import dsqllint.parse.lexer;
import dsqllint.parse.ast;
import dsqllint.parse.parser;
import dsqllint.parse.tokenize.iterator;

version(unittest) import aurorafw.unit.assertion;

/** SQL File
 *
 * This struct defines a SQL file, run the tokenizer and parse it to an AST.
 */
public struct SQLFile
{
	// disable default constructor
	@disable this();

	/** Construct a SQL file from filename
	 *
	 * Examples:
	 * --------------------
	 * auto sqlfile = SQLFile("foobar.sql");
	 * --------------------
	 */
	public this(string filename)
	{
		this._filename = filename;

		import std.file : readText;

		auto lexer = SQLLexer(filename.readText);
		auto toksContent = SQLLexer.tokensContent(lexer);
		it = new TokenIterator(toksContent);

		auto parser = SQLParser(it);
		_tree = parser.parse();
	}

	/** File name
	 *
	 * Returns: file name string
	 */
	pragma(inline)
	public string filename() @property
	{
		return this._filename;
	}

	/** Abstract Syntax Tree
	 *
	 * Returns: abstract syntax tree object
	 */
	pragma(inline)
	public SQLTree tree() @property
	{
		return this._tree;
	}

	/// The name of the file being parsed
	private string _filename;
	/// Abstract Syntax Tree
	private SQLTree _tree;
	/// Token Iterator
	private TokenIterator it;
}

@("SQL File")
unittest {
	import std.file : deleteme, write, exists, remove;
	import std.exception : assertThrown;

	string dfile = deleteme();
	scope(exit)
	{
		assertTrue(exists(dfile));
		remove(dfile);
	}

	write(dfile, "SELECT * FROM tuna;");

	assertThrown(SQLFile("this-file-shouldnt-exist"));

	import std.stdio;
	writeln(" --> SQLFile without NotImplementedException! <-- ");
	//FIXME: shouldn't throw NotImplementedException

	// SQLFile file = SQLFile(dfile);
	// assertEquals(dfile, file.filename);

	//TODO: test tree() function
}
