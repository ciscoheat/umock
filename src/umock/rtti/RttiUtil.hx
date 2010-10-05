package umock.rtti;

import haxe.rtti.CType;

typedef CArgument = {
	var type : String;
	var opt : Bool;
	var name : String;
}

class RttiUtil
{
	public static function getFields(classType : Class<Dynamic>) : List<ClassField>
	{
		switch(getTypeTree(classType))
		{
			case TClassdecl(cl):
				return cl.fields;
				
			default:
				throw 'No RTTI class information found in ' + classType;
		}		
	}
	
	public static function getMethod(name : String, classType : Class<Dynamic>) : List<CArgument>
	{
		var methods = getMethods(classType, name);
		
		if(!methods.keys().hasNext())
			return null;
		
		return methods.get(name);
	}

	public static function getMethods(classType : Class<Dynamic>, ?methodName : String) : Hash<List<CArgument>>
	{
		var output = new Hash<List<CArgument>>();

		for(f in getFields(classType))
		{
			if(methodName != null && f.name != methodName)
				continue;
			
			switch(f.type)
			{
				// Test if field is a function
				case CFunction(args, ret):
					var argList = new List<CArgument>();
					
					for(arg in args)
					{
						var typeName = RttiUtil.typeName(arg.t, false);
						argList.add({type: typeName, opt: arg.opt, name: arg.name});
					}
					
					output.set(f.name, argList);

				default:
					// Do nothing if not a method.
			}					
		}

		return output;
	}	

	// Borrowed from caffeine-hx
	public static function typeName(type : CType, opt : Bool) : String 
	{
		switch(type)
		{
			case CFunction(_,_):
				return opt ? 'Null<function>' : 'function';
			
			case CUnknown:
				return opt ? 'Null<unknown>' : 'unknown';
			
			case CAnonymous(_), CDynamic(_):
				return opt ? 'Null<Dynamic>' : 'Dynamic';
			
			case CEnum(name, params), CClass(name, params), CTypedef(name, params):
				var t = name;
				
				if(params != null && params.length > 0) 
				{
					var types = new List<String>();
					for(p in params)
						types.add(RttiUtil.typeName(p, false));
					
					t += '<' + types.join(',') + '>';
				}
				
				return name != 'Null' && opt ? 'Null<'+t+'>' : t;
		}
	}
	
	public static function getTypeTree(classType : Class<Dynamic>) : TypeTree
	{
		var root : Xml = Xml.parse(getRtti(classType)).firstElement();
		return new haxe.rtti.XmlParser().processElement(root);
	}
	
	public static function getRtti(classType : Class<Dynamic>) : String
	{
		var rtti : String = untyped classType.__rtti;
		if(rtti == null)
		{
			throw 'No RTTI information found in ' + classType + ' (class must implement haxe.rtti.Infos)';
		}
		
		return rtti;
	}
}
