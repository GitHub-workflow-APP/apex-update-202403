public with sharing class PagghiazzuWithSharingController {

    @AuraEnabled
    public static List<Pagghiazzu__c> getPagghiazzi() {
        try {
            // AuraEnabled methods default to WITH_SHARING when no sharing condition is specified at class level
            // from release Spring '21. Before Spring'21 they were defaulting to no sharing.
            // In this example the class is specifying "with sharing", in which case "with sharing" is enforced
            List<Pagghiazzu__c> p = [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c with USER_MODE]; // FP
            List<Pagghiazzu__c> p2 = [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c with SYSTEM_MODE]; // CWE 284
            return [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c]; // CWE 274
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}