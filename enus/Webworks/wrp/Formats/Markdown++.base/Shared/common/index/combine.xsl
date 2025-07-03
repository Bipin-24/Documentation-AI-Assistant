<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Index-Schema"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwindexcombine="urn:WebWorks-Index-Combine"
                              exclude-result-prefixes="xsl wwmode msxsl wwlinks wwfiles wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwindexcombine"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterLocaleType" />


 <xsl:namespace-alias stylesheet-prefix="wwindex" result-prefix="#default" />
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

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <!-- Load locale -->
    <!--             -->
    <xsl:variable name="VarFilesLocale" select="key('wwfiles-files-by-type', $ParameterLocaleType)" />
    <xsl:variable name="VarLocale" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesLocale/@path)" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:value-of select="wwprogress:Start(1)" />

     <!-- Call template -->
     <!--               -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Combine">
        <xsl:with-param name="ParamLocale" select="$VarLocale" />
        <xsl:with-param name="ParamFilesDocument" select="$VarFilesDocument" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesLocale/@path}" checksum="{$VarFilesLocale/@checksum}" groupID="{$VarFilesLocale/@groupID}" documentID="{$VarFilesLocale/@documentID}" />
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <msxsl:script language="C#" implements-prefix="wwindexcombine">
  <![CDATA[
    private class  XmlNodePair
    {
      private XmlNode  mLeft;
      private XmlNode  mRight;

      public XmlNodePair(XmlNode  left,
                         XmlNode  right)
      {
       this.mLeft = left;
       this.mRight = right;
      }

      public XmlNode  Left
      {
        get { return this.mLeft; }
      }

      public XmlNode  Right
      {
        get { return this.mRight; }
      }
    }

    private void  CombineEntries(XmlNode    parentNode,
                                 Hashtable  uniqueEntries,
                                 ArrayList  redundantEntryList,
                                 Hashtable  keyAttributes,
                                 ArrayList  grandchildNodeList)
    {
      string  key;

      // Reset workspace
      //
      uniqueEntries.Clear();
      redundantEntryList.Clear();
      keyAttributes.Clear();
      grandchildNodeList.Clear();

      // Combine children
      //
      foreach (XmlNode  childNode in parentNode.ChildNodes)
      {
        if ((childNode.NodeType == XmlNodeType.Element) &&
            (childNode.Name == "Entry") &&
            (childNode.NamespaceURI == "urn:WebWorks-Index-Schema"))
        {
          // Construct key
          //
          keyAttributes["name"] = "";
          keyAttributes["sort"] = "";
          keyAttributes["sectionposition"] = "";
          foreach (XmlAttribute  attribute in childNode.Attributes)
          {
            if (keyAttributes.ContainsKey(attribute.Name))
            {
              keyAttributes[attribute.Name] = attribute.Value;
            }
          }
          key = "Entry:"
              + keyAttributes["name"]
              + ":"
              + keyAttributes["sort"]
              + ":"
              + keyAttributes["sectionposition"];

          // First unique entry?
          //
          if (uniqueEntries.ContainsKey(key))
          {
            XmlNodePair  redundantEntryPair;

            // Record redundant entries
            //
            redundantEntryPair = new XmlNodePair(childNode, uniqueEntries[key] as XmlNode);
            redundantEntryList.Add(redundantEntryPair);
          }
          else
          {
            // Track unique entry
            //
            uniqueEntries[key] = childNode;
          }
        }
      }

      // Remove redundant entries
      //
      foreach (XmlNodePair  redundantEntryPair in redundantEntryList)
      {
        grandchildNodeList.Clear();

        // Entry exists, copy over child entries and links only
        //
        foreach (XmlNode  grandchildNode in redundantEntryPair.Left.ChildNodes)
        {
          if ((grandchildNode.NodeType == XmlNodeType.Element) &&
              ((grandchildNode.Name == "Entry") || (grandchildNode.Name == "Link")) &&
              (grandchildNode.NamespaceURI == "urn:WebWorks-Index-Schema"))
          {
            // Existing unique entry adopts children
            //
            grandchildNodeList.Add(grandchildNode);
          }
        }

        // Adopt grandchildren
        //
        foreach (XmlNode  grandchildNode in grandchildNodeList)
        {
          redundantEntryPair.Right.AppendChild(grandchildNode);
        }

        // Remove child
        //
        parentNode.RemoveChild(redundantEntryPair.Left);
      }

      // Combine grandchildren
      //
      foreach (XmlNode  childNode in parentNode)
      {
        this.CombineEntries(childNode, uniqueEntries, redundantEntryList, keyAttributes, grandchildNodeList);
      }
    }

    public XPathNodeIterator  CombineIndex(string  indexPath)
    {
      XPathNodeIterator  result;
      XmlDocument        indexDocument;
      Hashtable          uniqueEntries;
      ArrayList          redundantEntryList;
      Hashtable          keyAttributes;
      ArrayList          grandchildNodeList;

      indexDocument = new XmlDocument();

      // Create and load format
      //
      using(System.IO.FileStream  indexStream = new System.IO.FileStream(indexPath,
                                                                         System.IO.FileMode.Open,
                                                                         System.IO.FileAccess.Read,
                                                                         System.IO.FileShare.Read,
                                                                         8192))
      {
        indexDocument.Load(indexStream);
      }

      // Define workspace
      //
      uniqueEntries = new Hashtable();
      redundantEntryList = new ArrayList();
      keyAttributes = new Hashtable();
      grandchildNodeList = new ArrayList();

      foreach (XmlNode  node in indexDocument)
      {
        if (node.NodeType == XmlNodeType.Element)
        {
          this.CombineEntries(node, uniqueEntries, redundantEntryList, keyAttributes, grandchildNodeList);
        }
      }

      result =  indexDocument.CreateNavigator().Select("/");

      // Drop references
      //
      indexDocument = null;
      uniqueEntries = null;
      redundantEntryList = null;
      keyAttributes = null;
      grandchildNodeList = null;

      return result;
    }
  ]]>
 </msxsl:script>


 <xsl:template name="Combine">
  <xsl:param name="ParamLocale" />
  <xsl:param name="ParamFilesDocument" />

  <!-- Combined Entries Index -->
  <!--                        -->
  <wwindex:Index version="1.0">

   <!-- Add section groups -->
   <!--                    -->
   <xsl:for-each select="$ParamLocale/wwlocale:Locale/wwlocale:Index/wwlocale:Sections/wwlocale:Section">
    <xsl:variable name="VarSection" select="." />

    <xsl:for-each select="$VarSection/wwlocale:Group">
     <xsl:variable name="VarGroup" select="." />

     <wwindex:Group name="{$VarGroup/@name}" sort="{$VarGroup/@sort}" sectionposition="{$VarSection/@position}" />
    </xsl:for-each>
   </xsl:for-each>

   <!-- Combined identical index entries -->
   <!--                                  -->
   <xsl:for-each select="wwindexcombine:CombineIndex($ParamFilesDocument/@path)/wwindex:Index/wwindex:Entry">
    <xsl:copy-of select="." />
   </xsl:for-each>

  </wwindex:Index>
 </xsl:template>
</xsl:stylesheet>
