package tavant.twms.domain.claim.payment.rates;

import tavant.twms.domain.catalog.CatalogService;
import tavant.twms.domain.catalog.ItemGroup;
import tavant.twms.domain.claim.Criteria;
import tavant.twms.domain.orgmodel.DealerCriterion;
import tavant.twms.domain.orgmodel.OrgService;
import tavant.twms.infra.DomainRepositoryTestCase;

public class TravelRatesAdminServiceImplTest extends DomainRepositoryTestCase {

    public TravelRatesAdminService travelRatesAdminService;

    private OrgService orgService;
    private CatalogService catalogService;

    public void setTravelRatesAdminService(TravelRatesAdminService travelRatesAdminService) {
        this.travelRatesAdminService = travelRatesAdminService;
    }

    public void setCatalogService(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    public void setOrgService(OrgService orgService) {
        this.orgService = orgService;
    }

    public void testIsUniqueWithClaimTypeSet() {
        Criteria forCriteria = new Criteria();
        forCriteria.setClaimType("Machine");
        TravelRates example = new TravelRates();
        example.setForCriteria(forCriteria);
        assertFalse(travelRatesAdminService.isUnique(example));
    }

    public void testIsUniqueWithAllCriteriaElements() {
        Criteria forCriteria = new Criteria();
        forCriteria.setClaimType("Machine");
        forCriteria.setWarrantyType("STANDARD");

        DealerCriterion dealerCriterion = new DealerCriterion(orgService.findDealerById(7L));
        forCriteria.setDealerCriterion(dealerCriterion);

        ItemGroup productType = catalogService.findItemGroup(5L);
        forCriteria.setProductType(productType);

        TravelRates example = new TravelRates();
        example.setForCriteria(forCriteria);
        assertFalse(travelRatesAdminService.isUnique(example));
    }

    public void testIsUniqueWithNewCriteria() {
        Criteria forCriteria = new Criteria();
        forCriteria.setWarrantyType("STANDARD");

        DealerCriterion dealerCriterion = new DealerCriterion(orgService.findDealerById(20L));
        forCriteria.setDealerCriterion(dealerCriterion);

        ItemGroup productType = catalogService.findItemGroup(6L);
        forCriteria.setProductType(productType);

        TravelRates example = new TravelRates();
        example.setForCriteria(forCriteria);
        assertTrue(travelRatesAdminService.isUnique(example));
    }
}