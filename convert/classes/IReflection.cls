/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-09-30
*  Description: 
*  This global interface is used by SuperSort class and should be implemented in custom classes that are exposed to UI as a dataset for sortable tables
*  getValue(String name) method should be implemented which returns value of the property specified by name                        
*  Modification History
*  Date        Name        Description
*                
*************************************************************/

public interface IReflection 
{
	object getValue(String name);
}