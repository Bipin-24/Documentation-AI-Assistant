<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
  <xsl:param name="GlobalInput" />
  <xsl:param name="GlobalPipelineName" />
  <xsl:param name="GlobalProject" />
  <xsl:param name="GlobalFiles" />
  <xsl:param name="ParameterDependsType" />
  <xsl:param name="ParameterSplitsType" />
  <xsl:param name="ParameterType" />
  <xsl:param name="ParameterSplitFileType" />
  <xsl:param name="ParameterCategory" />
  <xsl:param name="ParameterUse" />
  <xsl:param name="ParameterDeploy" />


  <xsl:output method="xml" encoding="UTF-8" indent="yes" />
  <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
  <xsl:strip-space elements="*" />


  <xsl:include href="wwtransform:common/project/properties.xsl" />
  <xsl:include href="wwtransform:html/css_properties.xsl" />
  <xsl:include href="wwtransform:uri/uri.xsl" />


  <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
  <xsl:key name="wwsplits-files-by-documentid" match="wwsplits:File" use="@documentID" />
  <xsl:key name="wwproject-property-by-name" match="wwproject:Property" use="@Name" />


  <xsl:variable name="GlobalActionChecksum">
    <xsl:variable name="VarTransformChecksums">
      <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
      <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
      <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
      <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
    </xsl:variable>
    <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
  </xsl:variable>


  <xsl:template match="/">
    <wwfiles:Files version="1.0">

      <!-- Groups -->
      <!--        -->
      <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
      <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
      <xsl:for-each select="$VarProjectGroups">
        <xsl:variable name="VarProjectGroup" select="." />

        <!-- Aborted? -->
        <!--          -->
        <xsl:if test="not(wwprogress:Abort())">
          <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

          <!-- Access splits -->
          <!--               -->
          <xsl:for-each select="$GlobalInput[1]">
            <xsl:variable name="VarFilesNameInfo" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterSplitsType))" />
            <xsl:for-each select="$VarFilesNameInfo[1]">
              <xsl:variable name="VarSplitsFileInfo" select="." />

              <!-- Load splits -->
              <!--             -->
              <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFileInfo/@path)" />

              <!-- Iterate input documents -->
              <!--                         -->
              <xsl:for-each select="$GlobalInput[1]">
                <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDependsType))" />

                <xsl:variable name="VarProgressDocumentWIFsStart" select="wwprogress:Start(count($VarFilesByType))" />

                <xsl:for-each select="$VarFilesByType">
                  <xsl:variable name="VarFilesDocumentNode" select="." />

                  <xsl:variable name="VarProgressDocumentWIFStart" select="wwprogress:Start(1)" />

                  <!-- Aborted? -->
                  <!--          -->
                  <xsl:if test="not(wwprogress:Abort())">
                    <!-- Output Path -->
                    <!--             -->
                    <xsl:variable name="VarPath">
                      <xsl:for-each select="$VarSplits[1]">
                        <xsl:value-of select="key('wwsplits-files-by-documentid', $VarFilesDocumentNode/@documentID)[@type = $ParameterSplitFileType][1]/@path" />
                      </xsl:for-each>
                    </xsl:variable>

                    <!-- Call template -->
                    <!--               -->
                    <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocumentNode/@groupID, $VarFilesDocumentNode/@documentID, $GlobalActionChecksum)" />
                    <xsl:if test="not($VarUpToDate)">
                      <xsl:variable name="VarResultAsXML">
                        <!-- Load document -->
                        <!--               -->
                        <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocumentNode/@path)" />

                        <xsl:call-template name="Styles">
                          <xsl:with-param name="ParamDocument" select="$VarDocument" />
                          <xsl:with-param name="ParamStylesPath" select="$VarPath" />
                          <xsl:with-param name="ParamSplits" select="$VarSplits" />
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
                      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'text')" />
                    </xsl:if>

                    <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
                      <wwfiles:Depends path="{$VarSplitsFileInfo/@path}" checksum="{$VarSplitsFileInfo/@checksum}" groupID="{$VarSplitsFileInfo/@groupID}" documentID="{$VarSplitsFileInfo/@documentID}" />
                      <wwfiles:Depends path="{$VarFilesDocumentNode/@path}" checksum="{$VarFilesDocumentNode/@checksum}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" />
                    </wwfiles:File>
                  </xsl:if>

                  <xsl:variable name="VarProgressDocumentWIFEnd" select="wwprogress:End()" />
                </xsl:for-each>

                <xsl:variable name="VarProgressDocumentWIFsEnd" select="wwprogress:End()" />
              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:if>

        <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
      </xsl:for-each>
      <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

    </wwfiles:Files>
  </xsl:template>


  <xsl:template name="Styles">
    <xsl:param name="ParamDocument" />
    <xsl:param name="ParamStylesPath" />
    <xsl:param name="ParamSplits" />

    <xsl:call-template name="CatalogStyles">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamStylesPath" select="$ParamStylesPath" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:ParagraphStyles[1]/wwdoc:ParagraphStyle" />
      <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
      <xsl:with-param name="ParamDefaultTag" select="'div'" />
    </xsl:call-template>

    <xsl:call-template name="CatalogStyles">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamStylesPath" select="$ParamStylesPath" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:CharacterStyles[1]/wwdoc:CharacterStyle" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
      <xsl:with-param name="ParamDefaultTag" select="'span'" />
    </xsl:call-template>

    <xsl:call-template name="CatalogStyles">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamStylesPath" select="$ParamStylesPath" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:TableStyles[1]/wwdoc:TableStyle" />
      <xsl:with-param name="ParamStyleType" select="'Table'" />
      <xsl:with-param name="ParamDefaultTag" select="'table'" />
    </xsl:call-template>

    <xsl:call-template name="CatalogStyles">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamStylesPath" select="$ParamStylesPath" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:GraphicStyles[1]/wwdoc:GraphicStyle" />
      <xsl:with-param name="ParamStyleType" select="'Graphic'" />
      <xsl:with-param name="ParamDefaultTag" select="'img'" />
    </xsl:call-template>

    <xsl:call-template name="CatalogStyles">
      <xsl:with-param name="ParamDocument" select="$ParamDocument" />
      <xsl:with-param name="ParamStylesPath" select="$ParamStylesPath" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamDocumentStyles" select="$ParamDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:GraphicStyles[1]/wwdoc:GraphicStyle" />
      <xsl:with-param name="ParamStyleType" select="'Graphic'" />
      <xsl:with-param name="ParamDefaultTag" select="'video'" />
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="CatalogStyles">
    <xsl:param name="ParamDocument" />
    <xsl:param name="ParamStylesPath" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamDocumentStyles" />
    <xsl:param name="ParamStyleType" />
    <xsl:param name="ParamDefaultTag" />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
      <xsl:for-each select="$ParamDocumentStyles">
        <xsl:variable name="VarDocumentStyle" select="." />

        <xsl:variable name="VarRule" select="wwprojext:GetRule($ParamStyleType, $VarDocumentStyle/@name)" />

        <!-- Resolve project properties -->
        <!--                            -->
        <xsl:variable name="VarResolvedPropertiesAsXML">
          <xsl:call-template name="Properties-ResolveRule">
            <xsl:with-param name="ParamDocumentContext" select="$ParamDocument" />
            <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
            <xsl:with-param name="ParamStyleName" select="$VarDocumentStyle/@name" />
            <xsl:with-param name="ParamStyleType" select="$ParamStyleType" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

        <!-- CSS properties -->
        <!--                -->
        <xsl:variable name="VarCSSPropertiesAsXML">
          <xsl:call-template name="CSS-TranslateProjectProperties">
            <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
            <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamStylesPath" />
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

        <!-- Tag -->
        <!--     -->
        <xsl:variable name="VarTagProperty" select="$VarRule/wwproject:Properties/wwproject:Property[@Name = 'tag']/@Value" />
        <xsl:variable name="VarTag">
          <xsl:choose>
            <xsl:when test="string-length($VarTagProperty) &gt; 0">
              <xsl:value-of select="$VarTagProperty" />
            </xsl:when>
            <xsl:when test="string-length($VarDocumentStyle/wwdoc:Style/wwdoc:Attribute[@name = 'tag']/@value) &gt; 0">
              <xsl:value-of select="$VarDocumentStyle/wwdoc:Style/wwdoc:Attribute[@name = 'tag']/@value" />
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select="$ParamDefaultTag" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:for-each select="$VarCSSProperties[1]">
          <!-- CSS Style -->
          <!--           -->
          <wwexsldoc:Text>
            <xsl:value-of select="$VarTag" />
            <xsl:text>.</xsl:text>
            <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />

            <!-- Handle cases where this is a numbered paragraph -->
            <!--                                                 -->
            <xsl:if test="$ParamStyleType = 'Paragraph'">
              <xsl:if test="$VarTag != 'div'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for div tag -->
                <!--                       -->
                <xsl:text>div.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              </xsl:if>
            </xsl:if>

            <!-- Handle cases where this is a table caption -->
            <!--                                            -->
            <xsl:if test="$ParamStyleType = 'Paragraph'">
              <!-- CSS separator -->
              <!--               -->
              <xsl:text>, </xsl:text>

              <!-- CSS Style for caption tag -->
              <!--                           -->
              <xsl:text>caption.</xsl:text>
              <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
            </xsl:if>

            <!-- Handle character level elements -->
            <!--                                 -->
            <xsl:if test="$ParamStyleType = 'Character'">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="$VarTag" />
              <xsl:text>.</xsl:text>
              <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              <xsl:text> a, </xsl:text>

              <xsl:value-of select="$VarTag" />
              <xsl:text>.</xsl:text>
              <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              <xsl:text> a:active</xsl:text>

              <xsl:if test="$VarTag != 'abbreviation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for abbreviation tag -->
                <!--                                -->
                <xsl:text>abbreviation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              </xsl:if>

              <xsl:if test="$VarTag != 'abbreviation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for abbreviation link tag -->
                <!--                           -->
                <xsl:text>abbreviation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a</xsl:text>
              </xsl:if>

              <xsl:if test="$VarTag != 'abbreviation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for abbreviation link tag -->
                <!--                           -->
                <xsl:text>abbreviation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a:active</xsl:text>
              </xsl:if>

              <xsl:if test="$VarTag != 'acronym'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for acronym tag -->
                <!--                           -->
                <xsl:text>acronym.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              </xsl:if>

              <xsl:if test="$VarTag != 'acronym'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for acronym link active tag -->
                <!--                           -->
                <xsl:text>acronym.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a</xsl:text>
              </xsl:if>

              <xsl:if test="$VarTag != 'acronym'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for acronym link active tag -->
                <!--                           -->
                <xsl:text>acronym.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a:active</xsl:text>
              </xsl:if>

              <xsl:if test="$VarTag != 'citation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for citation tag -->
                <!--                            -->
                <xsl:text>citation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
              </xsl:if>

              <xsl:if test="$VarTag != 'citation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for citation link active tag -->
                <!--                           -->
                <xsl:text>citation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a</xsl:text>
              </xsl:if>

              <xsl:if test="$VarTag != 'citation'">
                <!-- CSS separator -->
                <!--               -->
                <xsl:text>, </xsl:text>

                <!-- CSS Style for citation link active tag -->
                <!--                           -->
                <xsl:text>citation.</xsl:text>
                <xsl:value-of select="wwstring:CSSClassName($VarDocumentStyle/@name)" />
                <xsl:text> a:active</xsl:text>
              </xsl:if>
            </xsl:if>



            <xsl:text>
{
</xsl:text>

            <xsl:call-template name="CSS-CatalogProperties">
              <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
            </xsl:call-template>

            <xsl:text>}

</xsl:text>
          </wwexsldoc:Text>
        </xsl:for-each>
      </xsl:for-each>

      <!-- Emit any bullet-style rules not in the document catalog -->
      <!--                                                         -->
      <xsl:if test="$ParamStyleType = 'Character'">
        <xsl:for-each select="$GlobalProject[1]">
          <xsl:variable name="VarBulletStyleRules" select="key('wwproject-property-by-name', 'bullet-style')" />

          <xsl:for-each select="$VarBulletStyleRules">
            <xsl:variable name="VarBulletStyleRule" select="." />

            <xsl:if test="count($ParamDocument/wwdoc:Document/wwdoc:Styles/wwdoc:CharacterStyles/wwdoc:CharacterStyle[@name = $VarBulletStyleRule/@Value][1]) = 0">
              <xsl:variable name="VarRule" select="wwprojext:GetRule($ParamStyleType, $VarBulletStyleRule/@Value)" />

              <!-- Resolve project properties -->
              <!--                            -->
              <xsl:variable name="VarResolvedPropertiesAsXML">
                <xsl:call-template name="Properties-ResolveRule">
                  <xsl:with-param name="ParamDocumentContext" select="$ParamDocument" />
                  <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
                  <xsl:with-param name="ParamStyleName" select="$VarBulletStyleRule/@Name" />
                  <xsl:with-param name="ParamStyleType" select="$ParamStyleType" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

              <!-- CSS properties -->
              <!--                -->
              <xsl:variable name="VarCSSPropertiesAsXML">
                <xsl:call-template name="CSS-TranslateProjectProperties">
                  <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
                  <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamStylesPath" />
                  <xsl:with-param name="ParamSplits" select="$ParamSplits" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

              <!-- Tag -->
              <!--     -->
              <xsl:variable name="VarTagProperty" select="$VarRule/wwproject:Properties/wwproject:Property[@Name = 'tag']/@Value" />
              <xsl:variable name="VarTag">
                <xsl:choose>
                  <xsl:when test="string-length($VarTagProperty) &gt; 0">
                    <xsl:value-of select="$VarTagProperty" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="$ParamDefaultTag" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:for-each select="$VarCSSProperties[1]">
                <!-- CSS Style -->
                <!--           -->
                <wwexsldoc:Text>
                  <xsl:value-of select="$VarTag" />
                  <xsl:text>.</xsl:text>
                  <xsl:value-of select="wwstring:CSSClassName($VarBulletStyleRule/@Value)" />

                  <xsl:text>
{
</xsl:text>

                  <xsl:call-template name="CSS-CatalogProperties">
                    <xsl:with-param name="ParamProperties" select="$VarCSSProperties" />
                  </xsl:call-template>

                  <xsl:text>}

</xsl:text>
                </wwexsldoc:Text>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
