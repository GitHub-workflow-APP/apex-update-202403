public without sharing class ValidateSoqlQueriesNoSharing {
    public List<Lead> leads {get; set;}

    public ValidateSoqlQueriesNoSharing() {
        leads = [SELECT Name FROM Lead WHERE NumberofLocations__c < 130]; // CWE 284

    }
}