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
package tavant.twms.web.xls.reader;

import java.util.ArrayList;
import java.util.List;

/**
 * @author vineeth.varghese
 * @date May 31, 2007
 */
public class BlockReaderImpl implements BlockReader {

    List<BeanColumnMapping> beanColumnMappings =
        new ArrayList<BeanColumnMapping>();

    public ConversionResult read(Block block, Object rootObject) {
        ConversionErrors.getInstance().reset();
        ConversionErrors.getInstance().put(ConversionErrors.CLAIM, rootObject);//Super hacks creeping in :)
        for (BeanColumnMapping mapping : beanColumnMappings) {
            if (mapping.isDependentOnAnotherColumn()) {
                mapping.populateWithDependent(rootObject,
                        block.getCellsOfColumn(mapping.getColumn(rootObject)),
                        block.getCellsOfColumn(mapping.getDependsOnDesc()));
            } else {
                mapping.populate(rootObject, block.getCellsOfColumn(mapping.getColumn(rootObject)));
            }
        }
        List<String> errors = new ArrayList<String>();
        errors.addAll(ConversionErrors.getInstance().getErrors());
        return new ConversionResult(rootObject, errors);
    }

    public void addBeanColumnMapping(BeanColumnMapping beanColumnMapping) {
        beanColumnMappings.add(beanColumnMapping);
    }

    List<BeanColumnMapping> getBeanColumnMappings() {
        return beanColumnMappings;
    }

}
