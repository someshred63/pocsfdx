public without sharing class AGS_ST_User {
    public String firstName { get; set; }
    public String initial { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String email2 { get; set; }
    public String phone { get; set; }
    public String npi { get; set; }
    public String stateLicence { get; set; }
    public String licenceStateCode { get; set; }
    public String street { get; set; }
    public String suite { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String dob { get; set; }
    public String gender { get; set; }
    public String ssn { get; set; }
    public String speciality { get; set; }

    public List<SelectOption> genderList {
        public get {

            List<SelectOption> tmp = new List<SelectOption>();
            tmp.clear();
            tmp.add(new SelectOption('', ''));
            tmp.add(new SelectOption('M', 'M'));
            tmp.add(new SelectOption('F', 'F'));
            tmp.add(new SelectOption('U', 'U'));
            return tmp;
        }
        set;
    }
    public void trimData() {
        this.firstName = trimStr(this.firstName);
        this.initial = trimStr(this.initial);
        this.lastName = trimStr(this.lastName);
        this.email = trimStr(this.email);
        this.email2 = trimStr(this.email2);
        this.phone = trimStr(this.phone);
        this.npi = trimStr(this.npi);
        this.stateLicence = trimStr(this.stateLicence);
        this.licenceStateCode = trimStr(this.licenceStateCode);
        this.street = trimStr(this.street);
        this.suite = trimStr(this.suite);
        this.city = trimStr(this.city);
        this.state = trimStr(this.state);
        this.zip = trimStr(this.zip);
        this.dob = trimStr(this.dob);
        this.gender = trimStr(this.gender);
        this.ssn = trimStr(this.ssn);
    }

    private String trimStr(String s) {
        if (s == null) {
            return null;
        }
        return s.trim();
    }
}