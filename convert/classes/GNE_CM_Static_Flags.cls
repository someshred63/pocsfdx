/**
 * Static flags used for passing data between different functionalities within the same transaction.
 * @author Radek Krawiec, Roche
 * @created 03-13-2013
 */
public without sharing class GNE_CM_Static_Flags
{
	public static final String TASKS_UPSERT_IN_TRIGGER = 'tuit';
	
	private static Map<String, String> flags;
	
	public static void setFlag (String flag, String value)
	{
		if (flags == null)
		{
			flags = new Map<String, String>();
		}
		flags.put(flag, value);
	}
	
	public static void setFlag (String flag) 
	{
		GNE_CM_Static_Flags.setFlag(flag, 'true');
	}
	
	public static void unsetFlag (String flag)
	{
		flags.remove(flag);
	}
	
	public static Boolean isSet (String flag)
	{
		return flags != null && flags.containsKey(flag) && flags.containsKey(flag) != null;
	}
	
	public static String getFlag (String flag)
	{
		return flags != null ? flags.get(flag) : null;
	}
}