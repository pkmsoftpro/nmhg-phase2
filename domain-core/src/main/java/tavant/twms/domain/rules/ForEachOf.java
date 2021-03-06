/*
 *   Copyright (c)2007 Tavant Technologies
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
package tavant.twms.domain.rules;


import com.thoughtworks.xstream.annotations.XStreamAlias;

/**
 * @author radhakrishnan.j
 *
 */
@XStreamAlias("forEach")
public class ForEachOf extends AbstractCollectionUnaryPredicate {

    public ForEachOf() {
    }
    
    public ForEachOf(DomainSpecificVariable collectionValuedVariable,
                     Predicate conditionToBeSatisfied) {
        super(collectionValuedVariable, conditionToBeSatisfied);
    }

    @Override    
    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
    
    @Override    
    public String getDomainTerm() {
        return " label.operators.forEach ";
    }
    
    public Predicate getInverse() {
    	return new ForAnyOf(collectionValuedVariable,conditionToBeSatisfied.getInverse());	
    }
}
