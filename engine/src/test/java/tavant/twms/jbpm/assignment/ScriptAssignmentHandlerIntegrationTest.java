/*
 *   Copyright (c)2006 Tavant Technologies
 *   All Rights Reserved.
 *
 *   This software is furnished under a license and may be used and copied
 *   only  in  accordance  with  the  terms  of such  license and with the
 *   inclusion of the above copyright notice. This software or  any  other
 *   copies thereof may not be provided or otherwise made available to any
 *   other person. No title to and ownership of  the  software  is  hereby
 *   transferred.
 *
 *   The information in this software is subject to change without  notice
 *   and  should  not be  construed as a commitment  by Tavant Technologies.
 */
package tavant.twms.jbpm.assignment;

import org.jbpm.graph.def.ProcessDefinition;
import org.jbpm.graph.exe.ProcessInstance;
import org.jbpm.taskmgmt.exe.TaskInstance;

import tavant.twms.infra.ProcessDeployableTestCase;

/**
 * 
 * @author kannan.ekanath
 *
 */
public class ScriptAssignmentHandlerIntegrationTest extends ProcessDeployableTestCase {

	ProcessInstance processInstance;
	
	@Override
	protected void setUpInTxnRollbackOnFailure() throws Exception {
		super.setUpInTxnRollbackOnFailure();
		ProcessDefinition processDefinition = deployProcess("script-based-assignment-process.xml");
		processInstance = new ProcessInstance(processDefinition);
	}
	
	public void testScriptAssignment() {
		processInstance.signal();
		//it must have stopped at the task with swimlane
		TaskInstance taskInstance = (TaskInstance) processInstance
				.getTaskMgmtInstance().getTaskInstances().iterator().next();
		assertEquals("twms-admin@tavant.com", taskInstance.getActorId());
	}
	

}
