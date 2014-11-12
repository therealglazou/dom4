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

    var id = elt.getAttribute("id");
    if (selector.IDList.length != 0 && selector.IDList.filter(
            function(f) {
              return (id == f);
            }).length == 0)
      return false;

    var n = elt.localName;
    if (elt.ownerDocument.documentElement.namespaceURI == Namespaces.HTML_NAMESPACE)
      n = n.toLowerCase();
    if (selector.elementTypeList.length != 0 && selector.elementTypeList.filter(
            function(f) {
                return (f == "*") || ((elt.namespaceURI == Namespaces.HTML_NAMESPACE)
                        ? n == f.toLowerCase()
                        : n == f);
            }).length == 0)
      return false;

    var cl = elt.classList;
    if (selector.ClassList.length != 0 && selector.ClassList.filter(
            function(f) {
              return cl.contains(f);
            }).length == 0)
      return false;

    return true;
  }
}
