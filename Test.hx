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

import dom4.Document;
import dom4.Node;
import dom4.Element;
import dom4.Text;
import dom4.Comment;
import dom4.ProcessingInstruction;

import dom4.DOMParser;

class Test {

    static function main() : Void {

        var str = "<root><first>1</first> a text node <second foo='1'/><third>aaa<fourth>bbb</fourth></third><fourth/></root>";

        var parser = new DOMParser();
        try {
	        var document = parser.parseFromString(str, "text/xml"); 
	
	        trace("Return type is: " + document);
	        trace("Name of the document element is: " + document.documentElement.nodeName);
          trace("Document element has " + document.documentElement.childNodes.length + " children");
          trace("Document element has " + document.documentElement.children.length + " element children");

          trace("Document serialization:");
          trace("-----------------------");
          var indent = "  ";
          var node = cast(document.documentElement, Node);
          while (true) {
            switch (node.nodeType) {
              case Node.TEXT_NODE:
                trace(indent + "TEXT \"" + cast(node, Text).data + "\"");
              case Node.COMMENT_NODE:
                trace(indent + "COMMENT " + cast(node, Comment).data);
              case Node.PROCESSING_INSTRUCTION_NODE:
                trace(indent + "PROCESSING INSTRUCTION " + cast(node, ProcessingInstruction).data);
              case Node.ELEMENT_NODE:
                trace (indent + "ELEMENT " + node.nodeName);
                var elt = cast(node, Element);
                for (i in 0...elt.attributes.length) {
                  var attr = elt.attributes.item(i);
                  trace(indent + "  ATTRIBUTE " + attr.name + "=\"" + attr.value + "\"");
                }
            }

            if (null != node.firstChild) {
              node = node.firstChild;
              indent += "  ";
            }
            else if (null != node.nextSibling)
              node = node.nextSibling;
            else if (null == node.parentNode)
              break;
            else {
              while (null == node.nextSibling
                     && null != node.parentNode
                     && node.parentNode.nodeType == Node.ELEMENT_NODE) {
                node = node.parentNode;
                if (indent.length > 2)
                  indent = indent.substr(2);
              }
              node = node.nextSibling;
              if (null == node)
                break;
            }
          }
          trace("-----------------------");
        }
        catch(e: String) {
          Sys.println("EXCEPTION CAUGHT: " + e);
        }
    }

}

