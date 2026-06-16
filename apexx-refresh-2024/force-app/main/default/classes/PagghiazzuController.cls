public without sharing class PagghiazzuController {

    @AuraEnabled
    public static List<Pagghiazzu__c> getPagghiazzi() {
        try {
            // AuraEnabled methods default to WITH_SHARING ONLY when no sharing condition is specified at class level
            return [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c]; // CWE 284
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}