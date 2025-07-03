<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwbehaviorsscript="urn:WebWorks-Behaviors-Finalize-Script"
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
                              exclude-result-prefixes="xsl msxsl wwbehaviors wwbehaviorsscript wwsplits wwmode wwfiles wwdoc wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:namespace-alias stylesheet-prefix="wwbehaviors" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwbehaviors-by-id" match="wwbehaviors:*" use="@id" />
 <xsl:key name="wwbehaviors-behaviors-by-windowtype-and-splitid" match="wwbehaviors:*" use="concat(@window-type, ':', ancestor::wwbehaviors:Split/@id)" />


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
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarDocumentBehaviorsFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarProgressFilesStart" select="wwprogress:Start(count($VarDocumentBehaviorsFiles))" />

    <xsl:for-each select="$VarDocumentBehaviorsFiles">
     <xsl:variable name="VarDocumentBehaviorsFile" select="." />

     <xsl:variable name="VarProgressFileStart" select="wwprogress:Start(1)" />

     <!-- Up-to-date? -->
     <!--             -->
     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarDocumentBehaviorsFile/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarDocumentBehaviorsFile/@groupID, $VarDocumentBehaviorsFile/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <xsl:call-template name="Finalize">
        <xsl:with-param name="ParamDocumentBehaviorsFile" select="$VarDocumentBehaviorsFile" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'no')" />
     </xsl:if>

     <!-- Record file -->
     <!--             -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarDocumentBehaviorsFile/@path}" checksum="{$VarDocumentBehaviorsFile/@checksum}" groupID="{$VarDocumentBehaviorsFile/@groupID}" documentID="{$VarDocumentBehaviorsFile/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarProgressFileEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressFilesEnd" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <msxsl:script language="C#" implements-prefix="wwbehaviorsscript">
  <![CDATA[
    static private readonly System.IO.StringReader  smEmptyStringReader = new System.IO.StringReader("<?xml version=\"1.0\" encoding=\"utf-8\" ?><Empty />");
    static private readonly XPathDocument           smEmptyXPathDocument = new XPathDocument(smEmptyStringReader);
    static private readonly XPathNodeIterator       smEmptyXPathNodeIterator = smEmptyXPathDocument.CreateNavigator().Select("/*");

    private class  DropDownElement
    {
      private string  mPrefix = "";
      private string  mLocalName = "";
      private string  mNamespaceURI = "";
      private string  mAttributeID = "";
      private string  mAttributeDropDown = "";

      public DropDownElement()
      {
      }

      public string  Prefix
      {
        get { return this.mPrefix; }
      }

      public string  LocalName
      {
        get { return this.mLocalName; }
      }

      public string  NamespaceURI
      {
        get { return this.mNamespaceURI; }
      }

      public string  AttributeID
      {
        get { return this.mAttributeID; }
      }

      public string  AttributeDropDown
      {
        get { return this.mAttributeDropDown; }
        set { this.mAttributeDropDown = value; }
      }

      public void  Record(XPathNavigator  navigator)
      {
        // Reset fields
        //
        this.mPrefix = String.Empty;
        this.mLocalName = String.Empty;
        this.mNamespaceURI = String.Empty;
        this.mAttributeID = String.Empty;
        this.mAttributeDropDown = String.Empty;

        // Record from navigator
        //
        if (navigator.NodeType == XPathNodeType.Element)
        {
          XPathNavigator  attributeNavigator;

          this.mPrefix = navigator.Prefix;
          this.mLocalName = navigator.LocalName;
          this.mNamespaceURI = navigator.NamespaceURI;

          attributeNavigator = navigator.Clone();
          if (attributeNavigator.MoveToFirstAttribute())
          {
            do
            {
              if (attributeNavigator.LocalName.ToLower().Equals("id"))
              {
                this.mAttributeID = attributeNavigator.Value;
              }
              else if (attributeNavigator.LocalName.ToLower().Equals("dropdown"))
              {
                this.mAttributeDropDown = attributeNavigator.Value;
              }
            } while (attributeNavigator.MoveToNextAttribute());
          }
        }
      }

      public void  Write(ref XmlTextWriter  documentWriter)
      {
        if ((this.mLocalName.Length > 0) &&
            (this.mAttributeID.Length > 0) &&
            (this.mAttributeDropDown.Length > 0))
        {
          documentWriter.WriteStartElement(this.mPrefix, this.mLocalName, this.mNamespaceURI);
          documentWriter.WriteStartAttribute("", "id", "");
          documentWriter.WriteString(this.mAttributeID);
          documentWriter.WriteEndAttribute();
          documentWriter.WriteStartAttribute("", "dropdown", "");
          documentWriter.WriteString(this.mAttributeDropDown);
          documentWriter.WriteEndAttribute();
          documentWriter.WriteEndElement();
        }
      }
    }

    private void  WriteDropDownElements(ref XmlTextWriter    documentWriter,
                                        ref bool             dropDownOpen,
                                        ref DropDownElement  previousDropDownElement,
                                            bool             last,
                                            XPathNavigator   navigator)
    {
      if (navigator.NodeType == XPathNodeType.Element)
      {
        DropDownElement  dropDownElement;

        dropDownElement = new DropDownElement();
        dropDownElement.Record(navigator);

        // Set dropdown attribute
        //
        if (dropDownOpen)
        {
          if ((dropDownElement.AttributeDropDown == "break") ||
              (dropDownElement.AttributeDropDown == "start-open") ||
              (dropDownElement.AttributeDropDown == "start-closed"))
          {
            // Force previous dropdown to end
            //
            if (previousDropDownElement.AttributeDropDown == "break")
            {
              // Nothing to do
              //
            }
            else if ((previousDropDownElement.AttributeDropDown == "start-open") ||
                      (previousDropDownElement.AttributeDropDown == "start-closed"))
            {
              previousDropDownElement.AttributeDropDown = "break";
            }
            else if ((previousDropDownElement.AttributeDropDown == String.Empty) ||
                     (previousDropDownElement.AttributeDropDown == "continue"))
            {
              // Close drop down
              //
              previousDropDownElement.AttributeDropDown = "end";

              // Break or new dropdown?
              //
              if (dropDownElement.AttributeDropDown == "break")
              {
                dropDownOpen = false;
              }
            }
            else if (previousDropDownElement.AttributeDropDown == "end")
            {
              // Nothing to do
              //
            }
          }
          else if ((dropDownElement.AttributeDropDown == String.Empty) ||
                   (dropDownElement.AttributeDropDown == "continue"))
          {
            // Close drop down if last open child
            //
            if (last)
            {
              // Close drop down
              //
              dropDownElement.AttributeDropDown = "end";
              dropDownOpen = false;
            }
          }
          else if (dropDownElement.AttributeDropDown == "end")
          {
            // Close drop down
            //
            dropDownOpen = false;
          }
        }
        else
        {
          if (dropDownElement.AttributeDropDown == "break")
          {
            // Nothing to do
            //
          }
          else if ((dropDownElement.AttributeDropDown == "start-open") ||
                   (dropDownElement.AttributeDropDown == "start-closed"))
          {
            // Open drop down
            //
            if (!last)
            {
              dropDownOpen = true;
            }
            else
            {
              dropDownElement.AttributeDropDown = "continue";
            }
          }
          else if ((dropDownElement.AttributeDropDown == String.Empty) ||
                   (dropDownElement.AttributeDropDown == "continue"))
          {
            // Nothing to do
            //
          }
          else if (dropDownElement.AttributeDropDown == "end")
          {
            dropDownElement.AttributeDropDown = "continue";
          }
        }

        // Write previous
        //
        if (previousDropDownElement.AttributeDropDown == "continue")
        {
          previousDropDownElement.AttributeDropDown = String.Empty;
        }
        previousDropDownElement.Write(ref documentWriter);

        // Update previous
        //
        previousDropDownElement = dropDownElement;

        // Process children
        //
        if (navigator.HasChildren)
        {
          XPathNavigator   childNavigator;
          bool             childDropDownOpen;
          DropDownElement  childPreviousDropDownElement;

          childNavigator = navigator.Clone();
          childDropDownOpen = false;
          childPreviousDropDownElement = new DropDownElement();
          childNavigator.MoveToFirstChild();
          do
          {
            XPathNavigator childNavigatorClone = childNavigator.Clone();
            bool lastChild = (!childNavigatorClone.MoveToNext());

            this.WriteDropDownElements(ref documentWriter, ref childDropDownOpen, ref childPreviousDropDownElement, lastChild, childNavigator);
          } while (childNavigator.MoveToNext());

          // Write previous
          //
          if (childPreviousDropDownElement.AttributeDropDown == "continue")
          {
            childPreviousDropDownElement.AttributeDropDown = String.Empty;
          }
          childPreviousDropDownElement.Write(ref documentWriter);
        }
      }
    }

    private XPathNodeIterator  FinalizeDropDowns(XPathNodeIterator  inputIterator)
    {
      XPathNodeIterator  result;
      StringBuilder      buffer;
      XPathDocument      xpathDocument;

      buffer = new StringBuilder(8192);
      buffer.Length = 0;

      // Create document
      //
      using(System.IO.StringWriter  stringWriter = new System.IO.StringWriter(buffer))
      {
        XPathNodeIterator  iterator;
        XmlTextWriter      documentWriter;
        bool               dropDownOpen;
        DropDownElement    previousDropDownElement;

        iterator = inputIterator.Clone();

        dropDownOpen = false;
        previousDropDownElement = new DropDownElement();
        documentWriter = new XmlTextWriter(stringWriter);
        documentWriter.WriteStartDocument();
        documentWriter.WriteStartElement("wwbehaviors", "Behaviors", "urn:WebWorks-Behaviors-Schema");
        documentWriter.WriteStartElement("wwbehaviors", "AtLeastOne", "urn:WebWorks-Behaviors-Schema");
        documentWriter.WriteEndElement();

        if (iterator.MoveNext())
        {
          do
          {
            XPathNavigator childNavigatorClone = iterator.Current.Clone();
            bool lastChild = (!childNavigatorClone.MoveToNext());

            this.WriteDropDownElements(ref documentWriter, ref dropDownOpen, ref previousDropDownElement, lastChild, iterator.Current);
          } while (iterator.MoveNext());

          // Write previous
          //
          if (previousDropDownElement.AttributeDropDown == "continue")
          {
            previousDropDownElement.AttributeDropDown = String.Empty;
          }
          previousDropDownElement.Write(ref documentWriter);
        }

        documentWriter.WriteEndElement();
        documentWriter.WriteEndDocument();
        documentWriter.Close();

        // Drop references
        //
        documentWriter = null;
      }

      // Create XPathDocument
      //
      using(System.IO.StringReader  stringReader = new System.IO.StringReader(buffer.ToString()))
      {
        xpathDocument = new XPathDocument(stringReader);
      }

      // Get result
      //
      result = xpathDocument.CreateNavigator().Select("/*/*");

      // Drop references
      //
      xpathDocument = null;

      return result;
    }

    private XPathNodeIterator  FinalizeDropDowns(XPathNavigator  inputNavigator)
    {
      XPathNodeIterator  result;
      StringBuilder      buffer;
      XPathDocument      xpathDocument;

      buffer = new StringBuilder(8192);
      buffer.Length = 0;

      // Create document
      //
      using(System.IO.StringWriter  stringWriter = new System.IO.StringWriter(buffer))
      {
        XPathNavigator   navigator;
        XmlTextWriter    documentWriter;
        bool             dropDownOpen;
        DropDownElement  previousDropDownElement;

        navigator = inputNavigator.Clone();

        dropDownOpen = false;
        previousDropDownElement = new DropDownElement();
        documentWriter = new XmlTextWriter(stringWriter);
        documentWriter.WriteStartDocument();
        documentWriter.WriteStartElement(navigator.Prefix, "Behaviors", navigator.NamespaceURI);
        documentWriter.WriteStartElement(navigator.Prefix, "AtLeastOne", navigator.NamespaceURI);
        documentWriter.WriteEndElement();
        this.WriteDropDownElements(ref documentWriter, ref dropDownOpen, ref previousDropDownElement, false, navigator);
        previousDropDownElement.Write(ref documentWriter);
        documentWriter.WriteEndElement();
        documentWriter.WriteEndDocument();
        documentWriter.Close();

        // Drop references
        //
        documentWriter = null;
      }

      // Create XPathDocument
      //
      using(System.IO.StringReader  stringReader = new System.IO.StringReader(buffer.ToString()))
      {
        xpathDocument = new XPathDocument(stringReader);
      }

      // Get result
      //
      result = xpathDocument.CreateNavigator().Select("/*/*");

      // Drop references
      //
      xpathDocument = null;

      return result;
    }

    public XPathNodeIterator  FinalizeDropDowns(object  input)
    {
      XPathNodeIterator  result;

      // Iterator or navigator?
      //
      if (input is XPathNodeIterator)
      {
        result = this.FinalizeDropDowns(input as XPathNodeIterator);
      }
      else if (input is XPathNavigator)
      {
        result = this.FinalizeDropDowns(input as XPathNavigator);
      }
      else
      {
        result = smEmptyXPathNodeIterator.Clone();
      }

      return result;
    }

    private class  PopupElement
    {
      private string  mPrefix = String.Empty;
      private string  mLocalName = String.Empty;
      private string  mNamespaceURI = String.Empty;
      private string  mAttributeID = String.Empty;
      private string  mAttributePopup = String.Empty;
      private string  mAttributePopupID = String.Empty;
      private string  mAttributePopupPageRule = String.Empty;

      public PopupElement()
      {
      }

      public string  Prefix
      {
        get { return this.mPrefix; }
      }

      public string  LocalName
      {
        get { return this.mLocalName; }
      }

      public string  NamespaceURI
      {
        get { return this.mNamespaceURI; }
      }

      public string  AttributeID
      {
        get { return this.mAttributeID; }
      }

      public string  AttributePopup
      {
        get { return this.mAttributePopup; }
        set { this.mAttributePopup = value; }
      }

      public string  AttributePopupID
      {
        get { return this.mAttributePopupID; }
        set { this.mAttributePopupID = value; }
      }

      public string  AttributePopupPageRule
      {
        get { return this.mAttributePopupPageRule; }
        set { this.mAttributePopupPageRule = value; }
      }

      public void  Record(XPathNavigator  navigator)
      {
        // Reset fields
        //
        this.mPrefix = String.Empty;
        this.mLocalName = String.Empty;
        this.mNamespaceURI = String.Empty;
        this.mAttributeID = String.Empty;
        this.mAttributePopup = String.Empty;
        this.mAttributePopupID = String.Empty;
        this.mAttributePopupPageRule = String.Empty;

        // Record from navigator
        //
        if (navigator.NodeType == XPathNodeType.Element)
        {
          XPathNavigator  attributeNavigator;

          this.mPrefix = navigator.Prefix;
          this.mLocalName = navigator.LocalName;
          this.mNamespaceURI = navigator.NamespaceURI;

          attributeNavigator = navigator.Clone();
          if (attributeNavigator.MoveToFirstAttribute())
          {
            do
            {
              string  attributeLocalName;

              attributeLocalName = attributeNavigator.LocalName.ToLower();

              if (attributeLocalName.Equals("id"))
              {
                this.mAttributeID = attributeNavigator.Value;
              }
              else if (attributeLocalName.Equals("popup"))
              {
                this.mAttributePopup = attributeNavigator.Value;
              }
              else if (attributeLocalName.Equals("popup-page-rule"))
              {
                this.mAttributePopupPageRule = attributeNavigator.Value;
              }
            } while (attributeNavigator.MoveToNextAttribute());
          }
        }
      }

      public void  Write(ref XmlTextWriter  documentWriter)
      {
        if ((this.mLocalName.Length > 0) &&
            (this.mAttributeID.Length > 0) &&
            (this.mAttributePopup.Length > 0) &&
            (this.mAttributePopupID.Length > 0))
        {
          documentWriter.WriteStartElement(this.mPrefix, this.mLocalName, this.mNamespaceURI);
          documentWriter.WriteStartAttribute("", "id", "");
          documentWriter.WriteString(this.mAttributeID);
          documentWriter.WriteEndAttribute();
          documentWriter.WriteStartAttribute("", "popup", "");
          documentWriter.WriteString(this.mAttributePopup);
          documentWriter.WriteEndAttribute();
          documentWriter.WriteStartAttribute("", "popupID", "");
          documentWriter.WriteString(this.mAttributePopupID);
          documentWriter.WriteEndAttribute();
          if (this.mAttributePopupPageRule.Length > 0)
          {
            documentWriter.WriteStartAttribute("", "popup-page-rule", "");
            documentWriter.WriteString(this.mAttributePopupPageRule);
            documentWriter.WriteEndAttribute();
          }
          documentWriter.WriteEndElement();
        }
      }
    }

    private void  WritePopupElements(ref XmlTextWriter   documentWriter,
                                     ref bool            popupOpen,
                                     ref PopupElement    definedPopupElement,
                                         XPathNavigator  navigator)
    {
      if (navigator.NodeType == XPathNodeType.Element)
      {
        PopupElement  popupElement;

        popupElement = new PopupElement();
        popupElement.Record(navigator);

        // Set popup attribute
        //
        if (popupOpen)
        {
          if (popupElement.AttributePopup == "define")
          {
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = false;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "define-no-output")
          {
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = false;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "start")
          {
            popupElement.AttributePopup = "define";
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = true;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "start-no-output")
          {
            popupElement.AttributePopup = "define-no-output";
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = true;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "append")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;
            }
            else
            {
              popupElement.AttributePopup = "none";
            }
          }
          else if (popupElement.AttributePopup == "append-no-output")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;
            }
            else
            {
              popupElement.AttributePopup = "none";
            }
          }
          else if (popupElement.AttributePopup == "end")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopup = (definedPopupElement.AttributePopup == "define") ? "append" : "append-no-output";
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;

              definedPopupElement.AttributePopupID = String.Empty;
            }
            else
            {
              popupElement.AttributePopup = "none";
            }
          }
          else if (popupElement.AttributePopup == "none")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopup = (definedPopupElement.AttributePopup == "define") ? "append" : "append-no-output";
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;
            }
          }
        }
        else
        {
          if (popupElement.AttributePopup == "define")
          {
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = false;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "define-no-output")
          {
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = false;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "start")
          {
            popupElement.AttributePopup = "define";
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = true;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "start-no-output")
          {
            popupElement.AttributePopup = "define-no-output";
            popupElement.AttributePopupID = popupElement.AttributeID;

            popupOpen = true;
            definedPopupElement = popupElement;
          }
          else if (popupElement.AttributePopup == "append")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;
            }
            else
            {
              popupElement.AttributePopup = "none";
            }
          }
          else if (popupElement.AttributePopup == "append-no-output")
          {
            if (definedPopupElement.AttributePopupID.Length > 0)
            {
              popupElement.AttributePopupID = definedPopupElement.AttributePopupID;
            }
            else
            {
              popupElement.AttributePopup = "none";
            }
          }
          else if (popupElement.AttributePopup == "end")
          {
            // No popup open
            //
            popupElement.AttributePopup = "none";
          }
          else if (popupElement.AttributePopup == "none")
          {
            // Nothing to do
            //
          }
        }

        // Write current
        //
        popupElement.Write(ref documentWriter);

        // Process children
        //
        if (navigator.HasChildren)
        {
          XPathNavigator  childNavigator;
          bool            childPopupOpen;
          PopupElement    childDefinedPopupElement;

          childNavigator = navigator.Clone();
          childPopupOpen = false;
          childDefinedPopupElement = new PopupElement();
          childNavigator.MoveToFirstChild();
          do
          {
            this.WritePopupElements(ref documentWriter, ref childPopupOpen, ref childDefinedPopupElement, childNavigator);
          } while (childNavigator.MoveToNext());
        }
      }
    }

    private XPathNodeIterator  FinalizePopups(XPathNodeIterator  inputIterator)
    {
      XPathNodeIterator  result;
      StringBuilder      buffer;
      XPathDocument      xpathDocument;

      buffer = new StringBuilder(8192);
      buffer.Length = 0;

      // Create document
      //
      using(System.IO.StringWriter  stringWriter = new System.IO.StringWriter(buffer))
      {
        XPathNodeIterator  iterator;
        XmlTextWriter      documentWriter;
        bool               popupOpen;
        PopupElement       definedPopupElement;

        iterator = inputIterator.Clone();

        popupOpen = false;
        definedPopupElement = new PopupElement();
        documentWriter = new XmlTextWriter(stringWriter);
        documentWriter.WriteStartDocument();
        documentWriter.WriteStartElement("wwbehaviors", "Behaviors", "urn:WebWorks-Behaviors-Schema");
        documentWriter.WriteStartElement("wwbehaviors", "AtLeastOne", "urn:WebWorks-Behaviors-Schema");
        documentWriter.WriteEndElement();

        if (iterator.MoveNext())
        {
          do
          {
            this.WritePopupElements(ref documentWriter, ref popupOpen, ref definedPopupElement, iterator.Current);
          } while (iterator.MoveNext());
        }

        documentWriter.WriteEndElement();
        documentWriter.WriteEndDocument();
        documentWriter.Close();

        // Drop references
        //
        documentWriter = null;
      }

      // Create XPathDocument
      //
      using(System.IO.StringReader  stringReader = new System.IO.StringReader(buffer.ToString()))
      {
        xpathDocument = new XPathDocument(stringReader);
      }

      // Get result
      //
      result = xpathDocument.CreateNavigator().Select("/*/*");

      // Drop references
      //
      xpathDocument = null;

      return result;
    }

    private XPathNodeIterator  FinalizePopups(XPathNavigator  inputNavigator)
    {
      XPathNodeIterator  result;
      StringBuilder      buffer;
      XPathDocument      xpathDocument;

      buffer = new StringBuilder(8192);
      buffer.Length = 0;

      // Create document
      //
      using(System.IO.StringWriter  stringWriter = new System.IO.StringWriter(buffer))
      {
        XPathNavigator  navigator;
        XmlTextWriter   documentWriter;
        bool            popupOpen;
        PopupElement    definedPopupElement;

        navigator = inputNavigator.Clone();

        popupOpen = false;
        definedPopupElement = new PopupElement();
        documentWriter = new XmlTextWriter(stringWriter);
        documentWriter.WriteStartDocument();
        documentWriter.WriteStartElement(navigator.Prefix, "Behaviors", navigator.NamespaceURI);
        documentWriter.WriteStartElement(navigator.Prefix, "AtLeastOne", navigator.NamespaceURI);
        documentWriter.WriteEndElement();
        this.WritePopupElements(ref documentWriter, ref popupOpen, ref definedPopupElement, navigator);
        documentWriter.WriteEndElement();
        documentWriter.WriteEndDocument();
        documentWriter.Close();

        // Drop references
        //
        documentWriter = null;
      }

      // Create XPathDocument
      //
      using(System.IO.StringReader  stringReader = new System.IO.StringReader(buffer.ToString()))
      {
        xpathDocument = new XPathDocument(stringReader);
      }

      // Get result
      //
      result = xpathDocument.CreateNavigator().Select("/*/*");

      // Drop references
      //
      xpathDocument = null;

      return result;
    }

    public XPathNodeIterator  FinalizePopups(object  input)
    {
      XPathNodeIterator  result;

      // Iterator or navigator?
      //
      if (input is XPathNodeIterator)
      {
        result = this.FinalizePopups(input as XPathNodeIterator);
      }
      else if (input is XPathNavigator)
      {
        result = this.FinalizePopups(input as XPathNavigator);
      }
      else
      {
        result = smEmptyXPathNodeIterator.Clone();
      }

      return result;
    }
  ]]>
 </msxsl:script>


 <xsl:template name="Finalize">
  <xsl:param name="ParamDocumentBehaviorsFile" />

  <!-- Load document behaviors -->
  <!--                         -->
  <xsl:variable name="VarDocumentBehaviors" select="wwexsldoc:LoadXMLWithoutResolver($ParamDocumentBehaviorsFile/@path, false())" />

  <!-- Behaviors -->
  <!--           -->
  <xsl:variable name="VarBehaviorElements" select="$VarDocumentBehaviors/wwbehaviors:Behaviors/*" />
  <xsl:variable name="VarFinalDropDowns" select="wwbehaviorsscript:FinalizeDropDowns($VarBehaviorElements)" />
  <xsl:variable name="VarFinalPopups" select="wwbehaviorsscript:FinalizePopups($VarBehaviorElements)" />
  <xsl:apply-templates select="$VarDocumentBehaviors" mode="wwmode:finalize">
   <xsl:with-param name="ParamFinalDropDowns" select="$VarFinalDropDowns" />
   <xsl:with-param name="ParamFinalPopups" select="$VarFinalPopups" />
  </xsl:apply-templates>
 </xsl:template>


 <!-- wwmode:finalize -->
 <!--                 -->

 <xsl:template match="/" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:finalize">
   <xsl:with-param name="ParamFinalDropDowns" select="$ParamFinalDropDowns" />
   <xsl:with-param name="ParamFinalPopups" select="$ParamFinalPopups" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwbehaviors:Behaviors" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />

  <!-- Preserve node -->
  <!--               -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:finalize">
    <xsl:with-param name="ParamFinalDropDowns" select="$ParamFinalDropDowns" />
    <xsl:with-param name="ParamFinalPopups" select="$ParamFinalPopups" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="wwbehaviors:Split" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />

  <!-- Preserve node -->
  <!--               -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- window-type -->
   <!--             -->
   <xsl:if test="string-length(@window-type) &gt; 0">
    <xsl:variable name="VarWindowTypeBehaviors" select="key('wwbehaviors-behaviors-by-windowtype-and-splitid', concat(@window-type, ':', @id))" />
    <xsl:for-each select="$VarWindowTypeBehaviors[1]">
     <xsl:attribute name="window-type">
      <xsl:value-of select="$VarWindowTypeBehaviors[last()]/@window-type" />
     </xsl:attribute>
    </xsl:for-each>
   </xsl:if>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:finalize">
    <xsl:with-param name="ParamFinalDropDowns" select="$ParamFinalDropDowns" />
    <xsl:with-param name="ParamFinalPopups" select="$ParamFinalPopups" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="wwbehaviors:*" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />
  <xsl:param name="ParamDocumentBehavior" select="." />

  <!-- Preserve node -->
  <!--               -->
  <xsl:copy>
   <xsl:copy-of select="@*[(local-name() != 'dropdown') and (local-name() != 'popup') and (local-name() != 'popup-page-rule')]" />

   <!-- Drop Down Attribute -->
   <!--                     -->
   <xsl:for-each select="$ParamFinalDropDowns[1]">
    <xsl:variable name="VarFinalDropDown" select="key('wwbehaviors-by-id', $ParamDocumentBehavior/@id)[1]" />

    <xsl:if test="count($VarFinalDropDown) = 1">
     <xsl:attribute name="dropdown">
      <xsl:value-of select="$VarFinalDropDown/@dropdown" />
     </xsl:attribute>
    </xsl:if>
   </xsl:for-each>

   <!-- Popup Attribute -->
   <!--                 -->
   <xsl:for-each select="$ParamFinalPopups[1]">
    <xsl:variable name="VarFinalPopup" select="key('wwbehaviors-by-id', $ParamDocumentBehavior/@id)[1]" />

    <xsl:if test="count($VarFinalPopup) = 1">
     <xsl:attribute name="popup">
      <xsl:value-of select="$VarFinalPopup/@popup" />
     </xsl:attribute>
     <xsl:attribute name="popupID">
      <xsl:value-of select="$VarFinalPopup/@popupID" />
     </xsl:attribute>
     <xsl:attribute name="popup-page-rule">
      <xsl:value-of select="$VarFinalPopup/@popup-page-rule" />
     </xsl:attribute>
    </xsl:if>
   </xsl:for-each>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:finalize">
    <xsl:with-param name="ParamFinalDropDowns" select="$ParamFinalDropDowns" />
    <xsl:with-param name="ParamFinalPopups" select="$ParamFinalPopups" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:finalize">
    <xsl:with-param name="ParamFinalDropDowns" select="$ParamFinalDropDowns" />
    <xsl:with-param name="ParamFinalPopups" select="$ParamFinalPopups" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:finalize">
  <xsl:param name="ParamFinalDropDowns" />
  <xsl:param name="ParamFinalPopups" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>
</xsl:stylesheet>
