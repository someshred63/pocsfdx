@RestResource(urlMapping='/iPhoneAffiliationsUserMode/*')
global with sharing class iPhone_AffiliationsUserMode_gne {
	
	@HttpPost
	global static Map<String,Boolean> doGetAffiliationsUserMode() {
		Boolean viewMyBrandsOnly = 
			[SELECT ID FROM GroupMember 
			 WHERE GroupId IN (SELECT ID FROM Group 
			 				   WHERE Name = 'GNE-View-All-Brands-Users-Data-Group')
			 AND UserOrGroupId = :UserInfo.getUserId() limit 1].isEmpty();
			
		return new Map<String,Boolean>{'viewMyBrandsOnly' => viewMyBrandsOnly}; 
	}
}