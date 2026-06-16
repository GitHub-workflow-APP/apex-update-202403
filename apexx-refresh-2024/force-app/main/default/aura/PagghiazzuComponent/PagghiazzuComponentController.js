({
    init : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Owner', fieldName:'OwnerId.Id', type: 'text'},
            {label: 'Pagghiazzu Name', fieldName: 'Name', type: 'text'},
            {label: 'Color', fieldName:'Color__c', type: 'text'},
            {label: 'Hidden To All', fieldName:'HiddenToAll__c', type: 'text'}
        ]);
        helper.getData(component);
    }
})
