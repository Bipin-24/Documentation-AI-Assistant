<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwbehaviors wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDropDowns" />
 <xsl:param name="ParameterPopups" />


 <xsl:namespace-alias stylesheet-prefix="wwbehaviors" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Splits -->
   <!--        -->
   <xsl:value-of select="wwprogress:Start(1)" />
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarDocumentBehaviorsFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarIgnore1">
     <xsl:value-of select="wwprogress:Start(count($VarDocumentBehaviorsFiles))" />
    </xsl:variable>

    <xsl:for-each select="$VarDocumentBehaviorsFiles">
     <xsl:variable name="VarDocumentBehaviorsFile" select="." />

     <xsl:variable name="VarIgnore2">
      <xsl:value-of select="wwprogress:Start(1)" />
     </xsl:variable>

     <!-- Up-to-date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentBehaviorsFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentBehaviorsFile/@groupID, $VarDocumentBehaviorsFile/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Pullup">
        <xsl:with-param name="ParamDocumentBehaviorsFile" select="$VarDocumentBehaviorsFile" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <!-- Record file -->
     <!--             -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarDocumentBehaviorsFile/@path}" checksum="{$VarDocumentBehaviorsFile/@checksum}" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarIgnore3">
      <xsl:value-of select="wwprogress:End()" />
     </xsl:variable>
    </xsl:for-each>

    <xsl:variable name="VarIgnore4">
     <xsl:value-of select="wwprogress:End()" />
    </xsl:variable>
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Pullup">
  <xsl:param name="ParamDocumentBehaviorsFile" />

  <!-- Load document behaviors -->
  <!--                         -->
  <xsl:variable name="VarDocumentBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentBehaviorsFile/@path, false())" />

  <!-- Behaviors -->
  <!--           -->
  <wwbehaviors:Behaviors version="1.0">

   <xsl:apply-templates select="$VarDocumentBehaviors/wwbehaviors:Behaviors/wwbehaviors:*" mode="wwmode:pullup" />

  </wwbehaviors:Behaviors>
 </xsl:template>


 <xsl:template match="wwbehaviors:Paragraph" mode="wwmode:pullup">
  <xsl:param name="ParamParagraph" select="." />

  <!-- Drop Down -->
  <!--           -->
  <xsl:variable name="VarDropDown">
   <xsl:choose>
    <xsl:when test="$ParameterDropDowns != 'true'">
     <xsl:value-of select="'continue'" />
    </xsl:when>

    <xsl:when test="$ParamParagraph/@dropdown = 'start-open'">
     <xsl:choose>
      <xsl:when test="count($ParamParagraph//wwbehaviors:Marker[@behavior = 'dropdown-end'][1]) = 1">
       <xsl:value-of select="'break'" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="'start-open'" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:when test="$ParamParagraph/@dropdown = 'start-closed'">
     <xsl:choose>
      <xsl:when test="count($ParamParagraph//wwbehaviors:Marker[@behavior = 'dropdown-end'][1]) = 1">
       <xsl:value-of select="'break'" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="'start-closed'" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:when test="$ParamParagraph/@dropdown = 'continue'">
     <xsl:choose>
      <xsl:when test="count($ParamParagraph//wwbehaviors:Marker[@behavior = 'dropdown-end'][1]) = 1">
       <xsl:value-of select="'end'" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="'continue'" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamParagraph/@dropdown" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Popup -->
  <!--       -->
  <xsl:variable name="VarPopup">
   <xsl:choose>
    <xsl:when test="$ParameterPopups != 'true'">
     <xsl:value-of select="'none'" />
    </xsl:when>

    <xsl:when test="$ParamParagraph/@popup = 'none'">
     <xsl:choose>
      <xsl:when test="(count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start'][1]) = 1) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-end'][1]) = 1)">
       <xsl:value-of select="'define'" />
      </xsl:when>

      <xsl:when test="(count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start'][1]) = 1) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-end'][1]) = 0)">
       <xsl:value-of select="'start'" />
      </xsl:when>

      <xsl:when test="(count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start'][1]) = 0) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start-no-output'][1]) = 1) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-end'][1]) = 1)">
       <xsl:value-of select="'define-no-output'" />
      </xsl:when>

      <xsl:when test="(count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start'][1]) = 0) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start-no-output'][1]) = 1) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-end'][1]) = 0)">
       <xsl:value-of select="'start-no-output'" />
      </xsl:when>

      <xsl:when test="(count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start'][1]) = 0) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-start-no-output'][1]) = 0) and (count($ParamParagraph//wwbehaviors:Marker[@behavior = 'popup-end'][1]) = 1)">
       <xsl:value-of select="'end'" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="'none'" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamParagraph/@popup" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Popup Page Rule -->
  <!--                 -->
  <xsl:variable name="VarPopupPageRule">
   <xsl:choose>
    <xsl:when test="string-length($ParamParagraph/@popup-page-rule) &gt; 0">
     <xsl:value-of select="$ParamParagraph/@popup-page-rule" />
    </xsl:when>

    <xsl:when test="($VarPopup != 'none') and ($ParamParagraph/@popup = 'none')">
     <!-- Get popup page rule from popup marker -->
     <!--                                       -->
     <xsl:for-each select="$ParamParagraph//wwbehaviors:Marker[(@behavior = 'popup-start') or (@behavior = 'popup-start-no-output')][1]">
      <xsl:variable name="VarMarker" select="." />
      <xsl:for-each select="$VarMarker/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:for-each>
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <!-- Handle window type markers -->
  <!--                            -->
  <xsl:variable name="VarWindowType">
   <xsl:variable name="VarWindowTypeCount" select="count($ParamParagraph//wwbehaviors:Marker[@behavior = 'window-type'])" />
   <xsl:choose>
    <xsl:when test="$VarWindowTypeCount &gt; 0">
     <xsl:variable name="VarWindowTypeMarker" select="$ParamParagraph//wwbehaviors:Marker[@behavior = 'window-type'][$VarWindowTypeCount]" />
     <xsl:variable name="VarTestValue">
      <xsl:for-each select="$VarWindowTypeMarker/wwdoc:Marker/wwdoc:TextRun/wwdoc:Text">
       <xsl:value-of select="@value" />
      </xsl:for-each>
     </xsl:variable>

     <xsl:value-of select="$VarTestValue" />
    </xsl:when>
   </xsl:choose>
  </xsl:variable>

  <xsl:copy>
   <xsl:copy-of select="@*[(local-name() != 'dropdown') and (local-name() != 'popup') and (local-name() != 'popup-page-rule')]" />
   <xsl:attribute name="dropdown">
    <xsl:value-of select="$VarDropDown" />
   </xsl:attribute>

   <xsl:attribute name="popup">
    <xsl:value-of select="$VarPopup" />
   </xsl:attribute>

   <xsl:attribute name="popup-page-rule">
    <xsl:value-of select="$VarPopupPageRule" />
   </xsl:attribute>

   <xsl:if test="string-length($VarWindowType) &gt; 0">
    <xsl:attribute name="window-type">
     <xsl:value-of select="$VarWindowType" />
    </xsl:attribute>
   </xsl:if>

   <xsl:apply-templates select="$ParamParagraph/wwbehaviors:*[local-name() != 'Marker'] | $ParamParagraph/wwbehaviors:Marker[not(starts-with(@behavior, 'dropdown-')) and not(starts-with(@behavior, 'popup-'))]" mode="wwmode:pullup" />
  </xsl:copy>
 </xsl:template>


 <xsl:template match="*" mode="wwmode:pullup">
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <xsl:apply-templates select="./*" mode="wwmode:pullup" />
  </xsl:copy>
 </xsl:template>
</xsl:stylesheet>
