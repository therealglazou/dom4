/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is dom4 code.
 *
 * The Initial Developer of the Original Code is
 * Disruptive Innovations SAS
 * Portions created by the Initial Developer are Copyright (C) 2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Daniel Glazman <daniel.glazman@disruptive-innovations.com>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */


package dom4;

class Element extends Node
              implements ParentNode
              implements NonDocumentTypeChildNode {

  /*
   * https://dom.spec.whatwg.org/#interface-element
   */

  /*
   * https://dom.spec.whatwg.org/#dom-element-namespaceuri
   */
  public var namespaceURI(default, null): DOMString;

  /*
   * https://dom.spec.whatwg.org/#dom-element-prefix
   */
  public var prefix(default, null): DOMString;

  /*
   * https://dom.spec.whatwg.org/#dom-element-localname
   */
  public var localName(default, null): DOMString;

  /*
   * https://dom.spec.whatwg.org/#dom-element-tagname
   */
  public var tagName(get, null): DOMString;
      private function get_tagName(): DOMString
      {
        var qualifiedName = this.localName;
        if (this.prefix != "")
          qualifiedName = this.prefix + ":" + this.localName;
        if (this.namespaceURI == DOMImplementation.HTML_NAMESPACE
            && this.ownerDocument.documentElement != null
            && this.ownerDocument.documentElement.localName.toLowerCase() == "html")
          qualifiedName = qualifiedName.toUpperCase();
        return qualifiedName;
      }

  /*
   * https://dom.spec.whatwg.org/#dom-element-id
   * XXX
   */
  public var id: DOMString;

  /*
   * https://dom.spec.whatwg.org/#dom-element-classname
   */
  public var className: DOMString;
      private function get_className(): DOMString
      {
        return this.classList.toString();
      }
      private function set_className(v: DOMString): DOMString
      {
        this.classList = new DOMTokenList(v);
        return this.classList.toString();
      }

  /*
   * https://dom.spec.whatwg.org/#dom-element-classlist
   */
  public var classList(default, null): DOMTokenList;

  /*
   * https://dom.spec.whatwg.org/#dom-element-hasattributes
   */
  public function hasAttributes(): Bool
  {
    return (this.attributes.length != 0);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-attributes
   */
  public var attributes(default, null): NamedNodeMap;

  /*
   * https://dom.spec.whatwg.org/#dom-element-getattribute
   */
  public function getAttribute(name: DOMString): DOMString
  {
    var matching = this.attributes.getNamedItem(name);
    if (matching == null)
      return null;
    return matching.value;
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-getattributens
   */
  public function getAttributeNS(?namespace: DOMString, localName: DOMString): DOMString
  {
    var matching = this.attributes.getNamedItemNS(namespace, localName);
    if (matching == null)
      return null;
    return matching.value;
  }

  /* 
   * https://dom.spec.whatwg.org/#dom-element-setattribute
   */
  public function setAttribute(name: DOMString, value: DOMString): Void
  {
    if (!DOMImplementation.NAME_EREG.match(name))
      throw "Invalid character error";

    if (!DOMImplementation.PREFIXED_NAME_EREG.match(name))
      throw "Namespace error";

    var matching = this.attributes.getNamedItem(name);
    if (matching != null) {
      matching.value = value;
      return;
    }
    var attr = new Attr(null, null, name, value);
    this.attributes.setNamedItem(attr);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-setattributens
   */
  public function setAttributeNS(?namespace: DOMString, name: DOMString, value:DOMString): Void
  {
    if (namespace == "")
      namespace = null;

    if (!DOMImplementation.NAME_EREG.match(name))
      throw "Invalid character error";

    if (!DOMImplementation.PREFIXED_NAME_EREG.match(name))
      throw "Namespace error";

    var prefix = null;
    var localName = name;

    var colonPosition = name.indexOf(":");
    if (colonPosition != -1) {
      prefix = name.substr(0, colonPosition);
      localName = name.substr(colonPosition + 1);
    }

    if (prefix != null && namespace == null)
      throw "Namespace error";
      
    if (prefix == "xml" && namespace != DOMImplementation.XML_NAMESPACE)
      throw "Namespace error";

    if (namespace != DOMImplementation.XMLNS_NAMESPACE
        && (name == "xmlns"
            || prefix == "xmlns"))
      throw "Namespace error";

    if (namespace == DOMImplementation.XMLNS_NAMESPACE
        && name != "xmlns"
        && prefix != "xmlns")
      throw "Namespace error";

    var attr = new Attr(namespace, prefix, localName, value);
    this.attributes.setNamedItem(attr);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-removeattribute
   */
  public function removeAttribute(name: DOMString): Void
  {
    this.attributes.removeNamedItem(name);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-removeattributens
   */
  public function removeAttributeNS(?namespace: DOMString, localName: DOMString): Void
  {
    this.attributes.removeNamedItemNS(namespace, localName);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-hasattribute
   */
  public function hasAttribute(name: DOMString): Bool
  {
    return (null != this.attributes.getNamedItem(name));
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-hasattributens
   */
  public function hasAttributeNS(?namespace: DOMString, localName: DOMString): Bool
  {
    return (null != this.attributes.getNamedItemNS(namespace, localName));
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-getattributenode
   */
  public function getAttributeNode(name: DOMString): Attr
  {
    return this.attributes.getNamedItem(name);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-getattributenodens
   */
  public function getAttributeNodeNS(?namespace: DOMString, localName: DOMString): Attr
  {
    return this.attributes.getNamedItemNS(namespace, localName);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-setattributenode
   */
  public function setAttributeNode(attr: Attr): Attr
  {
    return this.attributes.setNamedItem(attr);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-setattributenode
   */
  public function setAttributeNodeNS(attr: Attr): Attr
  {
    return this.attributes.setNamedItemNS(attr);
  }

  /*
   * https://dom.spec.whatwg.org/#dom-element-removeattributenode
   */
  public function removeAttributeNode(attr:Attr): Attr
  {
    return this.attributes.removeAttributeNode(attr);
  }

  public var previousElementSibling(get, null): Node;
      private function get_previousElementSibling(): Node
      {
        return NonDocumentTypeChildNodeImpl.previousElementSibling(this);
      }
  public var nextElementSibling(get, null): Node;
      private function get_nextElementSibling(): Node
      {
        return NonDocumentTypeChildNodeImpl.nextElementSibling(this);
      }

  public var firstElementChild(get, null): Node;
      private function get_firstElementChild(): Node
      {
        return ParentNodeImpl.firstElementChild(this);
      }
  public var lastElementChild(get, null): Node;
      private function get_lastElementChild(): Node
      {
        return ParentNodeImpl.lastElementChild(this);
      }
  public var children(get, null): HTMLCollection;
      private function get_children(): HTMLCollection
      {
        return ParentNodeImpl.children(this);
      }

  public function new(namespace: DOMString, localName: DOMString, ?prefix: DOMString = "") {
    super();
    this.attributes = new NamedNodeMap();
    this.namespaceURI = namespace;
    this.localName = localName;
    this.prefix = prefix;
    this.nodeType = Node.ELEMENT_NODE;
  }
}
