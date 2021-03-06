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

/**
 * User: <a href="mailto:vikas.sasidharan@tavant.com>Vikas Sasidharan</a>
 * Date: May 4, 2007
 * Time: 5:30:46 PM
 */

package tavant.twms.domain.rules;

import javax.persistence.Entity;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;

/**
 * @author <a href="mailto:vikas.sasidharan@tavant.com>Vikas Sasidharan</a>
 *
 */
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public class IsWithinNext extends AbstractDateDurationPredicate {

    public IsWithinNext(DomainSpecificVariable oneValue, Constant anotherValue,
                      int durationType) {
        super(oneValue, anotherValue, durationType);
    }

    public IsWithinNext(DomainSpecificVariable oneValue,
			DomainSpecificVariable dateToCompare, Constant anotherValue,
			int durationType) {
		super(oneValue, dateToCompare, anotherValue, durationType);
	}
    
    public IsWithinNext() {
    }

    public String getDomainTerm() {
        return "label.operators.isWithinNext";
    }

    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
    
    public BinaryPredicate getInverse() {
		return new IsNotWithinNext(lhs, dateToCompare, rhs, durationType);
	}
}
