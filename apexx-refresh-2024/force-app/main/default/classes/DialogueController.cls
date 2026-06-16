public with sharing class DialogueController {


    @AuraEnabled
    public static List<Dialog__c> getDialogues() {
        
        System.debug('getDialogues called');

        try {
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c WITH USER_MODE];  // FP 284

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
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c]; // FP 284

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
            List<Dialog__c> dialogues = [SELECT Id, Name, Message__c FROM Dialog__c WITH SYSTEM_MODE] ; // CWE 284 System mode overrides "with sharing"

            System.debug('dialogues retrieved: ' + dialogues.size());

            return dialogues;
        } catch (Exception e) {
            System.debug('dialogues error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}