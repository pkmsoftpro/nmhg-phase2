package tavant.twms.taglib.treeTable;

import com.opensymphony.xwork2.util.ValueStack;
import org.apache.struts2.components.ClosingUIBean;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author : janmejay.singh
 * Date : Jun 12, 2007
 * Time : 12:15:08 PM
 */
public class DropButton extends ClosingUIBean {

    public static final String TEMPLATE = "treeDropButton-close",
                               OPEN_TEMPLATE = "treeDropButton";

    private String identifierCssClass;

    protected DropButton(ValueStack valueStack, HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) {
        super(valueStack, httpServletRequest, httpServletResponse);
    }

    @Override
    protected void evaluateExtraParams() {
        super.evaluateExtraParams();
        addParameter("identifierCssClass", findString(identifierCssClass));
    }

    public String getDefaultOpenTemplate() {
        return OPEN_TEMPLATE;
    }

    protected String getDefaultTemplate() {
        return TEMPLATE;
    }

    public void setIdentifierCssClass(String identifierCssClass) {
        this.identifierCssClass = identifierCssClass;
    }
}
