public class AGG_SearchUser 
{
	
	/*##################################################
	#Project Name           : Genentec - Infrequent Users Search
	# File                  : AGG_SearchUser.cls
	# Version               : 1.0 
	# Created by            : <<Sandeep Kumar>> 
	# Created Date          : <<11nd Nov 09>> 
	# Last Modified by      : <<Sandeep Kumar>> 
	# Last Modified Date    : <<11nd Nov 09>> 
	# Description           : <<This is the controller class for Infrequent User Search that searches for Users>>  
	# 
	# 
	##################################################*/
	
	public String sSearchText{get; set;}
	public String sErrMessage{get; set;}
	public String sSearchString='';
	
	public String sUserAddName{get; set;}
	public String sUserAddNameType{get; set;}
	public String sUserButtonName{get; set;}
	
	final Integer iMaxSearch=50;
	
	List<User> lstUsers=new List<User>();
	
	//constructors
	public AGG_SearchUser()
	{
		
	}
	
	public AGG_SearchUser(ApexPages.StandardController stdController)
	{
		//names of input Text fields in calling form pased as parameter values. 
		//These names will be referenced from called form to post values back to parent/called form
		if(System.currentPageReference().getParameters().get('hcpname')!=null )
		{
			sUserAddName=System.currentPageReference().getParameters().get('hcpname');
		}
		if(System.currentPageReference().getParameters().get('hcpnametype')!=null )
		{
			sUserAddNameType=System.currentPageReference().getParameters().get('hcpnametype');
		}
		if(System.currentPageReference().getParameters().get('hcpbutton')!=null )
		{
			sUserButtonName=System.currentPageReference().getParameters().get('hcpbutton');
		}
		
	}
	
	//List to bind/diplay resutls to VF page
	public List<User> getMatchesFound()
	{
		
		return lstUsers;
	}
	
	//action value for Search button on VF page
	//retrieves users based on the search crieria
	public PageReference goSearch()
	{
		sErrMessage='';
		
		if(lstUsers!=null && lstUsers.size()>0)
		{
			lstUsers.clear();
			lstUsers=new List<User>();
		}

		if(Utility.isNull(sSearchText))
		{
			sSearchText='%';
		}
		else
		{
			sSearchText=sSearchText.replace('*','%');
			sSearchText=sSearchText + '%';
		}
		
		sSearchString=sSearchText;
		lstUsers=[SELECT  u.Name, u.FirstName, u.Id, u.LastName, u.Phone, u.MobilePhone, u.Title, u.Email, u.CompanyName, u.UserRoleId, u.UserRole.Name, u.Username, u.City, u.Street, u.State, u.PostalCode, u.Country, u.isActive FROM User u WHERE isActive=true AND (FirstName LIKE :sSearchString OR LastName Like :sSearchString ) and UserType ='Standard' order BY Name LIMIT :iMaxSearch+1 ];
		
		if(lstUsers!=null && lstUsers.size()>iMaxSearch)
		{
			sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
		}
		//sErrMessage='SELECT  u.Name, u.FirstName, u.Id, u.LastName, u.Phone, u.MobilePhone, u.Title, u.Email, u.CompanyName, u.UserRoleId, u.UserRole.Name, u.Username, u.City, u.Street, u.State, u.PostalCode, u.Country, u.isActive FROM User u WHERE isActive=true AND (FirstName LIKE :sSearchString OR LastName Like '+ sSearchString + ')  order BY Name LIMIT ' + iMaxSearch+1;
		
		return null;
	}
	
	//////Starts Getters & Setters///////
	
	
	
}