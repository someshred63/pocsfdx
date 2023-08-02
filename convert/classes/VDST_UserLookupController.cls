/** @date 7/27/2013
* @Author Paweł Sprysak
* @description User Lookup controller
*/
public without sharing class VDST_UserLookupController {
    public User usr               { get; set; }
    public List<User> results     { get; set; }
    public String searchString    { get; set; }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description VDST_Users_Management constructor
    */
    public VDST_UserLookupController() {
        usr = new User();
        searchString = System.currentPageReference().getParameters().get('lksrch');
        runSearch();
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Search method
    * @return PageReference
    */
    public PageReference search() {
        runSearch();
        return null;
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Run Search method
    */
    private void runSearch() {
        results = performSearch(searchString);
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Perform Search by String value method
    * @param String searchString
    * @return List<User>
    */
    private List<User> performSearch(String searchString) {
        String soql = 'SELECT Id, Username, Name, Title, Phone, Email, Profile.Name FROM User';
        if(searchString != '' && searchString != null)
            soql = soql +  ' WHERE Name LIKE \'%' + searchString +'%\'';
        soql = soql + ' LIMIT 25';
        System.debug('---------- ' + soql);
        return database.query(soql);
    }

    /* @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Get Form Tag parameter
    * @return String
    */
    public String getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }

    /* @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Get Text Box parameter
    * @return String
    */
    public String getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
}