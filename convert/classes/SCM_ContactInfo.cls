public class SCM_ContactInfo {
	public String attention{get; set;}
	public String recipient{get; set;} 
	public String faxNumber{get; set;}
	
	public Integer attentionIndex{get; set;}
	public Integer recipientIndex{get; set;}
	public Integer faxNumberIndex{get;set;}
	public SCM_ContactInfo(String attn,
						   String recip,
						   String fax)
	{
		attention = attn;
		recipient = recip;
		faxNumber = fax;
 
	}
}