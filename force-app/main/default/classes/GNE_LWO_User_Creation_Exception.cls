/**
 * Exception thrown when creating LWO users fails.
 *
 * @author Radek Krawiec
 * @created 08/16/2012
 *
 * Test class: none
 */
public class GNE_LWO_User_Creation_Exception extends Exception
{
	public Integer errorCode { get; set; }
	
	public GNE_LWO_User_Creation_Exception (String msg, Integer errorCode)
	{
		this(msg);
		this.errorCode = errorCode;	
	}
}