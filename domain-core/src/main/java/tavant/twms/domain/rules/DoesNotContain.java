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
 * Date: Apr 26, 2007
 * Time: 1:02:57 PM
 */

package tavant.twms.domain.rules;


/**
 * @author <a href="mailto:vikas.sasidharan@tavant.com>Vikas Sasidharan</a>
 *
 */
public class DoesNotContain implements BinaryPredicate {
    
    Value lhs;
    Value rhs;

    public DoesNotContain() {
        super();
    }

    public DoesNotContain(Value lhs, Value rhs) {
        super();
        this.lhs = lhs;
        this.rhs = rhs;
    }

    public void accept(Visitor visitor) {
        visitor.visit(this);
    }

    public void validate(ValidationContext validationContext) {
        if( lhs==null) {
            validationContext.addError("lhs is null");
        }
        if( rhs==null) {
            validationContext.addError("rhs is null");
        }
        if( lhs!=null && rhs!=null && lhs.getType().equals(Type.STRING) &&
                lhs.getType().equals(rhs.getType()) ) {
            validationContext.addError(" lhs and rhs are not of same type ");
        }
    }

    public String getDomainTerm() {
        return "label.operators.doesNotContain";
    }

    public Value getLhs() {
        return lhs;
    }

    public void setLhs(Value lhs) {
        this.lhs = lhs;
    }

    public Value getRhs() {
        return rhs;
    }

    public void setRhs(Value rhs) {
        this.rhs = rhs;
    }
    
    public Predicate getInverse() {
		return new Contains(lhs,rhs);
	}
}