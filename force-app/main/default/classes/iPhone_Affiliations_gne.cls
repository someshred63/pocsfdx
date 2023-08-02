@RestResource(urlMapping='/iPhoneAffiliations/*')
global with sharing class iPhone_Affiliations_gne {
	
	global class AffiliationsSet {
		public List<AccountAffiliation> affaccts;
		public List<ContactAffiliation> affcons;
		
		public AffiliationsSet(List<AccountAffiliation> affacctsList,
			List<ContactAffiliation> affconsList) {
			affaccts = affacctsList;
			affcons = affconsList;
		}
	}
	
	global class AccountAffiliation {
		public String fid;	//Id,
		public String id;	//To_Account_vod__c,
		public String ln;	//To_Account_vod__r.LastName,
		public String rn;	//Role_vod__c,
		public String aid;	//From_Account_vod__c,
		//public String ax;	// i,u,d
		public String fn;	//To_Account_vod__r.FirstName,
		public String ip;	//To_Account_vod__r.IsPersonAccount,
		public String nm;	//To_Account_vod__r.Name

		public AccountAffiliation(Affiliation_vod__c affRec) {
			fid	= affRec.Id;
			id	= affRec.To_Account_vod__c;
			ln	= affRec.To_Account_vod__r.LastName;
			rn	= affRec.Role_vod__c;
			aid	= affRec.From_Account_vod__c ;
			fn	= affRec.To_Account_vod__r.FirstName;
			ip	= String.valueOf(affRec.To_Account_vod__r.IsPersonAccount);
			nm	= affRec.To_Account_vod__r.Name;
			
			id	= (id == null) ? '' : id;
			ln	= (ln == null) ? '' : ln;
			rn	= (rn == null) ? '' : rn;
			aid	= (aid == null) ? '' : aid;
			fn	= (fn == null) ? '' : fn;
			nm	= (nm == null) ? '' : nm;
		}
	}
	
	global class ContactAffiliation {
		public String fid; //Id,
		public String ln; //To_Contact_vod__r.LastName,
		public String p2; //To_Contact_vod__r.Secondary_Phone_gne__c,
		public String fx; //To_Contact_vod__r.Fax,
		public String z4; //To_Contact_vod__r.Zip_4_gne__c,
		public String ar; //Role_vod__c Affiliated with,
		public String aid; //From_Account_vod__c,
		//public String ax; // i,u,d
		public String x2; //To_Contact_vod__r.Secondary_ext_gne__c,
		public String ct; //To_Contact_vod__r.MailingCity,
		public String xt; //To_Contact_vod__r.Ext_gne__c,
		public String id; //To_Contact_vod__c,
		public String ty; //To_Contact_vod__r.Contact_Type_gne__c,
		public String e2; //To_Contact_vod__r.Secondary_Email_gne__c,
		public String ci; //To_Contact_vod__r.CreatedById,
		public String a1; //To_Contact_vod__r.MailingStreet,
		public String mdi; //To_Contact_vod__r.iPhone_Request_Id_gne__c,
		public String st; //To_Contact_vod__r.MailingState,
		public String zp; //To_Contact_vod__r.MailingPostalCode,
		public String em; //To_Contact_vod__r.Email,
		public String ph; //To_Contact_vod__r.Phone ,
		public String fn; //To_Contact_vod__r.FirstName,
		public String cd; //To_Contact_vod__r.CreatedDate transformed to text e.g. 2008-03-06 01:31:33.0,
		public String nm; //To_Contact_vod__r.Name
		
		public ContactAffiliation(Affiliation_vod__c affRec) {
			fid	= affRec.Id;
			ln	= affRec.To_Contact_vod__r.LastName ;
			p2	= affRec.To_Contact_vod__r.Secondary_Phone_gne__c;
			fx	= affRec.To_Contact_vod__r.Fax;
			z4	= affRec.To_Contact_vod__r.zip_4_gne__c;
			ar	= affRec.Role_vod__c;
			aid	= affRec.From_Account_vod__c;
			x2	= affRec.To_Contact_vod__r.Secondary_ext_gne__c ;
			ct	= affRec.To_Contact_vod__r.MailingCity ;
			xt	= affRec.To_Contact_vod__r.ext_gne__c;
			id	= affRec.To_Contact_vod__c;
			ty	= affRec.To_Contact_vod__r.Contact_Type_gne__c;
			e2	= affRec.To_Contact_vod__r.Secondary_Email_gne__c;
			ci	= affRec.To_Contact_vod__r.CreatedById;
			a1	= affRec.To_Contact_vod__r.MailingStreet;
			mdi	= affRec.To_Contact_vod__r.iPhone_Request_Id_gne__c;
			st	= affRec.To_Contact_vod__r.MailingState;
			zp	= affRec.To_Contact_vod__r.MailingPostalCode;
			em	= affRec.To_Contact_vod__r.email ;
			ph	= affRec.To_Contact_vod__r.phone;
			fn	= affRec.To_Contact_vod__r.firstname;
			cd	= affRec.To_Contact_vod__r.CreatedDate.format('yyyy-MM-dd HH:mm:ss.S');
			nm	= affRec.To_Contact_vod__r.name;
			
			ln	= (ln == null) ? '' : ln;
			p2	= (p2 == null) ? '' : p2;
			fx	= (fx == null) ? '' : fx;
			z4	= (z4 == null) ? '' : z4;
			ar	= (ar == null) ? '' : ar;
			aid	= (aid == null) ? '' : aid;
			x2	= (x2 == null) ? '' : x2;
			ct	= (ct == null) ? '' : ct;
			xt	= (xt == null) ? '' : xt;
			id	= (id == null) ? '' : id;
			ty	= (ty == null) ? '' : ty;
			e2	= (e2 == null) ? '' : e2;
			ci	= (ci == null) ? '' : ci;
			a1	= (a1 == null) ? '' : a1;
			mdi	= (mdi == null) ? '' : mdi;
			st	= (st == null) ? '' : st;
			zp	= (zp == null) ? '' : zp;
			em	= (em == null) ? '' : em;
			ph	= (ph == null) ? '' : ph;
			fn	= (fn == null) ? '' : fn;
			cd	= (cd == null) ? '' : cd;
			nm	= (nm == null) ? '' : nm;
		}
	}
	
	@HttpPost
	global static AffiliationsSet doGetAffiliations(List<String> accountIds) {
		
		System.debug('INPUT PARAM: accountIds = ' + accountIds);
		List<AccountAffiliation> accAffObjs = new List<AccountAffiliation>();
		List<ContactAffiliation> conAffObjs = new List<ContactAffiliation>();
		
		List<Affiliation_vod__c> affRecs = 
				[SELECT Id, 
					   	Role_vod__c,
					   	From_Account_vod__c,
					   	To_Account_vod__c,
					   	To_Contact_vod__c,
					   
					   	To_Account_vod__r.LastName,
						To_Account_vod__r.FirstName,
						To_Account_vod__r.IsPersonAccount,
						To_Account_vod__r.Name,
						To_Contact_vod__r.LastName,
						
						To_Contact_vod__r.Secondary_Phone_gne__c,
						To_Contact_vod__r.Fax,
						To_Contact_vod__r.zip_4_gne__c,
						To_Contact_vod__r.Secondary_ext_gne__c,
						To_Contact_vod__r.MailingCity,
						To_Contact_vod__r.ext_gne__c,
						To_Contact_vod__r.Contact_Type_gne__c,
						To_Contact_vod__r.Secondary_Email_gne__c,
						To_Contact_vod__r.CreatedById,
						To_Contact_vod__r.MailingStreet,
						To_Contact_vod__r.iPhone_Request_Id_gne__c,
						To_Contact_vod__r.MailingState,
						To_Contact_vod__r.MailingPostalCode,
						To_Contact_vod__r.email,
						To_Contact_vod__r.phone,
						To_Contact_vod__r.firstname,
						To_Contact_vod__r.CreatedDate,
						To_Contact_vod__r.Name
				 FROM Affiliation_vod__c
				 WHERE From_Account_vod__c in :accountIds];

		for (Affiliation_vod__c affRec : affRecs) {
			if(affRec.To_Contact_vod__c==null) {
				AccountAffiliation accAffObj = new AccountAffiliation(affRec);
				accAffObjs.add(accAffObj);
			} else {
				ContactAffiliation conAffObj = new ContactAffiliation(affRec);
				conAffObjs.add(conAffObj);
			}			
		}
		
		return new AffiliationsSet(accAffObjs, conAffObjs);
	}
}