<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwpreview="urn:WebWorks-Preview"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwimageinfo="urn:WebWorks-Image-Info-Schema"
                              xmlns:wwtrait="urn:WebWorks-Engine-FormatTraitInfo-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwunits"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />


 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:html/css_properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwimageinfo-imageinfo-by-id" match="wwimageinfo:ImageInfo" use="@id" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <!-- Load preview image info -->
    <!--                         -->
    <xsl:variable name="VarPreviewImageInfoFiles" select="key('wwfiles-files-by-type', 'preview:images')" />
    <xsl:variable name="VarPreviewImageInfo" select="wwexsldoc:LoadXMLWithoutResolver($VarPreviewImageInfoFiles[1]/@path, false())" />

    <xsl:variable name="VarWIFFiles" select="key('wwfiles-files-by-type', 'engine:wif')" />

    <xsl:value-of select="wwprogress:Start(count($VarWIFFiles))" />

    <xsl:for-each select="$VarWIFFiles">
     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Load document -->
     <!--               -->
     <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver(@path, false())" />

     <xsl:variable name="VarDocumentDataDirectoryPath" select="wwfilesystem:GetDirectoryName(@path)" />
     <xsl:variable name="VarPath" select="wwfilesystem:Combine($VarDocumentDataDirectoryPath, 'preview.html')" />


     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarResultAsXML">
      <xsl:call-template name="Document">
       <xsl:with-param name="ParamPreviewImageInfo" select="$VarPreviewImageInfo" />
       <xsl:with-param name="ParamDocument" select="$VarDocument" />
       <xsl:with-param name="ParamPath" select="$VarPath" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
     <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xhtml', '1.0', 'yes', 'no', '', '-//W3C//DTD XHTML 1.0 Transitional//EN', 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd', '', '')" />

     <wwfiles:File path="{$VarPath}" type="preview:html" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{@groupID}" documentID="{@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
      <wwfiles:Depends path="{$VarPreviewImageInfoFiles/@path}" checksum="{$VarPreviewImageInfoFiles/@checksum}" groupID="{$VarPreviewImageInfoFiles/@groupID}" documentID="{$VarPreviewImageInfoFiles/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Document">
  <xsl:param name="ParamPreviewImageInfo" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamPath" />

  <xsl:variable name="VarDocInfoScriptPath" select="wwuri:AsFilePath('wwtransform:preview/docinfo.js')" />
  <xsl:value-of select="wwfilesystem:CopyFile($VarDocInfoScriptPath, wwfilesystem:Combine(wwfilesystem:GetDirectoryName($ParamPath), 'scripts', 'docinfo.js'))"/>

  <html:html xmlns:wwpreview="urn:WebWorks-Preview" xml:lang="en" lang="en">
   <html:head>
    <html:meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <html:meta http-equiv="Content-Style-Type" content="text/css" />
    <html:meta http-equiv="X-UA-Compatible" content="IE=edge"/>

    <html:title>Preview</html:title>

    <html:link rel="StyleSheet" href="preview.css" type="text/css" media="all" />
    <html:link rel="StyleSheet" href="preview_overrides.css" type="text/css" media="all" />

    <html:script type="text/javascript" language="JavaScript1.2" src="scripts/docinfo.js"></html:script>
    <html:script type="text/javascript" language="JavaScript1.2">
     <xsl:comment>
        // New Docinfo Object
        //
        var WWDocInfo = new WWDocInfo_Object();
     // </xsl:comment>
    </html:script>
    <html:script type="text/javascript" language="JavaScript1.2" src="scripts/docinfo_tabledata.js"></html:script>
    <html:script type="text/javascript" language="JavaScript1.2" src="scripts/docinfo_number.js"></html:script>
    <html:script type="text/javascript" language="JavaScript1.2">
     <xsl:comment>
        // Load DocInfo data
        //
        WWLoadDocInfoData();
        WWLoadDocInfoNumberData();
     </xsl:comment>
    </html:script>
    <html:script type="text/javascript" language="JavaScript1.2">
     <xsl:comment>
        var  GlobalHighlightElement = null;

        function  WWRefreshStyleSheets()
        {
          var  VarMaxIndex;
          var  VarIndex;
          var  VarStyleSheet;

          for (VarMaxIndex = document.styleSheets.length, VarIndex = 0 ; VarIndex &lt; VarMaxIndex ; VarIndex++)
          {
            VarStyleSheet = document.styleSheets[VarIndex];
            if (VarStyleSheet.href.length &gt; 0)
            {
              VarStyleSheet.href = VarStyleSheet.href;
            }
          }

          WWUpdateHighlight();
        }

        function  WWOnClick()
        {
          var  VarFound;
          var  VarElement;
          var  VarAttribute;

          if (window.event != null)
          {
            VarElement = window.event.srcElement;
            if (VarElement != GlobalHighlightElement)
            {
              VarFound = false;
              while (( ! VarFound) &amp;&amp;
                     (typeof(VarElement) != "undefined") &amp;&amp;
                     (VarElement != null) &amp;&amp;
                     (VarElement != document.body))
              {
                if ((VarElement.tagName == "DIV") ||
                    (VarElement.tagName == "OL") ||
                    (VarElement.tagName == "UL") ||
                    (VarElement.tagName == "LI") ||
                    (VarElement.tagName == "BLOCKQUOTE") ||
                    (VarElement.tagName == "IMG") ||
                    (VarElement.tagName == "SPAN") ||
                    (VarElement.tagName == "TABLE"))
                {
                  VarAttribute = VarElement.getAttribute("data-id");
                  if ((typeof(VarAttribute) != "undefined") &amp;&amp;
                      (VarAttribute != null))
                  {
                    VarFound = true;
                  }
                  else
                  {
                    VarElement = VarElement.parentNode;
                  }
                }
                else
                {
                  VarElement = VarElement.parentNode;
                }
              }

              if (VarFound)
              {
                WWSetElement(VarElement);
              }
              else
              {
                WWSetElement(null);
              }
            }
          }

          return true;
        }

        function  WWOnSelectStart()
        {
          return false;
        }

        function  WWSetElement(ParamElement)
        {
          var  VarHighlightElement;

          if (ParamElement != null)
          {
            GlobalHighlightElement = ParamElement;
            WWUpdateHighlight();
          }
          else
          {
            if (GlobalHighlightElement != null)
            {
              VarHighlightElement = document.getElementById("highlight");
              VarHighlightElement.style.pixelLeft = 0;
              VarHighlightElement.style.pixelTop = 0;
              VarHighlightElement.style.display = "none";
              VarHighlightElement.style.visibility = "hidden";
            }

            GlobalHighlightElement = null;
          }
        }

        function  WWBrowserPosition_Object(ParamLeft,
                                           ParamTop)
        {
          this.mLeft = ParamLeft;
          this.mTop  = ParamTop;
        }

        function  WWBrowser_GetElementScrollPosition(ParamElement)
        {
          var  VarScrollPosition = null;
          var  VarOffsetParentElement;

          // Get element scroll position
          //
          VarScrollPosition = new WWBrowserPosition_Object(ParamElement.offsetLeft,
                                                           ParamElement.offsetTop);

          // Account for parent offsets
          //
          VarOffsetParentElement = ParamElement.offsetParent;
          while ((typeof(VarOffsetParentElement) != "undefined") &amp;&amp;
                 (VarOffsetParentElement != null))
          {
            VarScrollPosition.mLeft += VarOffsetParentElement.offsetLeft;
            VarScrollPosition.mTop += VarOffsetParentElement.offsetTop;

            VarOffsetParentElement = VarOffsetParentElement.offsetParent;
          }

          return VarScrollPosition;
        }

        function  WWUpdateHighlight()
        {
          var  VarHighlightElement;
          var  VarDimensions;
          var  VarBoundingRect;
          var  VarElementScrollPosition;

          if (GlobalHighlightElement != null)
          {
            // Get maximum visible offset positions
            //
            if ((typeof(window.document.documentElement) != "undefined") &amp;&amp;
                (typeof(window.document.documentElement.clientWidth) != "undefined") &amp;&amp;
                (typeof(window.document.documentElement.clientHeight) != "undefined") &amp;&amp;
                ((window.document.documentElement.clientWidth != 0) ||
                 (window.document.documentElement.clientHeight != 0)))
            {
              VarDimensions = { mWidth: window.document.documentElement.clientWidth,
                                mHeight: window.document.documentElement.clientHeight };
            }
            else
            {
              VarDimensions = { mWidth: window.document.body.clientWidth,
                                mHeight: window.document.body.clientHeight };
            }

            VarBoundingRect = GlobalHighlightElement.getBoundingClientRect();
            VarElementScrollPosition = WWBrowser_GetElementScrollPosition(GlobalHighlightElement);

            VarHighlightElement = document.getElementById("highlight");

            VarHighlightElement.style.pixelLeft = VarElementScrollPosition.mLeft - 4;
            VarHighlightElement.style.pixelTop = VarElementScrollPosition.mTop - 2;
            VarHighlightElement.style.width = VarBoundingRect.right - VarBoundingRect.left + 4 + 'px';
//            VarHighlightElement.style.width = VarDimensions.mWidth;
            VarHighlightElement.style.height = VarBoundingRect.bottom - VarBoundingRect.top + 4 + 'px';
            VarHighlightElement.style.display = "block";
            VarHighlightElement.style.visibility = "visible";
          }
        }

        function  WWOnResize()
        {
          WWUpdateHighlight();

          return true;
        }

        function  WWOnLoad()
        {
          document.onclick = WWOnClick;
          document.onselectstart = WWOnSelectStart;
          document.body.onresize = WWOnResize;

          WWDocInfo.fUpdateProperties();
        }
      // </xsl:comment>
    </html:script>
   </html:head>

   <html:body onload="WWOnLoad()">
    <xsl:call-template name="Content">
     <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
     <xsl:with-param name="ParamContent" select="$ParamDocument/wwdoc:Document/wwdoc:Content" />
    </xsl:call-template>

    <html:div id="highlight" style="display: none; visibility: hidden; position: absolute; left: 4px; top: 20px; z-index: 99; border-style: solid; border-color: #f69322; border-width: 0px; border-left-width: 2px; border-right-width: 2px; border-radius: 6px;  pointer-events: none;" data-type="Highlight">
     <html:div style="background-color: #f69322; opacity: 0.1; filter:alpha(opacity=10); width: 100%; height: 100%; pointer-events: none;">
      &#160;
     </html:div>
    </html:div>
    <html:script>
     <xsl:comment>
      WWDocInfo.fPreWriteBulletImages();
     // </xsl:comment>
    </html:script>
   </html:body>
  </html:html>
 </xsl:template>


 <xsl:template name="Content">
  <xsl:param name="ParamPreviewImageInfo" />
  <xsl:param name="ParamContent" />

  <xsl:apply-templates select="$ParamContent/*" mode="wwmode:content">
   <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
  </xsl:apply-templates>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:variable name="VarParagraph" select="." />

  <html:div id="{wwstring:NCNAME($VarParagraph/@id)}" class="{wwstring:CSSClassName($VarParagraph/@stylename)}" data-id="{$VarParagraph/@id}" data-style="{$VarParagraph/@stylename}" data-type="paragraph">
   <!-- Number handled via JavaScript -->
   <!--                               -->
   <html:span id="{wwstring:NCNAME($VarParagraph/@id)}_PositionWrapper">
    <html:span id="{wwstring:NCNAME($VarParagraph/@id)}_Number">
     <html:img id="{wwstring:NCNAME($VarParagraph/@id)}_BulletImage" src="preview_images/dummy.gif" style="visibility: hidden; display: none" />
    </html:span>
   </html:span>

   <!-- Emit paragraph -->
   <!--                -->
   <xsl:choose>
    <!-- Empty paragraph -->
    <!--                 -->
    <xsl:when test="(count($VarParagraph/wwdoc:*) = 1) and (count($VarParagraph/wwdoc:*/wwdoc:*) = 0)">
     &#160;
    </xsl:when>

    <!-- Paragraph has contents -->
    <!--                        -->
    <xsl:otherwise>
     <!-- Text Runs -->
     <!--           -->
     <xsl:call-template name="ParagraphTextRuns">
      <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
      <xsl:with-param name="ParamContextNodes" select="$VarParagraph/wwdoc:TextRun" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </html:div>
<xsl:text>
</xsl:text>
 </xsl:template>


 <xsl:template name="ParagraphTextRuns">
  <xsl:param name="ParamPreviewImageInfo" />
  <xsl:param name="ParamContextNodes" />

  <!-- Iterate text runs explicitly so that position() will match override IDs -->
  <!--                                                                         -->
  <xsl:for-each select="$ParamContextNodes">
   <xsl:variable name="VarContextNode" select="." />

   <xsl:choose>
    <xsl:when test="string-length(@stylename) &gt; 0">
     <!-- Character Style -->
     <!--                 -->
     <xsl:variable name="VarCharacterID" select="concat(wwstring:NCNAME(../@id), '_Character_', position())" />
     <html:span id="{$VarCharacterID}" class="{wwstring:CSSClassName(@stylename)}" data-id="{$VarContextNode/@id}" data-style="{$VarContextNode/@stylename}" data-type="character">
      <xsl:apply-templates select="./*" mode="wwmode:textrun">
       <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
      </xsl:apply-templates>
     </html:span>
    </xsl:when>

    <xsl:when test="count(./wwdoc:Style) &gt; 0">
     <!-- Character Style Override -->
     <!--                          -->
     <xsl:variable name="VarCharacterID" select="concat(wwstring:NCNAME(../@id), '_Character_', position())" />
     <html:span id="{$VarCharacterID}" data-id="{$VarContextNode/@id}" data-style="{$VarContextNode/@stylename}" data-type="character">
      <xsl:apply-templates select="./*" mode="wwmode:textrun">
       <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
      </xsl:apply-templates>
     </html:span>
    </xsl:when>

    <xsl:otherwise>
     <xsl:apply-templates select="./*" mode="wwmode:textrun">
      <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
     </xsl:apply-templates>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:call-template name="ParagraphTextRuns">
   <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
   <xsl:with-param name="ParamContextNodes" select="." />
  </xsl:call-template>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:variable name="VarList" select="." />

  <xsl:choose>
   <xsl:when test="$VarList/@ordered = 'True'">
    <html:ol id="{wwstring:NCNAME($VarList/@id)}" class="{wwstring:CSSClassName($VarList/@stylename)} grid-wrapper" data-id="{$VarList/@id}" data-style="{$VarList/@stylename}" data-type="paragraph">
     <xsl:apply-templates select="$VarList/*" mode="wwmode:content">
      <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
     </xsl:apply-templates>
    </html:ol>
   </xsl:when>
   <xsl:otherwise>
    <html:ul id="{wwstring:NCNAME($VarList/@id)}" class="{wwstring:CSSClassName($VarList/@stylename)} grid-wrapper" data-id="{$VarList/@id}" data-style="{$VarList/@stylename}" data-type="paragraph">
     <xsl:apply-templates select="$VarList/*" mode="wwmode:content">
      <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
     </xsl:apply-templates>
    </html:ul>
   </xsl:otherwise>
  </xsl:choose>

<xsl:text>
</xsl:text>
 </xsl:template>

 <xsl:template match="wwdoc:ListItem" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:variable name="VarListItem" select="." />

  <html:li id="{wwstring:NCNAME($VarListItem/@id)}" class="{wwstring:CSSClassName($VarListItem/@stylename)} grid-wrapper" data-id="{$VarListItem/@id}" data-style="{$VarListItem/@stylename}" data-type="paragraph">
   <xsl:apply-templates select="$VarListItem/*" mode="wwmode:content">
    <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
   </xsl:apply-templates>
  </html:li>
<xsl:text>
</xsl:text>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:variable name="VarBlock" select="." />

  <html:div id="{wwstring:NCNAME($VarBlock/@id)}" class="{wwstring:CSSClassName($VarBlock/@stylename)} grid-wrapper" data-id="{$VarBlock/@id}" data-style="{$VarBlock/@stylename}" data-type="paragraph">
   <xsl:apply-templates select="$VarBlock/*" mode="wwmode:content">
    <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
   </xsl:apply-templates>
  </html:div>
<xsl:text>
</xsl:text>
 </xsl:template>


 <xsl:template match="wwdoc:Note" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <!-- Implement notes -->
  <!--                 -->
 </xsl:template>


 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <html:br />
 </xsl:template>


 <xsl:template match="wwdoc:IndexMarker" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <!-- Ignore index markers -->
  <!--                      -->
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <!-- Ignore markers -->
  <!--                -->
 </xsl:template>


 <xsl:template match="wwdoc:Text" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:value-of select="@value" />
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:variable name="VarTable" select="." />

  <xsl:variable name="VarTableAlignID" select="concat(wwstring:NCNAME($VarTable/@id), '_horizontal_alignment')" />

  <html:div id="{$VarTableAlignID}">

   <html:table id="{wwstring:NCNAME($VarTable/@id)}" class="{wwstring:CSSClassName($VarTable/@stylename)} grid-wrapper" cellspacing="0" data-id="{$VarTable/@id}" data-style="{$VarTable/@stylename}" data-type="table">

    <xsl:for-each select="$VarTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
     <xsl:variable name="VarCaption" select="." />

     <html:caption>

      <xsl:apply-templates select="$VarCaption/*" mode="wwmode:content">
       <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
      </xsl:apply-templates>

     </html:caption>
<xsl:text>
</xsl:text>
    </xsl:for-each>

    <xsl:for-each select="wwdoc:TableHead|wwdoc:TableBody|wwdoc:TableFoot">
     <xsl:for-each select="wwdoc:TableRow">
      <html:tr>
<xsl:text>
</xsl:text>

      <xsl:for-each select="wwdoc:TableCell">
       <xsl:variable name="VarTableCell" select="." />

       <xsl:variable name="VarColumnSpan" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
       <xsl:variable name="VarRowSpan" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'row-span']/@value" />

       <html:td id="{wwstring:NCNAME(@id)}" class="grid-wrapper">
        <xsl:if test="number($VarColumnSpan) &gt; 0">
         <xsl:attribute name="colspan">
          <xsl:value-of select="number($VarColumnSpan)" />
         </xsl:attribute>
        </xsl:if>
        <xsl:if test="number($VarRowSpan) &gt; 0">
         <xsl:attribute name="rowspan">
          <xsl:value-of select="number($VarRowSpan)" />
         </xsl:attribute>
        </xsl:if>
<xsl:text>
</xsl:text>

       <xsl:apply-templates select="$VarTableCell/*" mode="wwmode:content">
        <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
       </xsl:apply-templates>

       </html:td>
<xsl:text>
</xsl:text>
      </xsl:for-each>

      </html:tr>
<xsl:text>
</xsl:text>
     </xsl:for-each>
    </xsl:for-each>

   </html:table>
  </html:div>
<xsl:text>
</xsl:text>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:content">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:call-template name="Frame">
   <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
   <xsl:with-param name="ParamFrame" select="." />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:textrun">
  <xsl:param name="ParamPreviewImageInfo" />

  <xsl:call-template name="Frame">
   <xsl:with-param name="ParamPreviewImageInfo" select="$ParamPreviewImageInfo" />
   <xsl:with-param name="ParamFrame" select="." />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="Frame">
  <xsl:param name="ParamPreviewImageInfo" />
  <xsl:param name="ParamFrame" />

  <!-- Locate preview image -->
  <!--                      -->
  <xsl:for-each select="$ParamPreviewImageInfo[1]">
   <xsl:variable name="VarPreviewImageInfo" select="key('wwimageinfo-imageinfo-by-id', $ParamFrame/@id)" />

   <xsl:variable name="VarRule" select="wwprojext:GetRule('Graphic', $ParamFrame/@stylename)" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveContextRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamFrame" />
     <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$ParamFrame/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
     <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- CSS properties for image wrapper element -->
   <!--                                          -->
   <xsl:variable name="VarCSSImgWrapperPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateImageWrapperProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$VarPreviewImageInfo[1]/@path" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarCSSImgWrapperProperties" select="msxsl:node-set($VarCSSImgWrapperPropertiesAsXML)/wwproject:Property" />

   <!-- Image wrapper style attribute value -->
   <!--                                     -->
   <xsl:variable name="VarImgWrapperStyle">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSImgWrapperProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:variable>

   <!-- CSS properties for image object element -->
   <!--                                         -->
   <xsl:variable name="VarCSSImgObjectPropertiesAsXML">
    <xsl:call-template name="CSS-TranslateImageObjectProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamFromAbsoluteURI" select="$VarPreviewImageInfo[1]/@path" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarCSSImgObjectProperties" select="msxsl:node-set($VarCSSImgObjectPropertiesAsXML)/wwproject:Property" />

   <!-- Image object style attribute value -->
   <!--                                    -->
   <xsl:variable name="VarImgObjectStyle">
    <xsl:call-template name="CSS-InlineProperties">
     <xsl:with-param name="ParamProperties" select="$VarCSSImgObjectProperties[string-length(@Value) &gt; 0]" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Image attributes -->
   <!--                  -->
   <xsl:variable name="VarWidth">
    <xsl:choose>
     <xsl:when test="$VarPreviewImageInfo[1]/@width &gt; 0">
      <xsl:value-of select="concat($VarPreviewImageInfo[1]/@width, 'px')" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="concat(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt')" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarHeight">
    <xsl:choose>
     <xsl:when test="$VarPreviewImageInfo[1]/@height &gt; 0">
      <xsl:value-of select="concat($VarPreviewImageInfo[1]/@height, 'px')" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="concat(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt')" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <html:span style="{$VarImgWrapperStyle}">
    <xsl:choose>
     <xsl:when test="count($VarPreviewImageInfo) &gt; 0">
      <!-- Image -->
      <!--       -->
      <html:img id="{wwstring:NCNAME($VarPreviewImageInfo[1]/@id)}" class="{wwstring:CSSClassName($ParamFrame/@stylename)}" src="{$VarPreviewImageInfo[1]/@path}" style="{$VarImgObjectStyle}" width="{$VarWidth}" height="{$VarHeight}" data-id="{$ParamFrame/@id}" data-style="{$ParamFrame/@stylename}" data-type="graphic" />
     </xsl:when>

     <xsl:otherwise>
      <!-- Image missing -->
      <!--               -->
      <html:span style="{concat($VarImgObjectStyle, 'width: ', $VarWidth, '; height: ', $VarHeight, '; font-size: 1px; border-width: 1px; border-style: solid; border-color: yellow; background-color: gray;')}">
       &#160;
      </html:span>
     </xsl:otherwise>
    </xsl:choose>
   </html:span>

  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
