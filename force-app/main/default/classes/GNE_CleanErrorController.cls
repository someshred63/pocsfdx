/**********************************************
 * A utility controller class for Error page.
 * Appirio.com
 *
 *********************************************/
public class GNE_CleanErrorController 
{
	public String msg {get;set;}
	
	public GNE_CleanErrorController()
	{
	  String parm = ApexPages.currentPage().getParameters().get('msg');
	  if(parm != null)
	    msg = parm;
	}
}