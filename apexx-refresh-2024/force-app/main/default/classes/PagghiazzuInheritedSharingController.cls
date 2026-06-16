public inherited sharing class PagghiazzuInheritedSharingController {

    @AuraEnabled
    public static List<Pagghiazzu__c> getPagghiazzi() {
        try {
            // AuraEnabled methods default to WITH_SHARING when no sharing condition is specified at class level
            // from release Spring '21. BEfore Spring'21 they were defaulting to no sharing.
            List<Pagghiazzu__c> p = [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c with USER_MODE];     // FP 284
            List<Pagghiazzu__c> p2 = [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c with SYSTEM_MODE];  // CWE 284
            return [SELECT Id, Name, Color__c, OwnerId FROM Pagghiazzu__c];                                     // CWE 274
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}