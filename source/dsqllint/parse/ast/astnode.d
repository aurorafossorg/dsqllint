module dsqllint.parse.ast.astnode;

import dsqllint.parse.ast.visitor.visitor;
import dsqllint.parse.ast.object;

interface SQLASTNode
{

	void accept(SQLASTVisitor visitor);
	void accept0(SQLASTVisitor visitor);

	public static void acceptChild(T = SQLObject)(SQLASTVisitor visitor, T[] children)
	{
		if (children is null)
			return;

		foreach(T child; children)
			acceptChild(visitor, child);
	}

	public static void acceptChild(SQLASTVisitor visitor, SQLObject child)
	{
		if (child is null)
			return;

		child.accept(visitor);
	}
}
