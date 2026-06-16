public with sharing class ValidateSoqlQueries {
    
    public List<Lead> leads {get; set;}


    public ValidateSoqlQueries() {
        leads = [SELECT Name FROM Lead WHERE NumberofLocations__c < 130];
    }
}