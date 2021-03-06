<?xml version="1.0"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
               xmlns:xsd="http://www.w3.org/1999/XMLSchema"
               xmlns:fo="http://www.w3.org/1999/XSL/Format"
               xmlns:fox="http://xml.apache.org/fop/extensions" xmlns:ssl="http://www.w3.org/1999/XSL/Transform"
               xmlns:Locale="java.util.Locale"
               xmlns:java="java">

    <xsl:variable name="language" select="shipmentTag/language"/>
    <xsl:variable name="bu" select="shipmentTag/businessUnit"/>
    <xsl:variable name="locale" select="Locale:new($language, '', $bu)"/>
    <xsl:variable name="resources"
                  select="java:util.ResourceBundle.getBundle('messages', $locale)"/>
    <xsl:output method="xml"/>

    <xsl:template name="emptyLine">
        <xsl:param name="numberOfCloumns"/>
        <fo:table-row>
            <fo:table-cell number-columns-spanned="$numberOfCloumns">
                <fo:block line-height="10pt" font-family="arial" font-size="8pt" space-before.optimum="1.5pt"
                          space-after.optimum="1.5pt"
                          keep-together="auto" text-align="start">
                    <fo:leader end-indent="0cm" start-indent="0cm" space-after.optimum="0pt"
                               space-before.optimum="0pt"
                               rule-thickness="0pt" leader-pattern="rule"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <!--<xsl:template name="displayPartDetail">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <fo:table border="solid 0.5px black" border-width="100%" table-layout="fixed" text-align="start">
                        <fo:table-column column-width="2.88cm"/>
                        <fo:table-column column-width="16cm"/>
                        <fo:table-body>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="20pt">
                                    <fo:block>
                                        <fo:external-graphic src="url(servlet-context:/image/logo_NMHG.gif)"
                                                             content-height="scale-to-fit" height="0.30in"
                                                             content-width="0.5in" scaling="non-uniform" left="50pt"/>

                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="start">
                                    <fo:block>
                                        <fo:inline font-size="22pt" font-weight="bold" text-decoration="underline"
                                                   left="25px">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.warrantyPartReturnTag')"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <fo:table-row>
                                <fo:table-cell  padding-start="0.5cm" number-columns-spanned="2" width="80%" padding-end="0.5cm">
                                    <fo:block border="solid 0.5px black">
                                        <fo:inline font-size="12pt" font-weight="normal">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.warrantyPartReturnTagMessages')"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm" number-columns-spanned="2"
                                               width="40%">&lt;!&ndash; Part Details, Receiver Instructions and claim comments goes here &ndash;&gt;
                                    <fo:table>
                                        <fo:table-column column-width="7cm"/>
                                        <fo:table-column column-width="12cm"/>
                                        <fo:table-body>
                                            <fo:table-cell>
                                                <fo:block font-family="sans-seriff">
                                                    <fo:table>
                                                        <fo:table-body>
                                                            <fo:table-row>&lt;!&ndash; Part Details row &ndash;&gt;
                                                                <fo:table-cell>
                                                                    <fo:block border="solid 0.5px black">
                                                                        <fo:table>&lt;!&ndash; Part Details table &ndash;&gt;
                                                                            <fo:table-body>
                                                                                <xsl:call-template name="emptyLine">
                                                                                    <xsl:with-param
                                                                                            name="numberOfCloumns"
                                                                                            select="'1'"/>
                                                                                </xsl:call-template>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell padding-start="5pt">
                                                                                        <fo:block font-weight="bold">
                                                                                            <fo:inline font-size="12pt"
                                                                                                    >
                                                                                                <xsl:value-of
                                                                                                        select="java:getString($resources,'label.common.partNumber')"/>:
                                                                                            </fo:inline>
                                                                                            <fo:inline font-size="18pt">
                                                                                                <xsl:value-of
                                                                                                        select="part/partNumber"/>
                                                                                            </fo:inline>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell>
                                                                                        <fo:block>
                                                                                            <fo:leader
                                                                                                    leader-length="100%"
                                                                                                    leader-pattern="space">
                                                                                                &#x00A0;</fo:leader>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell padding-start="5pt">
                                                                                        <fo:block font-size="12pt">
                                                                                            <fo:inline
                                                                                                    font-weight="bold">
                                                                                                <xsl:value-of
                                                                                                        select="java:getString($resources,'label.common.description')"/>:
                                                                                            </fo:inline>
                                                                                            <fo:inline>
                                                                                                <xsl:value-of
                                                                                                        select="part/description"/>
                                                                                            </fo:inline>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell>
                                                                                        <fo:block>
                                                                                            <fo:leader
                                                                                                    leader-length="100%"
                                                                                                    leader-pattern="space">
                                                                                                &#x00A0;</fo:leader>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell padding-start="5pt">
                                                                                        <fo:block font-size="12pt"
                                                                                                  font-weight="bold">
                                                                                            <fo:inline>
                                                                                                <xsl:value-of
                                                                                                        select="java:getString($resources,'label.partShipmentTag.returnDueDate')"/>:
                                                                                            </fo:inline>
                                                                                            <fo:inline>
                                                                                                <xsl:value-of
                                                                                                        select="part/dueDate/month"/>/<xsl:value-of
                                                                                                    select="part/dueDate/day"/>/<xsl:value-of
                                                                                                    select="part/dueDate/year"/>
                                                                                            </fo:inline>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <fo:table-row>
                                                                                    <fo:table-cell padding-start="5pt">
                                                                                        <fo:block font-size="12pt"
                                                                                                  font-weight="bold">
                                                                                            <fo:inline>
                                                                                                <xsl:value-of
                                                                                                        select="java:getString($resources,'label.warrantyAdmin.failureDate')"/>:
                                                                                            </fo:inline>
                                                                                            <fo:inline>
                                                                                                <xsl:value-of
                                                                                                        select="claim/failureDate/month"/>/<xsl:value-of
                                                                                                    select="claim/failureDate/day"/>/<xsl:value-of
                                                                                                    select="claim/failureDate/year"/>
                                                                                            </fo:inline>
                                                                                        </fo:block>
                                                                                    </fo:table-cell>
                                                                                </fo:table-row>
                                                                                <xsl:call-template name="emptyLine">
                                                                                    <xsl:with-param
                                                                                            name="numberOfCloumns" select="'1'"/>
                                                                                </xsl:call-template>
                                                                            </fo:table-body>
                                                                        </fo:table>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="11pt" font-weight="bold">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.partReturnConfiguration.receiverInstructions')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="10pt">
                                                                            <xsl:value-of
                                                                                    select="part/receiverInstructions"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="12pt" font-weight="bold"
                                                                                   text-decoration="underline">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.partShipmentTag.claimComments')"/>:
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="11pt" font-weight="bold">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.partShipmentTag.fault')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="10pt">
                                                                            <xsl:value-of select="claim/fault"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="11pt" font-weight="bold">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.partShipmentTag.cause')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="10pt">
                                                                            <xsl:value-of select="claim/cause"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="11pt" font-weight="bold">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.newClaim.workPerformed')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="10pt">
                                                                            <xsl:value-of select="claim/workPerformed"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:inline font-size="11pt" font-weight="bold">
                                                                            <xsl:value-of
                                                                                    select="java:getString($resources,'label.partShipmentTag.additionalNotes')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="10pt">
                                                                            <xsl:value-of
                                                                                    select="claim/additionalNotes"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                        </fo:table-body>
                                                    </fo:table>
                                                </fo:block>
                                            </fo:table-cell>
                                            <fo:table-cell text-align="end"
                                                           padding-end="1cm">&lt;!&ndash; claim number, rma number goes here &ndash;&gt;
                                                <fo:block>
                                                    <fo:table>
                                                        <fo:table-body>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block font-weight="bold">
                                                                        <fo:inline font-size="12pt"><xsl:value-of
                                                                                select="java:getString($resources,'columnTitle.common.claimNo')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="22pt"
                                                                                   text-decoration="underline">
                                                                            <xsl:value-of select="claim/claimNumber"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block font-weight="bold">
                                                                        <fo:inline font-size="12pt"><xsl:value-of
                                                                                select="java:getString($resources,'label.partReturnConfiguration.rmaNumber')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="22pt"
                                                                                   text-decoration="underline">
                                                                            <xsl:value-of select="part/rmaNumber"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block font-weight="bold">
                                                                        <fo:inline font-size="12pt"><xsl:value-of
                                                                                select="java:getString($resources,'label.partShipmentTag.machineSerialNo')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="14pt">
                                                                            <xsl:value-of
                                                                                    select="claim/machineSerialNumber"/>
                                                                        </fo:inline>


                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block font-weight="bold">
                                                                        <fo:inline font-size="12pt"><xsl:value-of
                                                                                select="java:getString($resources,'columnTitle.common.model')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="14pt">
                                                                            <xsl:value-of select="claim/model"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>


                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block>
                                                                        <fo:leader leader-length="100%"
                                                                                   leader-pattern="space">
                                                                            &#x00A0;</fo:leader>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                            <fo:table-row>
                                                                <fo:table-cell>
                                                                    <fo:block font-weight="bold">
                                                                        <fo:inline font-size="12pt"><xsl:value-of
                                                                                select="java:getString($resources,'label.inboxView.workOrderNumber')"/>:
                                                                        </fo:inline>
                                                                        <fo:inline font-size="14pt">
                                                                            <xsl:value-of
                                                                                    select="claim/workOrderNumber"/>
                                                                        </fo:inline>
                                                                    </fo:block>
                                                                </fo:table-cell>
                                                            </fo:table-row>
                                                        </fo:table-body>
                                                    </fo:table>
                                                </fo:block>
                                            </fo:table-cell>
                                        </fo:table-body>
                                    </fo:table>

                                </fo:table-cell>

                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
                <fo:block>
                    <fo:leader leader-pattern="space" leader-length="230pt"
                               border="solid 0.1px blue"/>
                    <fo:inline text-align="center" font-style="italic"
                               font-size="6pt">
                        <xsl:value-of select="java:getString($resources,'label.partShipmentTag.cutAlongLine')"/>
                    </fo:inline>
                    <fo:leader leader-pattern="space" leader-length="200pt"
                               border="solid 0.1px blue"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>-->

   <!-- <xsl:template name="displayWarrantySummery">
        <fo:table-row>
            <fo:table-cell>
                <fo:block page-break-after="always">
                    <fo:table border="solid 0.5px black" border-width="100%" table-layout="fixed" text-align="start">
                        <fo:table-column column-width="8.88cm"/>
                        <fo:table-column column-width="10cm"/>
                        <fo:table-body>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.supplier.requestdate')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            request date
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.dealerinfo')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt"> dealer info  </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.problem.desc')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            problem desc
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.problemPartNumber')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            problem part number
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.vendorPartNumber')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            vendor part number
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.hour.meter')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            hour meter
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'1'"/>
                            </xsl:call-template>
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm">
                                    <fo:block>
                                        <fo:inline font-size="11pt" font-weight="bold">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.installDate')"/>:
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell padding-start="0.1cm">
                                    <fo:block>
                                        <fo:inline font-size="10pt">
                                            install date
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <fo:inline text-align="center" font-style="italic" padding-start="2cm" font-size="6pt">
                        <xsl:value-of select="java:getString($resources,'label.partShipmentTag.footermsg')"/>
                    </fo:inline>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>-->

    <xsl:template name="pageLayout">
        <fo:layout-master-set>
            <fo:simple-page-master master-name="page">
                <fo:region-body region-name="body" margin-top="0.5in"
                                margin-bottom="1in" margin-left="0.5in" margin-right="0.5in"
                                background-image="watermark.png" background-repeat="no-repeat"
                                background-position-horizontal="left"
                                background-position-vertical="top"/>
            </fo:simple-page-master>
        </fo:layout-master-set>

    </xsl:template>

    <xsl:template name="displayShipmentTag">
        <fo:table-row>
            <fo:table-cell>
                <fo:block font-family="arial">
                    <!-- warranty parts return table starts  -->
                    <fo:table border="solid 0.5px black" border-width="100%" table-layout="fixed" text-align="start">
                        <fo:table-column column-width="4.88cm"/>
                        <fo:table-column column-width="14cm"/>
                        <fo:table-body>
                         <xsl:if test="$bu='EMEA'">
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
                             
                            <fo:table-row>
                                <fo:table-cell padding-start="15pt">
                                    <fo:block>
                                    <xsl:if test="partDetails/partDetail/claim/brand= 'YALE'"> 
                                        <fo:external-graphic src="url(servlet-context:/image/Yale_Header.jpg)"
                                              content-width="1.5in"/>
                                     </xsl:if>
                                     <xsl:if test="partDetails/partDetail/claim/brand= 'HYSTER'"> 
                                        <fo:external-graphic src="url(servlet-context:/image/Hyster_Header.jpg)"
                                          />
                                     </xsl:if>  
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell display-align="center" margin-left="10pt" padding-left="33pt">
                                    <fo:block>
                                        <fo:inline font-family="arial" font-size="26pt" font-weight="bold" text-decoration="underline"
                                                   >
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.shipmentTag')"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                          
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
				     </xsl:if>
				      <xsl:if test="$bu='AMER'">
				               <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
                             
                            <fo:table-row>
                                <fo:table-cell padding-start="15pt">
                                     <fo:block>
                                        <fo:external-graphic src="url(servlet-context:/image/logo_NMHG.gif)"
                                                             content-height="scale-to-fit" height="0.30in"
                                                             content-width="1.5in" scaling="non-uniform" left="50pt"/>

                                    </fo:block>                                    
                                </fo:table-cell>
                                <fo:table-cell display-align="center" margin-left="10pt" padding-left="33pt">
                                    <fo:block>
                                        <fo:inline font-family="arial" font-size="26pt" font-weight="bold" text-decoration="underline"
                                                   >
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.shipmentTag')"/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                          
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'2'"/>
                            </xsl:call-template>
				      </xsl:if>
				     
                            <fo:table-row>
                                <fo:table-cell padding-start="0.5cm" number-columns-spanned="2"
                                               width="40%">
                                    <fo:block font-family="arial">
                                        <fo:table>
                                            <fo:table-column column-width="7cm"/>
                                            <fo:table-column column-width="3cm"/>
                                            <fo:table-column column-width="8cm"/>
                                            <!-- from and sender comments goes here -->
                                            <fo:table-body>
                                                <fo:table-row>
                                                    <fo:table-cell  >
                                                        <fo:block>
                                                            <fo:table><!-- from table -->
                                                                <fo:table-body>
                                                                    <fo:table-row>
                                                                        <fo:table-cell >
                                                                            <fo:block border="solid 0.5px black">
                                                                                <fo:table>
                                                                                    <fo:table-body>
                                                                                        <xsl:call-template name="emptyLine">
                                                                                            <xsl:with-param name="numberOfCloumns" select="'1'"/>
                                                                                        </xsl:call-template>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell text-align="center">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold"
                                                                                                            text-decoration="underline"
                                                                                                            >
                                                                                                        <xsl:value-of
                                                                                                                select="java:getString($resources,'label.common.from')"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell>
                                                                                                <fo:block>
                                                                                                    <fo:leader
                                                                                                            leader-length="100%"
                                                                                                            leader-pattern="space">
                                                                                                        &#x00A0;</fo:leader>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block font-size="10pt"
                                                                                                          font-weight="bold">
                                                                                                    <xsl:value-of
                                                                                                            select="returnToAddress/address/name"/>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                         <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline font-family="arial"
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/businessName"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="10pt">
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/addressLine1"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="10pt">
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/addressLine2"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                         <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="10pt">
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/addressLine3"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                         <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="10pt">
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/addressLine4"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:if test="returnToAddress/address/city">    
                                                                                                         <xsl:value-of
                                                                                                                select="returnToAddress/address/city"/>,
                                                                                                        </xsl:if>
                                                                                                         <xsl:if test="returnToAddress/address/state">        
                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/address/state"/>,
                                                                                                       </xsl:if>       
                                                                                                         <xsl:if test="returnToAddress/address/zipCode">            
                                                                                                          <xsl:value-of
                                                                                                                select="returnToAddress/address/zipCode"/>,
                                                                                                         </xsl:if>          
                                                                                                                 <xsl:value-of
                                                                                                                select="returnToAddress/address/country"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block font-family="arial"  font-size="12pt"   font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="java:getString($resources,'label.partShipmentTag.attentionTo')"/>:

                                                                                                        <xsl:value-of
                                                                                                                select="returnToAddress/contactPersonName"/>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <!--<fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="10pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="java:getString($resources,'label.partShipmentTag.dealerNumber')"/>:
                                                                                                    </fo:inline>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="dealerNumber"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>-->
                                                                                        <xsl:call-template name="emptyLine">
                                                                                            <xsl:with-param name="numberOfCloumns" select="'1'"/>
                                                                                        </xsl:call-template>
                                                                                    </fo:table-body>
                                                                                </fo:table>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:leader leader-length="100%"
                                                                                           leader-pattern="space">
                                                                                    &#x00A0;</fo:leader>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                   <!-- <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:inline font-size="10pt"
                                                                                           font-weight="bold"
                                                                                           text-decoration="underline">
                                                                                    <xsl:value-of
                                                                                            select="java:getString($resources,'label.partShipmentTag.senderComments')"/>:
                                                                                </fo:inline>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:leader leader-length="100%"
                                                                                           leader-pattern="space">
                                                                                    &#x00A0;</fo:leader>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block font-size="10pt">
                                                                                <xsl:value-of
                                                                                        select="shipment/senderComments"/>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>-->
                                                                </fo:table-body>
                                                            </fo:table>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell>
                                                        <fo:block>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell >
                                                        <fo:block>
                                                            <fo:table>
                                                                <fo:table-body>
                                                                    <fo:table-row>
                                                                        <fo:table-cell >
                                                                            <fo:block font-family="arial">
                                                                                <fo:table
                                                                                        border="solid 0.5px black">
                                                                                    <!-- return to address and shipment details goes here -->
                                                                                    <fo:table-body>
                                                                                        <xsl:call-template
                                                                                                name="emptyLine">
                                                                                            <xsl:with-param
                                                                                                    name="numberOfCloumns" select="'1'"/>
                                                                                        </xsl:call-template>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell
                                                                                                    text-decoration="underline"
                                                                                                    text-align="center">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="14pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="java:getString($resources,'label.returnToAddress')"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell>
                                                                                                <fo:block>
                                                                                                    <fo:leader
                                                                                                            leader-length="100%"
                                                                                                            leader-pattern="space">
                                                                                                        &#x00A0;</fo:leader>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="from/name"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                         <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            font-weight="bold">
                                                                                                        <xsl:value-of
                                                                                                                select="from/contactPersonName"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt">
                                                                                                        <xsl:value-of
                                                                                                                select="from/addressLine1"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt">
                                                                                                        <xsl:value-of
                                                                                                                select="from/addressLine2"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt">
                                                                                                        <xsl:value-of
                                                                                                                select="from/addressLine3"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt">
                                                                                                        <xsl:value-of
                                                                                                                select="from/addressLine4"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>

                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block   font-size="12pt"   font-weight="bold">
                                                                                                 <!--   <xsl:value-of
                                                                                                            select="java:getString($resources,'label.partShipmentTag.attentionTo')"/>:-->
                                                                                                    <fo:inline
                                                                                                            font-size="10pt"
                                                                                                            font-weight="bold">
                                                                                                       <xsl:if test="from/city"> 
                                                                                                        <xsl:value-of
                                                                                                                select="from/city"/>,
                                                                                                        </xsl:if>
                                                                                                        <xsl:if test="from/state">        
                                                                                                        <xsl:value-of
                                                                                                                select="from/state"/>,
                                                                                                         </xsl:if>       
                                                                                                         <xsl:if test="from/zipCode">         
                                                                                                        <xsl:value-of
                                                                                                                select="from/zipCode"/>,
                                                                                                         </xsl:if>        
                                                                                                                 <xsl:value-of
                                                                                                                select="from/country"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <xsl:call-template name="emptyLine">
                                                                                            <xsl:with-param name="numberOfCloumns" select="'1'"/>
                                                                                        </xsl:call-template>
                                                                                    </fo:table-body>
                                                                                </fo:table>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:leader leader-length="100%"
                                                                                           leader-pattern="space">
                                                                                    &#x00A0;</fo:leader>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell >
                                                                            <fo:block font-family="arial">
                                                                                <fo:table border="solid 0.5px black">
                                                                                    <!-- return to address and shipment details goes here -->
                                                                                    <!--<fo:table-column column-width="100%" padding-start=".4cm" />-->
                                                                                    <fo:table-body>
                                                                                        <xsl:call-template name="emptyLine">
                                                                                            <xsl:with-param name="numberOfCloumns" select="'1'"/>
                                                                                        </xsl:call-template>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="12pt"
                                                                                                            text-align="center">
                                                                                                        <xsl:value-of
                                                                                                                select="java:getString($resources,'label.partReturnConfiguration.shipmentNumber')"/>:
                                                                                                    </fo:inline>
                                                                                                    <fo:inline
                                                                                                            font-size="16pt"
                                                                                                            font-weight="bold"
                                                                                                            text-align="center">
                                                                                                        <xsl:value-of
                                                                                                                select="shipment/shipmentNumber"/>
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell >
                                                                                                <fo:block>
                                                                                                    <fo:leader
                                                                                                            leader-length="100%"
                                                                                                            leader-pattern="space">
                                                                                                        &#x00A0;</fo:leader>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell padding-start="0.3cm">
                                                                                                <fo:block>
                                                                                                    <fo:inline
                                                                                                            font-size="11pt"
                                                                                                            text-align="center">
                                                                                                        <xsl:value-of
                                                                                                                select="labelShippedDate"/>:
                                                                                                    </fo:inline>
                                                                                                    <fo:inline
                                                                                                            font-size="11pt"
                                                                                                            font-weight="bold"
                                                                                                            text-align="center">
                                                                                                        <xsl:value-of
                                                                                                                select="shipment/shipmentDate" />
                                                                                                    </fo:inline>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell>
                                                                                                <fo:block>
                                                                                                    <fo:leader
                                                                                                            leader-length="100%"
                                                                                                            leader-pattern="space">
                                                                                                        &#x00A0;</fo:leader>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell>
                                                                                                <fo:block>
                                                                                                    <fo:leader
                                                                                                            leader-length="100%"
                                                                                                            leader-pattern="space">
                                                                                                        &#x00A0;</fo:leader>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                        <fo:table-row>
                                                                                            <fo:table-cell>
                                                                                                <fo:block
                                                                                                        text-align="center">
                                                                                                    <xsl:apply-templates
                                                                                                            select="shipment/barcode"/>
                                                                                                </fo:block>
                                                                                            </fo:table-cell>
                                                                                        </fo:table-row>
                                                                                    </fo:table-body>
                                                                                </fo:table>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:leader leader-length="100%"
                                                                                           leader-pattern="space">
                                                                                    &#x00A0;</fo:leader>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                    <fo:table-row>
                                                                        <fo:table-cell>
                                                                            <fo:block>
                                                                                <fo:leader leader-length="100%"
                                                                                           leader-pattern="space">
                                                                                    &#x00A0;</fo:leader>
                                                                            </fo:block>
                                                                        </fo:table-cell>
                                                                    </fo:table-row>
                                                                </fo:table-body>
                                                            </fo:table>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                </fo:table-row>
                                            </fo:table-body>
                                        </fo:table>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                    <!-- warranty parts return table starts  -->
                    <fo:block>
                        <fo:leader leader-pattern="space" leader-length="230pt"
                                   border="solid 0.1px blue"/>
                        <fo:inline text-align="center" font-style="italic"
                                   font-size="6pt">
                            <xsl:value-of
                                    select="java:getString($resources,'label.partShipmentTag.foldAlongLine')"/>
                        </fo:inline>
                        <fo:leader leader-pattern="space" leader-length="230pt"
                                   border="solid 0.1px blue"/>
                    </fo:block>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="shipmentTag">
        <fo:root>
            <xsl:call-template name="pageLayout"/>
            <fo:page-sequence master-reference="page">
                <fo:flow flow-name="body">
                    <!--<fo:table table-layout="fixed" text-align="start">
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block font-size="8pt" text-align="right" font-family="arial">
                                        <xsl:value-of
                                                select="java:getString($resources,'label.partShipmentTag.individualTags')"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                           &lt;!&ndash; <xsl:for-each select="partDetails/partDetail">
                                <xsl:call-template name="displayPartDetail"/>
                                <xsl:call-template name="displayWarrantySummery"/>
                            </xsl:for-each>&ndash;&gt;
                        </fo:table-body>
                    </fo:table>-->
                    <fo:block>
                        <fo:table>
                            <fo:table-body>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block font-size="8pt" text-align="center" font-family="arial">
                                            <xsl:value-of
                                                    select="java:getString($resources,'label.partShipmentTag.frontSide')"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <xsl:call-template name="displayShipmentTag"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                    <fo:block><!-- List of parts block starts -->
                        <fo:table>
                            <fo:table-body>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block>
                                            <fo:leader leader-length="100%" leader-pattern="space"> &#x00A0;</fo:leader>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block text-align="center">
                                            <fo:inline font-size="24pt" font-weight="bold">
                                                <xsl:value-of
                                                        select="java:getString($resources,'label.partShipmentTag.listOfParts')"/>
                                            </fo:inline>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block>
                                            <fo:leader leader-length="100%" leader-pattern="space"> &#x00A0;</fo:leader>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block>
                                            <fo:table border-style="solid" border-width="0.02cm">
                                                <fo:table-column column-width="28mm" />
                                                <fo:table-column column-width="32mm"/>
                                                <fo:table-column column-width="35mm"/>
                                                <fo:table-column column-width="30mm"/>
                                                <fo:table-column column-width="30mm"/>
                                                <fo:table-column column-width="20mm"/>
                                                <fo:table-header>
                                                    <fo:table-cell border-before-style="solid"   padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'columnTitle.common.claimNo')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell border-before-style="solid"   padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'label.partShipmentTag.modelNo')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell border-before-style="solid"       padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'columnTitle.common.serialNo')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell border-before-style="solid"     padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'label.common.partNumber')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell border-before-style="solid"    padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'label.common.description')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                    <fo:table-cell border-before-style="solid"      padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'columnTitle.common.quantity')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                   <!-- <fo:table-cell border-before-style="solid"      padding-start="3mm"
                                                                   border-before-width="0.02cm"
                                                                   border-right-style="solid"
                                                                   border-right-width="0.02cm">
                                                        <fo:block font-family="arial" >
                                                            <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                <xsl:value-of
                                                                        select="java:getString($resources,'label.partReturnConfiguration.rmaNumber')"/>
                                                            </fo:inline>
                                                        </fo:block>
                                                    </fo:table-cell>-->
                                                </fo:table-header>
                                                <fo:table-body>
                                                    <xsl:for-each select="partDetails/partDetail">
                                                        <fo:table-row>
                                                            <fo:table-cell border-before-style="solid"     padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial" >
                                                                    <fo:inline font-size="8pt" font-weight="bold" line-height="12pt" >
                                                                        <xsl:value-of select="claim/claimNumber"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <fo:table-cell border-before-style="solid"         padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial" >
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of select="claim/model"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <fo:table-cell border-before-style="solid"           padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial">
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of
                                                                                select="claim/machineSerialNumber"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <fo:table-cell border-before-style="solid"            padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial">
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of select="part/partNumber"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <fo:table-cell border-before-style="solid"           padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial">
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of select="part/description"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <fo:table-cell border-before-style="solid"           padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial">
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of select="part/numberOfParts"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>
                                                            <!--<fo:table-cell border-before-style="solid"               padding-start="3mm"
                                                                           border-before-width="0.02cm"
                                                                           border-right-style="solid"
                                                                           border-right-width="0.02cm">
                                                                <fo:block font-family="arial">
                                                                    <fo:inline font-size="8pt" line-height="12pt" >
                                                                        <xsl:value-of select="part/rmaNumber"/>
                                                                    </fo:inline>
                                                                </fo:block>
                                                            </fo:table-cell>-->
                                                        </fo:table-row>
                                                    </xsl:for-each>
                                                </fo:table-body>
                                            </fo:table>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                  <xsl:if test="$bu='EMEA'">
                                  <fo:table-row>
                                  <fo:table-cell  number-columns-spanned="1" width="100%"> 
			                         <fo:block>
	                               	  <fo:inline margin-top = "2pt" text-align="start" font-family="arial" font-size="12pt" font-weight="normal">
	                                     <xsl:if test="partDetails/partDetail/claim/brand= 'YALE'"> 
	                                       <fo:external-graphic src="url(servlet-context:/image/YALE_Footer.gif)"
	                                                            content-height="scale-to-fit" height=".40in"
	                                                          padding-top="5pt"  content-width="5in" scaling="non-uniform"/>
	                                     </xsl:if>
	                                    <xsl:if test="partDetails/partDetail/claim/brand= 'HYSTER'">
	                                       <fo:external-graphic src="url(servlet-context:/image/HYSTER_Footer.gif)"
	                                                            content-height="scale-to-fit" height=".60in"
	                                                         padding-top="5pt"   content-width="4in" scaling="non-uniform"/>
	                                    </xsl:if>  
	                                  </fo:inline>
			                         </fo:block>
		                           </fo:table-cell>
		                        </fo:table-row>
		                        </xsl:if>
		                         <xsl:if test="$bu='AMER'">
                            <xsl:call-template name="emptyLine">
                                <xsl:with-param name="numberOfCloumns" select="'3'"/>
                            </xsl:call-template>  
                                  <fo:table-row>
                                  <fo:table-cell  number-columns-spanned="1" width="100%"> 
                                  <fo:block>
                                  <fo:inline text-align="center" font-family="sans-seriff">
                                  1400 Sullivan Dr. Greenville, NC 27834                                  
                                  </fo:inline>
                                  </fo:block>
                                  </fo:table-cell>
                                  </fo:table-row>		                         
		                         </xsl:if>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <xsl:template match="shipment/barcode">
        <xsl:variable name="message" select="."/>
        <fo:instream-foreign-object>
            <barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns"
                             message="{$message}">
                <barcode:code128>
                    <barcode:height>15mm</barcode:height>
                </barcode:code128>
            </barcode:barcode>
        </fo:instream-foreign-object>
    </xsl:template>
</xsl:transform>