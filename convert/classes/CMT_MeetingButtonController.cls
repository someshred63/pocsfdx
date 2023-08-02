public with sharing class CMT_MeetingButtonController
{
	public String meetingId { get; set; }
	public String label { get; set; }
	
	public PageReference go()
	{
		if (meetingId == null)
		{
			throw new CMT_Exception('Meeting ID is null');
		}
		
		if (label == null)
		{
			label = 'Go to meeting';
		}
		
		PageReference ref = new PageReference('/' + meetingId);
		ref.setRedirect(true);
		return ref;
	}
}