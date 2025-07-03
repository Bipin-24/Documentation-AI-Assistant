<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc"
>
 <xsl:template name="Conditions-PassThrough">
  <xsl:param name="ParamConditions" />

  <xsl:choose>
   <xsl:when test="count($ParamConditions/wwdoc:Condition[1]) = 1">
    <xsl:variable name="VarPassThrough">
     <xsl:for-each select="$ParamConditions/wwdoc:Condition">
      <xsl:variable name="VarCondition" select="." />

      <xsl:choose>
       <xsl:when test="wwprojext:GetConditionIsPassThrough($VarCondition/@name)">
        <xsl:value-of select="'1'" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="''" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="string-length($VarPassThrough) &gt; 0" />
   </xsl:when>

   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
