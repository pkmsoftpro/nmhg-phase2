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
package tavant.twms.infra;

import java.io.IOException;
import java.sql.SQLException;

import org.dbunit.DatabaseUnitException;
import org.dbunit.dataset.DataSetException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.orm.hibernate3.SessionFactoryUtils;
import org.springframework.test.AbstractTransactionalDataSourceSpringContextTests;

import tavant.twms.security.SecurityHelper;

public abstract class DomainRepositoryTestCase extends
		AbstractTransactionalDataSourceSpringContextTests {

	SessionFactory sessionFactory;
	private SecurityHelper securityHelper = new SecurityHelper();
	/**
     * Overrides and delegates the real setup to the
     * {@link #setUpInTxnRollbackOnFailure()} method. Does a rollback of the
     * transaction if the delegate method returns abnormally.
     */
    @Override
    public final void onSetUpInTransaction() throws Exception {
        super.onSetUpInTransaction();
        try {
            setUpInTxnRollbackOnFailure();
        } catch (Throwable t) {
            logger.error(this.getClass().getName() + 
                    ".setUpInTxnRollbackOnFailure() returned abnormally. "
                    + "Rolling back txn to avoid side-effects.", t);
        }

    }

    /**
     * A safe method for performing setup operations. Test writers are
     * encounraged to use this API instead of the
     * 
     * @throws DatabaseUnitException
     * @throws SQLException
     * @throws IOException
     * @throws DataSetException
     */
    protected void setUpInTxnRollbackOnFailure() throws Exception {
    	/*
    	 * TODO: This is not the right way to do it.
    	 * Security helper is a class which is currently used in the service layer
    	 * it should not contain methods which specify setting up of default attributes
    	 * that needs to be populated for test cases. Will be moving the setting of security context
    	 * to this method and will remove the doDefaultAuthetication.
    	 */ 
        securityHelper.doDefaultAuthentication();
    }
    
	@Override
	public String[] getConfigLocations() {
		return new String[] { "classpath:unittest-env-context.xml", 
				"classpath:test-context.xml" ,
				"classpath*:/app-context.xml"};
	}

	@Required
	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}
	
	protected void flush() {
        Session session = getSession();
        session.flush();
    }    
    
    protected void evict(Object someObject) {
        Session session = getSession();
        session.evict(someObject);
    }    
    
    protected void flushAndClear() {
        Session session = getSession();
        session.flush();
        session.clear();
    }

    protected Session getSession() {
        return SessionFactoryUtils.getSession(sessionFactory, false);
    }
}
