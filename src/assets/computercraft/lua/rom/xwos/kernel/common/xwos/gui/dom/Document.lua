--interface Document : Node {
--  readonly attribute DocumentType     doctype;
--  readonly attribute DOMImplementation  implementation;
--  readonly attribute Element          documentElement;
--  Element            createElement(in DOMString tagName)
--                                        raises(DOMException);
--  DocumentFragment   createDocumentFragment();
--  Text               createTextNode(in DOMString data);
--  Comment            createComment(in DOMString data);
--  CDATASection       createCDATASection(in DOMString data)
--                                        raises(DOMException);
--  ProcessingInstruction createProcessingInstruction(in DOMString target, 
--                                                    in DOMString data)
--                                        raises(DOMException);
--  Attr               createAttribute(in DOMString name)
--                                        raises(DOMException);
--  EntityReference    createEntityReference(in DOMString name)
--                                        raises(DOMException);
--  NodeList           getElementsByTagName(in DOMString tagname);
--  // Introduced in DOM Level 2:
--  Node               importNode(in Node importedNode, 
--                                in boolean deep)
--                                        raises(DOMException);
--  // Introduced in DOM Level 2:
--  Element            createElementNS(in DOMString namespaceURI, 
--                                     in DOMString qualifiedName)
--                                        raises(DOMException);
--  // Introduced in DOM Level 2:
--  Attr               createAttributeNS(in DOMString namespaceURI, 
--                                       in DOMString qualifiedName)
--                                        raises(DOMException);
--  // Introduced in DOM Level 2:
--  NodeList           getElementsByTagNameNS(in DOMString namespaceURI, 
--                                            in DOMString localName);
--  // Introduced in DOM Level 2:
--  Element            getElementById(in DOMString elementId);
--};
--
--Attributes
--doctype of type DocumentType, readonly
--The Document Type Declaration (see DocumentType) associated with this document. For HTML documents as well as XML documents without a document type declaration this returns null. The DOM Level 2 does not support editing the Document Type Declaration. docType cannot be altered in any way, including through the use of methods inherited from the Node interface, such as insertNode or removeNode.
--
--documentElement of type Element, readonly
--This is a convenience attribute that allows direct access to the child node that is the root element of the document. For HTML documents, this is the element with the tagName "HTML".
--
--implementation of type DOMImplementation, readonly
--The DOMImplementation object that handles this document. A DOM application may use objects from multiple implementations.
--
--Methods
--createAttribute
--Creates an Attr of the given name. Note that the Attr instance can then be set on an Element using the setAttributeNode method.
--To create an attribute with a qualified name and namespace URI, use the createAttributeNS method. 
--Parameters 
--name of type DOMString
--The name of the attribute.
--Return Value 
--Attr
--A new Attr object with the nodeName attribute set to name, and localName, prefix, and namespaceURI set to null. The value of the attribute is the empty string.
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified name contains an illegal character.
--
--createAttributeNS introduced in DOM Level 2
--Creates an attribute of the given qualified name and namespace URI. HTML-only DOM implementations do not need to implement this method. 
--Parameters 
--namespaceURI of type DOMString
--The namespace URI of the attribute to create.
--qualifiedName of type DOMString
--The qualified name of the attribute to instantiate.
--Return Value 
--Attr
--A new Attr object with the following attributes:
--Attribute
--Value
--Node.nodeName
--qualifiedName
--Node.namespaceURI
--namespaceURI
--Node.prefix
--prefix, extracted from qualifiedName, or null if there is no prefix
--Node.localName
--local name, extracted from qualifiedName
--Attr.name
--qualifiedName
--Node.nodeValue
--the empty string
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified qualified name contains an illegal character.
--NAMESPACE_ERR: Raised if the qualifiedName is malformed, if the qualifiedName has a prefix and the namespaceURI is null, if the qualifiedName has a prefix that is "xml" and the namespaceURI is different from "http://www.w3.org/XML/1998/namespace", or if the qualifiedName is "xmlns" and the namespaceURI is different from "http://www.w3.org/2000/xmlns/".
--
--createCDATASection
--Creates a CDATASection node whose value is the specified string. 
--Parameters 
--data of type DOMString
--The data for the CDATASection contents.
--Return Value 
--CDATASection
--The new CDATASection object.
--Exceptions 
--DOMException
--NOT_SUPPORTED_ERR: Raised if this document is an HTML document.
--
--createComment
--Creates a Comment node given the specified string. 
--Parameters 
--data of type DOMString
--The data for the node.
--Return Value 
--Comment
--The new Comment object.
--No Exceptions
--
--createDocumentFragment
--Creates an empty DocumentFragment object. 
--Return Value 
--DocumentFragment
--A new DocumentFragment.
--No Parameters
--No Exceptions
--
--createElement
--Creates an element of the type specified. Note that the instance returned implements the Element interface, so attributes can be specified directly on the returned object.
--In addition, if there are known attributes with default values, Attr nodes representing them are automatically created and attached to the element.
--To create an element with a qualified name and namespace URI, use the createElementNS method. 
--Parameters 
--tagName of type DOMString
--The name of the element type to instantiate. For XML, this is case-sensitive. For HTML, the tagName parameter may be provided in any case, but it must be mapped to the canonical uppercase form by the DOM implementation.
--Return Value 
--Element
--A new Element object with the nodeName attribute set to tagName, and localName, prefix, and namespaceURI set to null.
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified name contains an illegal character.
--
--createElementNS introduced in DOM Level 2
--Creates an element of the given qualified name and namespace URI. HTML-only DOM implementations do not need to implement this method. 
--Parameters 
--namespaceURI of type DOMString
--The namespace URI of the element to create.
--qualifiedName of type DOMString
--The qualified name of the element type to instantiate.
--Return Value 
--Element
--A new Element object with the following attributes:
--Attribute
--Value
--Node.nodeName
--qualifiedName
--Node.namespaceURI
--namespaceURI
--Node.prefix
--prefix, extracted from qualifiedName, or null if there is no prefix
--Node.localName
--local name, extracted from qualifiedName
--Element.tagName
--qualifiedName
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified qualified name contains an illegal character.
--NAMESPACE_ERR: Raised if the qualifiedName is malformed, if the qualifiedName has a prefix and the namespaceURI is null, or if the qualifiedName has a prefix that is "xml" and the namespaceURI is different from "http://www.w3.org/XML/1998/namespace" [Namespaces].
--
--createEntityReference
--Creates an EntityReference object. In addition, if the referenced entity is known, the child list of the EntityReference node is made the same as that of the corresponding Entity node. 
--Note: If any descendant of the Entity node has an unbound namespace prefix, the corresponding descendant of the created EntityReference node is also unbound; (its namespaceURI is null). The DOM Level 2 does not support any mechanism to resolve namespace prefixes.
--Parameters 
--name of type DOMString
--The name of the entity to reference.
--Return Value 
--EntityReference
--The new EntityReference object.
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified name contains an illegal character.
--NOT_SUPPORTED_ERR: Raised if this document is an HTML document.
--
--createProcessingInstruction
--Creates a ProcessingInstruction node given the specified name and data strings. 
--Parameters 
--target of type DOMString
--The target part of the processing instruction.
--data of type DOMString
--The data for the node.
--Return Value 
--ProcessingInstruction
--The new ProcessingInstruction object.
--Exceptions 
--DOMException
--INVALID_CHARACTER_ERR: Raised if the specified target contains an illegal character.
--NOT_SUPPORTED_ERR: Raised if this document is an HTML document.
--
--createTextNode
--Creates a Text node given the specified string. 
--Parameters 
--data of type DOMString
--The data for the node.
--Return Value 
--Text
--The new Text object.
--No Exceptions
--
--getElementById introduced in DOM Level 2
--Returns the Element whose ID is given by elementId. If no such element exists, returns null. Behavior is not defined if more than one element has this ID. 
--Note: The DOM implementation must have information that says which attributes are of type ID. Attributes with the name "ID" are not of type ID unless so defined. Implementations that do not know whether attributes are of type ID or not are expected to return null.
--Parameters 
--elementId of type DOMString
--The unique id value for an element.
--Return Value 
--Element
--The matching element.
--No Exceptions
--
--getElementsByTagName
--Returns a NodeList of all the Elements with a given tag name in the order in which they are encountered in a preorder traversal of the Document tree. 
--Parameters 
--tagname of type DOMString
--The name of the tag to match on. The special value "*" matches all tags.
--Return Value 
--NodeList
--A new NodeList object containing all the matched Elements.
--No Exceptions
--
--getElementsByTagNameNS introduced in DOM Level 2
--Returns a NodeList of all the Elements with a given local name and namespace URI in the order in which they are encountered in a preorder traversal of the Document tree. 
--Parameters 
--namespaceURI of type DOMString
--The namespace URI of the elements to match on. The special value "*" matches all namespaces.
--localName of type DOMString
--The local name of the elements to match on. The special value "*" matches all local names.
--Return Value 
--NodeList
--A new NodeList object containing all the matched Elements.
--No Exceptions
--
--importNode introduced in DOM Level 2
--Imports a node from another document to this document. The returned node has no parent; (parentNode is null). The source node is not altered or removed from the original document; this method creates a new copy of the source node.
--For all nodes, importing a node creates a node object owned by the importing document, with attribute values identical to the source node's nodeName and nodeType, plus the attributes related to namespaces (prefix, localName, and namespaceURI). As in the cloneNode operation on a Node, the source node is not altered.
--Additional information is copied as appropriate to the nodeType, attempting to mirror the behavior expected if a fragment of XML or HTML source was copied from one document to another, recognizing that the two documents may have different DTDs in the XML case. The following list describes the specifics for each type of node. 
--ATTRIBUTE_NODE
--The ownerElement attribute is set to null and the specified flag is set to true on the generated Attr. The descendants of the source Attr are recursively imported and the resulting nodes reassembled to form the corresponding subtree.
--Note that the deep parameter has no effect on Attr nodes; they always carry their children with them when imported.
--DOCUMENT_FRAGMENT_NODE
--If the deep option was set to true, the descendants of the source element are recursively imported and the resulting nodes reassembled to form the corresponding subtree. Otherwise, this simply generates an empty DocumentFragment.
--DOCUMENT_NODE
--Document nodes cannot be imported.
--DOCUMENT_TYPE_NODE
--DocumentType nodes cannot be imported.
--ELEMENT_NODE
--Specified attribute nodes of the source element are imported, and the generated Attr nodes are attached to the generated Element. Default attributes are not copied, though if the document being imported into defines default attributes for this element name, those are assigned. If the importNode deep parameter was set to true, the descendants of the source element are recursively imported and the resulting nodes reassembled to form the corresponding subtree.
--ENTITY_NODE
--Entity nodes can be imported, however in the current release of the DOM the DocumentType is readonly. Ability to add these imported nodes to a DocumentType will be considered for addition to a future release of the DOM.
--On import, the publicId, systemId, and notationName attributes are copied. If a deep import is requested, the descendants of the the source Entity are recursively imported and the resulting nodes reassembled to form the corresponding subtree.
--ENTITY_REFERENCE_NODE
--Only the EntityReference itself is copied, even if a deep import is requested, since the source and destination documents might have defined the entity differently. If the document being imported into provides a definition for this entity name, its value is assigned.
--NOTATION_NODE
--Notation nodes can be imported, however in the current release of the DOM the DocumentType is readonly. Ability to add these imported nodes to a DocumentType will be considered for addition to a future release of the DOM.
--On import, the publicId and systemId attributes are copied.
--Note that the deep parameter has no effect on Notation nodes since they never have any children.
--PROCESSING_INSTRUCTION_NODE
--The imported node copies its target and data values from those of the source node.
--TEXT_NODE, CDATA_SECTION_NODE, COMMENT_NODE
--These three types of nodes inheriting from CharacterData copy their data and length attributes from those of the source node.
--Parameters 
--importedNode of type Node
--The node to import.
--deep of type boolean
--If true, recursively import the subtree under the specified node; if false, import only the node itself, as explained above. This has no effect on Attr, EntityReference, and Notation nodes.
--Return Value 
--Node
--The imported node that belongs to this Document.
--Exceptions 
--DOMException
--NOT_SUPPORTED_ERR: Raised if the type of node being imported is not supported.