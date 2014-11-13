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

package dom4.utils;

import dom4.CSSSelector;

class SelectorMatching {

  static public function matches(elt: Element, selector: CSSSelector): Bool
  {
    // test all selectors in the group, exit on positive answer
    if (selector.next != null) {
      if (SelectorMatching.matches(elt, selector.next))
        return true;
    }

    if (selector == null) // sanity case
      throw (new DOMException("Unknown error, parsed selector should not be null"));

    var rv: Bool;
    var currentCombinator = COMBINATOR_NONE;
    do {
      rv = true;
      var id = elt.getAttribute("id");
      for (i in 0...selector.IDList.length) {
        var f = selector.IDList[i];
        rv = (id == f);
        if (!rv)
          break;
      }
  
      var n = elt.localName;
      if (elt.ownerDocument.documentElement.namespaceURI == Namespaces.HTML_NAMESPACE)
        n = n.toLowerCase();
      if (rv)
        for (i in 0...selector.elementTypeList.length) {
          var f = selector.elementTypeList[i];
          rv = (f == "*") || ((elt.namespaceURI == Namespaces.HTML_NAMESPACE)
                              ? n == f.toLowerCase()
                              : n == f);
          if (!rv)
            break;
        }
  
      var cl = elt.classList;
      if (rv)
        for (i in 0...selector.ClassList.length) {
          var f = selector.ClassList[i];
          rv = cl.contains(f);
          if (!rv)
            break;
        }
  
      if (rv)
        for (i in 0...selector.AttrList.length) {
          var f = selector.AttrList[i];
          rv = (elt.hasAttribute(f.name) && switch (f.operator) {
                  case ATTR_EXISTS: true;
                  case ATTR_EQUALS:        (f.caseInsensitive
                                            ? elt.getAttribute(f.name).toLowerCase() == f.value.toLowerCase()
                                            : elt.getAttribute(f.name) == f.value);
                  case ATTR_CONTAINSMATCH: (f.caseInsensitive
                                            ? (elt.getAttribute(f.name).toLowerCase().indexOf(f.value.toLowerCase()) != -1)
                                            : (elt.getAttribute(f.name).indexOf(f.value) != -1));
                  case ATTR_BEGINSMATCH:   (f.caseInsensitive
                                            ? StringTools.startsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase())
                                            : StringTools.startsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase()));
                  case ATTR_ENDSMATCH:     (f.caseInsensitive
                                            ? StringTools.endsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase())
                                            : StringTools.endsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase()));
                  case ATTR_DASHMATCH:     (f.caseInsensitive
                                            ? elt.getAttribute(f.name).toLowerCase() == f.value.toLowerCase()
                                            : elt.getAttribute(f.name) == f.value)
                                           || (f.caseInsensitive
                                               ? StringTools.startsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase() + "-")
                                               : StringTools.startsWith(elt.getAttribute(f.name).toLowerCase(), f.value.toLowerCase() + "-"));
                  case ATTR_INCLUDES:      (f.caseInsensitive
                                            ? (elt.getAttribute(f.name).toLowerCase().split(" ").indexOf(f.value.toLowerCase()) != -1)
                                            : (elt.getAttribute(f.name).split(" ").indexOf(f.value) != -1));
                });
          if (!rv)
            break;
        }

      /*
       * PSEUDO-CLASSES
       */

      if (rv && selector.combinator == COMBINATOR_NONE)
        return rv;
      if (rv) {
        currentCombinator = selector.combinator;
        switch (selector.combinator) {
          case COMBINATOR_NONE: return rv;
          case COMBINATOR_DESCENDANT
               | COMBINATOR_CHILD    :       var n = elt.parentNode;
                                             if (n != null && n.nodeType == Node.ELEMENT_NODE)
                                               elt = cast(n, Element);
                                             else
                                               return false;
                                             selector = selector.parent;
          case COMBINATOR_ADJACENT_SIBLING
               | COMBINATOR_SIBLING        : elt = elt.previousElementSibling;
                                             if (elt == null)
                                               return false;
                                             selector = selector.parent;
        }
      }
      else {
        switch (currentCombinator) {
          case COMBINATOR_NONE:             return rv; // should never happen
          case COMBINATOR_CHILD:            return false;
          case COMBINATOR_ADJACENT_SIBLING: return false;
          case COMBINATOR_SIBLING:          elt = elt.previousElementSibling;
                                            if (elt == null)
                                              return false;
          case COMBINATOR_DESCENDANT:       var n = elt.parentNode;
                                            if (n != null && n.nodeType == Node.ELEMENT_NODE)
                                              elt = cast(n, Element);
                                            else
                                              return false;
        }
      }
    } while (elt != null && true);
    
    return rv;
  }
}
