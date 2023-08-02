public class CMT_Event extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public Date EventDate { get; set; }
    public String EventDateTime { get; set; }
    public CMT_Event()
    {
        // empty
    }
    
    private void init (CMT_Event_gne__c event, List<CMT_Attachment> attachments)
    {
    	if (event != null)
    	{
    		Id = event.Id;
        	Name = event.Name_gne__c;
        	EventDate = event.Event_Date_gne__c;
        	if(event.Event_Date_gne__c != null)
        	{
        		if(event.Event_Time_gne__c != null)
        		{ 
        			String dayStr,hourStr,monthStr,minuteStr,dayStrDt,monthStrDt; 
        			dayStrDt = event.Event_Date_gne__c.day()<10? '0'+String.valueof(event.Event_Date_gne__c.day()):String.valueof(event.Event_Date_gne__c.day());
		        	monthStrDt = event.Event_Date_gne__c.month()<10? '0'+String.valueof(event.Event_Date_gne__c.month()):String.valueof(event.Event_Date_gne__c.month());
		        	Datetime dt = DateTime.parse( monthStrDt + '/' + dayStrDt  + '/' + event.Event_Date_gne__c.year() +' ' + event.Event_Time_gne__c);
		        	minuteStr = dt.minute()<10? '0'+String.valueof(dt.minute()):String.valueof(dt.minute());
		        	monthStr = EventDate.month()<10? '0'+String.valueof(EventDate.month()):String.valueof(EventDate.month());
					dayStr = EventDate.day()<10? '0'+String.valueof(EventDate.day()):String.valueof(EventDate.day());
					hourStr = dt.hour()<10? '0'+String.valueof(dt.hour()):String.valueof(dt.hour());
		        	EventDateTime = EventDate.year() + '-' + monthStr + '-' + dayStr + 'T' + hourStr + ':' + minuteStr +':00.000Z';
        		}
        	}
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    public CMT_Event (CMT_Event_gne__c event)
    {
        init (event, null);
    }
    
    public CMT_Event (CMT_Event_gne__c event, List<CMT_Attachment> attachments)
    {
        init (event, attachments);
    }
}