public with sharing class CMT_DeleteAndRedirectController
{
	private String url { get; set; }
	private String meetingId { get; set; }
	private String delId { get; set; }
	
	public PageReference deleteAndRedirect()
	{
		PageReference currentPageRef = System.currentPageReference();
        delId = currentPageRef.getParameters().get('delId');
        url = currentPageRef.getParameters().get('url');
        meetingId = currentPageRef.getParameters().get('meetingId');
		Database.delete(delId);
		
		String qs = '';
		
		for (String paramName : currentPageRef.getParameters().keySet())
		{
			qs += paramName + '=' + currentPageRef.getParameters().get(paramName) + '&';
		}
		
		return CMT_MiscUtils.getPageRef(url + (qs != '' ? '?' + qs.substring(0, qs.length()-1) : ''));
	}
}