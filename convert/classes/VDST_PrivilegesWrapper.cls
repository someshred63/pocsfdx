/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Base Privileges Wrapper class
*/
public virtual class VDST_PrivilegesWrapper {
    public String                                             userRole         { get; set; }
    public Id                                                 providerId       { get; set; }
    public String                                             providerName     { get; set; }
    public String                                             providerCode     { get; set; }
    public String                                             providerFullName { get; set; }
    public Boolean                                            hasPrivileges    { get; set; }
    public Boolean                                            isProxy          { get; set; }
    public Boolean                                            isProvisioner {
        get {
            if(VDST_Utils.PROVISIONER_NAME.equals(userRole)) {
                return true;
            } else {
                return false;
            }
        }
    }
    public Boolean                                            isGene {
        get {
            if(VDST_Utils.GENENTECH_CODE.equals(providerCode)) {
                return true;
            } else {
                return false;
            }
        }
    }
}