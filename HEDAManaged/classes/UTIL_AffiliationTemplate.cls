/*
    Copyright (c) 2017, Kyle Schmid
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Kyle Schmid
* @date 2017
* @description Utility class for affiliation templates
*/
public class UTIL_AffiliationTemplate {
    
    /*******************************************************************************************************
    * @description Compares affiliation to an affiliation template to see if they match
    * @param template Affiliation Template to compare to
    * @param affiliation Affiliation to test
    * @return Boolean true if affiliation matches affiliation template
    */
    public static Boolean AffiliationMatches(AffiliationTemplate__c template, hed__Affiliation__c affiliation) {
        
        // Return false if accounts don't match
        if (template.Account__c != affiliation.hed__Account__c)
            return false;
        
        // Return false if template calls for primary and affiliation isn't primary
        if (template.Primary__c && !affiliation.hed__Primary__c)
            return false;
        
        // Return false if template role field doesn't contain affiliation's role
        if (String.isNotBlank(template.Role__c)) {
            Set<String> roles = new Set<String>();
            for (String s:template.Role__c.split(';'))
                roles.add(s.trim());
            if (!roles.contains(affiliation.hed__Role__c))
                return false;
        }
        
        // Return false if template status field doesn't contain affiliation's status
        if (String.isNotBlank(template.Status__c)) {
            Set<String> statuses = new Set<String>();
            for (String s:template.Status__c.split(';'))
                statuses.add(s.trim());
            if (!statuses.contains(affiliation.hed__Status__c))
                return false;
        }
        
        return true; // Return true if false hasn't been returned so far
    }
    
    /*******************************************************************************************************
    * @description Queries contacts based on parameters
    * @param fieldNames Set of field names to include in query
    * @param contactIds Set of Contact record ids to include in query result
    * @return Map<Id, Contact> Map of Contacts with Contact ID as key
    */
    public static Map<Id, Contact> GetContactMap(Set<String> fieldNames, Set<Id> contactIds) {
        
        fieldNames.add('AccountId'); // Make sure AccountId is included
        
        // Build query
        String query = 'SELECT ';
        for (String f:fieldNames)
            query += (f + ', ');
        query += 'Id FROM Contact WHERE Id IN :contactIds';
        
        // Query and return map
        return new Map<Id, Contact>((List<Contact>)Database.query(query));
    }
    
    /*******************************************************************************************************
    * @description Queries administrative accounts based on parameters
    * @param fieldNames Set of field names to include in query
    * @param accountIds Set of Account record ids to include in query result
    * @return Map<Id, Account> Map of Accounts with Account ID as key
    */
    public static Map<Id, Account> GetAdminAccountMap(Set<String> fieldNames, Set<Id> accountIds) {
        
        if (fieldNames.isEmpty()) return new Map<Id, Account>(); // Return empty map if no fields to query
        
        // Build query
        String query = 'SELECT ';
        for (String f:fieldNames)
            query += (f + ', ');
        query += 'Id FROM Account WHERE Id IN :accountIds';
        
        // Query and return map
        return new Map<Id, Account>((List<Account>)Database.query(query));
    }
    
    /*******************************************************************************************************
    * @description Inserts trigger handlers for affiliation templates
    * @return void
    */
    public static void CreateTriggerHandlers() {
        List<hed__Trigger_Handler__c> handlers = new List<hed__Trigger_Handler__c>();
        
        handlers.add(new hed__Trigger_Handler__c(hed__Active__c = true, hed__Asynchronous__c = false,
            hed__Class__c = 'AFFL_Template_TDTM', hed__Load_Order__c = 5, hed__Object__c = 'Affiliation__c',
            hed__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', hed__User_Managed__c = true));
        
        handlers.add(new hed__Trigger_Handler__c(hed__Active__c = true, hed__Asynchronous__c = false,
            hed__Class__c = 'AFFLTMP_Template_TDTM', hed__Load_Order__c = 1, hed__Object__c = 'AffiliationTemplate__c',
            hed__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', hed__User_Managed__c = true));
        
        insert handlers;
    }
}
