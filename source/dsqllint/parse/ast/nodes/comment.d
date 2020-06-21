/*
  ____      ____  ____  _     _     _  _    _  _____
 |  _"\    / ___\/  _ \/ \   / \   / \/ \  / |/__ __\
/| | | |   |    \| / \|| |   | |   | || |\ | |  / \
U| |_| |\  \___ || \_\|| |_/\| |_/\| || | \| |  | |
 |____/ u  \____/\____\\____/\____/\_/\_/  \_|  \_/
  |||_
 (__)_)

Copyright (C) 2019 Aurora Free Open Source Software.
Copyright (C) 2019 Luís Ferreira <luis@aurorafoss.org>

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
SQL Comment

This file defines a SQL comment. It can be a line or multiline comment.

Authors: Luís Ferreira <luis@aurorafoss.org>
Copyright: All rights reserved, Aurora Free Open Source Software
License: GNU Lesser General Public License (Version 3, 29 June 2007)
Date: 2019
+/
module dsqllint.parse.ast.nodes.comment;

import dsqllint.parse.tokenize.tok;
import dsqllint.parse.parser;

import dsqllint.parse.ast.nodes.base;
import dsqllint.parse.ast.nodes.hint.ihint;
import dsqllint.parse.file;

@safe pure
public final class SQLCommentNode : SQLBaseNode
{
	@safe pure
	this(SQLTokenContent tokc)
	{
		string tokName = tokc.token.name;

		switch(tokName)
		{
			case "MULTI_LINE_COMMENT":
				this._multiLine = true;
				goto case;
			case "LINE_COMMENT":
				this._content = tokc.content;
				break;
			default:
				throw new InvalidSQLParseException(
					"Expected comment token but found " ~ tokName,
					SQLFile.Location(tokc.startLine, tokc.startCol));
		}
	}


	/**
	 * Multi line comment property
	 * Returns: true if the comment is multiline, false otherwise.
	 */
	@safe pure
	@property bool isMultiline()
	{
		return _multiLine;
	}

	/**
	 * Content of the comment
	 * Returns: the comment content
	 */
	@safe pure
	@property string content()
	{
		return _content;
	}


	protected bool _multiLine;
	protected string _content;
}
