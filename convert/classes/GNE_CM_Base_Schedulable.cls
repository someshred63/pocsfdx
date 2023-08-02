global class GNE_CM_Base_Schedulable implements Schedulable 
{
	public String implClassName;

	global GNE_CM_Base_Schedulable(String pimplClassName)
	{
		implClassName=pimplClassName;
	}

	global void execute(SchedulableContext sc) 
	{
		Type targettype = Type.forName(implClassName);   
		if (targettype!=null)   
		{   
			Schedulable obj = (Schedulable) targettype.NewInstance();     
			obj.execute(sc);   
		}   
	}
}