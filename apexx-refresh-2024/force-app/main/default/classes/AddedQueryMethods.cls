public with sharing class AddedQueryMethods {

    public String taint {get; set;}
    public String messaggio {get; set;}
    private MyLittleLogger logger;

    public AddedQueryMethods(){
        logger = new MyLittleLogger();
        logger.log('AddedQueryMethods', ' started');
        messaggio = logger.flush();

    }

    public void runQueryWithBinds() {
        logger.reset();
        Map<String, Object> acctBindsSafe = new Map<String, Object>{'dialog_name' => 'xxx'};
        Map<String, Object> acctBindsTaint = new Map<String, Object>{'dialog_name' => taint};

        List<Dialog__c> dialogsList = Database.query('SELECT NAME from Dialog__c' + taint); // CWEID 943
        Database.queryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name' + taint, acctBindsSafe, AccessLevel.USER_MODE);  // CWEID 943 because of the 1st param being tainted
        Database.queryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name' + taint, acctBindsTaint, AccessLevel.USER_MODE); // CWEID 943 because of the 1st param being tainted
        Database.queryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name', acctBindsSafe, AccessLevel.USER_MODE);          // FP 943 1st param is safe
        Database.queryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name', acctBindsTaint, AccessLevel.USER_MODE);         // FP 943 1st param is safe

        logger.log('runMe', 'query done');
        messaggio = logger.flush();
        
    }

    public void runQueryLocatorWithBinds() {
        logger.reset();
        Map<String, Object> acctBindsSafe = new Map<String, Object>{'dialog_name' => 'ggg'};
        Map<String, Object> acctBindsTaint = new Map<String, Object>{'dialog_name' => taint};

        Database.QueryLocator queryLocator1 = Database.getQueryLocatorWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name' + taint, acctBindsSafe, AccessLevel.USER_MODE); // CWEID 943
        Database.QueryLocator queryLocator2 = Database.getQueryLocatorWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name', acctBindsTaint, AccessLevel.USER_MODE); // FP 943

        Database.query(queryLocator1.getQuery()); // CWEID 943 - The first parameter of the related getQueryLocatorWithBinds is tainted
        Database.query(queryLocator2.getQuery()); // FP 943 - The first parameter of the related getQueryLocatorWithBinds is not tainted

        logger.log('runMe', queryLocator1.getQuery());

        messaggio = logger.flush();
        
    }



    public void runCountQueryWithBinds() {
        logger.reset();
        Map<String, Object> acctBindsSafe = new Map<String, Object>{'dialog_name' => 'ggg'};
        Map<String, Object> acctBindsTaint = new Map<String, Object>{'dialog_name' => taint};

        Database.countQueryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name' + taint, acctBindsSafe, AccessLevel.USER_MODE); // CWEID 943
        Database.countQueryWithBinds('SELECT NAME from Dialog__c where Name = :dialog_name', acctBindsTaint, AccessLevel.USER_MODE); // FP 943

        messaggio = logger.flush();
        
    }


    private class MyLittleLogger {

        private String logMessage;

        public MyLittleLogger() {
            reset();
        }

        public void log(String orig, String msg){
            logMessage += '<tr><td>' + orig + '</td><td>' + msg + '</td></tr>';
        }

        public void log(String msg){
            logMessage += '<tr><td>-</td><td>' + msg + '</td></tr>';
        }

        public String flush(){
            logMessage += '</table>';

            return logMessage;
        }

        public void reset(){
            logMessage = '<table border=1><tr><th>Orig</th><th>Message</th></tr>';
        }
    }
}