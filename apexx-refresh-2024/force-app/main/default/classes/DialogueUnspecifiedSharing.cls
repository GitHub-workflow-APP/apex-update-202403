public class DialogueUnspecifiedSharing {


    @AuraEnabled
    public static List<Dialog__c> getDialogues() {
        
        System.debug('getDialogues called');

        try {
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c WITH USER_MODE]; // FP 284

            System.debug('dialogues retrieved: ' + dialogues.size());

            return dialogues;
        } catch (Exception e) {
            System.debug('dialogues error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Dialog__c> getDialogues2() {
        
        System.debug('getDialogues called');

        try {
            // AuraEnabled methods default to WITH_SHARING when no sharing condition is specified at class level
            // from release Spring '21. Before Spring'21 they were defaulting to no sharing.
            // FLS are still a possible issue, that is why we still have CWE 274
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c]; // CWE 274

            System.debug('dialogues retrieved: ' + dialogues.size());

            return dialogues;
        } catch (Exception e) {
            System.debug('dialogues error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Dialog__c> getDialogues3() {
        
        System.debug('getDialogues called');

        try {
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c WITH SYSTEM_MODE] ; // CWE 284

            System.debug('dialogues retrieved: ' + dialogues.size());

            return dialogues;
        } catch (Exception e) {
            System.debug('dialogues error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}