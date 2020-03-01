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

module dsqllint.parse.ast.visitor;

import dsqllint.parse.ast.object;

// private immutable uint[TypeInfo] typeMap;

// shared static this()
// {
//     // typeMap[typeid(AddExpression)] = 1;
// }

interface SQLASTVisitor {
	void postVisit(SQLObject obj);
	void preVisit(SQLObject obj);
	// void visit(const ExpressionNode n)
	// {
	//     switch (typeMap[typeid(n)])
	//     {
	//         //case 1: visit(cast(AddExpression) n); break;
	//         default: assert(false, __MODULE__ ~ " has a bug");
	//     }
	// }
}

//TODO: Reference libdparse here
template visitIfNotNull(fields ...)
{
	static if (fields.length > 1)
		immutable visitIfNotNull = visitIfNotNull!(fields[0]) ~ visitIfNotNull!(fields[1..$]);
	else
	{
		static if (typeof(fields[0]).stringof[$ - 2 .. $] == "[]")
		{
			static if (__traits(hasMember, typeof(fields[0][0]), "classinfo"))
				immutable visitIfNotNull = "foreach (i; " ~ fields[0].stringof ~ ") if (i !is null) visitor.visit(i);\n";
			else
				immutable visitIfNotNull = "foreach (i; " ~ fields[0].stringof ~ ") visitor.visit(i);\n";
		}
		else static if (__traits(hasMember, typeof(fields[0]), "classinfo"))
			immutable visitIfNotNull = "if (" ~ fields[0].stringof ~ " !is null) visitor.visit(" ~ fields[0].stringof ~ ");\n";
		else static if (is(Unqual!(typeof(fields[0])) == Token))
			immutable visitIfNotNull = "if (" ~ fields[0].stringof ~ ` != tok!""` ~ ") visitor.visit(" ~ fields[0].stringof ~ ");\n";
		else
			immutable visitIfNotNull = "visitor.visit(" ~ fields[0].stringof ~ ");\n";
	}
}
