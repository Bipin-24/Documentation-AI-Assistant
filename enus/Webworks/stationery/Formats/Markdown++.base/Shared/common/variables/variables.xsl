<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Variables-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwnodeset="urn:WebWorks-XSLT-Extension-NodeSet"
                              exclude-result-prefixes="xsl msxsl wwvars wwfilesext wwmode wwfiles wwdoc wwproject wwpage wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwnodeset"
>
 <xsl:key name="wwvars-groups-by-groupid" match="wwvars:Group" use="@groupID" />
 <xsl:key name="wwvars-documents-by-documentid" match="wwvars:Document" use="@documentID" />


 <xsl:template name="Variables-Globals-Scope-Split">
  <xsl:param name="ParamProjectVariables" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamSplitPosition" />

  <!-- Access group variables -->
  <!--                        -->
  <xsl:for-each select="$ParamProjectVariables[1]">
   <xsl:variable name="VarVariablesGroup" select="key('wwvars-groups-by-groupid', $ParamGroupID)[1]" />

   <!-- Determine document position -->
   <!--                             -->
   <xsl:variable name="VarDocumentPosition" select="key('wwvars-documents-by-documentid', $ParamDocumentID)/@position" />

   <!-- Emit following variables first and then preceeding variables -->
   <!-- This will mimic the Publisher 2003 behavior for globals      -->
   <!--                                                              -->
   <!-- Record preceeding variables -->
   <!--                             -->
   <xsl:variable name="VarVariablesAsXML">
    <!-- Following splits -->
    <!--                  -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position = $VarDocumentPosition]/wwvars:Split[@position &gt; $ParamSplitPosition]/wwvars:Variable, 'name')" />

    <!-- Following documents -->
    <!--                     -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position &gt; $VarDocumentPosition]/wwvars:Split/wwvars:Variable, 'name')" />

    <!-- Preceding documents -->
    <!--                     -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position &lt; $VarDocumentPosition]/wwvars:Split/wwvars:Variable, 'name')" />

    <!-- Preceding splits and this one -->
    <!--                               -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position = $VarDocumentPosition]/wwvars:Split[@position &lt;= $ParamSplitPosition]/wwvars:Variable, 'name')" />
   </xsl:variable>
   <xsl:variable name="VarVariables" select="msxsl:node-set($VarVariablesAsXML)/wwvars:Variable" />

   <!-- Return last unique variable instance -->
   <!--                                      -->
   <xsl:copy-of select="wwnodeset:LastUnique($VarVariables, 'name')" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Variables-Globals-Scope-Document">
  <xsl:param name="ParamProjectVariables" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamDocumentID" />

  <!-- Access group variables -->
  <!--                        -->
  <xsl:for-each select="$ParamProjectVariables[1]">
   <xsl:variable name="VarVariablesGroup" select="key('wwvars-groups-by-groupid', $ParamGroupID)[1]" />

   <!-- Determine document position -->
   <!--                             -->
   <xsl:variable name="VarDocumentPosition" select="key('wwvars-documents-by-documentid', $ParamDocumentID)/@position" />

   <!-- Emit following variables first and then preceeding variables -->
   <!-- This will mimic the Publisher 2003 behavior for globals      -->
   <!--                                                              -->
   <!-- Record preceeding variables -->
   <!--                             -->
   <xsl:variable name="VarVariablesAsXML">
    <!-- Following documents -->
    <!--                     -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position &gt; $VarDocumentPosition]/wwvars:Split/wwvars:Variable, 'name')" />

    <!-- Preceding documents -->
    <!--                     -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position &lt; $VarDocumentPosition]/wwvars:Split/wwvars:Variable, 'name')" />

    <!-- Current document -->
    <!--                  -->
    <xsl:copy-of select="wwnodeset:LastUnique($VarVariablesGroup/wwvars:Document[@position = $VarDocumentPosition]/wwvars:Split/wwvars:Variable, 'name')" />
   </xsl:variable>
   <xsl:variable name="VarVariables" select="msxsl:node-set($VarVariablesAsXML)/wwvars:Variable" />

   <!-- Return last unique variable instance -->
   <!--                                      -->
   <xsl:copy-of select="wwnodeset:LastUnique($VarVariables, 'name')" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Variables-Globals-Scope-Group">
  <xsl:param name="ParamProjectVariables" />
  <xsl:param name="ParamGroupID" />

  <!-- Access group variables -->
  <!--                        -->
  <xsl:for-each select="$ParamProjectVariables[1]">
   <xsl:variable name="VarVariablesGroup" select="key('wwvars-groups-by-groupid', $ParamGroupID)[1]" />

   <!-- Group variables -->
   <!--                 -->
   <xsl:variable name="VarVariables" select="$VarVariablesGroup/wwvars:Document/wwvars:Split/wwvars:Variable" />

   <!-- Return last unique variable instance -->
   <!--                                      -->
   <xsl:copy-of select="wwnodeset:LastUnique($VarVariables, 'name')" />
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Variables-Globals-Scope-Project">
  <xsl:param name="ParamProjectVariables" />

  <!-- Return last unique variable instance -->
  <!--                                      -->
  <xsl:copy-of select="wwnodeset:LastUnique($ParamProjectVariables/wwvars:Variables/wwvars:Group/wwvars:Document/wwvars:Split/wwvars:Variable, 'name')" />
 </xsl:template>


 <xsl:template name="Variables-Globals-For-Scope">
  <xsl:param name="ParamProjectVariables" />
  <xsl:param name="ParamGroupID" select="''" />
  <xsl:param name="ParamDocumentID" select="''" />
  <xsl:param name="ParamSplitPosition" select="''" />

  <!-- Which scope to use? -->
  <!--                     -->
  <xsl:choose>
   <!-- Split scope -->
   <!--             -->
   <xsl:when test="($ParamGroupID != '') and ($ParamDocumentID != '') and ($ParamSplitPosition != '')">
    <xsl:call-template name="Variables-Globals-Scope-Split">
     <xsl:with-param name="ParamProjectVariables" select="$ParamProjectVariables" />
     <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
     <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
     <xsl:with-param name="ParamSplitPosition" select="$ParamSplitPosition" />
    </xsl:call-template>
   </xsl:when>

   <!-- Document scope -->
   <!--                -->
   <xsl:when test="($ParamGroupID != '') and ($ParamDocumentID != '')">
    <xsl:call-template name="Variables-Globals-Scope-Document">
     <xsl:with-param name="ParamProjectVariables" select="$ParamProjectVariables" />
     <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
     <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    </xsl:call-template>
   </xsl:when>

   <!-- Group scope -->
   <!--             -->
   <xsl:when test="$ParamGroupID != ''">
    <xsl:call-template name="Variables-Globals-Scope-Group">
     <xsl:with-param name="ParamProjectVariables" select="$ParamProjectVariables" />
     <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
    </xsl:call-template>
   </xsl:when>

   <!-- Project scope -->
   <!--               -->
   <xsl:otherwise>
    <xsl:call-template name="Variables-Globals-Scope-Project">
     <xsl:with-param name="ParamProjectVariables" select="$ParamProjectVariables" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Variables-Globals-Split">
  <xsl:param name="ParamProjectVariables" />
  <xsl:param name="ParamSplit" />

  <xsl:call-template name="Variables-Globals-Scope-Split">
   <xsl:with-param name="ParamProjectVariables" select="$ParamProjectVariables" />
   <xsl:with-param name="ParamGroupID" select="$ParamSplit/@groupID" />
   <xsl:with-param name="ParamDocumentID" select="$ParamSplit/@documentID" />
   <xsl:with-param name="ParamSplitPosition" select="$ParamSplit/@position" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Variables-Filter-Last-Unique">
  <xsl:param name="ParamVariables" />

  <xsl:copy-of select="wwnodeset:LastUnique($ParamVariables, 'name')" />
 </xsl:template>


 <xsl:template name="Variables-Page-String-Replacements">
  <xsl:param name="ParamVariables" />

  <!-- Convert variables to simple string replacements -->
  <!--                                                 -->
  <xsl:for-each select="$ParamVariables">
   <xsl:variable name="VarVariable" select="." />

   <!-- Emit replacement -->
   <!--                  -->
   <wwpage:Replacement name="wwvars:{$VarVariable/@name}">
    <xsl:apply-templates select="$VarVariable" mode="wwmode:variable-string-value" />
   </wwpage:Replacement>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Variables-Page-Conditions">
  <xsl:param name="ParamVariables" />

  <xsl:for-each select="$ParamVariables">
   <xsl:variable name="VarVariable" select="." />
   <xsl:variable name="VarVariableValue">
    <xsl:apply-templates select="$VarVariable" mode="wwmode:variable-string-value" />
   </xsl:variable>

   <xsl:if test="string-length($VarVariableValue) &gt; 0">
    <wwpage:Condition name="wwvars:{$VarVariable/@name}" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwvars:Variable" mode="wwmode:variable-string-value">
  <xsl:param name="ParamVariable" select="." />

  <!-- Determine string value -->
  <!--                        -->
  <xsl:choose>
   <!-- Handle paragraphs -->
   <!--                   -->
   <xsl:when test="count($ParamVariable/wwdoc:Paragraph) = 1">
    <xsl:apply-templates select="$ParamVariable/wwdoc:Paragraph/wwdoc:Number/wwdoc:* | $ParamVariable/wwdoc:Paragraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
   </xsl:when>

   <!-- Handle text runs (character runs) -->
   <!--                                   -->
   <xsl:when test="count($ParamVariable/wwdoc:TextRun) = 1">
    <xsl:apply-templates select="$ParamVariable/wwdoc:TextRun" mode="wwmode:textrun_text" />
   </xsl:when>

   <!-- Handle markers -->
   <!--                -->
   <xsl:when test="count($ParamVariable/wwdoc:Marker) = 1">
    <xsl:apply-templates select="$ParamVariable/wwdoc:Marker/wwdoc:TextRun" mode="wwmode:textrun_text" />
   </xsl:when>

   <!-- Undefined -->
   <!--           -->
   <xsl:otherwise>
    <xsl:value-of select="''" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- Process all valid text in TextRuns and nested TextRuns (depth first, in order). -->
 <!--                                                                                 -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun_text">
  <xsl:variable name="VarTextRun" select="."/>
  <!-- Recurse to find nested TextRuns, Text, and LineBreaks -->
  <!--                                                       -->
  <xsl:apply-templates select="$VarTextRun/*" mode="wwmode:textrun_text"/>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:textrun_text">
  <xsl:value-of select="./@value"/>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun_text">
  <!-- Replace LineBreaks with a single space -->
  <!--                                        -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="* |text() | comment() | processing-instruction()" mode="wwmode:textrun_text">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
