public class GNE_SFA2_ComposeEmail_Ctrl {
	public String emailRecipients {get; set;}
	public String emailRecipientsCC {get; set;}
	public String emailSubject {get; set;}
	public String emailContent {get; set;}
	
	public GNE_SFA2_ComposeEmail_Ctrl() {
	}
	
	public class EmailData {
		public String[] to;
		public String[] cc;
		public String subject;
		public String body;
		
		public EmailData(String[] a_to, String[] a_cc, String a_subject, String a_body) {
			to = a_to;
			cc = a_cc;
			subject = a_subject;
			body = a_body;
		}
	}
}