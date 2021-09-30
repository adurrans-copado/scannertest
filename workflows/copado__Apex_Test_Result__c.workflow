<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Apex_Test_Result</fullName>
        <description>Send Apex Test Result</description>
        <protected>false</protected>
        <recipients>
            <recipient>adurrans-runa@force.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>copado__Copado_Deployer/copado__NewApexTestResultSummary</template>
    </alerts>
    <rules>
        <fullName>Send Apex Test Result</fullName>
        <actions>
            <name>Send_Apex_Test_Result</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Generates an email which will send the results of Apex Test Runs any time a new Apex Test Result record is created (i.e. triggered from OC [scheduled or manual])</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
