public class ValidateSoqlQueriesUndefSharing {

    public List<Lead> leads {get; set;}

    public ValidateSoqlQueriesUndefSharing() {
        leads = [SELECT Name FROM Lead WHERE NumberofLocations__c < 130]; // CWE 284
    }

}
