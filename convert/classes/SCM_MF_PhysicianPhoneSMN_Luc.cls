// Added by Reji Joseph

public class SCM_MF_PhysicianPhoneSMN_Luc extends SCM_MF_ContactCollectionSMN_Luc {

  public SCM_MF_PhysicianPhoneSMN_Luc(String AccountId, String CaseType)
  {
    super(AccountId, CaseType);
    key = 'Phy_Ph';
  }
   
  public override String getFieldValue()
  {    
    if (contactDetails != null && contactDetails.Phone != null)
        return contactDetails.Phone;
    else
        return 'T';
  }
}