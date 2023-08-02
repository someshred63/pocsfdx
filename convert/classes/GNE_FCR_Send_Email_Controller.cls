public with sharing class GNE_FCR_Send_Email_Controller {
	public Id fcrDaysPlanId {get; set;}
	
	public String getAttachmentName(){
		return GNE_FCR_Util.getReportName(fcrDaysPlanId);
	}
	
	@RemoteAction
	public static RemoteSendResult sendPDF(ModalFieldsWrapper wrapper){
		RemoteSendResult result;
		Blob pdf = GNE_FCR_Util.generatePDF(Page.GNE_FCR_PDF, wrapper.dayPlanId, Boolean.valueOf(wrapper.isAssesment), Boolean.valueOf(wrapper.isSummary));
		Messaging.EmailFileAttachment attachment = GNE_FCR_Util.createAttachment('application/pdf', wrapper.attachmentName, pdf);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setUseSignature(false);
		mail.setToAddresses(wrapper.emails.split(',', 0));
		if(String.isNotBlank(wrapper.cc)){
			mail.setCcAddresses(wrapper.cc.split(',', 0));
		}
		mail.setSubject(wrapper.subject);
		mail.setHTMLBody(wrapper.emailBody);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
		try{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			result = new RemoteSendResult(wrapper, System.Label.GNE_FCR_Email_Send);
		}catch(Exception e){
			system.debug(logginglevel.error, e.getMessage());
			result = new RemoteSendResult(wrapper, e.getMessage());
		}
		return result;
	}
	
	public class ModalFieldsWrapper{
		public String emails {get; private set;}
		public String cc {get; private set;}
		public String subject {get; private set;}
		public String emailBody {get; private set;}
		public String attachmentName {get; private set;}
		public Id dayPlanId {get; private set;}
		public String isAssesment {get; private set;}
		public String isSummary {get; private set;}
		
		public ModalFieldsWrapper(String emails, String cc, String subject, String attachmentName, String emailBody, Id dayPlanId, String isAssesment, String isSummary){
			this.emails = emails;
			this.cc = cc;
			this.subject = subject;
			this.emailBody = emailBody;
			this.dayPlanId = dayPlanId;
			this.attachmentName = attachmentName;
			this.isAssesment = isAssesment;
			this.isSummary = isSummary;
		}
	}
	
	public class RemoteSendResult{
		public ModalFieldsWrapper wrappedFields {get; private set;}
		public String message {get;set;}
		
		RemoteSendResult(ModalFieldsWrapper wrappedFields, String message){
			this.wrappedFields = wrappedFields;
			this.message = message;
		}
	}
}