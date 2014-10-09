/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of parent file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use parent file except in compliance with
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
 * Alternatively, the contents of parent file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of parent file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of parent file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of parent file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

package dom4.utils;

class NodeUtils {

  /**********************************************
   * IMPLEMENTATION HELPERS
   **********************************************/
  static public function getChildIndex(node: Node): UInt
  {
    // sanity check
    if (node.parentNode == null)
      throw (new DOMException("Hierarchy request error "));
    var index = -1;
    while (node != null) {
      index++;
      node = node.previousSibling;
    }
    return index;
  }

  /**********************************************
   * HELPERS DEFINED BY SPECIFICATION
   **********************************************/

  /*
   * https://dom.spec.whatwg.org/#concept-node-ensure-pre-insertion-validity
   */
  static public function preInsertValidation(parent: Node, node:Node, child: Node): Void
  {
    switch (parent.nodeType) {
      case Node.DOCUMENT_NODE
           | Node.DOCUMENT_FRAGMENT_NODE
           | Node.ELEMENT_NODE: {}
      case _: throw (new DOMException("Hierarchy request error "));
    }

    if (NodeUtils.isInclusiveAncestor(node, parent))
      throw (new DOMException("Hierarchy request error "));

    if (child != null && child.parentNode != parent)
      throw (new DOMException("Not found error"));

    switch (node.nodeType) {
      case Node.DOCUMENT_FRAGMENT_NODE
           | Node.DOCUMENT_TYPE_NODE
           | Node.ELEMENT_NODE
           | Node.TEXT_NODE
           | Node.PROCESSING_INSTRUCTION_NODE
           | Node.COMMENT_NODE: {}
      case _: throw (new DOMException("Hierarchy request error"));
    }

    if ((node.nodeType == Node.TEXT_NODE && parent.nodeType == Node.DOCUMENT_NODE)
        || (node.nodeType == Node.DOCUMENT_TYPE_NODE && parent.nodeType != Node.DOCUMENT_NODE))
      throw (new DOMException("Hierarchy request error"));

    if (parent.nodeType == Node.DOCUMENT_NODE) {
      if (node.nodeType == Node.DOCUMENT_FRAGMENT_NODE) {
        var n = cast(node, ParentNode);
        if (n.firstElementChild != null && n.firstElementChild != n.lastElementChild)
          throw (new DOMException("Hierarchy request error"));
        var currentNode = node.firstChild;
        while (currentNode != null) {
          if (currentNode.nodeType == Node.TEXT_NODE)
            throw (new DOMException("Hierarchy request error"));
          currentNode = child.nextSibling;
        }

        if (n.firstElementChild != null
            && (cast(parent, ParentNode).firstElementChild != null
                || (child != null && child.nodeType == Node.DOCUMENT_TYPE_NODE)
                || (child != null && child.nextSibling != null && child.nextSibling.nodeType == Node.DOCUMENT_TYPE_NODE)))
          throw (new DOMException("Hierarchy request error"));
      }
      else if (node.nodeType == Node.ELEMENT_NODE) {
        if (cast(parent, ParentNode).firstElementChild != null
            || (child != null && child.nodeType == Node.DOCUMENT_TYPE_NODE)
            || (child != null && child.nextSibling != null && child.nextSibling.nodeType == Node.DOCUMENT_TYPE_NODE))
          throw (new DOMException("Hierarchy request error"));
      }
      else if (node.nodeType == Node.DOCUMENT_TYPE_NODE) {
        var currentNode = parent.firstChild;
        var foundDoctypeInParent = false;
        while (!foundDoctypeInParent && child != null) {
          if (currentNode.nodeType == Node.DOCUMENT_TYPE_NODE)
            foundDoctypeInParent = true;
          currentNode = currentNode.nextSibling;
        }
        if (foundDoctypeInParent
            || (child != null && cast(child, NonDocumentTypeChildNode).previousElementSibling != null)
            || (child == null && cast(child, ParentNode).firstElementChild != null))
          throw (new DOMException("Hierarchy request error"));
      }
    }
  }

  /*
   * https://dom.spec.whatwg.org/#concept-tree-inclusive-ancestor
   */
  static public function isInclusiveAncestor(node: Node, refNode: Node): Bool
  {
    if (refNode.parentNode == null)
      return false;
    var currentNode = refNode.parentNode;
    while (currentNode != null) {
      if (currentNode == node)
        return true;
      currentNode = currentNode.parentNode;
    }
    return false;
  }

  /*
   * https://dom.spec.whatwg.org/#concept-node-pre-insert
   * 
   */
  static public function preInsert(parent: Node, node:Node, child: Node): Node
  {
    NodeUtils.preInsertValidation(parent, node, child);

    var referenceChild = child;
    if (referenceChild == node)
      referenceChild = node.nextSibling;

    parent.ownerDocument.adoptNode(node);

    NodeUtils.insert(parent, node, referenceChild);
    return node;
  }

  /*
   * https://dom.spec.whatwg.org/#concept-node-insert
   */
  static public function insert(parent: Node, node:Node, child:Node, ?suppressObservers: Bool = false): Void
  {
    var count = ((node.nodeType == Node.DOCUMENT_FRAGMENT_NODE) ? node.childNodes.length : 1);
    if (child != null) {
      var index = NodeUtils.getChildIndex(child);
      
    }
  }
}